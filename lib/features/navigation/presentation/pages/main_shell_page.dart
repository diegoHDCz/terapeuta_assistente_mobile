import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terapeuta_assistente_mobile/core/common/widgets/cubits/app_user_cubit.dart';
import 'package:terapeuta_assistente_mobile/core/theme/app_palette.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/presentation/pages/agenda_page.dart';
import 'package:terapeuta_assistente_mobile/features/history/presentation/pages/history_page.dart';
import 'package:terapeuta_assistente_mobile/features/home/presentation/pages/home_page.dart';
import 'package:terapeuta_assistente_mobile/features/patients/presentation/pages/patients_page.dart';
import 'package:terapeuta_assistente_mobile/features/profile/presentation/pages/profile_page.dart';

const _patientRole = 'patient';

/// Shown after a successful login/signup. Hosts the bottom navigation bar
/// and swaps between the main tabs; [LoginPage] and [SignupPage] never
/// build this widget, so the bar stays out of the auth flow.
///
/// The third tab depends on the logged-in user's role (from [AppUserCubit]):
/// patients see their own [HistoryPage], every other role (e.g. the
/// therapist/admin) sees [PatientsPage].
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appUserState = context.watch<AppUserCubit>().state;
    final isPatient = appUserState is AppUserLoggedIn && appUserState.user.role == _patientRole;

    final pages = [
      const HomePage(),
      const AgendaPage(),
      isPatient ? const HistoryPage() : const PatientsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppPalette.whiteIce,
        selectedItemColor: AppPalette.terracotta,
        unselectedItemColor: AppPalette.textSecondary,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          isPatient
              ? const BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history),
                  label: 'Histórico',
                )
              : const BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Pacientes',
                ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
