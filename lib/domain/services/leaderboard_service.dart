import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/member_repository.dart';

/// Aggregated leaderboard row for one unique member.
class LeaderboardEntry {
  final String memberId;
  final String memberName;
  final double totalPaid;
  final int rank;

  const LeaderboardEntry({
    required this.memberId,
    required this.memberName,
    required this.totalPaid,
    required this.rank,
  });

  String shortId({int length = 6}) {
    final clean = memberId.replaceAll('-', '');
    if (clean.length <= length) return clean;
    return clean.substring(0, length);
  }
}

/// Lightweight input record used by the ranking helper.
class LeaderboardPaymentRecord {
  final String memberId;
  final String memberName;
  final double totalPaid;

  const LeaderboardPaymentRecord({
    required this.memberId,
    required this.memberName,
    required this.totalPaid,
  });
}

/// Builds global leaderboard data from all groups in the local database.
class LeaderboardService {
  final GroupRepository _groupRepository;
  final MemberRepository _memberRepository;
  final ExpenseRepository _expenseRepository;

  LeaderboardService({
    GroupRepository? groupRepository,
    MemberRepository? memberRepository,
    ExpenseRepository? expenseRepository,
  })  : _groupRepository = groupRepository ?? GroupRepository(),
        _memberRepository = memberRepository ?? MemberRepository(),
        _expenseRepository = expenseRepository ?? ExpenseRepository();

  Future<List<LeaderboardEntry>> getTopPaidMembers({
    int limit = 10,
  }) async {
    final groups = await _groupRepository.getAllGroups();
    final memberNamesById = <String, String>{};
    final totalPaidByMemberId = <String, double>{};

    for (final group in groups) {
      final members = await _memberRepository.getMembersForGroup(group.id);
      for (final member in members) {
        memberNamesById[member.id] = member.name;
      }

      final expenses = await _expenseRepository.getExpensesForGroup(group.id);
      for (final expense in expenses) {
        if (!memberNamesById.containsKey(expense.payerId)) continue;
        totalPaidByMemberId[expense.payerId] =
            (totalPaidByMemberId[expense.payerId] ?? 0.0) + expense.amount;
      }
    }

    final records = totalPaidByMemberId.entries
        .map(
          (entry) => LeaderboardPaymentRecord(
            memberId: entry.key,
            memberName: memberNamesById[entry.key] ?? 'Unknown',
            totalPaid: entry.value,
          ),
        )
        .toList();

    return rankEntries(records, limit: limit);
  }

  /// Sort rule: totalPaid DESC, then memberName ASC, then memberId ASC.
  static List<LeaderboardEntry> rankEntries(
    List<LeaderboardPaymentRecord> records, {
    int limit = 10,
  }) {
    final merged = <String, LeaderboardPaymentRecord>{};

    for (final record in records) {
      final existing = merged[record.memberId];
      if (existing == null) {
        merged[record.memberId] = record;
      } else {
        merged[record.memberId] = LeaderboardPaymentRecord(
          memberId: record.memberId,
          memberName: existing.memberName,
          totalPaid: existing.totalPaid + record.totalPaid,
        );
      }
    }

    final sorted = merged.values.toList()
      ..sort((a, b) {
        final byAmount = b.totalPaid.compareTo(a.totalPaid);
        if (byAmount != 0) return byAmount;

        final byName =
            a.memberName.toLowerCase().compareTo(b.memberName.toLowerCase());
        if (byName != 0) return byName;

        return a.memberId.compareTo(b.memberId);
      });

    final top = sorted.take(limit).toList();
    return List.generate(
      top.length,
      (index) => LeaderboardEntry(
        memberId: top[index].memberId,
        memberName: top[index].memberName,
        totalPaid: top[index].totalPaid,
        rank: index + 1,
      ),
    );
  }
}
