//C:\Users\ziofl\StudioProjects\curriculator_free\lib\features\settings\settings_screen.dart
import 'package:curriculator_free/core/services/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Camada de Dados e Lógica ---

const _apiKeyStorageKey = 'gemini_api_key';

// Provider simples para a instância do flutter_secure_storage
final secureStorageProvider = Provider((_) => const FlutterSecureStorage());

// Repositório que encapsula toda a lógica de manipulação da chave
final apiKeyRepositoryProvider = Provider((ref) {
  return ApiKeyRepository(ref.watch(secureStorageProvider));
});

class ApiKeyRepository {
  final FlutterSecureStorage _storage;
  ApiKeyRepository(this._storage);

  Future<String?> getApiKey() => _storage.read(key: _apiKeyStorageKey);
  Future<void> saveApiKey(String key) => _storage.write(key: _apiKeyStorageKey, value: key);
  Future<void> deleteApiKey() => _storage.delete(key: _apiKeyStorageKey);

  // Testa a validade da chave fazendo uma chamada simples à API
  Future<bool> testApiKey(String apiKey) async {
    if (apiKey.isEmpty) return false;
    try {
      final aiService = AIService(apiKey: apiKey);
      // Usamos um método simples que não consome muitos tokens
      await aiService.testConnection();
      return true;
    } catch (e) {
      debugPrint("Erro ao testar a chave de API: $e");
      return false;
    }
  }
}

// FutureProvider para carregar a chave de forma assíncrona e reativa
final apiKeyProvider = FutureProvider.autoDispose<String?>((ref) {
  return ref.watch(apiKeyRepositoryProvider).getApiKey();
});


// --- Tela Principal (UI) ---
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _apiKeyController;
  bool _isObscured = true;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    // Preenche o campo de texto quando os dados iniciais carregam
    ref.read(apiKeyProvider.future).then((key) {
      if (mounted && key != null) {
        _apiKeyController.text = key;
      }
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _onSave(String? currentlySavedKey) async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty || key == currentlySavedKey) return;

    await ref.read(apiKeyRepositoryProvider).saveApiKey(key);
    ref.invalidate(apiKeyProvider); // Força a releitura do valor salvo
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chave de API salva com sucesso!'), backgroundColor: Colors.green)
      );
    }
  }

  void _onDelete() {
    ref.read(apiKeyRepositoryProvider).deleteApiKey();
    _apiKeyController.clear();
    ref.invalidate(apiKeyProvider); // Força a releitura
  }

  void _onTest() async {
    setState(() => _isTesting = true);
    final key = _apiKeyController.text.trim();
    final success = await ref.read(apiKeyRepositoryProvider).testApiKey(key);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Conexão com a IA bem-sucedida!' : 'Falha na conexão. Verifique sua chave e internet.'),
            backgroundColor: success ? Colors.green : Colors.red,
          )
      );
      setState(() => _isTesting = false);
    }
  }

  Future<void> _launchURL() async {
    final uri = Uri.parse('https://aistudio.google.com/app/apikey');
    if (!await launchUrl(uri)) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao abrir o link.'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTutorialCard(context),
              const SizedBox(height: 32),
              _buildApiKeySection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Como obter sua Chave de API (Gratuita)', style: textTheme.titleLarge?.copyWith(color: primaryColor)),
            const SizedBox(height: 8),
            Text('Para usar a IA, você precisa de uma chave pessoal do Google. É gratuito, rápido e nenhum cartão de crédito é necessário.', style: textTheme.bodyMedium),
            const Divider(height: 32),
            _buildStep(context, icon: Icons.ads_click, text: 'Clique no botão abaixo para abrir o Google AI Studio e faça login com sua conta Google.'),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir Google AI Studio'),
                onPressed: _launchURL,
              ),
            ),
            const SizedBox(height: 24),
            _buildStep(context, icon: Icons.key, text: 'Na página, clique em “Create API key”. Copie o código gerado.'),
            const SizedBox(height: 16),
            _buildStep(context, icon: Icons.paste, text: 'Volte aqui, cole a chave no campo abaixo e clique em “Salvar”.'),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeySection(BuildContext context) {
    final apiKeyAsync = ref.watch(apiKeyProvider);
    final currentlySavedKey = apiKeyAsync.valueOrNull;
    final bool canSave = _apiKeyController.text.trim().isNotEmpty && _apiKeyController.text.trim() != currentlySavedKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sua Chave de API do Google AI', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        apiKeyAsync.when(
          data: (key) => Column(
            children: [
              TextFormField(
                controller: _apiKeyController,
                obscureText: _isObscured,
                onChanged: (_) => setState(() {}), // Atualiza o estado para reavaliar o `canSave`
                decoration: InputDecoration(
                  hintText: 'Cole sua chave aqui...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_isTesting) const CircularProgressIndicator()
                  else OutlinedButton(
                    onPressed: _apiKeyController.text.trim().isEmpty ? null : _onTest,
                    child: const Text('Testar Conexão'),
                  ),
                  const Spacer(),
                  if (key != null && key.isNotEmpty)
                    TextButton(onPressed: _onDelete, child: const Text('Remover Chave')),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar'),
                    onPressed: canSave ? () => _onSave(key) : null, // Desabilita se não houver mudanças
                  ),
                ],
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Text('Erro ao carregar a chave: $err'),
        ),
      ],
    );
  }

  Widget _buildStep(BuildContext context, {required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(height: 1.5))),
      ],
    );
  }
}

