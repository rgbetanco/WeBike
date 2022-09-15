import 'package:flutter/material.dart';
import 'package:pizarro_app/models/chat_message.dart';
import 'package:pizarro_app/models/chat_user.dart';
import 'package:pizarro_app/widgets/message_bubbles.dart';
import 'package:pizarro_app/widgets/rounded_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomListViewTile extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isSelected;
  final Function onTap;

  CustomListViewTile({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: isSelected
          ? Icon(Icons.check, color: Colors.white)
          : Icon(Icons.select_all, color: Colors.white),
      onTap: () => onTap(),
      minVerticalPadding: height * 0.20,
      leading: RoundedImageNetworkWithStatusIndicator(
        key: UniqueKey(),
        size: height / 2,
        imagePath: imagePath,
        isActive: isActive,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class CustomListViewTileWithActivity extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final void Function(BuildContext) onTap;

  CustomListViewTileWithActivity({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isActivity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(context),
      minVerticalPadding: height * 0.20,
      leading: RoundedImageNetworkWithStatusIndicator(
        key: UniqueKey(),
        imagePath: imagePath,
        size: height / 2,
        isActive: isActive,
      ),
      title: Text(
        title,
        // ignore: prefer_const_constructors
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4),
        child: isActivity
            ? Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SpinKitThreeBounce(
                    color: Colors.white54,
                    size: height * 0.10,
                  )
                ],
              )
            : Text(
                subtitle,
                // ignore: prefer_const_constructors
                style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
              ),
      ),
    );
  }
}

class CustomChatListViewTile extends StatelessWidget {
  final double width;
  final double deviceHeight;
  final bool isOwnMessage;
  final ChatMessage message;
  final ChatUser sender;

  CustomChatListViewTile({
    required this.width,
    required this.deviceHeight,
    required this.isOwnMessage,
    required this.message,
    required this.sender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      width: width,
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment:
              isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            !isOwnMessage
                ? RoundedImageNetwork(
                    key: UniqueKey(),
                    imagePath: sender.imageURL,
                    size: width * 0.08)
                : Container(),
            SizedBox(
              width: width * 0.05,
            ),
            message.type == MessageType.TEXT
                ? TextMessageBubble(
                    height: deviceHeight * 0.06,
                    isOwnMessage: isOwnMessage,
                    message: message,
                    width: width,
                  )
                : ImageMessageBubble(
                    isOwnMessage: isOwnMessage,
                    message: message,
                    height: deviceHeight * 0.30,
                    width: width * 0.55,
                  ),
          ]),
    );
  }
}
