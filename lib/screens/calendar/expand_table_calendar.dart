
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

/// Callback exposing currently selected day.
typedef void OnDaySelected(DateTime day, List events, List holidays);

/// Callback exposing currently visible days (first and last of them), as well as current `CalendarFormat`.
typedef void OnVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format);

/// Callback exposing initially visible days (first and last of them), as well as initial `CalendarFormat`.
typedef void OnCalendarCreated(DateTime first, DateTime last, CalendarFormat format);

/// Signature for reacting to header gestures. Exposes current month and year as a `DateTime` object.
typedef void HeaderGestureCallback(DateTime focusedDay);

/// Builder signature for any text that can be localized and formatted with `DateFormat`.
typedef String TextBuilder(DateTime date, dynamic locale);

/// Signature for enabling days.
typedef bool EnabledDayPredicate(DateTime day);

/// Format to display the `TableCalendar` with.
enum CalendarFormat { month, twoWeeks, week }

/// Available animations to update the `CalendarFormat` with.
enum FormatAnimation { slide, scale }

/// Available day of week formats. `TableCalendar` will start the week with chosen day.
/// * `StartingDayOfWeek.monday`: Monday - Sunday
/// * `StartingDayOfWeek.tuesday`: Tuesday - Monday
/// * `StartingDayOfWeek.wednesday`: Wednesday - Tuesday
/// * `StartingDayOfWeek.thursday`: Thursday - Wednesday
/// * `StartingDayOfWeek.friday`: Friday - Thursday
/// * `StartingDayOfWeek.saturday`: Saturday - Friday
/// * `StartingDayOfWeek.sunday`: Sunday - Saturday
enum StartingDayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

int _getWeekdayNumber(StartingDayOfWeek weekday) {
  return StartingDayOfWeek.values.indexOf(weekday) + 1;
}

/// Gestures available to interal `TableCalendar`'s logic.
enum AvailableGestures { none, verticalSwipe, horizontalSwipe, all }

extension StringExtension on String {
  String toUpperCaseFirst() {
    if (this.length == 0) return this;
    return this.replaceFirst(this.substring(0, 1), this.substring(0, 1).toUpperCase());
  }
}

/// Highly customizable, feature-packed Flutter Calendar with gestures, animations and multiple formats.
class TableCalendar extends StatefulWidget {
  /// Controller required for `TableCalendar`.
  /// Use it to update `events`, `holidays`, etc.
  final CalendarController calendarController;

  /// Locale to format `TableCalendar` dates with, for example: `'en_US'`.
  ///
  /// If nothing is provided, a default locale will be used.
  final dynamic locale;

  /// `Map` of events.
  /// Each `DateTime` inside this `Map` should get its own `List` of objects (i.e. events).
  final Map<DateTime, List> events;

  /// `Map` of holidays.
  /// This property allows you to provide custom holiday rules.
  final Map<DateTime, List> holidays;

  /// Called whenever any day gets tapped.
  final OnDaySelected onDaySelected;

  /// Called whenever any day gets long pressed.
  final OnDaySelected onDayLongPressed;

  /// Called whenever any unavailable day gets tapped.
  /// Replaces `onDaySelected` for those days.
  final VoidCallback onUnavailableDaySelected;

  /// Called whenever any unavailable day gets long pressed.
  /// Replaces `onDaySelected` for those days.
  final VoidCallback onUnavailableDayLongPressed;

  /// Called whenever header gets tapped.
  final HeaderGestureCallback onHeaderTapped;

  /// Called whenever header gets long pressed.
  final HeaderGestureCallback onHeaderLongPressed;

  /// Called whenever the range of visible days changes.
  final OnVisibleDaysChanged onVisibleDaysChanged;

  /// Called once when the CalendarController gets initialized.
  final OnCalendarCreated onCalendarCreated;

  /// Initially selected DateTime. Usually it will be `DateTime.now()`.
  final DateTime initialSelectedDay;

  /// The first day of `TableCalendar`.
  /// Days before it will use `unavailableStyle` and run `onUnavailableDaySelected` callback.
  final DateTime startDay;

  /// The last day of `TableCalendar`.
  /// Days after it will use `unavailableStyle` and run `onUnavailableDaySelected` callback.
  final DateTime endDay;

  /// List of days treated as weekend days.
  /// Use built-in `DateTime` weekday constants (e.g. `DateTime.monday`) instead of `int` literals (e.q. `1`).
  final List<int> weekendDays;

  /// `CalendarFormat` which will be displayed first.
  final CalendarFormat initialCalendarFormat;

  /// `Map` of `CalendarFormat`s and `String` names associated with them.
  /// Those `CalendarFormat`s will be used by internal logic to manage displayed format.
  ///
  /// To ensure proper vertical Swipe behavior, `CalendarFormat`s should be in descending order (eg. from biggest to smallest).
  ///
  /// For example:
  /// ```dart
  /// availableCalendarFormats: const {
  ///   CalendarFormat.month: 'Month',
  ///   CalendarFormat.week: 'Week',
  /// }
  /// ```
  final Map<CalendarFormat, String> availableCalendarFormats;

  /// Used to show/hide Bottom
  final bool bottomVisible;

  /// Used to show/hide Header.
  final bool headerVisible;

  /// Function deciding whether given day should be enabled or not.
  /// If `false` is returned, this day will be unavailable.
  final EnabledDayPredicate enabledDayPredicate;

  /// Used for setting the height of `TableCalendar`'s rows.
  final double rowHeight;

  /// Animation to run when `CalendarFormat` gets changed.
  final FormatAnimation formatAnimation;

  /// `TableCalendar` will start weeks with provided day.
  /// Use `StartingDayOfWeek.monday` for Monday - Sunday week format.
  /// Use `StartingDayOfWeek.sunday` for Sunday - Saturday week format.
  final StartingDayOfWeek startingDayOfWeek;

  /// `HitTestBehavior` for every day cell inside `TableCalendar`.
  final HitTestBehavior dayHitTestBehavior;

  /// Specify Gestures available to `TableCalendar`.
  /// If `AvailableGestures.none` is used, the Calendar will only be interactive via buttons.
  final AvailableGestures availableGestures;

  /// Configuration for vertical Swipe detector.
  final SimpleSwipeConfig simpleSwipeConfig;

  /// Style for `TableCalendar`'s content.
  final CalendarStyle calendarStyle;

  /// Style for DaysOfWeek displayed between `TableCalendar`'s Header and content.
  final DaysOfWeekStyle daysOfWeekStyle;

  /// Style for `TableCalendar`'s Header.
  final HeaderStyle headerStyle;

  /// Set of Builders for `TableCalendar` to work with.
  final CalendarBuilders builders;

  final bool dayOfWeekInHeader;

  final Function(DateTime) onMonthChange;

  TableCalendar({
    Key key,
    @required this.calendarController,
    this.locale,
    this.events = const {},
    this.holidays = const {},
    this.onDaySelected,
    this.onDayLongPressed,
    this.onUnavailableDaySelected,
    this.onUnavailableDayLongPressed,
    this.onHeaderTapped,
    this.onHeaderLongPressed,
    this.onVisibleDaysChanged,
    this.onCalendarCreated,
    this.initialSelectedDay,
    this.startDay,
    this.endDay,
    this.weekendDays = const [DateTime.saturday, DateTime.sunday],
    this.initialCalendarFormat = CalendarFormat.month,
    this.availableCalendarFormats = const {
      CalendarFormat.month: 'Month',
      CalendarFormat.twoWeeks: '2 weeks',
      CalendarFormat.week: 'Week',
    },
    this.headerVisible = true,
    this.bottomVisible = true,
    this.enabledDayPredicate,
    this.rowHeight,
    this.formatAnimation = FormatAnimation.slide,
    this.startingDayOfWeek = StartingDayOfWeek.sunday,
    this.dayHitTestBehavior = HitTestBehavior.deferToChild,
    this.availableGestures = AvailableGestures.all,
    this.simpleSwipeConfig = const SimpleSwipeConfig(
      verticalThreshold: 25.0,
      swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
    ),
    this.calendarStyle = const CalendarStyle(),
    this.daysOfWeekStyle = const DaysOfWeekStyle(),
    this.headerStyle = const HeaderStyle(),
    this.builders = const CalendarBuilders(),
    this.dayOfWeekInHeader = false,
    this.onMonthChange,
  })  : assert(calendarController != null),
        assert(availableCalendarFormats.keys.contains(initialCalendarFormat)),
        assert(availableCalendarFormats.length <= CalendarFormat.values.length),
        assert(weekendDays != null),
        assert(weekendDays.isNotEmpty
            ? weekendDays.every((day) => day >= DateTime.monday && day <= DateTime.sunday)
            : true),
        super(key: key);

