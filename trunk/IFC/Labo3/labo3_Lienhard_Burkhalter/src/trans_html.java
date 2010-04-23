import java.io.File;
import java.io.FileWriter;
import java.io.Writer;
import java.util.List;

import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXTransformerFactory;
import javax.xml.transform.sax.TransformerHandler;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.output.SAXOutputter;

public class trans_html{
public static void main(String[] args) {
	try{
		File xmlFile = new File("./src/personne.xml");
		org.jdom.input.SAXBuilder saxb = new org.jdom.input.SAXBuilder();
		org.jdom.Document doc = saxb.build(xmlFile.getPath()); // le document XML en mémoire
		
		
		FileWriter w = new FileWriter(new File("./src/personne.html")); 
		
		/* A décommenter si on veut supprimer la première personne
		Element racine = doc.getRootElement();
		racine.removeChild("personne");
		*/
		TransformerFactory transFact = TransformerFactory.newInstance();
		
		if(transFact.getFeature(SAXTransformerFactory.FEATURE)){
			SAXTransformerFactory stf = (SAXTransformerFactory) transFact;
			TransformerHandler transHand = null;
			
			transHand = stf.newTransformerHandler(new StreamSource(new File("./src/personne.xsl")));
			
			transHand.setResult(new StreamResult(w));
			SAXOutputter saxOut = new SAXOutputter(transHand);
			saxOut.output(doc);
			w.close();
		}
		else{
			System.out.println("error");
		}
	}catch(Exception except){System.out.println(except);}
}}
