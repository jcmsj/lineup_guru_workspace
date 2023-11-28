import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/custom_app_bar.dart';
import 'package:shared/settings_item.dart';
import 'package:shared/theme/app_theme.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1DDBC),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 5, 0, 5),
                child: Text(
                  'About Line-Up Guru ',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF8E540C),
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Align(
                alignment: AlignmentDirectional(-1.00, 0.00),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 5, 10, 0),
                  child: Text(
                    'Welcome to Line-Up Guru, the cutting-edge content queuing app designed to transform the way you experience lines and waiting. At Line-Up Guru, we understand that time is a valuable resource, and waiting should be efficient and stress-free. Let us introduce you to a seamless queuing solution that leverages QR codes to revolutionize your waiting experience. Line-Up Guru was born out of a simple idea: to make queuing easier and more efficient. We understand the frustration of waiting in line, unsure of when your turn will come.   \n',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const VertSpace(),
              const Align(
                alignment: AlignmentDirectional(0.00, -1.00),
                child: Text(
                  'Our Vision ',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF562F10),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 0),
                child: Text(
                  'At Line-Up Guru, we envision a future where waiting is no longer a time-consuming chore but an opportunity to be productive, relax, or engage in activities you love. Our goal is to be the catalyst for change in how people perceive and manage queues. ',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const VertSpace(),
              const Align(
                alignment: AlignmentDirectional(0.00, -1.00),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                  child: Text(
                    'Our Mission',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF562F10),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 13, 10, 0),
                child: Text(
                  'Our mission is clear: to empower individuals and businesses with a smarter way to manage queues. We aim to eliminate the hassle of long lines, giving you more control over your time. With Line-Up Guru, we\'re on a mission to enhance your waiting experience, making it as stress-free as possible.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                child: Text(
                  'How It Works',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFC86B4A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 15, 10, 0),
                child: Text(
                  'Line-Up Guru introduces a groundbreaking approach to queuing through the use of QR codes. Here\'s how it works:\n',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: AlignmentDirectional(0.00, 0.00),
                child: Text(
                  'Scan and Queue:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Align(
                alignment: AlignmentDirectional(0.00, 0.00),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Text(
                    'Simply scan the QR code provided by the business or venue using the Line-Up Guru app. This quick and easy process instantly adds you to the virtual queue.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                child: Text(
                  'Your Queue Number:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 12, 10, 0),
                child: Text(
                  'Upon scanning, Line-Up Guru assigns you a unique queue number. This number becomes your digital ticket, determining your place in the line.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const VertSpace(),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                child: Text(
                  'Efficiency Redefined:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 12, 10, 0),
                child: Text(
                  'Experience real-time updates on your queue status. Receive notifications as your turn approaches, allowing you to plan your time effectively.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                child: Text(
                  'Download, Join, and Queue Smart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    color: Surface.fg(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 14, 10, 0),
                child: Text(
                  'Join the Line-Up Guru movement today! Download the app, join queues with ease, and reclaim your time. Whether you\'re a professional on the go, a business looking to enhance customer satisfaction, or someone who values efficiency, Line-Up Guru is your partner in mastering the art of waiting.\n\nQueue smarter, wait less, and embrace a new era of efficiency with Line-Up Guru - Where Waiting Meets Innovation. Download the app and experience the future of queues today!',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const VertSpace(),
            ],
          ),
        ),
      ),
    );
  }
}
