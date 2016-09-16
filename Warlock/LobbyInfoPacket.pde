import java.net.SocketAddress;

public static class LobbyInfoPacket extends Packet {

  public static final int SIZE = 720;

  private final String server_name;
  private final int total_player;
  private final int max_player;

  private SocketAddress socket_address;
  private String ipAddress;
  private int portNumber;

  public LobbyInfoPacket(String server_name, int total_player, int max_player) {
    super(PacketType.LOBBY_INFO);
    this.server_name = server_name;
    this.total_player = total_player;
    this.max_player = max_player;
  }

  public String getServerName() {
    return server_name;
  }

  public int getTotalPlayer() {
    return total_player;
  }

  public int getMaxPlayer() {
    return max_player;
  }

  public void setSocketAddress(SocketAddress socketAddress) {
    this.socket_address = socketAddress;
  }

  public SocketAddress getSocketAddress() {
    return socket_address;
  }

  public void setIpAddress(String ipAddress) {
    this.ipAddress = ipAddress;
  }

  public String getIpAddress() {
    return ipAddress;
  }

  public void setPortNumber(int portNumber) {
    this.portNumber = portNumber;
  }

  public int getPortNumber() {
    return portNumber;
  }
}
