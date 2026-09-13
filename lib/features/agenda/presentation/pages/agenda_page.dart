import 'package:flutter/material.dart';
import 'package:terapeuta_assistente_mobile/core/theme/app_palette.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppPalette.whiteIce,
      body: Center(
        child: Text('Agenda'),
      ),
    );
  }
}
