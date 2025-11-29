import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calorie_calculator/core/db/dao/reports_dao.dart';
import 'package:calorie_calculator/l10n/app_localizations.dart';
import 'package:calorie_calculator/features/food/data/meal_dao.dart';
import 'package:calorie_calculator/features/food/models/meal_record.dart';
import 'package:calorie_calculator/core/navigation/route_aware_mixin.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with RouteAwareState<ReportsPage> {
  final GlobalKey<_DailyReportViewState> _dailyKey = GlobalKey();
  final GlobalKey<_WeeklyReportViewState> _weeklyKey = GlobalKey();
  final GlobalKey<_MonthlyReportViewState> _monthlyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Initial refresh will be triggered by RouteAware didPush
    // as soon as the page becomes visible.
  }

  @override
  void onPageVisible() {
    _dailyKey.currentState?.refresh();
    _weeklyKey.currentState?.refresh();
    _monthlyKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.reports_title),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: t.report_tab_daily),
              Tab(text: t.report_tab_weekly),
              Tab(text: t.report_tab_monthly),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DailyReportView(key: _dailyKey),
            _WeeklyReportView(key: _weeklyKey),
            _MonthlyReportView(key: _monthlyKey),
          ],
        ),
      ),
    );
  }
}

class _DailyReportView extends StatefulWidget {
  const _DailyReportView({super.key});
  @override
  State<_DailyReportView> createState() => _DailyReportViewState();
}

class _DailyReportViewState extends State<_DailyReportView> {
  DateTime _selected = DateTime.now();
  int _total = 0;
  List<MealRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selected = picked);
      _load();
    }
  }

  Future<void> _load() async {
    final d = DateFormat('yyyy-MM-dd').format(_selected);
    final t = await ReportsDao.instance.totalCaloriesByDate(d);
    final items = await MealDao.instance.listByDate(d);
    setState(() {
      _total = t;
      _items = items;
    });
  }

  void refresh() => _load();

  @override
  Widget build(BuildContext context) {
    final label = DateFormat.yMMMd().format(_selected);
    final t = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t.report_date_label(label),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: _pickDate,
              icon: const Icon(Icons.date_range),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: t.report_calories_eaten,
          value: '$_total ${t.unit_kcal}',
        ),
        const SizedBox(height: 12),
        if (_items.isEmpty)
          Text(t.food_empty_list, style: Theme.of(context).textTheme.bodyMedium)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final it = _items[index];
              String mealLabel(String key) {
                switch (key) {
                  case 'breakfast':
                    return t.meal_breakfast;
                  case 'lunch':
                    return t.meal_lunch;
                  case 'dinner':
                    return t.meal_dinner;
                  default:
                    return t.meal_snacks;
                }
              }

              return ListTile(
                leading: const Icon(Icons.restaurant_outlined),
                title: Text(it.name),
                subtitle: Text(mealLabel(it.mealType)),
                trailing: Text('${it.calories} ${t.unit_kcal}'),
              );
            },
          ),
      ],
    );
  }
}

class _WeeklyReportView extends StatefulWidget {
  const _WeeklyReportView({super.key});
  @override
  State<_WeeklyReportView> createState() => _WeeklyReportViewState();
}

class _WeeklyReportViewState extends State<_WeeklyReportView> {
  DateTime _start = _mondayOf(DateTime.now());
  List<Map<String, Object?>> _rows = const [];

  static DateTime _mondayOf(DateTime d) =>
      d.subtract(Duration(days: d.weekday - 1));

  // ISO-8601 helpers: week starts Monday, week 1 has Jan 4th
  int _isoWeekNumber(DateTime date) {
    // Shift to Thursday in current week to ensure correct year association
    final weekdayIndex = (date.weekday + 6) % 7; // Mon=0..Sun=6
    final thursday = date.subtract(Duration(days: weekdayIndex - 3));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final firstWeekMonday = firstThursday.subtract(
      Duration(days: (firstThursday.weekday + 6) % 7),
    );
    return 1 + (thursday.difference(firstWeekMonday).inDays ~/ 7);
  }

  int _weeksInYear(int year) {
    // ISO weeks count equals the week number of Dec 28
    return _isoWeekNumber(DateTime(year, 12, 28));
  }

