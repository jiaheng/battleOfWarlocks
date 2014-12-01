import java.io.Serializable;

static class FireballData implements Serializable {
  // FiraballData used to send over the network
  private static final long serialVersionUID = 7614852198430071380L;

  public final float x, y, orientation;

  FireballData(float x, float y, float orientation) {
    this.x = x;
    this.y = y;
    this.orientation = orientation;
  }

  FireballData(Fireball fireball) {
    this(fireball.getX(), fireball.getY(), fireball.getOrientation());
  }
}

