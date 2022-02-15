import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/providers/chat_page_provider.dart';
import 'package:pizarro_app/services/database_service.dart';
import 'package:pizarro_app/services/mux_service.dart';
import 'package:pizarro_app/widgets/custom_list_view_tiles.dart';
import 'package:pizarro_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';

class ChatsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChatsPageState();
  }
}

class ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late AuthenticationProvider _auth;
  late ChatsPageProvider _chatPageProvider;
  late DatabaseService _db;
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatsPageProvider>(
          create: (_) => ChatsPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext _context) {
        _chatPageProvider = _context.watch<ChatsPageProvider>();
        return Scaffold(
          body: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * 0.03,
              vertical: _deviceHeight * 0.02,
            ),
            height: _deviceHeight * 0.98,
            width: _deviceWidth * 0.97,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TopBar(
                  'Chats',
                  primaryAction: IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Color.fromRGBO(0, 82, 218, 1.0),
                    ),
                    onPressed: () async {
                      _auth.logout();
                    },
                  ),
                ),
                _chatList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chatList() {
    return Expanded(
      child: _chatTile(),
    );
  }

  Widget _chatTile() {
    return CustomListViewTileWithActivity(
      height: _deviceHeight * 0.10,
      title: "rgbetanco",
      subtitle: "Hello world",
      imagePath: "https://i.pravatar.cc/150?img=28",
      isActive: true,
      isActivity: false,
      onTap: () {},
    );
  }
}
