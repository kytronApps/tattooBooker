import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class WorkingHoursWidget extends StatelessWidget {
  final Map<String, bool> workingDays;
  final Map<String, TimeOfDay> startTimes;
  final Map<String, TimeOfDay> endTimes;
  final Function(String, bool) onWorkingDayChanged;
  final Function(String, TimeOfDay) onStartTimeChanged;
  final Function(String, TimeOfDay) onEndTimeChanged;

  const WorkingHoursWidget({
    super.key,
    required this.workingDays,
    required this.startTimes,
    required this.endTimes,
    required this.onWorkingDayChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  Future<void> _pickTime(
      BuildContext context, String day, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTimes[day]! : endTimes[day]!,
    );

    if (picked != null) {
      if (isStart) {
        onStartTimeChanged(day, picked);
      } else {
        onEndTimeChanged(day, picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ordenar los días manualmente
    final orderedDays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];

    return Column(
      children: orderedDays.map((day) {
        final active = workingDays[day] ?? false;
        final start = startTimes[day] ?? const TimeOfDay(hour: 9, minute: 0);
        final end = endTimes[day] ?? const TimeOfDay(hour: 18, minute: 0);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  day,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: active
                        ? AppTheme.lightTheme.colorScheme.onSurface
                        : Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: active,
                activeColor: AppTheme.lightTheme.colorScheme.primary,
                onChanged: (v) => onWorkingDayChanged(day, v),
              ),
              if (active)
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => _pickTime(context, day, true),
                        child: Text(
                          "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}",
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      ),
                      Text("-", style: TextStyle(color: Colors.grey.shade600)),
                      GestureDetector(
                        onTap: () => _pickTime(context, day, false),
                        child: Text(
                          "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}",
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}