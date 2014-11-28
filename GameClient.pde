import processing.net.*;
import java.util.Arrays;

class GameClient extends Level {

  private Client client;
  private PacketSerializer ps = new PacketSerializer();
  private Hud hud;
  private World world;
  private Unit controlled_unit = null;
  private Action issue_cmd = Action.NOTHING;
  private ArrayList<Player> players = new ArrayList<Player>();

  private String msg = "";
  private boolean pregame = true;
  private int pregame_timer = 300;
  private boolean endgame = false;
  private Player current_player;

  private Button exit_button = null;

  GameClient(Client client) {
    this.client = client;
  }

  public void begin() {
    int retry = 0;
    do {
      retry++;
      byte[] data = client.readBytesUntil(interesting);
      if (data != null) {
        //if (client.available() > 0) {
        System.arraycopy(data, 0, data, 0, data.length - 1);
        Packet packet = null;
        try {
          packet = ps.deserialize(data);
          if (packet.getType() == PacketType.STATE) {
            ArrayList list = packet.getData();
            world = new World(packet.getRingRadius());
            gameObjs.clear();
            for (Object obj : list) {
              if (obj instanceof PlayerData) {
                PlayerData player_data = (PlayerData) obj;
                Player player = new Player(player_data);
                Unit unit = new Unit(player_data, world);
                if (player_name.equals(unit.getName())) {
                  this.current_player = player;
                  this.controlled_unit = unit;
                }
                players.add(player);
                gameObjs.add(unit);
              } else if (obj instanceof FireballData) {
                FireballData fireball_data = (FireballData) obj;
                Fireball fireball =  new Fireball(fireball_data);
                gameObjs.add(fireball);
              }
            }
          }
        } 
        catch (IOException e) {
          //println("problem reading packet");
          //System.err.println("Caught IOException: " + e.getMessage());
          //e.printStackTrace();
        } 
        catch (ClassNotFoundException e) {
          System.err.println("Caught ClassNotFoundException: " + e.getMessage());
          //e.printStackTrace();
          //exit();
          return;
        }
      }
    } 
    while (controlled_unit == null || retry < 100);
    if (controlled_unit == null) {
      println("failed to get my player unit");
      closeConnection();
      loadLevel(new Menu());
    }
    hud = new Hud(controlled_unit, players);
  }

  private boolean processPacket() {
    byte[] data = client.readBytesUntil(interesting);
    if (data == null) return false;
    if (data.length < 512) return false;
    System.arraycopy(data, 0, data, 0, data.length - 1);
    Packet packet = null;
    try {
      packet = ps.deserialize(data);
    } 
    catch (IOException e) {
      //System.err.println("Caught IOException: " + e.getMessage());
      //e.printStackTrace();
      return false;
    } 
    catch (ClassNotFoundException e) {
      //System.err.println("Caught ClassNotFoundException: " + e.getMessage());
      //e.printStackTrace();
      return false;
    }
    if (packet.getType() == PacketType.STATE) {
      ArrayList list = packet.getData();
      pregame = packet.isPregame();
      endgame = packet.isGameOver();
      pregame_timer = packet.getPregameTimer();
      world = new World(packet.getRingRadius());
      if (endgame) {
        hud.endGame();
        exit_button = new Button(ButtonAction.BACK, width/2-100, height/2+250, 200, 50, "Quit");
      }
      gameObjs.clear();
      for (Object obj : list) {
        if (obj instanceof PlayerData) {
          PlayerData player_data = (PlayerData) obj;
          Unit unit = new Unit(player_data, world);
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
      return true;
    } else if (packet.getType() == PacketType.PLAYER) {
      ArrayList list = packet.getData();
      players.clear();
      for (Object obj : list) {
        if (obj instanceof PlayerData) {
          PlayerData player_data = (PlayerData) obj;
          Player player = new Player(player_data);
          if (player_name.equals(player.getName())) {
            this.current_player = player;
          }
          players.add(player);
        }
      }
      return false;
    } else {
      return false;
    }
  }

  public void draw() {    
    byte[] data;
    if (!processPacket() && !endgame) {
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

    if (pregame && pregame_timer > 0) {
      fill(0);
      textSize(24);
      text("Game will start in " + (pregame_timer/60 + 1), width/2, height/2);
      pregame_timer--;
    }

    for (GameObject obj : gameObjs) {
      obj.draw();
    }

    for (GameObject obj : removeFromWorld) {
      gameObjs.remove(obj);
    }
    removeFromWorld.clear();

    hud.draw();
    if (endgame) {
      exit_button.draw();
    }
  }

  public void disconnectEvent(Client client) {
    println("server disconnected");
    closeConnection();
    if (endgame) return;
    loadLevel(new Menu());
  }

  private void sendCommand(PVector target, Action action) {
    if (endgame) return; // do not send command if game is ended
    Packet packet = new Packet(PacketType.COMMAND, player_name, target.x, target.y, action);
    byte[] data = null;
    try {
      data = ps.serialize(packet);
      client.write(data);
      client.write(interesting);
    } 
    catch (IOException e) {
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
    if (exit_button != null) {
      exit_button.unhighlight();
      if (exit_button.overButton()) {
        closeConnection();
        loadLevel(new Menu());
      }
    }
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
      sendCommand(new PVector(0, 0), issue_cmd);
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

  private void closeConnection() {
    if (client != null) {
      Client this_client = client;
      client = null;
      this_client.stop();
    }
  }

  public void stop() {
    closeConnection();
  }

  public void mousePressed() {
    if (exit_button == null) return;
    if (exit_button.overButton()) {
      exit_button.highlight();
    }
  }

  public void mouseDragged() {
    if (exit_button == null) return;
    if (exit_button.overButton()) {
      exit_button.highlight();
    } else {
      exit_button.unhighlight();
    }
  }

  public void keyPressed() {
  }
}