  @override
  _TableCalendarState createState() => _TableCalendarState();
}

class _TableCalendarState extends State<TableCalendar> with TickerProviderStateMixin {
  AnimationController _animationController;
  static const minHeight = 200.0;
  static const maxHeight = 400.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    widget.calendarController._init(
      events: widget.events,
      holidays: widget.holidays,
      initialDay: widget.initialSelectedDay,
      initialFormat: widget.initialCalendarFormat,
      availableCalendarFormats: widget.availableCalendarFormats,
      useNextCalendarFormat: widget.headerStyle.formatButtonShowsNext,
      startingDayOfWeek: widget.startingDayOfWeek,
      selectedDayCallback: _selectedDayCallback,
      monthChangeCallback: _monthChangeCallback,
      onVisibleDaysChanged: widget.onVisibleDaysChanged,
      onCalendarCreated: widget.onCalendarCreated,
      includeInvisibleDays: widget.calendarStyle.outsideDaysVisible,
    );
  }

  @override
  void didUpdateWidget(TableCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.events != widget.events) {
      widget.calendarController._events = widget.events;
    }

    if (oldWidget.holidays != widget.holidays) {
      widget.calendarController._holidays = widget.holidays;
    }

    if (oldWidget.availableCalendarFormats != widget.availableCalendarFormats) {
      widget.calendarController._availableCalendarFormats = widget.availableCalendarFormats;
    }
  }

  void _selectedDayCallback(DateTime day) {
    if (widget.onDaySelected != null) {
      widget.onDaySelected(
        day,
        widget.calendarController.visibleEvents[_getEventKey(day)] ?? [],
        widget.calendarController.visibleHolidays[_getHolidayKey(day)] ?? [],
      );
    }
  }

  void _monthChangeCallback(DateTime day) {
    if (widget.onMonthChange != null) {
      widget.onMonthChange(day);
    }
  }

  void _selectPrevious() {
    setState(() {
      widget.calendarController._selectPrevious();
    });
  }

  void _selectNext() {
    setState(() {
      widget.calendarController._selectNext();
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      widget.calendarController.setSelectedDay(day, isProgrammatic: false);
      _selectedDayCallback(day);
    });
  }

  void _onDayLongPressed(DateTime day) {
    if (widget.onDayLongPressed != null) {
      widget.onDayLongPressed(
        day,
        widget.calendarController.visibleEvents[_getEventKey(day)] ?? [],
        widget.calendarController.visibleHolidays[_getHolidayKey(day)] ?? [],
      );
    }
  }

  void _toggleCalendarFormat() {
    setState(() {
      widget.calendarController.toggleCalendarFormat();
    });
  }

  void _onHorizontalSwipe(DismissDirection direction) {
    if (direction == DismissDirection.startToEnd) {
      // Swipe right
      _selectPrevious();
    } else {
      // Swipe left
      _selectNext();
    }
  }

  void _onUnavailableDaySelected() {
    if (widget.onUnavailableDaySelected != null) {
      widget.onUnavailableDaySelected();
    }
  }

  void _onUnavailableDayLongPressed() {
    if (widget.onUnavailableDayLongPressed != null) {
      widget.onUnavailableDayLongPressed();
    }
  }

  void _onHeaderTapped() {
    if (widget.onHeaderTapped != null) {
      widget.onHeaderTapped(widget.calendarController.focusedDay);
    }
  }

  void _onHeaderLongPressed() {
    if (widget.onHeaderLongPressed != null) {
      widget.onHeaderLongPressed(widget.calendarController.focusedDay);
    }
  }

  bool _isDayUnavailable(DateTime day) {
    return (widget.startDay != null && day.isBefore(widget.calendarController._normalizeDate(widget.startDay))) ||
        (widget.endDay != null && day.isAfter(widget.calendarController._normalizeDate(widget.endDay))) ||
        (!_isDayEnabled(day));
  }

  bool _isDayEnabled(DateTime day) {
    return widget.enabledDayPredicate == null ? true : widget.enabledDayPredicate(day);
  }

  DateTime _getEventKey(DateTime day) {
    return widget.calendarController._getEventKey(day);
  }

  DateTime _getHolidayKey(DateTime day) {
    return widget.calendarController._getHolidayKey(day);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.headerVisible) _buildHeader(),
          Padding(
            padding: widget.calendarStyle.contentPadding,
            child: _buildCalendarContent(),
          ),
          if(widget.bottomVisible) _buildVerticalSwipeWrapper(child: _buildBottomLine()),
        ],
      ),
    );
  }

  // https://github.com/MarcinusX/buy_ticket_design/blob/master/lib/exhibition_bottom_sheet.dart#L136
  void _toggle() {
    final isOpen = _animationController.isCompleted;
    _animationController.fling(velocity: isOpen ? -2 : 2);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _animationController.value += details.primaryDelta /
        (maxHeight - minHeight);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_animationController.isAnimating || _animationController.isCompleted)
      return;

    final flingVelocity = details.velocity.pixelsPerSecond.dy /
        (maxHeight - minHeight);

    if (flingVelocity < 0.0) {
      _animationController.fling(velocity: math.min(-2.0, flingVelocity));
    } else if (flingVelocity > 0.0) {
      _animationController.fling(velocity: math.max(2.0, flingVelocity));
    } else {
      _animationController.fling(
          velocity: _animationController.value < 0.5 ? -2.0 : 2.0);
    }
  }

  Widget _buildBottomLine(){
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      color: Colors.transparent,
      height: 25,
      child: Center(
        child: Container(
          height: 4,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: widget.calendarStyle.bottomColor
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final children = [
      widget.headerStyle.showLeftChevron ?
      _CustomIconButton(
        icon: widget.headerStyle.leftChevronIcon,
        onTap: _selectPrevious,
        margin: widget.headerStyle.leftChevronMargin,
        padding: widget.headerStyle.leftChevronPadding,
      ) : Container(),
      Expanded(
        child: GestureDetector(
          onTap: _onHeaderTapped,
          onLongPress: _onHeaderLongPressed,
          child: Text(
            widget.headerStyle.titleTextBuilder != null
                ? widget.headerStyle.titleTextBuilder(widget.calendarController.focusedDay, widget.locale)
                : DateFormat.yMMMM(widget.locale).format(widget.calendarController.focusedDay)?.toUpperCaseFirst(),
            style: widget.headerStyle.titleTextStyle,
            textAlign: widget.headerStyle.centerHeaderTitle ? TextAlign.center : TextAlign.start,
          ),
        ),
      ),
      widget.headerStyle.showRightChevron ?
      _CustomIconButton(
        icon: widget.headerStyle.rightChevronIcon,
        onTap: _selectNext,
        margin: widget.headerStyle.rightChevronMargin,
        padding: widget.headerStyle.rightChevronPadding,
      ) : Container()
    ];

    if (widget.headerStyle.formatButtonVisible && widget.availableCalendarFormats.length > 1) {
      children.insert(2, const SizedBox(width: 8.0));
      children.insert(3, _buildFormatButton());
    }

    return Container(
      decoration: widget.headerStyle.decoration,
      margin: widget.headerStyle.headerMargin,
      padding: widget.headerStyle.headerPadding,
      child: widget.dayOfWeekInHeader ? Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: children,
          ),

          SizedBox(height: 20,),

          Table(
            children: [
              _buildDaysOfWeek(),
            ],
          ),
        ],
      ) : Row(
        mainAxisSize: MainAxisSize.max,
        children: children,
      ),
    );
  }

  Widget _buildFormatButton() {
    return GestureDetector(
      onTap: _toggleCalendarFormat,
      child: Container(
        decoration: widget.headerStyle.formatButtonDecoration,
        padding: widget.headerStyle.formatButtonPadding,
        child: Text(
          widget.calendarController._getFormatButtonText(),
          style: widget.headerStyle.formatButtonTextStyle,
        ),
      ),
    );
  }

  Widget _buildCalendarContent() {
    if (widget.formatAnimation == FormatAnimation.slide) {
      return AnimatedSize(
        duration: Duration(milliseconds: widget.calendarController.calendarFormat == CalendarFormat.month ? 330 : 330),
        curve: Curves.fastLinearToSlowEaseIn,
        alignment: Alignment(0, -1),
        vsync: this,
        child: _buildWrapper(),
      );
    } else {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          return SizeTransition(
            sizeFactor: animation,
            child: SizeTransition(
              sizeFactor: animation,
              child: child,
            ),
          );
        },
        child: _buildWrapper(
          key: ValueKey(widget.calendarController.calendarFormat),
        ),
      );
    }
  }

  Widget _buildWrapper({Key key}) {
    Widget wrappedChild = _buildTable();

    switch (widget.availableGestures) {
      case AvailableGestures.all:
        wrappedChild = _buildVerticalSwipeWrapper(
          child: _buildHorizontalSwipeWrapper(
            child: wrappedChild,
          ),
        );
        break;
      case AvailableGestures.verticalSwipe:
        wrappedChild = _buildVerticalSwipeWrapper(
          child: wrappedChild,
        );
        break;
      case AvailableGestures.horizontalSwipe:
        wrappedChild = _buildHorizontalSwipeWrapper(
          child: wrappedChild,
        );
        break;
      case AvailableGestures.none:
        break;
    }

    return Container(
      key: key,
      child: wrappedChild,
    );
  }

  Widget _buildVerticalSwipeWrapper({Widget child}) {

    return SimpleGestureDetector(
      child: child,
      onVerticalSwipe: (direction) {

        setState(() {
          widget.calendarController.swipeCalendarFormat(isSwipeUp: direction == SwipeDirection.up);
        });
      },
      swipeConfig: widget.simpleSwipeConfig,
    );
  }

  Widget _buildHorizontalSwipeWrapper({Widget child}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.fastOutSlowIn,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: Offset(widget.calendarController._dx, 0), end: Offset(0, 0)).animate(animation),
          child: child,
        );
      },
      layoutBuilder: (currentChild, _) => currentChild,
      child: Dismissible(
        key: ValueKey(widget.calendarController._pageId),
        resizeDuration: null,
        onDismissed: _onHorizontalSwipe,
        direction: DismissDirection.horizontal,
        child: child,
      ),
    );
  }

  Widget _buildTable() {
    final daysInWeek = 7;
    final children = <TableRow>[
      if (widget.calendarStyle.renderDaysOfWeek && !widget.dayOfWeekInHeader) _buildDaysOfWeek(),
    ];

    int x = 0;
    while (x < widget.calendarController._visibleDays.value.length) {
      children.add(_buildTableRow(widget.calendarController._visibleDays.value.skip(x).take(daysInWeek).toList()));
      x += daysInWeek;
    }

    return Table(
      // Makes this Table fill its parent horizontally
      defaultColumnWidth: FractionColumnWidth(1.0 / daysInWeek),
      children: children,
    );
  }

  TableRow _buildDaysOfWeek() {
    return TableRow(
      decoration: widget.daysOfWeekStyle.decoration,
      children: widget.calendarController._visibleDays.value.take(7).map((date) {
        final weekdayString = widget.daysOfWeekStyle.dowTextBuilder != null
            ? widget.daysOfWeekStyle.dowTextBuilder(date, widget.locale)
            : DateFormat.E(widget.locale).format(date);
        final isWeekend = widget.calendarController._isWeekend(date, widget.weekendDays);

        if (isWeekend && widget.builders.dowWeekendBuilder != null) {
          return widget.builders.dowWeekendBuilder(context, weekdayString);
        }
        if (widget.builders.dowWeekdayBuilder != null) {
          return widget.builders.dowWeekdayBuilder(context, weekdayString);
        }
        return Center(
          child: Text(
            widget.daysOfWeekStyle.isUpperCase ? weekdayString.toUpperCase() : weekdayString,
            style: isWeekend ? widget.daysOfWeekStyle.weekendStyle : widget.daysOfWeekStyle.weekdayStyle,
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildTableRow(List<DateTime> days) {
    return TableRow(
      decoration: widget.calendarStyle.contentDecoration,
      children: days.map((date) => _buildTableCell(date)).toList(),
    );
  }

  // TableCell will have equal width and height
  Widget _buildTableCell(DateTime date) {
    return LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: widget.rowHeight ?? constraints.maxWidth,
          minHeight: widget.rowHeight ?? constraints.maxWidth,
        ),
        child: _buildCell(date),
      ),
    );
  }

  Widget _buildCell(DateTime date) {
    if (!widget.calendarStyle.outsideDaysVisible &&
        widget.calendarController._isExtraDay(date) &&
        widget.calendarController.calendarFormat == CalendarFormat.month) {
      return Container();
    }

    Widget content = _buildCellContent(date);

    final eventKey = _getEventKey(date);
    final holidayKey = _getHolidayKey(date);
    final key = eventKey ?? holidayKey;

    if (key != null) {
      final children = <Widget>[content];
      final events = eventKey != null ? widget.calendarController.visibleEvents[eventKey] : [];
      final holidays = holidayKey != null ? widget.calendarController.visibleHolidays[holidayKey] : [];

      if (!_isDayUnavailable(date)) {
        if (widget.builders.markersBuilder != null) {
          children.addAll(
            widget.builders.markersBuilder(
              context,
              key,
              events,
              holidays,
            ),
          );
        } else {
          children.add(
            Positioned(
              top: widget.calendarStyle.markersPositionTop,
              bottom: widget.calendarStyle.markersPositionBottom,
              left: widget.calendarStyle.markersPositionLeft,
              right: widget.calendarStyle.markersPositionRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events
                    .take(widget.calendarStyle.markersMaxAmount)
                    .map((event) => _buildMarker(eventKey, event))
                    .toList(),
              ),
            ),
          );
        }
      }

      if (children.length > 1) {
        content = Stack(
          alignment: widget.calendarStyle.markersAlignment,
          children: children,
          overflow: widget.calendarStyle.canEventMarkersOverflow ? Overflow.visible : Overflow.clip,
        );
      }
    }

    return GestureDetector(
      behavior: widget.dayHitTestBehavior,
      onTap: () => _isDayUnavailable(date) ? _onUnavailableDaySelected() : _selectDay(date),
      onLongPress: () => _isDayUnavailable(date) ? _onUnavailableDayLongPressed() : _onDayLongPressed(date),
      child: content,
    );
  }

  Widget _buildCellContent(DateTime date) {
    final eventKey = _getEventKey(date);

    final tIsUnavailable = _isDayUnavailable(date);
    final tIsSelected = widget.calendarController.isSelected(date);
    final tIsToday = widget.calendarController.isToday(date);
    final tIsOutside = widget.calendarController._isExtraDay(date);
    final tIsHoliday = widget.calendarController.visibleHolidays.containsKey(_getHolidayKey(date));
    final tIsWeekend = widget.calendarController._isWeekend(date, widget.weekendDays);
    final tIsEventDay = widget.calendarController.visibleEvents.containsKey(eventKey);

    final isUnavailable = widget.builders.unavailableDayBuilder != null && tIsUnavailable;
    final isSelected = widget.builders.selectedDayBuilder != null && tIsSelected;
    final isToday = widget.builders.todayDayBuilder != null && tIsToday;
    final isOutsideHoliday = widget.builders.outsideHolidayDayBuilder != null && tIsOutside && tIsHoliday;
    final isHoliday = widget.builders.holidayDayBuilder != null && !tIsOutside && tIsHoliday;
    final isOutsideWeekend =
        widget.builders.outsideWeekendDayBuilder != null && tIsOutside && tIsWeekend && !tIsHoliday;
    final isOutside = widget.builders.outsideDayBuilder != null && tIsOutside && !tIsWeekend && !tIsHoliday;
    final isWeekend = widget.builders.weekendDayBuilder != null && !tIsOutside && tIsWeekend && !tIsHoliday;

    if (isUnavailable) {
      return widget.builders.unavailableDayBuilder(context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isSelected && widget.calendarStyle.renderSelectedFirst) {
      return widget.builders.selectedDayBuilder(context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isToday) {
      return widget.builders.todayDayBuilder(context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isSelected) {
      return widget.builders.selectedDayBuilder(context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isOutsideHoliday) {
      return widget.builders.outsideHolidayDayBuilder(context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isHoliday) {
      return widget.builders.holidayDayBuilder(context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isOutsideWeekend) {
      return widget.builders.outsideWeekendDayBuilder(context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isOutside) {
      return widget.builders.outsideDayBuilder(context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (isWeekend) {
      return widget.builders.weekendDayBuilder(context, date, widget.calendarController.visibleEvents[eventKey]);
    } else if (widget.builders.dayBuilder != null) {
      return widget.builders.dayBuilder(context, date, widget.calendarController.visibleEvents[eventKey]);
    } else {
      return _CellWidget(
        text: '${date.day}',
        isUnavailable: tIsUnavailable,
        isSelected: tIsSelected,
        isToday: tIsToday,
        isWeekend: tIsWeekend,
        isOutsideMonth: tIsOutside,
        isHoliday: tIsHoliday,
        isEventDay: tIsEventDay,
        calendarStyle: widget.calendarStyle,
      );
    }
  }

  Widget _buildMarker(DateTime date, dynamic event) {
    if (widget.builders.singleMarkerBuilder != null) {
      return widget.builders.singleMarkerBuilder(context, date, event);
    } else {
      return Container(
        width: widget.calendarStyle.makerSize,
        height: widget.calendarStyle.makerSize,
        margin: const EdgeInsets.symmetric(horizontal: 0.3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.calendarStyle.markersColor,
        ),
      );
    }
  }
}

/// CALENDAR CONTROLLER ////////////////////////////////////////////////////////////////////////

const double _dxMax = 1.2;
const double _dxMin = -1.2;

typedef void _SelectedDayCallback(DateTime day);
typedef void _MonthChangeCallback(DateTime day);

/// Controller required for `TableCalendar`.
///
/// Should be created in `initState()`, and then disposed in `dispose()`:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   _calendarController = CalendarController();
/// }
///
/// @override
/// void dispose() {
///   _calendarController.dispose();
///   super.dispose();
/// }
/// ```
class CalendarController {
  /// Currently focused day (used to determine which year/month should be visible).
  DateTime get focusedDay => _focusedDay;

  /// Currently selected day.
  DateTime get selectedDay => _selectedDay;

  /// Currently visible calendar format.
  CalendarFormat get calendarFormat => _calendarFormat.value;

  /// List of currently visible days.
  List<DateTime> get visibleDays => calendarFormat == CalendarFormat.month && !_includeInvisibleDays
      ? _visibleDays.value.where((day) => !_isExtraDay(day)).toList()
      : _visibleDays.value;

  /// `Map` of currently visible events.
  Map<DateTime, List> get visibleEvents {
    if (_events == null) {
      return {};
    }

    return Map.fromEntries(
      _events.entries.where((entry) {
        for (final day in visibleDays) {
          if (_isSameDay(day, entry.key)) {
            return true;
          }
        }

        return false;
      }),
    );
  }

  /// `Map` of currently visible holidays.
  Map<DateTime, List> get visibleHolidays {
    if (_holidays == null) {
      return {};
    }

    return Map.fromEntries(
      _holidays.entries.where((entry) {
        for (final day in visibleDays) {
          if (_isSameDay(day, entry.key)) {
            return true;
          }
        }

        return false;
      }),
    );
  }

  Map<DateTime, List> _events;
  Map<DateTime, List> _holidays;
  DateTime _focusedDay;
  DateTime _selectedDay;
  StartingDayOfWeek _startingDayOfWeek;
  ValueNotifier<CalendarFormat> _calendarFormat;
  ValueNotifier<List<DateTime>> _visibleDays;
  Map<CalendarFormat, String> _availableCalendarFormats;
  DateTime _previousFirstDay;
  DateTime _previousLastDay;
  int _pageId;
  double _dx;
  bool _useNextCalendarFormat;
  bool _includeInvisibleDays;
  _SelectedDayCallback _selectedDayCallback;
  _MonthChangeCallback _monthChangeCallback;

  void _init({
    @required Map<DateTime, List> events,
    @required Map<DateTime, List> holidays,
    @required DateTime initialDay,
    @required CalendarFormat initialFormat,
    @required Map<CalendarFormat, String> availableCalendarFormats,
    @required bool useNextCalendarFormat,
    @required StartingDayOfWeek startingDayOfWeek,
    @required _SelectedDayCallback selectedDayCallback,
    @required OnVisibleDaysChanged onVisibleDaysChanged,
    @required OnCalendarCreated onCalendarCreated,
    @required bool includeInvisibleDays,
    @required _MonthChangeCallback monthChangeCallback,
  }) {
    _events = events;
    _holidays = holidays;
    _availableCalendarFormats = availableCalendarFormats;
    _startingDayOfWeek = startingDayOfWeek;
    _useNextCalendarFormat = useNextCalendarFormat;
    _selectedDayCallback = selectedDayCallback;
    _includeInvisibleDays = includeInvisibleDays;
    _monthChangeCallback = monthChangeCallback;

    _pageId = 0;
    _dx = 0;

    final now = DateTime.now();
    _focusedDay = initialDay ?? _normalizeDate(now);
    _selectedDay = _focusedDay;
    _calendarFormat = ValueNotifier(initialFormat);
    _visibleDays = ValueNotifier(_getVisibleDays());
    _previousFirstDay = _visibleDays.value.first;
    _previousLastDay = _visibleDays.value.last;

    _calendarFormat.addListener(() {
      _visibleDays.value = _getVisibleDays();
    });

    if (onVisibleDaysChanged != null) {
      _visibleDays.addListener(() {
        if (!_isSameDay(_visibleDays.value.first, _previousFirstDay) ||
            !_isSameDay(_visibleDays.value.last, _previousLastDay)) {
          _previousFirstDay = _visibleDays.value.first;
          _previousLastDay = _visibleDays.value.last;
          onVisibleDaysChanged(
            _getFirstDay(includeInvisible: _includeInvisibleDays),
            _getLastDay(includeInvisible: _includeInvisibleDays),
            _calendarFormat.value,
          );
        }
      });
    }

    if (onCalendarCreated != null) {
      onCalendarCreated(
        _getFirstDay(includeInvisible: _includeInvisibleDays),
        _getLastDay(includeInvisible: _includeInvisibleDays),
        _calendarFormat.value,
      );
    }
  }

  /// Disposes the controller.
  /// ```dart
  /// @override
  /// void dispose() {
  ///   _calendarController.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    _calendarFormat?.dispose();
    _visibleDays?.dispose();
  }

  /// Toggles calendar format. Same as using `FormatButton`.
  void toggleCalendarFormat() {
    _calendarFormat.value = _nextFormat();
  }

  /// Sets calendar format by emulating swipe.
  void swipeCalendarFormat({@required bool isSwipeUp}) {
    assert(isSwipeUp != null);

    final formats = _availableCalendarFormats.keys.toList();
    int id = formats.indexOf(_calendarFormat.value);

    // Order of CalendarFormats must be from biggest to smallest,
    // eg.: [month, twoWeeks, week]
    if (isSwipeUp) {
      id = _clamp(0, formats.length - 1, id - 1);
    } else {
      id = _clamp(0, formats.length - 1, id + 1);
    }
    _calendarFormat.value = formats[id];
  }

  /// Sets calendar format to a given `value`.
  void setCalendarFormat(CalendarFormat value) {
    _calendarFormat.value = value;
  }

  /// Sets selected day to a given `value`.
  /// Use `runCallback: true` if this should trigger `OnDaySelected` callback.
  void setSelectedDay(
      DateTime value, {
        bool isProgrammatic = true,
        bool animate = true,
        bool runCallback = false,
      }) {
    final normalizedDate = _normalizeDate(value);

    if (animate) {
      if (normalizedDate.isBefore(_getFirstDay(includeInvisible: false))) {
        _decrementPage();
      } else if (normalizedDate.isAfter(_getLastDay(includeInvisible: false))) {
        _incrementPage();
      }
    }

    _selectedDay = normalizedDate;
    _focusedDay = normalizedDate;
    _updateVisibleDays(isProgrammatic);

    if (isProgrammatic && runCallback && _selectedDayCallback != null) {
      _selectedDayCallback(normalizedDate);
    }
  }

  /// Sets displayed month/year without changing the currently selected day.
  void setFocusedDay(DateTime value) {
    _focusedDay = _normalizeDate(value);
    _updateVisibleDays(true);
  }

  void _updateVisibleDays(bool isProgrammatic) {
    if (calendarFormat != CalendarFormat.twoWeeks || isProgrammatic) {
      _visibleDays.value = _getVisibleDays();
    }
  }

  CalendarFormat _nextFormat() {
    final formats = _availableCalendarFormats.keys.toList();
    int id = formats.indexOf(_calendarFormat.value);
    id = (id + 1) % formats.length;

    return formats[id];
  }

  String _getFormatButtonText() =>
      _useNextCalendarFormat ? _availableCalendarFormats[_nextFormat()] : _availableCalendarFormats[_calendarFormat.value];

  void _selectPrevious() {
    if (calendarFormat == CalendarFormat.month) {
      _selectPreviousMonth();
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      _selectPreviousTwoWeeks();
    } else {
      _selectPreviousWeek();
    }

    _visibleDays.value = _getVisibleDays();
    _decrementPage();
  }

  void _selectNext() {
    if (calendarFormat == CalendarFormat.month) {
      _selectNextMonth();
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      _selectNextTwoWeeks();
    } else {
      _selectNextWeek();
    }

    _visibleDays.value = _getVisibleDays();
    _incrementPage();
  }

  void _selectPreviousMonth() {
    _focusedDay = _previousMonth(_focusedDay);
    _monthChangeCallback(_focusedDay);
  }

  void _selectNextMonth() {
    _focusedDay = _nextMonth(_focusedDay);
    _monthChangeCallback(_focusedDay);
  }

  void _selectPreviousTwoWeeks() {
    if (_visibleDays.value.take(7).contains(_focusedDay)) {
      // in top row
      _focusedDay = _previousWeek(_focusedDay);
    } else {
      // in bottom row OR not visible
      _focusedDay = _previousWeek(_focusedDay.subtract(const Duration(days: 7)));
    }
  }

  void _selectNextTwoWeeks() {
    if (!_visibleDays.value.skip(7).contains(_focusedDay)) {
      // not in bottom row [eg: in top row OR not visible]
      _focusedDay = _nextWeek(_focusedDay);
    }
  }

  void _selectPreviousWeek() {
    _focusedDay = _previousWeek(_focusedDay);
  }

  void _selectNextWeek() {
    _focusedDay = _nextWeek(_focusedDay);
  }

  DateTime _getFirstDay({@required bool includeInvisible}) {
    if (_calendarFormat.value == CalendarFormat.month && !includeInvisible) {
      return _firstDayOfMonth(_focusedDay);
    } else {
      return _visibleDays.value.first;
    }
  }

  DateTime _getLastDay({@required bool includeInvisible}) {
    if (_calendarFormat.value == CalendarFormat.month && !includeInvisible) {
      return _lastDayOfMonth(_focusedDay);
    } else {
      return _visibleDays.value.last;
    }
  }

  List<DateTime> _getVisibleDays() {
    if (calendarFormat == CalendarFormat.month) {
      return _daysInMonth(_focusedDay);
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      return _daysInWeek(_focusedDay)
        ..addAll(_daysInWeek(
          _focusedDay.add(const Duration(days: 7)),
        ));
    } else {
      return _daysInWeek(_focusedDay);
    }
  }

  void _decrementPage() {
    _pageId--;
    _dx = _dxMin;
  }

  void _incrementPage() {
    _pageId++;
    _dx = _dxMax;
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final first = _firstDayOfMonth(month);
    final daysBefore = _getDaysBefore(first);
    final firstToDisplay = first.subtract(Duration(days: daysBefore));

    final last = _lastDayOfMonth(month);
    final daysAfter = _getDaysAfter(last);

    final lastToDisplay = last.add(Duration(days: daysAfter));
    return _daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  int _getDaysBefore(DateTime firstDay) {
    return (firstDay.weekday + 7 - _getWeekdayNumber(_startingDayOfWeek)) % 7;
  }

  int _getDaysAfter(DateTime lastDay) {
    int invertedStartingWeekday = 8 - _getWeekdayNumber(_startingDayOfWeek);

    int daysAfter = 7 - ((lastDay.weekday + invertedStartingWeekday) % 7) + 1;
    if (daysAfter == 8) {
      daysAfter = 1;
    }

    return daysAfter;
  }

  List<DateTime> _daysInWeek(DateTime week) {
    final first = _firstDayOfWeek(week);
    final last = _lastDayOfWeek(week);

    return _daysInRange(first, last).toList();
  }

  DateTime _firstDayOfWeek(DateTime day) {
    day = _normalizeDate(day);

    final decreaseNum = _getDaysBefore(day);
    return day.subtract(Duration(days: decreaseNum));
  }

  DateTime _lastDayOfWeek(DateTime day) {
    day = _normalizeDate(day);

    final increaseNum = _getDaysBefore(day);
    return day.add(Duration(days: 7 - increaseNum));
  }

  DateTime _firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month, 1, 12);
  }

  DateTime _lastDayOfMonth(DateTime month) {
    final date = month.month < 12 ? DateTime.utc(month.year, month.month + 1, 1, 12) : DateTime.utc(month.year + 1, 1, 1, 12);
    return date.subtract(const Duration(days: 1));
  }

  DateTime _previousWeek(DateTime week) {
    return week.subtract(const Duration(days: 7));
  }

  DateTime _nextWeek(DateTime week) {
    return week.add(const Duration(days: 7));
  }

  DateTime _previousMonth(DateTime month) {
    if (month.month == 1) {
      return DateTime(month.year - 1, 12);
    } else {
      return DateTime(month.year, month.month - 1);
    }
  }

  DateTime _nextMonth(DateTime month) {
    if (month.month == 12) {
      return DateTime(month.year + 1, 1);
    } else {
      return DateTime(month.year, month.month + 1);
    }
  }

  Iterable<DateTime> _daysInRange(DateTime firstDay, DateTime lastDay) sync* {
    var temp = firstDay;

    while (temp.isBefore(lastDay)) {
      yield _normalizeDate(temp);
      temp = temp.add(const Duration(days: 1));
    }
  }

  DateTime _normalizeDate(DateTime value) {
    return DateTime.utc(value.year, value.month, value.day, 12);
  }

  DateTime _getEventKey(DateTime day) {
    return visibleEvents.keys.firstWhere((it) => _isSameDay(it, day), orElse: () => null);
  }

  DateTime _getHolidayKey(DateTime day) {
    return visibleHolidays.keys.firstWhere((it) => _isSameDay(it, day), orElse: () => null);
  }

  /// Returns true if `day` is currently selected.
  bool isSelected(DateTime day) {
    return _isSameDay(day, selectedDay);
  }

  /// Returns true if `day` is the same day as `DateTime.now()`.
  bool isToday(DateTime day) {
    return _isSameDay(day, DateTime.now());
  }

  bool _isSameDay(DateTime dayA, DateTime dayB) {
    return dayA.year == dayB.year && dayA.month == dayB.month && dayA.day == dayB.day;
  }

  bool _isWeekend(DateTime day, List<int> weekendDays) {
    return weekendDays.contains(day.weekday);
  }

  bool _isExtraDay(DateTime day) {
    return _isExtraDayBefore(day) || _isExtraDayAfter(day);
  }

  bool _isExtraDayBefore(DateTime day) {
    return day.month < _focusedDay.month;
  }

  bool _isExtraDayAfter(DateTime day) {
    return day.month > _focusedDay.month;
  }

  int _clamp(int min, int max, int value) {
    if (value > max) {
      return max;
    } else if (value < min) {
      return min;
    } else {
      return value;
    }
  }
}

/// CALENDAR STYLE

class CalendarStyle {
  /// BoxDecoration for each interior row of the table
  final BoxDecoration contentDecoration;

  /// Style of foreground Text for regular weekdays.
  final TextStyle weekdayStyle;

  /// Style of foreground Text for regular weekends.
  final TextStyle weekendStyle;

  /// Style of foreground Text for holidays.
  final TextStyle holidayStyle;

  /// Style of foreground Text for selected day.
  final TextStyle selectedStyle;

  /// Style of foreground Text for today.
  final TextStyle todayStyle;

  /// Style of foreground Text for weekdays outside of current month.
  final TextStyle outsideStyle;

  /// Style of foreground Text for weekends outside of current month.
  final TextStyle outsideWeekendStyle;

  /// Style of foreground Text for holidays outside of current month.
  final TextStyle outsideHolidayStyle;

  /// Style of foreground Text for days outside of `startDay` - `endDay` Date range.
  final TextStyle unavailableStyle;

  /// Style of foreground Text for days that contain events.
  final TextStyle eventDayStyle;

  /// Background Color of selected day.
  final Color selectedColor;

  /// Background Color of today.
  final Color todayColor;

  /// Color of event markers placed on the bottom of every day containing events.
  final Color markersColor;

  /// bottom color
  final Color bottomColor;

  /// General `Alignment` for event markers.
  /// NOTE: `markersPositionBottom` defaults to `5.0`, so you might want to set it to `null` when using `markersAlignment`.
  final Alignment markersAlignment;

  /// `top` property of `Positioned` widget used for event markers.
  final double markersPositionTop;

  /// `bottom` property of `Positioned` widget used for event markers.
  /// NOTE: This defaults to `5.0`, so you might occasionally want to set it to `null`.
  final double markersPositionBottom;

  /// `left` property of `Positioned` widget used for event markers.
  final double markersPositionLeft;

  /// `right` property of `Positioned` widget used for event markers.
  final double markersPositionRight;

  /// Maximum amount of event markers to be displayed.
  final int markersMaxAmount;

  /// Specifies whether or not days outside of current month should be displayed.
  ///
  /// Sometimes a fragment of previous month's last week (or next month's first week) appears in current month's view.
  /// This property defines if those should be visible (eg. with custom style) or hidden.
  final bool outsideDaysVisible;

  /// Determines rendering priority for SelectedDay and Today.
  /// * `true` - SelectedDay will have higher priority than Today
  /// * `false` - Today will have higher priority than SelectedDay
  final bool renderSelectedFirst;

  /// Determines whether the row of days of the week should be rendered or not.
  final bool renderDaysOfWeek;

  /// Padding of `TableCalendar`'s content.
  final EdgeInsets contentPadding;

  /// Margin of Cells' decoration.
  final EdgeInsets cellMargin;

  /// Specifies if event markers rendered for a day cell can overflow cell's boundaries.
  /// * `true` - Event markers will be drawn over the cell boundaries
  /// * `false` - Event markers will not be drawn over the cell boundaries and will be clipped if they are too big
  final bool canEventMarkersOverflow;

  /// Specifies whether or not SelectedDay should be highlighted.
  final bool highlightSelected;

  /// Specifies whether or not Today should be highlighted.
  final bool highlightToday;

  /// maker size
  final double makerSize;

  final bool selectedDayBoxShapeCircle;

  const CalendarStyle({
    this.contentDecoration = const BoxDecoration(),
    this.weekdayStyle = const TextStyle(),
    this.weekendStyle = const TextStyle(color: const Color(0xFFF44336)), // Material red[500]
    this.holidayStyle = const TextStyle(color: const Color(0xFFF44336)), // Material red[500]
    this.selectedStyle = const TextStyle(color: const Color(0xFFFAFAFA), fontSize: 16.0), // Material grey[50]
    this.todayStyle = const TextStyle(color: const Color(0xFFFAFAFA), fontSize: 16.0), // Material grey[50]
    this.outsideStyle = const TextStyle(color: const Color(0xFF9E9E9E)), // Material grey[500]
    this.outsideWeekendStyle = const TextStyle(color: const Color(0xFFEF9A9A)), // Material red[200]
    this.outsideHolidayStyle = const TextStyle(color: const Color(0xFFEF9A9A)), // Material red[200]
    this.unavailableStyle = const TextStyle(color: const Color(0xFFBFBFBF)),
    this.eventDayStyle = const TextStyle(),
    this.selectedColor = const Color(0xFF5C6BC0), // Material indigo[400]
    this.todayColor = const Color(0xFF9FA8DA), // Material indigo[200]
    this.markersColor = const Color(0xFF263238),
    this.bottomColor = const Color.fromRGBO(218, 222, 240, 1),// Material blueGrey[900]
    this.markersAlignment = Alignment.bottomCenter,
    this.markersPositionTop,
    this.markersPositionBottom = 5.0,
    this.markersPositionLeft,
    this.markersPositionRight,
    this.markersMaxAmount = 4,
    this.outsideDaysVisible = true,
    this.renderSelectedFirst = true,
    this.renderDaysOfWeek = true,
    this.contentPadding = const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
    this.cellMargin = const EdgeInsets.all(6.0),
    this.canEventMarkersOverflow = false,
    this.highlightSelected = true,
    this.highlightToday = true,
    this.makerSize = 8.0,
    this.selectedDayBoxShapeCircle = false,
  });
}

/// Class containing styling for `TableCalendar`'s days of week panel.
class DaysOfWeekStyle {
  /// Use to customize days of week panel text (eg. with different `DateFormat`).
  /// You can use `String` transformations to further customize the text.
  /// Defaults to simple `'E'` format (eg. Mon, Tue, Wed, etc.).
  ///
  /// Example usage:
  /// ```dart
  /// dowTextBuilder: (date, locale) => DateFormat.E(locale).format(date)[0],
  /// ```
  final TextBuilder dowTextBuilder;

  /// BoxDecoration for the top row of the table
  final BoxDecoration decoration;

  /// Style for weekdays on the top of Calendar.
  final TextStyle weekdayStyle;

  /// Style for weekend days on the top of Calendar.
  final TextStyle weekendStyle;
  final bool isUpperCase;

  const DaysOfWeekStyle({
    this.dowTextBuilder,
    this.decoration = const BoxDecoration(),
    this.weekdayStyle = const TextStyle(color: const Color(0xFF616161)), // Material grey[700]
    this.weekendStyle = const TextStyle(color: const Color(0xFFF44336)),
    this.isUpperCase = false,// Material red[500]
  });
}

/// Main Builder signature for `TableCalendar`. Contains `date` and list of all `events` associated with that `date`.
/// Note that most of the time, `events` param will be ommited, however it is there if needed.
/// `events` param can be null.
typedef FullBuilder = Widget Function(BuildContext context, DateTime date, List events);

/// Builder signature for a list of event markers. Contains `date` and list of all `events` associated with that `date`.
/// Both `events` and `holidays` params can be null.
typedef FullListBuilder = List<Widget> Function(BuildContext context, DateTime date, List events, List holidays);

/// Builder signature for weekday names row. Contains `weekday` string, which is formatted by `dowTextBuilder`
/// or by default function (DateFormat.E(widget.locale).format(date)), if `dowTextBuilder` is null.
typedef DowBuilder = Widget Function(BuildContext context, String weekday);

/// Builder signature for a single event marker. Contains `date` and a single `event` associated with that `date`.
typedef SingleMarkerBuilder = Widget Function(BuildContext context, DateTime date, dynamic event);

/// Class containing all custom Builders for `TableCalendar`.
class CalendarBuilders {
  /// The most general custom Builder. Use to provide your own UI for every day cell.
  /// If `dayBuilder` is not specified, a default day cell will be displayed.
  /// Default day cells are customizable with `CalendarStyle`.
  final FullBuilder dayBuilder;

  /// Custom Builder for currently selected day. Will overwrite `dayBuilder` on selected day.
  final FullBuilder selectedDayBuilder;

  /// Custom Builder for today. Will overwrite `dayBuilder` on today.
  final FullBuilder todayDayBuilder;

  /// Custom Builder for holidays. Will overwrite `dayBuilder` on holidays.
  final FullBuilder holidayDayBuilder;

  /// Custom Builder for weekends. Will overwrite `dayBuilder` on weekends.
  final FullBuilder weekendDayBuilder;

  /// Custom Builder for days outside of current month. Will overwrite `dayBuilder` on days outside of current month.
  final FullBuilder outsideDayBuilder;

  /// Custom Builder for weekends outside of current month. Will overwrite `dayBuilder`on weekends outside of current month.
  final FullBuilder outsideWeekendDayBuilder;

  /// Custom Builder for holidays outside of current month. Will overwrite `dayBuilder` on holidays outside of current month.
  final FullBuilder outsideHolidayDayBuilder;

  /// Custom Builder for days outside of `startDay` - `endDay` Date range. Will overwrite `dayBuilder` for aforementioned days.
  final FullBuilder unavailableDayBuilder;

  /// Custom Builder for a whole group of event markers. Use to provide your own marker UI for each day cell.
  /// Every `Widget` passed here will be placed in a `Stack`, above the cell content.
  /// Wrap them with `Positioned` to gain more control over their placement.
  ///
  /// If `markersBuilder` is not specified, `TableCalendar` will try to use `singleMarkerBuilder` or default markers (customizable with `CalendarStyle`).
  /// Mutually exclusive with `singleMarkerBuilder`.
  final FullListBuilder markersBuilder;

  /// Custom Builder for a single event marker. Each of those will be displayed in a `Row` above of the day cell.
  /// You can adjust markers' position with `CalendarStyle` properties.
  ///
  /// If `singleMarkerBuilder` is not specified, a default event marker will be displayed (customizable with `CalendarStyle`).
  /// Mutually exclusive with `markersBuilder`.
  final SingleMarkerBuilder singleMarkerBuilder;

  /// Custom builder for dow weekday names (displayed between `HeaderRow` and calendar days).
  /// Will overwrite `weekdayStyle` and `weekendStyle` from `DaysOfWeekStyle`.
  final DowBuilder dowWeekdayBuilder;

  /// Custom builder for dow weekend names (displayed between `HeaderRow` and calendar days).
  /// Will overwrite `weekendStyle` from `DaysOfWeekStyle` and `dowWeekdayBuilder` for weekends, if it also exists.
  final DowBuilder dowWeekendBuilder;

  const CalendarBuilders({
    this.dayBuilder,
    this.selectedDayBuilder,
    this.todayDayBuilder,
    this.holidayDayBuilder,
    this.weekendDayBuilder,
    this.outsideDayBuilder,
    this.outsideWeekendDayBuilder,
    this.outsideHolidayDayBuilder,
    this.unavailableDayBuilder,
    this.markersBuilder,
    this.singleMarkerBuilder,
    this.dowWeekdayBuilder,
    this.dowWeekendBuilder,
  }) : assert(!(singleMarkerBuilder != null && markersBuilder != null));
}

/// Class containing styling and configuration of `TableCalendar`'s header.
class HeaderStyle {
  /// Responsible for making title Text centered.
  final bool centerHeaderTitle;

  /// Responsible for FormatButton visibility.
  final bool formatButtonVisible;

  /// Controls the text inside FormatButton.
  /// * `true` - the button will show next CalendarFormat
  /// * `false` - the button will show current CalendarFormat
  final bool formatButtonShowsNext;

  /// Use to customize header's title text (eg. with different `DateFormat`).
  /// You can use `String` transformations to further customize the text.
  /// Defaults to simple `'yMMMM'` format (eg. January 2019, February 2019, March 2019, etc.).
  ///
  /// Example usage:
  /// ```dart
  /// titleTextBuilder: (date, locale) => DateFormat.yM(locale).format(date),
  /// ```
  final TextBuilder titleTextBuilder;

  /// Style for title Text (month-year) displayed in header.
  final TextStyle titleTextStyle;

  /// Style for FormatButton `Text`.
  final TextStyle formatButtonTextStyle;

  /// Background `Decoration` for FormatButton.
  final Decoration formatButtonDecoration;

  /// Inside padding of the whole header.
  final EdgeInsets headerPadding;

  /// Outside margin of the whole header.
  final EdgeInsets headerMargin;

  /// Inside padding for FormatButton.
  final EdgeInsets formatButtonPadding;

  /// Inside padding for left chevron.
  final EdgeInsets leftChevronPadding;

  /// Inside padding for right chevron.
  final EdgeInsets rightChevronPadding;

  /// Outside margin for left chevron.
  final EdgeInsets leftChevronMargin;

  /// Outside margin for right chevron.
  final EdgeInsets rightChevronMargin;

  /// Icon used for left chevron.
  /// Defaults to black `Icons.chevron_left`.
  final Widget leftChevronIcon;

  /// Icon used for right chevron.
  /// Defaults to black `Icons.chevron_right`.
  final Widget rightChevronIcon;

  /// Show or hide chevrons.
  /// Defaults to `true`.
  final bool showLeftChevron;
  final bool showRightChevron;

  /// Header decoration, used to draw border or shadow or change color of the header
  /// Defaults to empty BoxDecoration.
  final BoxDecoration decoration;

  const HeaderStyle({
    this.centerHeaderTitle = false,
    this.formatButtonVisible = true,
    this.formatButtonShowsNext = true,
    this.titleTextBuilder,
    this.titleTextStyle = const TextStyle(fontSize: 17.0),
    this.formatButtonTextStyle = const TextStyle(),
    this.formatButtonDecoration = const BoxDecoration(
      border: const Border(top: BorderSide(), bottom: BorderSide(), left: BorderSide(), right: BorderSide()),
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
    ),
    this.headerMargin,
    this.headerPadding = const EdgeInsets.symmetric(vertical: 8.0),
    this.formatButtonPadding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
    this.leftChevronPadding = const EdgeInsets.all(12.0),
    this.rightChevronPadding = const EdgeInsets.all(12.0),
    this.leftChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.rightChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.leftChevronIcon = const Icon(Icons.chevron_left),
    this.rightChevronIcon = const Icon(Icons.chevron_right),
    this.showLeftChevron = true,
    this.showRightChevron = true,
    this.decoration = const BoxDecoration(),
  });
}

/// CELL WIDGET ///////////////////////////////////////////////////////////////////////////////////

class _CellWidget extends StatelessWidget {
  final String text;
  final bool isUnavailable;
  final bool isSelected;
  final bool isToday;
  final bool isWeekend;
  final bool isOutsideMonth;
  final bool isHoliday;
  final bool isEventDay;
  final CalendarStyle calendarStyle;

  const _CellWidget({
    Key key,
    @required this.text,
    this.isUnavailable = false,
    this.isSelected = false,
    this.isToday = false,
    this.isWeekend = false,
    this.isOutsideMonth = false,
    this.isHoliday = false,
    this.isEventDay = false,
    @required this.calendarStyle,
  })  : assert(text != null),
        assert(calendarStyle != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: calendarStyle.cellMargin,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: _buildCellDecoration(),
              margin: EdgeInsets.all(4),
              alignment: Alignment.center,
            ),
          ),
          Center(
            child: Text(
              text,
              style: _buildCellTextStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Decoration _buildCellDecoration() {
    if (isSelected &&
        calendarStyle.renderSelectedFirst &&
        calendarStyle.highlightSelected) {
      return BoxDecoration(
          shape: calendarStyle.selectedDayBoxShapeCircle
              ? BoxShape.circle
              : BoxShape.rectangle,
          color: calendarStyle.selectedColor,
          borderRadius: calendarStyle.selectedDayBoxShapeCircle
              ? null
              : BorderRadius.all(Radius.circular(11)));
    } else if (isToday && calendarStyle.highlightToday) {
      return BoxDecoration(
          shape: calendarStyle.selectedDayBoxShapeCircle
              ? BoxShape.circle
              : BoxShape.rectangle,
          color: calendarStyle.todayColor,
          borderRadius: calendarStyle.selectedDayBoxShapeCircle
              ? null
              : BorderRadius.all(Radius.circular(11)));
    } else if (isSelected && calendarStyle.highlightSelected) {
      return BoxDecoration(
          shape: calendarStyle.selectedDayBoxShapeCircle
              ? BoxShape.circle
              : BoxShape.rectangle,
          color: calendarStyle.selectedColor,
          borderRadius: calendarStyle.selectedDayBoxShapeCircle
              ? null
              : BorderRadius.all(Radius.circular(11)));
    } else {
      return BoxDecoration(shape: BoxShape.circle);
    }
  }

  TextStyle _buildCellTextStyle() {
    if (isUnavailable) {
      return calendarStyle.unavailableStyle;
    } else if (isSelected && calendarStyle.renderSelectedFirst && calendarStyle.highlightSelected) {
      return calendarStyle.selectedStyle;
    } else if (isToday && calendarStyle.highlightToday) {
      return calendarStyle.todayStyle;
    } else if (isSelected && calendarStyle.highlightSelected) {
      return calendarStyle.selectedStyle;
    } else if (isOutsideMonth && isHoliday) {
      return calendarStyle.outsideHolidayStyle;
    } else if (isHoliday) {
      return calendarStyle.holidayStyle;
    } else if (isOutsideMonth && isWeekend) {
      return calendarStyle.outsideWeekendStyle;
    } else if (isOutsideMonth) {
      return calendarStyle.outsideStyle;
    } else if (isWeekend) {
      return calendarStyle.weekendStyle;
    } else if (isEventDay) {
      return calendarStyle.eventDayStyle;
    } else {
      return calendarStyle.weekdayStyle;
    }
  }
}

/// CUSTOM ICON ////////////////////////////////////////////////////////////////////////////

class _CustomIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final EdgeInsets margin;
  final EdgeInsets padding;

  const _CustomIconButton({
    Key key,
    @required this.icon,
    @required this.onTap,
    this.margin,
    this.padding,
  })  : assert(icon != null),
        assert(onTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100.0),
        child: Padding(
          padding: padding,
          child: icon,
        ),
      ),
    );
  }
}

/// SIMPLE GESTURE DETECTOR //////////////////////////////////////////////////////////

/// Callback signature for swipe gesture.
typedef void SwipeCallback(SwipeDirection direction);

/// Possible directions of swipe gesture.
enum SwipeDirection { left, right, up, down }

/// Easy to use, reliable gesture detection Widget. Exposes simple API for basic gestures.
class SimpleGestureDetector extends StatefulWidget {
  /// Widget to be augmented with gesture detection.
  final Widget child;

  /// Configuration for swipe gesture.
  final SimpleSwipeConfig swipeConfig;

  /// Behavior used for hit testing. Set to `HitTestBehavior.deferToChild` by default.
  final HitTestBehavior behavior;

  /// Callback to be run when Widget is swiped vertically. Provides `SwipeDirection`.
  final SwipeCallback onVerticalSwipe;

  /// Callback to be run when Widget is swiped horizontally. Provides `SwipeDirection`.
  final SwipeCallback onHorizontalSwipe;

  /// Callback to be run when Widget is tapped;
  final VoidCallback onTap;

  /// Callback to be run when Widget is double-tapped;
  final VoidCallback onDoubleTap;

  /// Callback to be run when Widget is long-pressed;
  final VoidCallback onLongPress;

  const SimpleGestureDetector({
    Key key,
    @required this.child,
    this.swipeConfig = const SimpleSwipeConfig(),
    this.behavior = HitTestBehavior.deferToChild,
    this.onVerticalSwipe,
    this.onHorizontalSwipe,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  })  : assert(child != null),
        assert(swipeConfig != null),
        super(key: key);

  @override
  _SimpleGestureDetectorState createState() => _SimpleGestureDetectorState();
}

class _SimpleGestureDetectorState extends State<SimpleGestureDetector> {
  Offset _initialSwipeOffset;
  Offset _finalSwipeOffset;
  SwipeDirection _previousDirection;

  void _onVerticalDragStart(DragStartDetails details) {
    _initialSwipeOffset = details.globalPosition;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _finalSwipeOffset = details.globalPosition;

    if (widget.swipeConfig.swipeDetectionBehavior == SwipeDetectionBehavior.singularOnEnd) {
      return;
    }

    if (_initialSwipeOffset != null) {
      final offsetDifference = _initialSwipeOffset.dy - _finalSwipeOffset.dy;

      if (offsetDifference.abs() > widget.swipeConfig.verticalThreshold) {
        _initialSwipeOffset =
        widget.swipeConfig.swipeDetectionBehavior == SwipeDetectionBehavior.singular ? null : _finalSwipeOffset;

        final direction = offsetDifference > 0 ? SwipeDirection.up : SwipeDirection.down;

        if (widget.swipeConfig.swipeDetectionBehavior == SwipeDetectionBehavior.continuous ||
            _previousDirection == null ||
            direction != _previousDirection) {
          _previousDirection = direction;
          widget.onVerticalSwipe(direction);
        }
      }
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (widget.swipeConfig.swipeDetectionBehavior == SwipeDetectionBehavior.singularOnEnd) {
      if (_initialSwipeOffset != null) {
        final offsetDifference = _initialSwipeOffset.dy - _finalSwipeOffset.dy;

        if (offsetDifference.abs() > widget.swipeConfig.verticalThreshold) {
          final direction = offsetDifference > 0 ? SwipeDirection.up : SwipeDirection.down;
          widget.onVerticalSwipe(direction);
        }
      }
    }

    _initialSwipeOffset = null;
    _previousDirection = null;
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _initialSwipeOffset = details.globalPosition;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _finalSwipeOffset = details.globalPosition;

    if (widget.swipeConfig.swipeDetectionBehavior == SwipeDetectionBehavior.singularOnEnd) {
      return;
    }

    if (_initialSwipeOffset != null) {
      final offsetDifference = _initialSwipeOffset.dx - _finalSwipeOffset.dx;

      if (offsetDifference.abs() > widget.swipeConfig.horizontalThreshold) {
        _initialSwipeOffset =
        widget.swipeConfig.swipeDetectionBehavior == SwipeDetectionBehavior.singular ? null : _finalSwipeOffset;

        final direction = offsetDifference > 0 ? SwipeDirection.left : SwipeDirection.right;

        if (widget.swipeConfig.swipeDetectionBehavior == SwipeDetectionBehavior.continuous ||
            _previousDirection == null ||
            direction != _previousDirection) {
          _previousDirection = direction;
          widget.onHorizontalSwipe(direction);
        }
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.swipeConfig.swipeDetectionBehavior == SwipeDetectionBehavior.singularOnEnd) {
      if (_initialSwipeOffset != null) {
        final offsetDifference = _initialSwipeOffset.dx - _finalSwipeOffset.dx;

        if (offsetDifference.abs() > widget.swipeConfig.horizontalThreshold) {
          final direction = offsetDifference > 0 ? SwipeDirection.left : SwipeDirection.right;
          widget.onHorizontalSwipe(direction);
        }
      }
    }

    _initialSwipeOffset = null;
    _previousDirection = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      child: widget.child,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
      onVerticalDragStart: widget.onVerticalSwipe != null ? _onVerticalDragStart : null,
      onVerticalDragUpdate: widget.onVerticalSwipe != null ? _onVerticalDragUpdate : null,
      onVerticalDragEnd: widget.onVerticalSwipe != null ? _onVerticalDragEnd : null,
      onHorizontalDragStart: widget.onHorizontalSwipe != null ? _onHorizontalDragStart : null,
      onHorizontalDragUpdate: widget.onHorizontalSwipe != null ? _onHorizontalDragUpdate : null,
      onHorizontalDragEnd: widget.onHorizontalSwipe != null ? _onHorizontalDragEnd : null,
    );
  }
}

/// Behaviors describing swipe gesture detection.
enum SwipeDetectionBehavior {
  singular,
  singularOnEnd,
  continuous,
  continuousDistinct,
}

/// Configuration class for swipe gesture.
class SimpleSwipeConfig {
  /// Amount of offset after which vertical swipes get detected.
  final double verticalThreshold;

  /// Amount of offset after which horizontal swipes get detected.
  final double horizontalThreshold;

  /// Behavior used for swipe gesture detection.
  /// By default, `SwipeDetectionBehavior.singularOnEnd` is used, which runs callback after swipe is completed.
  /// Use `SwipeDetectionBehavior.continuous` for most reactive behavior but be careful with threshold values.
  ///
  /// * `SwipeDetectionBehavior.singular` - Runs callback a single time - when swipe movement is above set threshold.
  /// * `SwipeDetectionBehavior.singularOnEnd` - Runs callback a single time - when swipe is fully completed.
  /// * `SwipeDetectionBehavior.continuous` - Runs callback multiple times - whenever swipe movement is above set threshold. Make sure to set threshold values higher than usual!
  /// * `SwipeDetectionBehavior.continuousDistinct` - Runs callback multiple times - whenever swipe movement is above set threshold, but only on distinct `SwipeDirection`.
  final SwipeDetectionBehavior swipeDetectionBehavior;

  const SimpleSwipeConfig({
    this.verticalThreshold = 50.0,
    this.horizontalThreshold = 50.0,
    this.swipeDetectionBehavior = SwipeDetectionBehavior.singularOnEnd,
  })  : assert(verticalThreshold != null),
        assert(horizontalThreshold != null),
        assert(swipeDetectionBehavior != null);
}







