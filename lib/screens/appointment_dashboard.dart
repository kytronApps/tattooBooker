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
import '../widgets/notifications_dropdown_widget.dart';
import '../screens/calendar_management_screen.dart';
import 'links_management_screen.dart';

class AppointmentDashboard extends StatefulWidget {
  const AppointmentDashboard({super.key});

  @override
  State<AppointmentDashboard> createState() => _AppointmentDashboardState();
}

class _AppointmentDashboardState extends State<AppointmentDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearchExpanded = false;
  bool _isOnline = true;
  DateTime? _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 5));
  String _searchQuery = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CalendarSyncService _calendarService = CalendarSyncService();
  final AppointmentActionsService _appointmentService =
      AppointmentActionsService();

  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _filteredAppointments = [];
  List<Map<String, dynamic>> _notifications = [];
  List<String> _knownAppointments = [];
  OverlayEntry? _notificationsOverlay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 2) {
        setState(() {});
      }
    });

    _listenAppointmentsRealtime();
    _simulateNetworkStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notificationsOverlay?.remove();
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

          // Filtrar citas incompletas (protección)
          final cleaned = appointments.where((a) {
            final name = (a['clientName'] ?? '').toString().trim();
            final date = (a['date'] ?? '').toString().trim();
            final time = (a['timeSlot'] ?? a['time'] ?? '').toString().trim();
            return name.isNotEmpty && date.isNotEmpty && time.isNotEmpty;
          }).toList();

          // Inicializa el panel de notificaciones con las citas no leídas
          final unread = appointments
              .where(
                (a) =>
                    (a['lastChangeSource'] == 'client') && // 👈 solo cliente
                    (a['isRead'] == false ||
                        a['isRead'] == 'false' ||
                        a['isRead'] == null),
              )
              .toList();

          // 🔍 Detectar nuevas citas pendientes no leídas
          final newAppointments = appointments.where(
            (a) =>
                !_knownAppointments.contains(a['id']) &&
                (a['status'] == 'pendiente') &&
                (a['lastChangeSource'] == 'client') && // 👈 SOLO cliente
                (a['isRead'] == false ||
                    a['isRead'] == 'false' ||
                    a['isRead'] == null),
          );

          for (var newA in newAppointments) {
            _showNewAppointmentNotification(newA);
          }

          _knownAppointments = appointments
              .map((a) => a['id'] as String)
              .toList();

          setState(() {
            _appointments = cleaned;
            _filteredAppointments = _applySearchFilter(cleaned, _searchQuery);

            _notifications = List.from(unread);
          });
        });
  }

  //  Mostrar notificación visual
  void _showNewAppointmentNotification(Map<String, dynamic> appointment) {
    final clientName = appointment['clientName'] ?? 'Cliente';
    final time = appointment['timeSlot'] ?? appointment['time'] ?? '';
    final date = appointment['date'] ?? '';

    Fluttertoast.showToast(
      msg: "📩 Nueva cita de $clientName el $date a las $time",
      backgroundColor: AppTheme.infoColor,
      textColor: Colors.white,
      gravity: ToastGravity.TOP,
    );

    HapticFeedback.mediumImpact();

    setState(() {
      _notifications.insert(0, appointment);
    });
  }

  // 🔹 Marcar notificación como leída (Firestore + UI)
  Future<void> _markNotificationAsRead(String id) async {
    try {
      // Algunas colecciones guardan isRead como string ('true'/'false') por compatibilidad.
      await _firestore.collection('appointments').doc(id).update({
        'isRead': 'true',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        _notifications.removeWhere((n) => n['id'] == id);
      });

      debugPrint("✅ Notificación marcada como leída: $id");
    } catch (e) {
      debugPrint("❌ Error al marcar notificación como leída: $e");
      Fluttertoast.showToast(
        msg: "Error al eliminar la notificación",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  //  Filtro de búsqueda
  List<Map<String, dynamic>> _applySearchFilter(
    List<Map<String, dynamic>> list,
    String query,
  ) {
    if (query.isEmpty) return List.from(list);
    final searchLower = query.toLowerCase();
    return list.where((appointment) {
      final client = (appointment['clientName'] ?? '').toString().toLowerCase();
      final service = (appointment['serviceType'] ?? '')
          .toString()
          .toLowerCase();
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
      await _firestore
          .collection('appointments')
          .doc(appointment['id'])
          .delete();
      debugPrint("📦 Cita movida al histórico: ${appointment['id']}");
    } catch (e) {
      debugPrint("❌ Error moviendo cita al histórico: $e");
    }
  }

  // 📅 Agrupar citas por fecha
  Map<String, List<Map<String, dynamic>>> _groupAppointmentsByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final appointment in _filteredAppointments) {
      // Normalizar el campo date a una fecha simple 'yyyy-MM-dd'
      String dateKey = 'Sin fecha';
      final raw = appointment['date'];
      if (raw != null) {
        try {
          if (raw is Timestamp) {
            final d = raw.toDate();
            dateKey = d.toIso8601String().split('T').first;
          } else {
            final d = DateTime.parse(raw.toString());
            dateKey = d.toIso8601String().split('T').first;
          }
        } catch (_) {
          dateKey = raw.toString();
        }
      }

      grouped.putIfAbsent(dateKey, () => []).add(appointment);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        try {
          final da = a == 'Sin fecha' ? DateTime(1900) : DateTime.parse(a);
          final db = b == 'Sin fecha' ? DateTime(1900) : DateTime.parse(b);
          return da.compareTo(db);
        } catch (_) {
          return a.compareTo(b);
        }
      });

    return {for (var k in sortedKeys) k: grouped[k]!};
  }

  // 🔔 Mostrar / Ocultar panel de notificaciones

  // 🔔 Mostrar / Ocultar panel de notificaciones
  void _toggleNotificationsPanel(BuildContext context) {
    // Si ya está abierto, ciérralo manualmente
    if (_notificationsOverlay != null) {
      _notificationsOverlay!.remove();
      _notificationsOverlay = null;
      return;
    }

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {}, // evita cierre accidental
            child: NotificationsDropdownWidget(
              onView: (notif) async {
                await _markNotificationAsRead(notif['id']);
                _notificationsOverlay?.remove();
                _notificationsOverlay = null;
                _openAppointmentDetails(notif);
              },
              onDelete: (id) async {
                await _markNotificationAsRead(id);
                _notificationsOverlay?.remove();
                _notificationsOverlay = null;
              },
            ),
          ),
        ),
      ),
    );

    _notificationsOverlay = entry;
    overlay.insert(entry);
  }

  // 🔍 Ver detalles de cita
  void _openAppointmentDetails(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.event_note, color: Colors.black54),
              SizedBox(width: 8),
              Text("Detalles de la cita"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow("👤 Cliente", appointment['clientName']),
              _detailRow("📞 Teléfono", appointment['phone']),
              _detailRow("💬 Servicio", appointment['serviceType']),
              _detailRow("📅 Fecha", appointment['date']),
              _detailRow(
                "⏰ Hora",
                appointment['timeSlot'] ?? appointment['time'],
              ),
              _detailRow("⚙️ Estado", appointment['status']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.toString() ?? '—',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
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
                'Lunes',
                'Martes',
                'Miércoles',
                'Jueves',
                'Viernes',
                'Sábado',
                'Domingo',
              ];
              const months = [
                'Enero',
                'Febrero',
                'Marzo',
                'Abril',
                'Mayo',
                'Junio',
                'Julio',
                'Agosto',
                'Septiembre',
                'Octubre',
                'Noviembre',
                'Diciembre',
              ];
              final dayName = days[(now.weekday - 1) % 7];
              final monthName = months[(now.month - 1) % 12];
              return '$dayName, ${now.day} de $monthName ${now.year}';
            })(),
            notificationCount: _notifications.length,
            onNotificationTap: () => _toggleNotificationsPanel(context),
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
                Column(
                  children: [
                    SearchBarWidget(
                      isExpanded: _isSearchExpanded,
                      onToggle: () => setState(
                        () => _isSearchExpanded = !_isSearchExpanded,
                      ),
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
                                  final date = groupedAppointments.keys
                                      .elementAt(index);
                                  final appointments =
                                      groupedAppointments[date]!;
                                  final first = appointments.first;
                                  // Determinar dayOfWeek: preferimos el campo existente, sino lo calculamos desde la fecha clave
                                  String dayOfWeek = first['dayOfWeek'] ?? '';
                                  if (dayOfWeek.isEmpty) {
                                    try {
                                      final d = DateTime.parse(date);
                                      const days = [
                                        'Lunes',
                                        'Martes',
                                        'Miércoles',
                                        'Jueves',
                                        'Viernes',
                                        'Sábado',
                                        'Domingo',
                                      ];
                                      dayOfWeek = days[(d.weekday - 1) % 7];
                                    } catch (_) {
                                      dayOfWeek = '';
                                    }
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DateSectionWidget(
                                        date: date,
                                        dayOfWeek: dayOfWeek,
                                        appointmentCount: appointments.length,
                                      ),
                                      ...appointments.map(
                                        (a) => AppointmentCardWidget(
                                          appointment: a,
                                          onCancel: () async {
                                            await _appointmentService
                                                .cancelAppointment(
                                                  context,
                                                  a['id'],
                                                );
                                            await _moveToHistory(a);
                                          },
                                          onDelete: () async {
                                            await _appointmentService
                                                .deleteAppointment(
                                                  context,
                                                  a['id'],
                                                );
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
                LinksManagementScreen(),
                const SettingsManagementScreen(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.pushNamed(
                  context,
                  AppRoutes.newAppointment,
                );
                if (created == true) {
                  Fluttertoast.showToast(
                    msg: "Cita añadida correctamente 🕒",
                    backgroundColor: AppTheme.successColor,
                    textColor: Colors.white,
                  );
                }
              },
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
