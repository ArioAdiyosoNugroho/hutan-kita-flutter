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
        id:              _toInt(json['id']),
        userId:          json['user_id'] != null ? _toInt(json['user_id']) : null,
        amount:          _toInt(json['amount']),
        currency:        json['currency'] ?? 'IDR',
        status:          json['status'] ?? 'pending',
        treesCount:      _toInt(json['trees_count']),
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

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

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
        rank:          _toInt(json['rank']),
        user:          json['user'] != null ? User.fromJson(json['user']) : null,
        totalTrees:    _toInt(json['total_trees']),
        totalAmount:   json['total_amount'] ?? 'Rp 0',
        donationCount: _toInt(json['donation_count']),
      );

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
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
        totalTreesPlanted: _toInt(json['total_trees_planted']),
        totalDonors:       _toInt(json['total_donors']),
        totalDonated:      _toInt(json['total_donated']),
        totalDonations:    _toInt(json['total_donations']),
      );

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}