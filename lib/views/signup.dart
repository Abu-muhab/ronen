import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ronen/globals.dart';
import 'package:ronen/providers/auth.dart';
import 'package:ronen/util.dart';

class Signup extends StatefulWidget {
  @override
  State createState() => SignupState();
}

class SignupState extends State<Signup> {
  bool agreedToTerms = false;
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColorLight,
        title: Text('Create Account'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                  tileMode: TileMode.mirror,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    kPrimaryColorDark,
                    kPrimaryColorLight,
                  ]).createShader(bounds);
            },
            child: Container(
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SafeArea(
                child: Center(
              child: ListView(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'RONEN',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: TextFormField(
                            controller: emailController,
                            validator: (val) {
                              if (val.length == 0) {
                                return "Enter email";
                              }

                              if (!validateEmail(val.trim())) {
                                return "Invalid Email";
                              }

                              return null;
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: TextFormField(
                            controller: passwordController,
                            validator: (val) {
                              if (val.length < 6) {
                                return "Password must be atleast 6 characters";
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.white),
                            obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 50,
                          child: RaisedButton(
                            color: Colors.blueAccent,
                            onPressed: agreedToTerms == false
                                ? null
                                : () async {
                                    if (formKey.currentState.validate()) {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      setState(() {
                                        isLoading = true;
                                      });
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .signup(
                                              email:
                                                  emailController.text.trim(),
                                              password: passwordController.text
                                                  .trim())
                                          .then((value) {
                                        if (value == true) {
                                          Navigator.pop(context);
                                        }
                                      }).catchError((err) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: Text(err.toString()),
                                                actions: [
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "OKAY",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blueAccent),
                                                      ))
                                                ],
                                              );
                                            });
                                      });
                                    }
                                  },
                            child: isLoading == true
                                ? Center(
                                    child: SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : Text(
                                    'Create Account',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Theme(
                                  data: ThemeData(
                                      primarySwatch: Colors.blue,
                                      unselectedWidgetColor: Colors.blue),
                                  child: Checkbox(
                                      value: agreedToTerms,
                                      onChanged: (val) {
                                        setState(() {
                                          agreedToTerms = val;
                                        });
                                      })),
                              Text(
                                "I agree to the ",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "RONEN",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                " subscriber agreement and i am 13 years of age or older",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )),
          )
        ],
      ),
    );
  }
}
