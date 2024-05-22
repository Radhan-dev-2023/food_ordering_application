import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';
import 'LoginScreen.dart';

class OtpLogin extends StatefulWidget {


  OtpLogin({Key? key,this.verificationId}) : super(key: key);
String? verificationId;
  @override
  State<OtpLogin> createState() => _OtpLoginState();
}

class _OtpLoginState extends State<OtpLogin> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  late String userId;
  late String mobileNumber;
  late String fcmtoken = "";
  bool isLoading = false;

  getUserInformation() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userId = user.uid;
      mobileNumber = user.phoneNumber!;
      print('User ID: $userId');
      print('Mobile Number: $mobileNumber');
    }
  }

  Future<void> _saveUserDataToDatabase(
      String userId, String mobileNumber, String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save data to shared preferences

    prefs.setString('userId', userId);
    prefs.setString('mobileNumber', mobileNumber);
    prefs.setString('fcmtoken', token);

    // Saving the fcm token

    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    databaseReference.child("users").child(userId).update(
        {'userId': userId, 'mobileNumber': mobileNumber, 'fcm_token': token});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.orange),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Colors.orange,
      ),
    );
    var code = "";
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl:
                    "https://media.tenor.com/2yQv-RptjeQAAAAC/fastfood.gif",
                width: 350,
                height: 350,
                placeholder: (context, url) => const CircularProgressIndicator(
                  color: Colors.orange,
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  size: 20,
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.001,
              ),
              const Text(
                "OTP Verification",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.03,
              ),
              const Text(
                "Enter your OTP code number",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.04,
              ),
              Pinput(
                androidSmsAutofillMethod:
                    AndroidSmsAutofillMethod.smsRetrieverApi,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                onChanged: (value) {
                  code = value;
                },
                showCursor: true,
                onCompleted: (pin) => print(pin),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.04,
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.5,
                height: MediaQuery.sizeOf(context).height * 0.06,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    // try {
                    //   setState(() {
                    //     isLoading = true;
                    //   });
                    //   otpalert(smsCode: code);
                    // } catch (e) {
                    //   print("Error: $e");
                    //   showDialog(
                    //     context: context,
                    //     builder: (BuildContext context) {
                    //       return AlertDialog(
                    //         title: const Text(
                    //           "ALLDINE",
                    //           style: TextStyle(
                    //             fontSize: 18,
                    //             color: Colors.orange,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //         content: const Text(
                    //           "Wrong OTP",
                    //           style: TextStyle(
                    //             fontSize: 18,
                    //             color: Colors.black,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //         actions: <Widget>[
                    //           TextButton(
                    //             style: ElevatedButton.styleFrom(
                    //               backgroundColor: Colors.orange,
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(7),
                    //               ),
                    //             ),
                    //             onPressed: () {
                    //               Navigator.of(context).pop();
                    //             },
                    //             child: const Text("OK"),
                    //           ),
                    //         ],
                    //       );
                    //     },
                    //   );
                    // }
                    if (code.isNotEmpty) {
                      // PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode: code);
                      // await auth.signInWithCredential(credential);
                      otpAlert(smsCode: code);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.orange,
                            content: Text("Please Enter your OTP")),
                      );
                    }
                  },
                  child: const Text(
                    "VERIFY OTP",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const MobileLogin()));
                    },
                    child: const Text(
                      "Edit Phone Number ?",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void otpAlert({required String smsCode}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: "${widget.verificationId}", smsCode: smsCode);
      UserCredential userData = await auth.signInWithCredential(credential);
      String? token = await _fcm.getToken();
      if (userData.user == null || token == null) {
        return;
      }
      _saveUserDataToDatabase(
        userData.user!.uid,
        userData.user?.phoneNumber ?? "+0",
        token,
      ).then((_) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const HomeScreen(),
            ),
          );
        });
      });
    } catch (error) {
      print("Error signing in with credential: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Incorrect OTP. Please Check again."),
        ),
      );
    }
  }
}
