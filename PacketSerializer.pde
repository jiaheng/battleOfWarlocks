import java.io.*; 

class PacketSerializer {
  public byte[] serialize(Packet obj) throws IOException {
    ByteArrayOutputStream b = new ByteArrayOutputStream();
    ObjectOutput o = new ObjectOutputStream(b);
    o.writeObject(obj);
    return b.toByteArray();
  }

  public Packet deserialize(byte[] bytes) throws IOException, ClassNotFoundException {
    ByteArrayInputStream b = new ByteArrayInputStream(bytes);
    ObjectInput o = new ObjectInputStream(b);
    Object obj = o.readObject();
    return (Packet)obj;
  }
}
