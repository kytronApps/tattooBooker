import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_export.dart';
import '../widgets/working_hours_widget.dart';
import '../widgets/blocked_dates_widget.dart';

class SettingsManagementScreen extends StatefulWidget {
  const SettingsManagementScreen({Key? key}) : super(key: key);

  @override
  State<SettingsManagementScreen> createState() =>
      _SettingsManagementScreenState();
}

class _SettingsManagementScreenState extends State<SettingsManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  String? _userId; // ID del admin
  Map<String, bool> _workingDays = {};
  Map<String, TimeOfDay> _startTimes = {};
  Map<String, TimeOfDay> _endTimes = {};
  Set<DateTime> _blockedDates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No se encontró un usuario administrador.');
      }

      final userDoc = snapshot.docs.first;
      _userId = userDoc.id;
      final data = userDoc.data();

      // Días laborales
      final workingDaysData = data['workingDays'] as Map<String, dynamic>? ?? {};
      _workingDays = workingDaysData.map((k, v) => MapEntry(k, v == true));

      // Horarios
      final startTimesData = data['startTimes'] as Map<String, dynamic>? ?? {};
      final endTimesData = data['endTimes'] as Map<String, dynamic>? ?? {};

      _startTimes = startTimesData.map((day, timeString) {
        final parts = (timeString as String).split(':');
        return MapEntry(
          day,
          TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          ),
        );
      });

      _endTimes = endTimesData.map((day, timeString) {
        final parts = (timeString as String).split(':');
        return MapEntry(
          day,
          TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          ),
        );
      });

      // Días bloqueados
      final blockedDatesData = data['blockedDates'] as List<dynamic>? ?? [];
      _blockedDates = blockedDatesData
          .map((timestamp) => DateTime.parse(timestamp.toString()))
          .toSet();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('⚠️ Error cargando configuración: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar la configuración'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  Future<void> _saveSettingsToFirestore() async {
    if (_userId == null) return;

    try {
      final dataToUpdate = {
        'workingDays': _workingDays,
        'startTimes': _startTimes.map((k, v) =>
            MapEntry(k, '${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}')),
        'endTimes': _endTimes.map((k, v) =>
            MapEntry(k, '${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}')),
        'blockedDates':
            _blockedDates.map((d) => d.toIso8601String()).toList(),
      };

      await _firestore.collection('usuarios').doc(_userId).update(dataToUpdate);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Configuración guardada correctamente ✅'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error guardando configuración: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar cambios'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 🔹 Pantalla principal
@override
Widget build(BuildContext context) {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return Scaffold(
    backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
    appBar: AppBar(
      title: const Text("Configuración"),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/admin-login-screen'),
        ),
      ],
    ),
    body: Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildWorkingHoursTab(),
              _buildBlockedDatesTab(),
            ],
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _saveSettingsToFirestore,
      label: const Text('Guardar'),
      icon: const Icon(Icons.save),
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
    ),
  );
}

Widget _buildTabBar() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
    decoration: BoxDecoration(
      color: AppTheme.lightTheme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      boxShadow: [
        BoxShadow(
          color: AppTheme.shadowLight,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TabBar(
      controller: _tabController,
      indicator: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
      unselectedLabelColor:
          AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.6),
      tabs: const [
        Tab(text: 'Horarios'),
        Tab(text: 'Bloqueados'),
      ],
    ),
  );
}

  // 🔸 Tab Logout
  Widget _buildLogoutTab() => Center(
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushReplacementNamed(context, '/admin-login-screen'),
          icon: const Icon(Icons.exit_to_app),
          label: const Text('Cerrar Sesión'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          ),
        ),
      );

  // 🔸 Tab Horarios
  Widget _buildWorkingHoursTab() {
    return SingleChildScrollView(
      child: WorkingHoursWidget(
        workingDays: _workingDays,
        startTimes: _startTimes,
        endTimes: _endTimes,
        onWorkingDayChanged: (day, value) =>
            setState(() => _workingDays[day] = value),
        onStartTimeChanged: (day, time) =>
            setState(() => _startTimes[day] = time),
        onEndTimeChanged: (day, time) =>
            setState(() => _endTimes[day] = time),
      ),
    );
  }

  // 🔸 Tab Bloqueados
  Widget _buildBlockedDatesTab() {
    return SingleChildScrollView(
      child: BlockedDatesWidget(
        blockedDates: _blockedDates,
        onDateBlocked: (date) =>
            setState(() => _blockedDates.add(date)),
        onDateUnblocked: (date) =>
            setState(() => _blockedDates.remove(date)),
      ),
    );
  }
}