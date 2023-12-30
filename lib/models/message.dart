class Message {
  Message({
    required this.toId,
    required this.read,
    required this.type,
    required this.message,
    required this.sent,
    required this.fromId,
  });
  late final String toId;
  late final String read;
  late final String message;
  late final String sent;
  late final String fromId;
  late final Type type;

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['toId'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    message = json['message'].toString();
    sent = json['sent'].toString();
    fromId = json['fromId'].toString();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['toId'] = toId;
    _data['read'] = read;
    _data['type'] = type.name;
    _data['message'] = message;
    _data['sent'] = sent;
    _data['fromId'] = fromId;
    return _data;
  }
}

enum Type { image, text }
