--------------------------------------------------------------------------
--
-- Nom du fichier		: P_Section.ads
-- Auteur				    : P. Girardet sur la base du travail de
--                    M.Pascal Binggeli & M.Vincent Crausaz
--
-- Date de creation	: 12.10.97
-- Version				  : 3.0
-- Derniere modifs.	: Decembre 1997
-- Raison de la 
-- Modification     : Ajout d'une interface graphique
--
-- Projet				    : Simulateur de maquette
-- Module				    : Section
--
-- But					    : Module mettant a disposition des objets sections
--                    derivant tous d'un meme objet. Ils peuvent donc
--                    etre gerer de facon similaire.
--
-- Fonctions exportees	:
--
-- Materiel 
-- particulier       : Les dll "OpenGl32.dll" et "Glu32.dll" doivent
--                     etre dans le repertoire systeme de windows
--
--------------------------------------------------------------------------

                                  -- Pour utiliser des couleurs 
                                  -- compatible avec OpenGL 
with P_Couleur;

                                  -- Pour faire des entrees/sorties 
                                  -- sur ses fichiers
with Text_Io;

package P_Section is
    
    
-- ***********************************************************************
--
-- Exception
--
-- ***********************************************************************
                        
	                                -- Exception levee en cas de 
                                  -- collision entre deux trains ou 
                                  -- lorsqu'un train entre en
                                  -- collision avec une fin de voie.
                                  -- Il y a collision entre deux 
                                  -- trains lorsqu'un train essaie 
                                  -- d'occuper une section
	                                -- qui est deja prise.
  Collision: exception;
    
                                  -- Exception levee en cas de 
                                  -- changement de la direction d'un
                                  -- aiguillage lorsque l'aiguillage 
                                  -- est occupe par un train ou lorsque
                                  -- un train passe sur un aiguillage
                                  -- a trois voie et que les aiguillages
                                  -- qui le compose sont les deux devie 
  Derailler: exception;
    
   

-- ***********************************************************************
--
-- Constante
--
-- ***********************************************************************    
    
  Pi : constant := 3.14159265359;
    
	                               -- Nombre de connections max 
                                  -- par section.
	Max_Connections: constant := 4;
    
                                  -- Nombre max de sections
	Max_Sections: constant := 256;
      
                                  -- Largueur de toutes les sections
  Largueur_Section: constant := 30.0;
      
-- ***********************************************************************
--
-- Type
--
-- ***********************************************************************
    
                                  -- Le type vecteur indiquant 
                                  -- la direction dans laquelle 
                                  -- la section se dirige
  type T_Vecteur is record
    X: Float;
    Y: Float;
  end record;
    
                                  -- Le type du point de depart 
                                  -- ou se trouve l'entree
                                  -- de la section
  type T_Point is record
    X: Float;
    Y: Float;
  end record;
    
                                  -- Le type exprimant la position 
                                  -- a l'interieur d'une section
                                  -- (longueur max d'une section + 
                                  -- Vitesse Max En Mm)
  subtype T_Position is Float range 0.0..1000.0;
    
                                  -- Le type exprimant si un aiguillage
                                  -- est independant (il est dependant
                                  -- que si il s'agit du deuxieme 
                                  -- aiguillage d'un aiguillage double)
  type T_Aiguillage_Type is (Principal, Secondaire);
    
	                                -- Le type exprimant la commande 
                                   -- de direction d'un aiguillage. 
	type T_Direction is (Devie, Tout_Droit);
   
                                   -- Type exprimant la direction de
                                   -- rotation d'une section courbe
                                   -- (toujours selon son entree)
  type T_Orientation is (Gauche, Droite);
    
                                   -- Type pour l'etat d'un aiguillage.   
	type T_Etat is (Etat_Droit, Etat_Devie, Etat_Droit_Devie, 
                   Etat_Devie_Devie);

                                   -- Type pour un identificateur 
                                   -- de section.
  subtype T_Section_Id is Natural range 0..Max_Sections;
    
                                   -- Type pour un identificateur 
                                   -- de connection.
	subtype T_Connection_Id is Natural range 0..Max_Connections;

	                                -- Type pour exprimer les connection
                                   -- d'une section
	type T_Connections is array (T_Connection_Id range <>) of 
       T_Section_Id;
       
                                   -- Type de l'information necessaire 
                                   -- pour placer une section
                                   -- dans un plan                        
  type T_Info_Placement is record
        Section_Id: T_Section_Id;        -- Section a placer
        Vecteur: T_Vecteur;              -- Direction de la section
        Point: T_Point;                  -- Point de depart de la section
        
                                         -- Section qui fournit la
                                         -- direction et le point de
        Section_Id_Preced: T_Section_Id; -- depart 
                                         
  end record;                          
    
                                  -- Type renvoye lors du placement 
                                  -- d'une section pour donner les
                                  -- informations necessaire au 
                                  -- placement des sections connectee
  type T_Section_A_placer is array (T_Connection_Id range <>) of
         T_Info_Placement;                        
    
    
                                  -- Section inexistante utilise par 
                                  -- pour specifier qu'il n'a pas de
                                  -- section fournissant le point et
                                  -- le vecteur lors d'un placement
  Section_Null: constant T_Section_Id:= 0;
    
                                  -- Connection inexistante utilisee
                                  -- pour la meme raison
  Connection_Null: constant T_Connection_Id := 0; 
             
-- ***********************************************************************
--
-- Paquetage
--
-- ***********************************************************************         

                                  -- Paquetage utilise pour les entrees
                                  -- sortie le type d'un aiguillage
                                  -- (Principal ou Secondaire)
  package P_Aiguillage_Type_Io is new  
      Text_Io.Enumeration_Io(T_Aiguillage_Type);        

                                  -- Paquetage utilise pour les entrees
                                  -- sortie de l'orientation d'une
                                  -- section
  package P_Orientation_Io is new 
      Text_Io.Enumeration_Io(T_Orientation);
     
    
-- ***********************************************************************
--
-- Definition des objets sections
--
-- ***********************************************************************
                                         
-- =======================================================================
-- Type pour une section elementaire.
-- =======================================================================    
   
                                  -- Type de base de la classe de 
                                  -- derivation contient 
                                  -- les informations commune a toute
                                  -- les sections 
  type T_Section_Generic(Nbrconnections: T_Connection_Id) is abstract 
    tagged private;
		                       

                                  -- Type pointeur sur la classe 
                                  -- de derivation des objects section
                                  -- peut pointer sur n'importe quelle 
                                  -- section (polymorphisme)
  type T_Section_Ptr is access all T_Section_Generic'Class;
    
                                  -- Type pour exprimer un ensemble de 
                                  -- sections (une maquette)
  type T_Sections is array (T_Section_Id range <>) of T_Section_Ptr;
    
  ------------------------------------------------------------------------    
  -- Les primitives d'une section elementaire.
  ------------------------------------------------------------------------    
    
   ------------------------------------------------------------------------
   --
   -- Procedure: Put
 	 -- But      : Procedure qui affiche sur la fenetre textuelle
 	 --            des informations sur la section
   --
   --            Affiche le numero de la section et une indication si
   --            elle est occupee par une section ou pas ainsi que le
   --            numero des sections auquelles elle est connectee  
	 --  
   -- Entree   : Section        => Objet de type section generique
   --
	 ------------------------------------------------------------------------
	 procedure Put(Section: in T_Section_Generic);
   
   -----------------------------------------------------------------------
   --
   -- Procedure: Placer
   -- But      : Procedure qui determine la position d'une section dans
   --            le plan et qui affecte cette position a la section.
   --
   --            Procedure appellee un fois a l'initialisation du
   --            simulateur
   --
   -- Entree   : Point     => Le point dans le plan ou sera place 
   --                         l'entree ou une sortie de la section.
   --            Vecteur   => La direction dans laquelle va la section
   --                         depuis le point
   --            Preced    => L'identificateur de la section qui a
   --                         determine le point et le vecteur et qui 
   --                         sert a savoir quel entree ou sortie de la
   --                         section a placer sera sur ce point
   -- Entree &
   -- Sortie    : Section E=> La section a placer dans le plan      
   --                     S=> La section placee dans le plan
   --
   -- Sorties   : Suivant  => Un tableau contenant les informations
   --                         pour placer les sections connectee a la
   --                         section que l'on vient de placer
   --
   -----------------------------------------------------------------------    
    procedure Placer(Section: in out T_Section_Generic; 
                     Point: in T_Point; Vecteur: in T_Vecteur;
                     Preced: in T_Section_Id;
                     Suivant : out T_Section_A_placer )is abstract;
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Paint
    -- But      : Procedure qui affiche la section                                                                                    
    --            dans une fenetre graphique opengl selon son
    --            emplacement dans le plan
    --
    -- Entrees  : Section    => Objet section que l'on desir dessiner
    --
    ----------------------------------------------------------------------                                                                                    
    procedure Paint (Section: in T_Section_Generic) is abstract; 
                    
    
    ----------------------------------------------------------------------
    --
    -- Fonction: Positiondansplan
    -- But     : Fournit une position precise dans le plan (valeur X,
    --           et valeur Y) a partir d'un position determinee par
    --           une section et par une position dans cette section
    --           qui est un valeur exprimant la distance entre le
    --           point chercher et une extremite de la section,
    --           
    -- Entree  : Section     => Objet section sur lequel se touve la
    --                          position cherchee
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           Posdanssection
    --                       => Distance entre l'extremite de la section
    --                          determinee par "Entree" et le point 
    --                          de la section dont on desir les
    --                          coordonnee
    --
    -- Retour  : La position recherchee 
    --
    ----------------------------------------------------------------------
    function Positiondansplan(Section : in T_Section_Generic; 
                              Entree: in T_Connection_Id;                   
                              Posdanssection: in T_Position) 
                              return T_Point is abstract;
          
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondanssection
    -- But      : Indiquer si la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) est plus grande que la section et de combien
    --                          
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          a savoir si le position dans la section
    --                          et trop grande
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           
    -- Entrees &          
    -- Sorties : Posdanssection           
    --                    E  => Distance entre l'extremite de la Section
    --                          determinee par "Entree" et un point 
    --                          precis sur la section 
    --                    S  => Meme distance si elle ne depasse pas 
    --                          la longueur de la section ou distance
    --                          dans la section suivante si elle depasse
    --                          (distance - longueur section = distance
    --                          dans la suivante)
    --
    -- Sortie : Dehors       => Indique si on est toujours dans la section
    --                          ou pas (True => hors de la section
    --                                  False => dans la section
    --
    ----------------------------------------------------------------------                                                   
    procedure Positiondanssection (Section : in  T_Section_Generic;
                                   Entree: in  T_Connection_Id;
                                   Posdanssection: in out T_Position;
                                   Dehors: out Boolean) is abstract;
    
                                                             
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondepuissortie
    -- But      : Indiquer la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) depuis l'extremite oposee a celle utilisee
    --            utilisee pour definir cette position en entree.
    --
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          la position dans la section depuis
    --                          l'extremite oposee a celle definie dans
    --                          "entree"     
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie 
    --           Posdepuientree
    --                       => Position dans la section depuis 
    --                          l'extremite definie par "entree"
    -- 
    -- Retour  : La position dans la section depuis l'extremite
    --           oposee a celle qui sert de reference pour indiquer
    --           la position en entree
    --
    ----------------------------------------------------------------------                                                              
    function Positiondepuissortie(Section: in T_Section_Generic; 
                                  Entree: in T_Connection_Id;
                                  Posdepuisentree: in T_Position) 
                                  return T_Position is abstract;
   
    -----------------------------------------------------------------------
    --
    -- Fonction : Prendresortie
    -- But      : Fonction qui determine la section suivante                                  
	  --            a partir d'une section et de l'entree sur la section.
	  -- 
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          la sortie
    --           Entree      => Index du tableau de connection de la
    --                          section indiquant l'extremite qui fait
    --                          office d'entree
    -- 
    -- Retour  : Index du tableau de connection qui sera la sortie                                                       
  	-- 
    -----------------------------------------------------------------------
	  function Prendresortie(Section: in T_Section_Generic;
	    Entree: in T_Connection_Id) return T_Connection_Id is abstract;
    
