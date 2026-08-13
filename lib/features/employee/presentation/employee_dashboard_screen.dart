import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class EmployeeDashboardScreen extends StatelessWidget {
  final String fullName;
  final String organizationName;

  const EmployeeDashboardScreen({
    super.key,
    required this.fullName,
    required this.organizationName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning 👋',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 4),

              Text(
                fullName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 6),

              Text(
                organizationName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 14),

                    Text(
                      "Today's Attendance",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'You have not marked attendance today.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text(
                          'Mark Attendance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Attendance Overview',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Present',
                      value: '0',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.event_busy_outlined,
                      title: 'Leaves',
                      value: '0',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                'Recent Attendance',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      size: 40,
                      color: AppColors.textSecondary,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'No attendance history yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Your attendance records will appear here.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 26,
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}