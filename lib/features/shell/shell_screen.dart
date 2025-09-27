// C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\shell\shell_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellScreen extends StatefulWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  static const Map<String, int> _routeMap = {
    '/': 0,
    '/personal': 1,
    '/experience': 2,
    '/education': 3,
    '/skills': 4,
    '/languages': 5,
    '/analyzer': 6,
    '/settings': 7,
    '/about': 8,
    '/support': 9,
    '/legal': 10,
  };

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    return _routeMap[location] ?? 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final String? route = _routeMap.entries.firstWhere((entry) => entry.value == index, orElse: () => _routeMap.entries.first).key;
    if (route != null) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isDesktop = MediaQuery.of(context).size.width > 700;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              final isExtended = constraints.maxWidth > 200;

              // ====================== SOLUÇÃO FINAL E ROBUSTA ======================
              return Container(
                width: isExtended ? 256 : 80,
                color: Theme.of(context).colorScheme.surface.withAlpha(10),
                child: SingleChildScrollView( // Permite rolagem se a altura for pequena
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildNavItem(context, icon: Icons.dashboard_outlined, label: 'Dashboard', index: 0, selectedIndex: selectedIndex, isExtended: isExtended),
                          _buildNavItem(context, icon: Icons.person_outline, label: 'Dados Pessoais', index: 1, selectedIndex: selectedIndex, isExtended: isExtended),
                          _buildNavItem(context, icon: Icons.work_outline, label: 'Experiências', index: 2, selectedIndex: selectedIndex, isExtended: isExtended),
                          _buildNavItem(context, icon: Icons.school_outlined, label: 'Educação', index: 3, selectedIndex: selectedIndex, isExtended: isExtended),
                          _buildNavItem(context, icon: Icons.lightbulb_outline, label: 'Habilidades', index: 4, selectedIndex: selectedIndex, isExtended: isExtended),
                          _buildNavItem(context, icon: Icons.language_outlined, label: 'Idiomas', index: 5, selectedIndex: selectedIndex, isExtended: isExtended),
                          const Divider(height: 24, indent: 16, endIndent: 16),
                          _buildNavItem(context, icon: Icons.science_outlined, label: 'Análise (IA)', index: 6, selectedIndex: selectedIndex, isExtended: isExtended),
                          const Spacer(), // Empurra os itens de baixo para o rodapé
                          const Divider(height: 24, indent: 16, endIndent: 16),
                          _buildNavItem(context, icon: Icons.settings_outlined, label: 'Configurações', index: 7, selectedIndex: selectedIndex, isExtended: isExtended),
                          _buildNavItem(context, icon: Icons.info_outline, label: 'Sobre', index: 8, selectedIndex: selectedIndex, isExtended: isExtended),
                          _buildNavItem(context, icon: Icons.favorite_border, label: 'Apoie o Projeto', index: 9, selectedIndex: selectedIndex, isExtended: isExtended),
                          _buildNavItem(context, icon: Icons.gavel_outlined, label: 'Legal / LGPD', index: 10, selectedIndex: selectedIndex, isExtended: isExtended),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              // ======================== FIM DA CORREÇÃO =========================
            }),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    // Layout Mobile (inalterado)
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex > 4 ? 4 : selectedIndex,
        onDestinationSelected: (index) {
          if(index == 4) {
            // Lógica para abrir um menu 'Mais' no mobile
            _showMoreMenu(context);
          } else {
            _onItemTapped(index, context);
          }
        },
        destinations: const [
          NavigationDestination(label: 'Dashboard', icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard)),
          NavigationDestination(label: 'Pessoais', icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person)),
          NavigationDestination(label: 'Experiência', icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work)),
          NavigationDestination(label: 'Educação', icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school)),
          NavigationDestination(label: 'Mais', icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz)),
        ],
      ),
    );
  }

  // Menu "Mais" para a versão mobile
  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(context: context, builder: (ctx) {
      return ListView(
        shrinkWrap: true,
        children: [
          ListTile(leading: const Icon(Icons.lightbulb_outline), title: const Text('Habilidades'), onTap: () { context.go('/skills'); Navigator.pop(ctx); }),
          ListTile(leading: const Icon(Icons.language_outlined), title: const Text('Idiomas'), onTap: () { context.go('/languages'); Navigator.pop(ctx); }),
          ListTile(leading: const Icon(Icons.science_outlined), title: const Text('Análise (IA)'), onTap: () { context.go('/analyzer'); Navigator.pop(ctx); }),
          const Divider(),
          ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Configurações'), onTap: () { context.go('/settings'); Navigator.pop(ctx); }),
          ListTile(leading: const Icon(Icons.info_outline), title: const Text('Sobre'), onTap: () { context.go('/about'); Navigator.pop(ctx); }),
          ListTile(leading: const Icon(Icons.favorite_border), title: const Text('Apoie o Projeto'), onTap: () { context.go('/support'); Navigator.pop(ctx); }),
          ListTile(leading: const Icon(Icons.gavel_outlined), title: const Text('Legal / LGPD'), onTap: () { context.go('/legal'); Navigator.pop(ctx); }),
        ],
      );
    });
  }

  // Widget builder para criar cada item do menu (seu código original, levemente ajustado)
  Widget _buildNavItem(BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required int selectedIndex,
    required bool isExtended,
  }) {
    final bool isSelected = index == selectedIndex;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Widget content;

    if (isExtended) {
      content = Row(
        children: [
          Icon(icon, color: isSelected ? colors.primary : colors.onSurfaceVariant),
          const SizedBox(width: 16),
          Flexible(child: Text(label, style: TextStyle(color: isSelected ? colors.primary : colors.onSurfaceVariant), overflow: TextOverflow.ellipsis)),
        ],
      );
    } else {
      content = Icon(icon, color: isSelected ? colors.primary : colors.onSurfaceVariant);
    }

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () => _onItemTapped(index, context),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: isExtended ? 10 : 14),
          decoration: BoxDecoration(
            color: isSelected ? colors.primaryContainer.withOpacity(0.4) : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: content,
        ),
      ),
    );
  }
}