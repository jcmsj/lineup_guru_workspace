class ShopQueue {
  final int id;
  final String name;
  final int current;
  final int lastPosition;
  final String createdAt;
  final String iconName;
  final bool isMultiJoin;
  ShopQueue({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.current,
    required this.lastPosition,
    required this.iconName,
    required this.isMultiJoin,
  });

  factory ShopQueue.fromJson(Map<String, dynamic> json) {
    return ShopQueue(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
      current: json['current'],
      lastPosition: json['last_position'],
      iconName: json['icon'] ?? '',
      isMultiJoin: json['multi_join_on'] == 1,
    );
  }

  ShopQueue copyWith({
    int? id,
    String? name,
    String? createdAt,
    int? current,
    int? lastPosition,
    String? iconName,
    bool? isMultiJoin,
  }) {
    return ShopQueue(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      current: current ?? this.current,
      lastPosition: lastPosition ?? this.lastPosition,
      iconName: iconName ?? this.iconName,
      isMultiJoin: isMultiJoin ?? this.isMultiJoin,
    );
  }
}
