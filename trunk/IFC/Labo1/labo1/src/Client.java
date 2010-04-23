import java.io.*;
import java.net.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.Color;

import javax.swing.*;

public class Client extends JFrame{

	/* --- ATTRIBUTS CLIENT --- */
	
	// Port distant
	private int port;
	// Adresse IP du serveur
	private String serverIp;
	// Socket (flux)
	private Socket socket;
	// Buffer de lecture
	private BufferedReader in;
	// Buffer d'écriture
    private PrintWriter out; 
	// Buffer d'écriture d'objet
	private ObjectOutputStream outObject;
	// Indique si la connexion est On
	private boolean connexionOn = false;
	
	/* --- ATTRIBUTS FENETRE --- */
	final int WIDTH_SENDZONE = 30;
	final int WIDTH_RECEIVEDZONE = 10;
	final int HEIGHT_RECEIVEDZONE = 25;
	
	JPanel panel0 = new JPanel();
	JPanel panel1 = new JPanel();
	JPanel panel2 = new JPanel();
	JPanel panel3 = new JPanel();
	JPanel panel4 = new JPanel();
	
	JTextField sendText_zone = new JTextField();
	JTextArea receivedText_zone = new JTextArea(WIDTH_RECEIVEDZONE,
											    HEIGHT_RECEIVEDZONE);
	JTextField port_zone = new JTextField();
	JTextField ip_zone   = new JTextField();
	
	JLabel label_text = new JLabel("Texte");
	JLabel label_port = new JLabel("Port");
	JLabel label_ip   = new JLabel("IP");
	
	JButton con_Button  = new JButton("Connexion");
	JButton dec_Button  = new JButton("Deconnexion");
	JButton send_Button = new JButton("Send");
	
	String[] typeTab = {"Texte","Integer","Double","Float",
						"Byte","Fichier"};
	JComboBox typeBox = new JComboBox(typeTab);
	
	public Client(String name)throws IOException{
		/* --- Construction de la fenêtre --- */
		setTitle(name); 
		setSize(400,200); 
		setLocationRelativeTo(null); 
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE); 	
		
		getContentPane().setLayout(new BorderLayout());
		getContentPane().add(panel0);
		
		// Panel0
		panel0.setBackground(Color.LIGHT_GRAY);
		panel0.setLayout(new BorderLayout());
		panel0.add(panel1,BorderLayout.NORTH);
		panel0.add(panel2,BorderLayout.WEST);
		panel0.add(panel3,BorderLayout.EAST);
		panel0.add(panel4,BorderLayout.SOUTH);
		
		// Panel1
		panel1.setLayout(new FlowLayout());
		panel1.add(label_ip);
		panel1.add(ip_zone);
		panel1.add(label_port);
		panel1.add(port_zone);
		
		// Panel2
		panel2.setPreferredSize(new Dimension(130, 50));		
		panel2.setLayout(new FlowLayout());
		panel2.add(con_Button);
		con_Button.setPreferredSize(new Dimension(100,30));
		panel2.add(dec_Button);
		dec_Button.setPreferredSize(new Dimension(100,30));
		panel2.add(typeBox);
		typeBox.setPreferredSize(new Dimension(100,30));
		port_zone.setColumns(4);
		ip_zone.setColumns(9);
			
		// Panel3
		panel3.add(receivedText_zone);
		panel3.add(new JScrollPane(receivedText_zone));
		
		// Panel4
		panel4.setLayout(new FlowLayout());
		panel4.add(send_Button);
		panel4.add(sendText_zone);
		sendText_zone.setColumns(WIDTH_SENDZONE);
		
