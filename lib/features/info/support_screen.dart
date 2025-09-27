//C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\info\support_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir $url'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apoie este Projeto'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const Icon(Icons.favorite, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Pague um café para o dev!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'O Curriculator Free é um projeto feito com paixão para ajudar a comunidade. Se ele foi útil para você, considere apoiar o desenvolvimento contínuo com uma pequena doação. Qualquer valor ajuda a manter o projeto vivo e a adicionar novas funcionalidades!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              const Divider(height: 48),

              // Seção PIX
              _SupportOptionCard(
                title: 'Doação via PIX',
                icon: Icons.pix_outlined,
                child: Column(
                  children: [
                    const SelectableText(
                      'aa819ebc-dbe3-4816-96ce-92e104451007', // <-- SUBSTITUA PELO SEU CPF/CNPJ OU CHAVE ALEATÓRIA
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar Chave PIX'),
                      onPressed: () => _copyToClipboard(
                          context, 'aa819ebc-dbe3-4816-96ce-92e104451007', 'Chave PIX copiada!'), // <-- SUBSTITUA AQUI TBM
                    ),
                  ],
                ),
              ),

              // Seção BTC
              _SupportOptionCard(
                title: 'Doação com Bitcoin (BTC)',
                icon: Icons.currency_bitcoin,
                child: Column(
                  children: [
                    const SelectableText(
                      '13CDR1y8jYqh6UqSMLoTCk4k8gunp7QSZH', // <-- SUBSTITUA PELA SUA CARTEIRA
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar Endereço BTC'),
                      onPressed: () => _copyToClipboard(
                          context, '13CDR1y8jYqh6UqSMLoTCk4k8gunp7QSZH', 'Endereço BTC copiado!'), // <-- SUBSTITUA AQUI TBM
                    ),
                  ],
                ),
              ),

              _SupportOptionCard(
                  title: 'Conecte-se comigo',
                  icon: Icons.connect_without_contact,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        child: const Text('Patreon'),
                        onPressed: () => _launchURL(context, 'https://www.patreon.com/zuproject'), // <-- SUBSTITUA
                      ),
                      OutlinedButton(
                        child: const Text('LinkedIn'),
                        onPressed: () => _launchURL(context, 'https://www.linkedin.com/in/flavio-zuicker'), // <-- SUBSTITUA
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportOptionCard extends StatelessWidget {
  const _SupportOptionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}