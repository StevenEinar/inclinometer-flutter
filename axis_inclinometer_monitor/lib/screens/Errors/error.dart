import 'package:flutter/material.dart';
import 'package:axis_inclinometer_monitor/enums/ErrorEnums.dart';

class ErrorScreen extends StatelessWidget {

  final RouteSettings? routeSettings;
  final Map seed;

  ErrorScreen({Key? key, required this.routeSettings, required this.seed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(seed['message']);
    return Scaffold(
      backgroundColor: seed['tint'],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              child: Image.asset('assets/images/error.png'),
              width: 150.0,
            ),
            SelectableText.rich(
              TextSpan(
                text: 'Error Code: ',
                style: TextStyle(
                  color: Colors.white,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: seed['code'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                      color: Colors.white,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(155, 0, 0, 0),
                        ),
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 8.0,
                          color: Color.fromARGB(25, 0, 0, 255),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: SelectableText(
                'Error Message:\n\n"${seed['message']}"\n\n\n   - The Witness Team',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if(Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
        label: const Text('Back to app'),
        icon: const Icon(Icons.arrow_back),
        backgroundColor: Colors.white30,
      ),
    );
  }

}