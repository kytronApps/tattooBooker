import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BlockedDatesWidget extends StatefulWidget {
  final Set<DateTime> blockedDates;
  final Function(DateTime) onDateBlocked;
  final Function(DateTime) onDateUnblocked;

  const BlockedDatesWidget({
    Key? key,
    required this.blockedDates,
    required this.onDateBlocked,
    required this.onDateUnblocked,
  }) : super(key: key);

  @override
  State<BlockedDatesWidget> createState() => _BlockedDatesWidgetState();
}

class _BlockedDatesWidgetState extends State<BlockedDatesWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          _buildBlockedDatesList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.errorLight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.borderRadiusMedium),
          topRight: Radius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'block',
            color: AppTheme.errorLight,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Text(
            'Días No Disponibles',
            style: AppTheme.lightTheme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.errorLight,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: _showDatePicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.errorLight,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.lightTheme.colorScheme.onError,
                    size: 4.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Agregar',
                    style: AppTheme.lightTheme.textTheme.labelMedium!.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onError,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedDatesList() {
    if (widget.blockedDates.isEmpty) {
      return Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'event_available',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.4),
              size: 12.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'No hay fechas bloqueadas',
              style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Toca "Agregar" para bloquear fechas específicas',
              style: AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final sortedDates = widget.blockedDates.toList()
      ..sort((a, b) => a.compareTo(b));

    return Container(
      constraints: BoxConstraints(maxHeight: 30.h),
      child: ListView.separated(
        padding: EdgeInsets.all(4.w),
        shrinkWrap: true,
        itemCount: sortedDates.length,
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          return _buildBlockedDateItem(date);
        },
      ),
    );
  }

  Widget _buildBlockedDateItem(DateTime date) {
    final isToday = DateTime.now().day == date.day &&
        DateTime.now().month == date.month &&
        DateTime.now().year == date.year;

    final isPast = date.isBefore(DateTime.now().subtract(Duration(days: 1)));

    return Dismissible(
      key: Key(date.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        widget.onDateUnblocked(date);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fecha desbloqueada'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.errorLight,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        child: CustomIconWidget(
          iconName: 'delete',
          color: AppTheme.lightTheme.colorScheme.onError,
          size: 6.w,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isPast
              ? AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.05)
              : AppTheme.errorLight.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          border: Border.all(
            color: isPast
                ? AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3)
                : AppTheme.errorLight.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isPast
                    ? AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.1)
                    : AppTheme.errorLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: CustomIconWidget(
                iconName: isPast ? 'history' : 'block',
                color: isPast
                    ? AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6)
                    : AppTheme.errorLight,
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(date),
                    style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isPast
                          ? AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6)
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _getDateDescription(date, isToday, isPast),
                    style: AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                      color: isPast
                          ? AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.5)
                          : isToday
                              ? AppTheme.warningColor
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isToday)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Text(
                  'HOY',
                  style: AppTheme.lightTheme.textTheme.labelSmall!.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'swipe_left',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.4),
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
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
      'Diciembre'
    ];

    final weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];

    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    return '$weekday, $day de $month $year';
  }

  String _getDateDescription(DateTime date, bool isToday, bool isPast) {
    if (isPast) {
      return 'Fecha pasada - Ya no es relevante';
    } else if (isToday) {
      return 'Bloqueado hoy - No se pueden hacer citas';
    } else {
      final daysUntil = date.difference(DateTime.now()).inDays;
      if (daysUntil == 1) {
        return 'Bloqueado mañana';
      } else if (daysUntil <= 7) {
        return 'Bloqueado en $daysUntil días';
      } else {
        return 'Fecha bloqueada para citas';
      }
    }
  }

  void _showDatePicker() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      locale: Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              headerBackgroundColor: AppTheme.lightTheme.colorScheme.primary,
              headerForegroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.lightTheme.colorScheme.onPrimary;
                }
                return AppTheme.lightTheme.colorScheme.onSurface;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.lightTheme.colorScheme.primary;
                }
                return Colors.transparent;
              }),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && !widget.blockedDates.contains(selectedDate)) {
      widget.onDateBlocked(selectedDate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fecha bloqueada: ${_formatDate(selectedDate)}'),
          backgroundColor: AppTheme.errorLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (selectedDate != null &&
        widget.blockedDates.contains(selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Esta fecha ya está bloqueada'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
