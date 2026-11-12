import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippie_turismo/api.dart';
import 'package:hippie_turismo/app_state.dart';
import 'package:hippie_turismo/models.dart';
import 'package:hippie_turismo/trip_planner.dart';
import 'package:hippie_turismo/travel_actions.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Place place(
  String id, {
  double price = 0,
  double lng = 0,
  int minutes = 60,
  String status = 'open',
}) => Place(
  id: id,
  name: id,
  description: 'Um passeio de teste.',
  category: 'Natureza',
  address: 'Endereço de teste',
  hours: '8h às 17h',
  lat: 0,
  lng: lng,
  price: price,
  visitMinutes: minutes,
  status: status,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'roteiro respeita tempo, orçamento e fechamento sem incluir duplicatas',
    () {
      final items = [
        place('caro', price: 500),
        place('fechado', status: 'closed'),
        place('curto', price: 10, minutes: 30),
        place('curto', price: 10, minutes: 30),
        place('longo', minutes: 120),
        place('perto', price: 5, lng: .001, minutes: 20),
      ];
      final trip = planTrip(items, 0, 0, budget: 20, minutes: 60);
      expect(trip.map((p) => p.id), ['curto', 'perto']);
      expect(
        trip.fold<double>(0, (s, p) => s + p.price),
        lessThanOrEqualTo(20),
      );
      expect(planTrip(items, 0, 0, budget: 0, minutes: 10), isEmpty);
      expect(
        travelMinutes(10000, 'driving'),
        lessThan(travelMinutes(10000, 'walking')),
      );
    },
  );
  test('links preservam destino, origem e transporte', () {
    final uri = routeUri(
      place('destino', lng: 1),
      origin: place('origem'),
      mode: 'transit',
    );
    expect(uri.queryParameters['travelmode'], 'transit');
    expect(uri.queryParameters['destination'], '0.0,1.0');
    expect(uri.queryParameters['origin'], '0.0,0.0');
  });
  test(
    'roteiro baixado funciona após reabrir, com API indisponível e alterações bloqueadas',
    () async {
      final destination = place('museu');
      var calls = 0;
      final state =
          AppState(
              api: Api(
                client: MockClient((request) async {
                  calls++;
                  return http.Response(jsonEncode(destination.toJson()), 200);
                }),
              ),
            )
            ..uid = 'traveler'
            ..name = 'Viajante'
            ..email = 'teste@example.com'
            ..places = [destination]
            ..itineraryIds = {'museu'};
      await state.saveOffline();
      state.dispose();
      final offline = AppState(
        api: Api(
          client: MockClient((_) async {
            calls++;
            throw http.ClientException('sem rede');
          }),
        ),
      );
      await offline.openOffline();
      expect(offline.offline, isTrue);
      expect(offline.isAdmin, isFalse);
      expect(offline.itineraryPlaces.single.id, 'museu');
      expect((await offline.loadPlace('museu')).hours, '8h às 17h');
      await expectLater(
        offline.api.request('PUT', '/favorites/museu'),
        throwsA(isA<ApiError>()),
      );
      expect(calls, 1);
      offline.dispose();
    },
  );
}
