import 'dart:developer';
import 'package:appchat/Resources/color.dart';
import 'package:appchat/Screens/profile_screen.dart';
import 'package:appchat/api/api.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:appchat/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    APIs.getSelfinfo();
    APIs.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('message : $message');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          APIs.updateActiveStatus(true);
        if (message.toString().contains('pause'))
          APIs.updateActiveStatus(false);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if search is on and back is press than close search
        // or else simple close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              leading: Icon(CupertinoIcons.home),
              title: _isSearching
                  ? TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name, email, ...'),
                      autofocus: true,
                      style: TextStyle(fontSize: 17, letterSpacing: .5),
                      onChanged: (val) {
                        _searchList.clear();
                        for (var i in _list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : Text('AppChat'),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled
                        : Icons.search)),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                    user: APIs.me,
                                  )));
                    },
                    icon: Icon(Icons.more_vert_outlined))
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
              },
              child: Icon(Icons.add_comment_rounded),
            ),
            body: StreamBuilder(
                stream: APIs.getallUser(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return CircularProgressIndicator();
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                          [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            itemCount: _isSearching
                                ? _searchList.length
                                : _list.length,
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                  user: _isSearching
                                      ? _searchList[index]
                                      : _list[index]);
                            });
                      } else {
                        return Center(
                          child: Text(
                            'No Connection Found!',
                            style: TextStyle(
                                color: AppColors.primaryTextTextColor,
                                fontSize: 20),
                          ),
                        );
                      }
                  }
                })),
      ),
    );
  }
}
