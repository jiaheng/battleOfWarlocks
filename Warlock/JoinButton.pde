import java.net.SocketAddress;

public class JoinButton extends Button {

  private final UUID serverUUID;
  private final SocketAddress socketAddress;
  private final String ipAddress;
  private final int portNumber;


  JoinButton(int button_x, int button_y, int button_len, int button_width, String label, UUID serverUUID, SocketAddress socketAddress, String ipAddress, int portNumber) {
    super(ButtonAction.JOIN, button_x, button_y, button_len, button_width, label);
    this.serverUUID = serverUUID;
    this.socketAddress = socketAddress;
    this.ipAddress = ipAddress;
    this.portNumber = portNumber;
  }

  JoinButton(int button_x, int button_y, int button_len, int button_width, LobbyInfoPacket lobbyInfo) {
    super(ButtonAction.JOIN, button_x, button_y, button_len, button_width, lobbyInfo.getServerName());
    this.socketAddress = lobbyInfo.getSocketAddress();
    this.ipAddress = lobbyInfo.getIpAddress();
    this.portNumber = lobbyInfo.getPortNumber();
    this.serverUUID = lobbyInfo.getSenderUUID();
  }

  public SocketAddress getSocketAddress() {
    return socketAddress;
  }

  public String getIpAddress() {
    return ipAddress;
  }

  public int getPortNumber() {
    return portNumber;
  }

  @Override
  public int hashCode() {
    return serverUUID.hashCode();
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) return true;
    if (obj == null) return false;
    if (this.getClass() != obj.getClass()) return false;
    JoinButton joinButton = (JoinButton) obj;
    if (this.serverUUID.equals(joinButton.serverUUID)) return true;
    return false;
  }
}
