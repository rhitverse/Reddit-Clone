import 'package:flutter/material.dart';
import 'package:reddit_clone/features/community/screens/community_screen.dart';
import 'package:reddit_clone/features/community/screens/create_community_screens.dart';
import 'package:reddit_clone/features/community/screens/edit_community_screen.dart';
import 'package:reddit_clone/features/community/screens/mod_tools_screen.dart';
import 'package:reddit_clone/features/home/screen/home_screen.dart';
import 'package:reddit_clone/screen/login_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(
  routes: {'/': (_) => const MaterialPage(child: LoginScreen())},
);

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: HomeScreen()),
    '/create-community': (_) => MaterialPage(child: CreateCommunityScreens()),
    '/r/:name': (route) => MaterialPage(
      child: CommunityScreen(name: route.pathParameters['name']!),
    ),
    '/mod-tools/:name': (routeData) => MaterialPage(
      child: ModToolsScreen(name: routeData.pathParameters['name']!),
    ),
    '/edit-community/:name': (routeData) => MaterialPage(
      child: EditCommunityScreen(name: routeData.pathParameters['name']!),
    ),
  },
);
