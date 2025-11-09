import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/appointment_actions_service.dart';
import '../../widgets/appointment_edit_modal.dart';

class AppointmentCardWidget extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const AppointmentCardWidget({
    Key? key,
    required this.appointment,
    this.onCancel,
    this.onDelete,
  }) : super(key: key);

  Color _getStatusColor() {
    final status = (appointment['status'] ?? '').toLowerCase();
    switch (status) {
      case 'confirmado':
        return AppTheme.successColor;
      case 'pendiente':
        return AppTheme.warningColor;
      case 'cancelado':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getStatusText() {
    final status = (appointment['status'] ?? '').toLowerCase();
    switch (status) {
      case 'confirmado':
        return 'Confirmado';
      case 'pendiente':
        return 'Pendiente';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final actionsService = AppointmentActionsService();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(appointment['id']),
        startActionPane: ActionPane(
  motion: const ScrollMotion(),
  children: [
    if ((appointment['status'] ?? '').toLowerCase() == 'pendiente')
      _actionButton(
        context,
        color: Colors.green.shade600,
        icon: Icons.check_circle,
        label: 'Confirmar',
        onTap: () async {
          await actionsService.confirmAppointment(context, appointment['id']);
        },
      ),
    _actionButton(
      context,
      color: theme.colorScheme.primary,
      icon: Icons.edit,
      label: 'Editar',
      onTap: () => _openEditModal(context, actionsService),
    ),
    _actionButton(
      context,
      color: AppTheme.warningColor,
      icon: Icons.cancel,
      label: 'Cancelar',
      onTap: onCancel ?? () {},
    ),
    _actionButton(
      context,
      color: const Color(0xFFD32F2F),
      icon: Icons.delete,
      label: 'Eliminar',
      onTap: onDelete ?? () {},
    ),
  ],
),
        child: Card(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2C2C2E)
              : theme.colorScheme.surface,
          elevation: AppTheme.elevationLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            onLongPress: () => _showContextMenu(context, actionsService),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: _buildCardContent(context, theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SlidableAction(
      onPressed: (_) => onTap(),
      backgroundColor: color,
      foregroundColor: Colors.white,
      icon: icon,
      label: label,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
    );
  }

  Widget _buildCardContent(BuildContext context, ThemeData theme) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Nombre + estado
              Row(
                children: [
                  Expanded(
                    child: Text(
                      appointment['clientName'] ?? 'Cliente',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),

              // 🔹 Tipo
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'design_services',
                    size: 4.w,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      appointment['serviceType'] ?? 'Servicio no especificado',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),

              // 🔹 Hora y precio
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'access_time',
                    size: 4.w,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    appointment['timeSlot'] ?? '--:--',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  CustomIconWidget(
                    iconName: 'euro_symbol',
                    size: 4.w,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    appointment['price'] ?? '0€',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔹 Modal de edición
  void _openEditModal(BuildContext context, AppointmentActionsService actionsService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.borderRadiusLarge)),
      ),
      builder: (ctx) {
        return AppointmentEditModal(
          appointment: appointment,
          onSave: (service, time, price, newDate) {
            actionsService.editAppointment(
              ctx,
              appointment['id'],
              serviceType: service,
              timeSlot: time,
              price: price,
              newDate: newDate,
            );
          },
        );
      },
    );
  }



  // 🔹 Menú contextual (mantiene compatibilidad con long press)
  void _showContextMenu(BuildContext context, AppointmentActionsService service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.all(4.w),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 10.w,
                  height: 0.6.h,
                  margin: EdgeInsets.only(bottom: 1.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openEditModal(context, service);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text('Cancelar cita'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (onCancel != null) onCancel!();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Eliminar cita'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (onDelete != null) onDelete!();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}