import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/home/screen/delegates/search_community_delegate.dart';
import 'package:reddit_clone/features/home/screen/drawers/community_list_drawer.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/home/screen/drawers/profile_drawer.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart'; // add if not imported

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(body: Loader());
    }

    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);

    print('User: ${user.name}');
    print('isAuthenticated: ${user.isAuthenticated}');
    print('isGuest: $isGuest');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => displayDrawer(context),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchCommunityDelegate(ref),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {
              Routemaster.of(context).push('/add-post');
            },
            icon: const Icon(Icons.add),
          ),
          Builder(
            builder: (context) {
              return IconButton(
                icon: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic),
                ),
                onPressed: () => displayEndDrawer(context),
              );
            },
          ),
        ],
      ),
      body: Constants.tabWidgets[_page],
      drawer: const CommunityListDrawer(),
      endDrawer: isGuest ? null : const ProfileDrawer(),
      bottomNavigationBar: isGuest || kIsWeb
          ? null
          : CupertinoTabBar(
              activeColor: currentTheme.iconTheme.color,
              backgroundColor: currentTheme.colorScheme.surface,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
              ],
              onTap: onPageChanged,
              currentIndex: _page,
            ),
    );
  }
}
