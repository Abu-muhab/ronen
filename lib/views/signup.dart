import 'package:flutter/material.dart';
import 'package:ronen/globals.dart';

class Signup extends StatefulWidget {
  @override
  State createState() => SignupState();
}

class SignupState extends State<Signup> {
  bool agreedToTerms = false;
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
                  Column(
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
                        child: TextField(
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
                        child: TextField(
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
                          onPressed: () {},
                          child: Text(
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
                          // mainAxisSize: MainAxisSize.min,
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
