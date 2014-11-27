import processing.net.*;
import java.lang.ClassLoader.*;

class GameServer extends Level {
  
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
  
  public void begin() {
    server = new Server(parent, PORT_NUM);
    init_minute = minute();
    init_second = second();
    world = new World(init_second);
    
    controlled_unit = createPlayer(player_name);
    units.put("host", controlled_unit);
    gameObjs.add(controlled_unit);
    
    hud = new Hud(controlled_unit);
  }
  
  private Unit createPlayer(String name) {
    color from = color(255,0,0);
    color to = color(0,0,255);
    float inc = (total_player)/10f;
    Unit u = new Unit(width/2, height/2, 0, name, lerpColor(from, to, inc), world);
    total_player++;
    return u;
  }
  
  public void draw() {
    // Get the next available client
    Client client = server.available();
    // If the client is not null, and says something, display what it said
    if (client !=null && client.available() > 0) {
      byte[] data = client.readBytes();
      Packet packet = null;
      try {
        packet = ps.deserialize(data);
      } catch (IOException e) {
        System.err.println("Caught IOException: " + e.getMessage());
        e.printStackTrace();
        return;
      } catch (ClassNotFoundException e) {
        System.err.println("Caught ClassNotFoundException: " + e.getMessage());
        e.printStackTrace();
        exit();
        return;
      }
      // a Player joining
      if (packet.getType() == PacketType.JOIN) {
        println(client.ip() + " is joining the game");
        Unit u = createPlayer(packet.getName());
        gameObjs.add(u);
        units.put(client.ip(), u);
        ArrayList list = new ArrayList();
        PlayerData player = new PlayerData(u);
        list.add(player);
        packet = new Packet(PacketType.JOIN, world.getRadius(), hud.getDuration(), list);
        try {
          data = ps.serialize(packet);
          println(data.length);
          client.write(data);
          client.write(interesting);
        } catch (IOException e) {
          System.err.println("Caught IOException: " + e.getMessage());
          e.printStackTrace();
          exit();
          return;
        }
      } else if (packet.getType() == PacketType.COMMAND) {
        processCommand(packet, client.ip());
      }
    } 
    
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
    
    // send packet
    if (timer > 0) {
      timer--;
      return;
    }
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
    } catch (IOException e) {
      System.err.println("Caught IOException: " + e.getMessage());
      e.printStackTrace();
    }
    timer = 3;
  }
  
  private void processCommand(Packet packet, String ip) {
    String name = packet.getName();
    PVector target = new PVector(packet.getX(), packet.getY());
    Action action = packet.getAction();
    Unit unit = units.get(ip);
    if (name.equals(unit.getName())) {
        unit.command(target, action);
    }
    /*for(Unit unit : units) {
      if (name.equals(unit.getName())) {
        unit.command(target, action);
        break;
      }
    }*/
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
  
  public void mouseDragged() {}
  public void mousePressed() {}
  public void keyPressed() {}
}
