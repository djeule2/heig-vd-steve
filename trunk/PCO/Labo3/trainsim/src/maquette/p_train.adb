------------------------------------------------------------------------------
--
-- Nom du fichier     : P_Train.ads
-- Auteur             : E.D'Hooghe
-- Date               : Juin 2000
-- 
-- Code original
--  Auteur            : P.Girardet sur la base du travail de 
--                      M Pascal Binggeli & M Vincent Crausaz
--  Date de creation  : 22.8.97
--
-- Date de modifs.    : Juin 1998
-- Raison de la 
-- Modification       : 1) Ajout d'une interface graphique
--                      2) Modification de l'exclusion mutuelle sur les
--                         informations constituant la maquette 
--
-- Date de modifs.    : Juin 2000
-- Raison de la 
-- Modification       : Portage sur le compilateur GNAT et modifications
--                      necessaires a l'utilisation de la librairie GLUT
--                      OpenGL
--
-- Version            : 4.0
-- Projet				      : Simulateur de maquette
-- Module				      : Train
--                        
-- But					      : Fournir l'objet train ainsi que les primitives
--                      necessaire a sa manipulation
--
-- Modules appeles    : P_Section, P_Contact, P_Couleur, Text_Io, P_Afficher,
--                      Win32.Gl, Win32.Glu, Glut, P_Messages,
--                      Ada.Numerics.Elementary_Functions
--
-- Fonctions exportees: New_Train,
--                      Poser,
--                      Enlever,
--                      Mettrevitesse,
--                      Changerdirection,
--                      Avancer,
--                      Put,
--                      Paint
--
-- Materiel 
-- particulier        : Les dll "Glut32.dll", "OpenGl32.dll" et "Glu32.dll"
--                      doivent etre dans le repertoire systeme de Windows
--
------------------------------------------------------------------------------
                                            
-- Pour les affichage sur le moniteur
with P_Afficher;

-- Pour utiliser la librairie AUX
--with Win32.Glaux; use Win32.Glaux;

-- Pour utiliser la librairie GLUT
with Glut; use Glut;

-- Pour utiliser opengl
with Gl; use Gl;

-- Pour utiliser la librairie GLU
with Glu; use Glu;

-- Pour utiliser les fonction Sin. Cos sur des reels
with Ada.Numerics.Elementary_Functions; 
   use Ada.Numerics.Elementary_Functions;

-- Pour les entrees/Sorties dans le fichier trace
with Text_Io;

with P_Messages;

package body P_Train
is  

-- ***************************************************************************
--
-- Paquetage
--
-- ***************************************************************************

-- Pour effecuer des affichage d'entier
  package Aff_Int is new P_Afficher.Integer_Io(Integer);
  
  package Int_Io is new Text_Io.Integer_Io(Integer);
  
