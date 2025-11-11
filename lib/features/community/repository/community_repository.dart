import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/providers/failure.dart';
import 'package:reddit_clone/core/providers/firebase_provider.dart';
import 'package:reddit_clone/core/providers/type_defs.dart';
import 'package:reddit_clone/models/community_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);

  FutureVoid createCommunity(Community community) async {
    try {
      final communityDoc = await _communities.doc(community.name).get();

      if (communityDoc.exists) {
        return left(Failure('Community with the same name already exists!'));
      }

      await _communities.doc(community.name).set(community.toMap());
      print(
        "✅ Community '${community.name}' created successfully in Firestore",
      );
      return right(null);
    } on FirebaseException catch (e) {
      print("❌ Firebase error: ${e.message}");
      return left(Failure(e.message ?? 'Firebase error occurred'));
    } catch (e) {
      print("❌ Unknown error: $e");
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities.where('members', arrayContains: uid).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => Community.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map((snapshot) {
      return Community.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> searchCommunity(String query) {
    final searchKey = query.toLowerCase().trim();

    // 🔹 Agar query empty hai — sabse popular (ya limited) communities show kar do
    if (searchKey.isEmpty) {
      print("🔍 Empty query — showing first 25 communities");
      return _communities.orderBy('name').limit(25).snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Community.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    }

    // 🔹 Firestore text search using startAt / endAt
    return _communities
        .orderBy('name')
        .startAt([searchKey])
        .endAt([searchKey + '\uf8ff'])
        .snapshots()
        .map((snapshot) {
          final communities = snapshot.docs
              .map(
                (doc) => Community.fromMap(doc.data() as Map<String, dynamic>),
              )
              // local filter (safety in case Firestore index missing)
              .where((c) => c.name.toLowerCase().contains(searchKey))
              .toList();

          print("🔎 Query: '$searchKey' → Found: ${communities.length}");
          for (var c in communities) {
            print("📄 Community: ${c.name}");
          }

          return communities;
        });
  }
}
