import java.io.Serializable;

static class PlayerData implements Serializable {
  // PlayerData used to send over the network
  private static final long serialVersionUID = 6128864208430071380L;

  public Action action;
  public float x, y, orientation, current_hp, target_x, target_y, vel_x, vel_y;
  public int unit_color, fireball_cooldown, blink_cooldown;
  public String name;
  public boolean show_name;
  public int score;

  PlayerData(float x, float y, float vel_x, float vel_y, float orientation, String name, boolean show_name, int colour, int fireball_cooldown, int blink_cooldown, float current_hp, float target_x, float target_y, Action action) {
    this.x = x;
    this.y = y;
    this.vel_x = vel_x;
    this.vel_y = vel_y;
    this.orientation = orientation;
    this.name = name;
    this.show_name = show_name;
    this.unit_color = colour;
    this.fireball_cooldown = fireball_cooldown;
    this.blink_cooldown = blink_cooldown;
    this.current_hp = current_hp;
    this.target_x = target_x;
    this.target_y = target_y;
    this.action = action;
  }

  PlayerData(String name, int unit_color, int score) {
    this.name = name;
    this.unit_color = unit_color;
    this.score = score;
  }

  PlayerData(Unit unit) {
    this(unit.getX(), unit.getY(), unit.getVelX(), unit.getVelY(), 
    unit.getOrientation(), unit.getName(), unit.nameVisible(), unit.getColour(), 
    unit.getCooldown(Action.FIREBALL), unit.getCooldown(Action.BLINK), 
    unit.getHP(), unit.getTargetX(), unit.getTargetY(), unit.getAction());
  }

  PlayerData(Player player) {
    this(player.getName(), player.getColor(), player.getScore());
  }
}