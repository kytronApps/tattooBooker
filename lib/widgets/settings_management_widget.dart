import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class HistoryList extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String collection;
  final String emptyMessage;
  final String orderByField;
  final Widget Function(Map<String, dynamic> data) buildCard;

  const HistoryList({
    super.key,
    required this.firestore,
    required this.collection,
    required this.emptyMessage,
    required this.orderByField,
    required this.buildCard,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection(collection)
          .orderBy(orderByField, descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyHistory(context, emptyMessage);
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data =
                docs[index].data() as Map<String, dynamic>;
            final id = docs[index].id;

            return buildCard({...data, "id": id});
          },
        );
      },
    );
  }

  // -------------------------------------------------------------
  // 🔹 Empty State elegante
  // -------------------------------------------------------------
  Widget _emptyHistory(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              size: 40.sp,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
          SizedBox(height: 2.h),
          Text(
            message,
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------------
// 🔹 CARD REUTILIZABLE PARA HISTÓRICO (Citas o Links)
// -------------------------------------------------------------------------
class HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final VoidCallback onDelete;

  const HistoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
            // Título + botón eliminar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                ),
              ],
            ),

            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),

            SizedBox(height: 1.h),

            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 4.w,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
                SizedBox(width: 2.w),
                Text(date),

                if (time.isNotEmpty) ...[
                  SizedBox(width: 4.w),
                  Icon(Icons.access_time,
                      size: 4.w,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
                  SizedBox(width: 2.w),
                  Text(time),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}