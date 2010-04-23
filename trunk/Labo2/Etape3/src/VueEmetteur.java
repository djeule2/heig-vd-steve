import java.awt.Font;
import java.util.Observable;
import java.util.Observer;

import javax.swing.JFrame;
import javax.swing.JLabel;


public class VueEmetteur extends JFrame implements Observer{
	
	private final static int LARGEUR = 100;		// largeur fenêtre de l'emetteur
	private final static int HAUTEUR = 100;		// hauteur fenêtre de l'emetteur
	
	private Emetteur emetteur;
	private JLabel champAffichage = new JLabel("00");
    private Font fonte = new Font ("TimeRoman",  Font.BOLD, 80);	
    
	public VueEmetteur(Emetteur emetteurObs){
        getContentPane().add("North", champAffichage); 
        champAffichage.setSize(LARGEUR, HAUTEUR);
        champAffichage.setFont (fonte);
        setTitle("Emetteur");
        pack();
        setLocation(200, 200);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setVisible(true);
		emetteur = emetteurObs;
		// On s'abonne à l'emetteur
		emetteur.addObserver(this);
	}
	
	public void update(Observable o, Object arg) {
		champAffichage.setText (String.valueOf(emetteur.getSeconde()));				
	}

}
