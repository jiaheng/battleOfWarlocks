class Menu extends Level {

  private ArrayList<Button> buttons = new ArrayList<Button>();
  private final int BUTTON_LEN = 600;
  private final int BUTTON_WIDTH = 100;

  public void begin() {
    int button_y = 300;
    Button button = new Button(ButtonAction.START, width/2-BUTTON_LEN/2, button_y, BUTTON_LEN, BUTTON_WIDTH, "Start Game");
    buttons.add(button);
    button_y += BUTTON_WIDTH + 25;
    button = new Button(ButtonAction.JOIN, width/2-BUTTON_LEN/2, button_y, BUTTON_LEN, BUTTON_WIDTH, "Join Game");
    buttons.add(button);
    button_y += BUTTON_WIDTH + 25;
    button = new Button(ButtonAction.TEST, width/2-BUTTON_LEN/2, button_y, BUTTON_LEN, BUTTON_WIDTH, "TEST Game");
    buttons.add(button);
  }

  public void draw() {
    background(bg);
    for (Button button : buttons) {
      button.draw();
    }
    fill(0);
    rect(width/2-500/2, height/2-200, 500, 40);
    fill(255);
    text(player_name, width/2, height/2-170);
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
        loadLevel(new ServerLobby());
        return;
      case JOIN:
        loadLevel(new JoinLobby());
        return;
      case TEST:
        loadLevel(new Game());
        return;
      default:
        println("error!");
        return;
      }
    }
  }

  public void keyPressed() {
    if (key == BACKSPACE) {
      // remove last character
      if (player_name.length() > 0) {
        player_name = player_name.substring(0, player_name.length()-1);
      }
    } else if (key != CODED && key != TAB && key != ENTER && key != RETURN && key != ESC && key != DELETE) {
      // Otherwise, concatenate the String
      // Each character typed by the user is added to the end of the String variable.
      player_name += key;
    }
  }

  public void stop() {
  }
  public void keyReleased() {
  }
}

