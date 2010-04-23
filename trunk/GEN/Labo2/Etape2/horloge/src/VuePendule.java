import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.util.Observable;
import java.util.Observer;
import javax.swing.*;




public class VuePendule extends JFrame implements Observer{
	
    private static int TAILLE = 50; // Taille de la demi-fenétre
    private ToileGraphique toile;
    private Pendule pendule;
    
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
		                          Math.cos(2*((double)pendule.getMinute()/60*Math.PI - Math.PI/4)));
		        int sinym = (int)(TAILLE + (TAILLE/2)*
		                          Math.sin(2*((double)pendule.getMinute()/60*Math.PI - Math.PI/4)));
		        int cosxh = (int)(TAILLE+(TAILLE/4)*
		                          Math.cos(2*((double)pendule.getHeure()/12*Math.PI - Math.PI/4)));
		        int sinyh = (int)(TAILLE+(TAILLE/4)*
		                          Math.sin(2*((double)pendule.getHeure()/12*Math.PI - Math.PI/4)));

		        g.setColor(Color.red);
		        g.drawLine(TAILLE,TAILLE,
		                  (int)(TAILLE+(TAILLE-20.0)*
		                        Math.cos(2*((double)pendule.getSeconde()/60*Math.PI - Math.PI/4))),
		                  (int) (TAILLE+(TAILLE-20)*
		                        Math.sin(2*((double)pendule.getSeconde()/60*Math.PI - Math.PI/4))));
		        g.setColor(Color.blue);
		        g.drawLine(TAILLE,TAILLE,cosxm,sinym);
		        g.drawLine(TAILLE,TAILLE,cosxh,sinyh);
		    }
  }
	 
	
	 public VuePendule(String nom, int valSeconde, int posX, int posY, Pendule penduleObs){
		 toile = new ToileGraphique();					
	     setTitle(nom);
	     getContentPane().add (toile, BorderLayout.CENTER);
	     pack();
	     setResizable(false);
	     setLocation (posX, posY);
	     setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	     setVisible(true);
	     pendule = penduleObs;
	     // On s'abonne à pendule
	     pendule.addObserver(this);
	 }

	public void update(Observable arg0, Object arg1) {
			toile.repaint();				
	}
}
