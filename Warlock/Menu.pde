import gifAnimation.*;

class Menu extends Level {
  private final int BUTTON_LEN = 600;
  private final int BUTTON_WIDTH = 100;
  private final int MAX_NAME_LEN = 16;
  
  private Gif title;
  private ArrayList<Button> buttons = new ArrayList<Button>();

  public void begin() {
    title = new Gif(parent, "title.gif");
    title.play();
    
    int button_y = 250;
    int spacing = 30;
    Button button = new Button(ButtonAction.START, width/2-BUTTON_LEN/2, button_y, BUTTON_LEN, BUTTON_WIDTH, "Start Game");
    buttons.add(button);
    button_y += BUTTON_WIDTH + spacing;
    button = new Button(ButtonAction.JOIN, width/2-BUTTON_LEN/2, button_y, BUTTON_LEN, BUTTON_WIDTH, "Join Game");
    buttons.add(button);
    button_y += BUTTON_WIDTH + spacing;
    button = new Button(ButtonAction.TOOGLE, width/2-BUTTON_LEN/2, button_y, BUTTON_LEN, BUTTON_WIDTH, "Current Setting: Right click to Move");
    buttons.add(button);
    button_y += BUTTON_WIDTH + spacing;
    button = new Button(ButtonAction.QUIT, width/2-BUTTON_LEN/2, button_y, BUTTON_LEN, BUTTON_WIDTH, "Quit");
    buttons.add(button);
    button_y += BUTTON_WIDTH + spacing;
  }

  public void draw() {
    background(bg);
    image(title, (width-716)/2, 50);
    for (Button button : buttons) {
      button.draw();
    }
    fill(0);
    int textarea_length = 500;
    int y = height/2-230;
    rect((width-textarea_length)/2, y, textarea_length, 40);
    fill(255);
    text(player_name, width/2, y+30);
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
    if (selected_button != null && player_name.length() > 0) {
      ButtonAction action = selected_button.getAction();
      switch(action) {
      case START:
        loadLevel(new ServerLobby());
        return;
      case JOIN:
        loadLevel(new JoinLobby());
        return;
      case TOOGLE:
        if (left_mouse_as_move) {
          selected_button.changeLabel("Current Setting: Right click to Move");
          left_mouse_as_move = false;
        } else {
          selected_button.changeLabel("Current Setting: Left click to Move");
          left_mouse_as_move = true;
        }
        return;
      case QUIT:
        exit();
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
        play(sfx_typing);
      }
    } else if (key != CODED && key != TAB && key != ENTER && key != RETURN && key != ESC && key != DELETE) {
      // Otherwise, concatenate the String
      // Each character typed by the user is added to the end of the String variable.
      if (player_name.length() < MAX_NAME_LEN) player_name += key;
      play(sfx_typing);
    }
  }

  public void stop() {
  }
  public void keyReleased() {
  }
}