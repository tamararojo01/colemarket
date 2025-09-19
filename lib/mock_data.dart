import 'models.dart';

final schools = <School>[
  School(
    id: 'trinity',
    name: 'Trinity',
    garments: [
      Garment(id: 'polo', label: 'Polo', sizes: ['6', '8', '10', '12', 'S', 'M', 'L']),
      Garment(id: 'falda', label: 'Falda', sizes: ['6', '8', '10', '12']),
      Garment(id: 'pantalon', label: 'Pantalón', sizes: ['6', '8', '10', '12', 'S', 'M', 'L']),
      Garment(id: 'jersey', label: 'Jersey', sizes: ['6', '8', '10', '12', 'S', 'M', 'L']),
    ],
  ),
  School(
    id: 'alcala',
    name: 'Alcalá',
    garments: [
      Garment(id: 'polo', label: 'Polo', sizes: ['6', '8', '10', '12', 'S', 'M', 'L']),
      Garment(id: 'pichi', label: 'Pichi', sizes: ['6', '8', '10', '12']),
      Garment(id: 'chandal', label: 'Chándal', sizes: ['6', '8', '10', '12', 'S', 'M', 'L']),
    ],
  ),
];

final mockListings = <Listing>[
  Listing(
    id: 'l1',
    userId: 'u2',
    schoolId: 'trinity-sanse',
    garmentId: 'polo',
    title: 'Polo blanco',
    size: '10',
    price: 8.0,
    condition: Condition.good,
    defects: const [],
    active: true,
    isFavorite: false,
  ),
  Listing(
    id: 'l2',
    userId: 'u3',
    schoolId: 'trinity-sanse',
    garmentId: 'falda',
    title: 'Falda tablas',
    size: '12',
    price: 9.5,
    condition: Condition.fair,
    defects: const ['Pequeña mancha'],
    active: true,
    isFavorite: true,
  ),
  Listing(
    id: 'l3',
    userId: 'u4',
    schoolId: 'trinity-sanse',
    garmentId: 'chandal',
    title: 'Chándal completo',
    size: 'M',
    price: 14.0,
    condition: Condition.good,
    defects: const [],
    active: true,
    isFavorite: false,
  ),
];

final mockConversations = <Conversation>[
  Conversation(id: 'c1', otherUserName: 'Laura', lastMessage: '¿Sigue disponible?'),
  Conversation(id: 'c2', otherUserName: 'Marta', lastMessage: 'Te escribo por el polo.'),
];
