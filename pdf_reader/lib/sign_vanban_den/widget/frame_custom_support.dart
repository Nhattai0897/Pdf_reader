import 'package:flutter/material.dart';

class ResizebleWidget extends StatefulWidget {
  ResizebleWidget(
      {this.child,
      this.top,
      this.left,
      this.width,
      this.height,
      this.onDrag,
      this.minSize,
      this.maxSize,
      this.minHeightSize,
      this.maxHeightSize,
      this.maxWidthSize,
      this.minWidthSize,
      this.limitHeight,
      this.isIpad,
      this.widthSign});

  final Widget? child;
  final Function? onDrag;
  double? top;
  double? left;
  double? height;
  double? width;
  double? minSize;
  double? maxSize;
  double? minWidthSize;
  double? maxWidthSize;
  double? minHeightSize;
  double? maxHeightSize;
  double? limitHeight;
  double? widthSign;
  bool? isIpad;

  @override
  _ResizebleWidgetState createState() => _ResizebleWidgetState();
}

const ballDiameter = 30.0;
double? initX;
double? initY;
var updateWidth = 0.0;
var updateHeight = 0.0;
GlobalKey stickyKey = GlobalKey();

class _ResizebleWidgetState extends State<ResizebleWidget> {
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => getHeightFirstTime());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: widget.top,
            left: widget.left,
            child: Container(
                key: stickyKey,
                color: Colors.blue.withOpacity(0.1),
                width: widget.width,
                child: widget.child),
          ),
          // Point Top Right => dùng thay đổi kích thước khung chữ ký
          Positioned(
            top: widget.top! - ballDiameter / 2.2,
            left: widget.left! + widget.width! - ballDiameter / 1.9,
            child: ManipulatingBall(
              isDragCorner: false,
              onDrag: (dx, dy) {
                var mid = (dx + (dy * -1));
                var newHeight = widget.height! + 2 * mid;
                var newWidth = widget.width! + 2 * mid * 2.5;
                if (newHeight < widget.minHeightSize! ||
                    newWidth < widget.minWidthSize! ||
                    newHeight > widget.maxHeightSize! ||
                    newWidth > widget.maxWidthSize!) return;
                setState(() {
                  widget.height = newHeight > 0 ? newHeight : 0;
                  widget.width = newWidth > 0 ? newWidth : 0;
                  widget.top = widget.top! - mid;
                  widget.left = widget.left! - mid;
                });
                widget.onDrag!(widget.top! + dy, widget.left! + dx,
                    widget.width, widget.height);
              },
            ),
          ),
        ],
      ),
    );
  }

  onDrag(double dx, double dy) {
    var newHeight = widget.height! + dy;
    var newWidth = widget.width! + dx;
    setState(() {
      widget.height = newHeight > 0 ? newHeight : 0;
      widget.width = newWidth > 0 ? newWidth : 0;
    });
  }

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  Future<void> getHeightFirstTime() async {
    await Future.delayed(Duration(milliseconds: 500));
    final keyContext = stickyKey.currentContext;
    final box = keyContext!.findRenderObject() as RenderBox;
    widget.onDrag!(0.0, 0.0, box.size.width, 100.0);
    // widget.onDrag!(0.0, 0.0, box.size.width, box.size.height);
  }

  _handleUpdate(details) {
    final keyContext = stickyKey.currentContext;
    final box = keyContext!.findRenderObject() as RenderBox;
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    if (widget.isIpad != null && widget.isIpad == true) {
      if (widget.top! < 0) {
        widget.top = 0;
      } else if (widget.left! < 0) {
        widget.left = 0;
      } else if (widget.left! > (widget.widthSign! - box.size.width)) {
        widget.left = (widget.widthSign! - box.size.width);
      } else if (widget.top! > (widget.limitHeight! - box.size.height)) {
        widget.top = widget.limitHeight! - box.size.height;
      }
    } else {
      if (widget.top! < 0) {
        widget.top = 0;
      } else if (widget.left! < 0) {
        widget.left = 0;
      } else if (widget.left! >
          (MediaQuery.of(context).size.width - widget.width!)) {
        widget.left = MediaQuery.of(context).size.width - widget.width!;
      } else if (widget.top! > (widget.limitHeight! - box.size.height)) {
        widget.top = widget.limitHeight! - box.size.height;
      }
    }
    widget.onDrag!(
        widget.top! + dy, widget.left!, widget.width, box.size.height);
    // print('Sizeable y: ${widget.top! + dy}, x: ${widget.left!}, width: ${widget.width}, height: ${box.size.height}');
    setState(() {
      widget.top = widget.top! + dy;
      widget.left = widget.left! + dx;
    });
  }
}

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall(
      {Key? key, this.onDrag, this.isDragCorner, this.height, this.width});

  final Function? onDrag;
  final bool? isDragCorner;
  double? width;
  double? height;

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  double? initX;
  double? initY;
  var updateWidth = 0.0;
  var updateHeight = 0.0;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag!(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    updateWidth = (widget.isDragCorner! ? widget.width : ballDiameter)!;
    updateHeight = (widget.isDragCorner! ? widget.height : ballDiameter)!;
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        width: updateWidth < 30 ? 30 : updateWidth,
        height: updateHeight < 30 ? 30 : updateHeight,
        child: widget.isDragCorner!
            ? SizedBox()
            : Padding(
                padding: const EdgeInsets.all(7.0),
                child: Image.asset('assets/resize.png'),
              ),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(widget.isDragCorner! ? 0 : 0.5),
          shape: widget.isDragCorner! ? BoxShape.rectangle : BoxShape.circle,
        ),
      ),
    );
  }
}
