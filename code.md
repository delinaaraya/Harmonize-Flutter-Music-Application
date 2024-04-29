# Code Snippets

## User Model

```dart
import 'package:flutter/material.dart';

class UserModel with ChangeNotifier{
  String? _userId;
  String? get userId => _userId;
  void setUserId(String userId) {_userId = userId; notifyListeners();}
}
```

## Like, Dislike, & Messaging Buttons

```dart
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
                  icon: const Icon(
                    Icons.message,
                    size: 50,
                    color: Colors.blue,
                  )),
            ],
          ),
```

## Media Upload

```dart
  Future<void> uploadMedia(String userId, File mediaFile, String type) async {
    String fileName;
    // Generate a unique file name
    switch (type) {
      case 'image':
        fileName = 'images/${userId}_${DateTime.now().millisecondsSinceEpoch}';
        break;
      case 'video':
        fileName = 'videos/${userId}_${DateTime.now().millisecondsSinceEpoch}';
        break;
      case 'audio':
        fileName = 'audio/${userId}_${DateTime.now().millisecondsSinceEpoch}';
        break;
      default:
        throw 'Invalid media type';
    }

    // Upload to Firebase Storage
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.putFile(mediaFile);

    // Get the download URL
    String downloadUrl = await ref.getDownloadURL();

    // Save media item to Firestore
    await FirebaseFirestore.instance.collection('media').add({
      'userId': userId,
      'url': downloadUrl,
      'type': type, // 'image', 'video', 'audio'
    });
  }
```

## User Authentication
```dart
class Authentication {
  // sign in with email and password
  static Future signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } catch (error) {
      return null;
    }
  }

  // create user with email and password
  static Future createUserWithEmailAndPassword(
      String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } catch (error) {
      return null;
    }
  }
}
```
