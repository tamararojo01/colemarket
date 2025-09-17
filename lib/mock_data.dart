import 'models.dart';

final schools = <School>[
  School(id: 'trinity', name: 'Trinity College', city: 'Madrid', garments: [
    Garment(id: 'polo', label: 'Polo', sizes: ['6', '8', '10', '12', 'S', 'M', 'L']),
    Garment(id: 'camisa', label: 'Camisa', sizes: ['6', '8', '10', '12']),
    Garment(id: 'falda', label: 'Falda', sizes: ['6', '8', '10', '12']),
    Garment(id: 'pantalon', label: 'Pantalón', sizes: ['6', '8', '10', '12', 'S', 'M']),
    Garment(id: 'sudadera', label: 'Sudadera', sizes: ['S', 'M', 'L']),
  ]),
];

final mockListings = <Listing>[
  Listing.sample(title: 'Polo', schoolId: 'trinity', garmentId: 'polo', size: '10', price: 7.0, condition: Condition.likeNew),
  Listing.sample(title: 'Camisa', schoolId: 'trinity', garmentId: 'camisa', size: '8', price: 6.0, condition: Condition.good, defects: ['Pequeña mancha cuello']),
  Listing.sample(title: 'Falda', schoolId: 'trinity', garmentId: 'falda', size: '10', price: 8.0, condition: Condition.newItem),
];

final mockConversations = <Conversation>[
  Conversation(
    id: 'c1',
    otherUserName: 'Laura',
    lastMessage: '¿Sigue disponible la falda?',
    timestampMs: DateTime.now().millisecondsSinceEpoch - 3600000,
  ),
  Conversation(
    id: 'c2',
    otherUserName: 'Carlos',
    lastMessage: 'Perfecto, nos vemos en la puerta del cole.',
    timestampMs: DateTime.now().millisecondsSinceEpoch - 7200000,
  ),
];
