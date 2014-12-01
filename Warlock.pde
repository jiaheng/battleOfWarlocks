import processing.net.*;
import ddf.minim.*;

static final int TOTAL_ROUND = 3;
static Level current_level;
static final int PORT_NUM = 52042;
static final String HOST = "host";

byte interesting = (byte) 127;
final PApplet parent = this;
PGraphics bg;
PImage floor_img, fireball_icon, fireball_img, blink_icon;
String player_name = "player name";
AudioPlayer sfx_fireball, sfx_typing, sfx_blink;

void play(AudioPlayer sfx) {
  sfx.pause();
  sfx.rewind();
  sfx.play();
}

void setup() {
  size(800, 800);

  Minim minim = new Minim(this);
  sfx_fireball = minim.loadFile("fireball.mp3");
  sfx_typing = minim.loadFile("typing.wav");
  sfx_blink = minim.loadFile("blink.mp3");

  blink_icon = loadImage("blink_icon.png");
  fireball_icon = loadImage("fireball_icon.png");
  fireball_img = loadImage("fireball.png");
  floor_img = loadImage("floor.png");
  PImage lava_img = loadImage("lava.jpg");
  bg = createGraphics(800, 800, JAVA2D);
  bg.beginDraw();
  for (int i = 0; i<width; i+=40) {
    for (int j = 0; j<height; j+=40) {
      bg.image(lava_img, i, j);
    }
  }
  bg.endDraw();

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

