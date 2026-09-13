import 'package:flutter/material.dart';
import 'package:terapeuta_assistente_mobile/core/theme/app_palette.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppPalette.whiteIce,
      body: Center(
        child: Text('Histórico'),
      ),
    );
  }
}
