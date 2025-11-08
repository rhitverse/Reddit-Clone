import 'dart:ui' as BorderType;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/theme/pallete.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<EditCommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return ref
        .watch(getCommunityByNameProvider(widget.name))
        .when(
          data: (community) => Scaffold(
            backgroundColor: Pallete.darkModeAppTheme.colorScheme.surface,
            appBar: AppBar(
              title: const Text('Edit Community'),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                DottedBorder(
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        community.banner.isEmpty ||
                            community.banner == Constants.bannerDefault
                        ? const Center(
                            child: Icon(Icons.camera_alt_outlined, size: 40),
                          )
                        : Image.network(community.banner),
                  ),
                ),
              ],
            ),
          ),
          loading: () => const Loader(),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
        );
  }
}
