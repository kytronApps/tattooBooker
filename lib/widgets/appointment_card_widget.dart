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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(appointment['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              icon: Icons.edit,
              label: 'Editar',
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            SlidableAction(
              onPressed: (_) => onCancel?.call(),
              backgroundColor: AppTheme.warningColor,
              foregroundColor: Colors.white,
              icon: Icons.cancel,
              label: 'Cancelar',
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            SlidableAction(
              onPressed: (_) => onSendReminder?.call(),
              backgroundColor: AppTheme.infoColor,
              foregroundColor: Colors.white,
              icon: Icons.notifications,
              label: 'Recordar',
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _showDeleteConfirmation(context),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: AppTheme.lightTheme.colorScheme.onError,
              icon: Icons.delete,
              label: 'Eliminar',
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
          ],
        ),
        child: Card(
          elevation: AppTheme.elevationLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: InkWell(
            onTap: onTap,
            onLongPress: () => _showContextMenu(context),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl: appointment['clientAvatar'] as String,
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.cover,
                        semanticLabel:
                            appointment['clientAvatarSemanticLabel'] as String,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  // Appointment details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                appointment['clientName'] as String,
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadiusSmall),
                                border: Border.all(
                                  color: _getStatusColor(),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getStatusText(),
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'design_services',
                              size: 4.w,
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                appointment['serviceType'] as String,
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'access_time',
                              size: 4.w,
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              appointment['timeSlot'] as String,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            CustomIconWidget(
                              iconName: 'euro_symbol',
                              size: 4.w,
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              appointment['price'] as String,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar eliminación',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar esta cita con ${appointment['clientName']}? Esta acción no se puede deshacer.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                foregroundColor: AppTheme.lightTheme.colorScheme.onError,
              ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Opciones de cita',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'visibility',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                title: const Text('Ver detalles'),
                onTap: () {
                  Navigator.pop(context);
                  onTap?.call();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'edit',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                title: const Text('Editar cita'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'notifications',
                  color: AppTheme.infoColor,
                  size: 6.w,
                ),
                title: const Text('Enviar recordatorio'),
                onTap: () {
                  Navigator.pop(context);
                  onSendReminder?.call();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'cancel',
                  color: AppTheme.warningColor,
                  size: 6.w,
                ),
                title: const Text('Cancelar cita'),
                onTap: () {
                  Navigator.pop(context);
                  onCancel?.call();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 6.w,
                ),
                title: const Text('Eliminar cita'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }
}
