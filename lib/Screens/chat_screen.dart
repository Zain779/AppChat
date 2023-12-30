import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:appchat/Resources/color.dart';
import 'package:appchat/Resources/fonts_sizes.dart';
import 'package:appchat/Screens/view_profile_screen.dart';
import 'package:appchat/api/api.dart';
import 'package:appchat/helper/my_date_util.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:appchat/models/message.dart';
import 'package:appchat/widgets/chat_user_card.dart';
import 'package:appchat/widgets/message_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _emoji = false, _uploading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          if (_emoji) {
            setState(() {
              _emoji = !_emoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: AppColors.chatBlueColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: APIs.getallMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return SizedBox();
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];
                            // final _list = ['hi', 'Boy'];
                            // _list.clear();
                            // _list.add(Message(
                            //     toId: 'xyz',
                            //     read: '',
                            //     type: Type.text,
                            //     message: 'Hi',
                            //     sent: '12:00 Am',
                            //     fromId: APIs.user.uid));
                            // _list.add(Message(
                            //     toId: APIs.user.uid,
                            //     read: '',
                            //     type: Type.text,
                            //     message: 'Hello',
                            //     sent: '12:00 Am',
                            //     fromId: 'xyz'));
                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  reverse: true,
                                  itemCount: _list.length,
                                  itemBuilder: (context, index) {
                                    return MessageCard(
                                      message: _list[index],
                                    );
                                  });
                            } else {
                              return Center(
                                child: Text(
                                  'Say Hii! 👋',
                                  style: TextStyle(
                                      color: AppColors.primaryTextTextColor,
                                      fontSize: 20),
                                ),
                              );
                            }
                        }
                      }),
                ),
                if (_uploading)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        )),
                  ),
                _chatInput(),
                if (_emoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        columns: 8,
                        bgColor: AppColors.chatBlueColor,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserinfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.darkGrayColor,
                      )),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * 0.05,
                      height: mq.height * 0.05,
                      fit: BoxFit.fill,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: kHeading3GreyTextStyle,
                      ),
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: kHeading4GreyTextStyle,
                      ),
                    ],
                  )
                ],
              );
            }));
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * .02, vertical: mq.height * .02),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _emoji = !_emoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: AppColors.iconsColor,
                        size: 26,
                      )),
                  Expanded(
                      child: TextField(
                    onTap: () {
                      if (_emoji)
                        setState(() {
                          _emoji = !_emoji;
                        });
                    },
                    controller: _textController,
                    decoration: InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: AppColors.iconsColor),
                        border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images =
                            await picker.pickMultiImage();
                        for (var i in images) {
                          setState(() {
                            _uploading = true;
                          });
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() {
                            _uploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: AppColors.iconsColor,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          setState(() {
                            _uploading = true;
                          });
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() {
                            _uploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt,
                        color: AppColors.iconsColor,
                        size: 26,
                      )),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            color: AppColors.button1Color,
            child: Icon(
              Icons.send,
              color: AppColors.whiteColor,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
