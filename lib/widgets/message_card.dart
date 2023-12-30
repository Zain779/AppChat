import 'dart:developer';

import 'package:appchat/Resources/color.dart';
import 'package:appchat/Resources/fonts_sizes.dart';
import 'package:appchat/api/api.dart';
import 'package:appchat/helper/my_date_util.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      log('message read updated');
    }
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .015),
            child: Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.chatBlueColor,
                    border: Border.all(color: AppColors.chatBlueBorderColor),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                padding: EdgeInsets.symmetric(
                    horizontal: mq.width * .04, vertical: mq.height * .02),
                child: widget.message.type == Type.text
                    ? Text(widget.message.message)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          width: mq.width * .6,
                          height: mq.height * .35,
                          fit: BoxFit.fill,
                          imageUrl: widget.message.message,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => CircleAvatar(
                            child: Icon(
                              Icons.image,
                              size: 70,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: mq.width * .04),
            child: Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: kHeading4GreyTextStyle,
            ),
          )
        ],
      ),
    );
  }

  Widget _greenMessage() {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: mq.width * .04),
            child: Row(
              children: [
                if (widget.message.read.isNotEmpty)
                  Icon(
                    Icons.done_all_rounded,
                    size: 19,
                    color: AppColors.chatBlueBorderColor,
                  ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  MyDateUtil.getFormattedTime(
                      context: context, time: widget.message.sent),
                  style: kHeading4GreyTextStyle,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .015),
            child: Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.chatgreenColor,
                    border: Border.all(color: AppColors.chatGreenBorderColor),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                padding: EdgeInsets.symmetric(
                    horizontal: mq.width * .04, vertical: mq.height * .02),
                child: widget.message.type == Type.text
                    ? Text(widget.message.message)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          width: mq.width * .5,
                          height: mq.height * .35,
                          fit: BoxFit.fill,
                          imageUrl: widget.message.message,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => CircleAvatar(
                            child: Icon(
                              Icons.image,
                              size: 70,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
