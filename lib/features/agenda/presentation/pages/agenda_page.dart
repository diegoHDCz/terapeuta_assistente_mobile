import 'package:flutter/material.dart';
import 'package:terapeuta_assistente_mobile/core/theme/app_palette.dart';
import 'package:terapeuta_assistente_mobile/core/utils/show_toast.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/domain/models/appointment.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/presentation/utils/pt_br_date.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/presentation/widgets/agenda_blocked_state.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/presentation/widgets/agenda_empty_state.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/presentation/widgets/agenda_week_strip.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/presentation/widgets/appointment_card.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/presentation/widgets/session_form_sheet.dart';

/// Agenda skeleton: week strip + day list backed by an in-memory mock list.
/// Wire this up to a real AgendaBloc/repository once appointment data lives
/// in Supabase — the widgets below (card, sheet, empty state) are already
/// shaped around the [Appointment] model so that swap should stay local to
/// this file.
class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late DateTime _selectedDate;
  late DateTime _weekStart;
  late List<Appointment> _appointments;

  /// Names registered as leads through a free consultation, kept separate
  /// from [mockPatientNames] (already-registered patients). Once Leads has
  /// a real data source, move this into that feature and drop it here.
  final Set<String> _leadNames = {'Marina Alves'};

  /// Days locked against new appointments (e.g. vacation, day off).
  /// Existing appointments already on a blocked day are left untouched —
  /// blocking only stops *new* ones from being created.
  final Set<DateTime> _blockedDays = {};

  @override
  void initState() {
    super.initState();
    final today = DateTime.now().dateOnly;
    _selectedDate = today;
    _weekStart = today.subtract(Duration(days: today.weekday - 1));
    _appointments = _seedMockAppointments(today);
  }

  List<Appointment> _seedMockAppointments(DateTime today) {
    return [
      Appointment(
        id: '1',
        patientName: 'Ana Souza',
        start: DateTime(today.year, today.month, today.day, 9, 0),
        status: AppointmentStatus.confirmed,
      ),
      Appointment(
        id: '2',
        patientName: 'Bruno Lima',
        start: DateTime(today.year, today.month, today.day, 11, 0),
        duration: const Duration(minutes: 60),
        status: AppointmentStatus.pending,
        notes: 'Primeira sessão de avaliação.',
      ),
      Appointment(
        id: '3',
        patientName: 'Carla Menezes',
        start: DateTime(today.year, today.month, today.day, 16, 30),
        status: AppointmentStatus.pending,
      ),
      Appointment(
        id: '4',
        patientName: 'Diego Prado',
        start: today.add(const Duration(days: 1)).add(const Duration(hours: 10)),
        status: AppointmentStatus.confirmed,
      ),
      Appointment(
        id: '5',
        patientName: 'Elisa Tavares',
        start: today.subtract(const Duration(days: 1)).add(const Duration(hours: 14)),
        status: AppointmentStatus.completed,
      ),
      Appointment(
        id: '6',
        patientName: 'Marina Alves',
        start: today.add(const Duration(days: 2)).add(const Duration(hours: 15)),
        duration: const Duration(minutes: 30),
        type: AppointmentType.freeConsultation,
        status: AppointmentStatus.confirmed,
      ),
    ];
  }

  List<Appointment> get _dayAppointments {
    final list = _appointments.where((a) => a.start.isSameDay(_selectedDate)).toList();
    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  bool _hasAppointmentsOn(DateTime day) {
    return _appointments.any((a) => a.start.isSameDay(day));
  }

  bool _isDayBlocked(DateTime day) {
    return _blockedDays.any((d) => d.isSameDay(day));
  }

  Future<void> _toggleBlockedDay(DateTime day) async {
    if (_isDayBlocked(day)) {
      setState(() => _blockedDays.removeWhere((d) => d.isSameDay(day)));
      showInfoToast('Agenda desbloqueada para este dia');
      return;
    }

    final existingCount = _appointments.where((a) => a.start.isSameDay(day)).length;
    if (existingCount > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bloquear dia com sessões marcadas'),
          content: Text(
            'Este dia já tem ${existingCount == 1 ? '1 sessão marcada' : '$existingCount sessões marcadas'}. '
            'Bloquear impede novos agendamentos, mas não cancela os existentes. Continuar?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Bloquear', style: TextStyle(color: AppPalette.error)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _blockedDays.add(day.dateOnly));
    showSuccessToast('Agenda bloqueada para este dia');
  }

  void _requestNewAppointment() {
    if (_isDayBlocked(_selectedDate)) {
      showInfoToast('Agenda bloqueada neste dia. Desbloqueie para marcar.');
      return;
    }
    _openScheduleTypePicker();
  }

  void _goToPreviousWeek() {
    setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  }

  void _goToNextWeek() {
    setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
  }

  void _selectDay(DateTime day) {
    setState(() => _selectedDate = day);
  }

  Future<void> _jumpToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked.dateOnly;
      _weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    });
  }

  Future<void> _openScheduleTypePicker() async {
    final type = await showModalBottomSheet<AppointmentType>(
      context: context,
      backgroundColor: AppPalette.whiteIce,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  Expanded(child: Text('O que deseja marcar?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event_note_outlined, color: AppPalette.terracotta),
              title: const Text('Nova sessão'),
              subtitle: const Text('Para um paciente já cadastrado'),
              onTap: () => Navigator.of(sheetContext).pop(AppointmentType.session),
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism_outlined, color: AppPalette.pinkDark),
              title: const Text('Consulta gratuita'),
              subtitle: const Text('Primeiro contato — o nome vira um lead'),
              onTap: () => Navigator.of(sheetContext).pop(AppointmentType.freeConsultation),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (type == null) return;
    await _openNewSessionForm(type);
  }

  Future<void> _openNewSessionForm(AppointmentType type) async {
    final suggestions = type == AppointmentType.session ? mockPatientNames : [...mockPatientNames, ..._leadNames];
    final result = await showSessionFormSheet(
      context,
      initialDate: _selectedDate,
      type: type,
      nameSuggestions: suggestions,
    );
    if (result == null) return;

    setState(() => _appointments = [..._appointments, result]);

    final isNewLead = result.type == AppointmentType.freeConsultation &&
        !mockPatientNames.any((p) => p.toLowerCase() == result.patientName.toLowerCase()) &&
        !_leadNames.any((l) => l.toLowerCase() == result.patientName.toLowerCase());

    if (isNewLead) {
      setState(() => _leadNames.add(result.patientName));
      showSuccessToast('${result.patientName} marcado(a) e registrado(a) como lead');
    } else {
      showSuccessToast('${result.type.formNoun[0].toUpperCase()}${result.type.formNoun.substring(1)} marcada com ${result.patientName}');
    }
  }

  Future<void> _openEditSessionForm(Appointment appointment) async {
    final suggestions = appointment.type == AppointmentType.session ? mockPatientNames : [...mockPatientNames, ..._leadNames];
    final result = await showSessionFormSheet(
      context,
      initialDate: _selectedDate,
      existing: appointment,
      nameSuggestions: suggestions,
    );
    if (result == null) return;
    _replaceAppointment(result);
    showSuccessToast('Sessão atualizada');
  }

  void _replaceAppointment(Appointment updated) {
    setState(() {
      _appointments = _appointments.map((a) => a.id == updated.id ? updated : a).toList();
    });
  }

  Future<void> _deleteAppointment(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir sessão'),
        content: Text('Deseja excluir a sessão de ${appointment.patientName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir', style: TextStyle(color: AppPalette.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _appointments = _appointments.where((a) => a.id != appointment.id).toList());
    showSuccessToast('Sessão excluída');
  }

  void _handleAction(Appointment appointment, AppointmentAction action) {
    switch (action) {
      case AppointmentAction.edit:
        _openEditSessionForm(appointment);
      case AppointmentAction.confirm:
        _replaceAppointment(appointment.copyWith(status: AppointmentStatus.confirmed));
        showSuccessToast('Sessão confirmada');
      case AppointmentAction.complete:
        _replaceAppointment(appointment.copyWith(status: AppointmentStatus.completed));
        showSuccessToast('Sessão concluída');
      case AppointmentAction.cancel:
        _replaceAppointment(appointment.copyWith(status: AppointmentStatus.cancelled));
        showInfoToast('Sessão cancelada');
      case AppointmentAction.delete:
        _deleteAppointment(appointment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dayAppointments = _dayAppointments;
    final isBlocked = _isDayBlocked(_selectedDate);

    Widget body;
    if (dayAppointments.isEmpty && isBlocked) {
      body = AgendaBlockedState(onUnblock: () => _toggleBlockedDay(_selectedDate));
    } else if (dayAppointments.isEmpty) {
      body = AgendaEmptyState(onNewSession: _requestNewAppointment);
    } else {
      body = Column(
        children: [
          if (isBlocked)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppPalette.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 18, color: AppPalette.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Agenda bloqueada — novos agendamentos desativados neste dia.',
                      style: textTheme.labelSmall?.copyWith(color: AppPalette.error, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _toggleBlockedDay(_selectedDate),
                    child: const Text('Desbloquear'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
              itemCount: dayAppointments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final appointment = dayAppointments[index];
                return AppointmentCard(
                  appointment: appointment,
                  onTap: () => _openEditSessionForm(appointment),
                  onAction: (action) => _handleAction(appointment, action),
                );
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppPalette.whiteIce,
      appBar: AppBar(
        title: Text(formatMonthYear(_weekStart)),
        actions: [
          IconButton(
            onPressed: _jumpToDate,
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Ir para data',
          ),
        ],
      ),
      body: Column(
        children: [
          AgendaWeekStrip(
            weekStart: _weekStart,
            selectedDate: _selectedDate,
            hasAppointments: _hasAppointmentsOn,
            isDayBlocked: _isDayBlocked,
            onSelectDay: _selectDay,
            onPreviousWeek: _goToPreviousWeek,
            onNextWeek: _goToNextWeek,
          ),
          const Divider(height: 1, color: AppPalette.whiteIceSurface),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(formatFullDate(_selectedDate), style: textTheme.titleMedium),
                ),
                if (dayAppointments.isNotEmpty) ...[
                  Text(
                    dayAppointments.length == 1 ? '1 sessão' : '${dayAppointments.length} sessões',
                    style: textTheme.labelMedium?.copyWith(color: AppPalette.textSecondary),
                  ),
                  const SizedBox(width: 4),
                ],
                IconButton(
                  onPressed: () => _toggleBlockedDay(_selectedDate),
                  tooltip: isBlocked ? 'Desbloquear este dia' : 'Bloquear este dia',
                  icon: Icon(
                    isBlocked ? Icons.lock : Icons.lock_open_outlined,
                    color: isBlocked ? AppPalette.error : AppPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _requestNewAppointment,
        backgroundColor: AppPalette.terracotta,
        foregroundColor: AppPalette.textOnBrand,
        icon: const Icon(Icons.add),
        label: const Text('Nova sessão'),
      ),
    );
  }
}
