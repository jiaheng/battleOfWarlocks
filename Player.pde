class Player {
  private String name;
  private color player_color;
  private String ip;

  Player(String name, color player_color, String ip) {
    this.name = name;
    this.player_color = player_color;
    this.ip = ip;
  }

  Player(PlayerData player) {
    this.name = player.name;
    this.player_color = player.unit_color;
  }

  public String getName() {
    return name;
  }

  public int getColor() {
    return player_color;
  }

  public String getIp() {
    return ip;
  }
}

