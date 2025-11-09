import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/home/screen/drawers/community_list_drawer.dart';
import 'package:reddit_clone/core/common/loader.dart'; // add if not imported

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    // ✅ FIX: check null before using it
    if (user == null) {
      return const Scaffold(
        body: Loader(), // you can use CircularProgressIndicator() instead
      );
    }

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
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(
            icon: CircleAvatar(backgroundImage: NetworkImage(user.profilePic)),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const CommunityListDrawer(),
      body: const Center(child: Text('Welcome to Reddit Clone!')),
    );
  }
}
