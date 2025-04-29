import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback onFacebookTap;

  const SocialAuthButtons({
    super.key,
    required this.onGoogleTap,
    required this.onFacebookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Divider
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Or sign in with',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        /// Google & Facebook Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(100),
              ),
              child: IconButton(
                onPressed: onGoogleTap,
                icon: SvgPicture.asset(
                  'assets/icons/google.svg',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            SizedBox(width: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(100),
              ),
              child: IconButton(
                onPressed: onFacebookTap,
                icon: SvgPicture.asset(
                  'assets/icons/fb.svg',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
