import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class CalendarSyncService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  /// Verifica y solicita permisos si es necesario
  Future<bool> requestPermissions() async {
    // Verificar si ya existen permisos
    final hasPermissions = await _deviceCalendarPlugin.hasPermissions();
    if (hasPermissions.isSuccess && (hasPermissions.data ?? false)) {
      return true;
    }

    // Solicitar permisos si no se tienen
    final result = await _deviceCalendarPlugin.requestPermissions();
    return result.isSuccess && (result.data ?? false);
  }

  /// Obtiene el calendario por defecto (ej: iCloud)
  Future<Calendar?> getDefaultCalendar() async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (calendarsResult.isSuccess && calendarsResult.data!.isNotEmpty) {
      return calendarsResult.data!.firstWhere(
        (c) => c.isDefault ?? false,
        orElse: () => calendarsResult.data!.first,
      );
    }
    return null;
  }

  /// Sincroniza una cita con el calendario del iPhone
  Future<void> addAppointmentToCalendar({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('⚠️ Permiso para acceder al calendario denegado. Actívalo en Ajustes > Privacidad > Calendarios.');
    }

    final calendar = await getDefaultCalendar();
    if (calendar == null) {
      throw Exception('❌ No se encontró un calendario disponible (iCloud, Google, etc.)');
    }

    try {
      // Inicializar zona horaria
      tzdata.initializeTimeZones();
      try {
        final zoneName = DateTime.now().timeZoneName;
        final loc = tz.getLocation(zoneName);
        tz.setLocalLocation(loc);
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      final tz.TZDateTime tzStart = tz.TZDateTime.from(startTime, tz.local);
      final tz.TZDateTime tzEnd = tz.TZDateTime.from(endTime, tz.local);

      final event = Event(
        calendar.id,
        title: title,
        description: description,
        start: tzStart,
        end: tzEnd,
      );

      final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      if (!(result?.isSuccess ?? false)) {
        throw Exception('❌ No se pudo crear el evento en el calendario.');
      }
    } catch (e) {
      throw Exception('Error al intentar agregar evento: $e');
    }
  }
}