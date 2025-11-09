import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class BlockedDatesWidget extends StatelessWidget {
  final Set<DateTime> blockedDates;
  final Function(DateTime) onDateBlocked;
  final Function(DateTime) onDateUnblocked;

  const BlockedDatesWidget({
    super.key,
    required this.blockedDates,
    required this.onDateBlocked,
    required this.onDateUnblocked,
  });

  Future<void> _pickDate(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 1),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) onDateBlocked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = blockedDates.toList()..sort((a, b) => a.compareTo(b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.block, color: Colors.redAccent, size: 20.sp),
                    SizedBox(width: 2.w),
                    Flexible(
                      child: Text(
                        "Días No Disponibles",
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickDate(context),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Agregar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de fechas bloqueadas
        ...sortedDates.map((date) {
          final formattedDate =
              "${_getWeekday(date.weekday)}, ${date.day} de ${_getMonth(date.month)} ${date.year}";
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.06),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.block, color: Colors.redAccent),
                      SizedBox(width: 3.w),
                      // ← Text expandible, evita overflow
                      Expanded(
                        child: Text(
                          formattedDate,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.lock_open, color: Colors.redAccent),
                  tooltip: "Desbloquear",
                  onPressed: () => onDateUnblocked(date),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getWeekday(int weekday) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    return days[(weekday - 1) % 7];
  }

  String _getMonth(int month) {
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
      'Diciembre'
    ];
    return months[month - 1];
  }
}