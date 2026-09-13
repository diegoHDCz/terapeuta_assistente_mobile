import 'package:flutter/material.dart';
import 'package:terapeuta_assistente_mobile/core/theme/app_palette.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/domain/models/appointment.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/presentation/utils/pt_br_date.dart';

enum AppointmentAction { edit, confirm, complete, cancel, delete }

/// No menu icon: actions live entirely in gestures on the card itself —
/// tap to edit, swipe right to advance the status (confirm → conclude),
/// swipe left to delete, long-press for the full action list.
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;
  final ValueChanged<AppointmentAction> onAction;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
    required this.onAction,
  });

  String get _initials {
    final parts = appointment.patientName.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
    return letters.toUpperCase();
  }

  bool get _canAdvance => appointment.status == AppointmentStatus.pending || appointment.status == AppointmentStatus.confirmed;

  void _showQuickActions(BuildContext context) {
    final status = appointment.status;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppPalette.whiteIce,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        void select(AppointmentAction action) {
          Navigator.of(sheetContext).pop();
          onAction(action);
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppPalette.terracottaLight,
                      child: Text(_initials, style: const TextStyle(color: AppPalette.textOnBrand, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(appointment.patientName, style: Theme.of(sheetContext).textTheme.titleSmall),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, color: AppPalette.whiteIceSurface),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppPalette.textPrimary),
                title: const Text('Editar'),
                onTap: () => select(AppointmentAction.edit),
              ),
              if (status == AppointmentStatus.pending)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: AppPalette.success),
                  title: const Text('Confirmar'),
                  onTap: () => select(AppointmentAction.confirm),
                ),
              if (_canAdvance)
                ListTile(
                  leading: const Icon(Icons.done_all, color: AppPalette.success),
                  title: const Text('Marcar como concluída'),
                  onTap: () => select(AppointmentAction.complete),
                ),
              if (status != AppointmentStatus.cancelled)
                ListTile(
                  leading: const Icon(Icons.event_busy_outlined, color: AppPalette.warning),
                  title: const Text('Cancelar sessão'),
                  onTap: () => select(AppointmentAction.cancel),
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppPalette.error),
                title: const Text('Excluir', style: TextStyle(color: AppPalette.error)),
                onTap: () => select(AppointmentAction.delete),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = appointment.status;

    return Dismissible(
      key: ValueKey(appointment.id),
      direction: _canAdvance ? DismissDirection.horizontal : DismissDirection.endToStart,
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: AppPalette.success,
        icon: status == AppointmentStatus.pending ? Icons.check_circle_outline : Icons.done_all,
        label: status == AppointmentStatus.pending ? 'Confirmar' : 'Concluir',
      ),
      secondaryBackground: const _SwipeBackground(
        alignment: Alignment.centerRight,
        color: AppPalette.error,
        icon: Icons.delete_outline,
        label: 'Excluir',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onAction(status == AppointmentStatus.pending ? AppointmentAction.confirm : AppointmentAction.complete);
        } else {
          onAction(AppointmentAction.delete);
        }
        return false;
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          onLongPress: () => _showQuickActions(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppPalette.whiteIceSurface, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 52,
                  decoration: BoxDecoration(
                    color: status.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 48,
                  child: Column(
                    children: [
                      Text(formatTime(appointment.start), style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: AppPalette.textPrimary)),
                      const SizedBox(height: 2),
                      Text(formatTime(appointment.end), style: textTheme.labelSmall),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppPalette.terracottaLight,
                  child: Text(
                    _initials,
                    style: textTheme.labelMedium?.copyWith(color: AppPalette.textOnBrand, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.patientName, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: status.color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.label,
                              style: textTheme.labelSmall?.copyWith(color: status.color, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (appointment.type == AppointmentType.freeConsultation)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppPalette.pinkDark.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.volunteer_activism_outlined, size: 12, color: AppPalette.pinkDark),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Gratuita',
                                    style: textTheme.labelSmall?.copyWith(color: AppPalette.pinkDark, fontWeight: FontWeight.w600),
                                  ),
                                ],
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
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isStart = alignment == Alignment.centerLeft;

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isStart
            ? [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
              ]
            : [
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Icon(icon, color: color),
              ],
      ),
    );
  }
}
