import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippie_turismo/app_state.dart';
import 'package:hippie_turismo/main.dart';
import 'package:hippie_turismo/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

Place stop(String id, double lng) => Place(
  id: id,
  name: id,
  description: '',
  category: 'Cultura',
  address: '',
  hours: '8h às 18h',
  lat: 0,
  lng: lng,
  price: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'inclui todos uma vez, segue proximidade e salva a ordem por conta',
    () async {
      final state = AppState()
        ..uid = 'traveler'
        ..lat = 0
        ..lng = 0
        ..places = [
          stop('oeste', -1.5),
          stop('leste', 2),
          stop('inicio', 1),
          stop('inicio', 1),
        ];
      addTearDown(state.dispose);
      await state.generateItinerary();
      expect(state.itineraryPlaces.map((p) => p.id), [
        'inicio',
        'leste',
        'oeste',
      ]);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('itinerary_traveler'), [
        'inicio',
        'leste',
        'oeste',
      ]);
      state.places = state.places.reversed.toList();
      expect(state.itineraryPlaces.map((p) => p.id), [
        'inicio',
        'leste',
        'oeste',
      ]);
      await state.toggleItinerary(stop('leste', 2));
      expect(state.itineraryPlaces.map((p) => p.id), ['inicio', 'oeste']);
      await state.clearItinerary();
      expect(state.itineraryPlaces, isEmpty);
      expect(prefs.getStringList('itinerary_traveler'), isNull);
    },
  );

  test('catálogo vazio não apaga uma seleção existente', () async {
    final state = AppState()..itineraryIds = {'saved'};
    addTearDown(state.dispose);
    await state.generateItinerary();
    expect(state.itineraryIds, {'saved'});
  });

  testWidgets('cria roteiro pela interface em tela pequena', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppState()
      ..uid = 'traveler'
      ..lat = 0
      ..lng = 0
      ..places = [stop('Museu', 0.001), stop('Praça', 0.002)];
    addTearDown(state.dispose);
    await tester.pumpWidget(HippieApp(state: state));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Roteiro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Planejar por tempo e orçamento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Criar roteiro'));
    await tester.pumpAndSettle();
    expect(find.text('2 paradas'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Parada 1'), 200, scrollable:find.byType(Scrollable).first);
    expect(find.text('Parada 1'), findsOneWidget);
    expect(find.text('Ir ao início'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
