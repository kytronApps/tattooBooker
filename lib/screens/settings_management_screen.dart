import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';
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

  // 🔹 Cargar configuración del usuario
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

      final workingDaysData = data['workingDays'] as Map<String, dynamic>? ?? {};
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

      // Asegurar que todos los días tengan valores por defecto para poder editar/guardar fácilmente
      final orderedDays = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo'
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

  // 🔹 Guardar cambios
  Future<void> _saveSettingsToFirestore() async {
    if (_userId == null) return;
    try {
      final dataToUpdate = {
        'workingDays': _workingDays,
        'startTimes': _startTimes.map((k, v) =>
            MapEntry(k, '${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}')),
        'endTimes': _endTimes.map((k, v) =>
            MapEntry(k, '${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}')),
        'blockedDates': _blockedDates.map((d) => d.toIso8601String()).toList(),
      };

      await _firestore.collection('usuarios').doc(_userId).update(dataToUpdate);

      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(
              'Configuración guardada correctamente',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error guardando configuración: $e');
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar los cambios',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.onError,
              ),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  // 🔹 Cerrar sesión
  void logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔸 Header fijo superior
            Row(
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
                  onPressed: () => logout(context),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  tooltip: 'Cerrar sesión',
                ),
              ],
            ),

            // 🔸 Tabs principales
            _buildTabBar(),
            SizedBox(height: 1.h),

            // 🔸 Contenido
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWorkingHoursTab(),
                  _buildBlockedDatesTab(),
                  _buildHistoryTab(), // 👈 Aquí se añadió el histórico
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Tabs
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
        unselectedLabelColor:
            AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.6),
        tabs: const [
          Tab(text: 'Horarios'),
          Tab(text: 'Bloqueados'),
          Tab(text: 'Histórico'),
        ],
      ),
    );
  }

  // 🔹 Tab Horarios
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

  // 🔹 Tab Bloqueados
  Widget _buildBlockedDatesTab() {
    return SingleChildScrollView(
      child: BlockedDatesWidget(
        blockedDates: _blockedDates,
        onDateBlocked: (date) async {
          setState(() => _blockedDates.add(date));
          await _saveSettingsToFirestore(); // 🔥 Guarda cambio inmediato
        },
        onDateUnblocked: (date) async {
          setState(() => _blockedDates.remove(date));
          await _saveSettingsToFirestore(); // 🔥 Persistencia instantánea
        },
      ),
    );
  }

  // 🔹 Tab Histórico
  Widget _buildHistoryTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('appointments_history')
          .orderBy('movedToHistoryAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded,
                      size: 40.sp,
                      color:
                          AppTheme.lightTheme.colorScheme.onSurfaceVariant),
                  SizedBox(height: 2.h),
                  Text(
                    'Sin citas en el histórico',
                    style:
                        AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color:
                          AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Las citas canceladas aparecerán aquí automáticamente.',
                    textAlign: TextAlign.center,
                    style:
                        AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.only(top: 1.h),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final client = data['clientName'] ?? 'Cliente desconocido';
            final service = data['serviceType'] ?? 'Servicio';
            final time = data['timeSlot'] ?? '--:--';
            final date = data['date'] ?? 'Sin fecha';

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              elevation: AppTheme.elevationLow,
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client,
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Icon(Icons.design_services_rounded,
                            color: AppTheme.lightTheme.colorScheme
                                .onSurfaceVariant,
                            size: 4.w),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            service,
                            style:
                                AppTheme.lightTheme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            color: AppTheme.lightTheme.colorScheme
                                .onSurfaceVariant,
                            size: 4.w),
                        SizedBox(width: 2.w),
                        Text(time,
                            style:
                                AppTheme.lightTheme.textTheme.bodyMedium),
                        SizedBox(width: 3.w),
                        Icon(Icons.calendar_today,
                            color: AppTheme.lightTheme.colorScheme
                                .onSurfaceVariant,
                            size: 4.w),
                        SizedBox(width: 2.w),
                        Text(date,
                            style:
                                AppTheme.lightTheme.textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}