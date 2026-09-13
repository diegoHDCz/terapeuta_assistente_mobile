import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:terapeuta_assistente_mobile/core/theme/app_palette.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/presentation/utils/pt_br_date.dart';

/// Two-week strip with prev/next navigation. [weekStart] is expected to
/// already be normalized to the Monday of the first week being shown; the
/// second row displays the following week.
class AgendaWeekStrip extends StatelessWidget {
  final DateTime weekStart;
  final DateTime selectedDate;
  final bool Function(DateTime day) hasAppointments;
  final bool Function(DateTime day) isDayBlocked;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const AgendaWeekStrip({
    super.key,
    required this.weekStart,
    required this.selectedDate,
    required this.hasAppointments,
    required this.isDayBlocked,
    required this.onSelectDay,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    final firstWeek = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final secondWeek = List.generate(7, (i) => weekStart.add(Duration(days: 7 + i)));

    return Row(
      children: [
        IconButton(
          onPressed: onPreviousWeek,
          icon: const Icon(Icons.chevron_left, color: AppPalette.textSecondary),
        ),
        Expanded(
          child: Column(
            children: [
              _WeekRow(
                days: firstWeek,
                selectedDate: selectedDate,
                hasAppointments: hasAppointments,
                isDayBlocked: isDayBlocked,
                onSelectDay: onSelectDay,
              ),
              const SizedBox(height: 10),
              _WeekRow(
                days: secondWeek,
                selectedDate: selectedDate,
                hasAppointments: hasAppointments,
                isDayBlocked: isDayBlocked,
                onSelectDay: onSelectDay,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNextWeek,
          icon: const Icon(Icons.chevron_right, color: AppPalette.textSecondary),
        ),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selectedDate;
  final bool Function(DateTime day) hasAppointments;
  final bool Function(DateTime day) isDayBlocked;
  final ValueChanged<DateTime> onSelectDay;

  const _WeekRow({
    required this.days,
    required this.selectedDate,
    required this.hasAppointments,
    required this.isDayBlocked,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isSelected = day.isSameDay(selectedDate);
        final isToday = day.isSameDay(DateTime.now());

        return _DayCell(
          day: day,
          isSelected: isSelected,
          isToday: isToday,
          hasAppointments: hasAppointments(day),
          isBlocked: isDayBlocked(day),
          onTap: () => onSelectDay(day),
        );
      }).toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool hasAppointments;
  final bool isBlocked;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasAppointments,
    required this.isBlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            weekdayAbbrev[day.weekday - 1],
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppPalette.terracotta : AppPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? AppPalette.terracotta : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected ? Border.all(color: AppPalette.terracotta, width: 1.5) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppPalette.textOnBrand : AppPalette.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 10,
            child: isBlocked
                ? Icon(Icons.lock, size: 10, color: isSelected ? AppPalette.textOnBrand : AppPalette.error)
                : Container(
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(
                      color: hasAppointments ? (isSelected ? AppPalette.terracotta : AppPalette.pinkDark) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
