import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    print('🟢 [NAVIGATE] → Create Community screen');
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, Community community) {
    print('🟣 [NAVIGATE] → Community: ${community.name}');
    Routemaster.of(context).push('/r/${community.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🟡 [BUILD] CommunityListDrawer building...');

    final userCommunities = ref.watch(userCommunitiesProvider);
    print('🔵 [PROVIDER] userCommunitiesProvider status: $userCommunities');

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: const Text('Create a community'),
              leading: const Icon(Icons.add),
              onTap: () {
                print('🟠 [ACTION] Create Community tapped');
                navigateToCreateCommunity(context);
              },
            ),
            userCommunities.when(
              data: (communities) {
                print('✅ [DATA] Communities loaded: ${communities.length}');
                for (var c in communities) {
                  print('   → Community: ${c.name} (${c.id})');
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: communities.length,
                    itemBuilder: (BuildContext context, int index) {
                      final community = communities[index];
                      print('🧱 [ITEM] Building tile for ${community.name}');
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(community.avatar),
                        ),
                        title: Text('r/${community.name}'),
                        onTap: () {
                          print('🟢 [TAP] ${community.name} selected');
                          navigateToCommunity(context, community);
                        },
                      );
                    },
                  ),
                );
              },
              error: (error, stackTrace) {
                print('❌ [ERROR] Failed to load communities: $error');
                print('📄 StackTrace: $stackTrace');
                return ErrorText(error: error.toString());
              },
              loading: () {
                print('⏳ [LOADING] Fetching user communities...');
                return const Loader();
              },
            ),
          ],
        ),
      ),
    );
  }
}
