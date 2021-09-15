import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  const BottomButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          backgroundColor:
              MaterialStateColor.resolveWith((states) => Colors.amber.shade300),
          fixedSize: MaterialStateProperty.all(
            Size(double.infinity, double.infinity),
          ),
        ),
        onPressed: () {},
        child: const Text(
          'Synchronize time',
          style: TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}
