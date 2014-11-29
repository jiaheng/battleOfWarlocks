import java.util.*;

class Hud {
  private Unit controlled_unit;
  private Player current_player; // unused (for now)
  private long duration = 0;
  private SkillButton fb_button, blink_button;
  private boolean timer = false;
  private List<Player> players;
  private boolean gameover = false;

  Hud(Unit controlled_unit, List<Player> players) {
    this.players = players;
    this.controlled_unit = controlled_unit;
    fb_button = new SkillButton(width/2-SkillButton.SIZE*2, height-SkillButton.SIZE, Fireball.COOLDOWN, fireball_icon);
    blink_button = new SkillButton(width/2+SkillButton.SIZE, height-SkillButton.SIZE, Blink.COOLDOWN, blink_icon);
  }

  Hud(Unit controlled_unit, long duration, List<Player> players) {
    this(controlled_unit, players);
    this.duration = duration;
  }

  public String getStrDuration() {
    String str;
    long total_second = (int) (duration / 60f);
    long second = total_second % 60;
    long minute = total_second / 60;
    str = String.format("%02d", minute) + ":" + String.format("%02d", second);
    return str;
  }

  public void startTimer() {
    timer = true;
  }

  public void stopTimer() {
    timer = false;
  }

  public void update() {
    if (timer) 
      duration++;
  }

  public void update(Unit unit, long duration) {
    this.controlled_unit = unit;
    this.duration = duration;
  }

  public Action getCommand() {
    if (fb_button.overButton()) {
      return Action.FIREBALL;
    } else if (blink_button.overButton()) {
      return Action.BLINK;
    } else {
      return Action.NOTHING;
    }
  }

  public void draw() {
    fill(255, 255, 255);
    textSize(24);
    textAlign(CENTER);
    text(getStrDuration(), width/2, 30);
    fb_button.update(controlled_unit.fireball_cooldown);
    fb_button.draw();
    blink_button.update(controlled_unit.blink_cooldown);
    blink_button.draw();
    Collections.sort(players);
    if (!gameover) {
      showScore();
    } else {
      showFinalScore();
    }
  }

  public void showScore() {
    float x = width - 180;
    float x2 = x + 150;
    float y = 20;
    int board_w = 200;
    int board_l = 250;
    fill(0, 150);
    rect(width-board_w, 0, board_w, board_l);
    fill(255);
    textSize(18);
    text("Scoreboard", width-board_w/2, y);
    y += 24;
    textSize(15);
    textAlign(LEFT);
    for (Player player : players) {
      fill(player.getColor());
      text(player.getName(), x, y);
      text(player.getScore(), x2, y);
      y += 22;
    }
    textAlign(CENTER);
  }

  public void showFinalScore() {
    int board_w = 500;
    int board_l = 700;
    float x = width/2 - 200;
    float x2 = x + 400;
    float y = (height - board_l)/2 + 50;
    fill(0, 190);
    rect((width - board_w)/2, (height - board_l)/2, board_w, board_l);
    textSize(30);
    fill(255);
    text("Game Over", width/2, y);
    y += 50;
    textSize(24);
    textAlign(LEFT);
    for (Player player : players) {
      fill(player.getColor());
      text(player.getName(), x, y);
      text(player.getScore(), x2, y);
      y += 35;
    }
    textAlign(CENTER);
  }

  public long getDuration() {
    return duration;
  }

  public void endGame() {
    stopTimer();
    fb_button.disable();
    blink_button.disable();
    gameover = true;
  }
  
  public void enable() {
    startTimer();
    fb_button.enable();
    blink_button.enable();
  }
  
  public void disable() {
    stopTimer();
    fb_button.disable();
    blink_button.disable();
  }
}

