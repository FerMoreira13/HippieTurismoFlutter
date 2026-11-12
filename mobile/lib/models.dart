class Place {
  static const _localPhotos = <String, String>{
    'igreja-rosario-sao-benedito':
        'assets/places/igreja-rosario-sao-benedito.webp',
    'parque-das-aguas': 'assets/places/parque-das-aguas.jpeg',
    'parque-mae-bonifacia': 'assets/places/parque-mae-bonifacia.jpg',
    'parque-tia-nair': 'assets/places/parque-tia-nair.jpg',
    'museu-caixa-dagua-velha': 'assets/places/museu-caixa-dagua-velha.jpg',
    'chapada-veu-de-noiva': 'assets/places/chapada-veu-de-noiva.jpg',
    'complexo-salgadeira': 'assets/places/complexo-salgadeira.jpg',
    'chapada-mirante-geodesico': 'assets/places/chapada-mirante-geodesico.jpg',
  };
  final String id, name, description, category, address, hours;
  final String? imageAsset;
  final String contact, website, accessibility, status, source;
  final String? verifiedAt;
  final int visitMinutes;
  final double lat, lng, price;
  final double? distance, rating;
  final bool demo, priceKnown;
  final List<Review> reviews;
  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.address,
    required this.hours,
    this.imageAsset,
    this.contact = '',
    this.website = '',
    this.accessibility = 'Informação ainda não verificada.',
    this.status = 'unverified',
    this.source = '',
    this.verifiedAt,
    this.visitMinutes = 60,
    required this.lat,
    required this.lng,
    required this.price,
    this.distance,
    this.rating,
    this.demo = false,
    this.priceKnown = true,
    this.reviews = const [],
  });
  factory Place.fromJson(Map<String, dynamic> j) => Place(
    id: j['id'],
    name: j['name'],
    description: j['description'],
    category: j['category'],
    address: j['address'],
    hours: j['hours'],
    imageAsset: j['imageAsset'] as String? ?? _localPhotos[j['id']],
    contact: j['contact'] ?? '',
    website: j['website'] ?? '',
    accessibility: j['accessibility'] ?? 'Informação ainda não verificada.',
    status: j['status'] ?? 'unverified',
    source: j['source'] ?? '',
    verifiedAt: j['verifiedAt'],
    visitMinutes: j['visitMinutes'] ?? 60,
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    price: (j['price'] as num).toDouble(),
    distance: (j['distance'] as num?)?.toDouble(),
    rating: (j['rating'] as num?)?.toDouble(),
    demo: j['demo'] == true,
    priceKnown: j['priceKnown'] != false,
    reviews: (j['reviews'] as List? ?? [])
        .map((r) => Review.fromJson(r))
        .toList(),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'address': address,
    'hours': hours,
    'imageAsset': imageAsset,
    'lat': lat,
    'lng': lng,
    'price': price,
    'distance': distance,
    'rating': rating,
    'demo': demo,
    'priceKnown': priceKnown,
    'contact': contact,
    'website': website,
    'accessibility': accessibility,
    'status': status,
    'source': source,
    'verifiedAt': verifiedAt,
    'visitMinutes': visitMinutes,
    'reviews': reviews.map((r) => r.toJson()).toList(),
  };
  String get statusLabel => switch (status) {
    'open' => 'Em funcionamento',
    'temporarily_closed' => 'Temporariamente fechado',
    'closed' => 'Fechado',
    _ => 'Funcionamento ainda não verificado',
  };
  String get priceLabel => !priceKnown
      ? 'Valor de entrada a confirmar'
      : price == 0
      ? 'Entrada gratuita'
      : 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
  String get distanceLabel => distance == null
      ? ''
      : distance! < 1000
      ? '${distance!.round()} m'
      : '${(distance! / 1000).toStringAsFixed(1)} km';
}

class Review {
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'comment': comment,
    'rating': rating,
    if (photo != null) 'photo': photo,
    if (visitedOn != null) 'visitedOn': visitedOn,
  };
  final String userId, userName, comment;
  final int rating;
  final String? photo, visitedOn;
  const Review({
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    this.photo,
    this.visitedOn,
  });
  factory Review.fromJson(Map<String, dynamic> j) => Review(
    userId: j['userId'],
    userName: j['userName'],
    comment: j['comment'],
    rating: j['rating'],
    photo: j['photo'],
    visitedOn: j['visitedOn'],
  );
}
