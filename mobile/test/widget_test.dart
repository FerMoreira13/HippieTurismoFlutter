import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippie_turismo/api.dart';
import 'package:hippie_turismo/app_state.dart';
import 'package:hippie_turismo/main.dart';
import 'package:hippie_turismo/nearby_policy.dart';
import 'package:hippie_turismo/screens/place_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const fixture = {
  'id': 'cachoeira-serena',
  'name': 'Cachoeira Serena',
  'description': 'Um jardim fictício para testes de apresentação.',
  'category': 'Natureza',
  'address': 'Circuito fictício',
  'hours': '8h às 18h',
  'lat': -15.5989,
  'lng': -56.0949,
  'price': 0,
  'distance': 0,
  'demo': true,
};

class FakeApi extends Api {
  final saved = <Map<String, dynamic>>[];
  final reviews = <Map<String, dynamic>>[];
  @override
  Future<dynamic> request(String method, String path, {Object? body}) async {
    if (path == '/me') {
      return {
        'uid': 'tester',
        'name': 'Viajante Teste',
        'email': 'teste@example.com',
      };
    }
    if (path == '/auth/register' || path == '/auth/login') {
      return {'token': 'test-token'};
    }
    if (path == '/favorites') return List.of(saved);
    if (path.startsWith('/favorites/')) {
      if (method == 'PUT') {
        saved.add(fixture);
      } else {
        saved.clear();
      }
      return null;
    }
    if (path.startsWith('/restaurants?')) {
      return {'items': [], 'source': 'catalog'};
    }
    if (path.endsWith('/review')) {
      final r = body as Map<String, dynamic>;
      reviews.clear();
      reviews.add({...r, 'userId': 'tester', 'userName': 'Viajante Teste'});
      return null;
    }
    if (path == '/places/cachoeira-serena') {
      return {
        ...fixture,
        'reviews': List.of(reviews),
        'rating': reviews.isEmpty ? null : reviews.first['rating'],
      };
    }
    if (path.startsWith('/places?')) return [fixture];
    return null;
  }
}

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_QA')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('capture')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('build/qa/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'demo salva um destino e respeita sua remoção após recarregar',
    () async {
      final api = FakeApi();
      final state = AppState(api: api);
      addTearDown(state.dispose);
      await state.authenticate('teste@example.com', 'senha1234');
      expect(state.favorites.single.id, fixture['id']);
      expect(api.saved.single['id'], fixture['id']);
      await state.toggleFavorite(state.favorites.single);
      await state.refresh();
      expect(state.favorites, isEmpty);
      await state.signOut();
      await state.authenticate('teste@example.com', 'senha1234');
      expect(state.favorites, isEmpty);
    },
  );
  setUpAll(() async {
    if (!const bool.fromEnvironment('CAPTURE_QA')) return;
    const path = '../../../work/flutter-sdk/bin/cache/artifacts/material_fonts';
    for (final entry in {
      'Roboto': 'roboto-regular.ttf',
      'MaterialIcons': 'materialicons-regular.otf',
    }.entries) {
      final loader = FontLoader(entry.key);
      loader.addFont(
        File(
          '$path/${entry.value}',
        ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
      );
      await loader.load();
    }
  });
  test(
    'alertas respeitam distância, consentimento aplicado no serviço e intervalo',
    () {
      const p = NearbyPolicy();
      final now = DateTime(2026, 9, 3, 12);
      expect(p.shouldNotify(distance: 500, now: now), isTrue);
      expect(p.shouldNotify(distance: 501, now: now), isFalse);
      expect(
        p.shouldNotify(
          distance: 10,
          now: now,
          last: now.subtract(const Duration(hours: 5)),
        ),
        isFalse,
      );
      expect(
        p.shouldNotify(
          distance: 10,
          now: now,
          last: now.subtract(const Duration(hours: 6)),
        ),
        isTrue,
      );
      expect(p.shouldNotify(distance: double.nan, now: now), isFalse);
    },
  );
  testWidgets('cadastro apresenta validação e interface sem transbordar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppState(api: FakeApi());
    addTearDown(state.dispose);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('capture'),
        child: HippieApp(state: state),
      ),
    );
    await tester.pumpAndSettle();
    await capture(tester, 'login');
    await tester.ensureVisible(find.text('Entrar e explorar'));
    await tester.tap(find.text('Entrar e explorar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(find.text('Use pelo menos 8 caracteres.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('explorar, salvar, abrir detalhes e publicar avaliação', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppState(api: FakeApi());
    addTearDown(state.dispose);
    await state.authenticate('teste@example.com', 'senha1234');
    await state.toggleFavorite(state.favorites.single);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('capture'),
        child: HippieApp(state: state),
      ),
    );
    await tester.pumpAndSettle();
    await capture(tester, 'explorar');
    expect(find.text('Próximas descobertas'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byTooltip('Salvar local'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byTooltip('Salvar local'));
    await tester.pumpAndSettle();
    expect(state.favorites.length, 1);
    await tester.tap(find.byTooltip('Adicionar ao roteiro'));
    await tester.pumpAndSettle();
    expect(state.itineraryPlaces.length, 1);
    await tester.tap(find.text('Roteiro'));
    await tester.pumpAndSettle();
    expect(find.text('1 parada'), findsOneWidget);
    await tester.tap(find.text('Salvos'));
    await tester.pumpAndSettle();
    expect(find.text('Cachoeira Serena'), findsOneWidget);
    await tester.tap(find.text('Cachoeira Serena'));
    await tester.pumpAndSettle();
    await capture(tester, 'detalhes');
    await tester.scrollUntilVisible(
      find.text('Avaliar'),
      400,
      scrollable: find
          .descendant(
            of: find.byType(PlaceScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(find.text('Avaliar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Avaliar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField),
      'Gostei da experiência de teste.',
    );
    await tester.tap(find.text('Salvar avaliação'));
    await tester.pumpAndSettle();
    expect(
      (state.api as FakeApi).reviews.single['comment'],
      'Gostei da experiência de teste.',
    );
    expect(find.text('Editar avaliação'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
