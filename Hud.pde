class Hud {
  private Unit controlled_unit;
  private long duration = 0;
  private SkillButton fb_button, blink_button;

  Hud(Unit controlled_unit) {
    this.controlled_unit = controlled_unit;
    fb_button = new SkillButton(width/2-SkillButton.SIZE*2, height-SkillButton.SIZE, Fireball.COOLDOWN, fireball_icon);
    blink_button = new SkillButton(width/2+SkillButton.SIZE, height-SkillButton.SIZE, Blink.COOLDOWN, blink_icon);
  }

  Hud(Unit controlled_unit, long duration) {
    this(controlled_unit);
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

  public void update() {
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
  }

  public long getDuration() {
    return duration;
  }
}

