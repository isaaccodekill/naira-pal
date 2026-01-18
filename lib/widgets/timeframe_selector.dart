import 'package:flutter/material.dart' hide DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

class TimeframeSelector extends ConsumerWidget {
  const TimeframeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTimeFrame = ref.watch(selectedTimeFrameProvider);

    return SegmentedButton<TimeFrame>(
      segments: const [
        ButtonSegment(value: TimeFrame.day, label: Text('Day')),
        ButtonSegment(value: TimeFrame.week, label: Text('Week')),
        ButtonSegment(value: TimeFrame.month, label: Text('Month')),
      ],
      selected: {selectedTimeFrame},
      onSelectionChanged: (selection) {
        final timeFrame = selection.first;
        ref.read(selectedTimeFrameProvider.notifier).state = timeFrame;

        final now = DateTime.now();
        late DateTimeRange range;

        switch (timeFrame) {
          case TimeFrame.day:
            final startOfDay = DateTime(now.year, now.month, now.day);
            final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
            range = DateTimeRange(start: startOfDay, end: endOfDay);
          case TimeFrame.week:
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final startOfWeekMidnight = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
            final endOfWeek = startOfWeekMidnight.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
            range = DateTimeRange(start: startOfWeekMidnight, end: endOfWeek);
          case TimeFrame.month:
            final startOfMonth = DateTime(now.year, now.month, 1);
            final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
            range = DateTimeRange(start: startOfMonth, end: endOfMonth);
          case TimeFrame.custom:
            return;
        }

        ref.read(selectedDateRangeProvider.notifier).state = range;
      },
    );
  }
}
