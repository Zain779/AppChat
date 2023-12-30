import 'package:appchat/Resources/color.dart';
import 'package:appchat/api/api.dart';
import 'package:appchat/helper/my_date_util.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  List<ChatUser> list = [];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding Keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.user.name),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Joined at:  '),
              Text(
                MyDateUtil.getLastMessageTime(
                    context: context,
                    time: widget.user.createdAt,
                    showYear: true),
                style: TextStyle(fontSize: 12, color: AppColors.darkGrayColor),
              )
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.height * .03),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: mq.height * 0.03,
                    width: mq.height,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * 0.2,
                      height: mq.height * 0.2,
                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  Text(
                    widget.user.email,
                    style:
                        TextStyle(fontSize: 18, color: AppColors.darkGrayColor),
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('About:  '),
                      Text(
                        widget.user.about,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.darkGrayColor),
                      )
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }
}