-- =======================================================================
-- Type pour une section simple.
-- ======================================================================= 
                                  -- Type d'un objet voie simple 
                                  -- qui est dans la classe de
                                  -- derivation de T_Section_Generic
    type T_Section_Simple is abstract new T_Section_Generic with private;                       
    
    ----------------------------------------------------------------------    
    -- Les primitives d'une section simple.
    ----------------------------------------------------------------------                        
    
   -----------------------------------------------------------------------
   --
   -- Fonction : Prendresortie
   -- But      : Fonction qui determine la section suivante                                  
	 --            a partir d'une section et de l'entree sur la section.
	 -- 
   -- Entree  : Section     => Objet section sur lequel on cherche
   --                          la sortie
   --           Entree      => Index du tableau de connection de la
   --                          section indiquant l'extremite qui fait
   --                          office d'entree
   -- 
   -- Retour  : Index du tableau de connection qui sera la sortie                                                       
	 -- 
   ----------------------------------------------------------------------- 
	 function Prendresortie(Section: in T_Section_Simple;
							Entree: in T_Connection_Id) return T_Connection_Id;                       
    
   
                                                
-- =======================================================================
-- Type pour une section simple droite.
-- =======================================================================
                                  -- Type d'un objet voie droite 
                                  -- qui est dans la classe de
                                  -- derivation de T_Section_Generic
    type T_Section_Droite is new T_Section_Simple with private;
        
                                  -- Type pointeur sur un objet voie
                                  -- droite
    type T_Section_Droite_Ptr is access T_Section_Droite;
 
    ----------------------------------------------------------------------    
    -- Les primitives d'une section simple droite.
    ---------------------------------------------------------------------- 
    
    ----------------------------------------------------------------------
    --
    -- Fonction : New_Section_Droite
    -- But      : Fonction qui cree une instance de l'objet voie droite  
    --            et retourne le pointeur sur celui-ci
    -- 
    -- Entree   : Numero      => Le numero de la section
    --            Connections => Un tableau de connection indiquant les
    --                           section connectee a la section que l'on
    --                           construit
    --            Longueur    => Longueur de la section
    --
    -- Retour   : Un pointeur sur l'instance de l'objet cree
    --
    ----------------------------------------------------------------------  
    function New_Section_Droite(Numero: T_Section_Id; 
                                Connections:T_Connections;
                                Longueur: Float) return 
                                   T_Section_Droite_Ptr;
    
   -----------------------------------------------------------------------
   --
   -- Procedure: Placer
   -- But      : Procedure qui determine la position d'une section dans
   --            le plan et qui affecte cette position a la section.
   --
   --            Procedure appellee un fois a l'initialisation du
   --            simulateur
   --
   -- Entree   : Point     => Le point dans le plan ou sera place 
   --                         l'entree ou une sortie de la section.
   --            Vecteur   => La direction dans laquelle va la section
   --                         depuis le point
   --            Preced    => L'identificateur de la section qui a
   --                         determine le point et le vecteur et qui 
   --                         sert a savoir quel entree ou sortie de la
   --                         section a placer sera sur ce point
   -- Entree &
   -- Sortie    : Section E=> La section a placer dans le plan      
   --                     S=> La section placee dans le plan
   --
   -- Sorties   : Suivant  => Un tableau contenant les informations
   --                         pour placer les sections connectee a la
   --                         section que l'on vient de placer
   --
   -----------------------------------------------------------------------                            
    procedure Placer(Section: in out T_Section_Droite; 
                     Point: in T_Point; Vecteur: in T_Vecteur;
                     Preced: in T_Section_Id; 
                     Suivant : out T_Section_A_placer );
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Paint
    -- But      : Procedure qui affiche la section                                                                                    
    --            dans une fenetre graphique opengl selon son
    --            emplacement dans le plan
    --
    -- Entrees  : Section    => Objet section que l'on desir dessiner
    --
    ----------------------------------------------------------------------
    procedure Paint (Section: in T_Section_Droite);
    
    ----------------------------------------------------------------------
    --
    -- Fonction: Positiondansplan
    -- But     : Fournit une position precise dans le plan (valeur X,
    --           et valeur Y) a partir d'un position determinee par
    --           une section et par une position dans cette section
    --           qui est un valeur exprimant la distance entre le
    --           point chercher et une extremite de la section,
    --           
    -- Entree  : Section     => Objet section sur lequel se touve la
    --                          position cherchee
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           Posdanssection
    --                       => Distance entre l'extremite de la section
    --                          determinee par "Entree" et le point 
    --                          de la section dont on desir les
    --                          coordonnee
    --
    -- Retour  : La position recherchee 
    --
    ----------------------------------------------------------------------                        
    function Positiondansplan(Section : in  T_Section_Droite; 
                              Entree: in T_Connection_Id;                   
                              Posdanssection: in T_Position) 
                              return T_Point;
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondanssection
    -- But      : Indiquer si la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) est plus grande que la section et de combien
    --                          
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          a savoir si le position dans la section
    --                          et trop grande
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           
    -- Entrees &          
    -- Sorties : Posdanssection           
    --                    E  => Distance entre l'extremite de la Section
    --                          determinee par "Entree" et un point 
    --                          precis sur la section 
    --                    S  => Meme distance si elle ne depasse pas 
    --                          la longueur de la section ou distance
    --                          dans la section suivante si elle depasse
    --                          (distance - longueur section = distance
    --                          dans la suivante)
    --
    -- Sortie : Dehors       => Indique si on est toujours dans la section
    --                          ou pas (True => hors de la section
    --                                  False => dans la section
    --
    ----------------------------------------------------------------------                           
    procedure Positiondanssection (Section : in  T_Section_Droite;
                                   Entree: in  T_Connection_Id;
                                   Posdanssection: in out T_Position;
                                   Dehors: out Boolean);
                                                                         
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondepuissortie
    -- But      : Indiquer la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) depuis l'extremite oposee a celle utilisee
    --            utilisee pour definir cette position en entree.
    --
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          la position dans la section depuis
    --                          l'extremite oposee a celle definie dans
    --                          "entree"     
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie 
    --           Posdepuientree
    --                       => Position dans la section depuis 
    --                          l'extremite definie par "entree"
    -- 
    -- Retour  : La position dans la section depuis l'extremite
    --           oposee a celle qui sert de reference pour indiquer
    --           la position en entree
    --
    ----------------------------------------------------------------------                   
    function Positiondepuissortie(Section: in T_Section_Droite; 
                                  Entree: in T_Connection_Id;
                                  Posdepuisentree: in T_Position) 
                                  return T_Position ;                                   
