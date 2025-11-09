import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class NotificationsDropdownWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) onView;
  final Function(String) onDelete;

  const NotificationsDropdownWidget({
    super.key,
    required this.onView,
    required this.onDelete,
  });

  // 🔹 Stream de notificaciones no leídas (solo pendientes)
  Stream<QuerySnapshot<Map<String, dynamic>>> _notificationsStream() {
  // Trae todas las citas activas y filtra client-side para soportar
  // tanto 'true'/'false' strings como booleanos nullables.
  return FirebaseFirestore.instance
    .collection('appointments')
    .where('status', isNotEqualTo: 'cancelado')
    .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _notificationsStream(),
      builder: (context, snapshot) {
        // 🌀 Cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _decoratedContainer(
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        // ❌ Sin datos
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _decoratedContainer(
            child: const Text("Sin notificaciones"),
          );
        }

        // ✅ Lista de notificaciones (filtramos client-side por isRead)
        final notifications = snapshot.data!.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .where((n) => n['isRead'] == false || n['isRead'] == 'false' || n['isRead'] == null)
            .toList();

        if (notifications.isEmpty) {
          return _decoratedContainer(
            child: const Text("Sin notificaciones"),
          );
        }

        return Container(
          width: 80.w,
          constraints: BoxConstraints(maxHeight: 45.h),
          padding: EdgeInsets.symmetric(vertical: 1.w, horizontal: 2.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListView.separated(
            itemCount: notifications.length,
            shrinkWrap: true,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final clientName = notif['clientName'] ?? 'Cliente';
              final date = notif['date'] ?? '—';
              final time =
                  notif['timeSlot'] ?? notif['time'] ?? notif['timeRange'] ?? '—';
              final service = notif['serviceType'] ?? '—';

              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 1.w,
                  vertical: 0.5.h,
                ),
                leading: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.black54,
                  size: 22,
                ),
                title: Text(
                  clientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Fila protegida sin overflow
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            date,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.access_time,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            time,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                  onPressed: () async {
                    await _markAsRead(notif['id']);
                    onDelete(notif['id']);
                  },
                ),
                onTap: () {
                  _markAsRead(notif['id']);
                  onView(notif);
                },
              );
            },
          ),
        );
      },
    );
  }

  // 🟢 Marcar como leída
  Future<void> _markAsRead(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(id)
          .update({'isRead': 'true'}); // String para mantener compatibilidad
    } catch (e) {
      debugPrint("❌ Error al marcar como leída: $e");
    }
  }

  // 🎨 Contenedor reutilizable
  Widget _decoratedContainer({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}