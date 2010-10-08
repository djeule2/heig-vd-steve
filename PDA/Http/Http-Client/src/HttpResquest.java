import java.util.HashMap;
import java.util.Map;


public class HttpResquest 
{
	protected  	String method;
	protected  	String protocol;
	protected  	String serverName;
	protected  	String path;
	protected  	String protocolVersion;
	protected  	String query;
	protected 	int port;
	protected 	HashMap headers = new HashMap();	
}
