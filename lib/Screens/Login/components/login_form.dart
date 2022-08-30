import 'package:flutter/material.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../../controllers.dart';
import '../../Home/home.dart';
import '../../Signup/signup_screen.dart';
import 'package:get/get.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import '../../../shared_prefs.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // final formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final Controller c = Get.find();


  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            decoration: InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "login_btn",
            child: ElevatedButton(
              onPressed: () {
                _doLogin();
              },
              child: Text(
                "Login".toUpperCase(),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  _doLogin() async {
    const baseUrl='https://pos.vitraining.com';
    const db='pos.vitraining.com';
    final client = OdooClient(baseUrl);
    try {
      final session = await client.authenticate(db, _usernameController.text, _passwordController.text);
      
      final prefs = SharedPref();
      prefs.saveObject('session', session); 
      prefs.saveString('baseUrl', baseUrl);
      prefs.saveString('db', db);


      c.setCurrentUser(session.userName);
      c.setDb(db);
      c.setBaseUrl(baseUrl);
      c.loggedIn();
      
      Get.to(Home());

    } on Exception catch (e) {
      client.close();
      showDialog(context: context, builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            Center(child: Text(e.toString()))
          ]);
      });
    }
    client.close();
  }

}
