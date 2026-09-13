import 'package:flutter/material.dart';
import 'package:terapeuta_assistente_mobile/core/theme/app_palette.dart';

enum AppointmentType { session, freeConsultation }

extension AppointmentTypeX on AppointmentType {
  /// Title-case label used for chips/titles, e.g. "Nova sessão".
  String get label => switch (this) {
        AppointmentType.session => 'Sessão',
        AppointmentType.freeConsultation => 'Consulta gratuita',
      };

  /// Lowercase noun used inline, e.g. "Editar {formNoun}".
  String get formNoun => switch (this) {
        AppointmentType.session => 'sessão',
        AppointmentType.freeConsultation => 'consulta gratuita',
      };

  IconData get icon => switch (this) {
        AppointmentType.session => Icons.event_note_outlined,
        AppointmentType.freeConsultation => Icons.volunteer_activism_outlined,
      };
}

enum AppointmentStatus { pending, confirmed, completed, cancelled }

extension AppointmentStatusX on AppointmentStatus {
  String get label => switch (this) {
        AppointmentStatus.pending => 'Pendente',
        AppointmentStatus.confirmed => 'Confirmada',
        AppointmentStatus.completed => 'Concluída',
        AppointmentStatus.cancelled => 'Cancelada',
      };

  Color get color => switch (this) {
        AppointmentStatus.pending => AppPalette.warning,
        AppointmentStatus.confirmed => AppPalette.success,
        AppointmentStatus.completed => AppPalette.textSecondary,
        AppointmentStatus.cancelled => AppPalette.error,
      };
}

/// A therapy session slot on the agenda. This is a UI-layer skeleton model —
/// once the backend exists, swap the in-memory list in [AgendaPage] for a
/// bloc/repository backed by Supabase and keep this shape (or map to it).
class Appointment {
  final String id;
  final String patientName;
  final DateTime start;
  final Duration duration;
  final AppointmentStatus status;
  final AppointmentType type;
  final String notes;

  const Appointment({
    required this.id,
    required this.patientName,
    required this.start,
    this.duration = const Duration(minutes: 50),
    this.status = AppointmentStatus.pending,
    this.type = AppointmentType.session,
    this.notes = '',
  });

  DateTime get end => start.add(duration);

  Appointment copyWith({
    String? patientName,
    DateTime? start,
    Duration? duration,
    AppointmentStatus? status,
    AppointmentType? type,
    String? notes,
  }) {
    return Appointment(
      id: id,
      patientName: patientName ?? this.patientName,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      type: type ?? this.type,
      notes: notes ?? this.notes,
    );
  }
}

/// Placeholder patient directory used to power the patient-picker
/// autocomplete until the Pacientes feature exposes a real data source.
const mockPatientNames = [
  'Ana Souza',
  'Bruno Lima',
  'Carla Menezes',
  'Diego Prado',
  'Elisa Tavares',
  'Fábio Nogueira',
];
