class Game extends Level {
  
  private int init_minute, init_second;
  private World world;
  private Unit controlled_unit;  
  private Hud hud;
  private Action issue_cmd = Action.NOTHING;

  public void begin() {
    init_minute = minute();
    init_second = second();
    world = new World(init_second);

    Unit u1 = new Unit(width/2, height/2, 0f, "You", color(255, 0, 0), world);
    Unit u2 = new Unit(width/2+100, height/2-150, 0f, "unknown", color(255, 255, 0), world);
    gameObjs.add(u1);
    gameObjs.add(u2);
    controlled_unit = u1;
    hud = new Hud(controlled_unit, null);
  }

  public void draw() {
    world.draw();

    for (GameObject obj : gameObjs) {
      obj.update();
    }

    for (GameObject obj : gameObjs) {
      checkCollisions(obj);
      obj.draw();
    }

    for (GameObject obj : addToWorld) {
      gameObjs.add(obj);
    }
    addToWorld.clear();

    for (GameObject obj : removeFromWorld) {
      gameObjs.remove(obj);
    }
    removeFromWorld.clear();

    hud.draw();
  }

  private void checkCollisions(GameObject other) {
    for (GameObject obj : gameObjs) {
      if (obj != other && obj.collidingWith(other)) {
        obj.collidedWith(other);
      }
    }
  }

  public void mouseReleased() {
    PVector target = new PVector(mouseX, mouseY);
    if (mouseButton == RIGHT) { 
      if (issue_cmd == Action.NOTHING) { // move command if no cmd issued
        controlled_unit.command(target, Action.MOVE);
      } else { // if a cmd issued, cancel the cmd
        issue_cmd = Action.NOTHING;
        cursor(ARROW);
      }
    } else if (mouseButton == LEFT) {
      Action command = hud.getCommand();
      if (command == Action.NOTHING && issue_cmd != Action.NOTHING) { //if no button is clicked and there is a command issue
        controlled_unit.command(target, issue_cmd);
        cursor(ARROW);
        issue_cmd = Action.NOTHING;
      } else if (command != Action.NOTHING) { //if a button is clicked
        selectAction(command);
      }
      //PVector target = new PVector(mouseX, mouseY);
      //controlled_unit.cast(target);
    }
  }

  public void keyReleased() {
    if (key == 'f' || key == 'F') {
      selectAction(Action.FIREBALL);
    } else if (key == 'm' || key == 'M') {
      selectAction(Action.MOVE);
    }
  }

  private void selectAction(Action action) {
    int cooldown = controlled_unit.getCooldown(action);
    if (cooldown == 0) {
      issue_cmd = action;
      cursor(CROSS);
    } else if (cooldown > 0) {
      // show cooldown message
    } else {
      println("error!");
    }
  }

  public void mouseDragged() {
  }
  public void mousePressed() {
  }
  public void keyPressed() {
  }
  public void stop() {
  }
}

