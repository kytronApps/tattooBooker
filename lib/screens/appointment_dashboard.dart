import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../widgets/appointment_card_widget.dart';
import '../widgets/dashboard_header_widget.dart';
import '../widgets/date_section_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/sync_indicator_widget.dart';

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
  List<Map<String, dynamic>> _filteredAppointments = [];

  // Mock data for appointments
  final List<Map<String, dynamic>> _mockAppointments = [
    {
      "id": 1,
      "clientName": "María González",
      "clientAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1beb9fc75-1762273370028.png",
      "clientAvatarSemanticLabel":
          "Professional headshot of a young Hispanic woman with long dark hair wearing a white blouse",
      "serviceType": "Tatuaje Tradicional",
      "timeSlot": "10:00 - 12:00",
      "price": "150€",
      "status": "confirmado",
      "date": "2025-11-06",
      "dayOfWeek": "Miércoles",
      "phone": "+34 612 345 678",
      "email": "maria.gonzalez@email.com",
    },
    {
      "id": 2,
      "clientName": "Carlos Ruiz",
      "clientAvatar":
          "https://images.unsplash.com/photo-1724225618359-a1d2763326f9",
      "clientAvatarSemanticLabel":
          "Portrait of a young man with short brown hair and beard wearing a dark casual shirt",
      "serviceType": "Retoque de Color",
      "timeSlot": "14:30 - 15:30",
      "price": "80€",
      "status": "pendiente",
      "date": "2025-11-06",
      "dayOfWeek": "Miércoles",
      "phone": "+34 687 123 456",
      "email": "carlos.ruiz@email.com",
    },
    {
      "id": 3,
      "clientName": "Ana Martín",
      "clientAvatar":
          "https://images.unsplash.com/photo-1681431276801-2a39191882a7",
      "clientAvatarSemanticLabel":
          "Close-up portrait of a woman with blonde hair and blue eyes wearing a light colored top",
      "serviceType": "Diseño Personalizado",
      "timeSlot": "16:00 - 18:00",
      "price": "200€",
      "status": "confirmado",
      "date": "2025-11-07",
      "dayOfWeek": "Jueves",
      "phone": "+34 654 987 321",
      "email": "ana.martin@email.com",
    },
    {
      "id": 4,
      "clientName": "David López",
      "clientAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_11902ba28-1762249079503.png",
      "clientAvatarSemanticLabel":
          "Professional photo of a man with dark hair wearing a navy blue suit jacket",
      "serviceType": "Tatuaje Minimalista",
      "timeSlot": "11:00 - 12:30",
      "price": "120€",
      "status": "cancelado",
      "date": "2025-11-07",
      "dayOfWeek": "Jueves",
      "phone": "+34 698 456 789",
      "email": "david.lopez@email.com",
    },
    {
      "id": 5,
      "clientName": "Laura Fernández",
      "clientAvatar":
          "https://images.unsplash.com/photo-1606142184213-dac814cef071",
      "clientAvatarSemanticLabel":
          "Portrait of a young woman with curly brown hair wearing a striped shirt smiling at camera",
      "serviceType": "Consulta de Diseño",
      "timeSlot": "09:30 - 10:30",
      "price": "50€",
      "status": "pendiente",
      "date": "2025-11-08",
      "dayOfWeek": "Viernes",
      "phone": "+34 623 789 456",
      "email": "laura.fernandez@email.com",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _filteredAppointments = List.from(_mockAppointments);
    _simulateNetworkStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _simulateNetworkStatus() {
    // Simulate network status changes
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
      }
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
        _filteredAppointments = List.from(_mockAppointments);
      } else {
        _filteredAppointments = _mockAppointments.where((appointment) {
          final clientName =
              (appointment['clientName'] as String).toLowerCase();
          final serviceType =
              (appointment['serviceType'] as String).toLowerCase();
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
      _filteredAppointments = List.from(_mockAppointments);
    });
  }

  Future<void> _refreshAppointments() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isSyncing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _lastSyncTime = DateTime.now();
        _isOnline = true;
      });

      Fluttertoast.showToast(
        msg: "Citas actualizadas correctamente",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
      );
    }
  }

  void _retrySync() {
    _refreshAppointments();
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
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
                trailing: Text(
                  '2 min',
                  style: AppTheme.lightTheme.textTheme.labelSmall,
                ),
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: CustomIconWidget(
                    iconName: 'event_available',
                    color: AppTheme.infoColor,
                    size: 5.w,
                  ),
                ),
                title: const Text('Nueva solicitud de cita'),
                subtitle: const Text('Laura Fernández - Consulta de diseño'),
                trailing: Text(
                  '5 min',
                  style: AppTheme.lightTheme.textTheme.labelSmall,
                ),
              ),
              SizedBox(height: 2.h),
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
          _mockAppointments.indexWhere((a) => a['id'] == appointment['id']);
      if (index != -1) {
        _mockAppointments[index]['status'] = 'cancelado';
        _filterAppointments(_searchQuery);
      }
    });

    Fluttertoast.showToast(
      msg: "Cita cancelada. Email enviado a ${appointment['clientName']}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.warningColor,
      textColor: Colors.white,
    );
  }

  void _onDeleteAppointment(Map<String, dynamic> appointment) {
    setState(() {
      _mockAppointments.removeWhere((a) => a['id'] == appointment['id']);
      _filterAppointments(_searchQuery);
    });

    Fluttertoast.showToast(
      msg: "Cita eliminada. Email enviado a ${appointment['clientName']}",
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
      final date = appointment['date'] as String;
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(appointment);
    }

    // Sort by date
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedGrouped = <String, List<Map<String, dynamic>>>{};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedAppointments = _groupAppointmentsByDate();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          DashboardHeaderWidget(
            studioName: "TattooBooker Studio",
            currentDate: "Miércoles, 6 de Noviembre 2025",
            notificationCount: 3,
            onNotificationTap: _showNotifications,
          ),

          // Tab Bar
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'Calendario'),
                Tab(text: 'Clientes'),
                Tab(text: 'Links'),
                Tab(text: 'Ajustes'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Dashboard Tab
                Column(
                  children: [
                    // Sync indicator
                    if (!_isOnline || _isSyncing)
                      SyncIndicatorWidget(
                        isOnline: _isOnline,
                        isSyncing: _isSyncing,
                        lastSyncTime: _lastSyncTime,
                        onRetrySync: _retrySync,
                      ),

                    // Search bar
                    SearchBarWidget(
                      isExpanded: _isSearchExpanded,
                      onToggle: () {
                        setState(() {
                          _isSearchExpanded = !_isSearchExpanded;
                        });
                      },
                      onChanged: _filterAppointments,
                      onClear: _clearSearch,
                    ),
                    SizedBox(height: 1.h),

                    // Appointments list
                    Expanded(
                      child: _filteredAppointments.isEmpty
                          ? EmptyStateWidget(
                              title: _searchQuery.isNotEmpty
                                  ? 'No se encontraron citas'
                                  : 'No hay citas programadas',
                              subtitle: _searchQuery.isNotEmpty
                                  ? 'Intenta con otros términos de búsqueda o revisa la ortografía.'
                                  : 'Comienza creando tu primera cita para gestionar las reservas de tu estudio.',
                              buttonText: _searchQuery.isNotEmpty
                                  ? 'Limpiar Búsqueda'
                                  : 'Crear Primera Cita',
                              onButtonPressed: _searchQuery.isNotEmpty
                                  ? () {
                                      setState(() {
                                        _isSearchExpanded = false;
                                      });
                                      _clearSearch();
                                    }
                                  : _createNewAppointment,
                              illustrationUrl:
                                  "https://images.pexels.com/photos/6801648/pexels-photo-6801648.jpeg?auto=compress&cs=tinysrgb&w=800",
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
                                  final firstAppointment = appointments.first;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Date section header
                                      DateSectionWidget(
                                        date: date,
                                        dayOfWeek: firstAppointment['dayOfWeek']
                                            as String,
                                        appointmentCount: appointments.length,
                                      ),

                                      // Appointments for this date
                                      ...appointments.map((appointment) {
                                        return AppointmentCardWidget(
                                          appointment: appointment,
                                          onTap: () =>
                                              _onAppointmentTap(appointment),
                                          onEdit: () =>
                                              _onEditAppointment(appointment),
                                          onCancel: () =>
                                              _onCancelAppointment(appointment),
                                          onDelete: () =>
                                              _onDeleteAppointment(appointment),
                                          onSendReminder: () =>
                                              _onSendReminder(appointment),
                                        );
                                      }).toList(),

                                      SizedBox(height: 1.h),
                                    ],
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),

                // Calendar Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_month',
                        size: 20.w,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Vista de Calendario',
                        style: AppTheme.lightTheme.textTheme.headlineSmall,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Próximamente disponible',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Clients Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'people',
                        size: 20.w,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Gestión de Clientes',
                        style: AppTheme.lightTheme.textTheme.headlineSmall,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Próximamente disponible',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Links Tab
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
                        'Aquí verás la gestión de links',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/link-management-screen',
                          );
                        },
                        child: Text('Ver Links'),
                      ),
                    ],
                  ),
                ),

                // Settings Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'settings',
                        size: 20.w,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Configuración',
                        style: AppTheme.lightTheme.textTheme.headlineSmall,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Próximamente disponible',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _createNewAppointment,
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                size: 6.w,
              ),
              label: Text(
                'Nueva Cita',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }
}
