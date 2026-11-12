import 'dart:convert';
import 'trip_planner.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alerts.dart';
import 'api.dart';
import 'config.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  final Api api;
  final Alerts alerts;
  AppState({Api? api, Alerts? alerts})
    : api = api ?? Api(),
      alerts = alerts ?? Alerts() {
    this.api.token = () async => Config.demo
        ? _demoToken
        : FirebaseAuth.instance.currentUser?.getIdToken();
  }
  String? _demoToken, uid;
  String name = 'Viajante', email = '';
  bool isAdmin = false, offline = false;
  String? recoveryCode, offlineSavedAt;
  final Map<String, Place> offlinePlaces = {};
  bool loading = false, useGps = false, _refreshing = false;
  String? error;
  double lat = -15.5989, lng = -56.0949, radius = 100000;
  int _generation = 0;
  List<Place> places = [], favorites = [];
  Set<String> itineraryIds = {};
  StreamSubscription<Position>? _positions;
  DateTime? _lastFetch;
  DateTime? lastPositionAt;
  double? accuracyMeters;
  bool get signedIn => uid != null;
  String get centerLabel => useGps
      ? '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}'
      : Config.demo
      ? 'Centro fictício • Cuiabá'
      : 'Centro de busca • Cuiabá';
  String get gpsDetailLabel {
    if (!useGps) return 'GPS desligado';
    final accuracy = accuracyMeters == null
        ? 'precisão calculando'
        : 'precisão de ±${accuracyMeters!.round()} m';
    final updated = lastPositionAt == null
        ? 'agora'
        : '${lastPositionAt!.hour.toString().padLeft(2, '0')}:${lastPositionAt!.minute.toString().padLeft(2, '0')}';
    return '$accuracy • atualizado às $updated';
  }

  Future<void> restore() async {
    if (Config.demo || FirebaseAuth.instance.currentUser == null) return;
    await _profile();
    await refresh();
  }

  Future<void> _profile() async {
    final p = await api.request('GET', '/me');
    uid = p['uid'];
    isAdmin = p['admin'] == true;
    name = p['name'];
    email = p['email'] ?? '';
    await _loadItinerary();
    notifyListeners();
  }

  Future<void> authenticate(
    String email,
    String password, {
    String? name,
  }) async {
    offline = false;
    api.readOnly = false;
    if (Config.demo) {
      final result = await api.request(
        'POST',
        name == null ? '/auth/login' : '/auth/register',
        body: {'email': email, 'password': password, 'name': ?name},
      );
      _demoToken = result['token'];
      recoveryCode = result['recoveryCode'];
    } else {
      if (name == null) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        await result.user!.updateDisplayName(name);
        await result.user!.getIdToken(true);
      }
    }
    await _profile();
    await refresh();
  }

  Future<void> refresh() async {
    if (offline) {
      error =
          'Modo offline: consulte os dados salvos ou saia e entre com conexão.';
      notifyListeners();
      return;
    }
    if (!signedIn || _refreshing) return;
    _refreshing = true;
    loading = true;
    error = null;
    notifyListeners();
    final generation = _generation;
    try {
      final results = await Future.wait([
        api.request(
          'GET',
          '/places?lat=$lat&lng=$lng&radius=${radius.round()}',
        ),
        api.request('GET', '/favorites'),
      ]);
      if (generation != _generation) return;
      places = (results[0] as List).map((p) => Place.fromJson(p)).toList();
      favorites = (results[1] as List).map((p) => Place.fromJson(p)).toList();
      if (Config.demo) await _saveInitialDemoDestination(generation);
      // O centro demonstrativo nunca dispara notificações de localização real.
      if (useGps) await alerts.check(places, uid!);
    } catch (e) {
      if (generation == _generation) error = messageFor(e);
    } finally {
      _refreshing = false;
      loading = false;
      notifyListeners();
    }
  }

  String get _itineraryKey => 'itinerary_${uid ?? 'visitor'}';
  Future<void> _saveInitialDemoDestination(int generation) async {
    final key = 'demo_saved_destination_$uid';
    final prefs = await SharedPreferences.getInstance();
    if (generation != _generation || prefs.getBool(key) == true) return;
    if (favorites.isEmpty) {
      if (places.isEmpty) return;
      final destination = places.first;
      await api.request('PUT', '/favorites/${destination.id}');
      if (generation != _generation) return;
      if (!isFavorite(destination.id)) favorites.add(destination);
    }
    await prefs.setBool(key, true);
  }

  List<Place> get itineraryPlaces {
    final available = {
      for (final p in [...offlinePlaces.values, ...favorites, ...places])
        p.id: p,
    };
    return [
      for (final id in itineraryIds)
        if (available[id] != null) available[id]!,
    ];
  }

  Future<void> generateItinerary({
    double budget = double.infinity,
    int minutes = 100000,
    String mode = 'walking',
  }) async {
    if (places.isEmpty) return;
    final selected = planTrip(
      places,
      lat,
      lng,
      budget: budget,
      minutes: minutes,
      mode: mode,
    );
    if (selected.isEmpty) {
      throw const ApiError(
        'Nenhum passeio cabe nesse tempo e orçamento. Tente aumentar os limites.',
      );
    }
    itineraryIds = selected.map((p) => p.id).toSet();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_itineraryKey, itineraryIds.toList());
    notifyListeners();
  }

  Future<Place> loadPlace(String id) async {
    if (offline) {
      final place = offlinePlaces[id];
      if (place == null) {
        throw const ApiError(
          'Este local não foi baixado. Entre com conexão e salve o roteiro offline.',
        );
      }
      return place;
    }
    return Place.fromJson(await api.request('GET', '/places/$id'));
  }

  Future<void> saveOffline() async {
    final selection = {
      for (final p in [...itineraryPlaces, ...favorites]) p.id: p,
    };
    if (selection.isEmpty) {
      throw const ApiError(
        'Adicione locais ao roteiro ou aos salvos primeiro.',
      );
    }
    final details = <Place>[];
    for (final p in selection.values) {
      details.add(await loadPlace(p.id));
    }
    final prefs = await SharedPreferences.getInstance();
    final at = DateTime.now().toIso8601String();
    await prefs.setString(
      'offline_trip',
      jsonEncode({
        'uid': uid,
        'name': name,
        'email': email,
        'savedAt': at,
        'places': details.map((p) => p.toJson()).toList(),
        'favorites': favorites.map((p) => p.id).toList(),
        'itinerary': itineraryIds.toList(),
      }),
    );
    offlineSavedAt = at;
    notifyListeners();
  }

  Future<void> openOffline() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('offline_trip');
    if (raw == null) {
      throw const ApiError(
        'Nenhum roteiro foi baixado neste aparelho. Entre na conta e use Salvar para usar offline.',
      );
    }
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final saved = (data['places'] as List)
        .map((p) => Place.fromJson(p))
        .toList();
    offlinePlaces.clear();
    offlinePlaces.addAll({for (final p in saved) p.id: p});
    _demoToken = null;
    isAdmin = false;
    offline = true;
    api.readOnly = true;
    uid = data['uid'];
    name = data['name'];
    email = data['email'];
    offlineSavedAt = data['savedAt'];
    places = saved;
    favorites = saved
        .where((p) => (data['favorites'] as List).contains(p.id))
        .toList();
    itineraryIds = (data['itinerary'] as List).cast<String>().toSet();
    error = null;
    notifyListeners();
  }

  Future<void> removeOffline() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('offline_trip');
    offlineSavedAt = null;
    if (offline) {
      await signOut();
    } else {
      notifyListeners();
    }
  }

  Future<String?> recoverPassword(
    String email, {
    String? code,
    String? password,
  }) async {
    if (!Config.demo) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null;
    }
    final result = await api.request(
      'POST',
      '/auth/recover',
      body: {'email': email, 'password': password, 'recoveryCode': code},
    );
    return result['recoveryCode'] as String?;
  }

  Future<void> _loadItinerary() async {
    final prefs = await SharedPreferences.getInstance();
    itineraryIds = (prefs.getStringList(_itineraryKey) ?? []).toSet();
  }

  bool isInItinerary(String id) => itineraryIds.contains(id);

  Future<void> toggleItinerary(Place p) async {
    if (!itineraryIds.add(p.id)) itineraryIds.remove(p.id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_itineraryKey, itineraryIds.toList());
    notifyListeners();
  }

  Future<void> clearItinerary() async {
    itineraryIds.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_itineraryKey);
    notifyListeners();
  }

  bool isFavorite(String id) => favorites.any((p) => p.id == id);
  Future<void> toggleFavorite(Place p) async {
    final was = isFavorite(p.id);
    await api.request(was ? 'DELETE' : 'PUT', '/favorites/${p.id}');
    if (was) {
      favorites.removeWhere((x) => x.id == p.id);
    } else {
      if (!isFavorite(p.id)) favorites.add(p);
    }
    notifyListeners();
  }

  Future<void> enableGps() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const ApiError(
        'Ative a localização nas configurações do dispositivo.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const ApiError(
        'Permissão bloqueada. Abra as configurações do aplicativo para permitir localização.',
      );
    }
    if (permission == LocationPermission.denied) {
      throw const ApiError(
        'A localização não foi autorizada. Você pode continuar explorando pelo centro de busca.',
      );
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
    useGps = true;
    lat = p.latitude;
    lng = p.longitude;
    accuracyMeters = p.accuracy;
    lastPositionAt = DateTime.now();
    _lastFetch = lastPositionAt;
    await refresh();
    resumeGps();
    notifyListeners();
  }

  void resumeGps() {
    if (!signedIn || !useGps || _positions != null) return;
    _positions =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 100,
          ),
        ).listen(
          (p) {
            lat = p.latitude;
            lng = p.longitude;
            accuracyMeters = p.accuracy;
            lastPositionAt = DateTime.now();
            notifyListeners();
            if (_lastFetch == null ||
                DateTime.now().difference(_lastFetch!) >=
                    const Duration(seconds: 20)) {
              _lastFetch = DateTime.now();
              unawaited(refresh());
            }
          },
          onError: (Object e) {
            error =
                'O GPS está indisponível. Tente ativar a localização novamente.';
            useGps = false;
            pauseGps();
            notifyListeners();
          },
        );
  }

  Future<void> syncGpsStatus() async {
    if (!signedIn || !useGps) return;
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    final allowed =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    if (!serviceEnabled || !allowed) {
      pauseGps();
      useGps = false;
      accuracyMeters = null;
      lastPositionAt = null;
      error = !serviceEnabled
          ? 'O GPS foi desligado no dispositivo.'
          : 'A permissão de localização foi removida.';
      notifyListeners();
      return;
    }
    error = null;
    resumeGps();
    notifyListeners();
  }

  void pauseGps() {
    unawaited(_positions?.cancel());
    _positions = null;
  }

  void disableGps() {
    pauseGps();
    useGps = false;
    lat = -15.5989;
    lng = -56.0949;
    accuracyMeters = null;
    lastPositionAt = null;
    notifyListeners();
    unawaited(refresh());
  }

  Future<void> signOut() async {
    _generation++;
    pauseGps();
    useGps = false;
    accuracyMeters = null;
    lastPositionAt = null;
    try {
      await api.request('POST', '/auth/logout');
    } catch (_) {
      /* A saída local continua disponível sem rede. */
    }
    if (!Config.demo) await FirebaseAuth.instance.signOut();
    await alerts.clear();
    _demoToken = null;
    offline = false;
    api.readOnly = false;
    isAdmin = false;
    offlinePlaces.clear();
    uid = null;
    places = [];
    favorites = [];
    itineraryIds = {};
    error = null;
    name = 'Viajante';
    email = '';
    lat = -15.5989;
    lng = -56.0949;
    notifyListeners();
  }

  @override
  void dispose() {
    pauseGps();
    api.close();
    super.dispose();
  }
}

String messageFor(Object e) {
  if (e is FirebaseAuthException) {
    return switch (e.code) {
      'invalid-email' => 'Informe um e-mail válido.',
      'email-already-in-use' => 'Este e-mail já está cadastrado.',
      'weak-password' => 'Escolha uma senha mais forte.',
      'network-request-failed' => 'Verifique sua conexão com a internet.',
      'too-many-requests' => 'Muitas tentativas. Aguarde e tente novamente.',
      _ =>
        'Não foi possível entrar. Confira e-mail, senha e configuração do Firebase.',
    };
  }
  return e is ApiError
      ? e.message
      : 'Não foi possível concluir. Tente novamente.';
}
