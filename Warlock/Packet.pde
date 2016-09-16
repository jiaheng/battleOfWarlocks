import java.io.Serializable;

public static class Packet implements Serializable {
  private static final long serialVersionUID = 6128016096756071380L;

  private final PacketType type;
  private final UUID senderUUID = APP_UUID;

  private ArrayList data;
  private float ring_radius;
  private long duration;
  private String player_name;
  private float x, y;
  private Action action;
  private boolean pregame;
  private int pregame_timer;
  private boolean endgame;
  private boolean endround;
  private int endround_timer;

  Packet(PacketType type) {
    this.type = type;
  }

  Packet(PacketType type, float ring_radius, boolean pregame, boolean endgame, int pregame_timer, boolean endround, int endround_timer, long duration, ArrayList data) {
    this.type = type;
    this.ring_radius = ring_radius;
    this.pregame = pregame;
    this.endgame = endgame;
    this.pregame_timer = pregame_timer;
    this.endround = endround;
    this.endround_timer = endround_timer;
    this.duration = duration;
    this.data = data;
  }

  Packet(PacketType type, String player_name) {
    this.type = type;
    this.player_name = player_name;
  }

  Packet(PacketType type, ArrayList data) {
    this.type = type;
    this.data = data;
  }

  Packet(PacketType type, String player_name, float x, float y, Action action) {
    this.type = type;
    this.player_name = player_name;
    this.x = x;
    this.y = y;
    this.action = action;
  }

  public UUID getSenderUUID() {
    return senderUUID;
  }

  public PacketType getType() {
    return type;
  }

  public float getRingRadius() {
    return ring_radius;
  }

  public ArrayList getData() {
    return data;
  }

  public long getDuration() {
    return duration;
  }

  public String getName() {
    return player_name;
  }

  public float getX() {
    return x;
  }

  public float getY() {
    return y;
  }

  public Action getAction() {
    return action;
  }

  public boolean isPregame() {
    return pregame;
  }

  public int getPregameTimer() {
    return pregame_timer;
  }

  public boolean isGameOver() {
    return endgame;
  }

  public boolean isRoundOver() {
    return endround;
  }

  public int getEndroundTimer() {
    return endround_timer;
  }
}
