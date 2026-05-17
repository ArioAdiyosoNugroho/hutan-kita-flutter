import 'user.dart';

class Donation {
  final int id;
  final int? userId;
  final int amount;
  final String currency;
  final String status;
  final int treesCount;
  final String? donorName;
  final String? donorEmail;
  final String? donorMessage;
  final String? checkoutUrl;
  final String? mayarOrderId;
  final DateTime? paidAt;
  final DateTime createdAt;
  final User? user;
  final String? amountFormatted;

  Donation({
    required this.id,
    this.userId,
    required this.amount,
    this.currency = 'IDR',
    required this.status,
    required this.treesCount,
    this.donorName,
    this.donorEmail,
    this.donorMessage,
    this.checkoutUrl,
    this.mayarOrderId,
    this.paidAt,
    required this.createdAt,
    this.user,
    this.amountFormatted,
  });

  factory Donation.fromJson(Map<String, dynamic> json) => Donation(
        id:              json['id'],
        userId:          json['user_id'],
        amount:          json['amount'] ?? 0,
        currency:        json['currency'] ?? 'IDR',
        status:          json['status'] ?? 'pending',
        treesCount:      json['trees_count'] ?? 0,
        donorName:       json['donor_name'],
        donorEmail:      json['donor_email'],
        donorMessage:    json['donor_message'],
        checkoutUrl:     json['checkout_url'],
        mayarOrderId:    json['mayar_order_id'],
        paidAt:          json['paid_at'] != null
                             ? DateTime.tryParse(json['paid_at'])
                             : null,
        createdAt:       DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        user:            json['user'] != null ? User.fromJson(json['user']) : null,
        amountFormatted: json['amount_formatted'],
      );

  String get statusLabel {
    switch (status) {
      case 'paid':    return 'Berhasil';
      case 'failed':  return 'Gagal';
      case 'expired': return 'Kedaluwarsa';
      default:        return 'Menunggu';
    }
  }

  String get formattedAmount {
    if (amountFormatted != null) return amountFormatted!;
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}

class LeaderboardEntry {
  final int rank;
  final User? user;
  final int totalTrees;
  final String totalAmount;
  final int donationCount;

  LeaderboardEntry({
    required this.rank,
    this.user,
    required this.totalTrees,
    required this.totalAmount,
    required this.donationCount,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        rank:          json['rank'] ?? 0,
        user:          json['user'] != null ? User.fromJson(json['user']) : null,
        totalTrees:    json['total_trees'] ?? 0,
        totalAmount:   json['total_amount'] ?? 'Rp 0',
        donationCount: json['donation_count'] ?? 0,
      );
}

class DonationSummary {
  final int totalTreesPlanted;
  final int totalDonors;
  final int totalDonated;
  final int totalDonations;

  DonationSummary({
    required this.totalTreesPlanted,
    required this.totalDonors,
    required this.totalDonated,
    required this.totalDonations,
  });

  factory DonationSummary.fromJson(Map<String, dynamic> json) => DonationSummary(
        totalTreesPlanted: json['total_trees_planted'] ?? 0,
        totalDonors:       json['total_donors'] ?? 0,
        totalDonated:      json['total_donated'] ?? 0,
        totalDonations:    json['total_donations'] ?? 0,
      );
}
