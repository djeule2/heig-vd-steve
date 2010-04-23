/****************************************************************
 * Auteur:	    Eric Lefrançois                                 *
 * Groupe:	    HES_SO      Informatique & Télécommunications   *
 * Fichier:     Emetteur.java                                   *
 * Date :	    1er Octobre 2009    - Départ             		*
 * Projet:	    Horloges synchronisées                          *
 ****************************************************************
*/


import java.awt.*;
import javax.swing.*;



class Emetteur extends JFrame {

  private final static int LARGEUR = 100;		// largeur fenêtre de l'emetteur
  private final static int HAUTEUR = 100;		// hauteur fenêtre de l'emetteur

  private int dureeSeconde ;                    // Durée sec. en msec.

  private int secondes = 0;						// Compteur de secondes

  private JLabel champAffichage = new JLabel("00");
  private Font fonte = new Font ("TimeRoman",  Font.BOLD, 80);
	

// Constructeur
    public Emetteur (int dureeSeconde) {
        this.dureeSeconde = dureeSeconde;
        getContentPane().add("North", champAffichage); 
        champAffichage.setSize(LARGEUR, HAUTEUR);
        champAffichage.setFont (fonte);
        setTitle("Emetteur");

        pack();
        setLocation(200, 200);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setVisible(true);

    }

    private void heureMettreAJour () {
        secondes = ++secondes % 60;
        champAffichage.setText (String.valueOf(secondes));
    }
 
}