-- =======================================================================
-- Type pour une section simple courbe.
-- =======================================================================                     
                    
                                  -- Type d'un objet voie courbe 
                                  -- qui est dans la classe de
                                  -- derivation de T_Section_Generic
    type T_Section_Courbe is new T_Section_Simple with private;
        
                                  -- Type pointeur sur un objet
                                  -- voie courbe 
    type T_Section_Courbe_Ptr is access T_Section_Courbe;
    
    ---------------------------------------------------------------------------    
    -- Les primitives d'une section simple courbe
    --------------------------------------------------------------------------- 
    
    ----------------------------------------------------------------------
    --
    -- Fonction : New_Section_Courbe
    -- But      : Fonction qui cree une instance de l'objet voie courbe  
    --            et retourne le pointeur sur celui-ci
    -- 
    -- Entree   : Numero      => Le numero de la section
    --            Connections => Un tableau de connection indiquant les
    --                           section connectee a la section que l'on
    --                           construit
    --            Rayon       => Rayon du cercle realise par le rail
    --            Angle       => Portion du cercle indiquant la longueur 
    --                           du rail
    --            Orientation => Direction de la courbure de la section
    --                           avec comme reference l'entree de la
    --                           section
    --
    -- Retour   : Un pointeur sur l'instance de l'objet cree
    --
    ----------------------------------------------------------------------
    function New_Section_Courbe(Numero: T_Section_Id;
                                Connections:T_Connections;
                                Angle: Float; Rayon: Float;
                                Orientation: T_Orientation ) return T_Section_Courbe_Ptr;
    
   -----------------------------------------------------------------------
   --
   -- Procedure: Placer
   -- But      : Procedure qui determine la position d'une section dans
   --            le plan et qui affecte cette position a la section.
   --
   --            Procedure appellee un fois a l'initialisation du
   --            simulateur
   --
   -- Entree   : Point     => Le point dans le plan ou sera place 
   --                         l'entree ou une sortie de la section.
   --            Vecteur   => La direction dans laquelle va la section
   --                         depuis le point
   --            Preced    => L'identificateur de la section qui a
   --                         determine le point et le vecteur et qui 
   --                         sert a savoir quel entree ou sortie de la
   --                         section a placer sera sur ce point
   -- Entree &
   -- Sortie    : Section E=> La section a placer dans le plan      
   --                     S=> La section placee dans le plan
   --
   -- Sorties   : Suivant  => Un tableau contenant les informations
   --                         pour placer les sections connectee a la
   --                         section que l'on vient de placer
   --
   -----------------------------------------------------------------------                                                        
    procedure Placer(Section: in out T_Section_Courbe; 
                     Point: in T_Point; Vecteur: in T_Vecteur;
                     Preced: in T_Section_Id; 
                     Suivant : out T_Section_A_placer );
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Paint
    -- But      : Procedure qui affiche la section                                                                                    
    --            dans une fenetre graphique opengl selon son
    --            emplacement dans le plan
    --
    -- Entrees  : Section    => Objet section que l'on desir dessiner
    --
    ----------------------------------------------------------------------
    procedure Paint (Section: in T_Section_Courbe);
    
    ----------------------------------------------------------------------
    --
    -- Fonction: Positiondansplan
    -- But     : Fournit une position precise dans le plan (valeur X,
    --           et valeur Y) a partir d'un position determinee par
    --           une section et par une position dans cette section
    --           qui est un valeur exprimant la distance entre le
    --           point chercher et une extremite de la section,
    --           
    -- Entree  : Section     => Objet section sur lequel se touve la
    --                          position cherchee
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           Posdanssection
    --                       => Distance entre l'extremite de la section
    --                          determinee par "Entree" et le point 
    --                          de la section dont on desir les
    --                          coordonnee
    --
    -- Retour  : La position recherchee 
    --
    ----------------------------------------------------------------------               
    function Positiondansplan(Section : in  T_Section_Courbe;
                              Entree: in T_Connection_Id;                   
                              Posdanssection: in T_Position) 
                              return T_Point;
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondanssection
    -- But      : Indiquer si la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) est plus grande que la section et de combien
    --                          
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          a savoir si le position dans la section
    --                          et trop grande
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           
    -- Entrees &          
    -- Sorties : Posdanssection           
    --                    E  => Distance entre l'extremite de la Section
    --                          determinee par "Entree" et un point 
    --                          precis sur la section 
    --                    S  => Meme distance si elle ne depasse pas 
    --                          la longueur de la section ou distance
    --                          dans la section suivante si elle depasse
    --                          (distance - longueur section = distance
    --                          dans la suivante)
    --
    -- Sortie : Dehors       => Indique si on est toujours dans la section
    --                          ou pas (True => hors de la section
    --                                  False => dans la section
    --
    ----------------------------------------------------------------------                           
    procedure Positiondanssection (Section : in T_Section_Courbe;
                                   Entree: in  T_Connection_Id;
                                   Posdanssection: in out T_Position;
                                   Dehors: out Boolean);
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondepuissortie
    -- But      : Indiquer la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) depuis l'extremite oposee a celle utilisee
    --            utilisee pour definir cette position en entree.
    --
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          la position dans la section depuis
    --                          l'extremite oposee a celle definie dans
    --                          "entree"     
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie 
    --           Posdepuientree
    --                       => Position dans la section depuis 
    --                          l'extremite definie par "entree"
    -- 
    -- Retour  : La position dans la section depuis l'extremite
    --           oposee a celle qui sert de reference pour indiquer
    --           la position en entree
    --
    ----------------------------------------------------------------------                                                          
    function Positiondepuissortie(Section: in T_Section_Courbe; 
                                  Entree: in T_Connection_Id;
                                  Posdepuisentree: in T_Position) 
                                  return T_Position ; 
                                                                                                         
-- =======================================================================
-- Type pour une section de fin de voie.
-- ======================================================================= 
                                  
                                  -- Type d'un objet fin de voie 
                                  -- qui est dans la classe de
                                  -- derivation de T_Section_Generic
    type T_Section_Fin_De_Voie is new T_Section_Generic with private;
       
                                  -- Type pointeur dur un objet
                                  -- fin de voie
    type T_Section_Fin_De_Voie_Ptr is access T_Section_Fin_De_Voie;
    
    ----------------------------------------------------------------------   
    -- Les primitives d'une section fin de voie.
    ----------------------------------------------------------------------
    
    ----------------------------------------------------------------------
    --
    -- Fonction : New_Section_Fin_de_Voie
    -- But      : Fonction qui cree une instance de l'objet fin de voie  
    --            et retourne le pointeur sur celui-ci
    -- 
    -- Entree   : Numero      => Le numero de la section
    --            Connections => Un tableau de connection indiquant les
    --                           section connectee a la section que l'on
    --                           construit
    --            Longueur    => Longueur de la section
    --
    -- Retour   : Un pointeur sur l'instance de l'objet cree
    --
    ----------------------------------------------------------------------
    function New_Section_Fin_De_Voie(Numero: T_Section_Id; 
                                  Connections:T_Connections;
                                  Longueur: Float) 
                                  return T_Section_Fin_De_Voie_Ptr;

   -----------------------------------------------------------------------
   --
   -- Fonction : Prendresortie
   -- But      : Fonction qui determine la section suivante                                  
	 --            a partir d'une section et de l'entree sur la section.
	 -- 
   -- Entree  : Section     => Objet section sur lequel on cherche
   --                          la sortie
   --           Entree      => Index du tableau de connection de la
   --                          section indiquant l'extremite qui fait
   --                          office d'entree
   -- 
   -- Retour  : Index du tableau de connection qui sera la sortie                                                       
	 -- 
   -----------------------------------------------------------------------                                              
   function Prendresortie(Section: in T_Section_Fin_De_Voie;
							Entree: in T_Connection_Id) return T_Connection_Id;

   -----------------------------------------------------------------------
   --
   -- Procedure: Placer
   -- But      : Procedure qui determine la position d'une section dans
   --            le plan et qui affecte cette position a la section.
   --
   --            Procedure appellee un fois a l'initialisation du
   --            simulateur
   --
   -- Entree   : Point     => Le point dans le plan ou sera place 
   --                         l'entree ou une sortie de la section.
   --            Vecteur   => La direction dans laquelle va la section
   --                         depuis le point
   --            Preced    => L'identificateur de la section qui a
   --                         determine le point et le vecteur et qui 
   --                         sert a savoir quel entree ou sortie de la
   --                         section a placer sera sur ce point
   -- Entree &
   -- Sortie    : Section E=> La section a placer dans le plan      
   --                     S=> La section placee dans le plan
   --
   -- Sorties   : Suivant  => Un tableau contenant les informations
   --                         pour placer les sections connectee a la
   --                         section que l'on vient de placer
   --
   -----------------------------------------------------------------------                 
   procedure Placer(Section: in out T_Section_Fin_De_Voie; 
                     Point: in T_Point; Vecteur: in T_Vecteur;
                     Preced: in T_Section_Id; 
                     Suivant : out T_Section_A_placer );
                                             
    ----------------------------------------------------------------------
    --
    -- Procedure: Paint
    -- But      : Procedure qui affiche la section                                                                                    
    --            dans une fenetre graphique opengl selon son
    --            emplacement dans le plan
    --
    -- Entrees  : Section    => Objet section que l'on desir dessiner
    --
    ----------------------------------------------------------------------
    procedure Paint (Section: in T_Section_Fin_De_Voie);
    
    ----------------------------------------------------------------------
    --
    -- Fonction: Positiondansplan
    -- But     : Fournit une position precise dans le plan (valeur X,
    --           et valeur Y) a partir d'un position determinee par
    --           une section et par une position dans cette section
    --           qui est un valeur exprimant la distance entre le
    --           point chercher et une extremite de la section,
    --           
    -- Entree  : Section     => Objet section sur lequel se touve la
    --                          position cherchee
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           Posdanssection
    --                       => Distance entre l'extremite de la section
    --                          determinee par "Entree" et le point 
    --                          de la section dont on desir les
    --                          coordonnee
    --
    -- Retour  : La position recherchee 
    --
    ----------------------------------------------------------------------       
    function Positiondansplan(Section : in  T_Section_Fin_De_Voie;
                              Entree: in T_Connection_Id;                   
                              Posdanssection: in T_Position) 
                              return T_Point;
                              
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondanssection
    -- But      : Indiquer si la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) est plus grande que la section et de combien
    --                          
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          a savoir si le position dans la section
    --                          et trop grande
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           
    -- Entrees &          
    -- Sorties : Posdanssection           
    --                    E  => Distance entre l'extremite de la Section
    --                          determinee par "Entree" et un point 
    --                          precis sur la section 
    --                    S  => Meme distance si elle ne depasse pas 
    --                          la longueur de la section ou distance
    --                          dans la section suivante si elle depasse
    --                          (distance - longueur section = distance
    --                          dans la suivante)
    --
    -- Sortie : Dehors       => Indique si on est toujours dans la section
    --                          ou pas (True => hors de la section
    --                                  False => dans la section
    --
    ----------------------------------------------------------------------                           
    procedure Positiondanssection (Section : in T_Section_Fin_De_Voie;
                                   Entree: in  T_Connection_Id;
                                   Posdanssection: in out T_Position;
                                   Dehors: out Boolean);                  
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondepuissortie
    -- But      : Indiquer la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) depuis l'extremite oposee a celle utilisee
    --            utilisee pour definir cette position en entree.
    --
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          la position dans la section depuis
    --                          l'extremite oposee a celle definie dans
    --                          "entree"     
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie 
    --           Posdepuientree
    --                       => Position dans la section depuis 
    --                          l'extremite definie par "entree"
    -- 
    -- Retour  : La position dans la section depuis l'extremite
    --           oposee a celle qui sert de reference pour indiquer
    --           la position en entree
    --
    ----------------------------------------------------------------------                   
    function Positiondepuissortie(Section: in T_Section_Fin_De_Voie; 
                                  Entree: in T_Connection_Id;
                                  Posdepuisentree: in T_Position) 
                                  return T_Position ;
                                                                                                                 
