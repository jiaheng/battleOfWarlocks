abstract class Level {
  public ArrayList<GameObject> gameObjs = new ArrayList<GameObject>();
  public ArrayList<GameObject> addToWorld = new ArrayList<GameObject>();
  public ArrayList<GameObject> removeFromWorld = new ArrayList<GameObject>();
  
  public abstract void draw();
  public abstract void begin();
  public abstract void stop();
  public abstract void mousePressed();
  public abstract void mouseDragged();
  public abstract void mouseReleased();
  public abstract void keyPressed();
  public abstract void keyReleased();
  
  void disconnectEvent(Client client) {}
}
