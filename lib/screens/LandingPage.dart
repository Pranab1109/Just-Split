import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_split/Services/FirebaseFirestoreRepo.dart';
import 'package:just_split/bloc/auth/auth_bloc.dart';
import 'package:just_split/screens/LoginPage.dart';
import 'package:just_split/screens/RoomDetailScreen.dart';
import 'package:just_split/utils/Cooloors.dart';
import 'package:just_split/utils/CreateAndJoinRoomModalSheet.dart';
import 'package:just_split/utils/RoomTile.dart';
import '../utils/OnWillPop.dart';

import 'package:just_split/screens/PersonalSettlementsScreen.dart';

class LandingPage extends StatelessWidget {
  LandingPage({
    super.key,
    required this.user,
  });
  final User user;

  final TextEditingController roomEditingController = TextEditingController();
  final TextEditingController joinEditingController = TextEditingController();
  final Cooloors cooloors = Cooloors();
  final _formKey = GlobalKey<FormState>();
  final _formKeyTwo = GlobalKey<FormState>();

  void _signOut(context) async {
    bool signout = await onWillPop(context);
    if (signout) {
      BlocProvider.of<AuthBloc>(context).add(
        SignOutRequested(),
      );
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  void addRoom(context) {
    if (_formKey.currentState!.validate()) {
      RepositoryProvider.of<FirebaseFirestoreRepo>(context)
          .addRoom(roomEditingController.text, user);
      roomEditingController.text = "";
      Navigator.pop(context);
    }
  }

  Future<void> joinRoom(context) async {
    if (_formKeyTwo.currentState!.validate()) {
      dynamic res = await RepositoryProvider.of<FirebaseFirestoreRepo>(context)
          .joinRoom(roomCode: joinEditingController.text);
      roomEditingController.text = "";
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.down,
          padding: const EdgeInsets.all(0),
          content: Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              color: !res["success"]
                  ? Theme.of(context).colorScheme.error
                  : const Color(0xFF34D399),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: Cooloors.neoShadow,
            ),
            child: Center(
              child: Text(
                res["message"],
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void deleteRoom(context, roomUID, userRoomID, roomID) {
    RepositoryProvider.of<FirebaseFirestoreRepo>(context)
        .deleteRoom(roomDocID: roomUID, userRoomID: userRoomID, roomID: roomID);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Stream documentStream = FirebaseFirestore.instance
        .collection('USERS')
        .doc(user.uid.toString())
        .collection("rooms")
        .orderBy("time", descending: true)
        .snapshots();
        
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Just Split",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 26,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          const ThemeToggle(),
          IconButton(
            onPressed: () => _signOut(context),
            icon: Icon(Icons.logout_rounded, color: colorScheme.onSurface),
          ),
        ],
      ),
      body: Column(
        children: [
          // Global Balances Summary Card (Neo-brutalist)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PersonalSettlementsScreen(user: user),
                ));
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primary, // Vibrant purple
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: Cooloors.neoShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Global Balances", style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text("See your net standing", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900)),
                          Text("across all groups", style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Rooms",
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w900),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("View All", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: StreamBuilder<dynamic>(
                stream: documentStream,
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasError) return Center(child: Text('Error loading rooms', style: TextStyle(color: colorScheme.onSurface)));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                  }
                  
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 3),
                              boxShadow: Cooloors.neoShadow,
                            ),
                            child: Icon(Icons.maps_home_work_rounded, size: 80, color: colorScheme.onSurface),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "No rooms found",
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              "Create a room to start splitting bills with your friends!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RoomDetailScreen(
                                roomID: data["roomUID"],
                                roomName: data["roomName"],
                                roomCode: data["roomID"],
                              ),
                            ));
                          },
                          child: roomTile(context, data, document, deleteRoom),
                        ),
                      );
                    },
                  );
                }),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Theme.of(context).scaffoldBackgroundColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: "Join",
                    icon: Icons.group_add_rounded,
                    onPressed: () => _showModal(context, true),
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: "Create",
                    icon: Icons.add_rounded,
                    onPressed: () => _showModal(context, false),
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isPrimary ? colorScheme.primary : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: Cooloors.neoShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isPrimary ? Colors.black : colorScheme.onSurface, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.black : colorScheme.onSurface, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModal(BuildContext context, bool isJoin) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        side: BorderSide(color: Colors.black, width: 4),
      ),
      context: context,
      builder: (context) => createAndJoinRoomModalSheet(
        context,
        cooloors,
        _formKey,
        _formKeyTwo,
        roomEditingController,
        joinEditingController,
        addRoom,
        joinRoom,
        isJoin,
      ),
    );
  }
}
