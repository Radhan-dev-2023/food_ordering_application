
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/HomeScreen.dart';



class UserProfile {
  String fullName;
  String email;
  String mobile;
  String bio;

  UserProfile(
      {required this.fullName,
      required this.email,
      required this.mobile,
      required this.bio});
}

class UserProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfileProvider();

  UserProfile? get userProfile => _userProfile;

  void saveUserProfile(UserProfile userProfile) {
    _userProfile = userProfile;
    notifyListeners();
  }
}

class Edit_ProfileScreen extends StatefulWidget {
  const Edit_ProfileScreen({
    Key? key,
  }) : super(key: key);

  //final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  State<Edit_ProfileScreen> createState() => _Edit_ProfileScreenState();
}

class _Edit_ProfileScreenState extends State<Edit_ProfileScreen> {
  // final TextEditingController _fullNameController = TextEditingController();
  late TextEditingController _fullNameController;

  late TextEditingController _emailController;

  late TextEditingController _mobileController;

  late TextEditingController _bioController;
  RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');



  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _bioController = TextEditingController();

    // Load saved data from shared preferences
    loadProfileData();
  }

  void loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullNameController.text = prefs.getString('fullName') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _mobileController.text = prefs.getString('mobile') ?? '';
      _bioController.text = prefs.getString('bio') ?? '';
    });
  }

  Future<void> _saveProfile() async {
    // Save data to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', _fullNameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('mobile', _mobileController.text);
    await prefs.setString('bio', _bioController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
   // final mediaQuery=MediaQuery.of(context);
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 58.0, left: 28),
                child: Row(
                  children: [
                    Container(
                      child: InkWell(
                        onTap: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => HomeScreen(
                                        frommyorders: true,
                                      )));
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey.shade300),
                      height: 40,
                      width: 40,
                    ),
                    SizedBox(width: 30),
                    Text(
                      'Profile',
                      style: TextStyle(
                          fontSize: 20 * textScaleFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
             Padding(
               padding: const EdgeInsets.all(12.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                 SizedBox(height: MediaQuery.sizeOf(context).height * 0.07),
                 Text(
                   "FULL NAME",
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 15* textScaleFactor,
                     color: Colors.grey.shade600,
                   ),
                 ),
                   SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                 TextField(
                   controller: _fullNameController,
                   style: TextStyle(color: Colors.white),
                   decoration: InputDecoration(
                     focusedBorder: OutlineInputBorder(
                       borderSide:
                       BorderSide(color: Colors.orange, width: 0.7),
                       borderRadius: BorderRadius.circular(10.0),
                     ),
                     enabledBorder: OutlineInputBorder(
                       borderSide:
                       BorderSide(color: Colors.orange, width: 0.7),
                       borderRadius: BorderRadius.circular(10.0),
                     ),
                     hintText: '  Please Enter Full Name',
                     hintStyle: TextStyle(color: Colors.blueGrey),
                     filled: true,
                     fillColor: Colors.blueGrey.withOpacity(0.1),
                   ),
                 ),
                 SizedBox(
                   height: MediaQuery.sizeOf(context).height * 0.04,
                 ),
                 Text(
                   "EMAIL",
                   style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: 15* textScaleFactor,
                       color: Colors.grey.shade600),
                 ),
                   SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                 TextField(
                   keyboardType: TextInputType.emailAddress,
                   controller: _emailController,
                   style: TextStyle(color: Colors.white),
                   decoration: InputDecoration(
                     focusedBorder: OutlineInputBorder(
                       borderSide: BorderSide(color: Colors.grey, width: 0.1),
                       borderRadius: BorderRadius.circular(10.0),
                     ),
                     enabledBorder: OutlineInputBorder(
                       borderSide:
                       BorderSide(color: Colors.orange, width: 0.7),
                       borderRadius: BorderRadius.circular(10.0),
                     ),
                     hintText: '  Please Enter Email Id',
                     hintStyle: TextStyle(color: Colors.blueGrey),
                     filled: true,
                     fillColor: Colors.blueGrey.withOpacity(0.1),
                   ),
                 ),
                 SizedBox(
                   height: MediaQuery.sizeOf(context).height * 0.04,
                 ),
                 Text(
                   "MOBILE",
                   style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: 15* textScaleFactor,
                       color: Colors.grey.shade600),
                 ),
                   SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                 TextField(
                   inputFormatters: [
                     FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                     LengthLimitingTextInputFormatter(10),
                   ],
                   keyboardType: TextInputType.phone,
                   controller: _mobileController,
                   style: TextStyle(color: Colors.white),
                   decoration: InputDecoration(
                     focusedBorder: OutlineInputBorder(
                       borderSide: BorderSide(color: Colors.grey, width: 0.1),
                       borderRadius: BorderRadius.circular(10.0),
                     ),
                     enabledBorder: OutlineInputBorder(
                       borderSide:
                       BorderSide(color: Colors.orange, width: 0.7),
                       borderRadius: BorderRadius.circular(10.0),
                     ),
                     hintText: '  Please Enter Mobile Number',
                     hintStyle: TextStyle(color: Colors.blueGrey),
                     filled: true,
                     fillColor: Colors.blueGrey.withOpacity(0.1),
                   ),
                 ),
                 SizedBox(
                   height: MediaQuery.sizeOf(context).height * 0.04,
                 ),
                 Text(
                   "FAVORITE FOOD",
                   style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: 15* textScaleFactor,
                       color: Colors.grey.shade600),
                 ),
                   SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                 TextField(
                   keyboardType: TextInputType.multiline,
                   controller: _bioController,
                   style: TextStyle(color: Colors.white),
                   decoration: InputDecoration(
                     focusedBorder: OutlineInputBorder(
                       borderSide: BorderSide(color: Colors.grey, width: 0.1),
                       borderRadius: BorderRadius.circular(10.0),
                     ),
                     enabledBorder: OutlineInputBorder(
                       borderSide:
                       BorderSide(color: Colors.orange, width: 0.7),
                       borderRadius: BorderRadius.circular(10.0),
                     ),
                     hintText: '  Eg: I love Fast Food',
                     hintStyle: TextStyle(color: Colors.blueGrey),
                     filled: true,
                     fillColor: Colors.blueGrey.withOpacity(0.1),
                   ),
                 ),
                 SizedBox(
                   height: MediaQuery.sizeOf(context).height * 0.05,
                 ),
                Center(child: Container(
                   height: MediaQuery.sizeOf(context).height * 0.07,
                   width: MediaQuery.sizeOf(context).width * 0.7,
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.orange,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(10),
                       ),
                     ),
                     onPressed: () {
                       if (!emailRegExp.hasMatch(_emailController.text)) {
                         showDialog(
                           context: context,
                           builder: (BuildContext context) {
                             return AlertDialog(
                               title: Text(
                                 "ALLDINE",
                                 style: TextStyle(
                                     fontWeight: FontWeight.bold,
                                     color: Colors.black,
                                     fontSize: 22),
                               ),
                               content: StatefulBuilder(
                                 builder:
                                     (BuildContext context, StateSetter setState) {
                                   return Text(
                                     "Please check your Email-id",
                                     style: TextStyle(
                                         color: Colors.orange,
                                         fontWeight: FontWeight.bold,
                                         fontSize: 18),
                                   );
                                 },
                               ),
                               actions: <Widget>[
                                 TextButton(
                                   onPressed: () {
                                     Navigator.of(context).pop();
                                   },
                                   child: Text(
                                     "OK",
                                     style: TextStyle(
                                       fontWeight: FontWeight.bold,
                                       color: Colors.black,
                                     ),
                                   ),
                                 ),
                               ],
                             );
                           },
                         );
                         return;
                       }
                       if (_mobileController.text.length !=10) {
                         showDialog(
                           context: context,
                           builder: (BuildContext context) {
                             return AlertDialog(
                               title: Text(
                                 "ALLDINE",
                                 style: TextStyle(
                                     fontWeight: FontWeight.bold,
                                     color: Colors.black,
                                     fontSize: 22),
                               ),
                               content: StatefulBuilder(
                                 builder:
                                     (BuildContext context, StateSetter setState) {
                                   return Text(
                                     "Please enter a 10-digit contact number.",
                                     style: TextStyle(
                                         color: Colors.orange,
                                         fontWeight: FontWeight.bold,
                                         fontSize: 18),
                                   );
                                 },
                               ),
                               actions: <Widget>[
                                 TextButton(
                                   onPressed: () {
                                     Navigator.of(context).pop();
                                   },
                                   child: Text(
                                     "OK",
                                     style: TextStyle(
                                       fontWeight: FontWeight.bold,
                                       color: Colors.black,
                                     ),
                                   ),
                                 ),
                               ],
                             );
                           },
                         );
                         return;
                       }
                       _saveProfile();
                       showSuccessDialog(context);
                     },
                     child: Text(
                       "SAVE",
                       style: TextStyle(color: Colors.black, fontSize: 20,fontWeight: FontWeight.bold),
                     ),
                   ),
                 ),),
                 SizedBox(
                   height: MediaQuery.sizeOf(context).height * 0.04,
                 ),
               ],),
             )
            ],
          ),
        ));
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "ALLDINE",
          style: TextStyle(
            fontSize: 18,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Your Profile Updated Successfully",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
            child: const Text(
              "OK",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
