import ddf.minim.*;

static final int MAX_PLAYER = 8;
static final int TOTAL_ROUND = 3;
static final int PORT_NUM = 50000;
static final int SERVER_PORT_NUM = 50001;
static final int CLIENT_PORT_NUM = 50002;
static final String LOBBY_LISTEN_ADDRESS = "224.0.0.134";
static final String HOST = "host";
static final UUID APP_UUID = UUID.randomUUID();

private final InetAddress SERVER_DISCOVERY_GROUP;

static Level current_level;

byte interesting = (byte) 127;
final PApplet parent = this;
PGraphics bg;
PImage floor_img, fireball_icon, fireball_img, blink_icon;
String player_name = "player name";
AudioPlayer sfx_fireball, sfx_typing, sfx_blink;
boolean left_mouse_as_move = false;

public Warlock() {
  InetAddress group = null;
  try {
     group = InetAddress.getByName(LOBBY_LISTEN_ADDRESS);
  } catch (UnknownHostException e) {
    e.printStackTrace();
    exit();
  }
  SERVER_DISCOVERY_GROUP = group;
}

void play(AudioPlayer sfx) {
  sfx.pause();
  sfx.rewind();
  sfx.play();
}

void setup() {
  size(800, 800);

  // load sound files
  Minim minim = new Minim(this);
  sfx_fireball = minim.loadFile("fireball.mp3");
  sfx_typing = minim.loadFile("typing.wav");
  sfx_blink = minim.loadFile("blink.mp3");

  // load images
  blink_icon = loadImage("blink_icon.png");
  fireball_icon = loadImage("fireball_icon.png");
  fireball_img = loadImage("fireball.png");
  floor_img = loadImage("floor.png");
  // draw backgraound with lava
  PImage lava_img = loadImage("lava.jpg");
  bg = createGraphics(800, 800, JAVA2D);
  bg.beginDraw();
  for (int i = 0; i<width; i+=40) {
    for (int j = 0; j<height; j+=40) {
      bg.image(lava_img, i, j);
    }
  }
  bg.endDraw();

  // start with main menu
  loadLevel(new Menu());
}

void draw() {
  current_level.draw();
}

void mouseReleased() {
  current_level.mouseReleased();
}

void keyPressed() {
  current_level.keyPressed();
}

void keyReleased() {
  current_level.keyReleased();
}

void mousePressed() {
  current_level.mousePressed();
}

void mouseDragged() {
  current_level.mouseDragged();
}

void disconnectEvent(Client client) {
  current_level.disconnectEvent(client);
}

void stop() {
  current_level.stop();
}

void loadLevel(Level level) {
  current_level = level;
  level.begin();
}
