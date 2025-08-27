import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/routes.dart';

class FloatingAddButton extends StatelessWidget {
  const FloatingAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      right: 20,
      child: GestureDetector(
        onTap: () {
          context.push(AppRoutes.addTransaction);
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2ECC71),
                Color(0xFF27AE60),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2ECC71).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.add,
            color: CupertinoColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
