/*
Fichier:  Noel.java
Rem:     
	Exemple d'utilisation du modèle Observer/Observable
	Exécuter le programme en application autonome
          Ou éxécuter le programme en mode Applet en ouvrant une fenêtre de 315*315

          Le répertoire contenant les classes à exécuter doit contenir les 3 fichiers image:
          "Lune.gif", "Montagne.gif" et "PNoel.gif"


Date :	  Eric Lefrançois, Janvier 2002
*/

import java.util.*;   // Random, Observer, Observable
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.awt.image.ImageObserver;
import java.applet.*;

// -----------------------------------------------------------------------------
interface Parametres {
	// Constantes globales:  taille des composants

	int PG_X = 315;   // Taille en X du panneau graphique
	int PG_Y = 315;   // Taille en Y du panneau graphique

	// Flocons
	int MAX_FLOCONS = 300;   // Nombre max. de flocons
 
}


// -----------------------------------------------------------------------------
class ChuteNeige implements Runnable, Parametres { 
    /**
     * @link aggregationByValue 
     * @supplierCardinality 0..*
     */
	private Flocon[] flocons  = new Flocon [MAX_FLOCONS];
	private int nbFlocons;    // Nombre de flocons créés
	private Thread activite;
	
	private LinkedList<Observer> observers = new LinkedList();
	
	public ChuteNeige () {
		activite = new Thread (this);
		activite.start();
	}

	public void run () {
	// Activité limitée à la création des flocons
		while (nbFlocons < MAX_FLOCONS) {
			try {Thread.sleep(100);}catch (InterruptedException e) {}
			flocons[nbFlocons]=new Flocon(); // Créer un nouveau flocon
			
			for(int i = 0; i < observers.size(); i++)
				flocons[nbFlocons].addObserver(observers.get(i));
			
			nbFlocons++;
		}
	}

	public void dessiner(Graphics g){
		for (int i = 0; i < nbFlocons; i++) {
			flocons[i].dessiner(g);
		}
	}
	
	public void observerFlocon(Observer o){
	   observers.add(o);
	}	
}


// -----------------------------------------------------------------------------

class Flocon extends Observable implements Runnable, Parametres {
	
	private int x, y; 			// Coordonnées courantes du flocon
	private int largeur; 		// largeur du flocon (en pixels)
	private int hauteur; 		// hauteur du flocon (en pixels)
	private int vitesse; 		// DeltaT entre deux déplacements en Y

	private Thread activite;
	  
	// Un générateur de nombres aléatoires  
	public static Random rdGen = new Random();
  
	public Flocon () {
		x = rdGen.nextInt(PG_X);
		y = 0;
		largeur = 1+rdGen.nextInt(3);    // Génération nb aléat. entre 1 et 4
		hauteur = largeur + rdGen.nextInt(2);
		vitesse = hauteur;                   // Vitesse directement fonction de la taillE
			  
		activite = new Thread(this);
		activite.start();
	}

	public synchronized void deplacer () {
	// Synchronisation nécessaire:  les coordonnées du flocon sont une
	// ressource critique (dessin et mise à jour simultanés)	
		boolean aDroite = rdGen.nextInt(2)==1;
		x = aDroite ? x+1 : x-1;
		y += vitesse ;
		setChanged();
		notifyObservers();
		if (y+hauteur> PG_Y) {
			x = rdGen.nextInt(PG_X);
			y = 0;
		}		
	}
	
	public void reset(){
		x = rdGen.nextInt(PG_X);
		y = 0;
	}

	public void run () {
		while (true) {
			try {Thread.sleep(50*(7-vitesse));}catch(InterruptedException e) {}
			deplacer();
		}
	}

	public synchronized void dessiner (Graphics g) {
	// Synchronisation nécessaire:  les coordonnées du flocon sont une
	// ressource critique  (dessin et mise à jour simultanés)	
		g.setColor(Color.white);
		g.fillRect(x, y, largeur, hauteur);
		g.setColor(Color.lightGray);
		g.drawRect(x, y, largeur, hauteur);
	}
	
	public int getX(){
		return  x;
	}
	
	public int getY(){
		return y;
	}
	
	public int getHauteur(){
		return hauteur;
	}
	
	public int getLargeur(){
		return largeur;
	}
}
// -----------------------------------------------------------------------------
class PereNoel extends Observable implements Runnable, Parametres  {	
	private int x;
	private Thread activite;
	private int y;
    // Coordonnées courantes du flocon
	private  Image imagePereNoel;	

    /**
     * @link aggregationByValue
     * @supplierCardinality 0..1 
     */
    private Noel lnkNoel;
	  
	public PereNoel () {
		imagePereNoel = Toolkit.getDefaultToolkit().getImage ("PNoel.gif");
		activite = new Thread (this);
		activite.start();
	}

	public void run () {
		x = 0;
		y = PG_Y/4;
		while (true) {
			try {Thread.sleep(50);}catch (InterruptedException e) {}
			x += 2;
			if (x > PG_X+100) x = -200;
			//setChanged();
			//notifyObservers();
		}
	}

	public void dessiner(Graphics g, ImageObserver imObs) {
		g.drawImage (imagePereNoel, x, y, imObs);
	}

}
//------------------------------------------------------------------------------
class PanneauGraphique extends JPanel implements Parametres, Observer {
// Vue passive, pour affichage uniquement


	private ChuteNeige a_chuteNeige;
	private CoucheNeige a_coucheNeige;

