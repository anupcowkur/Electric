import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(ElectricApp());
}

class ElectricApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electric',
      home: Scaffold(
        backgroundColor: Color(0xFF242424),
        body: Electricity(),
      ),
    );
  }
}

class Electricity extends StatefulWidget {
  @override
  _ElectricityState createState() => _ElectricityState();
}

class _ElectricityState extends State<Electricity>
    with SingleTickerProviderStateMixin {
  final _trunkEdges = 10;
  Offset _userFingerPosition;
  Path _trunkPath = Path();
  Path _branch1Path = Path();
  Path _branch2Path = Path();
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 60),
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_userFingerPosition != null) {
            _generatePoints();
            _animationController.reset();
            _animationController.forward();
          }
        }
      });
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _userFingerPosition = details.localPosition;
    });
    _generatePoints();
    _animationController.reset();
    _animationController.forward();
  }

  void _onFingerMove(DragUpdateDetails details) {
    _stopLightning();
  }

  void _onTapUp(TapUpDetails details) {
    _stopLightning();
  }

  void _stopLightning() {
    setState(() {
      _userFingerPosition = null;
    });
    _animationController.reset();
  }

  void _generatePoints() {
    _trunkPath = Path();
    _branch1Path = Path();
    _branch2Path = Path();

    if (_userFingerPosition == null) {
      return;
    }

    Offset currentPoint = _userFingerPosition;
    _trunkPath.moveTo(currentPoint.dx, currentPoint.dy);
    Offset nextPoint;

    int branch1StartEdge = Random().nextInt(_trunkEdges);
    int branch1Edges = Random().nextInt(_trunkEdges);
    int branch2StartEdge = Random().nextInt(_trunkEdges);
    int branch2Edges = Random().nextInt(_trunkEdges);
    Offset branch1Start;
    Offset branch2Start;

    // Calculate trunk points
    for (int i = 0; i < _trunkEdges; i++) {
      nextPoint = _getNextPoint(currentPoint);

      _trunkPath.lineTo(nextPoint.dx, nextPoint.dy);

      if (i == branch1StartEdge) {
        branch1Start = currentPoint;
      }

      if (i == branch2StartEdge) {
        branch2Start = currentPoint;
      }

      currentPoint = nextPoint;
    }

    // Calculate branch 1 points
    currentPoint = branch1Start;
    _branch1Path.moveTo(currentPoint.dx, currentPoint.dy);
    for (int i = 0; i < branch1Edges; i++) {
      nextPoint = _getNextPoint(currentPoint);

      _branch1Path.lineTo(nextPoint.dx, nextPoint.dy);

      currentPoint = nextPoint;
    }

    // Calculate branch 2 points
    currentPoint = branch2Start;
    _branch2Path.moveTo(currentPoint.dx, currentPoint.dy);
    for (int i = 0; i < branch2Edges; i++) {
      nextPoint = _getNextPoint(currentPoint);

      _branch2Path.lineTo(nextPoint.dx, nextPoint.dy);

      currentPoint = nextPoint;
    }
  }

  Offset _getNextPoint(Offset currentPoint) {
    double randomXChange = _doubleInRange(Random(), -50, 50);
    double randomYChange = _doubleInRange(Random(), 10, 70);

    return Offset(
        currentPoint.dx + randomXChange, currentPoint.dy + randomYChange);
  }

  double _doubleInRange(Random source, num start, num end) =>
      source.nextDouble() * (end - start) + start;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onPanUpdate: _onFingerMove,
        child: CustomPaint(
            painter: ElectricityPainter(_animation.value, _userFingerPosition,
                _trunkPath, _branch1Path, _branch2Path)),
      ),
    );
  }
}

class ElectricityPainter extends CustomPainter {
  final Path _trunkPath;
  final Path _branch1Path;
  final Path _branch2Path;
  final double _animationProgress;
  final Offset _userFingerPosition;

  Paint _trunkPaint = Paint()
    ..color = Colors.white.withAlpha(220)
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.butt;

  Paint _branchPaint = Paint()
    ..color = Colors.white.withAlpha(150)
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.butt;

  Paint _circlePaint = Paint()
    ..color = Colors.white.withOpacity(0.75)
    ..style = PaintingStyle.fill;

  Paint _shadowPaint = Paint()
    ..color = Colors.purple.withOpacity(0.65)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, 50);

  ElectricityPainter(this._animationProgress, this._userFingerPosition,
      this._trunkPath, this._branch1Path, this._branch2Path);

  @override
  void paint(Canvas canvas, Size size) {
    if (_animationProgress > 0) {
      canvas.drawPath(_trunkPath, _trunkPaint);
      canvas.drawCircle(_userFingerPosition, 2, _circlePaint);
      canvas.drawCircle(_userFingerPosition, 15, _shadowPaint);
    }

    _drawBranch(_branch1Path.computeMetrics(), canvas);
    _drawBranch(_branch2Path.computeMetrics(), canvas);
  }

  void _drawBranch(PathMetrics pathMetrics, Canvas canvas) {
    for (PathMetric pathMetric in pathMetrics) {
      Path extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * _animationProgress,
      );
      canvas.drawPath(extractPath, _branchPaint);
      canvas.drawPath(extractPath, _shadowPaint);
    }
  }

  @override
  bool shouldRepaint(ElectricityPainter oldDelegate) {
    return _trunkPath != oldDelegate._trunkPath ||
        _branch1Path != oldDelegate._branch1Path ||
        _branch2Path != oldDelegate._branch2Path ||
        _animationProgress != oldDelegate._animationProgress;
  }
}
