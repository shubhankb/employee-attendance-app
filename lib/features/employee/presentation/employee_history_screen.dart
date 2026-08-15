import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';

class EmployeeHistoryScreen extends StatefulWidget {
  final String token;

  const EmployeeHistoryScreen({
    super.key,
    required this.token,
  });

  @override
  State<EmployeeHistoryScreen> createState() =>
      _EmployeeHistoryScreenState();
}

class _EmployeeHistoryScreenState
    extends State<EmployeeHistoryScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final result = await ApiService.getEmployeeHistory(
        token: widget.token,
      );

      if (!mounted) return;

      setState(() {
        _history = result['history'] ?? [];
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';

    final parsed = DateTime.tryParse(date);

    if (parsed == null) return date;

    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')}/'
        '${parsed.year}';
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '-';

    final parsed = DateTime.tryParse(time);

    if (parsed == null) return time;

    final hour = parsed.hour % 12 == 0
        ? 12
        : parsed.hour % 12;

    final minute = parsed.minute
        .toString()
        .padLeft(2, '0');

    final period = parsed.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadHistory,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_history.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Icon(
              Icons.event_note_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'No attendance history yet',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          32,
        ),
        itemCount: _history.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final record = _history[index];

          final status =
              (record['status'] ?? 'unknown')
                  .toString();

          final isPresent = status == 'present';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPresent
                        ? Icons.check_circle_outline_rounded
                        : Icons.event_note_outlined,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(
                          record['attendance_date']
                              ?.toString(),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Check-in: ${_formatTime(
                          record['check_in']?.toString(),
                        )}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                    ],
                  ),
                ),

                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: isPresent
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}