import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../widgets/working_hours_widget.dart';
import '../widgets/blocked_dates_widget.dart';

class SettingsManagementScreen extends StatefulWidget {
  const SettingsManagementScreen({Key? key}) : super(key: key);

  @override
  State<SettingsManagementScreen> createState() => _SettingsManagementScreenState();
}

class _SettingsManagementScreenState extends State<SettingsManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  Map<String, bool> _workingDays = {
    'Lunes': true,
    'Martes': true,
    'Miércoles': true,
    'Jueves': true,
    'Viernes': true,
    'Sábado': false,
    'Domingo': false,
  };

  Map<String, TimeOfDay> _startTimes = {
    'Lunes': TimeOfDay(hour: 9, minute: 0),
    'Martes': TimeOfDay(hour: 9, minute: 0),
    'Miércoles': TimeOfDay(hour: 9, minute: 0),
    'Jueves': TimeOfDay(hour: 9, minute: 0),
    'Viernes': TimeOfDay(hour: 9, minute: 0),
  };

  Map<String, TimeOfDay> _endTimes = {
    'Lunes': TimeOfDay(hour: 18, minute: 0),
    'Martes': TimeOfDay(hour: 18, minute: 0),
    'Miércoles': TimeOfDay(hour: 18, minute: 0),
    'Jueves': TimeOfDay(hour: 18, minute: 0),
    'Viernes': TimeOfDay(hour: 18, minute: 0),
  };

  Set<DateTime> _blockedDates = {
    DateTime(2025, 11, 20),
    DateTime(2025, 11, 25),
    DateTime(2025, 12, 1),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Configuración de Horarios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWorkingHoursTab(),
                _buildBlockedDatesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        tabs: const [
          Tab(text: 'Horarios'),
          Tab(text: 'Bloqueados'),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursTab() {
    return SingleChildScrollView(
      child: WorkingHoursWidget(
        workingDays: _workingDays,
        startTimes: _startTimes,
        endTimes: _endTimes,
        onWorkingDayChanged: (day, value) {
          setState(() => _workingDays[day] = value);
        },
        onStartTimeChanged: (day, time) {
          setState(() => _startTimes[day] = time);
        },
        onEndTimeChanged: (day, time) {
          setState(() => _endTimes[day] = time);
        },
      ),
    );
  }

  Widget _buildBlockedDatesTab() {
    return SingleChildScrollView(
      child: BlockedDatesWidget(
        blockedDates: _blockedDates,
        onDateBlocked: (date) => setState(() => _blockedDates.add(date)),
        onDateUnblocked: (date) => setState(() => _blockedDates.remove(date)),
      ),
    );
  }
}
