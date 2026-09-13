import 'package:flutter/material.dart';
import 'package:terapeuta_assistente_mobile/core/theme/app_palette.dart';

class AgendaBlockedState extends StatelessWidget {
  final VoidCallback onUnblock;

  const AgendaBlockedState({super.key, required this.onUnblock});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppPalette.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, size: 32, color: AppPalette.error),
            ),
            const SizedBox(height: 16),
            Text('Agenda bloqueada neste dia', style: textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Você marcou este dia como indisponível. Novos agendamentos estão desativados.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onUnblock,
              icon: const Icon(Icons.lock_open_outlined),
              label: const Text('Desbloquear este dia'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppPalette.error,
                side: const BorderSide(color: AppPalette.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
