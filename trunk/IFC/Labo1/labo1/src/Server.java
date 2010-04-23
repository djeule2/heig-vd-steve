
import java.io.*;
import java.net.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

public class Server extends JFrame{	
	
	// Port d'écoute
	private int port;
	// Socket serveur
	private ServerSocket serSoc;
	// Socket en mode connecté
	private Socket soc;
	// Buffer de lecture de texte
	private BufferedReader in;
	// Buffer d'écriture de texte
	private PrintWriter out;
	// Buffer de lecture d'objet
	private ObjectInputStream inObject;
	// Indique si une connexion a été demandée
	private boolean connexionAsked;
	// Indique si la connexion est ON
	private boolean connexionOn;
	
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
	
	JLabel label_text = new JLabel("Texte");
	JLabel label_port = new JLabel("Port");
	
	JButton con_Button  = new JButton("Connexion");
	JButton dec_Button  = new JButton("Deconnexion");
	JButton send_Button = new JButton("Send");
	
	
	/* --- Construction de la fenêtre --- */
	public Server(String name)throws IOException{
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
		panel1.add(label_port);
		panel1.add(port_zone);
		
		// Panel2
		panel2.setPreferredSize(new Dimension(130, 50));
		
		panel2.setLayout(new FlowLayout());
		panel2.add(con_Button);
		con_Button.setPreferredSize(new Dimension(100,30));
		panel2.add(dec_Button);
		dec_Button.setPreferredSize(new Dimension(100,30));
		port_zone.setColumns(4);		
			
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
	
	public void receiveFile(String s)throws IOException{
		int index = 6;
		String nomFichier = new String();
		// Récupération du nom du fichier
		while(s.charAt(index) != '-'){
		   nomFichier+=s.charAt(index++);
		}
		
		File fichier = new File(nomFichier);
		FileWriter writerStream = new FileWriter(fichier);
		writerStream.write(s.substring(index));
		writerStream.close();
		receivedText_zone.append("\nFichier créé à l'emplacement : " + 
		nomFichier);
	}
	
	protected void finalize() {
		   try {
				// Fermeture des buffers et sockets, 
	  			// réinitialisation de l'IP et du port d'écoute
	    		serSoc.close();
	    		soc.close();
	    		out.close();
	    		in.close();
	    		inObject.close();
	    		port = 0;
	    		connexionAsked = false;
	    		connexionOn = false;
	    		// Gestion des boutons
				con_Button.setEnabled(true);
				dec_Button.setEnabled(false);
				send_Button.setEnabled(false);
				receivedText_zone.append("Serveur déconnecté...");
		   } catch(Exception except){System.out.println(except);}
	}
	
    public static void main(String[] args){
    	try{
	    	final Server server = new Server("Server");

	    	server.setSize(420,279);
	    	server.setVisible(true);
	    	server.setResizable(false);
	    	
	    	
	    	/* Création d'un écouteur sur le bouton de connexion
		     * A l'action de ce bouton, le serveur est UP
		     */
		      server.con_Button.addActionListener(new ActionListener(){
		    	  public void actionPerformed(ActionEvent e){
					     server.connexionAsked = true;
			      }
		      });
		      
		      /* Création d'un écouteur sur le bouton de déconnexion
		       * A l'action de ce bouton, le serveur est DOWN
		       */
		      server.dec_Button.addActionListener(new ActionListener(){
		    	  public void actionPerformed(ActionEvent e){
			    	    server.finalize();	 
		    	  }
		    	  
		      });
		    	  
		      /* Création d'un écouteur sur le bouton d'envoye
		       * A l'action de ce bouton, le client envoie le message
		       * au serveur 
		       */
		      server.send_Button.addActionListener(new ActionListener(){
		    	  public void actionPerformed(ActionEvent e){
		    	  // On récupère le texte tappé et on l'envoie sur la 
		          // socket out du serveur	    	  
		          server.out.println(server.sendText_zone.getText());   
		    	  }
		      });		      

		while(true){
			  // Si il n'y a aucune connexion et que la connexion est demandée
			  if(server.connexionAsked == true && server.connexionOn == false){	  
				      server.port = Integer.valueOf(
				    		  		server.port_zone.getText());
				      // Création du socket d'écoute
					  server.serSoc = new ServerSocket(server.port);
					  // Attente d'une demande de connexion et acceptation 
					  // de celle-ci
					  server.receivedText_zone.setText(
					  						   "Attente de connexion...");
					  server.soc = server.serSoc.accept();
					  
					  // Création du BufferReader (pour les strings)
					  server.in = new BufferedReader(
							      new InputStreamReader(
						          server.soc.getInputStream()));
					  // Création du PrintWriter (pour les strings)
					  server.out = new PrintWriter(
					               server.soc.getOutputStream(), true);	
					  // Création du lecteur d'objets
					  server.inObject = new ObjectInputStream(
							  			server.soc.getInputStream());	
					  
					  // Indication du client au serveur que la 
					  // connexion est ON 
					  server.receivedText_zone.append(server.in.readLine());
					  server.connexionOn = true;
					  
					  // Gestion des boutons
					  server.con_Button.setEnabled(false);
					  server.dec_Button.setEnabled(true);
					  server.send_Button.setEnabled(true);
					  server.connexionAsked = false;
			  }
			  // Si la connexion est en cours
			  else if(server.connexionOn == true) {
				 try{					 
					 Object o = server.inObject.readObject();	  
				     if(o instanceof Integer){
				        server.receivedText_zone.append(
				        						 "\n"+(Integer)(o));   	 
				     }
				     else if(o instanceof Float){
				    	server.receivedText_zone.append(
				    							 "\n"+(Float)(o));  
				     }
				     else if(o instanceof Double){
				    	server.receivedText_zone.append(
				    							 "\n"+(Double)(o));   
				     }
				     else if(o instanceof Byte){
				    	server.receivedText_zone.append(
				    							 "\n"+(Byte)(o));   
				     }
				     else if(o instanceof String){
				    	String s = ((String)o);		
				    	// On test si c'est un fichier ou un String
				    	if(s.length() >= 7 && s.substring(0,6)
				    						   .equals("%file*"))
				    		// On reconstruit le fichier du côté serveur
				    		server.receiveFile(s);
				    	else
				    	{
				    	    // Le texte reçu est affiché dans la 
				    		// fenêtre du serveur
				    	    server.receivedText_zone.append("\n" + s); 
				    	    // pour l'echo :
				    		server.out.println("echo :" + s);
				    	}
				    }		 
    		    }catch(EOFException except){System.out.println(except);}			  
		     }	
		  }
       }catch(Exception except){System.out.println(except);}
    }
}



