------------------------------------------------------------------------------
--
-- Nom du fichier     : P_train.ads
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

-- Pour utiliser les objets sections (rail)
with P_Section;
                                   
-- Pour utiliser les objets contacts
with P_Contact;

-- Pour utiliser les couleurs
with P_Couleur;

-- Pour ecrire dans le fichier trace
with Text_Io;

package P_Train
is

-- ***************************************************************************
--
-- Constantes
--
-- ***************************************************************************
   
  -- Nombre maximum de train pouvant etre utilise
  Nbr_Max_Train : constant := 80;
  
  -- Largueur du train (egalement utilise pour la hauteur du train)
  Largeur_Train : constant := 25.0;
  
  -- longueur du train
  Longueur_Train : constant :=  120.0;
  
  -- Vitesse maximun d'un train selon specification de train_handler 
  Vitesse_Max : constant := 14;
  
  -- Distance en mm qu'un train peut parcourir en une seconde vitesse 
  -- 1,7 km/h (472mm/s)
  Vitesse_Max_Mm : constant := 472.0; 
                         
-- ***************************************************************************
--
-- Type
--
-- ***************************************************************************
   
  -- Type pour identifier un train.
  subtype T_Train_Id is Natural range 0..Nbr_Max_Train;    
                                        
  -- Type pour exprimer la vitesse d'un train ( indique le nombre de mm
  -- effectue en un pas de simulation)
  subtype T_Vitesse is Natural range 0..Vitesse_Max;

-- ***************************************************************************
--
-- Constante suite
--
-- ***************************************************************************   
    
  -- Vitesse representant l'arret d'un train
  Arret : constant T_Vitesse := 0; 
   
  -- Identificateur d'un train inexistant
  Train_Null : constant T_Train_Id:= 0;
   
-- ***************************************************************************
--
-- Definition des Objets
--
-- ***************************************************************************     
 
