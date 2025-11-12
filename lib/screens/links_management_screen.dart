import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../core/app_export.dart';
import '../widgets/custom_snackbar.dart';
import '../services/booking_links_service.dart';

class LinksManagementScreen extends StatefulWidget {
  const LinksManagementScreen({super.key});

  @override
  State<LinksManagementScreen> createState() => _LinksManagementScreenState();
}

class _LinksManagementScreenState extends State<LinksManagementScreen> {
  final BookingLinksService _service = BookingLinksService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Generador de Links',
                  style: AppTheme.lightTheme.textTheme.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 3.w),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 46.w),
                child: ElevatedButton.icon(
                  onPressed: _createNewLink,
                  icon: const Icon(Icons.add_link, size: 18),
                  label: const Text('Generar link'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    textStyle: AppTheme.lightTheme.textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // 🔹 Lista de links
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _service.linksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay links generados aún',
                      style: AppTheme.lightTheme.textTheme.bodyLarge,
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => SizedBox(height: 1.h),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final id = doc.id;
                    final active =
                        data['active'] == true || data['active'] == 'true';
                    final createdAt = data['createdAt'] ?? '';
                    final uses = data['uses'] ?? 0;
                    final linkUrl = 'https://kytron-apps.web.app/book/$id';

                    return Card(
                      elevation: AppTheme.elevationLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusMedium,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 URL + estado
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    linkUrl,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        AppTheme.lightTheme.textTheme.bodySmall,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? Colors.green.shade50
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    active ? 'Activo' : 'Revocado',
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: active
                                              ? Colors.green
                                              : Colors.grey.shade600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),

                            // 🔹 Fecha de creación
                            Row(
                              children: [
                                Text(
                                  'Generado:',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  createdAt.toString(),
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),

                            // 🔹 Acciones
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Usos: $uses',
                                  style:
                                      AppTheme.lightTheme.textTheme.labelSmall,
                                ),
                                SizedBox(width: 3.w),

                                // Copiar
                                IconButton(
                                  tooltip: 'Copiar link',
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: linkUrl),
                                    );
                                    if (mounted) {
                                      CustomSnackBar.show(
                                        context,
                                        message: 'Link copiado al portapapeles',
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.copy_outlined),
                                ),

                                // Revocar / activar
                                // Revocar / activar link
                                IconButton(
                                  tooltip: active ? 'Revocar' : 'Activar',
                                  onPressed: () async {
                                    if (active) {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Revocar link'),
                                          content: const Text(
                                            '¿Deseas revocar este link? Pasará al histórico.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('Revocar'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await _service.moveLinkToHistory(id);
                                        if (mounted) {
                                          Future.delayed(Duration.zero, () {
                                            CustomSnackBar.show(
                                              context,
                                              message:
                                                  'Link movido al histórico',
                                            );
                                          });
                                        }
                                      }
                                    } else {
                                      await _service.toggleActive(id, true);
                                      if (mounted) {
                                        Future.delayed(Duration.zero, () {
                                          CustomSnackBar.show(
                                            context,
                                            message: 'Link reactivado',
                                          );
                                        });
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    active
                                        ? Icons.block_outlined
                                        : Icons.check_circle_outline,
                                  ),
                                  color: active ? Colors.orange : Colors.green,
                                ),

                                // Eliminar
                                IconButton(
                                  tooltip: 'Eliminar',
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Eliminar link'),
                                        content: const Text(
                                          '¿Eliminar este link? Esta acción no se puede deshacer.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (ok == true) {
                                      await _service.deleteLink(id);
                                      if (mounted) {
                                        CustomSnackBar.show(
                                          context,
                                          message: 'Link eliminado',
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Crea un nuevo link con token único
  Future<void> _createNewLink() async {
    try {
      final docRef = await _service.createLink();
      final doc = await docRef.get();
      final token = doc.data()?['editToken'];
      final linkUrl = 'https://kytron-apps.web.app/book/$token';

      if (mounted) {
        CustomSnackBar.show(context, message: 'Link generado correctamente');
      }
      await Clipboard.setData(ClipboardData(text: linkUrl));

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Link generado'),
            content: SelectableText(linkUrl),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generando link: $e');
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Error generando link',
          isError: true,
        );
      }
    }
  }
}
