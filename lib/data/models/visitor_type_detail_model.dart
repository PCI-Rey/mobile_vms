class MultipleOptionField {
  final String id;
  final String name;
  final String value;

  const MultipleOptionField({
    required this.id,
    required this.name,
    required this.value,
  });

  factory MultipleOptionField.fromJson(Map<String, dynamic> json) {
    return MultipleOptionField(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'value': value,
      };
}

class VisitFormField {
  final int sort;
  final String shortName;
  final String longDisplayText;
  final int fieldType;
  final bool isPrimary;
  final bool isEnable;
  final bool mandatory;
  final String remarks;
  final String customFieldId;
  final List<MultipleOptionField> multipleOptionFields;
  final int visitorFormType;
  // Mutable answer fields
  String answerText;
  String answerDatetime;

  VisitFormField({
    required this.sort,
    required this.shortName,
    required this.longDisplayText,
    required this.fieldType,
    required this.isPrimary,
    required this.isEnable,
    required this.mandatory,
    required this.remarks,
    required this.customFieldId,
    required this.multipleOptionFields,
    required this.visitorFormType,
    this.answerText = '',
    this.answerDatetime = '',
  });

  factory VisitFormField.fromJson(Map<String, dynamic> json) {
    final options = (json['multiple_option_fields'] as List<dynamic>? ?? [])
        .map((e) => MultipleOptionField.fromJson(e as Map<String, dynamic>))
        .toList();

    return VisitFormField(
      sort: (json['sort'] as num?)?.toInt() ?? 0,
      shortName: json['short_name']?.toString() ?? '',
      longDisplayText: json['long_display_text']?.toString() ?? '',
      fieldType: (json['field_type'] as num?)?.toInt() ?? 0,
      isPrimary: json['is_primary'] == true,
      isEnable: json['is_enable'] == true,
      mandatory: json['mandatory'] == true,
      remarks: json['remarks']?.toString() ?? '',
      customFieldId: json['custom_field_id']?.toString() ?? '',
      multipleOptionFields: options,
      visitorFormType: (json['visitor_form_type'] as num?)?.toInt() ?? 0,
      answerText: json['answer_text']?.toString() ?? '',
      answerDatetime: json['answer_datetime']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    // Strip milliseconds from strings if present
    String cleanText = answerText;
    if (cleanText.contains('.')) {
      cleanText = cleanText.replaceAll(RegExp(r'\.\d+'), '');
    }

    String? cleanDt;
    if (answerDatetime.isNotEmpty) {
      cleanDt = answerDatetime;
      if (cleanDt.contains('.')) {
        cleanDt = cleanDt.replaceAll(RegExp(r'\.\d+'), '');
      }
    } else {
      cleanDt = null;
    }

    return {
      'sort': sort,
      'short_name': shortName,
      'long_display_text': longDisplayText,
      'field_type': fieldType,
      'is_primary': isPrimary,
      'is_enable': isEnable,
      'mandatory': mandatory,
      'remarks': remarks,
      'custom_field_id': customFieldId,
      'multiple_option_fields':
          multipleOptionFields.map((e) => e.toJson()).toList(),
      'visitor_form_type': visitorFormType,
      'answer_text': cleanText,
      'answer_datetime': cleanDt,
    };
  }
}

class SectionPageVisitorType {
  final String id;
  final int sort;
  final String name;
  final bool isDocument;
  final bool canMultipleUsed;
  final String foreignId;
  final List<VisitFormField> visitForm;

  const SectionPageVisitorType({
    required this.id,
    required this.sort,
    required this.name,
    required this.isDocument,
    required this.canMultipleUsed,
    required this.foreignId,
    required this.visitForm,
  });

  factory SectionPageVisitorType.fromJson(Map<String, dynamic> json) {
    final forms = ((json['VisitForm'] ?? json['visit_form']) as List<dynamic>? ?? [])
        .map((e) => VisitFormField.fromJson(e as Map<String, dynamic>))
        .toList();

    return SectionPageVisitorType(
      id: (json['Id'] ?? json['id'])?.toString() ?? '',
      sort: (json['Sort'] ?? json['sort'] as num?)?.toInt() ?? 0,
      name: (json['Name'] ?? json['name'])?.toString() ?? '',
      isDocument: (json['IsDocument'] ?? json['is_document']) == true,
      canMultipleUsed:
          (json['CanMultipleUsed'] ?? json['can_multiple_used']) == true,
      foreignId: (json['ForeignId'] ?? json['foreign_id'])?.toString() ?? '',
      visitForm: forms,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sort': sort,
        'name': name,
        'is_document': isDocument,
        'can_multiple_used': canMultipleUsed,
        'foreign_id': foreignId,
        'form': visitForm.map((e) => e.toJson()).toList(),
      };
}

class VisitorTypeDetailModel {
  final List<SectionPageVisitorType> sectionPageVisitorTypes;

  const VisitorTypeDetailModel({required this.sectionPageVisitorTypes});

  factory VisitorTypeDetailModel.fromJson(Map<String, dynamic> json) {
    final sections =
        (json['section_page_visitor_types'] as List<dynamic>? ?? [])
            .map((e) =>
                SectionPageVisitorType.fromJson(e as Map<String, dynamic>))
            .toList();

    return VisitorTypeDetailModel(sectionPageVisitorTypes: sections);
  }
}
