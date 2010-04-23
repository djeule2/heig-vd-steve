import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Observable;
import java.util.Observer;
import javax.swing.*;




public class VuePendule extends JFrame implements Observer{
	
    private static int TAILLE = 50; // Taille de la demi-fenétre
    private ToileGraphique toile;
    private Pendule pendule;

    
	class ToileGraphique extends JPanel implements ActionListener {
	    private AlphaPanel alphaPanel;
	    private JPanel boutonPanel;
	    private JButton plusButton;	  
		public ToileGraphique() {    
			 setBackground(Color.white);
			
			 // Etape3
		     alphaPanel = new AlphaPanel();
		     alphaPanel.setSize(this.getWidth(), 5);
		     alphaPanel.setBackground(Color.lightGray);
		     getContentPane().add(alphaPanel, BorderLayout.SOUTH);	     
		     boutonPanel = new JPanel();
		     plusButton = new JButton();
		     boutonPanel.setSize(this.getWidth(),6);
		     boutonPanel.setBackground(Color.lightGray);
		     boutonPanel.add(plusButton);
		     plusButton.setText("+");
			 plusButton.setSize(this.getWidth(), boutonPanel.getHeight());
			 plusButton.addActionListener(this);
			 getContentPane().add(boutonPanel, BorderLayout.NORTH);
		  }

		  public void paintComponent (Graphics g) {
				super.paintComponent(g);
				dessinerAiguilles (g);
				alphaPanel.afficherHeure();
		  }
		
		  public Dimension getPreferredSize() {
				return new Dimension (2*TAILLE, 2*TAILLE);
		  }
		  
		  public void dessinerAiguilles(Graphics g) {
		        // calculer les coordonnées des aiguilles
		        int cosxm = (int)(TAILLE + (TAILLE/2)*
		                          Math.cos(2*((double)pendule.getMinutes()/60*Math.PI - Math.PI/4)));
		        int sinym = (int)(TAILLE + (TAILLE/2)*
		                          Math.sin(2*((double)pendule.getMinutes()/60*Math.PI - Math.PI/4)));
		        int cosxh = (int)(TAILLE+(TAILLE/4)*
		                          Math.cos(2*((double)pendule.getHeures()/12*Math.PI - Math.PI/4)));
		        int sinyh = (int)(TAILLE+(TAILLE/4)*
		                          Math.sin(2*((double)pendule.getHeures()/12*Math.PI - Math.PI/4)));

		        g.setColor(Color.red);
		        g.drawLine(TAILLE,TAILLE,
		                  (int)(TAILLE+(TAILLE-20.0)*
		                        Math.cos(2*((double)pendule.getSecondes()/60*Math.PI - Math.PI/4))),
		                  (int) (TAILLE+(TAILLE-20)*
		                        Math.sin(2*((double)pendule.getSecondes()/60*Math.PI - Math.PI/4))));
		        g.setColor(Color.blue);
		        g.drawLine(TAILLE,TAILLE,cosxm,sinym);
		        g.drawLine(TAILLE,TAILLE,cosxh,sinyh);
		  }
		  
		  public void actionPerformed(ActionEvent e) {
			    pendule.incrementerMinutes();	
		  }
		  
		  
		  class AlphaPanel extends JPanel{
				 
			  private JLabel heures;
			  private JLabel minutes;
			  private JLabel secondes;
			  
			  public AlphaPanel(){
				  heures = new JLabel("00");
				  minutes = new JLabel("00");
				  secondes = new JLabel("00");
				  
				  this.add(heures);
				  this.add(minutes);
				  this.add(secondes);
			  }
			  
			  public void afficherHeure(){
				  heures.setText(String.valueOf(pendule.getHeures()));
				  minutes.setText(String.valueOf(pendule.getMinutes()));
				  secondes.setText(String.valueOf(pendule.getSecondes()));
			  }
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
