import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../core/app_export.dart';

class AppointmentEditModal extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final Function(String service, String timeSlot, String price, String? newDate) onSave;

  const AppointmentEditModal({
    super.key,
    required this.appointment,
    required this.onSave,
  });

  @override
  State<AppointmentEditModal> createState() => _AppointmentEditModalState();
}

class _AppointmentEditModalState extends State<AppointmentEditModal> {
  late TextEditingController _serviceController;
  late TextEditingController _timeController;
  late TextEditingController _priceController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _serviceController = TextEditingController(text: widget.appointment['serviceType']);
    _timeController = TextEditingController(text: widget.appointment['timeSlot']);
    _priceController = TextEditingController(text: widget.appointment['price']);
    // Inicializar fecha si existe en el appointment
    final rawDate = widget.appointment['date'];
    if (rawDate != null) {
      try {
        _selectedDate = DateTime.tryParse(rawDate.toString());
      } catch (_) {
        _selectedDate = null;
      }
    }

    // No usamos TimePicker — mantenemos el campo 'Horario' como texto libre
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Editar Cita', style: AppTheme.lightTheme.textTheme.titleMedium),
          SizedBox(height: 2.h),
          _buildTextField('Tipo de Tatuaje', _serviceController),
          SizedBox(height: 1.5.h),
          // Campo fecha
          _buildDateField(context),
          SizedBox(height: 1.5.h),
          // Campo horario (texto libre, p.ej. "16:00 - 18:00")
          _buildTextField('Horario (ej: 16:00 - 18:00)', _timeController),
          SizedBox(height: 1.5.h),
          _buildTextField('Precio (€)', _priceController, keyboardType: TextInputType.number),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () {
              final newDateIso = _selectedDate?.toIso8601String();
              // Usamos el campo de texto 'Horario' como timeSlot
              widget.onSave(
                _serviceController.text.trim(),
                _timeController.text.trim(),
                _priceController.text.trim(),
                newDateIso,
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
            label: const Text('Guardar Cambios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    final display = _selectedDate != null
        ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
        : (widget.appointment['date']?.toString() ?? 'Seleccionar fecha');

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final initial = _selectedDate ?? DateTime.tryParse(widget.appointment['date']?.toString() ?? '') ?? now;
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 5),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(display),
            const Icon(Icons.calendar_today_outlined),
          ],
        ),
      ),
    );
  }

  
}