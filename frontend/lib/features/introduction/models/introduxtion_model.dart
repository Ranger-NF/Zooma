class Box {
  double x, y;
  double velocityY;
  double rotation;
  double rotationSpeed;
  bool isStopped;
  int imageIndex;

  Box({
    required this.x,
    required this.y,
    this.velocityY = 0.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    this.isStopped = false,
    required this.imageIndex
  });
}