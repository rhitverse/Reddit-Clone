import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/providers/failure.dart';
import 'package:reddit_clone/core/providers/firebase_provider.dart';
import 'package:reddit_clone/core/providers/type_defs.dart';
import 'package:reddit_clone/models/community_model.dart';

final communityRepositoryProvider = Provider((ref) {
  print('🧩 [INIT] CommunityRepository provider initialized');
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore {
    print('🧱 [INIT] CommunityRepository instance created');
  }

  // 🟢 CREATE COMMUNITY
  FutureVoid createCommunity(Community community) async {
    print('🚀 [CREATE] Attempting to create community: ${community.name}');
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        print('⚠️ [DUPLICATE] Community "${community.name}" already exists!');
        throw 'Community with the same name already exists!';
      }

      await _communities.doc(community.name).set(community.toMap());
      print('✅ [SUCCESS] Community "${community.name}" created successfully!');
      return right(null);
    } on FirebaseException catch (e) {
      print('❌ [FIREBASE ERROR] ${e.message}');
      throw e.message!;
    } catch (e) {
      print('❌ [ERROR] createCommunity failed: $e');
      return left(Failure(e.toString()));
    }
  }

  // 🔵 GET USER COMMUNITIES
  Stream<List<Community>> getUserCommunities(String uid) {
    print('📡 [STREAM] Listening for communities of user: $uid');
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      print('📦 [DATA] Received ${event.docs.length} community docs for user');
      List<Community> communities = [];
      for (var doc in event.docs) {
        print('   → Found: ${doc.id}');
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  // 🟣 GET COMMUNITY BY NAME
  Stream<Community> getCommunityByName(String name) {
    print('🔍 [QUERY] Listening to community: $name');
    return _communities.doc(name).snapshots().map((event) {
      if (!event.exists) {
        print('⚠️ [NOT FOUND] Community "$name" does not exist');
      } else {
        print('✅ [FOUND] Community data fetched for "$name"');
      }
      return Community.fromMap(event.data() as Map<String, dynamic>);
    });
  }

  // 🟠 EDIT COMMUNITY
  FutureVoid editCommunity(Community community) async {
    print('🛠️ [UPDATE] Editing community: ${community.name}');
    try {
      await _communities.doc(community.name).update(community.toMap());
      print('✅ [SUCCESS] Community "${community.name}" updated');
      return right(null);
    } on FirebaseException catch (e) {
      print('❌ [FIREBASE ERROR] ${e.message}');
      throw e.message!;
    } catch (e) {
      print('❌ [ERROR] editCommunity failed: $e');
      return left(Failure(e.toString()));
    }
  }

  // 🧠 SEARCH COMMUNITY
  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var community in event.docs) {
        communities.add(Community.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  // 🧩 COLLECTION REFERENCE
  CollectionReference get _communities {
    print('📁 [REF] Accessing communities collection');
    return _firestore.collection(FirebaseConstants.communitiesCollection);
  }
}
