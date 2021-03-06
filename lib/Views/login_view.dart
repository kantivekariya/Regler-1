import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Classes/preferances.dart';
import 'package:flutter_app/Classes/strings.dart';
import 'package:flutter_app/Models/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './User/home_page.dart';
import './Admin/admin_home_view.dart';
import 'package:flare_flutter/flare_actor.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.title,
      home: HomePage(),
      theme: ThemeData(
          fontFamily: Strings.fontFamily,
          primarySwatch: Colors.red,
          brightness: Brightness.dark,
          accentColor: Colors.red),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  Widget lgForm;

  String _userId;
  String _password;

  LoginModel loginModel;

  @override
  void initState() {
    loginModel = LoginModel();
    _setBackForm();
    super.initState();
  }

  void _submit() async {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      _setLoading();
      String res = await loginModel.auth(_userId, _password);

      _gotoHome(res);
    }
  }

  _setLoading() {
    setState(() {
      lgForm = SizedBox(
        height: 200,
        width: 200,
        child: FlareActor(
          Strings.dropLoadFlr,
          animation: Strings.dropLoadFlrAnimtion,
        ),
      );
    });
  }

  _setBackForm() {
    setState(() {
      lgForm = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 130.0,
            height: 130.0,
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage(Strings.rLogoTeal),
                repeat: ImageRepeat.repeat,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formKey,
              child: Theme(
                data: ThemeData(
                    brightness: Brightness.dark,
                    primarySwatch: Colors.teal,
                    fontFamily: Strings.fontFamily,
                    inputDecorationTheme: InputDecorationTheme(
                        labelStyle:
                            TextStyle(color: Colors.teal, fontSize: 17.0))),
                child: Container(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: Strings.enterUserIdMsg),
                        validator: (val) {
                          if (val.length > 12 || val.isEmpty) {
                            return Strings.errorInvaliduserID;
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => _userId = val,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: Strings.enterPasswordMsg),
                        validator: (val) =>
                            val.length < 8 ? Strings.errorPasswordShort : null,
                        onSaved: (val) => _password = val,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                      ),
                      Padding(padding: const EdgeInsets.only(top: 20.0)),
                      MaterialButton(
                        height: 40.0,
                        minWidth: 200.0,
                        color: Colors.teal,
                        textColor: Colors.white,
                        child: Text(Strings.btnLogin),
                        onPressed: () {
                          _submit();
                        },
                        splashColor: Colors.tealAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      );
    });
  }

  void _gotoHome(String role) {
    if (role == Strings.roleUser) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => UserMainPage()));
    } else if (role == Strings.roleDirector || role == Strings.roleAdmin) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => AdminHomeView()));
    } else if (role == Strings.userBlocked) {
      _setBackForm();
      showSnakbar(Strings.userBlockMessage);
    } else if (role == Strings.internetEr) {
      _setBackForm();
      showSnakbar(Strings.internetErrorMsg);
    } else {
      _setBackForm();
      showSnakbar(Strings.invalidUserMessage);
    }
  }

  void showSnakbar(String msg) {
    final snackbar = SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Future<bool> setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(Strings.keyIsLoggedin) == null) {
      return false;
    }
    Preferances.id = prefs.getInt(Strings.keyId);
    Preferances.name = prefs.getString(Strings.keyName);
    Preferances.role = prefs.getString(Strings.keyRole);
    Preferances.instituteid = prefs.getString(Strings.keyInsId);
    Preferances.institute = prefs.getString(Strings.keyIns);
    Preferances.imgurl = prefs.getString(Strings.keyImgUrl);
    Preferances.limit = prefs.getString(Strings.keyLimit);
    Preferances.use = prefs.getString(Strings.keyUse);
    Preferances.bal = prefs.getString(Strings.keyBal);
    Preferances.isLoggedin = prefs.getBool(Strings.keyIsLoggedin);
    return Preferances.isLoggedin;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.data) {
          if (Preferances.role == Strings.roleAdmin ||
              Preferances.role == Strings.roleDirector) {
            return AdminHomeView();
          } else {
            return UserMainPage();
          }
        }
        return Scaffold(
            key: scaffoldKey,
            body: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image(
                  image: AssetImage(Strings.loginBackgroundImage),
                  fit: BoxFit.cover,
                  color: Colors.black87,
                  colorBlendMode: BlendMode.darken,
                ),
                Center(
                  child: SingleChildScrollView(child: lgForm),
                )
              ],
            ));
      },
    );
  }
}
