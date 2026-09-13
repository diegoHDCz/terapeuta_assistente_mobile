import 'package:flutter/material.dart';
import 'package:terapeuta_assistente_mobile/core/theme/app_palette.dart';

class AgendaEmptyState extends StatelessWidget {
  final VoidCallback onNewSession;

  const AgendaEmptyState({super.key, required this.onNewSession});

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
              decoration: const BoxDecoration(
                color: AppPalette.whiteIceSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_available_outlined, size: 32, color: AppPalette.terracotta),
            ),
            const SizedBox(height: 16),
            Text('Nenhuma sessão neste dia', style: textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Toque no botão abaixo para marcar uma nova sessão.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onNewSession,
              icon: const Icon(Icons.add),
              label: const Text('Marcar sessão'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppPalette.terracotta,
                side: const BorderSide(color: AppPalette.terracotta),
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
