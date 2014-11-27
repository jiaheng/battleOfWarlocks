class Button {
  
  private static final int FONT_SIZE = 28;
  private static final color HIGHLIGHT_COLOR = 128;
  private static final color NORMAL_COLOR = 0;
  
  private color button_color = NORMAL_COLOR;
  private int button_x, button_y, button_len, button_width;
  private String label;
  private ButtonAction action;
  
  Button(ButtonAction action, int button_x, int button_y, int button_len, int button_width, String label) {
    this.action = action;
    this.button_x = button_x;
    this.button_y = button_y;
    this.button_len = button_len;
    this.button_width = button_width;
    this.label = label;
  }
  
  public void draw() {
    fill(button_color);
    rect(button_x, button_y, button_len, button_width);
    fill(255);
    textSize(FONT_SIZE);
    textAlign(CENTER);
    text(this.label, button_x + button_len/2, button_y+FONT_SIZE/3 + button_width/2);
  }
  
  public void highlight() {
    button_color = HIGHLIGHT_COLOR;
  }
  
  public void unhighlight() {
    button_color = NORMAL_COLOR;
  }
  
  public ButtonAction getAction() {
    return action;
  }
  
  public boolean overButton()  {
    if (mouseX >= button_x && mouseX <= button_x + button_len && 
        mouseY >= button_y && mouseY <= button_y + button_width) {
      return true;
    } else {
      return false;
    }
  }
}
