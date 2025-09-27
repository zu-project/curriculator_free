//C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\info\about_screen.dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o Curriculator Free'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Text(
                'Curriculator Free',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Sua central de currículos, local e privada.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(height: 48),

              _buildSection(
                context,
                title: 'Nosso Propósito',
                content:
                'Em um mercado de trabalho competitivo, criar um currículo otimizado para cada vaga é crucial. O Curriculator Free nasceu da necessidade de simplificar esse processo. Nossa missão é fornecer uma ferramenta gratuita, poderosa e que respeita sua privacidade, ajudando você a organizar suas informações profissionais e a criar versões personalizadas do seu currículo com facilidade.',
              ),

              _buildSection(
                context,
                title: 'Principais Tecnologias Utilizadas',
                content: 'Este aplicativo foi construído com amor e código aberto, utilizando tecnologias modernas:',
                children: const [
                  _TechItem('Flutter & Dart', 'Para uma interface bonita e multiplataforma (Desktop e Mobile) a partir de uma única base de código.'),
                  _TechItem('Isar Database', 'Um banco de dados local super rápido e eficiente, garantindo que seus dados fiquem apenas no seu dispositivo.'),
                  _TechItem('Riverpod', 'Para um gerenciamento de estado moderno, escalável e robusto.'),
                  _TechItem('Google Gemini', 'A Inteligência Artificial da Google é usada nas funcionalidades opcionais de otimização e tradução.'),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LicensePage()));
                },
                icon: const Icon(Icons.description_outlined),
                label: const Text('Ver Licenças de Software'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content, List<Widget> children = const []}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _TechItem extends StatelessWidget {
  const _TechItem(this.name, this.description);
  final String name;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          )
        ],
      ),
    );
  }
}