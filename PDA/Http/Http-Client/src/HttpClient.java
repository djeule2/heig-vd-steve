import java.io.IOException;
import java.io.OutputStream;
import java.net.Socket;
import java.net.URL;
import java.net.UnknownHostException;
 
public class HttpClient 
{
	private Socket socket;
	
	// Fonction permettant la connexion au serveur
	public HttpResponse fetchUrl(String url)
	{
		HttpClientRequest requete_client;
		HttpClientResponse reponse;
		
		try
		{
			
			requete_client = new HttpClientRequest(new URL("http://" + url + "/index.html"));			
			requete_client.setMethod();
			requete_client.setProtocolVersion();
			requete_client.setPath();
			requete_client.setHeadersValue("Host:", "www.bluewin.ch");
			socket = new Socket(url, 80);
			requete_client.send(socket.getOutputStream());
			reponse = new HttpClientResponse(socket.getInputStream());						
		}
		catch(IOException e)
		{
			e.printStackTrace();
		}
		
		return null;

	}


	
public static void main(String[] args)
{
	HttpClient client = new HttpClient();
	String url = "www.bluewin.ch" ;
	client.fetchUrl(url);
}}

