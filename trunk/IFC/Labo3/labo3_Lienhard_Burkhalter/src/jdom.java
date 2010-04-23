import java.io.File;
import java.io.IOException;
import java.lang.Object;
import org.jdom.Element;
import org.jdom.JDOMException;
import java.util.*;

public class jdom {
	public static void main(String args[]){
		try{
			File xmlFile = new File("./src/personne.xml");
			org.jdom.input.SAXBuilder saxb = new org.jdom.input.SAXBuilder();
			org.jdom.Document doc = saxb.build(xmlFile.getPath());

			//L'élément racine est initialisé avec la valeur de la racine du document
			Element racine = doc.getRootElement();
			
			//On crée une liste de tous les noeuds de la racine du document
			List listPersonnes = racine.getChildren();

			//On crée un Iterator sur notre liste
			Iterator i = listPersonnes.iterator();
			Element e;
			while(i.hasNext())
			{
				  e = (Element) i.next();
				  
				  //affichage des informations d'une personne
				  System.out.println("Nom : " + e.getChildText("nom"));
			      System.out.println("Prenom : " + e.getChildText("prenom"));
			      System.out.println("Email : " + e.getChildText("email"));
			      System.out.print("Tel fixe : " + e.getChild("telephone").getChild("fixe").getChild("indicatif").getText());
			      System.out.println(e.getChild("telephone").getChild("fixe").getChild("numero").getText());
			      System.out.print("Tel mobile : " + e.getChild("telephone").getChild("mobile").getChild("indicatif").getText());
			      System.out.println(e.getChild("telephone").getChild("mobile").getChild("numero").getText() + "\n");
			      
		      
			}						
		}catch(Exception except){System.out.println(except);}
	}
}
