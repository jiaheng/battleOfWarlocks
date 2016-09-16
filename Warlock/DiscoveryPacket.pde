public static class DiscoveryPacket extends Packet {

  public static final int SIZE = 512;

  public DiscoveryPacket(){
    super(PacketType.DISCOVERY);
  }

}
