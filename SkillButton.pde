class SkillButton {

  public static final int SIZE = 50;

  private final int total_cooldown;

  private boolean disabled = false;
  private int current_cooldown;
  private int button_x, button_y;
  private PImage icon;

  SkillButton(int position_x, int position_y, int total_cooldown, PImage icon) {
    button_x = position_x;
    button_y = position_y;
    this.total_cooldown = total_cooldown;
    this.icon = icon;
  }

  public void update(int current_cooldown) {
    this.current_cooldown = current_cooldown;
  }

  public void draw() {
    fill(128);
    rect(button_x, button_y, SIZE, SIZE);
    image(icon, button_x, button_y);
    if (current_cooldown > 0) {
      float percentage = (float)current_cooldown / (float)total_cooldown;
      fill(0, 50);
      rect(button_x, button_y, SIZE, SIZE);
      fill(0, 150);
      rect(button_x, button_y + SIZE*(1-percentage), SIZE, SIZE*percentage);
      fill(255, 255, 255);
      textSize(18);
      textAlign(CENTER);
      text(ceil(current_cooldown/60f), button_x+SIZE/2, button_y+9+SIZE/2);
    }
    if (disabled) {
      fill(0, 75);
      rect(button_x, button_y, SIZE, SIZE);
    }
  }

  public void disable() {
    disabled = true;
  }

  public void enable() {
    disabled = false;
  }

  public boolean isDisable() {
    return disabled;
  }

  public boolean overButton() {
    if (mouseX >= button_x && mouseX <= button_x+SIZE && 
      mouseY >= button_y && mouseY <= button_y + SIZE) {
      return true;
    } else {
      return false;
    }
  }
}

