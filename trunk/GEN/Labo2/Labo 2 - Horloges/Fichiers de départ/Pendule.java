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
import java.awt.event.*;
import javax.swing.*;




public class Pendule extends JFrame
{
//Classe qui décrit une montre avec un affichage des aiguilles
	
	private int dureeSeconde;       // Durée de la seconde en msec.
    private int minutes = 0;       	// Compteurs de la pendule
    private int secondes = 0;
    private int heures = 0;
    private static int TAILLE = 50; // Taille de la demi-fenétre
    private ToileGraphique toile;


    //------------------------------------------------------------------------
    class ToileGraphique extends JPanel {
		  
		  public ToileGraphique() {
				setBackground(Color.white);
		  }

		  public void paintComponent (Graphics g) {
				super.paintComponent(g);
				dessinerAiguilles (g);
		  }
		
		  public Dimension getPreferredSize() {
				return new Dimension (2*TAILLE, 2*TAILLE);
		  }
		  
		  public void dessinerAiguilles(Graphics g) {
		        // calculer les coordonnées des aiguilles
		        int cosxm = (int)(TAILLE + (TAILLE/2)*
		                          Math.cos(2*((double)minutes/60*Math.PI - Math.PI/4)));
		        int sinym = (int)(TAILLE + (TAILLE/2)*
		                          Math.sin(2*((double)minutes/60*Math.PI - Math.PI/4)));
		        int cosxh = (int)(TAILLE+(TAILLE/4)*
		                          Math.cos(2*((double)heures/12*Math.PI - Math.PI/4)));
		        int sinyh = (int)(TAILLE+(TAILLE/4)*
		                          Math.sin(2*((double)heures/12*Math.PI - Math.PI/4)));

		        g.setColor(Color.red);
		        g.drawLine(TAILLE,TAILLE,
		                  (int)(TAILLE+(TAILLE-20.0)*
		                        Math.cos(2*((double)secondes/60*Math.PI - Math.PI/4))),
		                  (int) (TAILLE+(TAILLE-20)*
		                        Math.sin(2*((double)secondes/60*Math.PI - Math.PI/4))));

		        g.setColor(Color.blue);
		        g.drawLine(TAILLE,TAILLE,cosxm,sinym);
		        g.drawLine(TAILLE,TAILLE,cosxh,sinyh);
		    }
    }

    //------------------------------------------------------------------------
    public Pendule (String nom, int valSeconde, int posX, int posY) {

        toile = new ToileGraphique();					
        setTitle(nom);
        getContentPane().add (toile, BorderLayout.CENTER);
        
        pack();
        setResizable(false);
        setLocation (posX, posY);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setVisible(true);

	    dureeSeconde = valSeconde;
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

}
