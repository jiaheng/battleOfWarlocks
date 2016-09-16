import processing.net.*;
import java.util.concurrent.CopyOnWriteArrayList;
import java.net.*;

class ServerLobby extends Level {
  private final int SERVER_DISCOVERY_INTERVAL = 60;
  private int discovery_counter = 0;

  private MulticastSocket discoverySocket;
  private DatagramSocket serverSocket;

  // color used to represent each player
  private final color[] color_list = new color[] {
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
  private CopyOnWriteArrayList<Player> players = new CopyOnWriteArrayList<Player>();
  private PacketSerializer ps = new PacketSerializer();
  private Server server;
  private int timer = 0;
  private int total_player = 0;
  private String msg = "";

  public ServerLobby() {
    try {
      serverSocket = new DatagramSocket();
      discoverySocket = new MulticastSocket(SERVER_PORT_NUM);
      discoverySocket.joinGroup(SERVER_DISCOVERY_GROUP);
      discoverySocket.setSoTimeout(50);
    } catch (SocketException e) {
      e.printStackTrace();
      discoverySocket.close();
      exit();
    } catch (IOException e) {
      e.printStackTrace();
      discoverySocket.close();
      exit();
    }
  }

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

    receiveDiscoveryRequest();
  }

  private void receiveDiscoveryRequest() {
    byte[] buffer = new byte[DiscoveryPacket.SIZE];
    DatagramPacket receivePacket = new DatagramPacket(buffer, buffer.length);
    Packet packet = null;
    try {
      discoverySocket.receive(receivePacket);
      packet = PacketSerializer.deserialize(receivePacket.getData());
      println(packet.getType());
      println(receivePacket.getAddress().getHostAddress() + " " + receivePacket.getPort());
      SocketAddress clientAddress = receivePacket.getSocketAddress();
      LobbyInfoPacket serverInfoPacket = new LobbyInfoPacket(player_name + " Server", total_player, MAX_PLAYER);
      buffer = PacketSerializer.serialize(serverInfoPacket);
      DatagramPacket outgoingPacket = new DatagramPacket(buffer, buffer.length, clientAddress);
      if (buffer.length > LobbyInfoPacket.SIZE) {
        println("Lobby info Packet size too large: " + buffer.length + " bytes.");
      }
      discoverySocket.send(outgoingPacket);
      println("sending back " + buffer.length + " bytes. and id:" + serverInfoPacket.getSenderUUID());
    } catch (SocketTimeoutException e) {
      return;
    } catch (IOException e) {
      e.printStackTrace();
      exit();
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
      exit();
    }
  }

  private void closeConnection() {
    if (server != null) {
      server.stop();
    }

    if (discoverySocket != null) {
      discoverySocket.close();
    }
  }

  private color getUnusedColor() {
    // find unused color for representing a player
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
    if (total_player >= MAX_PLAYER) return false; // maximum 8 player
    color unit_color = getUnusedColor();
    for (Player player : players) {
      if (player.getName().equals(name))
        // if player name is used
        return false;
    }
    Player player = new Player(name, unit_color, ip);
    players.add(player);
    total_player++;
    msg = "";
    return true;
  }

  private void findPlayer() {
    // receive data from connected client
    Client client = server.available();
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
            // if failed to create a player
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
    // tell clients to start the games
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
    // load game
    loadLevel(new GameServer(server, players));
  }

  private void sendList() {
    // send list of players in the lobby
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
    // send list of players in the lobby
    if (timer > 0) {
      timer--;
    } else {
      sendList();
      timer = 5;
    }

    // check discovery request
    if (discovery_counter == SERVER_DISCOVERY_INTERVAL) {
      discovery_counter = 0;
      receiveDiscoveryRequest();
    } else {
      discovery_counter++;
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
        } else {
          startGame();
        }
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
