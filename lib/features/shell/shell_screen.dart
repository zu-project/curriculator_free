import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellScreen extends StatefulWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location == '/') return 0;
    if (location.startsWith('/personal')) return 1;
    if (location.startsWith('/experience')) return 2;
    if (location.startsWith('/education')) return 3;
    if (location.startsWith('/skills')) return 4;
    if (location.startsWith('/languages')) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/personal');
        break;
      case 2:
        context.go('/experience');
        break;
      case 3:
        context.go('/education');
        break;
      case 4:
        context.go('/skills');
        break;
      case 5:
        context.go('/languages');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para adaptar a UI para desktop
    return Scaffold(
      body: Row(
        children: [
          // NavigationRail para telas mais largas (Desktop)
          LayoutBuilder(builder: (context, constraints) {
            // Se a altura for maior que 450, usa o NavigationRail
            if (constraints.maxHeight > 500) {
              // --- CORREÇÃO APLICADA AQUI ---
              // Criamos uma variável para a condição de estar estendido para reutilizá-la.
              final bool isExtended = constraints.maxWidth > 800;

              return NavigationRail(
                selectedIndex: _calculateSelectedIndex(context),
                onDestinationSelected: (index) => _onItemTapped(index, context),

                // A correção principal: usamos um operador ternário.
                // Se estiver estendido (isExtended == true), o labelType é 'none'.
                // Se não estiver estendido, o labelType é 'all'.
                labelType: isExtended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,

                extended: isExtended, // A propriedade 'extended' agora usa a mesma variável.
                // --- Adicione a propriedade `trailing` ---
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            tooltip: 'Configurações',
                            onPressed: () => context.go('/settings'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            tooltip: 'Sobre',
                            onPressed: () => context.go('/about'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
                            tooltip: 'Apoie o Projeto',
                            onPressed: () => context.go('/support'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Dados Pessoais'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.work_outline),
                    selectedIcon: Icon(Icons.work),
                    label: Text('Experiências'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school),
                    label: Text('Educação'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.lightbulb_outline),
                    selectedIcon: Icon(Icons.lightbulb),
                    label: Text('Habilidades'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.language_outlined),
                    selectedIcon: Icon(Icons.language),
                    label: Text('Idiomas'),
                  ),
                ],
              );

            }
            return const SizedBox.shrink(); // Não mostra nada em telas pequenas
          }),
          const VerticalDivider(thickness: 1, width: 1),
          // O conteúdo da tela atual
          Expanded(child: widget.child),
        ],
      ),
      // Adaptei aqui para ser mais focado em mobile (largura < 600)
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(label: 'Dashboard', icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard)),
          NavigationDestination(label: 'Pessoais', icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person)),
          NavigationDestination(label: 'Experiência', icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work)),
          NavigationDestination(label: 'Educação', icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school)),
        ],
      )
          : null,
    );

  }

}