import '../travel_actions.dart';
import '../trip_planner.dart';
import 'admin_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../app_theme.dart';
import '../config.dart';
import '../models.dart';
import '../widgets/travel_art.dart';
import 'place_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _tab = 0;
  String _query = '', _category = 'Todos';
  bool _gpsBusy = false, _alertBusy = false;
  bool _itineraryBusy = false;
  String _travelMode = 'walking';
  AppState get s => widget.state;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    s.alerts.onTap = _openById;
    final code = s.recoveryCode;
    if (code != null) {
      s.recoveryCode = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showRecoveryCode(context, code);
      });
    }
    if (s.alerts.pending != null) {
      final id = s.alerts.pending!;
      s.alerts.pending = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _openById(id));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    s.alerts.onTap = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(s.syncGpsStatus());
    } else {
      s.pauseGps();
    }
  }

  void _openById(String id) {
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlaceScreen(state: s, id: id),
        ),
      );
    }
  }

  void _snack(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _gps() async {
    setState(() => _gpsBusy = true);
    try {
      await s.enableGps();
    } catch (e) {
      _snack(messageFor(e));
    } finally {
      if (mounted) setState(() => _gpsBusy = false);
    }
  }

  Future<void> _favorite(Place p) async {
    try {
      await s.toggleFavorite(p);
    } catch (e) {
      _snack(messageFor(e));
    }
  }

  Future<void> _generateItinerary() async {
    final budget = TextEditingController(text: '100');
    final minutes = TextEditingController(text: '240');
    final form = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Planejar meu passeio'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Defina o total para entradas e o tempo disponível. A seleção atual será substituída.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: budget,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Orçamento para entradas (R\$)',
                  ),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                    return n == null || !n.isFinite || n < 0
                        ? 'Informe um valor válido.'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: minutes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tempo disponível (minutos)',
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return n == null || n < 10 || n > 1440
                        ? 'Use entre 10 e 1440 minutos.'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _travelMode,
                  items: const [
                    DropdownMenuItem(value: 'walking', child: Text('A pé')),
                    DropdownMenuItem(value: 'driving', child: Text('De carro')),
                    DropdownMenuItem(
                      value: 'transit',
                      child: Text('Transporte público'),
                    ),
                  ],
                  onChanged: (v) => _travelMode = v!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Criar roteiro'),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    setState(() => _itineraryBusy = true);
    try {
      await s.generateItinerary(
        budget: double.parse(budget.text.replaceAll(',', '.')),
        minutes: int.parse(minutes.text),
        mode: _travelMode,
      );
      _snack('Roteiro criado com ${s.itineraryPlaces.length} paradas.');
    } catch (e) {
      _snack(messageFor(e));
    } finally {
      if (mounted) setState(() => _itineraryBusy = false);
    }
  }

  Future<void> _openItineraryLeg(Place destination, Place? origin) async {
    final mode = await chooseTravelMode(context);
    if (mode == null) return;
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      if (origin != null) 'origin': '${origin.lat},${origin.lng}',
      'destination': '${destination.lat},${destination.lng}',
      'travelmode': mode,
    });
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _snack('Não foi possível abrir o Google Maps. Tente novamente.');
      }
    } catch (e) {
      _snack(messageFor(e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const HippieWordmark(),
      actions: [
        IconButton(
          tooltip: 'Atualizar locais',
          onPressed: s.loading ? null : s.refresh,
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: Column(
      children: [
        if (Config.demo)
          Container(
            width: double.infinity,
            color: AppColors.primarySoft,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            child: const Text(
              'MODO LOCAL • atrações reais e exemplos sinalizados',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        if (s.offline)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Consulta offline • salvo em ${s.offlineSavedAt?.split('T').first ?? ''} • informações podem ter mudado',
            ),
          ),
        if (s.loading) const LinearProgressIndicator(minHeight: 2),
        if (s.error != null)
          MaterialBanner(
            content: Text(s.error!),
            actions: [
              TextButton(
                onPressed: s.refresh,
                child: const Text('Tentar novamente'),
              ),
              TextButton(
                onPressed: () => unawaited(s.signOut()),
                child: const Text('Sair'),
              ),
            ],
          ),
        Expanded(
          child: switch (_tab) {
            0 => _explore(),
            1 => _map(),
            2 => _saved(),
            3 => _itinerary(),
            _ => _profile(),
          },
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (v) => setState(() => _tab = v),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Explorar',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Mapa',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_border),
          selectedIcon: Icon(Icons.bookmark),
          label: 'Salvos',
        ),
        NavigationDestination(
          icon: Icon(Icons.route_outlined),
          selectedIcon: Icon(Icons.route_rounded),
          label: 'Roteiro',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    ),
  );
  Widget _explore() {
    final filtered = s.places
        .where(
          (p) =>
              (_category == 'Todos' || p.category == _category) &&
              '${p.name} ${p.description}'.toLowerCase().contains(
                _query.toLowerCase(),
              ),
        )
        .toList();
    return RefreshIndicator(
      onRefresh: s.refresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Olá, ${s.name.split(' ').first}',
            style: const TextStyle(fontSize: 15, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vá onde a\ncuriosidade levar.',
            style: TextStyle(
              fontSize: 34,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 20),
          LocationHeroCard(
            active: s.useGps,
            busy: _gpsBusy,
            location: s.centerLabel,
            radiusKm: (s.radius / 1000).round(),
            onPressed: _gpsBusy ? null : _gps,
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'O que você quer descobrir?',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todos', 'Natureza', 'Cultura', 'História', 'Lazer']
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Próximas descobertas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${filtered.length} ${filtered.length == 1 ? 'local' : 'locais'}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty && !s.loading)
            _empty(
              Icons.travel_explore,
              'Nenhum local por aqui',
              'Tente outro filtro ou aumente o raio no perfil.',
            ),
          ...filtered.map(_card),
        ],
      ),
    );
  }

  Widget _card(Place p) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => _openById(p.id),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 82,
              child: DiscoveryArtwork(
                category: p.category,
                height: 88,
                imageAsset: p.imageAsset,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: categoryColor(p.category),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    [
                      p.priceLabel,
                      if (p.distance != null) p.distanceLabel,
                    ].join(' • '),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: s.isFavorite(p.id)
                      ? 'Remover dos salvos'
                      : 'Salvar local',
                  onPressed: () => _favorite(p),
                  icon: Icon(
                    s.isFavorite(p.id) ? Icons.bookmark : Icons.bookmark_border,
                    color: AppColors.secondaryDark,
                  ),
                ),
                IconButton(
                  tooltip: s.isInItinerary(p.id)
                      ? 'Remover do roteiro'
                      : 'Adicionar ao roteiro',
                  onPressed: () => s.toggleItinerary(p),
                  icon: Icon(
                    s.isInItinerary(p.id)
                        ? Icons.route_rounded
                        : Icons.add_road_rounded,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  Widget _saved() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        'Suas próximas paradas',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      const Text('Acrescente locais que você pretende conhecer.'),
      const SizedBox(height: 24),
      if (s.favorites.isEmpty)
        _empty(
          Icons.bookmark_border,
          'Sua coleção começa aqui',
          'Toque no marcador de um local para salvá-lo.',
        ),
      ...s.favorites.map(_card),
    ],
  );
  Widget _itinerary() {
    final items = s.itineraryPlaces;
    final total = items.fold<double>(0, (sum, place) => sum + place.price);
    final totalLabel = total == 0
        ? 'Passeios gratuitos'
        : 'Entradas: R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Meu roteiro',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text('Monte seu passeio e acompanhe o custo das entradas.'),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: s.loading || _itineraryBusy || s.places.isEmpty
              ? null
              : _generateItinerary,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: Text(
            _itineraryBusy
                ? 'Criando roteiro...'
                : 'Planejar por tempo e orçamento',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Estimativas de deslocamento pela distância em linha reta, sem trânsito ou horários de transporte. Confira a rota e o funcionamento dos locais. Transporte, alimentação e retorno não entram no orçamento.',
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 18),
        if (items.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => shareTrip(context, items),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Compartilhar'),
              ),
              OutlinedButton.icon(
                onPressed: s.offline
                    ? null
                    : () async {
                        try {
                          await s.saveOffline();
                          _snack(
                            'Roteiro e detalhes salvos. Na tela de entrada, use Consultar roteiro baixado.',
                          );
                        } catch (e) {
                          _snack(messageFor(e));
                        }
                      },
                icon: const Icon(Icons.download_outlined),
                label: const Text('Salvar para usar offline'),
              ),
            ],
          ),
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Tempo estimado de visitas e deslocamentos: ${_estimatedMinutes(items)} min.',
            ),
          ),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.secondarySoft,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.secondaryDark,
                foregroundColor: Colors.white,
                child: Icon(Icons.route_rounded),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${items.length} ${items.length == 1 ? 'parada' : 'paradas'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(totalLabel),
                    if (items.any((p) => !p.priceKnown))
                      const Text(
                        'Estimativa parcial: há entradas com valor a confirmar.',
                      ),
                  ],
                ),
              ),
              if (items.isNotEmpty)
                TextButton(
                  onPressed: s.clearItinerary,
                  child: const Text('Limpar'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (items.isEmpty)
          _empty(
            Icons.add_road_rounded,
            'Escolha suas próximas paradas',
            'Use o ícone de rota nos cartões ou nos detalhes de um local.',
          ),
        if (items.isNotEmpty) ...[
          const Text(
            'Siga as paradas na ordem abaixo. Cada trecho abre no Google Maps '
            'para escolher seu transporte. Confira os horários de visita.',
          ),
          const SizedBox(height: 16),
        ],
        for (var index = 0; index < items.length; index++) ...[
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                child: Text('${index + 1}'),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('Parada ${index + 1}')),
              TextButton.icon(
                onPressed: () => _openItineraryLeg(
                  items[index],
                  index == 0 ? null : items[index - 1],
                ),
                icon: const Icon(Icons.directions_walk),
                label: Text(index == 0 ? 'Ir ao início' : 'Abrir trecho'),
              ),
            ],
          ),
          _card(items[index]),
        ],
      ],
    );
  }

  int _estimatedMinutes(List<Place> items) {
    var lat = s.lat, lng = s.lng, total = 0;
    for (final p in items) {
      total +=
          p.visitMinutes +
          travelMinutes(tripDistance(lat, lng, p), _travelMode);
      lat = p.lat;
      lng = p.lng;
    }
    return total;
  }

  Widget _map() {
    if (s.offline) {
      return _empty(
        Icons.offline_pin,
        'Mapa indisponível offline',
        'Consulte endereços, horários e paradas na aba Roteiro.',
      );
    }
    if (!Config.maps) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _empty(
            Icons.map_outlined,
            'O mapa precisa de uma chave',
            'Configure Google Maps conforme o README e use MAPS_ENABLED=true. Os locais e os links de rota continuam disponíveis.',
          ),
          ...s.places.map(_card),
        ],
      );
    }
    return GoogleMap(
      key: ValueKey('${s.lat.toStringAsFixed(3)},${s.lng.toStringAsFixed(3)}'),
      initialCameraPosition: CameraPosition(
        target: LatLng(s.lat, s.lng),
        zoom: 13,
      ),
      myLocationEnabled: s.useGps,
      myLocationButtonEnabled: s.useGps,
      markers: s.places
          .map(
            (p) => Marker(
              markerId: MarkerId(p.id),
              position: LatLng(p.lat, p.lng),
              infoWindow: InfoWindow(
                title: p.name,
                snippet: p.category,
                onTap: () => _openById(p.id),
              ),
            ),
          )
          .toSet(),
    );
  }

  Widget _profile() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const CircleAvatar(
        radius: 36,
        child: Icon(Icons.person_outline, size: 38),
      ),
      const SizedBox(height: 14),
      Center(
        child: Text(
          s.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      Center(child: Text(s.email)),
      const SizedBox(height: 28),
      const Text(
        'Seu jeito de explorar',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Usar GPS'),
        subtitle: const Text(
          'Precisão moderada. Acompanhamento apenas com o app aberto.',
        ),
        value: s.useGps,
        onChanged: _gpsBusy || s.offline
            ? null
            : (v) => v ? _gps() : s.disableGps(),
      ),
      if (s.useGps) ...[
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                child: Icon(Icons.gps_fixed_rounded),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GPS conectado',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${s.lat.toStringAsFixed(5)}, ${s.lng.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      s.gpsDetailLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Avisar sobre locais próximos'),
        subtitle: const Text(
          'Até 500 m; intervalo de 6 horas por local. Requer GPS ativo.',
        ),
        value: s.alerts.enabled,
        onChanged: _alertBusy
            ? null
            : (v) async {
                if (!v) {
                  await s.alerts.clear();
                  if (mounted) setState(() {});
                  return;
                }
                setState(() => _alertBusy = true);
                try {
                  final enabled = await s.alerts.enable();
                  if (!enabled) {
                    _snack(
                      'Autorize as notificações nas configurações do dispositivo.',
                    );
                  }
                  if (enabled && s.useGps) await s.refresh();
                } catch (e) {
                  _snack(messageFor(e));
                } finally {
                  if (mounted) setState(() => _alertBusy = false);
                }
              },
      ),
      const SizedBox(height: 12),
      Text('Raio de descoberta: ${(s.radius / 1000).round()} km'),
      Slider(
        value: s.radius / 1000,
        min: 1,
        max: 100,
        divisions: 99,
        label: '${(s.radius / 1000).round()} km',
        onChanged: (v) => setState(() => s.radius = v * 1000),
        onChangeEnd: (_) => s.refresh(),
      ),
      TextButton.icon(
        onPressed: () async {
          try {
            await Geolocator.openAppSettings();
          } catch (e) {
            _snack(messageFor(e));
          }
        },
        icon: const Icon(Icons.settings_outlined),
        label: const Text('Abrir permissões do dispositivo'),
      ),
      if (s.isAdmin && !s.offline)
        ListTile(
          leading: const Icon(Icons.admin_panel_settings_outlined),
          title: const Text('Administrar locais e relatos'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminScreen(state: s)),
          ),
        ),
      ListTile(
        leading: const Icon(Icons.delete_outline),
        title: const Text('Apagar roteiro baixado deste aparelho'),
        onTap: () async {
          final yes = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Apagar cópia offline?'),
              content: const Text(
                'Os dados da sua conta no servidor serão mantidos.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Apagar'),
                ),
              ],
            ),
          );
          if (yes == true) {
            await s.removeOffline();
            _snack('Cópia offline apagada.');
          }
        },
      ),
      const Divider(height: 36),
      if (Config.demo && !s.offline)
        TextButton.icon(
          onPressed: () async {
            try {
              final result = await s.api.request('POST', '/auth/recovery-code');
              if (mounted) {
                await showRecoveryCode(context, result['recoveryCode']);
              }
            } catch (e) {
              _snack(messageFor(e));
            }
          },
          icon: const Icon(Icons.key_outlined),
          label: const Text('Gerar código de recuperação'),
        ),
      const Text(
        'Sobre seus dados',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      const Text(
        'A posição é enviada ao servidor para calcular a proximidade, sem guardar seu histórico de trajetos. Favoritos e avaliações ficam vinculados à sua conta. Desligue o GPS quando quiser.',
      ),
      const SizedBox(height: 12),
      if (Config.demo)
        const Text(
          'Ambiente local: contas e alterações são salvas no computador do servidor. Atrações reais têm fontes oficiais; locais fictícios são sinalizados.',
        ),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        onPressed: () async {
          try {
            await s.signOut();
          } catch (e) {
            _snack(messageFor(e));
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Sair da conta'),
      ),
    ],
  );
  Widget _empty(IconData icon, String title, String body) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
    child: Column(
      children: [
        Icon(icon, size: 52, color: AppColors.muted),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    ),
  );
}
