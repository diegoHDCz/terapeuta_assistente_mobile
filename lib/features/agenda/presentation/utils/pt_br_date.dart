const weekdayAbbrev = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];

const weekdayFull = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
];

const monthNames = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

String twoDigits(int n) => n.toString().padLeft(2, '0');

String formatTime(DateTime d) => '${twoDigits(d.hour)}:${twoDigits(d.minute)}';

String formatFullDate(DateTime d) {
  return '${weekdayFull[d.weekday - 1]}, ${d.day} de ${monthNames[d.month - 1].toLowerCase()}';
}

String formatMonthYear(DateTime d) => '${monthNames[d.month - 1]} de ${d.year}';

extension DateOnly on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
