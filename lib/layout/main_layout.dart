import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_export.dart';
import '../screens/appointment_dashboard.dart';
import '../screens/links_management_screen.dart';
import '../screens/calendar_management_screen.dart';
import '../screens/settings_management_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista de páginas para el bottom navigation
  final List<Widget> _pages = const [
    AppointmentDashboard(),
    CalendarManagementScreen(),
    LinksManagementScreen(),
    SettingsManagementScreen(),
  ];

  // Títulos para cada página
  final List<String> _titles = ['Dashboard', 'Calendario', 'Links', 'Ajustes'];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _syncWithCalendar() async {
    // Implementar sincronización con calendario
  }

  Future<void> _saveSettingsToFirestore() async {
    try {
      // Implementar guardado de configuración
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Configuración guardada correctamente',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar la configuración: $e',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onError,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.link), label: 'Links'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
      floatingActionButton: _buildFabForCurrentTab(),
    );
  }

  Widget _buildFabForCurrentTab() {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/new-appointment'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 1: // Calendario
        return FloatingActionButton.extended(
          onPressed: _syncWithCalendar,
          icon: const Icon(Icons.sync, color: Colors.white),
          label: const Text("Sincronizar"),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        );
      case 2: // Ajustes
        return FloatingActionButton(
          onPressed: _saveSettingsToFirestore,
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          child: const Icon(Icons.save, color: Colors.white),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
