// lib/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// 👤 نموذج المستخدم
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final int totalScore;
  final int totalCoins;
  final int levelsCompleted;
  final int currentLevel;
  final int totalMoves;
  final DateTime createdAt;
  final DateTime lastPlayedAt;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final bool isBanned;
  final String? banReason;
  final List<String> unlockedBoosters;
  final int gamesPlayed;
  final int gamesWon;
  final double winRate;
  final int longestStreak;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.totalScore = 0,
    this.totalCoins = 0,
    this.levelsCompleted = 0,
    this.currentLevel = 1,
    this.totalMoves = 0,
    required this.createdAt,
    required this.lastPlayedAt,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.isBanned = false,
    this.banReason,
    this.unlockedBoosters = const [],
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.winRate = 0.0,
    this.longestStreak = 0,
  });

  /// التحويل من Firestore Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      totalScore: data['totalScore'] ?? 0,
      totalCoins: data['totalCoins'] ?? 0,
      levelsCompleted: data['levelsCompleted'] ?? 0,
      currentLevel: data['currentLevel'] ?? 1,
      totalMoves: data['totalMoves'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPremium: data['isPremium'] ?? false,
      premiumExpiresAt: (data['premiumExpiresAt'] as Timestamp?)?.toDate(),
      isBanned: data['isBanned'] ?? false,
      banReason: data['banReason'],
      unlockedBoosters: List<String>.from(data['unlockedBoosters'] ?? []),
      gamesPlayed: data['gamesPlayed'] ?? 0,
      gamesWon: data['gamesWon'] ?? 0,
      winRate: (data['winRate'] ?? 0.0).toDouble(),
      longestStreak: data['longestStreak'] ?? 0,
    );
  }

  /// التحويل إلى Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'totalScore': totalScore,
      'totalCoins': totalCoins,
      'levelsCompleted': levelsCompleted,
      'currentLevel': currentLevel,
      'totalMoves': totalMoves,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastPlayedAt': Timestamp.fromDate(lastPlayedAt),
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt != null ? Timestamp.fromDate(premiumExpiresAt!) : null,
      'isBanned': isBanned,
      'banReason': banReason,
      'unlockedBoosters': unlockedBoosters,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'winRate': winRate,
      'longestStreak': longestStreak,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    int? totalScore,
    int? totalCoins,
    int? levelsCompleted,
    int? currentLevel,
    int? totalMoves,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    bool? isBanned,
    String? banReason,
    List<String>? unlockedBoosters,
    int? gamesPlayed,
    int? gamesWon,
    double? winRate,
    int? longestStreak,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      totalScore: totalScore ?? this.totalScore,
      totalCoins: totalCoins ?? this.totalCoins,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      currentLevel: currentLevel ?? this.currentLevel,
      totalMoves: totalMoves ?? this.totalMoves,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      isBanned: isBanned ?? this.isBanned,
      banReason: banReason ?? this.banReason,
      unlockedBoosters: unlockedBoosters ?? this.unlockedBoosters,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      winRate: winRate ?? this.winRate,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    totalScore,
    totalCoins,
    levelsCompleted,
    currentLevel,
    totalMoves,
    createdAt,
    lastPlayedAt,
    isPremium,
    premiumExpiresAt,
    isBanned,
    banReason,
    unlockedBoosters,
    gamesPlayed,
    gamesWon,
    winRate,
    longestStreak,
  ];
}

/// 🎮 نموذج نتيجة اللعبة
class GameResultModel extends Equatable {
  final String id;
  final String userId;
  final int levelNumber;
  final int score;
  final int moves;
  final int timeSpent; // بالثواني
  final bool isPerfect;
  final int coinsEarned;
  final DateTime completedAt;
  final bool isOnlineSubmitted;

  const GameResultModel({
    required this.id,
    required this.userId,
    required this.levelNumber,
    required this.score,
    required this.moves,
    required this.timeSpent,
    required this.isPerfect,
    required this.coinsEarned,
    required this.completedAt,
    this.isOnlineSubmitted = false,
  });

  /// التحويل من Firestore Document
  factory GameResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameResultModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      levelNumber: data['levelNumber'] ?? 0,
      score: data['score'] ?? 0,
      moves: data['moves'] ?? 0,
      timeSpent: data['timeSpent'] ?? 0,
      isPerfect: data['isPerfect'] ?? false,
      coinsEarned: data['coinsEarned'] ?? 0,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOnlineSubmitted: data['isOnlineSubmitted'] ?? false,
    );
  }

  /// التحويل إلى Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'levelNumber': levelNumber,
      'score': score,
      'moves': moves,
      'timeSpent': timeSpent,
      'isPerfect': isPerfect,
      'coinsEarned': coinsEarned,
      'completedAt': Timestamp.fromDate(completedAt),
      'isOnlineSubmitted': isOnlineSubmitted,
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    levelNumber,
    score,
    moves,
    timeSpent,
    isPerfect,
    coinsEarned,
    completedAt,
    isOnlineSubmitted,
  ];
}

/// 🏆 نموذج إدخال التصنيف
class LeaderboardEntryModel extends Equatable {
  final String userId;
  final String userName;
  final String? userPhoto;
  final int totalScore;
  final int rank;
  final int levelsCompleted;
  final DateTime lastUpdated;

  const LeaderboardEntryModel({
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.totalScore,
    required this.rank,
    required this.levelsCompleted,
    required this.lastUpdated,
  });

  /// التحويل من Firestore Document
  factory LeaderboardEntryModel.fromFirestore(DocumentSnapshot doc, int rank) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntryModel(
      userId: doc.id,
      userName: data['displayName'] ?? 'Anonymous',
      userPhoto: data['photoUrl'],
      totalScore: data['totalScore'] ?? 0,
      rank: rank,
      levelsCompleted: data['levelsCompleted'] ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    userId,
    userName,
    userPhoto,
    totalScore,
    rank,
    levelsCompleted,
    lastUpdated,
  ];
}

/// 💰 نموذج المعاملات المالية
class TransactionModel extends Equatable {
  final String id;
  final String userId;
  final String type; // coin_earned, coin_spent, ad_reward, purchase
  final int amount;
  final String description;
  final DateTime timestamp;
  final bool isOnlineSubmitted;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    this.isOnlineSubmitted = false,
  });

  /// التحويل من Firestore Document
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      amount: data['amount'] ?? 0,
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOnlineSubmitted: data['isOnlineSubmitted'] ?? false,
    );
  }

  /// التحويل إلى Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'amount': amount,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'isOnlineSubmitted': isOnlineSubmitted,
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    amount,
    description,
    timestamp,
    isOnlineSubmitted,
  ];
}
