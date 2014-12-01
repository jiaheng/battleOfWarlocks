class Fireball extends GameObject {
  public static final float SPEED = 7f;
  public static final float RADIUS = 8f;
  public static final float FORCE = 4f;
  public static final float DAMAGE = 5f;
  public static final int COOLDOWN = 300; // 5 seconds

  public final Unit caster;
  public int lifespan = 50;

  Fireball(PVector position, float orientation, Unit caster) {
    this.position = position;
    this.orientation = orientation;
    velocity = PVector.fromAngle(orientation);
    velocity.mult(SPEED);
    this.caster = caster;
  } 

  Fireball(FireballData fireball) {
    this(new PVector(fireball.x, fireball.y), fireball.orientation, null);
  }

  public void draw() {
    fill(255, 102, 0);
    ellipse(position.x, position.y, RADIUS*2, RADIUS*2);
    translate(position.x, position.y);
    rotate(orientation+HALF_PI); // fireball image is facing top, need to translate it
    image(fireball_img, -3-RADIUS, -RADIUS);
    resetMatrix();
  }

  public void update() {
    position.add(velocity);

    lifespan--;
    if (lifespan <= 0) {
      current_level.removeFromWorld.add(this);
    }
  }

  public float getRadius() {
    return RADIUS;
  }

  public void collidedWith(GameObject other) {
    current_level.removeFromWorld.add(this);
    play(sfx_fireball);
  }
}

