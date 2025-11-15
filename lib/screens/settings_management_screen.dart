import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../widgets/working_hours_widget.dart';
import '../widgets/blocked_dates_widget.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/settings_management_widget.dart';

class SettingsManagementScreen extends StatefulWidget {
  const SettingsManagementScreen({super.key});

  @override
  State<SettingsManagementScreen> createState() =>
      _SettingsManagementScreenState();
}

class _SettingsManagementScreenState extends State<SettingsManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  String? _userId;
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

  // -------------------------------------------------------------
  // 🔹 Cargar configuración del usuario (Only once)
  // -------------------------------------------------------------
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

      final workingDaysData =
          data['workingDays'] as Map<String, dynamic>? ?? {};
      _workingDays = workingDaysData.map((k, v) => MapEntry(k, v == true));

      final startTimesData = data['startTimes'] as Map<String, dynamic>? ?? {};
      final endTimesData = data['endTimes'] as Map<String, dynamic>? ?? {};

      _startTimes = startTimesData.map((day, timeString) {
        final parts = (timeString as String).split(':');
        return MapEntry(
          day,
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
        );
      });

      _endTimes = endTimesData.map((day, timeString) {
        final parts = (timeString as String).split(':');
        return MapEntry(
          day,
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
        );
      });

      // Asegurar días
      const orderedDays = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo',
      ];

      for (final day in orderedDays) {
        _startTimes.putIfAbsent(day, () => const TimeOfDay(hour: 9, minute: 0));
        _endTimes.putIfAbsent(day, () => const TimeOfDay(hour: 18, minute: 0));
        _workingDays.putIfAbsent(day, () => false);
      }

      final blockedDatesData = data['blockedDates'] as List<dynamic>? ?? [];
      _blockedDates = blockedDatesData
          .map((timestamp) => DateTime.parse(timestamp.toString()))
          .toSet();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('⚠️ Error cargando configuración: $e');
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: const Text('Error al cargar la configuración'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  // -------------------------------------------------------------
  // 🔹 Guardar cambios automáticamente
  // -------------------------------------------------------------
  Future<void> _saveSettingsToFirestore() async {
    if (_userId == null) return;
    try {
      await _firestore.collection('usuarios').doc(_userId!).update({
        'workingDays': _workingDays,
        'startTimes': _startTimes.map(
          (k, v) => MapEntry(
            k,
            '${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}',
          ),
        ),
        'endTimes': _endTimes.map(
          (k, v) => MapEntry(
            k,
            '${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}',
          ),
        ),
        'blockedDates': _blockedDates.map((d) => d.toIso8601String()).toList(),
      });

      CustomSnackBar.show(context, message: "Configuración guardada");
    } catch (e) {
      debugPrint("❌ Error guardando configuración: $e");
    }
  }

  // -------------------------------------------------------------
  // UI PRINCIPAL
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            SizedBox(height: 1.h),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWorkingHoursTab(),
                  _buildBlockedDatesTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔹 Header
  // -------------------------------------------------------------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Configuración',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          icon: const Icon(Icons.logout, color: Colors.redAccent),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 🔹 Tabs principales
  // -------------------------------------------------------------
  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
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
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface
            .withOpacity(0.6),
        tabs: const [
          Tab(text: 'Horarios'),
          Tab(text: 'Bloqueados'),
          Tab(text: 'Histórico'),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔹 Tab Horarios
  // -------------------------------------------------------------
  Widget _buildWorkingHoursTab() {
    return SingleChildScrollView(
      child: WorkingHoursWidget(
        workingDays: _workingDays,
        startTimes: _startTimes,
        endTimes: _endTimes,
        onWorkingDayChanged: (day, value) async {
          setState(() => _workingDays[day] = value);
          await _saveSettingsToFirestore();
        },
        onStartTimeChanged: (day, time) async {
          setState(() => _startTimes[day] = time);
          await _saveSettingsToFirestore();
        },
        onEndTimeChanged: (day, time) async {
          setState(() => _endTimes[day] = time);
          await _saveSettingsToFirestore();
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔹 Tab Fechas Bloqueadas
  // -------------------------------------------------------------
  Widget _buildBlockedDatesTab() {
    return SingleChildScrollView(
      child: BlockedDatesWidget(
        blockedDates: _blockedDates,
        onDateBlocked: (date) async {
          setState(() => _blockedDates.add(date));
          await _saveSettingsToFirestore();
        },
        onDateUnblocked: (date) async {
          setState(() => _blockedDates.remove(date));
          await _saveSettingsToFirestore();
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔹 Tab HISTÓRICO — Citas + Links
  // -------------------------------------------------------------
  Widget _buildHistoryTab() {
  return DefaultTabController(
    length: 2,
    child: Column(
      children: [
        Container(
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
          child: const TabBar(
            tabs: [
              Tab(text: "Citas"),
              Tab(text: "Links"),
            ],
          ),
        ),

        SizedBox(height: 1.h),

        Expanded(
          child: TabBarView(
            children: [
              _buildAppointmentsHistory(),
              _buildLinksHistory(),
            ],
          ),
        ),
      ],
    ),
  );
}

  // -------------------------------------------------------------
  // 🔹 HISTÓRICO — CITAS
  // -------------------------------------------------------------
  Widget _buildAppointmentsHistory() {
  return HistoryList(
    firestore: _firestore,
    collection: "appointments_history",
    emptyMessage: "Sin citas en el histórico",
    orderByField: "movedToHistoryAt",
    buildCard: (data) {
      return HistoryCard(
        title: data["clientName"] ?? "Cliente",
        subtitle: data["serviceType"] ?? "Servicio",
        date: data["date"] ?? "",
        time: data["timeSlot"] ?? "--",
        onDelete: () async {
          await _firestore
              .collection("appointments_history")
              .doc(data["id"])
              .delete();

          CustomSnackBar.show(context,
              message: "Cita eliminada del histórico");
        },
      );
    },
  );
}

  // -------------------------------------------------------------
  // 🔹 HISTÓRICO — LINKS REVOCADOS
  // -------------------------------------------------------------
  Widget _buildLinksHistory() {
  return HistoryList(
    firestore: _firestore,
    collection: "booking_links_history",
    emptyMessage: "Sin links revocados",
    orderByField: "revokedAt",
    buildCard: (data) {
      final token = data["editToken"] ?? "—";
      final linkUrl = "https://kytron-apps.web.app/book/$token";

      return HistoryCard(
        title: linkUrl,
        subtitle: "Link revocado",
        date: data["revokedAt"]?.toString().split("T").first ?? "",
        time: "",
        onDelete: () async {
          await _firestore
              .collection("booking_links_history")
              .doc(data["id"])
              .delete();

          CustomSnackBar.show(context,
              message: "Link eliminado del histórico");
        },
      );
    },
  );
}

  // -------------------------------------------------------------
  // 🔹 CARD ELEGANTE DEL HISTÓRICO
  // -------------------------------------------------------------
  Widget _historyCard({
    required String title,
    required String subtitle,
    required String date,
    required String time,
    required VoidCallback onDelete,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 1.5.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),

            SizedBox(height: 0.4.h),

            Text(subtitle, style: AppTheme.lightTheme.textTheme.bodySmall),

            SizedBox(height: 1.h),

            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 4.w,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 2.w),
                Text(date),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔹 Estado vacío elegante
  // -------------------------------------------------------------
  Widget _emptyHistory(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 40.sp,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 2.h),
          Text(message, style: AppTheme.lightTheme.textTheme.titleMedium),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔹 Eliminar item del histórico
  // -------------------------------------------------------------
  Future<void> _deleteHistoryItem(String collection, String id) async {
    await _firestore.collection(collection).doc(id).delete();
    CustomSnackBar.show(context, message: "Elemento eliminado del histórico");
  }
}
