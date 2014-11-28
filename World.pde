class World {  

  private static final float INITIAL_RING_RADIUS = 320f;
  private static final int RING_REDUCE_TIME = 40;
  private static final int RING_INTERVAL = 10;
  private static final float RING_REDUCE_INC = 5f;

  public final float LAVA_DMG = 12f; // 10 dmg per second 

  private final int start_time;

  private float ring_radius = INITIAL_RING_RADIUS;
  private int ring_time;
  private boolean smaller_ring = false;
  private float ring_reduce = 10f;

  World(int start_time) {
    this.start_time = start_time;
  }

  World(float ring_radius) {
    start_time = 0; //arbitrary value
    this.ring_radius = ring_radius;
  }

  private void update() {
    int now = second();
    if (smaller_ring) {
      int interval = now - ring_time;
      interval = (interval >= 0)? interval : interval + 60;
      if (interval >= RING_INTERVAL) {
        ring_radius -= ring_reduce;
        ring_reduce += RING_REDUCE_INC;
        ring_time = second();
      }
    } else {
      int duration = now - start_time;
      duration = (duration >= 0)? duration : duration + 60;
      if (duration >= RING_REDUCE_TIME) {
        smaller_ring = true;
        ring_radius -= ring_reduce;
        ring_time = second();
      }
    }
  }

  public float getRadius() {
    return ring_radius;
  }

  public void draw() {
    background(bg);
    if (ring_radius > 0) {
      fill(128);
      ellipse(width/2, height/2, ring_radius*2, ring_radius*2);
      //imageMode(CENTER);
      //image(floor_img, width/2, height/2, ring_radius*2, ring_radius*2);
      //imageMode(CORNER);
    }
  }
}

