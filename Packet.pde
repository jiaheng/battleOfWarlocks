import java.io.Serializable;

static class Packet implements Serializable {
  private static final long serialVersionUID = 6128016096756071380L;
  
  private final PacketType type;
  private ArrayList data;
  private float ring_radius;
  private long duration;
  private String player_name;
  private float x, y;
  private Action action;
  
  Packet(PacketType type, float ring_radius, long duration, ArrayList data) {
    this.type = type;
    this.ring_radius = ring_radius;
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
  
  Packet(PacketType type) {
    this.type = type;
  }
  
  Packet(PacketType type, String player_name, float x, float y, Action action) {
    this.type = type;
    this.player_name = player_name;
    this.x = x;
    this.y = y;
    this.action = action;
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
}