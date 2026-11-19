import 'package:flutter/material.dart';

/// Lightweight, high-performance shimmer effect widget without external dependencies.
/// Uses a continuous [AnimationController] with linear gradient sweep to create
/// smooth 60 FPS skeleton loading states optimized for budget Android devices.
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE2E8F0),
    this.highlightColor = const Color(0xFFF8FAFC),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              stops: const [0.1, 0.5, 0.9],
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

/// Skeleton placeholder box with customizable dimensions and border radius.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer skeleton list simulating [ProjectCard] items during initial load.
class ProjectsShimmerList extends StatelessWidget {
  final int count;

  const ProjectsShimmerList({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF4F46E5),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Fetching latest projects...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ShimmerLoading(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count,
              itemBuilder: (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ShimmerBox(width: 48, height: 48, borderRadius: 14),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(
                                width: 160, height: 16, borderRadius: 6),
                            SizedBox(height: 8),
                            ShimmerBox(
                                width: 100, height: 12, borderRadius: 4),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                ShimmerBox(
                                    width: 70, height: 18, borderRadius: 6),
                                SizedBox(width: 6),
                                ShimmerBox(
                                    width: 55, height: 18, borderRadius: 6),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      ShimmerBox(width: 72, height: 38, borderRadius: 12),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Shimmer skeleton list simulating [EarningTile] items during initial load.
class EarningsShimmerList extends StatelessWidget {
  final int count;

  const EarningsShimmerList({super.key, this.count = 8});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: count,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Row(
              children: [
                ShimmerBox(width: 40, height: 40, borderRadius: 10),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 180, height: 15, borderRadius: 4),
                      SizedBox(height: 6),
                      ShimmerBox(width: 90, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                ShimmerBox(width: 65, height: 20, borderRadius: 6),
              ],
            ),
          );
        },
      ),
    );
  }
}
