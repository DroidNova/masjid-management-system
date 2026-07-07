class UpdateAnnouncementRequest {
  const UpdateAnnouncementRequest({this.title, this.message, this.isActive});

  final String? title;
  final String? message;
  final bool? isActive;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title!.trim();
    if (message != null) json['message'] = message!.trim();
    if (isActive != null) json['isActive'] = isActive;
    return json;
  }
}
