import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/media/media_item.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/messages.dart';
import 'package:flutter_application_1/pages/user_profile_page.dart';
import 'package:provider/provider.dart';

class UserDiscovery extends StatefulWidget {
  const UserDiscovery({super.key});
  @override
  State<UserDiscovery> createState() => _UserDiscoveryState();
}

class _UserDiscoveryState extends State<UserDiscovery> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _mediaStream;
  late String? currentUserId;
  int _selectedIndex = 1;

  late Future <DocumentSnapshot> fUserOfInterest;
  late Future<String?> fUserIdOfInterest;
  late Future<String?> fUserNameOfInterest;
  late Future<List<DocumentSnapshot>> fUserListOfInterest;
  //late Future<List<DocumentSnapshot>> fUserIdOfInterest;
  //late Future<List<DocumentSnapshot>> fUserNameOfInterest;

  Future<List<DocumentSnapshot>> fetchUsersOfInterest() async{
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await _firestore.collection('users').where(FieldPath.documentId, isNotEqualTo: currentUserId).get();

    return querySnapshot.docs;
  }

    Future<DocumentSnapshot> fetchLoggedInUser() async{
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await _firestore.collection('users').where(FieldPath.documentId, isEqualTo: currentUserId).get();

    return querySnapshot.docs.first;
  }

    Future<String?> fetchUserIdOfInterest() async{
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await _firestore.collection('users').where(FieldPath.documentId, isNotEqualTo: currentUserId).get();

    return querySnapshot.docs.first.id;
  }    
  
    Future<String?> fetchUserNameOfInterest() async{
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await _firestore.collection('users').where(FieldPath.documentId, isNotEqualTo: currentUserId).get();

    return (querySnapshot.docs.first.data() as Map<String, dynamic>)['username'];
  }

  void onLike(String userOfInterestId) {
      _firestore.collection('users').doc(currentUserId).update({
        'likes': FieldValue.arrayUnion([userOfInterestId])
      });
    //TODO: handle the 'like' action
    //fetch the next profile
    //setState
  }

  void onDislike(String userOfInterestId) {
      _firestore.collection('users').doc(currentUserId).update({
        'dislikes': FieldValue.arrayUnion([userOfInterestId])
      });
    //TODO: handle the 'dislike' action
    //fetch the next profile
    //setState
  }

  @override
  void initState() {
    super.initState();
    fUserListOfInterest = fetchUsersOfInterest();
    fUserIdOfInterest = fetchUserIdOfInterest();
    fUserNameOfInterest = fetchUserNameOfInterest();
    currentUserId = Provider.of<UserModel>(context, listen: false).userId;
    // Loads the media for the current user
    _mediaStream = _firestore.collection('media').snapshots();

  }

  void _onItemTapped(int index) async{
    if (index == _selectedIndex) {
      return;
      //prevent navigation to the same page
    }

    setState(() {
      _selectedIndex = index;
    });
    Widget page;
    switch (index) {
      case 0:
        page = const UserProfile();
        break;
      case 1:
        return;
      case 2:
      String? userIdOfInterest = await fUserIdOfInterest;
      String? userNameOfInterest = await fUserNameOfInterest;
        page = Messages(receiverUserId: userIdOfInterest, receiverUserName: userNameOfInterest);
        //page = const Messages();
        break;
      default:
        return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page,
        ));
  }

  Widget buildUserPage(DocumentSnapshot<Map<String, dynamic>> userOfInterest){
    _mediaStream = _firestore.collection('media').where('userId', isEqualTo: userOfInterest.id).snapshots();
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          CircleAvatar(
            backgroundImage:
                NetworkImage(userOfInterest.data()?['imageUrl'] ?? ''),
            radius: 60,
          ),
          Text(
            //currentProfile?.data()?['username'] 
            userOfInterest.data()?['username'] ?? 'no name provided',
            style: const TextStyle(fontSize: 24),
          ),
          Text(
            userOfInterest.data()?['userBio'] ?? 'no bio provided',
            style: const TextStyle(fontSize: 16),
          ),
          Wrap(
            spacing: 8.0,
            children: List<Widget>.from(
                userOfInterest.data()?['instruments']?.map((instrument) {
                      return Chip(label: Text(instrument));
                    }) ??
                    []),
          ),


          // display media items
          StreamBuilder<QuerySnapshot>(
            stream: _mediaStream,
            builder: (context, snapshot) {
              //if (_mediaStream == null) {
              //  return const Text('Media stream not initialized');
              //}
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());

                default:
                //return const Column(children: [Text('no media to display for now')],);
                
                  if (snapshot.data?.docs.isEmpty ?? true) {
                    // Display a friendly message when there's no media
                    return const Column(
                      children: [
                        Text('No media yet, add your first item!'),
                      ],
                    );
                  } else {
                    // Display media items in a grid view
                    return Center(
                        child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600
                            ? 4
                            : 3, // Adjust grid columns based on screen width
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot mediaDoc = snapshot.data!.docs[index];
                        return MediaItem(
                          mediaDoc: mediaDoc,
                          onDelete: () => {},
                        );
                      },
                    ));
                  }
                  
              }
            },
          ),

          //add the buttons to like or dislike and message that specific user
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                  onPressed: () => onDislike(userOfInterest.id),
                  icon: const Icon(
                    Icons.close,
                    size: 50,
                    color: Colors.red,
                  )),
              IconButton(
                  onPressed: () => onLike(userOfInterest.id),
                  icon: const Icon(
                    Icons.favorite,
                    size: 50,
                    color: Colors.green,
                  )),
              IconButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Messages(
                          receiverUserId: userOfInterest.id,
                          receiverUserName: userOfInterest.data()?['username'],
                          )
                        )
                      );
                  },
                                    
                  // => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context){
                  //           return FutureBuilder<Messages>(
                  //             future: () async{
                  //               //fUserIdOfInterest = userOfInterest.id as Future<String?>;
                  //               //fUserNameOfInterest = userOfInterest.data()?['username'];
                  //               String? userIdOfInterest = await fUserIdOfInterest;
                  //               String? userNameOfInterest = await fUserNameOfInterest;
                  //               return Messages(receiverUserId: userIdOfInterest, receiverUserName: userNameOfInterest);
                  //             } (),
                  //             builder:(context, snapshot) {
                  //               if (snapshot.connectionState == ConnectionState.waiting) {
                  //                 return const CircularProgressIndicator();
                  //               } else if(snapshot.hasError) {
                  //                 return Text('error: ${snapshot.error}');
                  //               } else {
                  //                 return snapshot.data!;
                  //               }
                  //             }, 
                  //           );
                  //         },
                  //       )),

                  icon: const Icon(
                    Icons.message,
                    size: 50,
                    color: Colors.blue,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('User Discovery')),
        automaticallyImplyLeading: false, //this disables back arrow
        actions: <Widget>[
          IconButton(
            onPressed: () async{
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const LoginPage()));
            }, 
            icon: const Center(child: Icon(Icons.logout),))
        ],
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fUserListOfInterest,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
              );
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty){
            return const Center(
              child: Text('no users found'),
              );
          }

          return
          PageView.builder(
            itemCount:  snapshot.data!.length,
            itemBuilder: (context, index) {
              var users = snapshot.data!
              .where((doc) => doc.id != FirebaseAuth.instance.currentUser!.uid)
              .toList();
              DocumentSnapshot<Map<String, dynamic>> userOfInterest = users[index] as DocumentSnapshot<Map<String, dynamic>>;
              return buildUserPage(userOfInterest);
            },
          );
        },
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', //profile page (picture, bio, media, etc.)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
