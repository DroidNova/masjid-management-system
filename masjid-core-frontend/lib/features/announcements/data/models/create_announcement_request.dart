class CreateAnnouncementRequest {
  const CreateAnnouncementRequest({
    required this.title,
    required this.message,
    required this.isActive,
  });

  final String title;
  final String message;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title.trim(),
      'message': message.trim(),
      'isActive': isActive,
    };
  }
}
