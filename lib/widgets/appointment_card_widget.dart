import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class AppointmentCardWidget extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onSendReminder;

  const AppointmentCardWidget({
    Key? key,
    required this.appointment,
    this.onTap,
    this.onEdit,
    this.onCancel,
    this.onDelete,
    this.onSendReminder,
  }) : super(key: key);

  Color _getStatusColor() {
    final status = (appointment['status'] as String).toLowerCase();
    switch (status) {
      case 'confirmado':
        return AppTheme.successColor;
      case 'pendiente':
        return AppTheme.warningColor;
      case 'cancelado':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusText() {
    final status = (appointment['status'] as String).toLowerCase();
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(appointment['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            _actionButton(
              context,
              color: theme.colorScheme.primary,
              icon: Icons.edit,
              label: 'Editar',
              onTap: onEdit,
            ),
            _actionButton(
              context,
              color: AppTheme.warningColor,
              icon: Icons.cancel,
              label: 'Cancelar',
              onTap: onCancel,
            ),
            _actionButton(
              context,
              color: AppTheme.infoColor,
              icon: Icons.notifications,
              label: 'Recordar',
              onTap: onSendReminder,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            _actionButton(
              context,
              color: theme.colorScheme.error,
              icon: Icons.delete,
              label: 'Eliminar',
              onTap: () => _showDeleteConfirmation(context),
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
            onTap: onTap,
            onLongPress: () => _showContextMenu(context),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: _buildCardContent(context, theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context,
      {required Color color,
      required IconData icon,
      required String label,
      VoidCallback? onTap}) {
    return SlidableAction(
      onPressed: (_) => onTap?.call(),
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
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cliente + Estado
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

              // Tipo de servicio
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

              // Hora y precio
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
            '¿Deseas eliminar la cita con ${appointment['clientName']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDelete?.call();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.borderRadiusLarge)),
      ),
      builder: (BuildContext sheetContext) {
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
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('Ver detalles'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onTap?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar cita'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onEdit?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('Enviar recordatorio'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSendReminder?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text('Cancelar cita'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onCancel?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Eliminar cita'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}