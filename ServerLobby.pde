import processing.net.*;

class ServerLobby extends Level {

  private color[] color_list = new color[] {
    color(#FF0000), 
    color(#1400FF), 
    color(#A900FF), 
    color(#FFF300), 
    color(#11DB00), 
    color(#FC36B4), 
    color(#9B6000), 
    color(#1FFFEA)
  };
  private int WIDTH = 500;
  private int LENGTH = 600;
  private ArrayList<Button> buttons = new ArrayList<Button>();
  private ArrayList<Player> players = new ArrayList<Player>();
  private PacketSerializer ps = new PacketSerializer();  
  private Server server;
  private int timer = 0;
  private int total_player = 0;
  private String msg = "";

  public void begin() {
    Button button;
    int button_height = 50;
    int button_width = 200;
    server = new Server(parent, PORT_NUM);
    button = new Button(ButtonAction.START, width/2-button_width-50, height-100, button_width, button_height, "START");
    buttons.add(button);
    button = new Button(ButtonAction.BACK, width/2+50, height-100, button_width, button_height, "BACK");
    buttons.add(button);
    createPlayer(player_name, HOST);
  }

  private void closeConnection() {
    if (server != null) {
      println("server is closing");
      server.stop();
    }
  }

  private color getUnusedColor() {
    for (color c : color_list) {
      boolean unused = true;
      for (Player player : players) {
        if (c == player.getColor()) {
          unused = false;
          break;
        }
      }
      if (unused) return c;
    }
    return -1;
  }

  private boolean createPlayer(String name, String ip) {
    if (total_player >= 8) return false;
    color unit_color = getUnusedColor();
    for (Player player : players) {
      if (player.getName().equals(name))
        return false;
    }
    Player player = new Player(name, unit_color, ip);
    players.add(player);
    total_player++;
    return true;
  }

  private void findPlayer() {
    // Get the next available client
    Client client = server.available();
    // If the client is not null, and says something, display what it said
    if (client !=null && client.available() > 0) {
      byte[] data = client.readBytesUntil(interesting);
      if (data == null) return;
      System.arraycopy(data, 0, data, 0, data.length - 1);
      Packet packet = null;
      try {
        packet = ps.deserialize(data);
        // a player joining
        if (packet.getType() == PacketType.JOIN) {
          println(client.ip() + " is joining the game");
          if (createPlayer(packet.getName(), client.ip())) {
            packet = new Packet(PacketType.ACCEPT);
            data = ps.serialize(packet);
            client.write(data);
            client.write(interesting);
          } else {
            packet = new Packet(PacketType.REJECT);
            data = ps.serialize(packet);
            client.write(data);
            client.write(interesting);
            println("disconnecting client " + client.ip());
            server.disconnect(client);
          }
        } else {
          server.disconnect(client);
        }
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
    }
  }

  private void startGame() {
    Packet packet = new Packet(PacketType.START);
    byte[] data = null;
    try {
      data = ps.serialize(packet);
      server.write(data);
      server.write(interesting);
    } 
    catch (IOException e) {
      System.err.println("Caught IOException: " + e.getMessage());
      e.printStackTrace();
    }
    loadLevel(new GameServer(server, players));
  }

  private void sendList() {
    ArrayList list = new ArrayList();
    for (Player player : players) {
      PlayerData data = new PlayerData(player);
      list.add(data);
    }
    Packet packet = new Packet(PacketType.LIST, list);
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

  private void removePlayer(String ip) {
    for (Player player : players) {
      if (player.getIp().equals(ip)) {
        players.remove(player);
        total_player--;
        return;
      }
    }
  }

  public void disconnectEvent(Client client) {
    println(client.ip() + " disconnected");
    removePlayer(client.ip());
  }

  public void draw() {
    findPlayer();
    background(bg);
    fill(0);
    rect((width-WIDTH)/2f, (height-LENGTH-100)/2f, WIDTH, LENGTH);
    fill(255);
    textSize(32);
    float y = (height-LENGTH)/2f;
    text("Lobby", width/2, y);
    y += 50;
    textSize(20);
    for (Player player : players) {
      fill(player.getColor());
      text(player.getName(), width/2, y);
      y += 30;
    }
    fill(255);
    y += 100;
    text(msg, width/2, y);
    for (Button button : buttons) {
      button.draw();
    }
    if (timer > 0) {
      timer--;
    } else {
      sendList();
      timer = 5;
    }
  }

  private Button selectedButton() {
    for (Button button : buttons) {
      if (button.overButton()) return button;
    }
    return null;
  }

  public void mousePressed() {
    Button selected_button = selectedButton();
    if (selected_button != null) {
      selected_button.highlight();
    }
  }

  public void mouseDragged() {
    for (Button button : buttons) {
      button.unhighlight();
    }
    Button selected_button = selectedButton();
    if (selected_button != null) {
      selected_button.highlight();
    }
  }

  public void mouseReleased() {
    for (Button button : buttons) {
      button.unhighlight();
    }
    Button selected_button = selectedButton();
    if (selected_button != null) {
      ButtonAction action = selected_button.getAction();
      switch(action) {
      case START:
        if (total_player<2) {
          msg = "Not enough player\nneed at least 2 players to play the game";
        }
        startGame();
        return;
      case BACK:
        closeConnection();
        loadLevel(new Menu());
        return;
      default:
        println("error!");
        return;
      }
    }
  }
  public void keyPressed() {
  }
  public void keyReleased() {
  }

  public void stop() {
    closeConnection();
  }
}

