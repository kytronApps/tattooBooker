import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/calendar_sync_service.dart';
import '../services/appointment_actions_service.dart';
import '../screens/settings_management_screen.dart';

import '../../core/app_export.dart';
import '../widgets/appointment_card_widget.dart';
import '../widgets/dashboard_header_widget.dart';
import '../widgets/date_section_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/sync_indicator_widget.dart';
import '../screens/calendar_management_screen.dart';

class AppointmentDashboard extends StatefulWidget {
  const AppointmentDashboard({Key? key}) : super(key: key);

  @override
  State<AppointmentDashboard> createState() => _AppointmentDashboardState();
}

class _AppointmentDashboardState extends State<AppointmentDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearchExpanded = false;
  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 5));
  String _searchQuery = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CalendarSyncService _calendarService = CalendarSyncService();
  final AppointmentActionsService _appointmentService = AppointmentActionsService();

  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _filteredAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _listenAppointmentsRealtime(); // 🔥 Escucha en tiempo real
    _simulateNetworkStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 🔹 Escucha en tiempo real las citas activas
  void _listenAppointmentsRealtime() {
    _firestore
        .collection('appointments')
        .where('status', isNotEqualTo: 'cancelado')
        .snapshots()
        .listen((snapshot) {
      final appointments = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _appointments = appointments;
        _filteredAppointments = _applySearchFilter(appointments, _searchQuery);
      });
    });
  }

  // 🔍 Filtrado por búsqueda
  List<Map<String, dynamic>> _applySearchFilter(
      List<Map<String, dynamic>> list, String query) {
    if (query.isEmpty) return List.from(list);

    final searchLower = query.toLowerCase();
    return list.where((appointment) {
      final client = (appointment['clientName'] ?? '').toString().toLowerCase();
      final service =
          (appointment['serviceType'] ?? '').toString().toLowerCase();
      return client.contains(searchLower) || service.contains(searchLower);
    }).toList();
  }

  void _filterAppointments(String query) {
    setState(() {
      _searchQuery = query;
      _filteredAppointments = _applySearchFilter(_appointments, query);
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _filteredAppointments = List.from(_appointments);
    });
  }

  void _simulateNetworkStatus() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) setState(() => _isOnline = false);
    });
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _isOnline = true;
          _lastSyncTime = DateTime.now();
        });
      }
    });
  }

  Future<void> _refreshAppointments() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 300));
    Fluttertoast.showToast(
      msg: "Actualizado 🔄",
      backgroundColor: AppTheme.successColor,
      textColor: Colors.white,
    );
  }

  Future<void> _moveToHistory(Map<String, dynamic> appointment) async {
    try {
      await _firestore
          .collection('appointments_history')
          .doc(appointment['id'])
          .set({
        ...appointment,
        'movedToHistoryAt': DateTime.now().toIso8601String(),
      });

      await _firestore.collection('appointments').doc(appointment['id']).delete();
      debugPrint("📦 Cita movida al histórico: ${appointment['id']}");
    } catch (e) {
      debugPrint("❌ Error moviendo cita al histórico: $e");
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupAppointmentsByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final appointment in _filteredAppointments) {
      final date = (appointment['date'] ?? 'Sin fecha').toString();
      grouped.putIfAbsent(date, () => []).add(appointment);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (var k in sortedKeys) k: grouped[k]!};
  }

  @override
  Widget build(BuildContext context) {
    final groupedAppointments = _groupAppointmentsByDate();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          DashboardHeaderWidget(
            studioName: "TattooBooker",
            currentDate: (() {
              final now = DateTime.now();
              const days = [
                'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
              ];
              const months = [
                'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
              ];
              final dayName = days[(now.weekday - 1) % 7];
              final monthName = months[(now.month - 1) % 12];
              return '$dayName, ${now.day} de $monthName ${now.year}';
            })(),
            notificationCount: 3,
            onNotificationTap: () {},
          ),
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'Calendario'),
                Tab(text: 'Links'),
                Tab(text: 'Ajustes'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 🗓 Dashboard principal
                Column(
                  children: [
                    if (!_isOnline || _isSyncing)
                      SyncIndicatorWidget(
                        isOnline: _isOnline,
                        isSyncing: _isSyncing,
                        lastSyncTime: _lastSyncTime,
                        onRetrySync: _refreshAppointments,
                      ),
                    SearchBarWidget(
                      isExpanded: _isSearchExpanded,
                      onToggle: () =>
                          setState(() => _isSearchExpanded = !_isSearchExpanded),
                      onChanged: _filterAppointments,
                      onClear: _clearSearch,
                    ),
                    SizedBox(height: 1.h),
                    Expanded(
                      child: _filteredAppointments.isEmpty
                          ? SingleChildScrollView(
                              child: EmptyStateWidget(
                                title: _searchQuery.isNotEmpty
                                    ? 'No se encontraron citas'
                                    : 'No hay citas programadas',
                                subtitle: _searchQuery.isNotEmpty
                                    ? 'Prueba con otro término de búsqueda'
                                    : 'Comienza creando tu primera cita',
                                buttonText: _searchQuery.isNotEmpty
                                    ? 'Limpiar Búsqueda'
                                    : 'Nueva Cita',
                                onButtonPressed: _searchQuery.isNotEmpty
                                    ? _clearSearch
                                    : () => Fluttertoast.showToast(
                                          msg: "Abrir formulario de cita",
                                        ),
                                illustrationUrl:
                                    "https://images.pexels.com/photos/6801648/pexels-photo-6801648.jpeg?auto=compress&cs=tinysrgb&w=800",
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _refreshAppointments,
                              color: AppTheme.lightTheme.colorScheme.primary,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: groupedAppointments.length,
                                itemBuilder: (context, index) {
                                  final date =
                                      groupedAppointments.keys.elementAt(index);
                                  final appointments =
                                      groupedAppointments[date]!;
                                  final first = appointments.first;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      DateSectionWidget(
                                        date: date,
                                        dayOfWeek: first['dayOfWeek'] ?? '',
                                        appointmentCount: appointments.length,
                                      ),
                                      ...appointments.map(
                                        (a) => AppointmentCardWidget(
                                          appointment: a,
                                          // 🔹 Cancelar → mover al histórico
                                          onCancel: () async {
                                            await _appointmentService
                                                .cancelAppointment(
                                                    context, a['id']);
                                            await _moveToHistory(a);
                                          },
                                          // 🔹 Eliminar
                                          onDelete: () async {
                                            await _appointmentService
                                                .deleteAppointment(
                                                    context, a['id']);
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                    ],
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
                const CalendarManagementScreen(),
                const Center(child: Text("Gestión de Links (próximamente)")),
                const SettingsManagementScreen(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () =>
                  Fluttertoast.showToast(msg: "Crear nueva cita 🖋️"),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              child: Icon(
                Icons.add,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 8.w,
              ),
            )
          : null,
    );
  }
}