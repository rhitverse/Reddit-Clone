import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;

  SearchCommunityDelegate(this.ref) {
    print('🧩 [INIT] SearchCommunityDelegate created');
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    print('⚙️ [UI] buildActions() called — showing clear icon');
    return [
      IconButton(
        onPressed: () {
          print('🧹 [ACTION] Clear search query');
          query = '';
          showSuggestions(context);
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    print('⬅️ [UI] buildLeading() called — no leading icon');
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    print('📄 [UI] buildResults() called — currently returns empty box');
    return const SizedBox();
  }

  // Replace your entire buildSuggestions() method with this:

@override
Widget buildSuggestions(BuildContext context) {
  print('🔍 [SEARCH] buildSuggestions() called with query: "$query"');

  // Watch the communities provider (get all communities)
  final communitiesResult = ref.watch(userCommunitiesProvider);
  
  return communitiesResult.when(
    data: (communities) {
      print('✅ [DATA] Total communities: ${communities.length}');
      
      // Filter communities based on search query
      final filteredCommunities = query.isEmpty
          ? communities // Show all if query is empty
          : communities.where((community) {
              final communityName = community.name.toLowerCase();
              final searchQuery = query.toLowerCase();
              return communityName.contains(searchQuery);
            }).toList();
      
      print('🔎 [FILTER] Filtered to: ${filteredCommunities.length} communities');
      for (var c in filteredCommunities) {
        print('   → r/${c.name}');
      }

      return ListView.builder(
        itemCount: filteredCommunities.length,
        itemBuilder: (BuildContext context, int index) {
          final community = filteredCommunities[index];
          print('🧱 [ITEM] Building list tile for r/${community.name}');
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(community.avatar),
            ),
            title: Text('r/${community.name}'),
            onTap: () {
              print('🟢 [TAP] User selected community: r/${community.name}');
              navigateToCommunity(context, community.name);
            },
          );
        },
      );
    },
    error: (error, stackTrace) {
      print('❌ [ERROR] Failed to load communities: $error');
      print('📄 StackTrace: $stackTrace');
      return ErrorText(error: error.toString());
    },
    loading: () {
      print('⏳ [LOADING] Loading communities...');
      return const Loader();
    },
  );
}

  void navigateToCommunity(BuildContext context, String communityName) {
    print('🚀 [NAVIGATE] → Navigating to /r/$communityName');
    Routemaster.of(context).push('/r/$communityName');
  }
}
