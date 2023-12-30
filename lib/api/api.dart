import 'dart:developer' show log;
import 'dart:io';
import 'package:appchat/models/chat_user.dart';
import 'package:appchat/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static late ChatUser me;
  static User get user => auth.currentUser!;

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getSelfinfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        log('My data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfinfo());
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        name: user.displayName.toString(),
        about: "Hey I'm Using AppChat",
        createdAt: time,
        isOnline: false,
        id: user.uid,
        lastActive: time,
        pushToken: '',
        email: user.email.toString());
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getallUser() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserinfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool _isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': _isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString()
    });
  }

  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('Extension: ${ext}');
    final ref = storage.ref().child('profile image/${user.uid}.${ext}');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/${ext}'))
        .then((p0) async {
      log('Data Transfer : ${p0.bytesTransferred / 1000} kb');
      me.image = await ref.getDownloadURL();
      await firestore.collection('users').doc(user.uid).update({
        'image': me.image,
      });
    });
  }

  static getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : "${id}_${user.uid}";
  static Stream<QuerySnapshot<Map<String, dynamic>>> getallMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatuser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        toId: chatuser.id,
        read: '',
        type: type,
        message: msg,
        sent: time,
        fromId: user.uid);
    final ref = firestore
        .collection('chats/${getConversationId(chatuser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'image/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.${ext}');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/${ext}'))
        .then((p0) async {
      log('Data Transfer : ${p0.bytesTransferred / 1000} kb');
      final imageUrl = await ref.getDownloadURL();
      await sendMessage(chatUser, imageUrl, Type.image);
    });
  }
}
