import 'package:flutter/material.dart';

class UbiquitousAppBarTitle extends StatelessWidget {

  final isTopLevel;
  final title;
  final subtitle;

  UbiquitousAppBarTitle(
    {
      this.isTopLevel = true,
      this.title = 'Axis Inclinometer Monitor',
      this.subtitle = 'Discover, monitor and log Axis Inclinometers...',
    }
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        (isTopLevel)
        ?
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: SizedBox(
              child: Image.asset('assets/images/witness.png'),
              width: 32.0,
            ),
          )
        :
        Container(
          width: 0,
          height: 0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ],
    );
  }

}