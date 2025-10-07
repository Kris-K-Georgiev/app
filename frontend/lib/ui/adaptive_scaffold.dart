import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Simple adaptive navigation scaffold switching between:
/// - BottomNavigationBar (phones)
/// - NavigationRail (medium / large tablet)
/// - Sidebar (wide desktop)
class AdaptiveNavItem {
  final Widget Function(bool selected, ColorScheme scheme) iconBuilder;
  final String label;
  const AdaptiveNavItem({required this.iconBuilder, required this.label});
}

class AdaptiveScaffold extends StatelessWidget {
  final int index;
  final ValueChanged<int> onIndexChanged;
  final List<AdaptiveNavItem> items;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  const AdaptiveScaffold({super.key, required this.index, required this.onIndexChanged, required this.items, required this.body, this.appBar, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final navType = navTypeForWidth(width);
    final scheme = Theme.of(context).colorScheme;

    if (navType == NavType.bottom) {
      return Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
            onDestinationSelected: onIndexChanged,
            indicatorColor: Colors.transparent, // remove filled background
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: [
              for (int i = 0; i < items.length; i++)
                NavigationDestination(
                  icon: items[i].iconBuilder(index == i, scheme),
                  label: items[i].label,
                )
            ]),
      );
    }

    if (navType == NavType.rail) {
      return Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            NavigationRail(
              indicatorColor: Colors.transparent,
              selectedIndex: index,
              onDestinationSelected: onIndexChanged,
              labelType: NavigationRailLabelType.none,
              destinations: [
                for (int i = 0; i < items.length; i++)
                  NavigationRailDestination(
                    icon: items[i].iconBuilder(index == i, scheme),
                    label: Text(items[i].label),
                  )
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body)
          ],
        ),
      );
    }

    // Sidebar
    return Scaffold(
      appBar: appBar, // can be null on very wide desktop if desired
      floatingActionButton: floatingActionButton,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withOpacity(.4))),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Text('БХСС', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  for (int i = 0; i < items.length; i++)
                    _SidebarTile(
                      selected: index == i,
                      label: items[i].label,
                      icon: items[i].iconBuilder(index == i, scheme),
                      onTap: () => onIndexChanged(i),
                    ),
                ],
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final bool selected;
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  const _SidebarTile({required this.selected, required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: selected ? scheme.primary.withOpacity(.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: icon,
            ),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? scheme.primary : scheme.onSurface,
            )),
          ],
        ),
      ),
    );
  }
}
