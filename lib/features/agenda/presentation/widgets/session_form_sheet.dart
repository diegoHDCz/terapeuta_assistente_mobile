import 'package:flutter/material.dart';
import 'package:terapeuta_assistente_mobile/core/theme/app_palette.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/domain/models/appointment.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/presentation/utils/pt_br_date.dart';

const _durationOptions = [
  Duration(minutes: 30),
  Duration(minutes: 45),
  Duration(minutes: 50),
  Duration(minutes: 60),
  Duration(minutes: 90),
];

/// Opens the create/edit session form and returns the resulting
/// [Appointment], or null if the user dismissed the sheet without saving.
///
/// [type] only matters for a new appointment (editing keeps [existing]'s
/// type). It drives two different flows sharing this one form:
/// - [AppointmentType.session]: the name must match an already-registered
///   patient (from [nameSuggestions]).
/// - [AppointmentType.freeConsultation]: any name is accepted — a new one
///   is meant to be registered as a lead by the caller once this returns.
Future<Appointment?> showSessionFormSheet(
  BuildContext context, {
  required DateTime initialDate,
  Appointment? existing,
  AppointmentType type = AppointmentType.session,
  List<String> nameSuggestions = mockPatientNames,
}) {
  return showModalBottomSheet<Appointment>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SessionFormSheet(
      initialDate: initialDate,
      existing: existing,
      type: type,
      nameSuggestions: nameSuggestions,
    ),
  );
}

class SessionFormSheet extends StatefulWidget {
  final DateTime initialDate;
  final Appointment? existing;
  final AppointmentType type;
  final List<String> nameSuggestions;

  const SessionFormSheet({
    super.key,
    required this.initialDate,
    this.existing,
    this.type = AppointmentType.session,
    this.nameSuggestions = mockPatientNames,
  });

  @override
  State<SessionFormSheet> createState() => _SessionFormSheetState();
}

class _SessionFormSheetState extends State<SessionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _patientController;
  late final TextEditingController _notesController;
  late final AppointmentType _type;
  late DateTime _date;
  late TimeOfDay _time;
  late Duration _duration;
  late AppointmentStatus _status;

  bool get _isEditing => widget.existing != null;
  bool get _isFreeConsultation => _type == AppointmentType.freeConsultation;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.type ?? widget.type;
    _patientController = TextEditingController(text: existing?.patientName ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _date = (existing?.start ?? widget.initialDate).dateOnly;
    _time = TimeOfDay.fromDateTime(existing?.start ?? DateTime.now());
    _duration = existing?.duration ?? (_isFreeConsultation ? const Duration(minutes: 30) : const Duration(minutes: 50));
    _status = existing?.status ?? AppointmentStatus.pending;
  }

  @override
  void dispose() {
    _patientController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final start = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final result = Appointment(
      id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      patientName: _patientController.text.trim(),
      start: start,
      duration: _duration,
      status: _status,
      type: _type,
      notes: _notesController.text.trim(),
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppPalette.whiteIce,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppPalette.whiteIceSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(_type.icon, color: _isFreeConsultation ? AppPalette.pinkDark : AppPalette.terracotta, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Editar ${_type.formNoun}' : 'Nova ${_type.formNoun}',
                        style: textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: _patientController.text),
                  optionsBuilder: (value) {
                    if (value.text.isEmpty) return const Iterable<String>.empty();
                    return widget.nameSuggestions.where(
                      (name) => name.toLowerCase().contains(value.text.toLowerCase()),
                    );
                  },
                  onSelected: (selection) => _patientController.text = selection,
                  fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                    controller.text = _patientController.text;
                    controller.addListener(() => _patientController.text = controller.text);
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: _isFreeConsultation ? 'Nome' : 'Paciente',
                        prefixIcon: Icon(_isFreeConsultation ? Icons.person_add_alt_outlined : Icons.person_outline, size: 20),
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.isEmpty) {
                          return _isFreeConsultation ? 'Informe o nome' : 'Selecione o paciente';
                        }
                        if (!_isFreeConsultation && !mockPatientNames.any((p) => p.toLowerCase() == name.toLowerCase())) {
                          return 'Paciente não cadastrado — use consulta gratuita para novos contatos';
                        }
                        return null;
                      },
                    );
                  },
                ),
                if (_isFreeConsultation && !_isEditing) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Nome novo? A pessoa é registrada como lead ao marcar.',
                      style: textTheme.labelSmall?.copyWith(color: AppPalette.textSecondary),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        icon: Icons.calendar_today_outlined,
                        label: 'Data',
                        value: '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerField(
                        icon: Icons.access_time,
                        label: 'Horário',
                        value: _time.format(context),
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Duração', style: textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _durationOptions.map((duration) {
                    final selected = duration == _duration;
                    return ChoiceChip(
                      label: Text('${duration.inMinutes} min'),
                      selected: selected,
                      onSelected: (_) => setState(() => _duration = duration),
                      selectedColor: AppPalette.terracotta,
                      labelStyle: TextStyle(
                        color: selected ? AppPalette.textOnBrand : AppPalette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: AppPalette.whiteIceSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                    );
                  }).toList(),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 14),
                  Text('Status', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppointmentStatus.values.map((status) {
                      final selected = status == _status;
                      return ChoiceChip(
                        label: Text(status.label),
                        selected: selected,
                        onSelected: (_) => setState(() => _status = status),
                        selectedColor: status.color,
                        labelStyle: TextStyle(
                          color: selected ? AppPalette.textOnBrand : AppPalette.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: AppPalette.whiteIceSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observações (opcional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isEditing ? 'Salvar alterações' : 'Marcar ${_type.formNoun}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
        child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
