import 'package:flutter/material.dart';
import '../app_state.dart';
import 'place_screen.dart';

class AdminScreen extends StatefulWidget {
  final AppState state;
  const AdminScreen({super.key, required this.state});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> places = [], reports = [];
  bool busy = true;
  String? error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => busy = true);
    try {
      final data = await Future.wait([
        widget.state.api.request('GET', '/admin/places'),
        widget.state.api.request('GET', '/admin/reports'),
      ]);
      if (mounted) {
        setState(() {
          places = data[0];
          reports = data[1];
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = messageFor(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _edit([Map<String, dynamic>? place]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceEditor(state: widget.state, place: place),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _resolve(
    Map<String, dynamic> report, {
    bool removeReview = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          removeReview
              ? 'Remover avaliação denunciada?'
              : 'Marcar relato como resolvido?',
        ),
        content: Text(
          removeReview
              ? 'A avaliação e a foto serão removidas.'
              : 'Confirme que você conferiu as informações e fez as correções necessárias.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      if (removeReview) {
        await widget.state.api.request(
          'DELETE',
          '/admin/places/${report['placeId']}/reviews/${report['reviewUserId']}',
        );
      }
      await widget.state.api.request(
        'PATCH',
        '/admin/reports/${report['id']}',
        body: {'status': 'resolved'},
      );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(messageFor(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Administrar turismo'),
      actions: [
        IconButton(
          onPressed: busy ? null : _load,
          icon: const Icon(Icons.refresh),
          tooltip: 'Atualizar painel',
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(),
      icon: const Icon(Icons.add),
      label: const Text('Novo local'),
    ),
    body: busy
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              if (error != null) Text(error!),
              Text(
                'Locais (${places.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              for (final p in places)
                Card(
                  child: ListTile(
                    title: Text(p['name']),
                    subtitle: Text(p['address'] ?? ''),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _edit(Map<String, dynamic>.from(p)),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Relatos pendentes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (!reports.any((r) => r['status'] == 'pending'))
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum relato pendente.'),
                ),
              for (final r in reports.where((r) => r['status'] == 'pending'))
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['placeName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(r['details']),
                        Text(
                          'Recebido: ${(r['createdAt'] as String).split('T').first}',
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlaceScreen(
                                    state: widget.state,
                                    id: r['placeId'],
                                  ),
                                ),
                              ),
                              child: const Text('Conferir local'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  _resolve(Map<String, dynamic>.from(r)),
                              child: const Text('Resolvido'),
                            ),
                            if (r['reason'] == 'review')
                              TextButton(
                                onPressed: () => _resolve(
                                  Map<String, dynamic>.from(r),
                                  removeReview: true,
                                ),
                                child: const Text('Remover avaliação'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
  );
}

class PlaceEditor extends StatefulWidget {
  final AppState state;
  final Map<String, dynamic>? place;
  const PlaceEditor({super.key, required this.state, this.place});
  @override
  State<PlaceEditor> createState() => _PlaceEditorState();
}

class _PlaceEditorState extends State<PlaceEditor> {
  final form = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{};
  String category = 'Natureza', status = 'unverified';
  bool demo = true, busy = false, verified = false;
  String? error;
  @override
  void initState() {
    super.initState();
    final p = widget.place ?? {};
    for (final key in [
      'id',
      'name',
      'description',
      'address',
      'hours',
      'price',
      'lat',
      'lng',
      'contact',
      'website',
      'accessibility',
      'visitMinutes',
      'source',
    ]) {
      fields[key] = TextEditingController(
        text:
            '${p[key] ?? (key == 'visitMinutes'
                    ? 60
                    : key == 'price'
                    ? 0
                    : '')}',
      );
    }
    category = p['category'] ?? 'Natureza';
    status = p['status'] ?? 'unverified';
    demo = p['demo'] ?? true;
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final data = <String, dynamic>{
        for (final key in [
          'name',
          'description',
          'address',
          'hours',
          'contact',
          'website',
          'accessibility',
          'source',
        ])
          key: fields[key]!.text.trim(),
        for (final key in ['price', 'lat', 'lng'])
          key: double.parse(fields[key]!.text.replaceAll(',', '.')),
        'visitMinutes': int.parse(fields['visitMinutes']!.text),
        'category': category,
        'status': status,
        'demo': demo,
        'priceKnown': widget.place?['priceKnown'] ?? true,
        'verifiedAt': verified
            ? DateTime.now().toUtc().toIso8601String()
            : widget.place?['verifiedAt'],
        if (widget.place?['imageAsset'] != null)
          'imageAsset': widget.place!['imageAsset'],
      };
      await widget.state.api.request(
        'PUT',
        '/admin/places/${fields['id']!.text.trim()}',
        body: data,
      );
      await widget.state.refresh();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => error = messageFor(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget field(
    String key,
    String label, {
    int lines = 1,
    bool optional = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: fields[key],
      maxLines: lines,
      enabled: !busy && !(key == 'id' && widget.place != null),
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final v = (value ?? '').trim();
        if (v.isEmpty) return optional ? null : 'Preencha este campo.';
        if (key == 'id' && !RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(v)) {
          return 'Use letras, números, hífen ou sublinhado.';
        }
        if (['price', 'lat', 'lng'].contains(key)) {
          final n = double.tryParse(v.replaceAll(',', '.'));
          if (n == null || !n.isFinite) return 'Informe um número válido.';
          if (key == 'lat' && (n < -90 || n > 90) ||
              key == 'lng' && (n < -180 || n > 180) ||
              key == 'price' && (n < 0 || n > 100000)) {
            return 'Valor fora do limite.';
          }
        }
        if (key == 'visitMinutes') {
          final n = int.tryParse(v);
          if (n == null || n < 10 || n > 720) return 'Use de 10 a 720 minutos.';
        }
        if (key == 'description' && v.length < 10) {
          return 'Escreva pelo menos 10 caracteres.';
        }
        if (key == 'name' && v.length < 3) {
          return 'Use pelo menos 3 caracteres.';
        }
        if (key == 'website' && !v.startsWith('https://')) {
          return 'Informe um endereço HTTPS.';
        }
        return null;
      },
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.place == null ? 'Novo local' : 'Editar local'),
    ),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          field('id', 'Identificador do local'),
          field('name', 'Nome'),
          field('description', 'Descrição', lines: 4),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: category,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: [
              for (final c in ['Natureza', 'Cultura', 'História', 'Lazer'])
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => category = v!,
          ),
          const SizedBox(height: 14),
          field('address', 'Endereço'),
          field('lat', 'Latitude'),
          field('lng', 'Longitude'),
          field('hours', 'Horários'),
          field('price', 'Preço da entrada (R\$)'),
          field('visitMinutes', 'Duração média (minutos)'),
          field('contact', 'Contato', optional: true),
          field('website', 'Site oficial HTTPS', optional: true),
          field('accessibility', 'Acessibilidade', lines: 3),
          field('source', 'Fonte das informações', optional: true),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Funcionamento'),
            items: [
              for (final e in {
                'unverified': 'Não verificado',
                'open': 'Em funcionamento',
                'temporarily_closed': 'Temporariamente fechado',
                'closed': 'Fechado',
              }.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) => status = v!,
          ),
          SwitchListTile(
            title: const Text('Local fictício de demonstração'),
            value: demo,
            onChanged: (v) => setState(() => demo = v),
          ),
          CheckboxListTile(
            title: const Text('Conferi as informações hoje'),
            subtitle: const Text(
              'Marque somente após consultar uma fonte confiável.',
            ),
            value: verified,
            onChanged: (v) => setState(() => verified = v!),
          ),
          if (error != null) Text(error!),
          FilledButton(
            onPressed: busy ? null : _save,
            child: Text(busy ? 'Salvando…' : 'Salvar local'),
          ),
        ],
      ),
    ),
  );
}
