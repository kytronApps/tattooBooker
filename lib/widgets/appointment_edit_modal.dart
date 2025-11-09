import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../core/app_export.dart';

class AppointmentEditModal extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final Function(String, String, String) onSave;

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

  @override
  void initState() {
    super.initState();
    _serviceController = TextEditingController(text: widget.appointment['serviceType']);
    _timeController = TextEditingController(text: widget.appointment['timeSlot']);
    _priceController = TextEditingController(text: widget.appointment['price']);
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
          _buildTextField('Horario (ej: 16:00 - 18:00)', _timeController),
          SizedBox(height: 1.5.h),
          _buildTextField('Precio (€)', _priceController, keyboardType: TextInputType.number),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () {
              widget.onSave(
                _serviceController.text.trim(),
                _timeController.text.trim(),
                _priceController.text.trim(),
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
}