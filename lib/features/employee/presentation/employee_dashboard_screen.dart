import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import 'package:geolocator/geolocator.dart';
class EmployeeDashboardScreen extends StatefulWidget {
  final String fullName;
  final String organizationName;
  final String token;

  const EmployeeDashboardScreen({
    super.key,
    required this.fullName,
    required this.organizationName,
    required this.token,
  });

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState
    extends State<EmployeeDashboardScreen> {
  bool _isMarkingAttendance = false;
  bool _attendanceMarked = false;

  Future<void> _markAttendance() async {
  if (_isMarkingAttendance || _attendanceMarked) {
    return;
  }

  setState(() {
    _isMarkingAttendance = true;
  });

  try {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Please turn on location services.',
      );
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'Location permission is required.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Enable it from settings.',
      );
    }

    final position =
        await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final result = await ApiService.markAttendance(
      token: widget.token,
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (!mounted) return;

    setState(() {
      _attendanceMarked = true;
      _isMarkingAttendance = false;
    });

    final distance = result['distance'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          distance != null
              ? 'Attendance marked • ${distance}m from workplace'
              : result['message'] ??
                  'Attendance marked successfully',
        ),
      ),
    );
  } catch (error) {
    if (!mounted) return;

    setState(() {
      _isMarkingAttendance = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      ),
    );
  }
}

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
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
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
                widget.fullName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 6),

              Text(
                widget.organizationName,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
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
                    Icon(
                      _attendanceMarked
                          ? Icons.check_circle_rounded
                          : Icons.access_time_rounded,
                      size: 48,
                      color: _attendanceMarked
                          ? Colors.green
                          : AppColors.primary,
                    ),

                    const SizedBox(height: 14),

                    Text(
                      _attendanceMarked
                          ? 'Attendance Marked'
                          : "Today's Attendance",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _attendanceMarked
                          ? 'Your attendance has been recorded for today.'
                          : 'You have not marked attendance today.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _attendanceMarked
                            ? null
                            : _markAttendance,
                        child: _isMarkingAttendance
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _attendanceMarked
                                    ? 'Attendance Marked'
                                    : 'Mark Attendance',
                                style: const TextStyle(
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
                      value: _attendanceMarked ? '1' : '0',
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
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
                    Icon(
                      _attendanceMarked
                          ? Icons.check_circle_outline_rounded
                          : Icons.history_rounded,
                      size: 40,
                      color: _attendanceMarked
                          ? Colors.green
                          : AppColors.textSecondary,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _attendanceMarked
                          ? 'Present today'
                          : 'No attendance history yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _attendanceMarked
                          ? 'Your attendance was recorded successfully.'
                          : 'Your attendance records will appear here.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
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