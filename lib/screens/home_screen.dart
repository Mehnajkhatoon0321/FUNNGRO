import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/utils/responsive_layout.dart';
import 'earnings_screen.dart';
import 'projects_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveLayout.horizontalPadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/funngro_logo.jpg',
                  height: 32,
                  width: 54,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Text(
                      'funngro',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      ' .',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
                Text(
                  'ENGINEERING ASSESSMENT',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ResponsiveLayout.constrainedBody(
          context,
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 18.0,
            ),
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4338CA),
                      Color(0xFF6366F1),
                      Color(0xFF7C3AED),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: Colors.amberAccent,
                                size: 13,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Mobile Engineer Candidate',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.35),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Text(
                            '19/19 Tests Passing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      AppStrings.assessmentTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Engineered for 800-3,000 items & flaky APIs on ₹8,000 budget Android phones (Impeller 60 FPS).',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Architectural Highlights Scroll Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFeatureChip(
                      icon: Icons.speed_rounded,
                      label: '60 FPS Impeller',
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    _buildFeatureChip(
                      icon: Icons.memory_rounded,
                      label: 'Zero OOM Killer',
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 8),
                    _buildFeatureChip(
                      icon: Icons.stream_rounded,
                      label: 'WebSocket Sync',
                      color: const Color(0xFF0EA5E9),
                    ),
                    const SizedBox(width: 8),
                    _buildFeatureChip(
                      icon: Icons.layers_rounded,
                      label: 'BLoC Pattern',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section Title
              const Row(
                children: [
                  Icon(
                    Icons.widgets_rounded,
                    size: 18,
                    color: Color(0xFF4F46E5),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Interactive Implementations',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Part 1 Card
              _buildDemoCard(
                title: AppStrings.part1Title,
                subtitle: AppStrings.part1Subtitle,
                badgeText: 'Part 1: Performance & BLoC',
                gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                icon: Icons.currency_rupee_rounded,
                tags: const ['BLoC Pattern', '1,000+ Items', 'WebSocket Stream'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const EarningsScreen(userId: 'teen_user_101'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Part 2 Card
              _buildDemoCard(
                title: AppStrings.part2Title,
                subtitle: AppStrings.part2Subtitle,
                badgeText: 'Part 2: Infinite Scroll Pagination',
                gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                icon: Icons.view_stream_rounded,
                tags: const ['Infinite Scroll', 'Retry Footer', 'Pages 0-7'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProjectsScreen(),
                    ),
                  );
                },
              ),


              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required List<Color> gradient,
    required IconData icon,
    required List<String> tags,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: gradient[0].withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: gradient[0].withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: gradient[0],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                // Tags row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
