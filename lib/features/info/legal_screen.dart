//C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\info\legal_screen.dart
import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LGPD e Aviso Legal'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildSectionCard(
                context,
                title: 'Política de Privacidade e LGPD',
                icon: Icons.privacy_tip_outlined,
                content: const Text(
                  'Sua privacidade é nossa prioridade.\n\n'
                      '1.  **Nenhum dado é coletado:** O Curriculator Free funciona 100% offline no seu computador. Nenhuma informação pessoal, dado de currículo ou qualquer outro tipo de dado que você insere no aplicativo é enviado para nossos servidores ou para terceiros. Tudo fica armazenado localmente no seu dispositivo.\n\n'
                      '2.  **Armazenamento Local:** Utilizamos um banco de dados local (Isar) para salvar suas informações de forma segura na sua máquina. Apenas você tem acesso a esses dados.\n\n'
                      '3.  **Funcionalidade de IA Opcional:** O recurso de otimização de currículo com Inteligência Artificial é opcional e requer que você forneça sua própria chave de API do Google AI Studio. Ao usar esta funcionalidade, os dados do seu currículo e a descrição da vaga são enviados para os servidores da Google para processamento, sujeitos à política de privacidade da Google. O Curriculator Free não armazena nem tem acesso a essas interações.\n\n'
                      '4.  **Transparência:** Acreditamos no poder do código aberto. O uso de tecnologias open source garante que não há mecanismos ocultos de coleta de dados.',
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                context,
                title: 'Aviso Legal',
                icon: Icons.gavel_outlined,
                content: const Text(
                  '1.  **Uso do Software:** O Curriculator Free é fornecido "como está", sem garantias de qualquer tipo. O uso do software é de sua total responsabilidade. Não nos responsabilizamos por qualquer perda de dados ou por decisões de carreira tomadas com base no uso do aplicativo.\n\n'
                      '2.  **Licenças Open Source:** Este software utiliza bibliotecas de código aberto. Agradecemos imensamente à comunidade de desenvolvedores por seu trabalho. As licenças para os principais pacotes utilizados podem ser consultadas nas respectivas páginas dos projetos.\n\n'
                      '3.  **Isenção de Responsabilidade:** As sugestões fornecidas pela funcionalidade de IA são geradas por modelos de linguagem e devem ser revisadas e usadas como um ponto de partida. Não garantimos que o uso dessas sugestões resultará em uma oferta de emprego.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title, required IconData icon, required Widget content}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.6),
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}