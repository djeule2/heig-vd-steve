import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;

import javax.net.ssl.SSLEngineResult.Status;


public class HttpClientResponse extends HttpResponse
{
	private String texte = new String();
	
	
	HttpClientResponse(InputStream in) throws IOException
	{
		int emplacementSeparateur;
		HttpInputStream httpInputStream = new HttpInputStream(in);
		
		if((texte = httpInputStream.readHttpLine()) != null)
		{
			setStatusCode(texte.substring(9, 11));
			
			// placement des headers dans la hashmap
			while((texte = httpInputStream.readHttpLine()) != null)
			{
				emplacementSeparateur = texte.indexOf(":");
				headers.put(texte.substring(0, emplacementSeparateur - 1),texte.substring(emplacementSeparateur + 1 , texte.length()-1));
				
			}
		}
		
		System.out.println(texte);
		
	}

	public void setStatusCode (String valeur)
	{
		statusCode = valeur;
	}

	
	
	
}
