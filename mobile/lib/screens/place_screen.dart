import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../travel_actions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../api.dart';
import '../models.dart';
import '../app_theme.dart';
import '../widgets/travel_art.dart';

class PlaceScreen extends StatefulWidget {
  final AppState state;
  final String id;
  const PlaceScreen({super.key, required this.state, required this.id});
  @override
  State<PlaceScreen> createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  late Future<Place> _place;
  Future<dynamic>? _restaurants;
  bool _saving = false;
  AppState get s => widget.state;
  @override
  void initState() {
    super.initState();
    _place = _load();
  }

  Future<Place> _load() async {
    final p = await s.loadPlace(widget.id);
    _restaurants = s.offline
        ? Future.value({
            'items': [],
            'source': 'catalog',
            'warning': 'Restaurantes e mapas precisam de conexão.',
          })
        : s.api.request(
            'GET',
            '/restaurants?lat=${p.lat}&lng=${p.lng}&radius=3000',
          );
    return p;
  }

  Future<void> _refresh() async {
    setState(() => _place = _load());
    await _place;
  }

  void _snack(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  Future<void> _route(double lat, double lng) async {
    final mode = await chooseTravelMode(context);
    if (mode == null) return;
    try {
      final uri = Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': '$lat,$lng',
        'travelmode': mode,
      });
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw const ApiError('Não foi possível abrir o mapa.');
      }
    } catch (e) {
      _snack(messageFor(e));
    }
  }

  Future<void> _review(Place p) async {
    final existing = p.reviews.where((r) => r.userId == s.uid).firstOrNull;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => ReviewDialog(existing: existing),
    );
    if (result == null) return;
    setState(() => _saving = true);
    try {
      await s.api.request('PUT', '/places/${p.id}/review', body: result);
      await _refresh();
      _snack('Sua avaliação foi salva.');
    } catch (e) {
      _snack(messageFor(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _report(Place p, [Review? review]) async {
    final text = TextEditingController();
    String reason = review == null ? 'incorrect' : 'review';
    final form = GlobalKey<FormState>();
    bool busy = false;
    String? error;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: Text(
            review == null ? 'Informar um problema' : 'Denunciar avaliação',
          ),
          content: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (review == null)
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: reason,
                      items: const [
                        DropdownMenuItem(
                          value: 'incorrect',
                          child: Text('Informação incorreta'),
                        ),
                        DropdownMenuItem(
                          value: 'closed',
                          child: Text('Local fechado'),
                        ),
                      ],
                      onChanged: (v) => reason = v!,
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: text,
                    maxLines: 4,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      labelText: 'Descreva o problema',
                    ),
                    validator: (v) => (v ?? '').trim().length < 5
                        ? 'Escreva pelo menos 5 caracteres.'
                        : null,
                  ),
                  if (error != null) Text(error!),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      setDialog(() => busy = true);
                      try {
                        await s.api.request(
                          'POST',
                          '/places/${p.id}/reports',
                          body: {
                            'reason': reason,
                            'details': text.text.trim(),
                            if (review != null) 'reviewUserId': review.userId,
                          },
                        );
                        if (context.mounted) Navigator.pop(context);
                        _snack(
                          'Relato enviado para análise. Obrigado por ajudar!',
                        );
                      } catch (e) {
                        if (context.mounted) {
                          setDialog(() => error = messageFor(e));
                        }
                      } finally {
                        if (context.mounted) setDialog(() => busy = false);
                      }
                    },
              child: Text(busy ? 'Enviando…' : 'Enviar relato'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sua próxima descoberta')),
    body: FutureBuilder<Place>(
      future: _place,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    messageFor(snapshot.error!),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(() => _place = _load()),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = snapshot.data!;
        return ListenableBuilder(
          listenable: s,
          builder: (context, _) => RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                Hero(
                  tag: 'place-art-${p.id}',
                  child: DiscoveryArtwork(
                    category: p.category,
                    height: 210,
                    showLabel: true,
                    imageAsset: p.imageAsset,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  p.category.toUpperCase(),
                  style: TextStyle(
                    color: categoryColor(p.category),
                    letterSpacing: 1.5,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(p.address, style: const TextStyle(color: Colors.black54)),
                if (p.demo)
                  Container(
                    margin: const EdgeInsets.only(top: 13),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Local fictício de demonstração',
                            style: TextStyle(
                              color: AppColors.accentDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _route(p.lat, p.lng),
                      icon: const Icon(Icons.directions_walk),
                      label: const Text('Ver rota'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await s.toggleFavorite(p);
                        } catch (e) {
                          _snack(messageFor(e));
                        }
                      },
                      icon: Icon(
                        s.isFavorite(p.id)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                      ),
                      label: Text(s.isFavorite(p.id) ? 'Salvo' : 'Salvar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => s.toggleItinerary(p),
                      icon: Icon(
                        s.isInItinerary(p.id)
                            ? Icons.route_rounded
                            : Icons.add_road_rounded,
                      ),
                      label: Text(
                        s.isInItinerary(p.id)
                            ? 'No roteiro'
                            : 'Adicionar ao roteiro',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _section('Um pouco sobre o lugar'),
                Text(
                  p.description,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: const Text('Horário de visitação'),
                  subtitle: Text(p.hours),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.confirmation_number_outlined),
                  title: Text(p.priceLabel),
                  subtitle: const Text(
                    'Confirme horários e valores antes da visita.',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline),
                  title: Text(p.statusLabel),
                  subtitle: Text(
                    p.verifiedAt == null
                        ? 'Informações ainda não verificadas.'
                        : 'Conferido em ${p.verifiedAt!.split('T').first}${p.source.isEmpty ? '' : ' • ${p.source}'}',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.accessible),
                  title: const Text('Acessibilidade'),
                  subtitle: Text(p.accessibility),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.timer_outlined),
                  title: Text('Visita estimada: ${p.visitMinutes} minutos'),
                ),
                if (p.contact.isNotEmpty)
                  SelectableText('Contato: ${p.contact}'),
                if (p.website.isNotEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        await launchUrl(
                          Uri.parse(p.website),
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        _snack(messageFor(e));
                      }
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Consultar site oficial'),
                  ),
                TextButton.icon(
                  onPressed: s.offline ? null : () => _report(p),
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Informar local fechado ou dado incorreto'),
                ),
                const Divider(height: 32),
                _section('Uma pausa para comer'),
                const Text('Restaurantes a até 3 km deste local.'),
                const SizedBox(height: 12),
                FutureBuilder<dynamic>(
                  future: _restaurants,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(messageFor(snapshot.error!)),
                          TextButton(
                            onPressed: () => setState(
                              () => _restaurants = s.api.request(
                                'GET',
                                '/restaurants?lat=${p.lat}&lng=${p.lng}&radius=3000',
                              ),
                            ),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      );
                    }
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }
                    final data = snapshot.data as Map<String, dynamic>,
                        items = data['items'] as List;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data['warning'] != null)
                          Text(
                            data['warning'],
                            style: const TextStyle(color: Colors.brown),
                          ),
                        if (data['source'] == 'google')
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Google Maps',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (items.isEmpty)
                          const Text(
                            'Nenhum restaurante encontrado neste raio.',
                          ),
                        ...items.map(
                          (r) => Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.restaurant),
                                    title: Text(r['name']),
                                    subtitle: Text(
                                      '${r['cuisine']} • ${((r['distance'] as num) / 1000).toStringAsFixed(1)} km\n${r['address']}${r['demo'] == true ? '\nEstabelecimento fictício' : ''}',
                                    ),
                                    isThreeLine: true,
                                    trailing: IconButton(
                                      tooltip: 'Ver rota',
                                      icon: const Icon(
                                        Icons.directions_outlined,
                                      ),
                                      onPressed: () => _route(
                                        (r['lat'] as num).toDouble(),
                                        (r['lng'] as num).toDouble(),
                                      ),
                                    ),
                                  ),
                                  for (final attribution
                                      in (r['attributions'] as List? ?? []))
                                    TextButton(
                                      onPressed: () async {
                                        final uri = Uri.tryParse(
                                          attribution['providerUri'] ?? '',
                                        );
                                        if (uri != null &&
                                            uri.scheme == 'https') {
                                          await launchUrl(
                                            uri,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                      },
                                      child: Text(
                                        attribution['provider'] ?? 'Fonte',
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 36),
                _section('Histórias de quem passou'),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xffcc833c)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        p.rating == null
                            ? 'Ainda sem avaliações'
                            : '${p.rating!.toStringAsFixed(1)} • ${p.reviews.length} avaliações',
                      ),
                    ),
                    TextButton(
                      onPressed: _saving || s.offline ? null : () => _review(p),
                      child: Text(
                        _saving
                            ? 'Salvando…'
                            : p.reviews.any((r) => r.userId == s.uid)
                            ? 'Editar avaliação'
                            : 'Avaliar',
                      ),
                    ),
                  ],
                ),
                ...p.reviews.map(
                  (r) => Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.userName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '★' * r.rating,
                            style: const TextStyle(color: Color(0xffcc833c)),
                          ),
                          const SizedBox(height: 8),
                          if (r.visitedOn != null)
                            Text('Visitou em ${r.visitedOn}'),
                          Text(r.comment),
                          if (r.photo != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  base64Decode(r.photo!.split(',').last),
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, error, stack) =>
                                      const Text('Foto indisponível.'),
                                ),
                              ),
                            ),
                          if (!s.offline)
                            TextButton.icon(
                              onPressed: () => _report(p, r),
                              icon: const Icon(Icons.flag_outlined),
                              label: const Text('Denunciar'),
                            ),
                          if (s.isAdmin && !s.offline)
                            TextButton(
                              onPressed: () async {
                                final yes = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                      'Remover esta avaliação?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Remover'),
                                      ),
                                    ],
                                  ),
                                );
                                if (yes == true) {
                                  try {
                                    await s.api.request(
                                      'DELETE',
                                      '/admin/places/${p.id}/reviews/${r.userId}',
                                    );
                                    await _refresh();
                                  } catch (e) {
                                    _snack(messageFor(e));
                                  }
                                }
                              },
                              child: const Text('Moderar: remover avaliação'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    ),
  );
  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    ),
  );
}

