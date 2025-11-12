class ChatMessageModel {
  final String? text;
  final bool isUser;
  final bool isError;
  final String? surfaceId;
  String? id;

  ChatMessageModel({
    this.text,
    this.isUser = false,
    this.isError = false,
    this.surfaceId,
    this.id
  }){
    id ??= DateTime.now().millisecondsSinceEpoch.toString();
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'isError': isError,
    'surfaceId': surfaceId,
    'id':id
  };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        text: json['text'] as String?,
        isUser: json['isUser'] as bool? ?? false,
        isError: json['isError'] as bool? ?? false,
        surfaceId: json['surfaceId'] as String?,
        id: json['id'] as String?
      );
}


