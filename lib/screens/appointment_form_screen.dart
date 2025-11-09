import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../widgets/custom_snackbar.dart';

class AppointmentFormScreen extends StatefulWidget {
  const AppointmentFormScreen({super.key});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _clientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _serviceController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSaving = false;

  // 🔹 Seleccionar fecha
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // 🔹 Seleccionar horario
  Future<void> _pickTimeRange() async {
    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (start == null) return;
    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: start.hour + 1, minute: start.minute),
    );
    if (end == null) return;

    setState(() {
      _startTime = start;
      _endTime = end;
    });
  }

  // 🔹 Guardar cita en Firestore
  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null) {
      CustomSnackBar.show(context,
          message: "Completa todos los campos antes de guardar", isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dateFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final timeSlot =
          '${_startTime!.format(context)} - ${_endTime!.format(context)}';
      final dayOfWeek =
          DateFormat('EEEE', 'es_ES').format(_selectedDate!).toUpperCase();

      await _firestore.collection('appointments').add({
        'clientName': _clientController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'serviceType': _serviceController.text.trim(),
        'price': _priceController.text.trim(),
        'date': dateFormatted,
        'dayOfWeek': dayOfWeek,
        'timeSlot': timeSlot,
        'status': 'pendiente',
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        CustomSnackBar.show(context, message: "Cita creada correctamente");
        Navigator.pop(context, true);
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message: "Error al guardar la cita: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _clientController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _serviceController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Cita"),
        centerTitle: true,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _clientController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre del cliente'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo obligatorio' : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration:
                      const InputDecoration(labelText: 'Teléfono (opcional)'),
                  keyboardType: TextInputType.phone,
                ),
                // TextFormField(
                //   controller: _emailController,
                //   decoration: const InputDecoration(
                //       labelText: 'Correo electrónico (opcional)'),
                //   keyboardType: TextInputType.emailAddress,
                // ),
                TextFormField(
                  controller: _serviceController,
                  decoration:
                      const InputDecoration(labelText: 'Tipo de servicio'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo obligatorio' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Precio (€)'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 2.h),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(_selectedDate == null
                      ? 'Seleccionar fecha'
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                  onTap: _pickDate,
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(_startTime == null
                      ? 'Seleccionar horario'
                      : '${_startTime!.format(context)} - ${_endTime!.format(context)}'),
                  onTap: _pickTimeRange,
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.check),
                    label: Text(_isSaving ? 'Guardando...' : 'Guardar cita'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      backgroundColor:
                          AppTheme.lightTheme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isSaving ? null : _saveAppointment,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}