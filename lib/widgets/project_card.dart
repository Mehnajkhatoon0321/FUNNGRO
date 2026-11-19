import 'package:flutter/material.dart';

import '../core/utils/currency_formatter.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final idNumber =
        int.tryParse(project.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    const gradients = [
      [Color(0xFF6366F1), Color(0xFF4F46E5)], // Indigo
      [Color(0xFF0EA5E9), Color(0xFF0284C7)], // Sky
      [Color(0xFF10B981), Color(0xFF059669)], // Emerald
      [Color(0xFF8B5CF6), Color(0xFF7C3AED)], // Purple
      [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
    ];

    const icons = [
      Icons.campaign_rounded,
      Icons.design_services_rounded,
      Icons.edit_note_rounded,
      Icons.phonelink_setup_rounded,
      Icons.analytics_rounded,
    ];

    const categories = [
      'Social Media',
      'Design Review',
      'Content Writing',
      'App Testing',
      'Market Survey',
    ];

    final gradient = gradients[idNumber % gradients.length];
    final icon = icons[idNumber % icons.length];
    final category = categories[idNumber % categories.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Viewing ${project.title} (${project.company})'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gradient Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Project Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              project.company,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 13,
                            color: Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Tags Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 11,
                                  color: Color(0xFF6366F1),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Remote',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Payout Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFBBF7D0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'PAYOUT',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatCurrency(project.payout),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
