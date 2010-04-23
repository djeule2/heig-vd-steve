/*
Auteur:		Eric Lefrançois
Fichier:	Gui.java
Date :		Octobre 2009
Note:		Annonce tournante, s'exécutant en mode bimodal
                (Applet ou Application autonome)
*/

   import java.awt.*;
   import java.awt.event.*;
   import java.applet.*;
   import javax.swing.*;

   import utilitaires.*;

//-----------------------------------------------------------------------------

     class Gui extends JPanel implements Runnable {
   	// Interface utilisateur:  Graphical User Interface

      	private static final int LARGEUR = 400;		// Largeur fenêtre
      	private static final int HAUTEUR = 80;		// Hauteur fenêtre


      	private Font fonte = new Font ("Arial", Font.BOLD, 36);

      	private String message;

      	private int messagePosX=0;	// Position en X du message

      	private Thread activite;



       	public void paintComponent (Graphics g) {
      		super.paintComponent(g);
      		g.setFont (fonte);
      		g.setColor (Color.GREEN);
      		g.drawString (message, messagePosX, 40);
        	g.drawString (message, messagePosX-LARGEUR, 40);
      	}

       	public void init() {
         	message = JOptionPane.showInputDialog(this, "Entrez votre texte d'annonce");
      	}

       	public void start() {
         	activite = new Thread(this);
         	activite.start();
      	}

       	public void stop() {
         	activite = null;
      	}

       public void run () {
         	while (Thread.currentThread() == activite) {
            	try {Thread.sleep(10);}
            	catch (InterruptedException e) {}
            	messagePosX = (messagePosX+=1) % LARGEUR;
            	repaint();
         	}
      	}

       public static void main (String arg[]) {
         Fenetre f = new Fenetre();
         Gui a = new Gui ();
         f.add(a, BorderLayout.CENTER);

         a.init();
         a.start();

         f.setSize(LARGEUR, HAUTEUR);
         f.setVisible(true);

      }
   }

//------------------------------------------------------------------------

