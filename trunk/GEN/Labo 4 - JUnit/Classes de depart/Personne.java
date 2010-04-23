public class Personne{
	private String 	nom;
	private String 	prenom;
	private String 	email;
	private int		annee;
	
	public Personne(String nom, String prenom, String email, int annee){
		this.nom = nom;
		this.prenom = prenom;
		this.email = email;
		this.annee = annee;
	}
	
	public String getNom(){
		return nom;
	}
	
	public String getPrenom(){
		return prenom;
	}
	
	public String getEmail(){
		return email;
	}
	
	public int getAnnee(){
		return annee;
	}
	
	public void setNom(String nom){
		this.nom = nom;
	}
	
	public void setPrenom(String prenom){
		this.prenom = prenom;
	}
	
	public void setEmail(String email){
		this.email = email;
	}
	
	public void setAnnee(int annee){
		this.annee = annee;
	}
}