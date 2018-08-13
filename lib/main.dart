import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoggedIn = false;
  var profileData;

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Facebook Login"),
        ),
        body: Container(
          child: Center(
            child: isLoggedIn
                ? Text("Logged in as: ${profileData['name']}")
                : RaisedButton(
                    child: Text("Login with Facebook"),
                    onPressed: () => initiateFacebookLogin(),
                  ),
          ),
        ),
      ),
    );
  }

  void initiateFacebookLogin() async {
    var facebookLogin = FacebookLogin();
    var facebookLoginResult =
        await facebookLogin.logInWithReadPermissions(['email']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${facebookLoginResult
                .accessToken.token}');
        var profile = json.decode(graphResponse.body);
        print(profile.toString());
        onLoginStatusChanged(true, profileData: profile);
        break;
    }
  }
}