-- ***************************************************************************
--
-- Primitives de l'objet train
--
-- ***************************************************************************
   
   
  ----------------------------------------------------------------------------
  --
  -- Fonction : NewTrain       
  -- But      : Cree une instance du type etiquete train  
  --
  -- Entrees  : NoTrain       => Numero de la locomotive (numero externe 
  --                             simulateur donner par l'utilisateur)
  --            Vitesse       => Vitesse du train (nombre de mm parcouru
  --                             pendant un pas de simulation)
  --            EntreeTete    => Numero de la connection par laquelle la tete
  --                             du train est arrive sur la section
  --            EntreeQueue   => Numero de la connection par laquelle la queue
  --                             du train est arrive sur la section 
  --            SectionTete   => Pointeur vers l'objet section sur lequel la
  --                             tete du train se trouve 
  --            PositionTete  => Position de la tete du train dans la section 
  --                             (distance entre l'entree de la section et la 
  --                             tete du train)
  --            SectionQueue  => Pointeur vers l'objet section sur lequel la
  --                             queue du train se trouve 
  --            PositionQueue => Position de la queue du train dans la section 
  --                             (distance entre l'entree de la section et la  
  --                             queue du train)
  --            Actif         => Flag indiquant si le train est pose sur la
  --                             maquette
  --            Couleur       => Indique la couleur dans laquelle le train
  --                             sera dessine
  --
  ----------------------------------------------------------------------------
  function Newtrain (Notrain      : Integer:= -1;
                     Vitesse      : T_Vitesse:= Arret;
                     Entreetete   : P_Section.T_Connection_Id:= 1;
		                 Entreequeue  : P_Section.T_Connection_Id:= 1;
                     Sectiontete  : P_Section.T_Section_Ptr  := null;
                     Positiontete : P_Section.T_Position     := 0.0;
                     Sectionqueue : P_Section.T_Section_Ptr  := null;
                     Positionqueue: P_Section.T_Position     := 0.0;
                     Actif        : Boolean := False;
		                 Couleur      : P_Couleur.T_Couleur:= P_Couleur.Magenta)
    return T_Train_Ptr
  is                       
  begin
  
    -- Cree et initialise un objet train
    return new T_Train'(Notrain       => Notrain,
                        Vitesse       => Vitesse,
                        Entreetete    => Entreetete,
		                    Entreequeue   => Entreequeue,
                        Sectiontete   => Sectiontete,
                        Positiontete  => Positiontete,
                        Sectionqueue  => Sectionqueue,
                        Positionqueue => Positionqueue,
                        Actif         => Actif,
		                    Couleur       => Couleur);
  
  end Newtrain;
	
	----------------------------------------------------------------------------
  --
  -- Procedure: Poser       
  -- But      : Procedure qui permet de poser un train sur une section de 
  --            maquette.
	--            La procedure initialise la position de la tete et de la queue
	--            du train.
	--            La tete du train est posee sur la section specifieea a la
	--            position specifiee. La section et la position de la queue du
	--            train est determinee a partir de la longueur du train
	--  
	-- Entrees  : NoTrain  => Numero de la locomotive (numero externe simulateur
	--                        donner par l'utilisateur).
  --            Section  => Pointeur vers l'objet section sur lequel on va
  --                        poser la tete du train.
  --            Entree   => Identificateur de la connexion sur laquelle la
  --                        tete du train sera posee (la queue du train sera
  --                        placee de maniere a etre sur la section)      
  --            Position => Position de la tete du train dans la section
  --                        (distance entre l'entree de la section et la tete
  --                        du train)
  --            Couleur  => Indique la couleur dans laquelle le train sera
  --                        dessine                   
  -- Entrees &
  -- Sorties  : Train    => Le train que l'on veut placer sur la maquette.                                                             
	--            
	--            Contacts_actives
  --                     => Indique les contactes qui ont ete actives par le
  --                        train.
  --                                                 
	----------------------------------------------------------------------------
  procedure Poser(Train   : in out T_Train;
		         			Notrain : in     Integer;
					        Section : in     P_Section.T_Section_Ptr;
                  Entree  : in     P_Section.T_Connection_Id;
					        Sections: in     P_Section.T_Sections;
					        Position: in     P_Section.T_Position := 0.0; 
					        Couleur : in     P_Couleur.T_Couleur := P_Couleur.Magenta;
                  Contacts: in     P_Contact.T_Contacts;
                  Contacts_Actives: in out P_Contact.T_Contacts_Actives)
  is
                   
    -- Indique si la position dans la section est plus grande que la section
    Sectionsuivante: Boolean;
      
    -- Position dans la section de la queue du train
    Nouvelleposition: P_Section.T_Position := Position; 
      
    -- Identificateur du contact correspondant a la section occupe par le
    -- train
    Contact_Id : P_Contact.T_Contact_Id;
      
    -- Indication si la section est un contact
    Vrai: Boolean; 
      
	begin
      
		-- On stocke le numero du train.
		Train.Notrain := Notrain;

		-- Vitesse du train nulle.
		Train.Vitesse := 0;
      
    -- Affecte la couleur du train
		Train.Couleur := Couleur;
    
    -- on place la tete du train a l'endroit specifie
		Train.Sectiontete := Section;
		Train.Positiontete := Position;
      
    -- On specifie l'entree pour placer la tete du train sur la bonne
    -- connexion de la section 
    Train.Entreetete := Entree;

		-- On occupe la section
		P_Section.Occuper(Section);
      
    -- On verifie si cette section est un contact
    P_Contact.Est_Un_Contact(P_Section.Numero(Section),
                             Contacts,
                             Contact_Id,
                             Vrai); 
                                 
    -- Si oui on note dans la liste des contacts active
    if Vrai 
    then 
    
      Contacts_Actives(Contact_Id) := True;
      
    end if;
      
		-- On determine la position de la queue en remontant le long des sections
    Train.Sectionqueue:= Train.Sectiontete;
    Train.Entreequeue:=  Train.Entreetete;
       
    -- On determine la position de la queue
    Nouvelleposition:= Nouvelleposition + Float(Longueur_Train);   
        
    -- On verifie si on est toujours dans la meme section
    P_Section.Positiondanssection(Train.Sectionqueue.all,
                                  Train.Entreequeue, 
                                  Nouvelleposition,
                                  Sectionsuivante);
                                 
    -- Si la queue est sur une autre section                         
    while Sectionsuivante 
    loop
           
		  -- On cherche cette sectionet on l'affecte a la queue
		  P_Section.Prendresectionsuivante(Train.Sectionqueue,
		                                   Train.Entreequeue,
		                                   Sections);

			-- On occupe cette section.
			P_Section.Occuper(Train.Sectionqueue);
         
      -- On verifie si cette section est un contact
      P_Contact.Est_Un_Contact(P_Section.Numero(Train.Sectionqueue),
                               Contacts, 
                               Contact_Id,Vrai); 
                        
      -- Si oui on note dans la liste des contacts active
      if Vrai 
      then
      
        Contacts_Actives(Contact_Id) := True;
        
      end if;
                         
      -- On verifie si elle n'est pas encore dans la section suivante
      P_Section.Positiondanssection(Train.Sectionqueue.all,
                                    Train.Entreequeue, 
                                    Nouvelleposition,
                                    Sectionsuivante);
    end loop;
            
    -- On memorise la position de la queue
    Train.Positionqueue:= Nouvelleposition;
   
    -- On met la tete dans le sens de la marche
      
    -- Inverse la position et l'entree de la tete pour mettre la tete devant
    -- la queue selon le sens de marche
    Train.Positiontete := 
      P_Section.Positiondepuissortie(Train.Sectiontete.all,
                                     Train.Entreetete,
                                     Train.Positiontete);
                                                  
		Train.Entreetete	:= P_Section.Prendresortie(Train.Sectiontete.all,
                                                 Train.Entreetete);
     
		-- Inverse la position et l'entree de la queue pour mettre la tete devant
		-- la queue selon le sens de marche
		Train.Positionqueue := 
		  P_Section.Positiondepuissortie(Train.Sectionqueue.all,
                                     Train.Entreequeue,
                                     Train.Positionqueue);
                                                 
		Train.Entreequeue	:= 
		  P_Section.Prendresortie(Train.Sectionqueue.all,
		                          Train.Entreequeue);

      
    -- On active le train
		Train.Actif := True;
        
	end Poser;
          
	----------------------------------------------------------------------------
  --                 
  -- Procedure: Enlever
	-- But      : Procedure qui enleve un train de la maquette. A partir de ce
	--            moment, le train n'est plus actif il ne sera donc plus visible
	--            sur la maquette                 
	-- 
  -- Entrees &
  -- Sorties  : Train => le train que l'on veut retirer de la maquette.                                   
  --                 
	----------------------------------------------------------------------------
	procedure Enlever(Train: in out T_Train)
	is  
  begin
  
    -- On desactive le train
		Train.Actif := False;
    
	end Enlever;

	----------------------------------------------------------------------------
  --
  -- Procedure: MettreVitesse
	-- But      : Procedure qui permet de fixer la vitesse du train.
	--
	-- Entree   : Vitesse => Vitesse que l'on veut affecter au train  
	-- Entrees &
  -- Sorties  : Train   => le train dont on veut modifier la vitesse. 
  --
	----------------------------------------------------------------------------
	procedure Mettrevitesse(Train  : in out T_Train; 
	                        Vitesse: in     T_Vitesse)
	is
  begin
  
    -- Si le train est sur la maquette
    if Train.Actif 
    then
      -- On affecte la vitesse au train
		  Train.Vitesse := Vitesse;
		  
    end if;
    
	end Mettrevitesse;
    
	----------------------------------------------------------------------------
  --
	-- Procedure: ChangerDirection
	-- But      : Procedure qui permet de changer le sens de marche du train.
	-- 
	-- Entrees &  
	-- Sorties	: Train => le train dont on veut modifier le sens de la marche. 
  --
	----------------------------------------------------------------------------
  procedure Changerdirection(Train: in out T_Train)
  is
      
    -- On memorise la section de la tete
    Section : P_Section.T_Section_Ptr := Train.Sectiontete;
      
    -- On memorise la position de la tete
	  Position: P_Section.T_Position:= Train.Positiontete;
      
    -- On memorise l'entree de la tete
    Entree :  P_Section.T_Connection_Id:= Train.Entreetete;
      
  begin
    -- Si le train est sur la maquette
    if Train.Actif
    
    then
		  -- On echange les entree et les positions de la tete et de la queue du
		  -- train
		  Train.Sectiontete := Train.Sectionqueue;
      
      Train.Positiontete := 
        P_Section.Positiondepuissortie(Train.Sectionqueue.all,
                                       Train.Entreequeue,
                                       Train.Positionqueue);
                                        
		  Train.Entreetete	:= 
		    P_Section.Prendresortie(Train.Sectionqueue.all,
		                            Train.Entreequeue);
     
		  Train.Sectionqueue := Section;
      
	    Train.Positionqueue := 
	      P_Section.Positiondepuissortie(Section.all,
                                       Entree,
                                       Position);
                                             
		  Train.Entreequeue	:= 
		    P_Section.Prendresortie(Section.all, 
                                Entree);
    
    end if;
      
	end Changerdirection;
    
	----------------------------------------------------------------------------
  --
	-- Procedure: Avancer
	-- But      : Procedure qui avance le train d'une distance en relation avec
	--            sa vitesse et le nombre d'affichage par seconde realiser par
	--            le simulateur pour avoir a l'ecran un vitesse qui correspond a
	--            la realite
	-- 
	-- Entree   : Sections   => Ensemble des sections de la maquette utiliser
	--                          pour calculer la nouvelle section si on change
	--                          de section
  --            Nbraffichageparseconde 
  --                       => Indique le nombre pas de simulation (avance des
  --                          trains et affichage) qui est realise en une
  --                          seconde ce qui nous permet de calculer la 
  --                          distance que le train devra pourcourir a chaque
  --                          fois que avance est appelle
  --                                
  -- Entrees &
  -- Sorties  : Train   E => le train que l'on veut faire avancer. 
  --                    S => Le train que l'on a fait avancer
  --            Contacts_actives
  --                      => Indique les contactes qui ont ete actives par le
  --                         train. 
	--
	----------------------------------------------------------------------------
  procedure Avancer(Train                 : in out T_Train;
		     			      Sections              : in     P_Section.T_Sections;
                    Contacts              : in     P_Contact.T_Contacts;
                    Nbraffichageparseconde: in     Integer;
                    Contacts_Actives: in out P_Contact.T_Contacts_Actives)
  is
                          
    -- Position dans la section de la tete apres le deplacement
    Nouvellepositiontete: P_Section.T_Position := Train.Positiontete; 
       
    -- Position dans la section de la queue apres le deplacement
    Nouvellepositionqueue: P_Section.T_Position := Train.Positionqueue;   
       
    -- Indique si la position dans la section est plus grande que la section
    Sectionsuivante: Boolean;
       
    -- Identificateur du contact correspondant a la section occupe par le
    -- train
    Contact_Id: P_Contact.T_Contact_Id;
      
    -- Indication si la section est un contact
    Vrai : Boolean;
                                    
       
    -- Tableau indiquant la distance en mm a parcourir lors d'un appel a la
    -- procedure "avancer" selon la vitesse du train
    -- Distance calculee pour que la 
    -- vitesse max a l'ecran soit de 1.7 Km/h
    Vitesse_En_Mm: constant array (T_Vitesse) of Float := 
		    ( 0.0,
        (1.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde), 
        (2.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde), 
        (3.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde), 
        (4.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde),
        (5.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde), 
        (6.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde),
        (7.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde), 
        (8.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde),
        (9.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde), 
        (10.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde),
        (11.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde), 
        (12.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde),
        (13.0*(Vitesse_Max_Mm / 14.0)) / Float(Nbraffichageparseconde), 
        Vitesse_Max_Mm / Float(Nbraffichageparseconde));  
               
  begin
       
		-- Si le train n'est pas sur la maquette on retourne directement.
		if (not Train.Actif) 
		then
		
		  return;
		
		end if;

		-- On deplace la tete du train          
    Nouvellepositiontete:= Nouvellepositiontete + 
                           Vitesse_En_Mm(Train.Vitesse);
           
    -- On verifie si on est toujours dans la meme section
		P_Section.Positiondanssection(Train.Sectiontete.all, 
                                  Train.Entreetete, 
                                  Nouvellepositiontete,
                                  Sectionsuivante);
              
    -- Si on a changer de section  
    while Sectionsuivante 
    loop 
                                   
      -- On cherche la suivante et on l'affecte a la tete   
      P_Section.Prendresectionsuivante(Train.Sectiontete,
						              				     Train.Entreetete, Sections);  
         
      -- On occupe cette section.  
      P_Section.Occuper(Train.Sectiontete);
         
      -- On verifie si cette section est un contact
      P_Contact.Est_Un_Contact(P_Section.Numero(Train.Sectiontete),
                               Contacts, 
                               Contact_Id,
                               Vrai); 
                        
      -- Si oui on note dans la liste des contacts active
      if Vrai
      then
      
        Contacts_Actives(Contact_Id) := True;
        
      end if;
         
                                  -- on verifie si on pas pas 
                                  -- encore dans la section suivante                           
      P_Section.Positiondanssection(
                                 Train.Sectiontete.all, 
                                 Train.Entreetete, 
                                 Nouvellepositiontete,
                                 Sectionsuivante);                           
    end loop;
    
    -- On memorise la position de la tete                              
    Train.Positiontete:= Nouvellepositiontete;
      
    -- l'avant et l'arriere du train sont independant mais comme il se
    -- deplace a la meme vitesse sur les meme voie la distance entre eux est
    -- conservee dans la limite des erreurs de calculs    
      
    -- On deplace la queue du train
    Nouvellepositionqueue:= Nouvellepositionqueue + 
                            Vitesse_En_Mm(Train.Vitesse);
      
    -- On verifie si on est toujours dans la meme section
		P_Section.Positiondanssection(Train.Sectionqueue.all, 
                                  Train.Entreequeue, 
                                  Nouvellepositionqueue,
                                  Sectionsuivante);
      
    -- Si la on a changer de section
    while Sectionsuivante
    loop                     
                                   
      -- On libere la section que le train vient de quitter
      P_Section.Liberer(Train.Sectionqueue);
            
      -- On cherche la suivante et on l'affecte a la tete 
      P_Section.Prendresectionsuivante(Train.Sectionqueue,
										                   Train.Entreequeue,
										                   Sections);  
         
      -- on verifie si on pas pas encore dans la section suivante  
      P_Section.Positiondanssection(Train.Sectionqueue.all, 
                                    Train.Entreequeue, 
                                    Nouvellepositionqueue,
                                    Sectionsuivante);                           
    
    end loop;
    
    -- On memorise la position de la queue                               
    Train.Positionqueue:= Nouvellepositionqueue;		

	end Avancer;

  ----------------------------------------------------------------------------
  --                   
  -- Procedure: Put
  -- But      : Procedure qui affiche a l'ecran des informations a propos du
  --            train.
  --                   
  -- Entrees  : Train         => le train a propos duquel on veut des
  --                             informations
  --
  --            Affichage     => Indique si on affiche les indications dans la
  --                             fenetre texte ou si on ne les fait apparaitre
  --                             que dans le fichier trace. 
  --
  --            Fichier_Trace => Fichier dans lequel on ecrit le deroulement
  --                             d'une simulation.
  -- 
  ----------------------------------------------------------------------------
  procedure Put(Train        : in     T_Train;
                Affichage    :        Boolean; 
                Fichier_Trace: in     Text_Io.File_Type)
  is 
  begin
     
  -- Cette procedure doit etre appelee dans une partie de code ou l'ecran est
  -- reserve sinon les affichages seront pas ecrit en exclusion mutuelle 
     
     -- Affiche le numero
     if Affichage 
     then
     
        P_Afficher.Put_Dans_Zone_Reserv("| " & P_Messages.Numero);
        Aff_Int.Put_Dans_Zone_Reserv(Train.Notrain, 2);
     
     end if;
     
     Text_Io.Put(Fichier_Trace, "| " & P_Messages.Numero);
     Int_Io.Put(Fichier_Trace, Train.NoTrain, 2);
     
     -- Si il est sur la maquette
     if Train.Actif 
     then
     
        -- On affiche sa vitesse
        if Affichage
        then
        
           P_Afficher.Put_Dans_Zone_Reserv(" | Vit: ");
           Aff_Int.Put_Dans_Zone_Reserv(Train.Vitesse, 2);
           P_Afficher.Put_Dans_Zone_Reserv(" | ");
        
        end if;
                 
        Text_Io.Put(Fichier_Trace, " | " & P_Messages.Vitesse);
        Int_Io.Put(Fichier_Trace, Train.Vitesse, 2);
        Text_Io.Put(Fichier_Trace, " | ");
     
     else
     
        -- Si il n'est pas sur la maquette on l'indique 
        if Affichage
        then
        
           P_Afficher.Put_Dans_Zone_Reserv(" | " & P_Messages.Pas_Active);
           
        end if;
           
        Text_Io.Put(Fichier_Trace, " | " & P_Messages.Pas_Active);
             
     end if;
           
     if Affichage
     then
     
        P_Afficher.New_Line_Dans_Zone_Reserv;
        
     end if;          
     
	end Put;
   
  ----------------------------------------------------------------------------
  --
  -- Procedure: Paint
  -- But      : Procedure qui affiche a le train a l'ecran (le train est
  --            modeliser par un parallelepipede rectangle dont l'extremite
  --            avant est de couleur jaune comme les phares.  
  --          
  -- Entrees  : Train => le train a propos duquel on veut des informations
  --
  ----------------------------------------------------------------------------
  procedure Paint( Train: in     T_Train)
  is     
    
    -- Point dans le plan ou se trouve la tete du train
    Pointtete : P_Section.T_Point;
        
    -- Point dans le plan ou se trouve la queue du train
    Pointqueue : P_Section.T_Point;
               
    -- Couleur du train
    Couleur: P_Couleur.T_Couleur_Rvba := P_Couleur.Transforme(Train.Couleur); 
           
    -- Couleur des phares avants et arrieres
    Couleur_Feux_Avants   : P_Couleur.T_Couleur_Rvba
                          := P_Couleur.Transforme(P_Couleur.Jaune);
           
  begin
       
    -- On dessine le train que si il est pose sur la maquette
    if Train.Actif 
    then
    
      -- On cherche la position en X et Y de la tete du train
      Pointtete:= P_Section.Positiondansplan(Train.Sectiontete.all,
                                             Train.Entreetete, 
                                             Train.Positiontete);
                                              
      -- On cherche la position en X et Y de la queue du train
      Pointqueue:= P_Section.Positiondansplan(Train.Sectionqueue.all,
                                              Train.Entreequeue, 
                                              Train.Positionqueue);                   
                                               
      -- On sauve la matrice courante (modelView) sur la pile
      Glpushmatrix;
         
      -- on place le train a sa place dans la maquette
      Gltranslatef (Glfloat(Pointqueue.X), 
                    Glfloat(Pointqueue.Y),
                    10.0);
       
      -- On le met dans la direction qui correspond a sa position dans
      -- la maquette
      Glrotatef (Glfloat(Arctan((Pointtete.Y-Pointqueue.Y),
                (Pointtete.X-Pointqueue.X), 360.0)), 0.0, 0.0, 1.0);
                                 
      -- On sauve la matrice de transformation pour que les instruction si
      -- dessous ne la modifie pas - les sauvegardes multiples permettent
      -- des transformations successives
      Glpushmatrix;
                                  
      -- On specifie la couleur du dessin en determinant les proprietes de
	    -- reflexion de la lumiere de l'objet dessine
      Glmaterialfv (Gl_Front,
                    Gl_Ambient,
                    Couleur(1)'Unchecked_Access);
      Glmaterialfv (Gl_Front,
                    Gl_Diffuse,
                    Couleur(1)'Unchecked_Access);
          
      -- On place le train a l'origine, juste en dessus de la maquette
      -- pour bien le voir
      Gltranslatef (Glfloat(Longueur_train/2.0),
                    0.0,
                    1.0);
      -- On dessine le train
      glScalef(Glfloat(Longueur_Train),
               Glfloat(Largeur_Train),
               15.0);
      glutSolidCube(1.0);
      
      -- On retablit le contexte precedant l'execution de la fonction
      Glpopmatrix;

      Glpushmatrix;

      Gltranslatef (Glfloat(Longueur_train/2.0 - Largeur_Train/2),
                    0.0,
                    10.0);
      glScalef(Glfloat(Longueur_Train - Largeur_Train),
               Glfloat(Largeur_Train),
               10.0);
      glutSolidCube(1.0);
      
      -- On replace la matrice ainsi les transformation ci-dessus
      -- n'affecteront pas les dessin ci-dessous
      Glpopmatrix;                             
          
      Glpushmatrix;

      -- On specifie la couleur du dessin en determinant les proprietes de 
	    -- reflexion de la lumiere de l'objet dessine
      Glmaterialfv (Gl_Front,
                    Gl_Ambient,
                    Couleur_Feux_Avants(1)'Unchecked_Access);
      Glmaterialfv (Gl_Front,
                    Gl_Diffuse,
                    Couleur_Feux_Avants(1)'Unchecked_Access);
          
      -- On place les phares au bout du train
      Gltranslatef (Glfloat(Longueur_Train - Largeur_Train/2),
                    0.0,
                    10.0);
      -- On dessine la cabine de conduite eclairee
      glScalef(Glfloat(Largeur_Train),
               Glfloat(Largeur_Train),
               10.0);
      glutSolidCube(1.0);
      
      -- On retablit le contexte precedant l'execution de la fonction
      Glpopmatrix;
      
      Glpushmatrix;

      -- On place le phare avant gauche
      Gltranslatef (Glfloat(Longueur_Train),
                    Glfloat(Largeur_Train/2) - 5.5,
                    2.0);
      -- On dessine le phare avant gauche
      glutSolidSphere (5.0, 20, 20);

      -- On retablit le contexte precedant l'execution de la fonction
      Glpopmatrix;
      
      Glpushmatrix;

      -- On place le phare avant droit
      Gltranslatef (Glfloat(Longueur_Train),
                    Glfloat(-Largeur_Train/2) + 5.5,
                    2.0);
      -- On dessine le phare avant droit
      glutSolidSphere (4.0, 20, 20);
      
      Glpopmatrix;

      -- On retablit le contexte precedant l'execution de la fonction
      Glpopmatrix;
           
    end if;
    
  end Paint;
  
end P_Train;


