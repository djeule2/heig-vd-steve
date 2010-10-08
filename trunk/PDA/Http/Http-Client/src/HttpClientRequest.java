import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.URL;


public class HttpClientRequest extends HttpResquest
{
	URL u;
	public HttpClientRequest(URL u)
	{
		this.u = u;
	}
	
	public void setMethod()
	{
		method = "GET";
	}
	
	public void setProtocol()
	{
		protocol = u.getProtocol();
	}
	
	public void setServerName()
	{
		serverName = u.getHost();	
	}
	
	public void setPath()
	{
		path = u.getPath();
	}
	
	public void setQuery(String query)
	{
		query = u.getQuery();
	}
	
	public void setProtocolVersion()
	{
		protocolVersion = "HTTP/1.0";
	}
	
	public void setHeadersValue(String headers_type, String value)
	{
		headers.put(headers_type, value);
	}
	
	

	
	private int getPort(URL u)
	{
		int port = u.getPort();
		if (port > 0)
			return port;
		else
			return 80;
	}
	
	private String create_request()
	{
		String request = new String(
									method + " " + path + " " + protocolVersion + "\r\n" +
									"Host: " + headers.get("Host:") + "\r\n\r\n"
									);
		
		
		System.out.println(request);
		return request;		
	}
	
	public void send(OutputStream o)
	{
		byte[] requete_byte;
		BufferedOutputStream flux_buffered = new BufferedOutputStream(o);
		requete_byte = this.create_request().getBytes();
		
		try {
			flux_buffered.write(requete_byte);
			flux_buffered.flush();
		} 
		catch (IOException e) 
		{			
			System.out.println("Erreur lors de l'envoi de la requête");
			e.printStackTrace();
		}
	}
	
}
