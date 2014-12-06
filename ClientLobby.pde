import processing.net.*;

class ClientLobby extends Level {

  private int WIDTH = 500;
  private int LENGTH = 600;
  private ArrayList<Player> players = new ArrayList<Player>();
  private ArrayList<Button> buttons = new ArrayList<Button>();
  private PacketSerializer ps = new PacketSerializer();  
  private Client client;

  ClientLobby(Client client) {
    this.client = client;
  } 

  public void begin() {
    Button button;
    int button_height = 50;
    int button_width = 200;
    button = new Button(ButtonAction.BACK, width/2+50, height-100, button_width, button_height, "BACK");
    buttons.add(button);
  }

  private void closeConnection() {
    if (client != null) {
      println("disconnecting from client lobby");
      client.stop();
    }
  }

  private void receiveData() {
    byte[] data = client.readBytesUntil(interesting);
    if (data == null) return;
    System.arraycopy(data, 0, data, 0, data.length - 1); // remove the last byte(interesting) of the data
    Packet packet = null;
    try {
      packet = ps.deserialize(data);
      if (packet.getType() == PacketType.LIST) {
        // if the packet contain a list of player in the lobby
        ArrayList list = packet.getData();
        players.clear();
        for (Object obj : list) {
          if (obj instanceof PlayerData) {
            PlayerData player_data = (PlayerData) obj;
            Player player = new Player(player_data);
            players.add(player);
          }
        }
      } else if (packet.getType() == PacketType.START) {
        // start the game
        loadLevel(new GameClient(client));
      }
    } 
    catch (IOException e) {
      System.err.println("Caught IOException: " + e.getMessage());
      e.printStackTrace();
      return;
    } 
    catch (ClassNotFoundException e) {
      System.err.println("Caught ClassNotFoundException: " + e.getMessage());
      return;
    }
  }

  public void disconnectEvent(Client client) {
    println("Server disconnected");
    closeConnection();
    loadLevel(new Menu());
  }

  public void draw() {
    receiveData();
    background(bg);
    fill(0);
    rect((width-WIDTH)/2f, (height-LENGTH-100)/2f, WIDTH, LENGTH);
    fill(255);
    textSize(32);
    float y = (height-LENGTH)/2f;
    text("Lobby", width/2, y);
    y += 50;
    textSize(20);
    // list all the players in the lobby
    for (Player player : players) {
      fill(player.getColor());
      text(player.getName(), width/2, y);
      y += 30;
    }
    for (Button button : buttons) {
      button.draw();
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
    // find selected button and execute  
    Button selected_button = selectedButton();
    if (selected_button != null) {
      ButtonAction action = selected_button.getAction();
      switch(action) {
      case BACK:
        // back to main menu
        closeConnection();
        loadLevel(new Menu());
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

