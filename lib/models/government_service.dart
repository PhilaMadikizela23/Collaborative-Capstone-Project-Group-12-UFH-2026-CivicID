class GovernmentService {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<String> requiredDocumentTypes;

  const GovernmentService({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.requiredDocumentTypes,
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  GovernmentService copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    List<String>? requiredDocumentTypes,
  }) {
    return GovernmentService(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      requiredDocumentTypes:
      requiredDocumentTypes ?? this.requiredDocumentTypes,
    );
  }

  // ============================================================
  // FROM MAP
  // Useful later for Firebase / Firestore / JSON
  // ============================================================

  factory GovernmentService.fromMap(
      Map<String, dynamic> map,
      ) {
    return GovernmentService(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      requiredDocumentTypes:
      List<String>.from(
        map['requiredDocumentTypes'] ?? const [],
      ),
    );
  }

  // ============================================================
  // TO MAP
  // Useful when saving to Firebase / database
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'requiredDocumentTypes': requiredDocumentTypes,
    };
  }

  // ============================================================
  // DISPLAY
  // ============================================================

  @override
  String toString() {
    return 'GovernmentService('
        'id: $id, '
        'name: $name, '
        'category: $category'
        ')';
  }
}