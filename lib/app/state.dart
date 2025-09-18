import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../mock_data.dart';

class AppState {
  final List<Listing> listings;
  final List<Conversation> conversations;
  final AppUser user;

  final String selectedSchoolId;
  final String? selectedGarmentId;
  final String? selectedSize;

  final bool showOnlyActive;
  final bool priceUnder10;

  AppState({
    required this.listings,
    required this.conversations,
    required this.user,
    required this.selectedSchoolId,
    this.selectedGarmentId,
    this.selectedSize,
    this.showOnlyActive = true,
    this.priceUnder10 = false,
  });

  AppState copyWith({
    List<Listing>? listings,
    List<Conversation>? conversations,
    AppUser? user,
    String? selectedSchoolId,
    String? selectedGarmentId,
    String? selectedSize,
    bool? showOnlyActive,
    bool? priceUnder10,
  }) {
    return AppState(
      listings: listings ?? this.listings,
      conversations: conversations ?? this.conversations,
      user: user ?? this.user,
      selectedSchoolId: selectedSchoolId ?? this.selectedSchoolId,
      selectedGarmentId: selectedGarmentId ?? this.selectedGarmentId,
      selectedSize: selectedSize ?? this.selectedSize,
      showOnlyActive: showOnlyActive ?? this.showOnlyActive,
      priceUnder10: priceUnder10 ?? this.priceUnder10,
    );
  }
}

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return AppState(
      listings: List<Listing>.of(mockListings),
      conversations: List<Conversation>.of(mockConversations),
      user: AppUser(
        id: 'u1',
        email: 'demo@colemaket.app',
        phone: null,
        address: null,
        defaultSchoolId: 'trinity',
      ),
      selectedSchoolId: 'trinity-sanse',
      showOnlyActive: true,
      priceUnder10: false,
    );
  }

  void setSchool(String id) =>
      state = state.copyWith(selectedSchoolId: id, selectedGarmentId: null, selectedSize: null);

  void setGarment(String? id) => state = state.copyWith(selectedGarmentId: id, selectedSize: null);

  void setSize(String? size) => state = state.copyWith(selectedSize: size);

  void toggleFavorite(String listingId) {
    final updated = state.listings
        .map((l) => l.id == listingId ? l.copyWith(isFavorite: !l.isFavorite) : l)
        .toList();
    state = state.copyWith(listings: updated);
  }

  void addListing(Listing listing) =>
      state = state.copyWith(listings: <Listing>[listing, ...state.listings]);

  void updateProfile({String? email, String? phone, String? address}) =>
      state = state.copyWith(
        user: state.user.copyWith(email: email, phone: phone, address: address),
      );

  void toggleShowOnlyActive(bool v) => state = state.copyWith(showOnlyActive: v);

  void togglePriceUnder10(bool v) => state = state.copyWith(priceUnder10: v);
}

final appProvider = NotifierProvider<AppNotifier, AppState>(AppNotifier.new);
