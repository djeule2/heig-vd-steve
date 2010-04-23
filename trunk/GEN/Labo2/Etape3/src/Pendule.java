/********************************************************************
 * Auteur:	    Eric Lefrançois                                 *
 * Groupe:	    HES_SO/EIG  Informatique & Télécommunication    *
 * Fichier:     Pendule.java                                    *
 * Date :	    1er Octobre 2009 -  DEPART                 		*
 * Projet:	    Horloges synchronisées                          *
 ********************************************************************
*/


import java.awt.*;
import java.lang.Math;
import java.util.Observable;
import java.awt.event.*;
import javax.swing.*;


public class Pendule extends Observable implements Runnable
{
//Classe qui décrit une montre avec un affichage des aiguilles
	
	private int dureeSeconde;       // Durée de la seconde en msec.
    private int minutes = 0;       	// Compteurs de la pendule
    private int secondes = 0;
    private int heures = 0;
    
    // Création 
    private VuePendule vuePendule;
    
    // Thread
    private Thread activite;
    
    //------------------------------------------------------------------------
    public Pendule (String nom, int valSeconde, int posX, int posY){
       
	    dureeSeconde = valSeconde;
	    vuePendule = new VuePendule("horloge", valSeconde, posX, posY, this);
	    
	    // Création et démarrage du thread
	    activite = new Thread(this);
	    activite.start();
   }

    public void incrementerSecondes(){
    	secondes ++;
        if (secondes == 60) {   
        	secondes = 0;
        	incrementerMinutes();
        }
    }

    public void incrementerMinutes() {
      minutes = ++minutes % 60 ;
      if (minutes == 0) {
          heures = ++heures % 24;
      }
    }
    
    public int getMinutes(){
    	return minutes;
    }
    
    public int getHeures(){
    	return heures;
    }
    
    public int getSecondes(){
    	return secondes;
    }
    
    
    
    
	public void run() {
		while(true){
			try{
				Thread.sleep(dureeSeconde);
				incrementerSecondes();	
				setChanged();
				notifyObservers();
			}catch(InterruptedException e){System.out.println(e);}
		}		
	}
}
