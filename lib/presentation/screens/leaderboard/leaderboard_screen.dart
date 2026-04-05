import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends State<LeaderboardScreen>
    with AutomaticKeepAliveClientMixin {
  final _leaderboardService = LeaderboardService();

  List<LeaderboardEntry> _entries = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final entries = await _leaderboardService.getTopPaidMembers(limit: 10);

    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  /// Called by the app shell whenever the Leaderboard tab becomes active.
  Future<void> refreshOnTabSelected() => _load();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.leaderboard),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.noLeaderboardData,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return _LeaderboardTile(entry: entry);
                    },
                  ),
                ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;

  const _LeaderboardTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final rankColor = switch (entry.rank) {
      1 => const Color(0xFFD4AF37),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.primary,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rankColor.withOpacity(0.12),
          child: Text(
            '#${entry.rank}',
            style: TextStyle(
              color: rankColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          '${entry.memberName} (#${entry.shortId(length: 6)})',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          'TRY ${entry.totalPaid.toStringAsFixed(2)}',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
