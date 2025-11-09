import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class NotificationsDropdownWidget extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final Function(Map<String, dynamic>) onView;
  final Function(String) onDelete;

  const NotificationsDropdownWidget({
    super.key,
    required this.notifications,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
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
        child: const Text("Sin notificaciones"),
      );
    }

    return Container(
      width: 80.w,
      constraints: BoxConstraints(maxHeight: 50.h),
      padding: EdgeInsets.all(2.w),
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
      child: ListView.builder(
        itemCount: notifications.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return ListTile(
            leading: const Icon(Icons.notifications, color: Colors.black54),
            title: Text(
              notif['clientName'] ?? 'Cliente',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "📅 ${notif['date']}  ⏰ ${notif['time']}",
              style: const TextStyle(fontSize: 13),
            ),
            trailing: IconButton(
              icon:
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => onDelete(notif['id']),
            ),
            onTap: () => onView(notif),
          );
        },
      ),
    );
  }
}