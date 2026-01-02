import 'package:beats_music/theme_data/default.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerLoader.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  });

  const ShimmerLoader.circular({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Default_Theme.primaryColor2.withOpacity(0.1),
      highlightColor: Default_Theme.primaryColor2.withOpacity(0.2),
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Default_Theme.primaryColor2.withOpacity(0.1),
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class SearchSkeleton extends StatelessWidget {
  const SearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const ShimmerLoader.rectangular(
                height: 50,
                width: 50,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoader.rectangular(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.6,
                    ),
                    const SizedBox(height: 8),
                    const ShimmerLoader.rectangular(
                      height: 12,
                      width: 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ExploreSkeleton extends StatelessWidget {
  final String? title;
  const ExploreSkeleton({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 25, bottom: 10),
          child: title != null
              ? Text(
                  title!,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Default_Theme.primaryColor1),
                )
              : const ShimmerLoader.rectangular(height: 24, width: 150),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: 5,
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.only(right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoader.rectangular(height: 140, width: 140),
                    SizedBox(height: 10),
                    ShimmerLoader.rectangular(height: 16, width: 120),
                    SizedBox(height: 5),
                    ShimmerLoader.rectangular(height: 12, width: 80),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
