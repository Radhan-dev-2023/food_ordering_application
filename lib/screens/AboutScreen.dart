import 'package:flutter/material.dart';

import '../Screens/HomeScreen.dart';



class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: false,
        leading: InkWell(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) =>  HomeScreen(frommyorders: true
              ,)));
          },
        ),
        backgroundColor: Colors.orange,
        title: const Padding(
          padding:  EdgeInsets.symmetric(horizontal: 18.0),
          child:Text(
            'About Alldine',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height*0.03),
            const Text(
              'Welcome to Alldine!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.orange
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height*0.04),
            Text(
              'Have you ever been stuck in a meeting that refuses to end and started eating into your break time? Do you wish that you could go to the food court and have hot food ready to be served to you? Not to worry, you are at the right place.',
              style: TextStyle(fontSize: 18,height: MediaQuery.sizeOf(context).height*0.002,color: Colors.grey.shade300,fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height*0.04),
            Text(
              'Alldine has reinvented the idea of food ordering to ensure that it makes the process of ordering, preparing, and collecting food easy on both the customers and the restaurants. We, as an organization, will ensure that we make your food ordering process smooth and hassle-free.',
              style: TextStyle(fontSize: 18,height: MediaQuery.sizeOf(context).height*0.002,color: Colors.grey.shade300,fontWeight: FontWeight.bold),
            ),

          ],
        ),
      ),
    );
  }
}