-- =======================================================================
-- Type pour une section de croisement.
-- ======================================================================= 
     
                                  -- Type d'un objet voie croisement 
                                  -- qui est dans la classe de
                                  -- derivation de T_Section_Generic
    type T_Section_Croix is new T_Section_Generic with private;
     
                                  -- Type pointeur sur un objet
                                  -- voie croisement
    type T_Section_Croix_Ptr is access T_Section_Croix;
       
    ---------------------------------------------------------------------------    
    -- Les primitives d'une section croisement.
    --------------------------------------------------------------------------- 
    
    ----------------------------------------------------------------------
    --
    -- Fonction : New_Section_Croix
    -- But      : Fonction qui cree une instance de l'objet voie   
    --            croisement et retourne le pointeur sur celui-ci
    -- 
    -- Entree   : Numero      => Le numero de la section
    --            Connections => Un tableau de connection indiquant les
    --                           section connectee a la section que l'on
    --                           construit
    --            Angle       => Angle de croisement entre les deux rails
    --            Longueur    => Longueur de la traversee direct de la
    --                           section
    --
    -- Retour   : Un pointeur sur l'instance de l'objet cree
    --
    ----------------------------------------------------------------------
    function New_Section_Croix(Numero: T_Section_Id; 
                               Connections:T_Connections;
                               Angle: Float;
                               Longueur: Float) 
                               return T_Section_Croix_Ptr;
                                   
   -----------------------------------------------------------------------
   --
   -- Fonction : Prendresortie
   -- But      : Fonction qui determine la section suivante                                  
	 --            a partir d'une section et de l'entree sur la section.
	 -- 
   -- Entree  : Section     => Objet section sur lequel on cherche
   --                          la sortie
   --           Entree      => Index du tableau de connection de la
   --                          section indiquant l'extremite qui fait
   --                          office d'entree
   -- 
   -- Retour  : Index du tableau de connection qui sera la sortie                                                       
	 -- 
   -----------------------------------------------------------------------
	 function Prendresortie(Section: in T_Section_Croix;
							Entree: in T_Connection_Id) return T_Connection_Id;

   -----------------------------------------------------------------------
   --
   -- Procedure: Placer
   -- But      : Procedure qui determine la position d'une section dans
   --            le plan et qui affecte cette position a la section.
   --
   --            Procedure appellee un fois a l'initialisation du
   --            simulateur
   --
   -- Entree   : Point     => Le point dans le plan ou sera place 
   --                         l'entree ou une sortie de la section.
   --            Vecteur   => La direction dans laquelle va la section
   --                         depuis le point
   --            Preced    => L'identificateur de la section qui a
   --                         determine le point et le vecteur et qui 
   --                         sert a savoir quel entree ou sortie de la
   --                         section a placer sera sur ce point
   -- Entree &
   -- Sortie    : Section E=> La section a placer dans le plan      
   --                     S=> La section placee dans le plan
   --
   -- Sorties   : Suivant  => Un tableau contenant les informations
   --                         pour placer les sections connectee a la
   --                         section que l'on vient de placer
   --
   -----------------------------------------------------------------------                  
   procedure Placer(Section: in out T_Section_Croix; 
                     Point: in T_Point; Vecteur: in T_Vecteur;
                     Preced: in T_Section_Id; 
                     Suivant : out T_Section_A_placer );
                                             
	  ----------------------------------------------------------------------
    --
    -- Procedure: Paint
    -- But      : Procedure qui affiche la section                                                                                    
    --            dans une fenetre graphique opengl selon son
    --            emplacement dans le plan
    --
    -- Entrees  : Section    => Objet section que l'on desir dessiner
    --
    ----------------------------------------------------------------------
    procedure Paint (Section: in T_Section_Croix);
    
    ----------------------------------------------------------------------
    --
    -- Fonction: Positiondansplan
    -- But     : Fournit une position precise dans le plan (valeur X,
    --           et valeur Y) a partir d'un position determinee par
    --           une section et par une position dans cette section
    --           qui est un valeur exprimant la distance entre le
    --           point chercher et une extremite de la section,
    --           
    -- Entree  : Section     => Objet section sur lequel se touve la
    --                          position cherchee
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           Posdanssection
    --                       => Distance entre l'extremite de la section
    --                          determinee par "Entree" et le point 
    --                          de la section dont on desir les
    --                          coordonnee
    --
    -- Retour  : La position recherchee 
    --
    ----------------------------------------------------------------------    
    function Positiondansplan(Section : in  T_Section_Croix;
                              Entree: in T_Connection_Id;                   
                              Posdanssection: in T_Position) 
                              return T_Point;
                              
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondanssection
    -- But      : Indiquer si la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) est plus grande que la section et de combien
    --                          
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          a savoir si le position dans la section
    --                          et trop grande
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           
    -- Entrees &          
    -- Sorties : Posdanssection           
    --                    E  => Distance entre l'extremite de la Section
    --                          determinee par "Entree" et un point 
    --                          precis sur la section 
    --                    S  => Meme distance si elle ne depasse pas 
    --                          la longueur de la section ou distance
    --                          dans la section suivante si elle depasse
    --                          (distance - longueur section = distance
    --                          dans la suivante)
    --
    -- Sortie : Dehors       => Indique si on est toujours dans la section
    --                          ou pas (True => hors de la section
    --                                  False => dans la section
    --
    ----------------------------------------------------------------------                           
    procedure Positiondanssection (Section : in T_Section_Croix;
                                   Entree: in  T_Connection_Id;
                                   Posdanssection: in out T_Position;
                                   Dehors: out Boolean);                     
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondepuissortie
    -- But      : Indiquer la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) depuis l'extremite oposee a celle utilisee
    --            utilisee pour definir cette position en entree.
    --
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          la position dans la section depuis
    --                          l'extremite oposee a celle definie dans
    --                          "entree"     
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie 
    --           Posdepuientree
    --                       => Position dans la section depuis 
    --                          l'extremite definie par "entree"
    -- 
    -- Retour  : La position dans la section depuis l'extremite
    --           oposee a celle qui sert de reference pour indiquer
    --           la position en entree
    --
    ----------------------------------------------------------------------                   
    function Positiondepuissortie(Section: in T_Section_Croix; 
                                  Entree: in T_Connection_Id;
                                  Posdepuisentree: in T_Position) 
                                  return T_Position ;                                                      
-- =======================================================================
-- Type pour un aiguillage generique
-- =======================================================================   
                                  
                                  -- Type d'un objet aiguillage  
                                  -- elementaire qui est dans la
                                  -- classe de derivation de 
                                  -- T_Section_Generic et qui definit
                                  -- un sous classe de dervation qui
                                  -- contient les informations commune
                                  -- a toute les aiguillages 
	type T_Aiguillage_Generic is abstract new T_Section_Generic with private;
	
                                  -- Type pointeur sur un objet
                                  -- aiguillage elementaire
   type T_Aiguillage_Ptr is access all T_Aiguillage_Generic'Class;
    
   -----------------------------------------------------------------------    
   -- Les primitives d'un aiguillage generique.
   -----------------------------------------------------------------------     
   
   -----------------------------------------------------------------------
   --
   -- Procedure: Diriger
   -- But      : Procedure qui permet de modifier la direction d'un
   --            aiguillage
   --
   -- Entrees  : Direction   => Indique la nouvelle direction que 
   --                           aiguillage va prendre et qui va 
   --                           peut etre modifier son etat
   --            Sousaiguillage  
   --                        => Indique si l'aiguillage est independant
   --                           (Il est dependant que si il s'agit du
   --                           du deuxieme aiguillage d'un aiguillage
   --                           double)
   -- 
   -- Entrees &
   -- Sorties  : Section   E => Objet aiguillage (donc section) 
   --                           dont on desir modifier la direction
   --             
   --                      S => Objet aiguillage dont on a modifier    
   --                           la direction
   --
   -----------------------------------------------------------------------
	procedure Diriger(Section: in out T_Aiguillage_Generic;
					  Direction: in T_Direction;
					  Sousaiguillage: in T_Aiguillage_Type) is abstract;

  
   -----------------------------------------------------------------------
   --
   -- Fonction: Direction
   -- But      : Fonction qui permet de connaitre la direction d'un
   --            aiguillage
   --
   -- Entrees  : Section    => Objet aiguillage (donc section) 
   --                          dont on desir connaitre la direction
   --         
   --      
   --            Sousaiguillage  
   --                        => Indique si l'aiguillage est independant
   --                           (Il est dependant que si il s'agit du
   --                           du deuxieme aiguillage d'un aiguillage
   --                           double)
   -- 
   -- 
   -- Retour  :              => Indique la  direction de 
   --                           aiguillage selon son etat actuel
   --
   -----------------------------------------------------------------------            
   function Direction(Section: in T_Aiguillage_Generic;
					   Sousaiguillage: in T_Aiguillage_Type)
             return T_Direction is abstract; 
             
                     
