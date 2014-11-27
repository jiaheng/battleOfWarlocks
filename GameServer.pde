import processing.net.*;
import java.lang.ClassLoader.*;

class GameServer extends Level {

  private ArrayList<Player> players = new ArrayList<Player>();
  private HashMap<String, Unit> units = new HashMap<String, Unit>(10);
  private int total_player = 0;

  private PacketSerializer ps = new PacketSerializer();
  private Server server;
  private int init_minute, init_second;
  private World world;
  private Unit controlled_unit;  
  private Hud hud;
  private Action issue_cmd = Action.NOTHING;

  private int timer = 0;

  GameServer(Server server, ArrayList<Player> players) {
    this.server = server;
    this.players = players;
    this.total_player = players.size();
  }

  public void begin() {
    init_minute = minute();
    init_second = second();
    world = new World(init_second);

    createUnit();
    if (controlled_unit == null) {
      println("unable to find the controlled unit");
      exit();
      return;
    }
    hud = new Hud(controlled_unit);
  }

  private void createUnit() {
    float angle = TWO_PI/total_player;
    float orientation = 0;
    PVector spawn_vector = new PVector(-1, 0);
    spawn_vector.mult(250);
    for (Player player : players) {
      PVector spawn_point = new PVector(width/2, height/2);
      spawn_point.add(spawn_vector);
      color unit_color = color(player.getColor());
      Unit unit = new Unit(spawn_point.x, spawn_point.y, orientation, player.getName(), unit_color, world);
      String ip = player.getIp();
      if (ip.equals("host")) {
        controlled_unit = unit;
      }
      units.put(ip, unit);
      gameObjs.add(unit);
      spawn_vector.rotate(angle);
      orientation -= angle;
      if (orientation > PI) orientation = TWO_PI - orientation;
    }
  }

  private void receiveCommand() {
    // Get the next available client
    Client client = server.available();
    if (client !=null && client.available() > 0) {
      byte[] data = client.readBytesUntil(interesting);
      if (data == null) return;
      System.arraycopy(data, 0, data, 0, data.length - 1);
      Packet packet = null;
      try {
        packet = ps.deserialize(data);
      } 
      catch (IOException e) {
        System.err.println("Caught IOException: " + e.getMessage());
        e.printStackTrace();
        return;
      } 
      catch (ClassNotFoundException e) {
        System.err.println("Caught ClassNotFoundException: " + e.getMessage());
        e.printStackTrace();
        return;
      }
      // a Player trying to join during game
      if (packet.getType() == PacketType.JOIN) {
        server.disconnect(client);
      } else if (packet.getType() == PacketType.COMMAND) {
        processCommand(packet, client.ip());
      }
    }
  }

  private void sendState() {
    ArrayList list = new ArrayList();
    for (GameObject obj : gameObjs) {
      if (obj instanceof Unit) {
        Unit unit = (Unit) obj;
        PlayerData player = new PlayerData(unit);
        list.add(player);
      } else if (obj instanceof Fireball) {
        Fireball fireball = (Fireball) obj;
        FireballData fireball_data = new FireballData(fireball);
        list.add(fireball_data);
      }
    }

    Packet packet = new Packet(PacketType.STATE, world.getRadius(), hud.getDuration(), list);
    byte[] data = null;
    try {
      data = ps.serialize(packet);
      server.write(data);
      server.write(interesting);
      //println(data.length);
    } 
    catch (IOException e) {
      System.err.println("Caught IOException: " + e.getMessage());
      e.printStackTrace();
    }
  }

  public void draw() {
    receiveCommand();

    world.update();
    world.draw();

    for (GameObject obj : gameObjs) {
      obj.update();
    }

    for (GameObject obj : gameObjs) {
      checkCollisions(obj);
      obj.draw();
    }

    for (GameObject obj : addToWorld) {
      gameObjs.add(obj);
    }
    addToWorld.clear();

    for (GameObject obj : removeFromWorld) {
      gameObjs.remove(obj);
    }
    removeFromWorld.clear();

    hud.update();
    hud.draw();

    if (timer > 0) {
      timer--;
      return;
    } else {
      sendState();
      timer = 3;
    }
  }

  private void removePlayer(String ip) {
    Unit exist = units.remove(ip);
    if (exist == null) return; //exit if the player doesnt exist
    for (Player player : players) {
      if (player.getIp().equals(ip)) {
        players.remove(player);
      }
    }
    total_player--;
  }

  public void disconnectEvent(Client client) {
    println(client.ip() + " disconnected");
    removePlayer(client.ip());
  }

  private void processCommand(Packet packet, String ip) {
    String name = packet.getName();
    PVector target = new PVector(packet.getX(), packet.getY());
    Action action = packet.getAction();
    Unit unit = units.get(ip);
    if (unit == null) {
      return;
    }
    if (name.equals(unit.getName())) {
      unit.command(target, action);
    }
  }

  private void checkCollisions(GameObject other) {
    for (GameObject obj : gameObjs) {
      if (obj != other && obj.collidingWith(other)) {
        obj.collidedWith(other);
      }
    }
  }

  public void mouseReleased() {
    PVector target = new PVector(mouseX, mouseY);
    if (mouseButton == RIGHT) { 
      if (issue_cmd == Action.NOTHING) { // move command if no cmd issued
        controlled_unit.command(target, Action.MOVE);
      } else { // if a cmd issued, cancel the cmd
        issue_cmd = Action.NOTHING;
        cursor(ARROW);
      }
    } else if (mouseButton == LEFT) {
      Action command = hud.getCommand();
      if (command == Action.NOTHING && issue_cmd != Action.NOTHING) { //if no button is clicked and there is a command issue
        controlled_unit.command(target, issue_cmd);
        cursor(ARROW);
        issue_cmd = Action.NOTHING;
      } else if (command != Action.NOTHING) { //if a button is clicked
        selectAction(command);
      }
      //PVector target = new PVector(mouseX, mouseY);
      //controlled_unit.cast(target);
    }
  }

  public void keyReleased() {
    if (key == 'f' || key == 'F') {
      selectAction(Action.FIREBALL);
    } else if (key == 'm' || key == 'M') {
      selectAction(Action.MOVE);
    } else if (key == 'b' || key == 'B') {
      selectAction(Action.BLINK);
    } else if (key == 's' || key == 'S') {
      controlled_unit.command(null, Action.NOTHING);
    }
  }

  private void selectAction(Action action) {
    int cooldown = controlled_unit.getCooldown(action);
    if (cooldown == 0) {
      issue_cmd = action;
      cursor(CROSS);
    } else if (cooldown > 0) {
      // show cooldown message
    } else {
      println("error!");
    }
  }

  public void stop() {
    if (server != null) {
      server.stop();
    }
  }

  public void mouseDragged() {
  }
  public void mousePressed() {
  }
  public void keyPressed() {
  }
}

