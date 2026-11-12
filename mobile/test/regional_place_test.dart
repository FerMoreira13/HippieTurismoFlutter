import 'package:flutter_test/flutter_test.dart';
import 'package:hippie_turismo/models.dart';
import 'package:hippie_turismo/trip_planner.dart';

void main() {
  test(
    'preço não confirmado continua sinalizado após salvar para consulta offline',
    () {
      final place = Place.fromJson({
        'id': 'parque',
        'name': 'Parque',
        'description': 'Local real',
        'category': 'Natureza',
        'address': 'Cuiabá',
        'hours': 'Consultar',
        'lat': -15.5,
        'lng': -56.0,
        'price': 0,
        'priceKnown': false,
      });
      expect(place.priceLabel, 'Valor de entrada a confirmar');
      expect(Place.fromJson(place.toJson()).priceLabel, place.priceLabel);
      expect(planTrip([place], place.lat, place.lng, budget: 20), isEmpty);
      expect(planTrip([place], place.lat, place.lng), [place]);
    },
  );
}
