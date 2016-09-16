import processing.net.*;
import java.net.*;

public class JoinLobby extends Level {
  private final int CLIENT_DISCOVERY_INTERVAL = 300;
  private static final int JOIN_BUTTON_HEIGHT = 30;

  private int discovery_counter = 0;

  private static final int tf_len = 500; // text field length
  private static final int tf_width = 120; // text field width
  private static final int status_position_y = 20;

  private final int box_width = width/10*9;
  private final int box_height = height - 300;

  private int list_starting_x = (width-box_width)/2;
  private int list_starting_y = (height-box_height)/2;

  private String warning = "";
  private boolean connecting = false;
  private ArrayList<Button> buttons = new ArrayList<Button>();
  private Set<JoinButton> joinButtons = new HashSet<JoinButton>();
  private Client client = null;
  private int retry = 0;

  private MulticastSocket socket;

  public JoinLobby() {
    try {
      socket = new MulticastSocket(CLIENT_PORT_NUM);
      socket.joinGroup(SERVER_DISCOVERY_GROUP);
      socket.setSoTimeout(10);
    } catch (SocketException e) {
      e.printStackTrace();
      socket.close();
      exit();
    } catch (IOException e) {
      e.printStackTrace();
      socket.close();
      exit();
    }
  }

  public void begin() {
    Button button;
    int button_height = 50;
    int button_width = 300;
    button = new Button(ButtonAction.BACK, width/2-button_width/2, height-button_height-20, button_width, button_height, "BACK");
    buttons.add(button);

    sendDiscoveryRequest();
  }

  public void draw() {
    LobbyInfoPacket lobbyInfo = receiveLobbyInfo();
    if (lobbyInfo != null) {
      JoinButton joinButton = new JoinButton(list_starting_x, list_starting_y, box_width, JOIN_BUTTON_HEIGHT, lobbyInfo);
      joinButtons.add(joinButton);
      println("number of server: " + joinButtons.size());
    }
    if (discovery_counter == CLIENT_DISCOVERY_INTERVAL) {
      discovery_counter = 0;
      sendDiscoveryRequest();
    } else {
      discovery_counter++;
    }

    if (connecting) {
      // try to get reply from server if connected to server
      serverRead();
    }
    background(bg);
    fill(0);
    textSize(20);

    rect(list_starting_x, list_starting_y, box_width, box_height);

    rect(width/2-tf_len/2, status_position_y, tf_len, tf_width);
    fill(255);
    fill(255, 0, 0);
    text(warning, width/2, status_position_y+100);
    if (!connecting) {
      for (Button button : buttons) {
        button.draw();
      }
    }
    int joinButtonCounter = 0;
    for (JoinButton button : joinButtons) {
      button.setYPosition(list_starting_y + JOIN_BUTTON_HEIGHT * joinButtonCounter++);
      button.draw();
    }
  }

  private LobbyInfoPacket receiveLobbyInfo() {
    byte[] buffer = new byte[LobbyInfoPacket.SIZE];
    DatagramPacket receivePacket = new DatagramPacket(buffer, buffer.length);
    Packet packet = null;
    try {
      socket.receive(receivePacket);
      println(receivePacket.getAddress().getHostAddress() + " " + receivePacket.getPort());
      packet = PacketSerializer.deserialize(receivePacket.getData());
      println(packet.getType());
      if (packet.getType() == PacketType.LOBBY_INFO) {
        LobbyInfoPacket lobbyInfoPacket = (LobbyInfoPacket) packet;
        lobbyInfoPacket.setSocketAddress(receivePacket.getSocketAddress());
        lobbyInfoPacket.setIpAddress(receivePacket.getAddress().getHostAddress());
        lobbyInfoPacket.setPortNumber(receivePacket.getPort());
        return (LobbyInfoPacket) lobbyInfoPacket;
      } else {
        return null;
      }
    } catch (SocketTimeoutException e) {
      return null;
    } catch (IOException e) {
      e.printStackTrace();
      exit();
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
      exit();
    }
    return null;
  }

  private void sendDiscoveryRequest() {
    DiscoveryPacket packet = new DiscoveryPacket();
    byte[] buffer;
    try {
      buffer = PacketSerializer.serialize(packet);
    } catch (Exception e) {
      e.printStackTrace();
      buffer = new byte[0];
      exit();
    }
    DatagramPacket datagramPacket = new DatagramPacket(buffer, buffer.length, SERVER_DISCOVERY_GROUP, SERVER_PORT_NUM);
    if (buffer.length > DiscoveryPacket.SIZE) {
      println("Discovery Packet size too large: " + buffer.length + " bytes.");
    }
    try {
      socket.send(datagramPacket);
      println("send discovery");
    } catch (IOException e) {
      e.printStackTrace();
      exit();
    }
  }

  private void closeConnection() {
    if (client != null) {
      println("disconnecting from join lobby");
      client.stop();
    }

    if (socket != null) {
      socket.close();
    }
  }

  private void connect(String ip, int portNumber) {
    // connecting to server
    warning = "";
    retry = 0;
    portNumber = PORT_NUM; // TODO: temporary hard code
    println("IP: " + ip + ":" + portNumber);
    client = new Client(parent, ip, portNumber);
    if (client == null) {
      warning = "Unable to connect.";
      return;
    }
    // ask for joining the game
    Packet packet = new Packet(PacketType.JOIN, player_name);
    byte[] data = null;
    try {
      data = PacketSerializer.serialize(packet);
      client.write(data);
      client.write(interesting);
      connecting = true;
    }
    catch (IOException e) {
      System.err.println("Caught IOException: " + e.getMessage());
      e.printStackTrace();
      exit();
    }
  }

  private void serverRead() {
    // get reply from server
    retry++;
    byte[] data = client.readBytesUntil(interesting);
    if (data != null) {
      System.arraycopy(data, 0, data, 0, data.length - 1);
      try {
        Packet packet = PacketSerializer.deserialize(data);
        if (packet.getType() == PacketType.ACCEPT) {
          // go to lobby
          loadLevel(new ClientLobby(client));
          return;
        } else if (packet.getType() == PacketType.REJECT) {
          warning = "Connection Rejected";
          connecting = false;
          return;
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
    if (retry > 100) {
      // failed to connect after 100 retry
      connecting = false;
      warning = "Failed to connect";
    }
  }

  public void keyPressed() {

  }

  private Button selectedButton() {
    for (Button button : buttons) {
      if (button.overButton()) return button;
    }
    for (Button button : joinButtons) {
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
    for (Button button : joinButtons) {
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
      case JOIN:
        if (!connecting) {
          JoinButton joinButton = (JoinButton) selected_button;
          connect(joinButton.getIpAddress(), joinButton.getPortNumber());
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

  public void stop() {
    closeConnection();
  }

  public void keyReleased() {
  }
}
