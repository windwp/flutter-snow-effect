import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool _isRunning = true;
  Random _rnd;
  AnimationController controller;
  Animation animation;
  final int total = 250;

  List<Snow> _snows;
  double angle = 0;
  double W = 0;
  double H = 0;
  @override
  void initState() {
    super.initState();
    _rnd = new Random();
    init();
  }

  init() {
    if (controller == null) {
      controller = new AnimationController(
          vsync: this, duration: const Duration(milliseconds: 20000))
        ..repeat();
      animation = Tween(begin: 0.0, end: 360.0).animate(controller);
      controller.addListener(() {
        setState(() {
          update();
        });
      });
      controller.repeat();
    }
    if (!_isRunning) {
      controller.stop();
    } else {
      controller.repeat();
    }
  }

  update() {
    angle += 0.01;
    for (var i = 0; i < total; i++) {
      var snow = _snows[i];
      //We will add 1 to the cos function to prevent negative values which will lead flakes to move upwards
      //Every particle has its own density which can be used to make the downward movement different for each flake
      //Lets make it more random by adding in the radius
      snow.y += cos(angle + snow.d) + 1 + snow.r / 2;
      snow.x += sin(angle) * 2;
      if (snow.x > W + 5 || snow.x < -5 || snow.y > H) {
        if (i % 3 > 0) {
          //66.67% of the flakes
          _snows[i] = new Snow(_rnd.nextDouble() * W, -10, snow.r, snow.d);
        } else {
          //If the flake is exitting from the right
          if (sin(angle) > 0) {
            //Enter from the left
            _snows[i] = new Snow(-5, _rnd.nextDouble() * H, snow.r, snow.d);
          } else {
            //Enter from the right
            _snows[i] = new Snow(W + 5, _rnd.nextDouble() * H, snow.r, snow.d);
          }
        }
      }
    }
  }

// function update()
// 	{

// 			if(p.x > W+5 || p.x < -5 || p.y > H)
// 			{
// 				if(i%3 > 0) //66.67% of the flakes
// 				{
// 					particles[i] = {x: Math.random()*W, y: -10, r: p.r, d: p.d};
// 				}
// 				else
// 				{
// 					//If the flake is exitting from the right
// 					if(Math.sin(angle) > 0)
// 					{
// 						//Enter from the left
// 						particles[i] = {x: -5, y: Math.random()*H, r: p.r, d: p.d};
// 					}
// 					else
// 					{
// 						//Enter from the right
// 						particles[i] = {x: W+5, y: Math.random()*H, r: p.r, d: p.d};
// 					}
// 				}
// 			}
// 		}
// 	}

  //anim
  @override
  Widget build(BuildContext context) {
    if (_snows == null) {
      W = MediaQuery.of(context).size.width;
      H = MediaQuery.of(context).size.height;
      _snows = new List();
      for (var i = 0; i < total; i++) {
        _snows.add(new Snow(_rnd.nextDouble() * W, _rnd.nextDouble() * H,
            _rnd.nextDouble() * 4 + 1, _rnd.nextInt(total)));
      }
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
              color: Colors.blue,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height),
          Container(
            child: CustomPaint(
              willChange: _isRunning,
              painter: Signature(
                  progress: animation.value,
                  isRunning: _isRunning,
                  snows: _snows),
              size: Size.infinite,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Status :' + _isRunning.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.clear),
        onPressed: () {
          _isRunning = !_isRunning;
          setState(() {});
          this.init();
        },
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Snow {
  double x;
  double y;
  double r; //radius
  int d; //density
  Snow(this.x, this.y, this.r, this.d);
}

class Signature extends CustomPainter {
  List<Snow> snows;
  bool isRunning;
  double progress = 0;

  Signature({this.progress, this.isRunning, this.snows}) {}

  Random _rnd;

  @override
  void paint(Canvas canvas, Size size) {
    if (snows == null) return;
    //draw circle
    final Paint paint = new Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;
    for (var i = 0; i < snows.length; i++) {
      var snow = snows[i];
      if (snow != null) {
        canvas.drawCircle(Offset(snow.x, snow.y), snow.r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.progress != progress;
}
