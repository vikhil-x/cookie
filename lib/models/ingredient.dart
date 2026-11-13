class Ingredient {
  final String id;
  String name;
  String quantity; // text quantity, e.g. "2 tbsp", "1 cup", "to taste"

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name.trim(),
        'quantity': quantity.trim(),
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        quantity: json['quantity'] as String? ?? '',
      );

  Ingredient copyWith({String? id, String? name, String? quantity}) =>
      Ingredient(
        id: id ?? this.id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
      );
}