class ReviewDialog extends StatefulWidget {
  final Review? existing;
  const ReviewDialog({super.key, this.existing});
  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  late final TextEditingController _text;
  late int _rating;
  String? _photo, _photoError;
  DateTime? _visitedOn;
  bool _picking = false;
  final _form = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.existing?.comment);
    _rating = widget.existing?.rating ?? 5;
    _photo = widget.existing?.photo;
    _visitedOn = DateTime.tryParse(widget.existing?.visitedOn ?? '');
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    setState(() => _picking = true);
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 640,
        maxHeight: 640,
        imageQuality: 65,
        requestFullMetadata: false,
      );
      if (photo == null) return;
      final bytes = await photo.readAsBytes();
      if (bytes.length > 130000) {
        throw const ApiError(
          'Escolha uma foto menor (até 130 KB após redução).',
        );
      }
      final png =
          bytes.length >= 8 &&
          bytes[0] == 137 &&
          bytes[1] == 80 &&
          bytes[2] == 78 &&
          bytes[3] == 71;
      final jpeg =
          bytes.length >= 3 &&
          bytes[0] == 255 &&
          bytes[1] == 216 &&
          bytes[2] == 255;
      if (!png && !jpeg) throw const ApiError('Escolha uma foto JPEG ou PNG.');
      if (mounted) {
        setState(() {
          _photo =
              'data:image/${png ? 'png' : 'jpeg'};base64,${base64Encode(bytes)}';
          _photoError = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _photoError = messageFor(e));
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Como foi sua visita?'),
    content: SingleChildScrollView(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              children: List.generate(
                5,
                (i) => IconButton(
                  tooltip: '${i + 1} estrelas',
                  onPressed: () => setState(() => _rating = i + 1),
                  icon: Icon(
                    i < _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: const Color(0xffcc833c),
                  ),
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _visitedOn == null
                    ? 'Data da visita'
                    : 'Visita: ${_visitedOn!.toIso8601String().split('T').first}',
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _visitedOn ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null && mounted) setState(() => _visitedOn = date);
              },
            ),
            OutlinedButton.icon(
              onPressed: _picking ? null : _pickPhoto,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _picking ? 'Carregando…' : 'Adicionar foto da visita',
              ),
            ),
            if (_photoError != null) Text(_photoError!),
            if (_photo != null) ...[
              Image.memory(base64Decode(_photo!.split(',').last), height: 120),
              TextButton(
                onPressed: () => setState(() => _photo = null),
                child: const Text('Remover foto'),
              ),
            ],
            TextFormField(
              controller: _text,
              minLines: 3,
              maxLines: 5,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Conte sua experiência',
              ),
              validator: (v) => (v ?? '').trim().length < 3
                  ? 'Escreva pelo menos 3 caracteres.'
                  : null,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _picking
            ? null
            : () {
                if (_form.currentState!.validate()) {
                  Navigator.pop(context, {
                    if (_photo != null) 'photo': _photo,
                    if (_visitedOn != null)
                      'visitedOn': _visitedOn!
                          .toIso8601String()
                          .split('T')
                          .first,
                    'rating': _rating,
                    'comment': _text.text.trim(),
                  });
                }
              },
        child: const Text('Salvar avaliação'),
      ),
    ],
  );
}
