import processing.net.*;

class JoinLobby extends Level {
  
  // Variable to store text currently being typed
  private String ip = "";
  private String warning = "";
  private boolean connecting = false;
  private ArrayList<Button> buttons = new ArrayList<Button>();
  private Client client = null;
  private int retry = 0;
  private PacketSerializer ps = new PacketSerializer();  
  
  public void begin() {
    Button button;
    int button_height = 50;
    int button_width = 300;
    button = new Button(ButtonAction.JOIN, width/2-button_width/2, height/2, button_width, button_height, "JOIN");
    buttons.add(button);
    button = new Button(ButtonAction.BACK, width/2-button_width/2, height/2+button_height+20, button_width, button_height, "BACK");
    buttons.add(button);
  }
  
  public void draw() {
    if (connecting) {
      serverRead();
    }
    background(bg);
    fill(0);
    textSize(20);
    // Display everything
    int tf_len = 500; // text field length
    int tf_width = 120; // text field width
    rect(width/2-tf_len/2, height/2-130, tf_len, tf_width);
    fill(255);
    text("Type the IP of the host and click JOIN", width/2, height/2-100);
    text(ip,width/2,height/2-70);
    fill(255,0,0);
    text(warning,width/2,height/2-50);
    if (!connecting) { 
      for (Button button : buttons) {
        button.draw();
      }
    }
  }
  
  private void closeConnection() {
    if (client != null) {
      println("disconnecting from join lobby");
      client.stop();
    }
  }
  
  private void connect() {
    warning = "";
    retry = 0;
    client = new Client(parent, ip, PORT_NUM);
    if (client == null) {
      warning = "Unable to connect.";
      return;
    }
    Packet packet = new Packet(PacketType.JOIN, player_name);
    byte[] data = null;
    try {
      data = ps.serialize(packet);
      client.write(data);
      client.write(interesting);
      connecting = true;
    } catch (IOException e) {
      System.err.println("Caught IOException: " + e.getMessage());
      e.printStackTrace();
      exit();
    }
  }
  
  private void serverRead() {
    retry++;
    byte[] data = client.readBytesUntil(interesting);
    if (data != null) {
      System.arraycopy(data, 0, data, 0, data.length - 1);
      try {
        Packet packet = ps.deserialize(data);
        if (packet.getType() == PacketType.ACCEPT) {
          loadLevel(new ClientLobby(client));
          return;
        } else if (packet.getType() == PacketType.REJECT) {
          warning = "Connection Rejected";
          connecting = false;
          //println("disconnecting");
          //client.stop();
          //client = null;
          return;
        }
      } catch (IOException e) {
        System.err.println("Caught IOException: " + e.getMessage());
        e.printStackTrace();
        return;
      } catch (ClassNotFoundException e) {
        System.err.println("Caught ClassNotFoundException: " + e.getMessage());
        e.printStackTrace();
        return;
      }
    }
    if (retry > 100) {
      connecting = false;
      warning = "Failed to connect";
    }
  }
  
  public void keyPressed() {
    if (key == BACKSPACE ) {
      // remove last character
      if (ip.length() > 0) {
        ip = ip.substring(0, ip.length()-1);
      }
    } else if (key == ENTER) {
      // join
      connect();
    } else {
      // Otherwise, concatenate the String
      // Each character typed by the user is added to the end of the String variable.
      ip = ip + key; 
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
        case JOIN:
          connect();
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
  
  public void keyReleased() {}
}
