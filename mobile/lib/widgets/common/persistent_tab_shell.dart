import 'package:flutter/material.dart';

/// Shares a tab-selection callback with the bottom navigation widgets inside
/// the persistent shell. Detail pages pushed on the root Navigator stay
/// independent of this scope and keep their existing navigation behavior.
class PersistentTabScope extends InheritedWidget {
  const PersistentTabScope({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required super.child,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static PersistentTabScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PersistentTabScope>();

  @override
  bool updateShouldNotify(PersistentTabScope oldWidget) =>
      currentIndex != oldWidget.currentIndex || onSelect != oldWidget.onSelect;
}

/// Keeps each top-level tab mounted after its first visit, preserving scroll
/// positions, form state and already-loaded data when users switch tabs.
/// Pages are created lazily so all tab APIs are not requested at startup.
class PersistentTabShell extends StatefulWidget {
  const PersistentTabShell({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.transitionDuration = const Duration(milliseconds: 180),
  });

  final List<WidgetBuilder> tabs;
  final int initialIndex;
  final Duration transitionDuration;

  @override
  State<PersistentTabShell> createState() => _PersistentTabShellState();
}

class _PersistentTabShellState extends State<PersistentTabShell> {
  late int _currentIndex;
  late List<bool> _loaded;

  @override
  void initState() {
    super.initState();
    assert(widget.tabs.isNotEmpty, 'PersistentTabShell requires at least one tab.');
    assert(
      widget.initialIndex >= 0 && widget.initialIndex < widget.tabs.length,
      'initialIndex must reference an existing tab.',
    );
    _currentIndex = widget.initialIndex;
    _loaded = List<bool>.generate(
      widget.tabs.length,
      (index) => index == _currentIndex,
    );
  }

  @override
  void didUpdateWidget(covariant PersistentTabShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      // Tab counts are expected to remain stable for a role shell. Reset
      // safely if a future role configuration changes the number of tabs.
      _currentIndex = widget.initialIndex.clamp(0, widget.tabs.length - 1).toInt();
      _loaded = List<bool>.generate(
        widget.tabs.length,
        (index) => index == _currentIndex,
      );
    }
  }

  void _selectTab(int index) {
    if (index < 0 || index >= widget.tabs.length || index == _currentIndex) {
      return;
    }
    setState(() {
      _currentIndex = index;
      _loaded[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabScope(
      currentIndex: _currentIndex,
      onSelect: _selectTab,
      child: Stack(
        fit: StackFit.expand,
        children: List<Widget>.generate(widget.tabs.length, (index) {
          final isActive = index == _currentIndex;
          return Positioned.fill(
            child: Offstage(
              offstage: !isActive,
              child: IgnorePointer(
                ignoring: !isActive,
                child: ExcludeSemantics(
                  excluding: !isActive,
                  child: TickerMode(
                    enabled: isActive,
                    child: AnimatedOpacity(
                      key: ValueKey<int>(index),
                      opacity: isActive ? 1 : 0,
                      duration: widget.transitionDuration,
                      curve: Curves.easeOutCubic,
                      child: _loaded[index]
                          ? Builder(builder: widget.tabs[index])
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