		dec_Button.setEnabled(false);
		send_Button.setEnabled(false);
		
	 }

		public String readFile(String nomFichier)throws IOException{
			File fichier = new File(nomFichier);
			BufferedReader readStream = new BufferedReader(
										new FileReader(fichier));
			String s;
			String r = "%file*"+ nomFichier + "-";
			while((s=readStream.readLine()) != null){r+= s + '\n';}
			return r;
		}	
		
		protected void finalize(){
	       try{
			 socket.close();
	    	 out.close();
	    	 in.close();
	    	 outObject.close();
	    	 port = 0;
	    	 serverIp = null;
	    	 connexionOn = false;
	     	 dec_Button.setEnabled(false);
	      	 con_Button.setEnabled(true);
	      	 send_Button.setEnabled(false);	
	      	 receivedText_zone.append("\nclient deconnecté..."); 
	      	 
	       }catch(IOException except){System.out.println(except);}
		}
		
	
   public static void main(String args[]){
	  
	   try{	      
		  final Client client = new Client("Client");
		  client.setSize(420,270);
		  client.setVisible(true);
		  client.setResizable(false);
		    
	      /* Création d'un écouteur sur le bouton de connexion
	       * A l'action de ce bouton, le client essaye de se connecter
	       * au serveur 
	       */
	      client.con_Button.addActionListener(new ActionListener(){
	    	  public void actionPerformed(ActionEvent e){
    		     try{	
	    		  client.serverIp = client.ip_zone.getText();	  
	    		  client.port = Integer.valueOf(client.port_zone.getText());
		    	  // Création du socket
		    	  client.socket = new Socket(client.serverIp,client.port);
		    	  	  
		    	  // Création du printer sur la socket 
		  		  client.out = new PrintWriter(
		                    client.socket.getOutputStream(), true);
		  		
		      	  // Création du buffer qui permet de lire par ligne 
		  		  // sur la socket
		      	  client.in = new BufferedReader(
		  		         new InputStreamReader(client.socket.
		  		        		               getInputStream()));
				    
				      	  // Création du buffer qui permet d'écrire des 
				   		  // objets sur le socket
		      	  client.outObject = new ObjectOutputStream(
		      			  			 client.socket.getOutputStream());
		      	  	
		      	  // Indication au client que la connexion est ON
		      	  client.out.println("Connexion acceptee");
		    	  client.receivedText_zone.setText("Connexion à : " +
		    	  client.serverIp + " sur le port " + client.port + " réussie");	
		      	  client.connexionOn = true;
		      	  
		      	  // Gestion des boutons
		      	  client.dec_Button.setEnabled(true);
		      	  client.con_Button.setEnabled(false);
		      	  client.send_Button.setEnabled(true);
				      	  
		      }catch(IOException except){System.out.println(except);}    
	    	  }});
	      
	      /* Création d'un écouteur sur le bouton de déconnexion
	       * A l'action de ce bouton, le client est complétement
	       * réinitialisé
	       */
	      client.dec_Button.addActionListener(new ActionListener(){
	    	  public void actionPerformed(ActionEvent e){
		    	    client.finalize();
    	      }
	      });
	    	  
	      /* Création d'un écouteur sur le bouton d'envoye
	       * A l'action de ce bouton, le client envoie le message
	       * au serveur 
	       */
	      client.send_Button.addActionListener(new ActionListener(){
	    	  public void actionPerformed(ActionEvent e){
	    		  try{	 
	    			  switch(client.typeBox.getSelectedIndex()){
				    	  case 0 : client.outObject.writeObject(
				    			  		  client.sendText_zone.getText()); 
				    	  		   break;
				    	  case 1 : client.outObject.writeObject(
				    	  				  Integer.valueOf(
				    	  				  client.sendText_zone.getText()));         				    	  		   
				    	  		   break;
				    	  case 2 : client.outObject.writeObject(
				    			  		  Double.valueOf(
				    			  		  client.sendText_zone.getText()));	   
				    	  		   break;
				    	  case 3 : client.outObject.writeObject(
				    			  		  Float.valueOf(
				    			  		  client.sendText_zone.getText()));
				    	  		   break;
				    	  case 4 : client.outObject.writeObject(
				    			  		  Byte.valueOf(
				    			  		  client.sendText_zone.getText()));
				    	  		   break;
				    	  case 5 : client.outObject.writeObject(
				    			  		  client.readFile(
				    			  		  client.sendText_zone.getText()));  
				    	  		   break;
		    	      }	  
	    		  }catch(IOException except){System.out.println(except);}
	    	  }
	      });
	      
	      while(true){	  
	    	  // Tant que la connexion est ON, on écoute ce que 
	    	  // le server pourrait renvoyer
	    	  if(client.connexionOn == true){
	    		 String texteRecu = client.in.readLine(); 
	    		 if(texteRecu != null)
	    	        client.receivedText_zone.append("\n" + texteRecu); 
	    		 else {
	    			// Dans le cas où la connexion est coupée par le serveur 
	    		    client.finalize();}
	    	  }
	      }		
	   }catch(IOException e){System.out.println(e);}      
   }
}


