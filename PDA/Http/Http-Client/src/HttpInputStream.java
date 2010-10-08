import java.io.BufferedInputStream;
import java.io.BufferedWriter;
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
			ecrire(line);
			return line;
		}
	}
	
	public void ecrire(String texte)
	{
			
		try
		{
			
//			FileWriter writer = new FileWriter("c:\\output.txt");
//			
//			BufferedWriter output = new BufferedWriter(writer);
//
//			output.append(texte);
//			
//			output.flush();
//			output.close();
			
			Writer writer = new FileWriter("c:\\out.txt");
			writer.append(texte);
			writer.flush();
			writer.close();
		}
		catch(IOException ioe){
			System.out.print("Erreur : ");
			ioe.printStackTrace();
			}

	}
	
	
	
	
}