-- =======================================================================
-- Type pour un aiguillage simple.
-- =======================================================================  
                 
                                  -- Type d'un objet aiguillage  
                                  -- simple qui est dans la
                                  -- classe de derivation de 
                                  -- T_Section_Generic et dans celle
                                  -- T_Aiguillage_Generic
    type T_Aiguillage_Simple is abstract 
       new T_Aiguillage_Generic with private;
    
   ----------------------------------------------------------------------    
   -- Les primitives d'un aiguillage simple
   ----------------------------------------------------------------------
       
   -----------------------------------------------------------------------
   --
   -- Procedure: Diriger
   -- But      : Procedure qui permet de modifier la direction d'un
   --            aiguillage
   --
   -- Entrees  : Direction   => Indique la nouvelle direction que 
   --                           aiguillage va prendre et qui va 
   --                           peut etre modifier son etat
   --            Sousaiguillage  
   --                        => Indique si l'aiguillage est independant
   --                           (Il est dependant que si il s'agit du
   --                           du deuxieme aiguillage d'un aiguillage
   --                           double)
   -- 
   -- Entrees &
   -- Sorties  : Section   E => Objet aiguillage (donc section) 
   --                           dont on desir modifier la direction
   --             
   --                      S => Objet aiguillage dont on a modifier    
   --                           la direction
   --
   -----------------------------------------------------------------------   
   procedure Diriger(Section: in out T_Aiguillage_Simple;
					  Direction: in T_Direction;
					  Sousaiguillage: in T_Aiguillage_Type);

   -----------------------------------------------------------------------
   --
   -- Fonction : Direction
   -- But      : Fonction qui permet de connaitre la direction d'un
   --            aiguillage
   --
   -- Entrees  : Section    => Objet aiguillage (donc section) 
   --                          dont on desir connaitre la direction
   --         
   --      
   --            Sousaiguillage  
   --                        => Indique si l'aiguillage est independant
   --                           (Il est dependant que si il s'agit du
   --                           du deuxieme aiguillage d'un aiguillage
   --                           double)
   -- 
   -- 
   -- Retour  :              => Indique la  direction de 
   --                           aiguillage selon son etat actuel
   --
   -----------------------------------------------------------------------            
   function Direction(Section: in T_Aiguillage_Simple;
					  Sousaiguillage: in T_Aiguillage_Type)
            return T_Direction;  
                     
   -----------------------------------------------------------------------
   --
   -- Fonction : Prendresortie
   -- But      : Fonction qui determine la section suivante                                  
	 --            a partir d'une section et de l'entree sur la section.
	 -- 
   -- Entree  : Section     => Objet section sur lequel on cherche
   --                          la sortie
   --           Entree      => Index du tableau de connection de la
   --                          section indiquant l'extremite qui fait
   --                          office d'entree
   -- 
   -- Retour  : Index du tableau de connection qui sera la sortie                                                       
	 -- 
   -----------------------------------------------------------------------
	 function Prendresortie(Section: in T_Aiguillage_Simple;
							Entree: in T_Connection_Id) return T_Connection_Id;                  
                            
-- =======================================================================
-- Type pour un aiguillage simple droit.
-- =======================================================================
                     
                                  -- Type d'un objet aiguillage  
                                  -- simple droit qui est dans la
                                  -- classe de derivation de 
                                  -- T_Section_Generic et dans celle
                                  -- T_Aiguillage_Generic
    type T_Aiguillage_Simple_Droit is new T_Aiguillage_Simple with private;
     
                                  -- Type pointeur sur un objet
                                  -- aiguillage simple droit
    type T_Aiguillage_Simple_Droit_Ptr is access T_Aiguillage_Simple_Droit;
    
    ---------------------------------------------------------------------------    
    -- Les primitives d'un aiguillage simple droit.
    ---------------------------------------------------------------------------
    
    ----------------------------------------------------------------------
    --
    -- Fonction : New_Aiguillage_simple_droit
    -- But      : Fonction qui cree une instance de l'objet aiguillage  
    --            simple droit et retourne le pointeur sur celui-ci
    -- 
    -- Entree   : Numero      => Le numero de la section
    --            Connections => Un tableau de connection indiquant les
    --                           section connectee a la section que l'on
    --                           construit
    --            Rayon       => Rayon du cercle realise par le rail devie
    --            Angle       => Portion du cercle indiquant la longueur 
    --                           du rail devie
    --            Orientation => Direction de la courbure du rail devie
    --                           avec comme reference l'entree de la
    --                           section
    --            Longueur    => Longueur de la traversee direct
    --
    -- Retour   : Un pointeur sur l'instance de l'objet cree
    --
    ----------------------------------------------------------------------
    function New_Aiguillage_Simple_Droit(Numero: T_Section_Id; 
                               Connections:T_Connections;
                               Angle: Float;
                               Rayon: Float;
                               Orientation: T_Orientation;
                               Longueur: Float) 
                               return T_Aiguillage_Simple_Droit_Ptr;
           
    
	 -----------------------------------------------------------------------
   --
   -- Procedure: Placer
   -- But      : Procedure qui determine la position d'une section dans
   --            le plan et qui affecte cette position a la section.
   --
   --            Procedure appellee un fois a l'initialisation du
   --            simulateur
   --
   -- Entree   : Point     => Le point dans le plan ou sera place 
   --                         l'entree ou une sortie de la section.
   --            Vecteur   => La direction dans laquelle va la section
   --                         depuis le point
   --            Preced    => L'identificateur de la section qui a
   --                         determine le point et le vecteur et qui 
   --                         sert a savoir quel entree ou sortie de la
   --                         section a placer sera sur ce point
   -- Entree &
   -- Sortie    : Section E=> La section a placer dans le plan      
   --                     S=> La section placee dans le plan
   --
   -- Sorties   : Suivant  => Un tableau contenant les informations
   --                         pour placer les sections connectee a la
   --                         section que l'on vient de placer
   --
   -----------------------------------------------------------------------
   procedure Placer(Section: in out T_Aiguillage_Simple_Droit; 
                     Point: in T_Point; Vecteur: in T_Vecteur;
                     Preced: in T_Section_Id; 
                     Suivant : out T_Section_A_placer );
                     
    ----------------------------------------------------------------------
    --
    -- Procedure: Paint
    -- But      : Procedure qui affiche la section                                                                                    
    --            dans une fenetre graphique opengl selon son
    --            emplacement dans le plan
    --
    -- Entrees  : Section    => Objet section que l'on desir dessiner
    --
    ----------------------------------------------------------------------
    procedure Paint (Section: in T_Aiguillage_Simple_Droit);
    
    ----------------------------------------------------------------------
    --
    -- Fonction: Positiondansplan
    -- But     : Fournit une position precise dans le plan (valeur X,
    --           et valeur Y) a partir d'un position determinee par
    --           une section et par une position dans cette section
    --           qui est un valeur exprimant la distance entre le
    --           point chercher et une extremite de la section,
    --           
    -- Entree  : Section     => Objet section sur lequel se touve la
    --                          position cherchee
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           Posdanssection
    --                       => Distance entre l'extremite de la section
    --                          determinee par "Entree" et le point 
    --                          de la section dont on desir les
    --                          coordonnee
    --
    -- Retour  : La position recherchee 
    --
    ----------------------------------------------------------------------                     
    function Positiondansplan(Section : in  T_Aiguillage_Simple_Droit;
                              Entree: in T_Connection_Id;                   
                              Posdanssection: in T_Position) 
                              return T_Point;
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondanssection
    -- But      : Indiquer si la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) est plus grande que la section et de combien
    --                          
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          a savoir si le position dans la section
    --                          et trop grande
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           
    -- Entrees &          
    -- Sorties : Posdanssection           
    --                    E  => Distance entre l'extremite de la Section
    --                          determinee par "Entree" et un point 
    --                          precis sur la section 
    --                    S  => Meme distance si elle ne depasse pas 
    --                          la longueur de la section ou distance
    --                          dans la section suivante si elle depasse
    --                          (distance - longueur section = distance
    --                          dans la suivante)
    --
    -- Sortie : Dehors       => Indique si on est toujours dans la section
    --                          ou pas (True => hors de la section
    --                                  False => dans la section
    --
    ----------------------------------------------------------------------                                                     
    procedure Positiondanssection (Section : in T_Aiguillage_Simple_Droit;
                                   Entree: in  T_Connection_Id;
                                   Posdanssection: in out T_Position;
                                   Dehors: out Boolean);                     
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondepuissortie
    -- But      : Indiquer la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) depuis l'extremite oposee a celle utilisee
    --            utilisee pour definir cette position en entree.
    --
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          la position dans la section depuis
    --                          l'extremite oposee a celle definie dans
    --                          "entree"     
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie 
    --           Posdepuientree
    --                       => Position dans la section depuis 
    --                          l'extremite definie par "entree"
    -- 
    -- Retour  : La position dans la section depuis l'extremite
    --           oposee a celle qui sert de reference pour indiquer
    --           la position en entree
    --
    ----------------------------------------------------------------------                                  
    function Positiondepuissortie(Section: in T_Aiguillage_Simple_Droit; 
                                  Entree: in T_Connection_Id;
                                  Posdepuisentree: in T_Position) 
                                  return T_Position ;                                                        
