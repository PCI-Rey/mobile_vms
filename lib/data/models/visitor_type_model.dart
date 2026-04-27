class VisitorTypeModel {
  final String id;
  final String name;
  final String description;
  final bool isEnable;
  final bool showInForm;

  const VisitorTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isEnable,
    required this.showInForm,
  });

  factory VisitorTypeModel.fromJson(Map<String, dynamic> json) {
    return VisitorTypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isEnable: json['is_enable'] == true,
      showInForm: json['show_in_form'] == true,
    );
  }
}
