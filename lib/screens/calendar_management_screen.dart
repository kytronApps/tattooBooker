import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_export.dart';
import '../services/calendar_sync_service.dart';

class CalendarManagementScreen extends StatefulWidget {
  const CalendarManagementScreen({Key? key}) : super(key: key);

  @override
  State<CalendarManagementScreen> createState() => _CalendarManagementScreenState();
}

class _CalendarManagementScreenState extends State<CalendarManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CalendarSyncService _calendarService = CalendarSyncService();

  Map<DateTime, List<Map<String, dynamic>>> _confirmedAppointments = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _fetchConfirmedAppointments();
  }

  Future<void> _fetchConfirmedAppointments() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('status', isEqualTo: 'confirmado')
          .get();

      final Map<DateTime, List<Map<String, dynamic>>> appointmentsByDate = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = DateTime.tryParse(data['date'] ?? '');
        if (date != null) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          appointmentsByDate.putIfAbsent(normalizedDate, () => []).add(data);
        }
      }

      setState(() {
        _confirmedAppointments = appointmentsByDate;
        _isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error al cargar citas: $e",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    }
  }

  List<Map<String, dynamic>> _getAppointmentsForDay(DateTime day) {
    return _confirmedAppointments[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _syncAppointmentsToCalendar() async {
    setState(() => _isSyncing = true);
    try {
      for (var entry in _confirmedAppointments.entries) {
        for (var appointment in entry.value) {
          final date = DateTime.tryParse(appointment['date'] ?? '');
          if (date == null) continue;
          final timeSlot = (appointment['timeSlot'] ?? '').toString();
          final times = timeSlot.split('-').map((e) => e.trim()).toList();

          if (times.length == 2) {
            final startParts = times[0].split(':');
            final endParts = times[1].split(':');

            final start = DateTime(
              date.year,
              date.month,
              date.day,
              int.tryParse(startParts[0]) ?? 0,
              int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0,
            );
            final end = DateTime(
              date.year,
              date.month,
              date.day,
              int.tryParse(endParts[0]) ?? 0,
              int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0,
            );

            await _calendarService.addAppointmentToCalendar(
              title: '${appointment['clientName']} - ${appointment['serviceType']}',
              description: 'Teléfono: ${appointment['phone']}',
              startTime: start,
              endTime: end,
            );
          }
        }
      }

      Fluttertoast.showToast(
        msg: "✅ Citas sincronizadas con el calendario del iPhone",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error al sincronizar: $e",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: _getAppointmentsForDay,
                    calendarStyle: CalendarStyle(
                      markerDecoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: AppTheme.lightTheme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                Divider(thickness: 1, height: 2.h),
                Expanded(
                  child: _selectedDay == null ||
                          _getAppointmentsForDay(_selectedDay!).isEmpty
                      ? Center(
                          child: Text(
                            'No hay citas confirmadas para este día',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          itemCount: _getAppointmentsForDay(_selectedDay!).length,
                          itemBuilder: (context, index) {
                            final appointment =
                                _getAppointmentsForDay(_selectedDay!)[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 1.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.schedule,
                                    color: AppTheme.lightTheme.colorScheme.primary),
                                title: Text(appointment['clientName'] ?? 'Sin nombre'),
                                subtitle: Text(
                                  '${appointment['serviceType'] ?? ''} · ${appointment['timeSlot'] ?? ''}',
                                ),
                                trailing: Text(
                                  '${appointment['price'] ?? ''}€',
                                  style: TextStyle(
                                    color: AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _syncAppointmentsToCalendar,
                    icon: const Icon(Icons.sync),
                    label: Text(
                      _isSyncing ? 'Sincronizando...' : 'Sincronizar con Calendario',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 6.w),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}