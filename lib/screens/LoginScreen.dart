import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helpers/alert_dialog.dart';
import 'OTPScreen.dart';

class MobileLogin extends StatefulWidget {
  const MobileLogin({Key? key}) : super(key: key);

  static String verify = "";

  @override
  State<MobileLogin> createState() => _MobileLoginState();
}

class _MobileLoginState extends State<MobileLogin> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController countrycode = TextEditingController();
  var phone = "";
  final FocusNode _phoneNumberFocusNode = FocusNode();
  bool isLoading = false;

  @override
  void initState() {
    countrycode.text = "+91";
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant,
                  size: 200, color: Colors.orangeAccent),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              const Text(
                "LOGIN",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              const Text(
                "Add your Phone Number, we'll send an OTP to see that you're real",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 2,
                  color: Colors.brown,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.orangeAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.03,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.09,
                      child: TextField(
                        style: const TextStyle(color: Colors.black),
                        controller: countrycode,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Text(
                      "|",
                      style: TextStyle(fontSize: 33, color: Colors.grey),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.03,
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.orange),
                        onChanged: (value) {
                          phone = value;
                        },
                        focusNode: _phoneNumberFocusNode,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Mobile Number",
                          hintStyle: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.06,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (phone.length !=10) {
                      showMyDialog(context,"Please enter 10-Digit numbers");
                    }
                    else if(phone.isEmpty){
                      showMyDialog(context,"Please enter valid mobile numbers");
                    }
                    else {
                      setState(() {
                        isLoading = true;
                      });

                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: countrycode.text + phone,
                        timeout: const Duration(minutes: 1),
                        verificationCompleted:
                            (PhoneAuthCredential credential) async {
                             await auth.signInWithCredential(credential);
                            },
                        verificationFailed: (FirebaseAuthException e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                                backgroundColor: Colors.orange,
                                content: Text("${e.message}")
                            ),
                          );
                        },
                        codeSent: (String verificationId, int? resendToken) {
                          setState(() {
                            isLoading = false;
                          });
                         // MobileLogin.verify = verificationId;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  OtpLogin(verificationId: verificationId,)),


                          );


                        },
                        codeAutoRetrievalTimeout: (String verificationId) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                                backgroundColor: Colors.orange,
                                content: Text("OTP Timeout\nPlease Resend OTP again")
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        )
                      : const Text(
                          "GET OTP",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

