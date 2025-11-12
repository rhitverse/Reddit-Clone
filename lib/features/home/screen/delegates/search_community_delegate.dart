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

  @override
  Widget buildSuggestions(BuildContext context) {
    final communitiesResult = ref.watch(allCommunitiesProvider);

    return communitiesResult.when(
      data: (communities) {
        final filteredCommunities = query.isEmpty
            ? communities
            : communities.where((community) {
                final communityName = community.name.toLowerCase();
                final searchQuery = query.toLowerCase();
                return communityName.contains(searchQuery);
              }).toList();

        print(
          '🔎 [FILTER] Filtered to: ${filteredCommunities.length} communities',
        );
        for (var c in filteredCommunities) {
          print('   → r/${c.name}');
        }

        // Show message if no communities found
        if (filteredCommunities.isEmpty) {
          return Center(
            child: Text(
              query.isEmpty
                  ? 'No communities available'
                  : 'No communities found for "$query"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredCommunities.length,
          itemBuilder: (BuildContext context, int index) {
            final community = filteredCommunities[index];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(community.avatar),
              ),
              title: Text('r/${community.name}'),
              onTap: () => navigateToCommunity(context, community.name),
            );
          },
        );
      },
      error: (error, stackTrace) => ErrorText(error: error.toString()),
      loading: () => const Loader(),
    );
  }

  void navigateToCommunity(BuildContext context, String communityName) {
    Routemaster.of(context).push('/r/$communityName');
  }
}
