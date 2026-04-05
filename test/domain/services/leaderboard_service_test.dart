import 'package:flutter_test/flutter_test.dart';
import 'package:splitmate/domain/services/leaderboard_service.dart';

void main() {
  group('LeaderboardService.rankEntries', () {
    test('sorts by totalPaid desc, then memberName asc, and keeps top 10', () {
      final records = <LeaderboardPaymentRecord>[
        const LeaderboardPaymentRecord(
          memberId: 'm1-aaaaaa',
          memberName: 'Zeynep',
          totalPaid: 100,
        ),
        const LeaderboardPaymentRecord(
          memberId: 'm2-bbbbbb',
          memberName: 'Ahmet',
          totalPaid: 250,
        ),
        const LeaderboardPaymentRecord(
          memberId: 'm3-cccccc',
          memberName: 'Baris',
          totalPaid: 250,
        ),
        const LeaderboardPaymentRecord(
          memberId: 'm4-dddddd',
          memberName: 'Can',
          totalPaid: 200,
        ),
        const LeaderboardPaymentRecord(
          memberId: 'm5-eeeeee',
          memberName: 'Deniz',
          totalPaid: 180,
        ),
        const LeaderboardPaymentRecord(
          memberId: 'm6-ffffff',
          memberName: 'Ece',
          totalPaid: 170,
        ),
        const LeaderboardPaymentRecord(
          memberId: 'm7-111111',
          memberName: 'Furkan',
          totalPaid: 160,
        ),
        const LeaderboardPaymentRecord(
          memberId: 'm8-222222',
          memberName: 'Gizem',
          totalPaid: 150,
        ),
        const LeaderboardPaymentRecord(
          memberId: 'm9-333333',
          memberName: 'Hakan',
          totalPaid: 140,
        ),
        const LeaderboardPaymentRecord(
          memberId: 'm10-444444',
          memberName: 'Irem',
          totalPaid: 130,
        ),
        const LeaderboardPaymentRecord(
          memberId: 'm11-555555',
          memberName: 'Jale',
          totalPaid: 120,
        ),
      ];

      final ranked = LeaderboardService.rankEntries(records, limit: 10);

      expect(ranked.length, 10);
      // 250-tie must be alphabetical: Ahmet before Baris.
      expect(ranked[0].memberName, 'Ahmet');
      expect(ranked[1].memberName, 'Baris');
      // Lowest entry (Zeynep) is trimmed out by top-10 limit.
      expect(ranked.any((e) => e.memberName == 'Zeynep'), isFalse);
      expect(ranked.first.rank, 1);
      expect(ranked.last.rank, 10);
    });

    test('merges repeated memberId totals and returns 6-char short id', () {
      const repeatedId = '12345678-90ab-cdef';
      final records = <LeaderboardPaymentRecord>[
        const LeaderboardPaymentRecord(
          memberId: repeatedId,
          memberName: 'Ada',
          totalPaid: 40,
        ),
        const LeaderboardPaymentRecord(
          memberId: repeatedId,
          memberName: 'Ada',
          totalPaid: 60,
        ),
      ];

      final ranked = LeaderboardService.rankEntries(records, limit: 10);

      expect(ranked.length, 1);
      expect(ranked.first.totalPaid, 100);
      expect(ranked.first.shortId(length: 6).length, 6);
      expect(ranked.first.shortId(length: 6), '123456');
    });
  });
}

