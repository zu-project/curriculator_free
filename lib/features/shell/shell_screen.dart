import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// O ShellScreen é a "casca" que contém o layout principal do aplicativo.
class ShellScreen extends StatefulWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  // Mapeamento centralizado de rotas para índices.
  static const Map<String, int> _routeMap = {
    '/': 0,
    '/personal': 1,
    '/experience': 2,
    '/education': 3,
    '/skills': 4,
    '/languages': 5,
    '/settings': 6,
    '/about': 7,
    '/support': 8,
    '/legal': 9,
  };

  // Determina qual item do menu deve estar selecionado com base na rota.
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    for (final entry in _routeMap.entries) {
      if (location.startsWith(entry.key)) return entry.value;
    }
    return 0;
  }

  // Navega para a rota correspondente ao índice do item clicado.
  void _onItemTapped(int index, BuildContext context) {
    final String route = _routeMap.entries.firstWhere((entry) => entry.value == index).key;
    context.go(route);
  }

  // Decide em qual tela o FloatingActionButton (FAB) de "Adicionar" deve aparecer.
  bool _showFloatingActionButton(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    const routesWithFab = ['/experience', '/education', '/skills', '/languages'];
    return routesWithFab.contains(location);
  }

  // Define a ação do FAB com base na rota atual.
  void _onFabPressed(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    // No futuro, isso poderia chamar um método específico de cada tela.
    // Por enquanto, podemos assumir que cada tela sabe o que fazer
    // quando um evento de "adicionar" é disparado.
    // A forma mais robusta seria usar um serviço de eventos ou um provider.
    // Por simplicidade, vamos deixar a lógica na tela de destino por enquanto.
    // O ideal seria que a tela de destino escutasse um evento.
    // Por exemplo:
    // ref.read(fabActionProvider.notifier).trigger();

    // A ação de "adicionar" é específica para cada tela. A tela em si
    // já tem o FAB e sua lógica. Este FAB global é uma alternativa.
    // Vamos mantê-lo aqui, mas note que cada tela já tem seu próprio FAB
    // que é a abordagem mais recomendada.
    // Se decidirmos por um FAB global, a lógica seria mais complexa.
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    // Para telas de desktop, usamos o layout com a barra lateral.
    if (MediaQuery.of(context).size.width > 600) {
      return Scaffold(
        body: Row(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              final isExtended = constraints.maxWidth > 800;
              return Container(
                width: isExtended ? 256 : 80,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildNavItem(context, icon: Icons.dashboard_outlined, label: 'Dashboard', index: 0, selectedIndex: selectedIndex, isExtended: isExtended),
                    _buildNavItem(context, icon: Icons.person_outline, label: 'Dados Pessoais', index: 1, selectedIndex: selectedIndex, isExtended: isExtended),
                    _buildNavItem(context, icon: Icons.work_outline, label: 'Experiências', index: 2, selectedIndex: selectedIndex, isExtended: isExtended),
                    _buildNavItem(context, icon: Icons.school_outlined, label: 'Educação', index: 3, selectedIndex: selectedIndex, isExtended: isExtended),
                    _buildNavItem(context, icon: Icons.lightbulb_outline, label: 'Habilidades', index: 4, selectedIndex: selectedIndex, isExtended: isExtended),
                    _buildNavItem(context, icon: Icons.language_outlined, label: 'Idiomas', index: 5, selectedIndex: selectedIndex, isExtended: isExtended),
                    const Spacer(),
                    _buildNavItem(context, icon: Icons.settings_outlined, label: 'Configurações', index: 6, selectedIndex: selectedIndex, isExtended: isExtended),
                    _buildNavItem(context, icon: Icons.info_outline, label: 'Sobre', index: 7, selectedIndex: selectedIndex, isExtended: isExtended),
                    _buildNavItem(context, icon: Icons.favorite_border, label: 'Apoie o Projeto', index: 8, selectedIndex: selectedIndex, isExtended: isExtended),
                    _buildNavItem(context, icon: Icons.gavel_outlined, label: 'Legal / LGPD', index: 9, selectedIndex: selectedIndex, isExtended: isExtended),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    // Para telas mobile, usamos o layout com a barra inferior.
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(label: 'Dashboard', icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard)),
          NavigationDestination(label: 'Pessoais', icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person)),
          NavigationDestination(label: 'Experiência', icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work)),
          NavigationDestination(label: 'Educação', icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school)),
          NavigationDestination(label: 'Mais', icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz_outlined)),
        ],
      ),
    );
  }

  // Widget builder para criar cada item do menu, garantindo consistência visual.
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

    // Se a barra estiver estendida, usamos um Row com espaçamento.
    if (isExtended) {
      content = Row(
        children: [
          Icon(icon, color: isSelected ? colors.primary : colors.onSurfaceVariant),
          const SizedBox(width: 16),
          // Flexible previne o overflow de texto
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: isSelected ? colors.primary : colors.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else { // Versão recolhida (só ícone)
      content = Icon(icon, color: isSelected ? colors.primary : colors.onSurfaceVariant);
    }

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () => _onItemTapped(index, context),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: isExtended ? 8 : 12),
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