import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/calendar_sync_service.dart';
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
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _filteredAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchAppointments();
    _simulateNetworkStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isSyncing = true);

    try {
      final snapshot = await _firestore.collection('appointments').get();
      _appointments = snapshot.docs.map((doc) {
        final data = doc.data();
        // Valores por defecto para evitar errores de tipo Null
        data['clientName'] = data['clientName'] ?? '';
        data['serviceType'] = data['serviceType'] ?? '';
        data['date'] = data['date'] ?? 'Sin fecha';
        data['dayOfWeek'] = data['dayOfWeek'] ?? '';
        data['status'] = data['status'] ?? 'pendiente';
        data['price'] = data['price'] ?? '';
        data['timeSlot'] = data['timeSlot'] ?? '';
        data['phone'] = data['phone'] ?? '';
        data['email'] = data['email'] ?? '';
        data['id'] = doc.id;
        return data;
      }).toList();

      _filteredAppointments = List.from(_appointments);

      print("🔹 ${_appointments.length} citas cargadas desde Firestore");
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error al cargar las citas: $e",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
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

  void _filterAppointments(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredAppointments = List.from(_appointments);
      } else {
        _filteredAppointments = _appointments.where((appointment) {
          final clientName = (appointment['clientName'] ?? '').toString().toLowerCase();
          final serviceType = (appointment['serviceType'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return clientName.contains(searchLower) ||
              serviceType.contains(searchLower);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _filteredAppointments = List.from(_appointments);
    });
  }

  Future<void> _refreshAppointments() async {
    HapticFeedback.lightImpact();
    await _fetchAppointments();

    Fluttertoast.showToast(
      msg: "Citas actualizadas desde Firestore",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successColor,
      textColor: Colors.white,
    );
  }

  void _retrySync() => _refreshAppointments();

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.borderRadiusLarge)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Notificaciones',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: CustomIconWidget(
                    iconName: 'schedule',
                    color: AppTheme.warningColor,
                    size: 5.w,
                  ),
                ),
                title: const Text('Cita pendiente de confirmación'),
                subtitle: const Text('Carlos Ruiz - Mañana 14:30'),
                trailing: Text('2 min',
                    style: AppTheme.lightTheme.textTheme.labelSmall),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onAppointmentTap(Map<String, dynamic> appointment) {
    Navigator.pushNamed(
      context,
      '/appointment-detail-modal',
      arguments: appointment,
    );
  }

  void _onEditAppointment(Map<String, dynamic> appointment) {
    Fluttertoast.showToast(
      msg: "Editando cita de ${appointment['clientName']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onCancelAppointment(Map<String, dynamic> appointment) {
    setState(() {
      final index =
          _appointments.indexWhere((a) => a['id'] == appointment['id']);
      if (index != -1) {
        _appointments[index]['status'] = 'cancelado';
        _filterAppointments(_searchQuery);
      }
    });

    Fluttertoast.showToast(
      msg: "Cita cancelada: ${appointment['clientName']}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.warningColor,
      textColor: Colors.white,
    );
  }

  void _onDeleteAppointment(Map<String, dynamic> appointment) {
    setState(() {
      _appointments.removeWhere((a) => a['id'] == appointment['id']);
      _filterAppointments(_searchQuery);
    });

    Fluttertoast.showToast(
      msg: "Cita eliminada: ${appointment['clientName']}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: Colors.white,
    );
  }

  void _onSendReminder(Map<String, dynamic> appointment) {
    Fluttertoast.showToast(
      msg: "Recordatorio enviado a ${appointment['clientName']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.infoColor,
      textColor: Colors.white,
    );
  }

  Future<void> _syncAppointmentsToCalendar() async {
    setState(() => _isSyncing = true);
    try {
      for (var appointment in _appointments) {
        final date = DateTime.tryParse((appointment['date'] ?? '').toString());
        if (date == null) continue;
        final timeSlot = (appointment['timeSlot'] ?? '').toString();

        final times = timeSlot.split('-').map((e) => e.trim()).toList();
        if (times.length == 2) {
          final startParts = times[0].split(':');
          final endParts = times[1].split(':');

          final start = DateTime(
            date.year,
            date.month,
            date.day,
            int.tryParse(startParts[0]) ?? 0,
            int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0,
          );
          final end = DateTime(
            date.year,
            date.month,
            date.day,
            int.tryParse(endParts[0]) ?? 0,
            int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0,
          );

          await _calendarService.addAppointmentToCalendar(
            title: '${appointment['clientName']} - ${appointment['serviceType']}',
            description: 'Teléfono: ${appointment['phone']}',
            startTime: start,
            endTime: end,
          );
        }
      }

      Fluttertoast.showToast(
        msg: "Citas sincronizadas con el calendario 📅",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error al sincronizar calendario: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _createNewAppointment() {
    Fluttertoast.showToast(
      msg: "Abriendo formulario de nueva cita",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
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
            onNotificationTap: _showNotifications,
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
                // Dashboard
                Column(
                  children: [
                    if (!_isOnline || _isSyncing)
                      SyncIndicatorWidget(
                        isOnline: _isOnline,
                        isSyncing: _isSyncing,
                        lastSyncTime: _lastSyncTime,
                        onRetrySync: _retrySync,
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
                                    ? 'Intenta con otros términos de búsqueda o revisa la ortografía.'
                                    : 'Comienza creando tu primera cita para gestionar las reservas.',
                                buttonText: _searchQuery.isNotEmpty
                                    ? 'Limpiar Búsqueda'
                                    : 'Crear Primera Cita',
                                onButtonPressed: _searchQuery.isNotEmpty
                                    ? _clearSearch
                                    : _createNewAppointment,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DateSectionWidget(
                                        date: date,
                                        dayOfWeek: first['dayOfWeek'] ?? '',
                                        appointmentCount: appointments.length,
                                      ),
                                      ...appointments.map((a) =>
                                          AppointmentCardWidget(
                                            appointment: a,
                                            onTap: () => _onAppointmentTap(a),
                                            onEdit: () => _onEditAppointment(a),
                                            onCancel: () =>
                                                _onCancelAppointment(a),
                                            onDelete: () =>
                                                _onDeleteAppointment(a),
                                            onSendReminder: () =>
                                                _onSendReminder(a),
                                          )),
                                      SizedBox(height: 1.h),
                                    ],
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
                // Calendario
                const CalendarManagementScreen(),
                // Links
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'link',
                        size: 20.w,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Gestión de Links',
                        style: AppTheme.lightTheme.textTheme.headlineSmall,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Próximamente disponible',
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Ajustes
                // Ajustes
const SettingsManagementScreen(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _createNewAppointment,
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