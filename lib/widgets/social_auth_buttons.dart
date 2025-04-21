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
            Container(
              color: Colors.grey.shade600,
              height: 1,
              width: 70,
            ),
            const SizedBox(width: 10),
            Text(
              'or',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              color: Colors.grey.shade600,
              height: 1,
              width: 70,
            ),
          ],
        ),

        const SizedBox(height: 20),

        /// Google & Facebook Buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onGoogleTap,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFF44336)),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset('assets/icons/google.svg'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onFacebookTap,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset('assets/icons/fb.svg'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
