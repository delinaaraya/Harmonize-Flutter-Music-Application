import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/user_discovery.dart';
import 'package:flutter_application_1/pages/user_profile_page.dart';
import 'package:provider/provider.dart';

class Messages extends StatefulWidget {
  final String ? receiverUserId;
  final String ? receiverUserName;

  //const Messages({Key? key}) : super(key: key); // Fixed constructor syntax
  const Messages({Key? key, required this.receiverUserId, required this.receiverUserName}) : super(key: key);
  @override
  State<Messages> createState() => _MessagesState();  
}

class _MessagesState extends State<Messages> {
  int _selectedIndex = 2;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late String ? userId;
  late String ? userName;

  @override
  void initState() {
    super.initState();
    
    Future.delayed(Duration.zero, (){
        userId = Provider.of<UserModel>(context, listen: false).userId;
        _firestore.collection('users').doc(userId).get().then((DocumentSnapshot<Map<String, dynamic>> snapshot){
          if (snapshot.exists) {
            userName = snapshot.data()! ['username'];
          }
        });
    });
    //TODO: hard coded for now but should be replaced with info from user discovery page
        //receiverUserId = 'cuzV5SM2vkYcmD5sxVG37GpOeiD3';
        //receiverUserName = 'newuser';
  }

  Future<String?> fetchUserId() async{
    await Future.delayed(Duration.zero);
    userId = Provider.of<UserModel>(context, listen: false).userId;
    return userId;
  }

  void sendMessage(String receiverUserId, String message) async {
    if(message.trim().isEmpty){
      return;
    }
     try {
       //save message to firestore 'messages' collection
      await _firestore.collection('messages').add ({
        'senderId': userId, 
        'receiverId': receiverUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'content': message.trim(),
      });
      _messageController.clear();
     } catch (error) {  
      print('error sending message: $error');
     } 
    }

void _onItemTapped(int index) {
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
        page = const UserDiscovery();
        break;
      case 2:
        return;
      default:
        return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page,
        ));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Messages with ${widget.receiverUserName}')),
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
      
      body: FutureBuilder<String?>(
        //stream of matches where the user is involved
        future: fetchUserId(),
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done){ // ERROR 1: Fixed equality operator
            return const Center(child: CircularProgressIndicator(),);
          } 
          final userId = snapshot.data;
          if (userId == null) {
            return const Center(
              child: Text('userId not found'));
          }
          return Column(
            children: <Widget>[
              Center(
                child: Text("$widget.receiverUserName"),
                ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('messages').where('senderId', isEqualTo: userId).snapshots(),
                  builder: (context, snapshot){
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(),);
                    }

                    var messages = snapshot.data!.docs;
                    messages.sort((a, b){
                      var aData = a.data() as Map<String, dynamic>;
                      var bData = b.data() as Map<String, dynamic>;
                      var aTimestamp = aData['timestamp'] as Timestamp?;
                      var bTimestamp = bData['timestamp'] as Timestamp?;
                      if (aTimestamp == null  || bTimestamp == null) {
                        return 0;
                      }
                      return bTimestamp.compareTo(aTimestamp);                      
                    });
                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index){
                        var message = messages[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(
                            "${message['content']}: ${message['timestamp'].toDate()}"
                          ),
                        );
                      },
                    );
                  },
                )
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Enter your message here...",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: ()=> sendMessage(widget.receiverUserId!, _messageController.text),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                ),
                )
            ],
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
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
