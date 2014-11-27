import processing.net.*;
import java.util.Arrays;

class GameClient extends Level {
  
  private Client client;
  private PacketSerializer ps = new PacketSerializer();
  private Hud hud;
  private World world;
  private Unit controlled_unit = null;
  private Action issue_cmd = Action.NOTHING;
    
  GameClient(Client client) {
    this.client = client;
  }
  
  public void begin() {
    /*client = new Client(parent, "127.0.0.1", PORT_NUM);
    if (client == null) {
      println("unable to join");
      exit();
    }*/
    Packet packet = new Packet(PacketType.JOIN, player_name);
    byte[] data = null;
    try {
      data = ps.serialize(packet);
      client.write(data);
    } catch (IOException e) {
      System.err.println("Caught IOException: " + e.getMessage());
      e.printStackTrace();
      exit();
    }    
    /*
    do {
      if (client.available() > 0) {
        data = client.readBytes();
        packet = null;
        try {
          packet = ps.deserialize(data);
          if (packet.getType() == PacketType.STATE) {
            ArrayList list = packet.getData();
            world = new World(packet.getRingRadius());
            for (Object obj : list) {
              if (obj instanceof PlayerData) {
                PlayerData player = (PlayerData) obj;
                if (player_name.equals(player.name))
                  controlled_unit = new Unit(player, world);
              }
            }
          }
        } catch (IOException e) {
          System.err.println("Caught IOException: " + e.getMessage());
          e.printStackTrace();
        } catch (ClassNotFoundException e) {
          System.err.println("Caught ClassNotFoundException: " + e.getMessage());
          e.printStackTrace();
          exit();
          return;
        }
      }
      println("Waiting for my unit");
    } while(controlled_unit == null);
    println("done");
    hud = new Hud(controlled_unit);
    */int retry = 0;
    do {
      println("reading");
      retry++;
      data = client.readBytesUntil(interesting);
      if (data != null) {
      //if (client.available() > 0) {
        System.arraycopy(data, 0, data, 0, data.length - 1);
        println(data.length);
        packet = null;
        try {
          packet = ps.deserialize(data);
          if (packet.getType() == PacketType.STATE) {
            println("got state instead");
          }
          if (packet.getType() == PacketType.JOIN) {
            ArrayList list = packet.getData();
            world = new World(packet.getRingRadius());
            PlayerData player = (PlayerData) list.get(0);
            if (player_name.equals(player.name)) {
              controlled_unit = new Unit(player, world);
              gameObjs.add(controlled_unit);
            }
          }
        } catch (IOException e) {
          //println("problem reading packet");
          System.err.println("Caught IOException: " + e.getMessage());
          //e.printStackTrace();
        } catch (ClassNotFoundException e) {
          System.err.println("Caught ClassNotFoundException: " + e.getMessage());
          e.printStackTrace();
          exit();
          return;
        }
      }
    } while(controlled_unit == null || retry < 100);
    if (controlled_unit == null) {
      loadLevel(new Menu());
    }
    hud = new Hud(controlled_unit);
  }
  
  private void processPacket() {
    byte[] data = client.readBytesUntil(interesting);
    if (data == null) return;
    System.arraycopy(data, 0, data, 0, data.length - 1);
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
      return;
    }
    if (packet.getType() == PacketType.STATE) {
      ArrayList list = packet.getData();
      world = new World(packet.getRingRadius());
      gameObjs.clear();
      for (Object obj : list) {
        if (obj instanceof PlayerData) {
          PlayerData player = (PlayerData) obj;
          Unit unit = new Unit(player, world);
          if (player_name.equals(unit.getName())) {
            this.controlled_unit = unit;
            hud.update(unit, packet.getDuration());
          }
          gameObjs.add(unit);
        } else if (obj instanceof FireballData) {
          FireballData fireball_data = (FireballData) obj;
          Fireball fireball =  new Fireball(fireball_data);
          gameObjs.add(fireball);  
        }
      }
    }
  }
  
  public void draw() {    
    byte[] data;
    if (client.available() > 0) { 
      processPacket();
    } else {
      // update obj
      for (GameObject obj : gameObjs) {
        obj.update();
      }
      for (GameObject obj : gameObjs) {
        checkCollisions(obj);
      }
      hud.update();
    }
    
    world.draw();
    
    for (GameObject obj : gameObjs) {
      obj.draw();
    }
    
    for (GameObject obj : removeFromWorld) {
      gameObjs.remove(obj);
    }
    removeFromWorld.clear();
    
    hud.draw(); 
  }
  
  private void sendCommand(PVector target, Action action) {
    Packet packet = new Packet(PacketType.COMMAND, player_name, target.x, target.y, action);
    byte[] data = null;
    try {
      data = ps.serialize(packet);
      client.write(data);
    } catch (IOException e) {
      System.err.println("Caught IOException: " + e.getMessage());
      e.printStackTrace();
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
        sendCommand(target, Action.MOVE);
      } else { // if a cmd issued, cancel the cmd
        issue_cmd = Action.NOTHING;
        cursor(ARROW);
      }
    } else if (mouseButton == LEFT) {
      Action command = hud.getCommand();
      if (command == Action.NOTHING && issue_cmd != Action.NOTHING) { //if no button is clicked and there is a command issue
        sendCommand(target, issue_cmd);
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
    if (client != null) {
      client.stop();
    }
  }
  
  public void mousePressed() {}
  public void mouseDragged() {}
  public void keyPressed() {}
}