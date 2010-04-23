/****************************************************************
 * Auteur:	    Eric Lefrançois                                 *
 * Groupe:	    HES_SO      Informatique & Télécommunications   *
 * Fichier:     Emetteur.java                                   *
 * Date :	    1er Octobre 2009    - Départ             		*
 * Projet:	    Horloges synchronisées                          *
 ****************************************************************
*/


import java.awt.*;
import java.util.Observable;

import javax.swing.*;



class Emetteur extends Observable implements Runnable {

  private int dureeSeconde = 0;                    // Durée sec. en msec.
  private int secondes = 0;						// Compteur de secondes
  private Thread activite;
  private VueEmetteur vueEmetteur;

// Constructeur
    public Emetteur (int dureeSeconde) {
        this.dureeSeconde = dureeSeconde;
		vueEmetteur = new VueEmetteur(this);
		// Création et démarrage du thread
		activite = new Thread(this);
		activite.start();

    }

    private void heureMettreAJour () {
        secondes = ++secondes % 60;
    }
    
    public int getSeconde(){
    	return secondes;
    }
	
	public void run() {
	   while(true){
		   try{
			   Thread.sleep(dureeSeconde);
			   heureMettreAJour();
			   setChanged();
			   notifyObservers();
		   }catch(InterruptedException e){System.out.println(e);}
	      
		   
	   }
		
	}
 
}
