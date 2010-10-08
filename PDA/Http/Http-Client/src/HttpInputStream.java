import java.io.BufferedInputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.Writer;


public class HttpInputStream extends BufferedInputStream
{
	
	public HttpInputStream(InputStream in) {
		super(in);
	}

	public String readHttpLine()
	{
		String line = new String();
		char character;
		boolean crlf_present = false;
		try 
		{
			while(!crlf_present)
			{
				character = (char) in.read();
				line = line.concat(String.valueOf(character));	
				
				if(character == 13)
				{
					
					if((character = (char) in.read()) == 10)
					{
						crlf_present = true;
					}
					line = line.concat(String.valueOf(character));	
				}
			}
			
			//retrait du 10 et 13 successif indiquant la fin de chaîne
			line = line.substring(0, line.length() - 2);
		
				
		}catch (IOException e) 
		{
			e.printStackTrace();
		}
		
		System.out.println("LINE = " + line);
		
		if (line.equals(""))
			return null;
		else
		{	
			write(line);
			return line;
		}
	}
	
	public void write(String texte)
	{	
		File fichier = new File ("c:\\output.txt");
	
		// création du fichier de log si celui ci n'existe pas encore
		if (!fichier.exists())
		{
		    try
		    {
		        fichier.createNewFile();
		    }
		    catch (IOException exception)
		    {
		        System.out.println ("Erreur " + exception.getMessage());
		    }
		}
		
		// écriture dans le fichier de log
		try
		{
			Writer writer = new FileWriter(fichier,true);
			writer.append(texte+"\r\n");					
			writer.flush();
			writer.close();
	
		}
		catch(IOException ioe){
			System.out.print("Erreur : ");
			ioe.printStackTrace();
		}

	}
	
	
	
	
}
