import 'package:flutter/material.dart';
import 'package:pizarro_app/models/chat_user.dart';
import 'package:pizarro_app/providers/authentication_provider.dart';
import 'package:pizarro_app/providers/users_page_provider.dart';
import 'package:pizarro_app/widgets/custom_input_fields.dart';
import 'package:pizarro_app/widgets/custom_list_view_tiles.dart';
import 'package:provider/provider.dart';

import '../widgets/rounded_button.dart';
import '../widgets/top_bar.dart';

class UsersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UsersPageState();
  }
}

class UsersPageState extends State<UsersPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late UsersPageProvider _pageProvider;

  final TextEditingController _searchFieldTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsersPageProvider>(
          create: (_) => UsersPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(builder: (BuildContext _context) {
      _pageProvider = _context.watch<UsersPageProvider>();
      return Container(
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopBar(
              'Users',
              primaryAction: IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Color.fromRGBO(0, 82, 218, 1.0),
                ),
                onPressed: () {
                  _auth.logout();
                },
              ),
            ),
            CustomTextField(
              onEditingComplete: (_value) {
                _pageProvider.getUsers(name: _value);
                FocusScope.of(context).unfocus();
              },
              hintText: "Search...",
              obscureText: false,
              controller: _searchFieldTextEditingController,
              icon: Icons.search,
            ),
            _usersList(),
            _createChatButton(),
            SizedBox(
              height: _deviceHeight * 0.02,
            ),
            _createTripButton(),
            SizedBox(
              height: _deviceHeight * 0.05,
            ),
          ],
        ),
      );
    });
  }

  Widget _usersList() {
    List<ChatUser>? _users = _pageProvider.users;
    return Expanded(child: () {
      if (_users != null) {
        if (_users.length != 0) {
          return ListView.builder(
            itemCount: _users.length,
            itemBuilder: (BuildContext _context, int _index) {
              if (_users[_index].uid == _auth.user.uid) {
                return CustomListViewTile(
                  height: _deviceHeight * 0.10,
                  title: "me",
                  subtitle: "Last Active: ${_users[_index].lastDayActive()}",
                  imagePath: _users[_index].imageURL,
                  isActive: _users[_index].wasRecentlyActive(),
                  isSelected: _pageProvider.selectedUsers.contains(
                    _users[_index],
                  ),
                  onTap: () {},
                );
              } else {
                return CustomListViewTile(
                  height: _deviceHeight * 0.10,
                  title: _users[_index].name,
                  subtitle: "Last Active: ${_users[_index].lastDayActive()}",
                  imagePath: _users[_index].imageURL,
                  isActive: _users[_index].wasRecentlyActive(),
                  isSelected: _pageProvider.selectedUsers.contains(
                    _users[_index],
                  ),
                  onTap: () {
                    _pageProvider.updateSelectedUsers(
                      _users[_index],
                    );
                  },
                );
              }
            },
          );
        } else {
          return Center(
            child: Text(
              "No Users Found.",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          );
        }
      } else {
        return Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }
    }());
  }

  Widget _createChatButton() {
    return Visibility(
      visible: _pageProvider.selectedUsers.isNotEmpty,
      child: RoundedButton(
        name: _pageProvider.selectedUsers.length == 1
            ? "Chat With ${_pageProvider.selectedUsers.first.name}"
            : "Create Group Chat",
        height: _deviceHeight * 0.05,
        width: _deviceWidth * 0.60,
        onPressed: () {
          _pageProvider.createChat();
        },
      ),
    );
  }

  Widget _createTripButton() {
    return Visibility(
      visible: _pageProvider.selectedUsers.isNotEmpty,
      child: RoundedButton(
        name: _pageProvider.selectedUsers.length == 1
            ? "Travel With ${_pageProvider.selectedUsers.first.name}"
            : "Create Group Trip",
        height: _deviceHeight * 0.05,
        width: _deviceWidth * 0.60,
        onPressed: () {
          _pageProvider.createTrip();
        },
      ),
    );
  }
}
