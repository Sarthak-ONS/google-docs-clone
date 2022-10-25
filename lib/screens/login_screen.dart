import 'package:flutter/material.dart';
import 'package:google_docs_clone/custom_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/docs-logo.png',
              height: 40,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              'DOCS',
              style: TextStyle(
                color: AppColors.primaryFontColor,
                fontSize: 40,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Container(
              height: 70,
              width: 2,
              color: Colors.blueAccent,
            ),
            const SizedBox(
              width: 15,
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Image.asset(
                'assets/images/google-logo.png',
                height: 20,
              ),
              label: const Text(
                'Login With Google',
                style: TextStyle(
                  color: AppColors.primaryFontColor,
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50),
                primary: Colors.white54,
                elevation: 2,
                shadowColor: Colors.black,
                enableFeedback: true,
                onSurface: Colors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  side: BorderSide(
                    color: Colors.blueAccent,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
