abstract class GameObject {
  public PVector position = new PVector(0, 0);
  public PVector velocity = new PVector(0, 0);
  public float orientation = 0;

  public abstract void draw();
  public abstract void update();
  public abstract float getRadius();
  public abstract void collidedWith(GameObject other);

  public PVector getVelocity(float orientation, int speed) {
    float velX = sin(radians(orientation)) * speed;
    float velY = -cos(radians(orientation)) * speed;

    return new PVector(velX, velY);
  }

  public float getOrientation(PVector target) {
    float orientation;
    PVector direction = target.get();
    direction.sub(position);

    orientation = atan2(direction.y, direction.x);
    return orientation;
  }

  public boolean collidingWith(GameObject other) {
    float distance = PVector.dist(this.position, other.position);

    if (distance > getRadius() + other.getRadius())
      return false;
    else
      return true;
  }

  public float getX() {
    return position.x;
  }

  public float getY() {
    return position.y;
  }

  public float getOrientation() {
    return orientation;
  }
}

