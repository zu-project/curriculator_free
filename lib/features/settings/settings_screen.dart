import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Providers (Gerenciamento de Estado e Dependências) ---

// Chave usada para armazenar a API Key de forma segura.
const _apiKeyStorageKey = 'gemini_api_key';

// Provider para a instância do flutter_secure_storage
final secureStorageProvider = Provider((_) => const FlutterSecureStorage());

// StateNotifierProvider para gerenciar o estado da API Key (carregar, salvar, deletar)
final apiKeyNotifierProvider =
StateNotifierProvider.autoDispose<ApiKeyNotifier, AsyncValue<String?>>((ref) {
  return ApiKeyNotifier(ref.watch(secureStorageProvider));
});

class ApiKeyNotifier extends StateNotifier<AsyncValue<String?>> {
  final FlutterSecureStorage _storage;

  ApiKeyNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadApiKey();
  }

  Future<void> loadApiKey() async {
    try {
      final key = await _storage.read(key: _apiKeyStorageKey);
      state = AsyncValue.data(key);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> saveApiKey(String key) async {
    try {
      state = const AsyncValue.loading();
      await _storage.write(key: _apiKeyStorageKey, value: key);
      state = AsyncValue.data(key);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> deleteApiKey() async {
    state = const AsyncValue.loading();
    await _storage.delete(key: _apiKeyStorageKey);
    state = const AsyncValue.data(null);
  }
}

// --- UI Screen ---
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _apiKeyController;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O campo não pode estar vazio.'), backgroundColor: Colors.orange)
      );
      return;
    }

    final success = await ref.read(apiKeyNotifierProvider.notifier).saveApiKey(key);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API Key salva com sucesso!'), backgroundColor: Colors.green)
      );
    }
  }

  Future<void> _launchURL() async {
    final uri = Uri.parse('https://aistudio.google.com/app/apikey');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Não foi possível abrir o link.';
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao abrir o link: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ouve as mudanças no provider para atualizar o campo de texto
    ref.listen(apiKeyNotifierProvider, (_, state) {
      final apiKey = state.valueOrNull;
      if (apiKey != null) {
        _apiKeyController.text = apiKey;
      }
    });

    final apiKeyAsync = ref.watch(apiKeyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Tutorial Explicativo
                _buildTutorialCard(),
                const SizedBox(height: 32),

                // 2. Campo de Texto da API Key
                Text('Sua Chave de API do Google AI', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                apiKeyAsync.when(
                  data: (key) => Column(
                    children: [
                      TextFormField(
                        controller: _apiKeyController,
                        obscureText: _isObscured,
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
                          if (key != null && key.isNotEmpty)
                            TextButton(
                              child: const Text('Remover Chave'),
                              onPressed: () {
                                ref.read(apiKeyNotifierProvider.notifier).deleteApiKey();
                                _apiKeyController.clear();
                              },
                            ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                            onPressed: _onSave,
                          ),
                        ],
                      )
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Text('Erro ao carregar a chave: $err'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialCard() {
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
            Text(
              'Para usar a IA, você precisa de uma chave pessoal do Google. É gratuito, rápido e nenhum cartão de crédito é necessário.',
              style: textTheme.bodyMedium,
            ),
            const Divider(height: 32),

            _buildStep(
              icon: Icons.ads_click,
              text: RichText(text: const TextSpan(style: TextStyle(color: Colors.black, height: 1.5), children: [
                TextSpan(text: 'Clique no botão abaixo para abrir o '),
                TextSpan(text: 'Google AI Studio.', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' Faça login com sua conta Google.'),
              ]),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir Google AI Studio'),
                onPressed: _launchURL,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              ),
            ),
            const SizedBox(height: 24),

            _buildStep(
              icon: Icons.key,
              text: RichText(text: const TextSpan(style: TextStyle(color: Colors.black, height: 1.5), children: [
                TextSpan(text: 'Na página, clique em '),
                TextSpan(text: '“Create API key”', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '. Copie o código gerado.'),
              ]),
              ),
            ),
            const SizedBox(height: 16),
            _buildStep(
              icon: Icons.paste,
              text: RichText(text: const TextSpan(style: TextStyle(color: Colors.black, height: 1.5), children: [
                TextSpan(text: 'Volte aqui, cole a chave no campo abaixo e clique em '),
                TextSpan(text: '“Salvar”', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '.'),
              ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({required IconData icon, required Widget text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(width: 16),
        Expanded(child: text),
      ],
    );
  }
}