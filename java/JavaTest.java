import fr.free.natpmp.*;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.nio.IntBuffer;
import java.nio.ByteBuffer;


public class JavaTest {

    public static void main(String[] args) {

        NatpmpLibrary natpmp = NatpmpLibrary.INSTANCE;
	ByteBuffer addressBytes = ByteBuffer.allocateDirect(4);
	IntBuffer address = addressBytes.asIntBuffer();
	natpmp.getdefaultgateway(address);
	
	byte[] bytes = new byte[4];
	addressBytes.get(bytes);
	try {
	    InetAddress inetAddress = InetAddress.getByAddress(bytes);
	    System.out.println("Default gateway is " + inetAddress);
	} catch (UnknownHostException e) {
	    throw new RuntimeException(e);
	}
    }
}