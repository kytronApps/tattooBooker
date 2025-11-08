import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SyncIndicatorWidget extends StatefulWidget {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final VoidCallback? onRetrySync;

  const SyncIndicatorWidget({
    Key? key,
    required this.isOnline,
    this.isSyncing = false,
    this.lastSyncTime,
    this.onRetrySync,
  }) : super(key: key);

  @override
  State<SyncIndicatorWidget> createState() => _SyncIndicatorWidgetState();
}

class _SyncIndicatorWidgetState extends State<SyncIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSyncing) {
      _rotationController.repeat();
    }
    if (!widget.isOnline) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SyncIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing != oldWidget.isSyncing) {
      if (widget.isSyncing) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
    if (widget.isOnline != oldWidget.isOnline) {
      if (!widget.isOnline) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getLastSyncText() {
    if (widget.lastSyncTime == null) return 'Nunca sincronizado';

    final now = DateTime.now();
    final difference = now.difference(widget.lastSyncTime!);

    if (difference.inMinutes < 1) {
      return 'Sincronizado ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }

  Color _getStatusColor() {
    if (!widget.isOnline) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (widget.isSyncing) {
      return AppTheme.infoColor;
    } else {
      return AppTheme.successColor;
    }
  }

  String _getStatusText() {
    if (!widget.isOnline) {
      return 'Sin conexión';
    } else if (widget.isSyncing) {
      return 'Sincronizando...';
    } else {
      return 'Conectado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isSyncing)
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * 3.14159,
                  child: CustomIconWidget(
                    iconName: 'sync',
                    color: _getStatusColor(),
                    size: 4.w,
                  ),
                );
              },
            )
          else if (!widget.isOnline)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: CustomIconWidget(
                    iconName: 'wifi_off',
                    color: _getStatusColor(),
                    size: 4.w,
                  ),
                );
              },
            )
          else
            CustomIconWidget(
              iconName: 'wifi',
              color: _getStatusColor(),
              size: 4.w,
            ),
          SizedBox(width: 2.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getStatusText(),
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.lastSyncTime != null)
                Text(
                  _getLastSyncText(),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          if (!widget.isOnline && widget.onRetrySync != null) ...[
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: widget.onRetrySync,
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: CustomIconWidget(
                  iconName: 'refresh',
                  color: Colors.white,
                  size: 3.w,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
