import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DayDetailModal extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> appointments;
  final Map<String, TimeOfDay> startTimes;
  final Map<String, TimeOfDay> endTimes;
  final Map<String, bool> workingDays;
  final Function(Map<String, dynamic>) onAppointmentTap;

  const DayDetailModal({
    super.key,
    required this.selectedDate,
    required this.appointments,
    required this.startTimes,
    required this.endTimes,
    required this.workingDays,
    required this.onAppointmentTap,
  });

  @override
  State<DayDetailModal> createState() => _DayDetailModalState();
}

class _DayDetailModalState extends State<DayDetailModal> {
  final List<String> weekDays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.borderRadiusLarge),
          topRight: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      child: Column(
        children: [
          _buildModalHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateInfo(),
                  SizedBox(height: 3.h),
                  _buildWorkingHoursInfo(),
                  SizedBox(height: 3.h),
                  _buildAppointmentsList(),
                  SizedBox(height: 3.h),
                  _buildTimeSlots(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.borderRadiusLarge),
          topRight: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'event',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Detalles del Día',
                  style: AppTheme.lightTheme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 5.w,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo() {
    final weekday = weekDays[widget.selectedDate.weekday - 1];
    final isToday = DateTime.now().day == widget.selectedDate.day &&
        DateTime.now().month == widget.selectedDate.month &&
        DateTime.now().year == widget.selectedDate.year;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color:
            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Column(
              children: [
                Text(
                  '${widget.selectedDate.day}',
                  style: AppTheme.lightTheme.textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.onSecondary,
                  ),
                ),
                Text(
                  _getMonthAbbreviation(widget.selectedDate.month),
                  style: AppTheme.lightTheme.textTheme.labelMedium!.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekday,
                  style: AppTheme.lightTheme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${widget.selectedDate.day} de ${_getMonthName(widget.selectedDate.month)} ${widget.selectedDate.year}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (isToday)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.warningColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Text(
                'HOY',
                style: AppTheme.lightTheme.textTheme.labelSmall!.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursInfo() {
    final weekday = weekDays[widget.selectedDate.weekday - 1];
    final isWorkingDay = widget.workingDays[weekday] ?? false;
    final startTime =
        widget.startTimes[weekday] ?? TimeOfDay(hour: 9, minute: 0);
    final endTime = widget.endTimes[weekday] ?? TimeOfDay(hour: 18, minute: 0);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isWorkingDay
            ? AppTheme.successColor.withValues(alpha: 0.05)
            : AppTheme.errorLight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: isWorkingDay
              ? AppTheme.successColor.withValues(alpha: 0.2)
              : AppTheme.errorLight.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isWorkingDay ? 'access_time' : 'schedule_send',
            color: isWorkingDay ? AppTheme.successColor : AppTheme.errorLight,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWorkingDay ? 'Día Laboral' : 'Día No Laboral',
                  style: AppTheme.lightTheme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isWorkingDay
                        ? AppTheme.successColor
                        : AppTheme.errorLight,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  isWorkingDay
                      ? 'Horario: ${startTime.format(context)} - ${endTime.format(context)}'
                      : 'No hay horario de trabajo configurado',
                  style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final dayAppointments = widget.appointments.where((appointment) {
      final appointmentDate = appointment['date'] as DateTime;
      return appointmentDate.day == widget.selectedDate.day &&
          appointmentDate.month == widget.selectedDate.month &&
          appointmentDate.year == widget.selectedDate.year;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'event_note',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Citas del Día',
              style: AppTheme.lightTheme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: dayAppointments.isEmpty
                    ? AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Text(
                '${dayAppointments.length}',
                style: AppTheme.lightTheme.textTheme.labelMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: dayAppointments.isEmpty
                      ? AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6)
                      : AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        if (dayAppointments.isEmpty)
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'event_available',
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.4),
                  size: 8.w,
                ),
                SizedBox(height: 2.h),
                Text(
                  'No hay citas programadas',
                  style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Este día está disponible para nuevas citas',
                  style: AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...dayAppointments
              .map((appointment) => _buildAppointmentItem(appointment))
              ,
      ],
    );
  }

  Widget _buildAppointmentItem(Map<String, dynamic> appointment) {
    final time = appointment['time'] as String;
    final clientName = appointment['clientName'] as String;
    final service = appointment['service'] as String;
    final status = appointment['status'] as String;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'confirmed':
        statusColor = AppTheme.successColor;
        statusText = 'Confirmada';
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = AppTheme.warningColor;
        statusText = 'Pendiente';
        statusIcon = Icons.schedule;
        break;
      case 'cancelled':
        statusColor = AppTheme.errorLight;
        statusText = 'Cancelada';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppTheme.lightTheme.colorScheme.onSurface;
        statusText = 'Desconocido';
        statusIcon = Icons.help;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: GestureDetector(
        onTap: () => widget.onAppointmentTap(appointment),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: CustomIconWidget(
                  iconName: statusIcon.toString().split('.').last,
                  color: statusColor,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          time,
                          style: AppTheme.lightTheme.textTheme.titleMedium!
                              .copyWith(
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusSmall),
                          ),
                          child: Text(
                            statusText,
                            style: AppTheme.lightTheme.textTheme.labelSmall!
                                .copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      clientName,
                      style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      service,
                      style: AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.4),
                size: 5.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    final weekday = weekDays[widget.selectedDate.weekday - 1];
    final isWorkingDay = widget.workingDays[weekday] ?? false;

    if (!isWorkingDay) {
      return Container();
    }

    final startTime =
        widget.startTimes[weekday] ?? TimeOfDay(hour: 9, minute: 0);
    final endTime = widget.endTimes[weekday] ?? TimeOfDay(hour: 18, minute: 0);

    final timeSlots = _generateTimeSlots(startTime, endTime);
    final bookedTimes = widget.appointments
        .where((appointment) {
          final appointmentDate = appointment['date'] as DateTime;
          return appointmentDate.day == widget.selectedDate.day &&
              appointmentDate.month == widget.selectedDate.month &&
              appointmentDate.year == widget.selectedDate.year;
        })
        .map((appointment) => appointment['time'] as String)
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'access_time',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Horarios Disponibles',
              style: AppTheme.lightTheme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: timeSlots.map((timeSlot) {
            final isBooked = bookedTimes.contains(timeSlot);
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isBooked
                    ? AppTheme.errorLight.withValues(alpha: 0.1)
                    : AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                border: Border.all(
                  color: isBooked
                      ? AppTheme.errorLight.withValues(alpha: 0.3)
                      : AppTheme.successColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                timeSlot,
                style: AppTheme.lightTheme.textTheme.labelMedium!.copyWith(
                  color: isBooked ? AppTheme.errorLight : AppTheme.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<String> _generateTimeSlots(TimeOfDay start, TimeOfDay end) {
    final slots = <String>[];
    var current = start;

    while (current.hour < end.hour ||
        (current.hour == end.hour && current.minute < end.minute)) {
      slots.add(current.format(context));

      // Add 1 hour
      var newMinute = current.minute;
      var newHour = current.hour + 1;

      if (newHour >= 24) break;

      current = TimeOfDay(hour: newHour, minute: newMinute);
    }

    return slots;
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC'
    ];
    return months[month - 1];
  }

  String _getMonthName(int month) {
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