         // Chute de neige
    /**
     * @label Xxx 
     */
	private PereNoel a_lePereNoel;           	// Père Noël
	
	private  Image imageDeFond, imageLune;		 // Images de fond

// Constructeur
	public PanneauGraphique (ChuteNeige chNg, PereNoel lePereNoel, CoucheNeige coucheNeige){
		a_chuteNeige = chNg;
		a_lePereNoel = lePereNoel;
		a_coucheNeige = coucheNeige;
		
		setBackground(new Color (0, 0, 65));
		// Chargement de l'image Montagne.gif, située dans le répertoire
		// des classes.  Image de taille 315*44 pixels
		imageDeFond = Toolkit.getDefaultToolkit().getImage ("Montagne.gif");

		// Chargement des images Lune etPère Noel
	    imageLune = Toolkit.getDefaultToolkit().getImage ("Lune.gif");

	}
	
	public void update(Observable o, Object arg){
	   repaint();	
	}

	public void paintComponent (Graphics g) {
		super.paintComponent(g);
		g.drawImage (imageDeFond, 0, PG_Y-44, this);
		g.drawImage (imageLune, PG_X-100, PG_Y/4, this);
		a_chuteNeige.dessiner(g);  		
		a_lePereNoel.dessiner(g, this); 
		a_coucheNeige.dessiner(g);
		

		/*Note .......
		Le "this", 4ème paramètre de drawImage représente "l'image observer"".
		Cet objet contrôle le chargement de l'image en mémoire (chargée
		habituellement depuis un fichier).  Il est responsable de dessiner
		cette image de manière asynchrone au reste du programme, au fur et à
		mesure que l'image se charge.
		Ainsi, le programmeur peut donner l'ordre de charger une image ("getImage"),
		puis il peut la dessiner aussitôt (drawImage), sans attendre qu'elle
		soit chargée.  La procédure drawImage retourne aussitôt.
		L'image observer est implémenté par la classe Component (dont hérite
		la classe Canvas).
		Le cas échéant, il est possible de redéfinir cet objet, ce qui permettrait
		de contrôler le chargement de l'image, d'attendre qu'elle soit entièrement
		chargée avant de l'afficher, etc...
		*/
     }

   public Dimension getPreferredSize() {
   // Retourne la taille souhaitée pour le composant (remplace le "getSize")
        return new Dimension (PG_X, PG_Y);
   }
}
//------------------------------------------------------------------------------
public class Noel extends JApplet {
// Programme "Principal" -->  mise en place du programme
// Création des "modèles", des "vues"
// Associations diverses


   /**
    * @link aggregationByValue 
    */
   private PanneauGraphique panneauGraphique;     			// Vue

   /**
    * @link aggregationByValue 
    */
   private ChuteNeige chuteDeNeige = new ChuteNeige();

     	// Modèle ("observé")
   /**
    * @link aggregationByValue 
    */
   private PereNoel lePereNoel = new PereNoel();
   
   private CoucheNeige coucheDeNeige = new CoucheNeige();
	   
   public Noel () {}

   public void init () {
        getContentPane().setLayout (new BorderLayout ());

        // Création des vues, eventuellement associées aux modèles
        panneauGraphique = new PanneauGraphique (chuteDeNeige, lePereNoel, coucheDeNeige);
        // Positionnement des composants
        getContentPane().add (panneauGraphique, "Center");    // Ajout du panneau graphique à gauche
        
        lePereNoel.addObserver(panneauGraphique);
        chuteDeNeige.observerFlocon(panneauGraphique);
        chuteDeNeige.observerFlocon(coucheDeNeige);
        coucheDeNeige.addObserver(panneauGraphique);
   }
   public void start() {}

   public static void main (String[] arg) {
   // Point d'entrée du programme
	JFrame f = new JFrame ();
	f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	f.setTitle("Chablon");
	Noel a = new Noel();
	f.getContentPane().add (a, "Center");
	a.init();
	f.pack();
	f.setResizable(false);
	f.setVisible(true);
	a.start();
  }
}
//------------------------------------------------------------------------------
class CoucheNeige extends Observable implements Observer, Parametres{
	
	// Tableau comportant les coordonnées en y de chaque flocons
	private int tab[] = new int[PG_X+1+4];
	
	public void update (Observable o, Object arg){
	   if(o.getClass() == Flocon.class){
		   int hFloc = ((Flocon)o).getHauteur();
		   int lFloc = ((Flocon)o).getLargeur();
		   int X_Floc = ((Flocon)o).getX();
		   int Y_FLoc = ((Flocon)o).getY();
		   
		   // Si le flocon se trouve dans la fenêtre
		   if(X_Floc >= 0 && X_Floc <= PG_X){
			   // Si le flocon touche la couche 
			   for(int i = 0; i <= lFloc; i++)
			      if(Y_FLoc + hFloc >= PG_Y - tab[X_Floc+i]){
			         tab[X_Floc+i] += hFloc;
			         ((Flocon)o).reset();
			         setChanged();
					 notifyObservers();
					 break;
			   }			   
		   }
	   }
	}
	
	public synchronized void dessiner(Graphics g){
		g.setColor(Color.white);	
		for(int i = 0; i < tab.length; i++){	
		   g.fillRect(i,PG_Y,1, -tab[i]);
		   g.drawRect(i,PG_Y,1, -tab[i]);
		}
	}
}