-- ===========================================================================
-- Type pour un train (locomotive).
-- ===========================================================================   
   
  -- Type pour un train (objet Train) 
  type T_Train is tagged private; 

  -- Type pointeur sur un objet train.
  type T_Train_Ptr is access T_Train; 
   
  -- Type pour exprimer un ensemble de train.    
  type T_Trains is array (T_Train_Id range <>) of T_Train_Ptr;
   
   
  -- =========================================================================
  -- Les primitives d'un train.
  -- =========================================================================
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
                     Couleur: P_Couleur.T_Couleur:= P_Couleur.Magenta) 
    return T_Train_Ptr;
                      
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
  --            Contacts_actives
  --                     => Indique les contactes qui ont ete actives par le
  --                        train.
  --                                                 
  ----------------------------------------------------------------------------
  procedure Poser
    (Train            : in out T_Train;
     Notrain          : in     Integer;
     Section          : in     P_Section.T_Section_Ptr;
     Entree           : in     P_Section.T_Connection_Id;
     Sections         : in     P_Section.T_Sections;
     Position         : in     P_Section.T_Position := 0.0;
     Couleur          : in     P_Couleur.T_Couleur := P_Couleur.Magenta;
     Contacts         : in     P_Contact.T_Contacts;
     Contacts_Actives : in out P_Contact.T_Contacts_Actives);

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
  procedure Enlever(Train: in out T_Train);

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
                          Vitesse: in     T_Vitesse);
    
  ----------------------------------------------------------------------------
  --
  -- Procedure: ChangerDirection
  -- But      : Procedure qui permet de changer le sens de marche du train.
  -- 
  -- Entrees &  
  -- Sorties  : Train => le train dont on veut modifier le sens de la marche. 
  --
  ----------------------------------------------------------------------------
  procedure Changerdirection(Train: in out T_Train);
    
  ----------------------------------------------------------------------------
  --
  -- Procedure: Avancer
  -- But      : Procedure qui avance le train d'une distance en relation avec
  --            sa vitesse et le nombre d'affichage par seconde realiser par
  --            le simulateur pour avoir a l'ecran un vitesse qui correspond a
  --            la realite
  -- 
  -- Entree   : Sections => Ensemble des sections de la maquette utiliser pour
  --                        calculer la nouvelle section si on change de
  --                        section
  --            Nbraffichageparseconde 
  --                     => Indique le nombre pas de simulation (avance des
  --                        trains et affichage) qui est realise en une
  --                        seconde ce qui nous permet de calculer la distance
  --                        que le train devra pourcourir a chaque fois que
  --                        avance est appelle                                
  --   
  -- Entrees &
  -- Sorties  : Train  E => le train que l'on veut faire avancer. 
  --                   S => Le train que l'on a fait avancer
  --            Contacts_actives
  --                     => Indique les contactes qui ont ete actives par le
  --                        train. 
  --
  ----------------------------------------------------------------------------
  procedure Avancer
    (Train                   : in out T_Train; 
     Sections                : in     P_Section.T_Sections;
     Contacts                : in     P_Contact.T_Contacts;
     Nbraffichageparseconde  : in     Integer;
     Contacts_Actives        : in out P_Contact.T_Contacts_Actives);
                   
  ----------------------------------------------------------------------------
  --                   
  -- Procedure: Put
  -- But      : Procedure qui affiche a l'ecran des informations a propos du
  --            train.
  --                   
  -- Entrees  : Train         => le train a propos duquel on veut des
  --                             informations
  --            Affichage     => Indique si on affiche les indications dans la
  --                             fenetre texte ou si on ne les fait apparaitre
  --                             que dans le fichier trace.
  --            Fichier_Trace => Fichier dans lequel on ecrit le deroulement
  --                             d'une simulation.                    
  ----------------------------------------------------------------------------
  procedure Put(Train         : in     T_Train; 
                Affichage     : in     Boolean; 
                Fichier_Trace : in     Text_Io.File_Type);  
  
  ----------------------------------------------------------------------------
  --
  -- Procedure: Paint
  -- But      : Procedure qui affiche a le train a l'ecran (le train est
  --            modeliser par un parallelepiped rectangle dont l'extremite
  --            avant est de couleur jaune comme les phares.  
  --          
  -- Entrees  : Train => le train a propos duquel on veut des informations
  --
  ----------------------------------------------------------------------------
  procedure Paint(Train: in     T_Train);
   
   
-- ***************************************************************************
--
-- Implementation des Objets
--
-- ***************************************************************************    
private
   
-- ===========================================================================
-- Type pour un train (locomotive).
-- ===========================================================================
   
   -- Type de l'objet train
  type T_Train
  is tagged record      
    
    -- Numero de la locomotive (numero externe au simulateur utilise par 
    -- l'utilisateur)
    Notrain: Integer ;             
      
    -- Vitesse du train
    Vitesse:  T_Vitesse;           
      
    -- Numero de la connection par laquelle la tete du train est arrive sur la
    -- section
    Entreetete: P_Section.T_Connection_Id;
      
    -- Numero de la connection par laquelle la queue du train est arrive sur
    -- la section
    Entreequeue: P_Section.T_Connection_Id;

    -- Pointeur vers l'objet section sur lequel la tete du train se trouve 
    Sectiontete: P_Section.T_Section_Ptr;
      
    -- Position de la tete du train dans la section (distance entre l'entree
    -- de la section et la tete du train) 
    Positiontete: P_Section.T_Position;
      
    -- Pointeur vers l'objet section sur lequel la queue du train se trouve 
    Sectionqueue: P_Section.T_Section_Ptr;
      
    -- Position de la queue du train dans la section (distance entre l'entree
    -- de la section et la queue du train)  
    Positionqueue: P_Section.T_Position;
        
    --  Flag indiquant si le train est pose sur la maquette                    
    Actif: Boolean;                                             
      
    -- Indique la couleur dans laquelle le train sera dessine
    Couleur: P_Couleur.T_Couleur;
                          
  end record; 
  
end P_Train;

