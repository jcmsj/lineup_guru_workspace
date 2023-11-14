class ShopQueue {
  final int id;
  final String name;
  final int current;
  final int lastPosition;
  final String createdAt;
  final String iconName;
  ShopQueue({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.current,
    required this.lastPosition,
    required this.iconName,
  });

  factory ShopQueue.fromJson(Map<String, dynamic> json) {
    return ShopQueue(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
      current: json['current'],
      lastPosition: json['last_position'],
      iconName: json['icon'],
    );
  }
}
