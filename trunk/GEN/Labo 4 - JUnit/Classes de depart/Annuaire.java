import java.util.HashMap;

public class Annuaire{
	private HashMap <String,Personne> annu;
	
	public Annuaire(){
		init();
	}
	
	private void init(){
		annu = new HashMap<String,Personne>();
		annu.put("richard.albert@free.fr",new Personne("Richard","Albert","richard.albert@free.fr",1976));
		annu.put("sb@hispeed.ch",new Personne("Besson","Stephan","sb@hispeed.ch",1956));
		annu.put("j.muller@gmail.com",new Personne("Müller","Jean","j.muller@gmail.com",1984));
	}
	
	public Personne getPersonne(String email){
		return annu.get(email);
	}
	
	public boolean addPersonne(String nom, String prenom, String email, int annee){
		if(!annu.containsKey(email)){
			annu.put(email,new Personne(nom,prenom,email,annee));
			return true;
		}
		return false;
	}
	
	public boolean delPersonne(String email){
		if(annu.containsKey(email)){
			annu.remove(email);
			return true;
		}
		return false;	
	}
	
	public boolean changeNomPersonne(String email, String nom){
		Personne p = getPersonne(email);
		if(p != null){
			p.setNom(nom);
			return true;
		}
		return false;
	}
	
	public boolean changePrenomPersonne(String email, String prenom){
		Personne p = getPersonne(email);
		if(p != null){
			p.setPrenom(prenom);
			return true;
		}
		return false;
	}
	
	public boolean changeAnneePersonne(String email, int annee){
		Personne p = getPersonne(email);
		if(p != null){
			p.setAnnee(annee);
			return true;
		}
		return false;
	}
	
	public int getAnneePersonne(String email){
		Personne p = getPersonne(email);
		if(p != null)
			return p.getAnnee();
		return -1;
	}
	
	public String getNomPersonne(String email){
		Personne p = getPersonne(email);
		if(p != null)
			return p.getNom();
		return "";
	}
	
	public String getPrenomPersonne(String email){
		Personne p = getPersonne(email);
		if(p != null)
			return p.getPrenom();
		return "";
	}
	
	public boolean Exist(String email){
		return getPersonne(email)!=null;
	}
	
	public int getNombrePersonnes(){
		return annu.size();
	}
	
	public static void main(String [] args){
		
		Annuaire a = new Annuaire();
		System.out.println("*** Prenom de richard.albert@free.fr ***");
		System.out.println(a.getPrenomPersonne("richard.albert@free.fr")+"\n");
		
		System.out.println("*** Nom de sb@hispeed.ch ***");
		System.out.println(a.getNomPersonne("sb@hispeed.ch")+"\n");
		
		System.out.println("*** Annee de j.muller@gmail.com ***");
		System.out.println(a.getAnneePersonne("j.muller@gmail.com")+"\n");
		
		System.out.println("*** Nombre de personnes ***");
		System.out.println(a.getNombrePersonnes()+"\n");
		
		System.out.println("*** Ajout de Jean Smith ***\n");
		a.addPersonne("Smith", "Jean", "js@bluewin.ch", 1988);
		
		System.out.println("*** Nombre de personnes ***");
		System.out.println(a.getNombrePersonnes()+"\n");
		
		System.out.println("*** Suppression de richard.albert@free.fr ***\n");
		a.delPersonne("richard.albert@free.fr");
		
		System.out.println("*** Existe richard.albert@free.fr ? ***");
		System.out.println(a.Exist("richard.albert@free.fr")+"\n");
		
		System.out.println("*** Existe js@bluewin.ch ? ***");
		System.out.println(a.Exist("js@bluewin.ch")+"\n");
		
		System.out.println("*** Ajout utilisateur existant ***");
		System.out.println((a.addPersonne("Smith", "Jean", "js@bluewin.ch", 1988))+"\n");
		
		System.out.println("*** Recupération d'une personne inexistante ***");
		Personne p1 = a.getPersonne("jojo@hispeed.ch");
		System.out.println(p1+"\n");
		
		System.out.println("*** Recupération d'une personne existante ***");
		Personne p2 = a.getPersonne("js@bluewin.ch");
		System.out.println(p2+"\n");
	}
}