-- =======================================================================
-- Type pour unaiguillage simple courbe.
-- ======================================================================= 
                    
                                  -- Type d'un objet aiguillage  
                                  -- simple courbe qui est dans la
                                  -- classe de derivation de 
                                  -- T_Section_Generic et dans celle
                                  -- T_Aiguillage_Generic
    type T_Aiguillage_Simple_Courbe is new T_Aiguillage_Simple with private;
    
                                  -- Type pointeur sur un objet
                                  -- aiguillage simple courbe
    type T_Aiguillage_Simple_Courbe_Ptr is access T_Aiguillage_Simple_Courbe;
    
    ---------------------------------------------------------------------------    
    -- Les primitives d'un aiguillage simple courbe.
    ---------------------------------------------------------------------------
    
    ----------------------------------------------------------------------
    --
    -- Fonction : New_Aiguillage_simple_courbe
    -- But      : Fonction qui cree une instance de l'objet aiguillage  
    --            simple courbe et retourne le pointeur sur celui-ci
    -- 
    -- Entree   : Numero      => Le numero de la section
    --            Connections => Un tableau de connection indiquant les
    --                           section connectee a la section que l'on
    --                           construit
    --            Rayon       => Rayon du cercle realise par les rails 
    --            Angle       => Portion du cercle indiquant la longueur 
    --                           des rails 
    --            Orientation => Direction de la courbure des rails
    --                           avec comme reference l'entree de la
    --                           section
    --            Decalage    => Longueur du decalage entre le depart du
    --                           rail exterieur par rapport a l'interieur
    --
    -- Retour   : Un pointeur sur l'instance de l'objet cree
    --
    ----------------------------------------------------------------------
    function New_Aiguillage_Simple_Courbe(Numero: T_Section_Id; 
                               Connections:T_Connections;
                               Angle: Float;
                               Rayon: Float;
                               Orientation: T_Orientation;
                               Decalage: Float) 
                               return T_Aiguillage_Simple_Courbe_Ptr;
   
   -----------------------------------------------------------------------
   --
   -- Procedure: Placer
   -- But      : Procedure qui determine la position d'une section dans
   --            le plan et qui affecte cette position a la section.
   --
   --            Procedure appellee un fois a l'initialisation du
   --            simulateur
   --
   -- Entree   : Point     => Le point dans le plan ou sera place 
   --                         l'entree ou une sortie de la section.
   --            Vecteur   => La direction dans laquelle va la section
   --                         depuis le point
   --            Preced    => L'identificateur de la section qui a
   --                         determine le point et le vecteur et qui 
   --                         sert a savoir quel entree ou sortie de la
   --                         section a placer sera sur ce point
   -- Entree &
   -- Sortie    : Section E=> La section a placer dans le plan      
   --                     S=> La section placee dans le plan
   --
   -- Sorties   : Suivant  => Un tableau contenant les informations
   --                         pour placer les sections connectee a la
   --                         section que l'on vient de placer
   --
   -----------------------------------------------------------------------                             
   procedure Placer(Section: in out T_Aiguillage_Simple_Courbe; 
                     Point: in T_Point; Vecteur: in T_Vecteur;
                     Preced: in T_Section_Id;
                     Suivant : out T_Section_A_placer );
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Paint
    -- But      : Procedure qui affiche la section                                                                                    
    --            dans une fenetre graphique opengl selon son
    --            emplacement dans le plan
    --
    -- Entrees  : Section    => Objet section que l'on desir dessiner
    --
    ----------------------------------------------------------------------
    procedure Paint (Section: in T_Aiguillage_Simple_Courbe);                    
    
    ----------------------------------------------------------------------
    --
    -- Fonction: Positiondansplan
    -- But     : Fournit une position precise dans le plan (valeur X,
    --           et valeur Y) a partir d'un position determinee par
    --           une section et par une position dans cette section
    --           qui est un valeur exprimant la distance entre le
    --           point chercher et une extremite de la section,
    --           
    -- Entree  : Section     => Objet section sur lequel se touve la
    --                          position cherchee
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           Posdanssection
    --                       => Distance entre l'extremite de la section
    --                          determinee par "Entree" et le point 
    --                          de la section dont on desir les
    --                          coordonnee
    --
    -- Retour  : La position recherchee 
    --
    ----------------------------------------------------------------------                   
    function Positiondansplan(Section : in  T_Aiguillage_Simple_Courbe;
                              Entree: in T_Connection_Id;                   
                              Posdanssection: in T_Position) 
                              return T_Point;
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondanssection
    -- But      : Indiquer si la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) est plus grande que la section et de combien
    --                          
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          a savoir si le position dans la section
    --                          et trop grande
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           
    -- Entrees &          
    -- Sorties : Posdanssection           
    --                    E  => Distance entre l'extremite de la Section
    --                          determinee par "Entree" et un point 
    --                          precis sur la section 
    --                    S  => Meme distance si elle ne depasse pas 
    --                          la longueur de la section ou distance
    --                          dans la section suivante si elle depasse
    --                          (distance - longueur section = distance
    --                          dans la suivante)
    --
    -- Sortie : Dehors       => Indique si on est toujours dans la section
    --                          ou pas (True => hors de la section
    --                                  False => dans la section
    --
    ----------------------------------------------------------------------                                                     
    procedure Positiondanssection (Section : in T_Aiguillage_Simple_Courbe;
                                   Entree: in  T_Connection_Id;
                                   Posdanssection: in out T_Position;
                                   Dehors: out Boolean);  
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondepuissortie
    -- But      : Indiquer la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) depuis l'extremite oposee a celle utilisee
    --            utilisee pour definir cette position en entree.
    --
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          la position dans la section depuis
    --                          l'extremite oposee a celle definie dans
    --                          "entree"     
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie 
    --           Posdepuientree
    --                       => Position dans la section depuis 
    --                          l'extremite definie par "entree"
    -- 
    -- Retour  : La position dans la section depuis l'extremite
    --           oposee a celle qui sert de reference pour indiquer
    --           la position en entree
    --
    ----------------------------------------------------------------------                                                 
    function Positiondepuissortie(Section: in T_Aiguillage_Simple_Courbe; 
                                  Entree: in T_Connection_Id;
                                  Posdepuisentree: in T_Position) 
                                  return T_Position ;  
                                                                                                         
-- =======================================================================
-- Type pour un aiguillage double.
-- =======================================================================    
                                  
                                  -- Type d'un objet aiguillage  
                                  -- double qui est dans la
                                  -- classe de derivation de 
                                  -- T_Section_Generic et dans celle
                                  -- T_Aiguillage_Generic
    type T_Aiguillage_Double is new T_Aiguillage_Generic with private;
       
                                  -- Type pointeur sur un objet
                                  -- aiguillage double
    type T_Aiguillage_Double_Ptr is access T_Aiguillage_Double;
    
    ---------------------------------------------------------------------------    
    -- Les primitives d'un aiguillage double.
    ---------------------------------------------------------------------------
    
    ----------------------------------------------------------------------
    --
    -- Fonction : New_Aiguillage_double
    -- But      : Fonction qui cree une instance de l'objet aiguillage  
    --            double et retourne le pointeur sur celui-ci
    -- 
    -- Entree   : Numero      => Le numero de la section
    --            Connections => Un tableau de connection indiquant les
    --                           section connectee a la section que l'on
    --                           construit
    --            Rayon       => Rayon du cercle realise par les rails 
    --                           devies
    --            Angle       => Portion du cercle indiquant la longueur 
    --                           des rails devies
    --            Orientation => Direction de la courbure des rails devies
    --                           avec comme reference l'entree de la
    --                           section
    --            Longueur    => Longueurde la traversee direct
    --                           
    --
    -- Retour   : Un pointeur sur l'instance de l'objet cree
    --
    ----------------------------------------------------------------------
    function New_Aiguillage_Double(Numero: T_Section_Id; 
                               Connections:T_Connections;
                               Angle: Float;
                               Rayon: Float;
                               Longueur: Float) 
                               return T_Aiguillage_Double_Ptr;
                               
   -----------------------------------------------------------------------
   --
   -- Procedure: Diriger
   -- But      : Procedure qui permet de modifier la direction d'un
   --            aiguillage
   --
   -- Entrees  : Direction   => Indique la nouvelle direction que 
   --                           aiguillage va prendre et qui va 
   --                           peut etre modifier son etat
   --            Sousaiguillage  
   --                        => Indique si l'aiguillage est independant
   --                           (Il est dependant que si il s'agit du
   --                           du deuxieme aiguillage d'un aiguillage
   --                           double)
   -- 
   -- Entrees &
   -- Sorties  : Section   E => Objet aiguillage (donc section) 
   --                           dont on desir modifier la direction
   --             
   --                      S => Objet aiguillage dont on a modifier    
   --                           la direction
   --
   -----------------------------------------------------------------------
	procedure Diriger(Section: in out T_Aiguillage_Double;
					  Direction: in T_Direction;
					  Sousaiguillage: in T_Aiguillage_Type);

   -----------------------------------------------------------------------
   --
   -- Fonction: Direction
   -- But      : Fonction qui permet de connaitre la direction d'un
   --            aiguillage
   --
   -- Entrees  : Section    => Objet aiguillage (donc section) 
   --                          dont on desir connaitre la direction
   --         
   --      
   --            Sousaiguillage  
   --                        => Indique si l'aiguillage est independant
   --                           (Il est dependant que si il s'agit du
   --                           du deuxieme aiguillage d'un aiguillage
   --                           double)
   -- 
   -- 
   -- Retour  :              => Indique la  direction de 
   --                           aiguillage selon son etat actuel
   --
   -----------------------------------------------------------------------            
   function Direction(Section: in T_Aiguillage_Double;
					   Sousaiguillage: in T_Aiguillage_Type)
             return T_Direction;      
                  
   -----------------------------------------------------------------------
   --
   -- Fonction : Prendresortie
   -- But      : Fonction qui determine la section suivante                                  
	 --            a partir d'une section et de l'entree sur la section.
	 -- 
   -- Entree  : Section     => Objet section sur lequel on cherche
   --                          la sortie
   --           Entree      => Index du tableau de connection de la
   --                          section indiquant l'extremite qui fait
   --                          office d'entree
   -- 
   -- Retour  : Index du tableau de connection qui sera la sortie                                                       
	 -- 
   -----------------------------------------------------------------------
	function Prendresortie(Section: in T_Aiguillage_Double;
							Entree: in T_Connection_Id) return T_Connection_Id;

	
   -----------------------------------------------------------------------
   --
   -- Procedure: Placer
   -- But      : Procedure qui determine la position d'une section dans
   --            le plan et qui affecte cette position a la section.
   --
   --            Procedure appellee un fois a l'initialisation du
   --            simulateur
   --
   -- Entree   : Point     => Le point dans le plan ou sera place 
   --                         l'entree ou une sortie de la section.
   --            Vecteur   => La direction dans laquelle va la section
   --                         depuis le point
   --            Preced    => L'identificateur de la section qui a
   --                         determine le point et le vecteur et qui 
   --                         sert a savoir quel entree ou sortie de la
   --                         section a placer sera sur ce point
   -- Entree &
   -- Sortie    : Section E=> La section a placer dans le plan      
   --                     S=> La section placee dans le plan
   --
   -- Sorties   : Suivant  => Un tableau contenant les informations
   --                         pour placer les sections connectee a la
   --                         section que l'on vient de placer
   --
   ----------------------------------------------------------------------- 
   procedure Placer(Section: in out T_Aiguillage_Double; 
                     Point: in T_Point; Vecteur: in T_Vecteur;
                     Preced: in T_Section_Id;
                     Suivant : out T_Section_A_placer );
                     
    ----------------------------------------------------------------------
    --
    -- Procedure: Paint
    -- But      : Procedure qui affiche la section                                                                                    
    --            dans une fenetre graphique opengl selon son
    --            emplacement dans le plan
    --
    -- Entrees  : Section    => Objet section que l'on desir dessiner
    --
    ----------------------------------------------------------------------
    procedure Paint (Section: in T_Aiguillage_Double);
    
    ----------------------------------------------------------------------
    --
    -- Fonction: Positiondansplan
    -- But     : Fournit une position precise dans le plan (valeur X,
    --           et valeur Y) a partir d'un position determinee par
    --           une section et par une position dans cette section
    --           qui est un valeur exprimant la distance entre le
    --           point chercher et une extremite de la section,
    --           
    -- Entree  : Section     => Objet section sur lequel se touve la
    --                          position cherchee
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           Posdanssection
    --                       => Distance entre l'extremite de la section
    --                          determinee par "Entree" et le point 
    --                          de la section dont on desir les
    --                          coordonnee
    --
    -- Retour  : La position recherchee 
    --
    ----------------------------------------------------------------------
    function Positiondansplan(Section : in T_Aiguillage_Double;
                              Entree: in T_Connection_Id;                   
                              Posdanssection: in T_Position) 
                              return T_Point;
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondanssection
    -- But      : Indiquer si la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) est plus grande que la section et de combien
    --                          
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          a savoir si le position dans la section
    --                          et trop grande
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           
    -- Entrees &          
    -- Sorties : Posdanssection           
    --                    E  => Distance entre l'extremite de la Section
    --                          determinee par "Entree" et un point 
    --                          precis sur la section 
    --                    S  => Meme distance si elle ne depasse pas 
    --                          la longueur de la section ou distance
    --                          dans la section suivante si elle depasse
    --                          (distance - longueur section = distance
    --                          dans la suivante)
    --
    -- Sortie : Dehors       => Indique si on est toujours dans la section
    --                          ou pas (True => hors de la section
    --                                  False => dans la section
    --
    ----------------------------------------------------------------------                                            
    procedure Positiondanssection (Section : in T_Aiguillage_Double;
                                   Entree: in  T_Connection_Id;
                                   Posdanssection: in out T_Position;
                                   Dehors: out Boolean);                     
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondepuissortie
    -- But      : Indiquer la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) depuis l'extremite oposee a celle utilisee
    --            utilisee pour definir cette position en entree.
    --
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          la position dans la section depuis
    --                          l'extremite oposee a celle definie dans
    --                          "entree"     
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie 
    --           Posdepuientree
    --                       => Position dans la section depuis 
    --                          l'extremite definie par "entree"
    -- 
    -- Retour  : La position dans la section depuis l'extremite
    --           oposee a celle qui sert de reference pour indiquer
    --           la position en entree
    --
    ----------------------------------------------------------------------                   
    function Positiondepuissortie(Section: in T_Aiguillage_Double; 
                                  Entree: in T_Connection_Id;
                                  Posdepuisentree: in T_Position) 
                                  return T_Position ;                                                           
