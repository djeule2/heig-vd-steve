--------------------------------------------------------------------------
--
-- Nom du fichier   : Train_Handler.ads
-- Auteur           : Michel MOREROD, eivd
--
-- Date de creation : 6.12.89
-- But              : Fournir l'acces a une maquette de trains
--
-- Modifications    : Ete 97  P. Binggeli et V. Crausaz
-- Raison           : Adaptation pour un simulateur de maquettes
--
-- Modifications    : Decembre 97  P. Girardet
-- Raison           : Ajout d'une interface graphique
--
-- Modifications    : fevrier 98 P. Girardet
-- Raison           : Amélioration et adaptation aux nouvelles maquettes de 
--                    trains
--
-- Modifications    : janvier 99 P. Girardet
-- Raison           : Amélioration
--
-- Modifications    : juillet 99 P. Girardet
-- Raison           : Traduction des messages utilisateurs en anglais
--
-- Modifications    : Decembre 2003 D. Madon
-- Raison           : Connexion au travers des sockets
--
-- Modifications    : Fevrier 2009 K. Georgy
-- Raison           : Export pour utilisation C/C++
--
-- Version          : 4.0
--
-- Modules appeles  :
--
-- Routines exportees : Demander_loco,
--                      Init_maquette,
--                      Mettre_maquette_hors_service,
--                      Mettre_maquette_en_service,
--                      Diriger_aiguillage,
--                      Attendre_contact,
--                      Arreter_Loco
--                      Mettre_vitesse_progressive,
--                      Mettre_fonction_loco,
--                      Inverser_sens_loco,
--                      Mettre_vitesse_loco
--
-- Materiel particulier : PC avec le simulateur, ou un couple de PCs avec
--                        une maquette Marklin
-- Mode d'utilisation   : Voir document "Maquettes Marklin et paquetage
--                        TRAIN_HANDLER" version 1.3, P. Breguet eivd
--------------------------------------------------------------------------
package Train_Handler is

  -- Vitesse du train quand il est arrete
  Vitesse_Nulle   : constant Integer := 0;

  -- Vitesse minimum pour une locomotive
  Vitesse_Minimum : constant Integer := 3;

  -- Vitesse maximum pour une locomotive
  Vitesse_Maximum : constant Integer := 14;

  -- Nombre maximum d'aiguillages
  Max_Aiguillages : constant Integer := 80;

  -- Nombre maximum de contacts
  Max_Contacts    : constant Integer := 64;

  -- Nombre maximum de locomotives
  Max_Locos       : constant Integer := 80;


  -- Pour la direction des aiguillages
  type T_Direction is (Devie, Tout_Droit);
  pragma Convention(C, T_Direction);

  -- Intervalle pour la numerotation des aiguillages
  subtype No_Aiguillage_Type is Integer range 1..Max_Aiguillages;

  -- Intervalle pour la numerotation des contacts
  subtype No_Contact_Type is Integer range 1..Max_Contacts;

  -- Intervalle pour la numerotation des locomotives
  subtype No_Loco_Type is Integer range 0..Max_Locos-1;

  -- Intervalle pour les vitesses possibles des locomotives
  subtype Vitesse_Type is Integer range Vitesse_Nulle..Vitesse_Maximum;


   ---------------------
   --  Init_Maquette  --
   ---------------------

   --  La maquette est initialisee du cote simulateur (serveur).
   --  C'est la partie sockets qui est initialisee ici, profitant du
   --  fait que cette procedure est appelee par le client en debut de
   --  simulation.

   procedure Init_Maquette;
   pragma Export(C, Init_Maquette, "toc_init_maquette");


   ------------------------------------
   --  Mettre_Maquette_Hors_Service  --
   ------------------------------------

   --  On profite de l'appel obligatoire pour couper la connexion avec
   --  le simulateur.

   procedure Mettre_Maquette_Hors_Service;
   pragma Export(C, Mettre_Maquette_Hors_Service, 
                 "toc_mettre_maquette_hors_service");


   ----------------------------------
   --  Mettre_maquette_en_service  --
   ----------------------------------

   --  Cette procedure permet de retablir l'alimentation de la
   --  maquette, donc de reactive toute la maquette. Elle n'a pas
   --  besoin d'etre appelee apres "Init_Maquette"
   --
   --  Comme precedemment, on profite de l'appel pour connecter le
   --  client au simulateur.

   procedure Mettre_Maquette_En_Service;
   pragma Export(C, Mettre_Maquette_En_Service, 
                 "toc_mettre_maquette_en_service");


   --------------------------
   --  Diriger_Aiguillage  --
   --------------------------

   --  Cette procedure permet de changer la direction de l'aiguillage
   --  mentionne
   --
   --  Entrees : No_Aiguillage => Le numero de l'aiguillage.
   --            Direction     => La direction de l'aiguillage
   --                             (Tout_droit ou Devie)
   --
   --            Temps_alim    => Le temps l'alimentation minimal du
   --                             bobinage de l'aiguillage
   --
   --  NB      : Dans le cas d'un aiguillage courbe "Tout_Droit" correspond
   --            a la voie interieure.
   --
   --  Attention :
   --            Si un train se trouve sur l'aiguillage lors que l'on
   --            modifie sa direction, celui-ci va derailler.

   procedure Diriger_Aiguillage
     (No_Aiguillage  : in No_Aiguillage_Type;
      Direction      : in T_Direction;
      Temps_Alim     : in Natural := 0);
   pragma Export(C, Diriger_Aiguillage, "toc_diriger_aiguillage");

   ------------------------
   --  Attendre_Contact  --
   ------------------------

   --  Cette procedure fait attendre (la tache appelante) qu'une
   --  locomotive passe sur le contact transmis en parametre.
   --
   --  Entrees  : No_Contact => Numero du contact dont on attend
   --                           l'activation

   procedure Attendre_Contact (No_Contact: in No_Contact_Type);
   pragma Export(C, Attendre_Contact, "toc_attendre_contact");

   --------------------
   --  Arreter_Loco  --
   --------------------

   --  Cette procedure arrete la locomotive demandee de maniere
   --  immediate
   --
   --  Entrees  : No_loco   => Numero de la locomotive que l'on veut arreter

   procedure Arreter_Loco (No_Loco: in No_Loco_Type);
   pragma Export(C, Arreter_Loco, "toc_arreter_loco");

   ----------------------------------
   --  Mettre_Vitesse_Progressive  --
   ----------------------------------

   --  Cette procedure devrait effectuer un changement progressif de
   --  la vitesse de la locomotive demandee. Cette variation de
   --  vitesse va de la vitesse actuelle a la vitesse passee en
   --  parametre, par palier.
   --
   --  Entrees  : No_loco   => Numero de la locomotive dont on veut faire
   --                          varier la vitesse
   --             Vitesse_Futur =>
   --                          Vitesse que la locomotive aura apres
   --                          le changement de vitesse
   --
   --  Remarque : Dans le simulateur cette procedure agit comme la
   --             fonction "Mettre_Vitesse_Loco". c'est-a-dire que
   --             l'acceleration est immediate( de la vitesse actuelle
   --             a la vitesse specifiee )

   procedure Mettre_Vitesse_Progressive
     (No_Loco        : in No_Loco_Type;
      Vitesse_Future : in Vitesse_Type);
   pragma Export(C, Mettre_Vitesse_Progressive, 
                 "toc_mettre_vitesse_progressive");

   ----------------------------
   --  Mettre_Fonction_Loco  --
   ----------------------------

   --  Cette procedure devrait permettre d'allumer ou d'eteindre les
   --  phares de la locomotive. Pour eteindre les phares "Etat" doit
   --  valoir "False", pour les allumer "Etat" doit valoir "True"
   --
   --  Entrees  : No_loco   => Numero de la locomotive dont on veut
   --                          allumer ou eteindre les phares
   --             Etat      => Indique si l'on effectue un allumage
   --                          "True" ou une extinction.
   --
   --  Remarque : Dans le simulateur cette fonction n'a aucun effet.
   --             Les locomotive representee par des rectangles
   --             possedent une partie jaune indiquant le sens de
   --             deplacement. L'utilisation des phares n'est donc
   --             plus utile.

   procedure Mettre_Fonction_Loco
     (No_Loco : in No_Loco_Type;
      Etat    : in Boolean);
   pragma Export(C, Mettre_Fonction_Loco, "toc_mettre_fonction_loco");


   --------------------------
   --  Inverser_Sens_Loco  --
   --------------------------

   --  Cette procedure permet de changer les sens de marche de la
   --  locomotive. Elle l'arrete si sa vitesse est non nulle, puis la
   --  fait redemarrer dans l'autre sens a la meme vitesse.
   --
   --  Entrees  : No_loco   => Numero de la locomotive dont on veut modifier
   --                          le sens de marche

   procedure Inverser_Sens_Loco (No_Loco: in No_Loco_Type);
   pragma Export(C, Inverser_Sens_Loco, "toc_inverser_sens_loco");

   ---------------------------
   --  Mettre_Vitesse_Loco  --
   ---------------------------

   --  Cette procedure transmet l'ordre a la locomotive de passer a la
   --  vitesse transmise.
   --
   --  Entrees  : No_loco   => Numero de la locomotive dont on veut modifier
   --                          la vitesse
   --             Vitesse   => Vitesse que l'on veut affecter a la locomotive

   procedure Mettre_Vitesse_Loco
     (No_Loco: in No_Loco_Type;
      Vitesse: in Vitesse_Type);
   pragma Export(C, Mettre_Vitesse_Loco, "toc_mettre_vitesse_loco");

   ---------------------
   --  Demander_Loco  --
   ---------------------

   -- But      : Cette procedure demande a l'utilisateur le numero
   --            de la locomotive  qu'il desire utiliser.
   --
   --            Elle demande a l'utilisateur la vitesse a laquelle
   --            il desire actionner la locomotive
   --
   --            Elle place  la locomotive entre deux contacts A et B
   --            donnes par l'appelant.
   --
   --            On suppose l'utilisateur averti et ne commettant
   --            pas d'erreurs
   --
   -- Entrees  : Contact_A => Contact delimitant la zone sur laquelle la
   --                         locomotive sera posee (elle va se diriger
   --                         vers ce contact
   --            Contact_B => Contact delimitant la zone sur laquelle la
   --                         locomotive sera posee
   --
   -- Sorties  : Numero    => Numero de la locomotive qui sera pose a
   --                         l'endroit determine
   --            Vitesse   => Vitesse de la locomotive qui sera pose a
   --                         l'endroit determine
   --
   -- 13.1.92, P. Breguet sur une idee de Conus et Rappaz EI3 91

   procedure Demander_Loco
     (Contact_A : in Train_Handler.No_Contact_Type;
      Contact_B : in Train_Handler.No_Contact_Type;
      Numero    : out Train_Handler.No_Loco_Type;
      Vitesse   : out Train_Handler.Vitesse_Type);
   pragma Export(C, Demander_Loco, "toc_demander_loco");

private

   --  Encoded enumeration type that passes procedure information.
  type Procedure_Id_Type is
    (Null_Id,
     Diriger_Aiguillage_Id,
     Attendre_Contact_Id,
     Arreter_Loco_Id,
     Mettre_Vitesse_Progressive_Id,
     Mettre_Fonction_Loco_Id,
     Inverser_Sens_Loco_Id,
     Mettre_Vitesse_Loco_Id,
     Demander_Loco_Id);

  type Arguments_Record_Type (Id : Procedure_Id_Type := Null_Id) is record
    case Id is
       when Null_Id =>
         null;
       when Diriger_Aiguillage_Id =>
         No_Aiguillage  : No_Aiguillage_Type;
         Direction      : T_Direction;
         Temps_Alim     : Natural;
       when Attendre_Contact_Id =>
         No_Contact     : No_Contact_Type;
       when Arreter_Loco_Id =>
         No_Loco_A      : No_Loco_Type;
       when Mettre_Vitesse_Progressive_Id =>
         No_Loco_B      : No_Loco_Type;
         Vitesse_Future : Vitesse_Type;
       when Mettre_Fonction_Loco_Id =>
         No_Loco_C      : No_Loco_Type;
         Etat           : Boolean;
       when Inverser_Sens_Loco_Id =>
         No_Loco_D      : No_Loco_Type;
       when Mettre_Vitesse_Loco_Id =>
         No_Loco_E      : No_Loco_Type;
         Vitesse_A      : Vitesse_Type;
       when Demander_Loco_Id =>
         Contact_A      : No_Contact_Type;
         Contact_B      : No_Contact_Type;
         Numero         : No_Loco_Type;
         Vitesse_B      : Vitesse_Type;
    end case;
  end record;

  type Seq_Type is mod 16#1_000_000#;

  procedure Debug (Msg : in String);

end Train_Handler;