  DateTime _isoWeekStart(int year, int week) {
    // Monday of ISO week 1: week containing Jan 4
    final jan4 = DateTime(year, 1, 4);
    final week1Monday = jan4.subtract(Duration(days: (jan4.weekday + 6) % 7));
    return week1Monday.add(Duration(days: (week - 1) * 7));
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _pickWeek() async {
    final initialYear = _start.year;
    final initialWeek = _isoWeekNumber(_start);
    final selection = await showModalBottomSheet<_WeekSelection>(
      context: context,
      isScrollControlled: false,
      builder: (ctx) {
        final t = AppLocalizations.of(ctx)!;
        int year = initialYear;
        int week = initialWeek;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              final maxWeeks = _weeksInYear(year);
              if (week > maxWeeks) week = maxWeeks;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.report_select_week_title,
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: t.report_year_label,
                            border: const OutlineInputBorder(),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: year,
                              items: List.generate(5, (i) {
                                final y = initialYear - 2 + i;
                                return DropdownMenuItem(
                                  value: y,
                                  child: Text('$y'),
                                );
                              }),
                              onChanged: (v) {
                                if (v == null) return;
                                setSheetState(() {
                                  year = v;
                                  final wMax = _weeksInYear(year);
                                  if (week > wMax) week = wMax;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: t.report_week_label,
                            border: const OutlineInputBorder(),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: week,
                              items: List.generate(_weeksInYear(year), (i) {
                                final w = i + 1;
                                return DropdownMenuItem(
                                  value: w,
                                  child: Text('$w'),
                                );
                              }),
                              onChanged: (v) {
                                if (v == null) return;
                                setSheetState(() => week = v);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          MaterialLocalizations.of(ctx).cancelButtonLabel,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () =>
                            Navigator.of(ctx).pop(_WeekSelection(year, week)),
                        child: Text(t.common_ok),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    if (!mounted) return;
    if (selection != null) {
      setState(() => _start = _isoWeekStart(selection.year, selection.week));
      _load();
    }
  }

  Future<void> _load() async {
    final sdf = DateFormat('yyyy-MM-dd');
    final start = sdf.format(_start);
    final end = sdf.format(_start.add(const Duration(days: 6)));
    final rows = await ReportsDao.instance.weeklyTotals(start, end);
    setState(() => _rows = rows);
  }

  void refresh() => _load();

  @override
  Widget build(BuildContext context) {
    final sdf = DateFormat('yyyy-MM-dd');
    final t = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t.report_week_range(
                  sdf.format(_start),
                  sdf.format(_start.add(const Duration(days: 6))),
                ),
              ),
            ),
            IconButton(
              onPressed: _pickWeek,
              icon: const Icon(Icons.date_range),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(7, (i) {
          final day = _start.add(Duration(days: i));
          final key = DateFormat('yyyy-MM-dd').format(day);
          final row = _rows.firstWhere(
            (e) => e['date'] == key,
            orElse: () => {'total': 0},
          );
          final total =
              (row['total'] as int?) ?? (row['total'] as num?)?.toInt() ?? 0;
          final pct = (total / 2500).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    DateFormat.EEEE(
                      Localizations.localeOf(context).toString(),
                    ).format(day),
                  ),
                ),
                Expanded(child: LinearProgressIndicator(value: pct.toDouble())),
                const SizedBox(width: 12),
                Text('$total ${t.unit_kcal}'),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _MonthlyReportView extends StatefulWidget {
  const _MonthlyReportView({super.key});
  @override
  State<_MonthlyReportView> createState() => _MonthlyReportViewState();
}

class _MonthlyReportViewState extends State<_MonthlyReportView> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  List<Map<String, Object?>> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _pickMonth() async {
    final initialYear = _month.year;
    final initialMonth = _month.month;
    final selection = await showModalBottomSheet<_MonthSelection>(
      context: context,
      isScrollControlled: false,
      builder: (ctx) {
        final t = AppLocalizations.of(ctx)!;
        int year = initialYear;
        int month = initialMonth;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              final locale = Localizations.localeOf(ctx).toString();
              final monthNames = List<String>.generate(12, (i) {
                final m = i + 1;
                return DateFormat.MMMM(locale).format(DateTime(2000, m, 1));
              });
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.report_select_month_title,
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: t.report_year_label,
                            border: const OutlineInputBorder(),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: year,
                              items: List.generate(7, (i) {
                                final y = initialYear - 3 + i;
                                return DropdownMenuItem(
                                  value: y,
                                  child: Text('$y'),
                                );
                              }),
                              onChanged: (v) {
                                if (v == null) return;
                                setSheetState(() => year = v);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: t.report_month_label,
                            border: const OutlineInputBorder(),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: month,
                              items: List.generate(12, (i) {
                                final m = i + 1;
                                return DropdownMenuItem(
                                  value: m,
                                  child: Text(monthNames[i]),
                                );
                              }),
                              onChanged: (v) {
                                if (v == null) return;
                                setSheetState(() => month = v);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          MaterialLocalizations.of(ctx).cancelButtonLabel,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () =>
                            Navigator.of(ctx).pop(_MonthSelection(year, month)),
                        child: Text(t.common_ok),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    if (!mounted) return;
    if (selection != null) {
      setState(() => _month = DateTime(selection.year, selection.month, 1));
      _load();
    }
  }

  Future<void> _load() async {
    final prefix = DateFormat('yyyy-MM').format(_month);
    final rows = await ReportsDao.instance.monthlyTotals(prefix);
    setState(() => _rows = rows);
  }

  void refresh() => _load();

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final t = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: Text(DateFormat.yMMM().format(_month))),
            IconButton(
              onPressed: _pickMonth,
              icon: const Icon(Icons.date_range),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: daysInMonth,
          itemBuilder: (_, i) {
            final day = i + 1;
            final key = DateFormat(
              'yyyy-MM-dd',
            ).format(DateTime(_month.year, _month.month, day));
            final row = _rows.firstWhere(
              (e) => e['date'] == key,
              orElse: () => {'total': 0},
            );
            final total =
                (row['total'] as int?) ?? (row['total'] as num?)?.toInt() ?? 0;
            final pct = (total / 2500).clamp(0.0, 1.0);
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t.report_month_day_n(day)),
                  LinearProgressIndicator(value: pct.toDouble()),
                  Text('$total ${t.unit_kcal}'),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _WeekSelection {
  final int year;
  final int week;
  const _WeekSelection(this.year, this.week);
}

class _MonthSelection {
  final int year;
  final int month;
  const _MonthSelection(this.year, this.month);
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
