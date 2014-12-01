import processing.net.*;
import java.lang.ClassLoader.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

class GameServer extends Level {
  private final int PACKET_FREQ = 3;
  private final int SCORE_FREQ = 30;
  
  private CopyOnWriteArrayList<Player> players = new CopyOnWriteArrayList<Player>();
  private CopyOnWriteArrayList<GameObject> remove_from_game = new CopyOnWriteArrayList<GameObject>();
  private ConcurrentHashMap<String, Unit> units = new ConcurrentHashMap<String, Unit>(10);
  private int total_player = 0;

  private PacketSerializer ps = new PacketSerializer();
  private Server server;
  private int init_minute, init_second;
  private World world;
  private Unit controlled_unit;  
  private Hud hud;
  private Action issue_cmd = Action.NOTHING;

  private int score_timer = 0;
  private int packet_timer = 0;
  private boolean pregame = true;
  private int pregame_timer = 300;
  private boolean endgame = false;
  private int score_point = 1;
  private Player current_player;

  private Button exit_button = null;
  private boolean endround = false;
  private int endround_timer = 300;
  private int round = 1;

  GameServer(Server server, ArrayList<Player> players) {
    this.server = server;
    for (Player player : players) {
      this.players.add(player);
    }
    this.total_player = players.size();
  }

  public void begin() {
    endround = false;
    endround_timer = 300;
    pregame = true;
    pregame_timer = 300;
    init_minute = minute();
    init_second = second();
    units.clear();
    remove_from_game.clear();
    gameObjs.clear();
    addToWorld.clear();
    removeFromWorld.clear();
    world = new World(init_second);

    createUnit();
    if (controlled_unit == null) {
      println("unable to find the controlled unit");
      exit();
      return;
    }
    for (Player player : players) {
      if (player.getName().equals(player_name)) {
        current_player = player;
        break;
      }
    }
    hud = new Hud(controlled_unit, players);
  }

  private void createUnit() {
    float angle = TWO_PI/total_player;
    float orientation = 0;
    PVector spawn_vector = new PVector(-1, 0);
    spawn_vector.mult(250);
    for (Player player : players) {
      player.respawn();
      PVector spawn_point = new PVector(width/2, height/2);
      spawn_point.add(spawn_vector);
      color unit_color = color(player.getColor());
      Unit unit = new Unit(spawn_point.x, spawn_point.y, orientation, player.getName(), unit_color, world);
      String ip = player.getIp();
      if (ip.equals(HOST)) {
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

  private void sendScore() {
    ArrayList list = new ArrayList();
    for (Player player : players) {
      PlayerData player_data = new PlayerData(player);
      list.add(player_data);
    }
    Packet packet = new Packet(PacketType.PLAYER, list);
    byte[] data = null;
    try {
      data = ps.serialize(packet);
      server.write(interesting);
      server.write(data);
      server.write(interesting);
      //println(data.length);
    } 
    catch (IOException e) {
      System.err.println("Caught IOException: " + e.getMessage());
      e.printStackTrace();
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
    Packet packet = new Packet(PacketType.STATE, world.getRadius(), pregame, endgame, pregame_timer, endround, endround_timer, hud.getDuration(), list);
    byte[] data = null;
    try {
      data = ps.serialize(packet);
      server.write(interesting);
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

    if (!endgame) world.update();
    world.draw();

    if (pregame) {
      fill(0);
      textSize(24);
      text("Game will start in " + (pregame_timer/60+1), width/2, height/2);
      pregame_timer--;
      if (pregame_timer < 0) {
        hud.startTimer();
        pregame = false;
      }
    }

    if (!endgame) { // do not update if the game is ended
      for (GameObject obj : gameObjs) {
        obj.update();
      }
    }

    for (GameObject obj : gameObjs) {
      checkCollisions(obj);
      obj.draw();
    }

    for (GameObject obj : addToWorld) {
      gameObjs.add(obj);
    }
    addToWorld.clear();

    boolean player_died = false;
    for (GameObject obj : removeFromWorld) {
      if (obj instanceof Unit) {
        Unit unit = (Unit) obj;
        String name = unit.getName();
        for (Player player : players) {
          if (player.getName().equals(name)) {
            player.killed();
            player.addScore(score_point);
            player_died = true;
          }
        }
      }
      gameObjs.remove(obj);
    }
    removeFromWorld.clear();
    if (player_died) score_point += 1;

    for (GameObject obj : remove_from_game) {
      gameObjs.remove(obj);
    }
    remove_from_game.clear();

    // check if player is still alive
    int num_alive = getPlayerAlive();
    if (num_alive <= 1 && !endgame && !endround) {
      // add point to player alive
      for (Player player : players) {
        if (!player.isDead()) {
          player.addScore(score_point);
        }
      }
      endRound();
    }

    hud.update();
    hud.draw();

    if (endround) {
      fill(0);
      textSize(24);
      text("Round end, next round will start in " + (endround_timer/60+1), width/2, height/2);
      endround_timer--;
      if (endround_timer < 0) {
        begin();
      }
    }

    if (endgame) {
      exit_button.draw();
    }

    if (packet_timer > 0) {
      packet_timer--;
    } else {
      sendState();
      packet_timer = PACKET_FREQ;
    }

    if (score_timer > 0) {
      score_timer--;
    } else {
      sendScore();
      score_timer = SCORE_FREQ;
    }
  }

  private void endRound() {
    if (round < TOTAL_ROUND) {
      endround = true;
      round++;
    } else {
      endgame = true;
      hud.endGame();
      exit_button = new Button(ButtonAction.BACK, width/2-100, height/2+250, 200, 50, "Quit");
    }
  }
  
  private int getPlayerAlive() {
    int alive = 0;
    for (Player player : players) {
      if (!player.isDead()) alive++;
    }
    return alive;
  }

  private void removePlayer(String ip) {
    if (endgame) return;
    Unit unit = units.remove(ip);
    if (unit == null) return; //exit if the player doesnt exist
    for (Player player : players) {
      if (player.getIp().equals(ip)) {
        players.remove(player);
      }
    }
    remove_from_game.add(unit); //remove from game objects
    total_player--;
  }

  public void disconnectEvent(Client client) {
    println(client.ip() + " disconnected");
    removePlayer(client.ip());
  }

  private void processCommand(Packet packet, String ip) {
    if (pregame || endgame || endround) return; // all unit freeze before match start
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

  private void processCommand(String ip, PVector target, Action action) {
    if (pregame || endgame || endround) return; // all unit freeze before match start
    Unit unit = units.get(ip);
    if (unit != null) {
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
        processCommand(HOST, target, Action.MOVE);
      } else { // if a cmd issued, cancel the cmd
        issue_cmd = Action.NOTHING;
        cursor(ARROW);
      }
    } else if (mouseButton == LEFT) {
      Action command = hud.getCommand();
      if (command == Action.NOTHING && issue_cmd != Action.NOTHING) { //if no button is clicked and there is a command issue
        processCommand(HOST, target, issue_cmd);
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
      processCommand(HOST, null, Action.NOTHING);
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
    closeConnection();
  }

  private void closeConnection() {
    if (server != null) {
      server.stop();
      server = null;
    }
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

