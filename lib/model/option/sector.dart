class Sector {
  String? id;
  String? name;
  int? type; //0默认(不可删)，1自定义
  bool? show;
  bool? editable;
  bool? canDelete;

  Sector({
    this.id,
    this.name,
    this.type,
    this.show,
    this.editable,
    this.canDelete,
  });

  Sector.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    show = json['show'];
    editable = json['editable'];
    canDelete = json['canDelete'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'show': show,
      'editable': editable,
      'canDelete': canDelete,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Sector && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