-- =======================================================================
-- Type pour un aiguillage croix.
-- =======================================================================  
                                  
                                  -- Type d'un objet aiguillage  
                                  -- croix qui est dans la
                                  -- classe de derivation de 
                                  -- T_Section_Generic et dans celle
                                  -- T_Aiguillage_Generic
    type T_Aiguillage_Croix is new T_Aiguillage_Generic with private;

                                  -- Pointeur sur un objet aiguillage
                                  -- croix
    type T_Aiguillage_Croix_Ptr is access T_Aiguillage_Croix;
    
    ----------------------------------------------------------------------    
    -- Les primitives d'un aiguillage croix.
    ----------------------------------------------------------------------
    
    ----------------------------------------------------------------------
    --
    -- Fonction : New_Aiguillage_Croix
    -- But      : Fonction qui cree une instance de l'objet aiguillage  
    --            croix et retourne le pointeur sur celui-ci
    -- 
    -- Entree   : Numero      => Le numero de la section
    --            Connections => Un tableau de connection indiquant les
    --                           section connectee a la section que l'on
    --                           construit
    --            Angle       => Angle de croisement entre les deux rails
    --            Longueur    => Longueur de la traversee direct de la
    --                           section
    --
    -- Retour   : Un pointeur sur l'instance de l'objet cree
    --
    ----------------------------------------------------------------------
    function New_Aiguillage_Croix(Numero: T_Section_Id; 
                               Connections:T_Connections;
                               Angle: Float;
                               Longueur: Float) 
                               return T_Aiguillage_Croix_Ptr;
                               
   -----------------------------------------------------------------------
   --
   -- Procedure: Diriger
   -- But      : Procedure qui permet de modifier la direction d'un
   --            aiguillage
   --
   -- Entrees  : Direction   => Indique la nouvelle direction que 
   --                           aiguillage va prendre et qui va 
   --                           peut etre modifier son etat
   --            Sousaiguillage  
   --                        => Indique si l'aiguillage est independant
   --                           (Il est dependant que si il s'agit du
   --                           du deuxieme aiguillage d'un aiguillage
   --                           double)
   -- 
   -- Entrees &
   -- Sorties  : Section   E => Objet aiguillage (donc section) 
   --                           dont on desir modifier la direction
   --             
   --                      S => Objet aiguillage dont on a modifier    
   --                           la direction
   --
   -----------------------------------------------------------------------
	 procedure Diriger(Section: in out T_Aiguillage_Croix;
					  Direction: in T_Direction;
					  Sousaiguillage: in T_Aiguillage_Type);

   -----------------------------------------------------------------------
   --
   -- Fonction : Direction
   -- But      : Fonction qui permet de connaitre la direction d'un
   --            aiguillage
   --
   -- Entrees  : Section    => Objet aiguillage (donc section) 
   --                          dont on desir connaitre la direction
   --         
   --      
   --            Sousaiguillage  
   --                        => Indique si l'aiguillage est independant
   --                           (Il est dependant que si il s'agit du
   --                           du deuxieme aiguillage d'un aiguillage
   --                           double)
   -- 
   -- 
   -- Retour  :              => Indique la  direction de 
   --                           aiguillage selon son etat actuel
   --
   -----------------------------------------------------------------------            
   function Direction(Section: in T_Aiguillage_Croix;
					   Sousaiguillage: in T_Aiguillage_Type)
             return T_Direction; 
                      
   -----------------------------------------------------------------------
   --
   -- Fonction : Prendresortie
   -- But      : Fonction qui determine la section suivante                                  
	 --            a partir d'une section et de l'entree sur la section.
	 -- 
   -- Entree  : Section     => Objet section sur lequel on cherche
   --                          la sortie
   --           Entree      => Index du tableau de connection de la
   --                          section indiquant l'extremite qui fait
   --                          office d'entree
   -- 
   -- Retour  : Index du tableau de connection qui sera la sortie                                                       
	 -- 
   -----------------------------------------------------------------------
	 function Prendresortie(Section: in T_Aiguillage_Croix;
						   Entree: in T_Connection_Id) return T_Connection_Id;

	
   -----------------------------------------------------------------------
   --
   -- Procedure: Placer
   -- But      : Procedure qui determine la position d'une section dans
   --            le plan et qui affecte cette position a la section.
   --
   --            Procedure appellee un fois a l'initialisation du
   --            simulateur
   --
   -- Entree   : Point     => Le point dans le plan ou sera place 
   --                         l'entree ou une sortie de la section.
   --            Vecteur   => La direction dans laquelle va la section
   --                         depuis le point
   --            Preced    => L'identificateur de la section qui a
   --                         determine le point et le vecteur et qui 
   --                         sert a savoir quel entree ou sortie de la
   --                         section a placer sera sur ce point
   -- Entree &
   -- Sortie    : Section E=> La section a placer dans le plan      
   --                     S=> La section placee dans le plan
   --
   -- Sorties   : Suivant  => Un tableau contenant les informations
   --                         pour placer les sections connectee a la
   --                         section que l'on vient de placer
   --
   ----------------------------------------------------------------------- 
   procedure Placer(Section: in out T_Aiguillage_Croix; 
                     Point: in T_Point; Vecteur: in T_Vecteur;
                     Preced: in T_Section_Id;
                     Suivant : out T_Section_A_placer );
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Paint
    -- But      : Procedure qui affiche la section                                                                                    
    --            dans une fenetre graphique opengl selon son
    --            emplacement dans le plan
    --
    -- Entrees  : Section    => Objet section que l'on desir dessiner
    --
    ----------------------------------------------------------------------
    procedure Paint (Section: in T_Aiguillage_Croix);
    
    ----------------------------------------------------------------------
    --
    -- Fonction: Positiondansplan
    -- But     : Fournit une position precise dans le plan (valeur X,
    --           et valeur Y) a partir d'un position determinee par
    --           une section et par une position dans cette section
    --           qui est un valeur exprimant la distance entre le
    --           point chercher et une extremite de la section,
    --           
    -- Entree  : Section     => Objet section sur lequel se touve la
    --                          position cherchee
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           Posdanssection
    --                       => Distance entre l'extremite de la section
    --                          determinee par "Entree" et le point 
    --                          de la section dont on desir les
    --                          coordonnee
    --
    -- Retour  : La position recherchee 
    --
    ----------------------------------------------------------------------                                  
    function Positiondansplan(Section : in T_Aiguillage_Croix;
                              Entree: in T_Connection_Id;                   
                              Posdanssection: in T_Position) 
                              return T_Point;
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondanssection
    -- But      : Indiquer si la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) est plus grande que la section et de combien
    --                          
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          a savoir si le position dans la section
    --                          et trop grande
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie
    --           
    -- Entrees &          
    -- Sorties : Posdanssection           
    --                    E  => Distance entre l'extremite de la Section
    --                          determinee par "Entree" et un point 
    --                          precis sur la section 
    --                    S  => Meme distance si elle ne depasse pas 
    --                          la longueur de la section ou distance
    --                          dans la section suivante si elle depasse
    --                          (distance - longueur section = distance
    --                          dans la suivante)
    --
    -- Sortie : Dehors       => Indique si on est toujours dans la section
    --                          ou pas (True => hors de la section
    --                                  False => dans la section
    --
    ----------------------------------------------------------------------                                                     
    procedure Positiondanssection (Section : in  T_Aiguillage_Croix;
                                   Entree: in  T_Connection_Id;
                                   Posdanssection: in out T_Position;
                                   Dehors: out Boolean);                       
    
    
    ----------------------------------------------------------------------
    --
    -- Procedure: Positiondepuissortie
    -- But      : Indiquer la position dans la section (distance entre
    --            une extremite de la section et un point precis dans la
    --            section) depuis l'extremite oposee a celle utilisee
    --            utilisee pour definir cette position en entree.
    --
    -- Entree  : Section     => Objet section sur lequel on cherche
    --                          la position dans la section depuis
    --                          l'extremite oposee a celle definie dans
    --                          "entree"     
    --           Entree      => Indexe du tableau de connection de la
    --                          section indiquant depuis quelle
    --                          extremite de la sections la distance
    --                          "Posdanssection" est definie 
    --           Posdepuientree
    --                       => Position dans la section depuis 
    --                          l'extremite definie par "entree"
    -- 
    -- Retour  : La position dans la section depuis l'extremite
    --           oposee a celle qui sert de reference pour indiquer
    --           la position en entree
    --
    ----------------------------------------------------------------------                                                
    function Positiondepuissortie(Section: in T_Aiguillage_Croix; 
                                  Entree: in T_Connection_Id;
                                  Posdepuisentree: in T_Position) 
                                  return T_Position ; 
                                  
                                  
-- ***********************************************************************
--
-- Sous-programme a l'echelle de classe
--
-- ***********************************************************************
                                               
	 -----------------------------------------------------------------------
   --
	 -- Procedure: PrendreSectionSuivante
	 -- But      : Procedure qui prend la section suivante.
   --            C'est-a-dire qu'elle fournit la section connectee
   --            a section passee en parametre a l'oppose de l'entree
   --            specifiee
   --   
   -- Entree   : Sections      => Ensemble des sections d'une maquette
   --                             (Tableau dont les indexe corresponde
   --                             on numero des sections)         
   -- Entree    
   -- &                            
   -- Sortie   : Section     E => Pointeur sur l'objet section dont on          
	 --                             desir connaitre la section suivante.
   --
   --                        S => Pointeur sur l'objet section suivant
   --
   --            Entree      E => Index du tableau de connection de la
   --                             section indiquant la section d'ou 
   --                             l'on vient (la section suivante sera
   --                             donc a l'oppose)
   --
   --                        S => Index du tableau de connection de la
   --                             section suivante indiquant la section
   --                             precedente
   --
	-----------------------------------------------------------------------   
	procedure Prendresectionsuivante(Section: in out T_Section_Ptr;
							 		 Entree: in out T_Connection_Id;
							 		 Sections: in T_Sections); 
                                      
   -----------------------------------------------------------------------
   --
   -- Procedure: Occuper
   -- But      : Procedure qui specifie la section comme occupee                                
	 -- 
   --            Occuper une section signifie qu'un train est dessus
   --
   -- Entree   : Section     => Pointeur sur l'objet section que
   --                           l'on desir occuper
   --
   -----------------------------------------------------------------------              
	 procedure Occuper(Section: in T_Section_Ptr);
    
   -----------------------------------------------------------------------
   --
   -- Fonction: Estoccuper
   -- But     : Fonction qui indique si une section est occupee
   -- 
   -- Entree  : Section     => Pointeur sur l'objet section dont
   --                           on desir savoir si il est occupe
   --
   -- Retour  : Indication si la section est occupee
   --           (True => est occupee False => est libre
   -----------------------------------------------------------------------
   function Estoccuper(Section: in T_Section_Ptr) return Boolean;
   
   -----------------------------------------------------------------------
   --
   -- Procedure: Liberer
   -- But      : Procedure qui specifie la section comme libre 
	 --            (pas occupee)
   --
   -- Entree   : Section     => Pointeur sur l'objet section que
   --                           l'on desir liberer
   --
   -----------------------------------------------------------------------
	 procedure Liberer(Section: in T_Section_Ptr);
   
   -----------------------------------------------------------------------
   --
   -- Fonction: Numero
   -- But     : Fonction qui indique le numero d'une section
   --
   -- Entree   : Section     => Pointeur sur l'objet section dont
   --                           on desir le numero
   --
   -- Retour   : Le numero identifiant la section
   --
   -----------------------------------------------------------------------
   function Numero(Section : in T_Section_Ptr) return T_Section_Id;
   
   -----------------------------------------------------------------------
   --
   -- Procedure: Mettrecouleur
   -- But      : Affecter un couleur (sera utilise lors de l'affichage)
   --            a une section n'importe laquelle
   -- 
   -- Entree   : Section       => Pointeur sur l'objet section dont on          
	 --                             desir modifier la couleur.
   --           
   --            Couleur       => Couleur dans laquelle on desir peindre
   --                             la section
   --
   -----------------------------------------------------------------------
   procedure Mettrecouleur (Section: in  T_Section_Ptr; 
                            Couleur: in P_Couleur.T_Couleur);
    
-- ***********************************************************************
--
-- Declaration complete des objets
--
-- ***********************************************************************    
    
private
    
                                  -- Type de base de la classe de 
                                  -- derivation contient 
                                  -- les informations commune a toute
                                  -- les sections 
    type T_Section_Generic(Nbrconnections: T_Connection_Id) is abstract 
    tagged record
		                            -- Numero identifiant la section 
                                  -- dans une maquette.
	    Numero: T_Section_Id;
		                            -- Flag indiquant que la section est 
                                  -- occupee par un train.
      Occupe: Boolean;		                   
		                            -- Les section connectee a cette 
                                  -- section
		  Connections: T_Connections(1..Nbrconnections);
       
                                  -- Position dans le plan de la 
                                  -- section
      Point: T_Point;
       
                                  -- Direction dans laquelle va 
                                  -- la section
                                  -- depuis sa position
      Vecteur: T_Vecteur;
                                  -- Indique la couleur de la section
      Couleur: P_Couleur.T_Couleur ;
    end record;
    
                                  -- Type d'un objet pour une
                                  -- voie simple (doite ou courbe)
    type T_Section_Simple is abstract new T_Section_Generic with 
        null record;
    
                                  -- Type d'un objet pour une
                                  -- voie droite
    type T_Section_Droite is new T_Section_Simple with record
       
        Longueur: Float;          -- Longueur du rail
    end record;
    
                                  -- Type d'un objet pour une
                                  -- voie courbe
    type T_Section_Courbe is new T_Section_Simple with record
       
                                  -- Rayon du cercle realise par
        Rayon: Float;             -- le rail 
        
                                  -- Portion du cercle indiquant
        Angle: Float;             -- la longueur du rail
                               
                                  -- Indique si le rail tourne 
                                  -- a droite ou a gauche en allant 
                                  -- de la connexion une a la deux
        Orientation: T_Orientation;  
        
                               
    end record;
    
                                  -- Type d'un objet pour une
                                  -- fin de voie (Heurtoir)
    type T_Section_Fin_De_Voie is new T_Section_Generic with record
       
        Longueur: Float;          -- Longueur du rail
    end record;
    
                                  -- Type d'un objet pour une
                                  -- voie croisement
    type T_Section_Croix is new T_Section_Generic with record
       
        Longueur: Float;          -- Longueur de la traversee direct
        Angle: Float;             -- Angle de croisement des deux rails
    end record;
     
    
                                  -- Type d'un objet aiguillage  
                                  -- elementaire qui est dans la
                                  -- classe de derivation de 
                                  -- T_Section_Generic et qui definit
                                  -- un sous classe de dervation qui
                                  -- contient les informations commune
                                  -- a toute les aiguillages 
    type T_Aiguillage_Generic is abstract new T_Section_Generic with record
       
                                  -- Position dans laquelle
		  Etat: T_Etat := Etat_Droit; -- l'aiguille se trouve     
                                      
    end record;          
    
                                  -- Type d'un objet pour un
                                  -- aiguillage simple (droite ou
                                  -- courbe)
    type T_Aiguillage_Simple is abstract new T_Aiguillage_Generic with 
        null record;
    
                                  -- Type d'un objet pour un
                                  -- aiguillage simple droit 
    type T_Aiguillage_Simple_Droit is new T_Aiguillage_Simple with record
       
        Longueur : Float;         -- Longueur de la traversee direct
        
                                  -- Rayon du cercle realise par la
        Rayon : Float;            -- partie courbe 
                                  
                                  -- Portion du cercle indiquant la
        Angle: Float;             -- longueur de la partie courbe  
                                 
                                  -- Indique si le rail tourne a droite
                                  -- ou a gauche en allant de la 
                                  -- connexion une a la trois
        Orientation: T_Orientation;
                               
                               
    end record;
    
                                  -- Type d'un objet pour un
                                  -- aiguillage simple courbe
    type T_Aiguillage_Simple_Courbe is new T_Aiguillage_Simple with record
       
                                 -- Rayon du cercle realise par les deux 
        Rayon : Float;           -- rails
                               
                                 -- Portion du cercle indiquant la 
        Angle: Float;            -- longueur des deux rails
                            
                                 -- Indique si les rail tournent 
                                 -- a droite ou a gauche en partant 
                                 -- de la connexion une  
        Orientation: T_Orientation; 
        
                               
                                 -- Longueur du decalage entre le depart 
                                 -- du rail exterieur par rapport 
        Decalage: Float;         -- a l'interieur
                              
    end record;
    
                                  -- Type d'un objet pour un
                                  -- aiguillage double
    type T_Aiguillage_Double is new T_Aiguillage_Generic with record
       
        Longueur : Float;         -- Longueur de la traversee directe
        
                                  -- Rayon du cercle realise par les 
        Rayon : Float;            -- deux rails courbes 
                               
                                  -- Portion du cercle indiquant la 
        Angle: Float;             -- longueur des deux rails 
                               
    end record;  
    
                                  -- Type d'un objet pour un
                                  -- aiguillage croix
    type T_Aiguillage_Croix is new T_Aiguillage_Generic with record
       
        Longueur: Float;          -- Longueur de la traversee direct
        
                                  -- Angle de croisement entre
        Angle: Float;             -- les deux rails
    end record;
    
end P_Section;                 -- Fin du paquetage 
