import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../main.dart'; // 👈 importamos la key global

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    IconData? icon,
  }) {
    final colorScheme = AppTheme.lightTheme.colorScheme;
    final backgroundColor =
        isError ? colorScheme.errorContainer : colorScheme.primaryContainer;
    final iconColor = isError ? colorScheme.error : colorScheme.primary;

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      backgroundColor: backgroundColor.withOpacity(0.95),
      elevation: 2,
      duration: const Duration(seconds: 2),
      content: Row(
        children: [
          Icon(
            icon ??
                (isError ? Icons.error_outline : Icons.check_circle_rounded),
            color: iconColor,
            size: 20.sp,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              message,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    // ✅ Usamos el ScaffoldMessenger global en lugar del contexto local
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    } else {
      debugPrint('⚠️ SnackBar requested but no global messenger found: $message');
    }
  }
}