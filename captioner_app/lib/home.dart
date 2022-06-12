import 'package:flutter/material.dart';
import 'captioner.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Captioner()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromARGB(17, 226, 8, 8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 200.0,
                width: 200.0,
                child: Image.asset("assets/featuredimage.jpg")),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Image Captioning App ",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white),
            ),

            // LinearGradient(
            //     begin: Alignment.topCenter,
            //     end: Alignment.bottomCenter,
            //     stops: [0.004, 1.000],
            //     colors: [Color(0x11232526), Color(0XFF232526)]), // LinearGradient
            // photoSize: 50,
            // loaderColor: Colors.white,
          ],
        ),
      ),
    );
  }
}
