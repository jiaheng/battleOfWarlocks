class Unit extends GameObject {

  public static final float RADIUS = 15f;
  public static final float INV_MASS = 1f;

  private static final float DAMPING = .98f;
  private static final float MAX_SPEED = 2f;
  private static final float TURN_RATE = 0.3f;
  private static final float MAX_HP = 100f;
  private static final float HP_BAR_LEN = 40f;
  private static final float KNOCKBACK_GAIN_FACTOR = 1/5f;

  public final color unit_color;
  private final World world;
  private final String name;

  public Action action = Action.NOTHING;
  public PVector target_point = null;
  public float current_hp = MAX_HP;
  public float knockback_force = 0f;

  private int blink_cooldown = 0;
  private int fireball_cooldown = 0;
  private PVector force_acc = new PVector(0, 0);
  private int time_in_lava = -1;

  Unit(float x, float y, float orientation, String name, color colour, World world) {
    this.orientation = orientation;
    this.name = name;
    this.world = world;
    position = new PVector(x, y);
    unit_color = colour;
  }

  Unit(PlayerData player, World world) {
    this.orientation = player.orientation;
    this.name = player.name;
    this.unit_color = color(player.unit_color);
    this.fireball_cooldown = player.fireball_cooldown;
    this.blink_cooldown = player.blink_cooldown;
    this.current_hp = player.current_hp;
    position = new PVector(player.x, player.y);
    this.world = world;
    this.action = player.action;
    velocity = new PVector(player.vel_x, player.vel_y);
    if (player.target_x < 0 && player.target_y <0)
      target_point = null;
    else
      target_point = new PVector(player.target_x, player.target_y);
  }

  public void draw() {
    fill(unit_color);
    ellipse(position.x, position.y, RADIUS*2, RADIUS*2);
    /*fill(#006600);
     textSize(12);
     textAlign(CENTER);
     text(int(current_hp) + "/" + int(MAX_HP), position.x, position.y - RADIUS/0.8);
     */
    textAlign(CENTER);
    textSize(14);
    text(name, position.x, position.y - RADIUS/0.5);

    float percentage = current_hp / MAX_HP;
    fill(255);
    rect(position.x-HP_BAR_LEN/2, position.y-RADIUS-10, HP_BAR_LEN, 7);
    fill(#00CC00);
    rect(position.x-HP_BAR_LEN/2, position.y-RADIUS-10, HP_BAR_LEN*percentage, 7);
    fill(0);
    PVector facing = PVector.fromAngle(orientation);
    facing.mult(RADIUS);
    facing.add(position);
    line(position.x, position.y, facing.x, facing.y);
  }

  public float getRadius() {
    return RADIUS;
  }

  public void collidedWith(GameObject other) {
    if (other instanceof Fireball) {
      current_hp -= Fireball.DAMAGE;
      Fireball fireball = (Fireball)other;
      Unit caster = fireball.caster;
      PVector force = other.velocity.get();
      force.normalize();
      float add_knockback = 0f;
      if (caster != null) {
        add_knockback = caster.knockback_force;
        caster.gainKnockback(fireball.FORCE*KNOCKBACK_GAIN_FACTOR);
      }
      force.mult(Fireball.FORCE + add_knockback);
      force_acc.add(force);
    }
  }

  public void addForce(PVector force) {
    force_acc.add(force);
  }

  public void command(PVector target, Action action) {
    target_point = target;
    this.action = action;
  }

  private boolean changeOrientation(PVector target_point) {
    float facing = getOrientation(target_point);
    if (abs(orientation - facing) < TURN_RATE) {
      orientation = facing;
    } else if (orientation > facing && (orientation - facing) < PI) {
      orientation -= TURN_RATE;
    } else if (orientation > facing && (orientation - facing) > PI) {
      orientation += TURN_RATE;
    } else if (orientation < facing && (facing - orientation) < PI) {
      orientation += TURN_RATE;
    } else if (orientation < facing && (facing - orientation) > PI) {
      orientation -= TURN_RATE;
    }

    if (orientation > PI) {
      orientation = orientation - TWO_PI;
    } else if (orientation < -PI) {
      orientation = orientation + TWO_PI;
    }

    return (abs(orientation - facing) < 0.01)? true : false;
  }

  private void castBlink() {
    if (blink_cooldown > 0) {
      action = Action.NOTHING;
      return;
    }
    if (!changeOrientation(target_point)) return;

    if (position.dist(target_point) < Blink.MAX_RANGE) {
      position = target_point;
    } else {
      PVector new_position = PVector.fromAngle(orientation);
      new_position.mult(Blink.MAX_RANGE);
      new_position.add(position);
      position = new_position;
    }
    action = Action.NOTHING;
    blink_cooldown = Blink.COOLDOWN;
  }

  private void castFireball() {
    if (fireball_cooldown > 0) {
      action = Action.NOTHING;
      return;
    }
    if (!changeOrientation(target_point)) return;

    PVector fireball_position = PVector.fromAngle(orientation);
    fireball_position.mult(RADIUS + Fireball.RADIUS);
    fireball_position.add(position);
    Fireball fireball = new Fireball(fireball_position, orientation, this);

    current_level.addToWorld.add(fireball);
    action = Action.NOTHING;
    fireball_cooldown = Fireball.COOLDOWN;
  }

  private void move() {
    /*PVector direction = target_point.get();
     direction.sub(position);
     direction.normalize();
     direction.mult(MAX_SPEED);*/

    if (!changeOrientation(target_point)) return;

    PVector move_velocity = PVector.fromAngle(orientation);
    move_velocity.mult(MAX_SPEED);
    // if not moving or moving lower than max speed IN THE DISIRED DIRECTION
    if (abs(velocity.mag() - 0) < 0.1 || velocity.mag() <= MAX_SPEED && PVector.angleBetween(move_velocity, velocity) < 0.01) {
      float dist = position.dist(target_point);
      if (dist <= MAX_SPEED) {  //reach destination
        position = target_point;
        target_point = null;
        action = Action.NOTHING;
        velocity = new PVector(0, 0);
      } else {
        velocity = move_velocity;
      }
    }
    /*float cos_theta = velocity.dot(direction) / velocity.mag() / direction.mag();
     // not moving or moving in desired direction with speed lower than MAX_SPEED
     if (abs(velocity.mag() - 0) < 0.1 || velocity.mag() <= MAX_SPEED && abs(cos_theta - 1) < 0.1) {
     float dist = position.dist(target_point);
     if (dist <= MAX_SPEED) {
     position = target_point;
     target_point = null;
     action = Action.NOTHING;
     velocity = new PVector(0,0);
     } else {
     velocity = direction;
     }
     } else if (velocity.mag() <= MAX_SPEED && velocity.mag() > 0) {
     velocity = new PVector(0,0);
     }*/
  }

  private void hold() {
    if (velocity.mag() < MAX_SPEED && velocity.mag() > 0) {
      velocity = new PVector(0, 0);
    }
  }

  private boolean isOutsideRing() {
    PVector ring_center = new PVector(width/2, height/2);
    float distance = PVector.dist(this.position, ring_center);
    return (distance > world.ring_radius)? true : false;
  }

  public void update() {
    if (current_hp <= 0) {
      current_level.removeFromWorld.add(this);
    }

    position.add(velocity);

    PVector resultingAcceleration = force_acc.get();
    resultingAcceleration.mult(INV_MASS);

    velocity.add(resultingAcceleration);
    velocity.mult(DAMPING);
    if (velocity.mag() < MAX_SPEED && velocity.mag() > 0) {
      velocity = new PVector(0, 0);
    }

    // Clear accumulator
    force_acc.x = 0;
    force_acc.y = 0; 

    switch (action) {
    case MOVE:
      move();
      break;
    case BLINK:
      castBlink();
      break;
    case FIREBALL:
      castFireball();
      break;
    case NOTHING:
      hold();
      break;
    default:
      println("invalid action.");
    }

    //update skill cooldown
    if (fireball_cooldown > 0) fireball_cooldown--;
    if (blink_cooldown > 0) blink_cooldown--;

    if (time_in_lava >= 0) {
      int now = millis();
      int duration = now - time_in_lava;
      duration = (duration >= 0)? duration : duration + 1000;
      if (duration >= 100) {
        current_hp -= world.LAVA_DMG/10 * duration/100;
        time_in_lava = now;
      }
    }
    if (isOutsideRing()) {
      if (time_in_lava == -1) time_in_lava = millis();
    } else {
      time_in_lava = -1;
    }
  }

  public void gainKnockback(float force) {
    this.knockback_force += force;
  }

  public int getCooldown(Action action) {
    switch (action) {
    case FIREBALL:
      return fireball_cooldown;
    case BLINK:
      return blink_cooldown;
    case MOVE:
      return 0;
    default:
      println("invalid action.");
      return -1;
    }
  }

  public String getName() {
    return name;
  }

  public int getColour() {
    return unit_color;
  }

  public float getHP() {
    return current_hp;
  }

  public float getTargetX() {
    if (target_point == null) return -1f;
    return target_point.x;
  }

  public float getTargetY() {
    if (target_point == null) return -1f;
    return target_point.y;
  }

  public Action getAction() {
    return action;
  }

  public float getVelX() {
    return velocity.x;
  }

  public float getVelY() {
    return velocity.y;
  }
}

