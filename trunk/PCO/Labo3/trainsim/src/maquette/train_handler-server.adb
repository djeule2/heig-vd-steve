--------------------------------------------------------------------------
--
-- Nom du fichier   : Train_Handler-server.adb
-- Auteurs          : P.Girardet sur la base du paquetage de
--                    M Pascal Binggeli & M Vincent Crausaz
--                    Dominik Madon pour l'interface par sockets
--
-- Date de creation : 22.8.97
--
-- Modifs.          : Decembre 1997
-- Raison de la
-- Modification     : Ajout d'une interface graphique
--
-- Autre Modifs     : fevrier 1998
-- Raison           : Amelioration
--
-- Modification     : DŽcembre 2003/Avril 2004
-- Raison           : Division de train_handler en une interface
--                    client-serveur basŽes sur des sockets.
--
-- Origine          : TRAIN_HANDLER (Michel MOREROD, EINEV, 1989)
--
-- Version          : 4.0
-- Projet           : Simulateur de maquette
-- Module           : Train_Handler
-- But              : Module qui implemente l'interface TRAIN_HANDLER
--                    pour utiliser le simulateur
--
-- Modules appeles  :
--
-- Fonctions exportees: Demander_loco,
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
-- Materiel particulier : Les librairie OgenGL (dll)
--                        Interface Sockets (GNAT.Sockets ou Ada.Sockets)
-- Mode d'utilisation   : Compiler avec le programme a tester
--                        Sous objectAda lie au projet la librairie
--                        ..Objectada\Win32ada\binding\lib
--                        et seulement pour l'edition de lien la librairie
--                        ..Objectada\apilib
--
--
--------------------------------------------------------------------------

with P_Afficher;                  -- Pour les entrees/sorties sur l'ecran
with P_Maquette;                  -- Pour le simulateur de maquette
with P_Section;                   -- Pour les objets rails
with P_Train;                     -- Pour les objets Trains
with P_Contact;                   -- Pour les objets Contacts
with P_Aiguillage;                -- Pour les objets Aiguillages
with P_Messages;
with P_Couleur;

with Tunnel;
with Unchecked_Deallocation;

with Text_IO;


package body Train_Handler.Server is


   --  Custom tunnel package.
   package Network_Object is new Tunnel.Protocol
     (Packed_Arguments_Type => Arguments_Record_Type,
      Sequence_Type         => Seq_Type);

   --  tcpip connection parameters holder.
   Connection : aliased Network_Object.Tcpip_Configuration_Type;

   --  Reference type to tcpip connection.
   type Tcpip_Configuration_Type_Access is
     access all Network_Object.Tcpip_Configuration_Type;

   --  Reference to connection variable.
   Conn_Acc : Tcpip_Configuration_Type_Access := Connection'access;


   type Executor_Type; -- forward declaration.
   type Executor_Access is access all Executor_Type;

   type Dispatcher_Type; -- forward declaration;
   type Dispatcher_Access is access all Dispatcher_Type;


   -------------------
   --  Sender_Type  --
   -------------------

   --  Task responsible for sending packets to the client.

   task type Sender_Type is

      --  Starts the task given the tcpip configuration of the
      --  connection and the dispatcher's access (in order to
      --  communicate with them).
      entry Start
        (Conn_Acc       : in Tcpip_Configuration_Type_access;
         Dispatcher_Acc : in Dispatcher_Access);

      --  Send a record to the client.
      entry Send
        (Seq : in Seq_Type;
         Z   : in Arguments_Record_Type);

      entry Stop;

   end Sender_Type;

   type Sender_Access is access all Sender_Type;

   --  Deallocation procedure for the Sender.
   procedure Free is
      new Unchecked_Deallocation (Sender_Type, Sender_Access);


   -----------------------
   --  Dispatcher_Type  --
   -----------------------

   --  Task responsible for receiving information from the client and
   --  dispathing the messages to the executr tasks.

   task type Dispatcher_Type is

      --  Starts the dispatcher given the tcpip configuration, the
      --  sender access and the dispatcher acces itself (used to provide
      --  executor a way to talk back to the right dispatcher).
      entry Start
        (Conn_Acc            : in Tcpip_Configuration_Type_Access;
         Sender_Acc_Init     : in Sender_Access;
         Dispatcher_Acc_Init : in Dispatcher_Access);

      --  Hook for the executor tasks when it has finished its work.
      entry Wait
        (Seq : out Seq_Type;
         Rec : out Arguments_Record_Type);

      entry Stop;

   end Dispatcher_Type;


   procedure Free is
      new Unchecked_Deallocation (Dispatcher_Type, Dispatcher_Access);


   ---------------------
   --  Executor_Type  --
   ---------------------

   --  This task will loop waiting for a procedure to execute and its
   --  arguments, then it will execute (make the call) to the given
   --  procedure and return the result to the callee.

   task type Executor_Type is
      entry start  (Sender_Acc_Init     : Sender_Access;
                    Dispatcher_Acc_Init : Dispatcher_Access);
   end Executor_Type;

   task body Executor_Type is

      Dispatcher_Acc : Dispatcher_Access;
      Sender_Acc     : Sender_Access;

      Seq : Seq_Type;
      Rec : Arguments_Record_Type;

   begin
      accept Start (Sender_Acc_Init     : Sender_Access;
                    Dispatcher_Acc_Init : Dispatcher_Access) do
         Sender_Acc := Sender_Acc_Init;
         Dispatcher_Acc := Dispatcher_Acc_Init;
      end Start;

      loop
         Dispatcher_Acc.Wait (Seq, Rec);

         case Rec.Id is
            when Null_Id =>
               exit; --  "Stop" signal in fact.
            when Diriger_Aiguillage_Id =>
               Train_Handler.Server.Diriger_Aiguillage
                 (No_Aiguillage => Rec.No_Aiguillage,
                  Direction     => Rec.Direction,
                  Temps_Alim    => Rec.Temps_Alim);
            when Attendre_Contact_Id =>
               Train_Handler.Server.Attendre_Contact (Rec.No_Contact);
            when Arreter_Loco_Id =>
               Train_Handler.Server.Arreter_Loco (Rec.No_Loco_A);
            when Mettre_Vitesse_Progressive_Id =>
               Train_Handler.Server.Mettre_Vitesse_Progressive
                 (No_Loco        => Rec.No_Loco_B,
                  Vitesse_Future => Rec.Vitesse_Future);
            when Mettre_Fonction_Loco_Id =>
               Train_Handler.Server.Mettre_Fonction_Loco
                 (No_Loco => Rec.No_Loco_C,
                  Etat    => Rec.Etat);
            when Inverser_Sens_Loco_Id =>
               Train_Handler.Server.Inverser_Sens_Loco (Rec.No_Loco_D);
            when Mettre_Vitesse_Loco_Id =>
               Train_Handler.Server.Mettre_Vitesse_Loco
                 (No_Loco => Rec.No_Loco_E,
                  Vitesse => Rec.Vitesse_A);
            when Demander_Loco_Id =>
               Train_Handler.Server.Demander_Loco
                 (Contact_A => Rec.Contact_A,
                  Contact_B => Rec.Contact_B,
                  Numero    => Rec.Numero,
                  Vitesse   => Rec.Vitesse_B);
         end case;
         Sender_Acc.Send (Seq, Rec);
      end loop;
   end Executor_Type;


   task body Dispatcher_Type is

      Args       : Arguments_Record_Type;
      My_Seq  : Seq_Type;
      End_Rec : constant Arguments_Record_Type := (Id => Null_ID);

      Executor_Acc   : Executor_Access;
      Sender_Acc     : Sender_Access;
      Dispatcher_Acc : Dispatcher_Access;

      Executor_Counter : Natural := 0;

   begin

      accept Start (Conn_Acc            : in Tcpip_Configuration_Type_Access;
                    Sender_Acc_Init     : in Sender_Access;
                    Dispatcher_Acc_Init : in Dispatcher_Access) do
         Dispatcher_Acc := Dispatcher_Acc_Init;
         Sender_Acc := Sender_Acc_Init;
      end Start;

    loop

      Network_Object.Receive (Conn_Acc.all, My_Seq, Args);

      exit when Args = End_Rec;

      if Wait'Count = 0 then
         Executor_Counter := Executor_Counter + 1;
         Executor_Acc := new Executor_Type;
         Executor_Acc.Start (Sender_Acc, Dispatcher_Acc);
      end if;

      select
         accept Stop;
      or
         accept Wait
           (Seq : out Seq_Type;
            Rec : out Arguments_Record_Type) do
            Seq := My_Seq;
            Rec := Args;
         end Wait;
      end select;

    end loop;

    --  Check and stop executor tasks.
    while Executor_Counter > 0 loop
       accept Wait (Seq : out Seq_Type;
                    Rec : out Arguments_Record_Type) do
          Seq := Seq_Type'First;
          Rec := End_Rec;
       end Wait;
       Executor_Counter := Executor_Counter - 1;
    end loop;

    Sender_Acc.Stop;

   end Dispatcher_Type;


   task body Sender_Type is
   begin

      accept Start
        (Conn_Acc       : in Tcpip_Configuration_Type_Access;
         Dispatcher_Acc : in Dispatcher_Access);

      loop
         select
            accept Send
              (Seq : in Seq_Type;
               Z   : in Arguments_Record_Type) do
               Network_Object.Send (Conn_Acc.all, Seq, Z);
            end Send;
         or
            accept Stop;
            exit;
         end select;
      end loop;

      --  Check and stop executor tasks.
      while Send'Count > 0 loop
         accept Send (Seq : in Seq_Type;
                      Z   : in Arguments_Record_Type) do
            Network_Object.Send (Conn_Acc.all, Seq, Z);
         end Send;
      end loop;
   end Sender_Type;



   Dispatcher_Acc : Dispatcher_Access := new Dispatcher_Type;
   Sender_Acc     : Sender_Access     := new Sender_Type;


   -- Type pour identifier les divers maquettes
   type T_Type_Maquette is (a1, b1, a2, b2);


   -- Pour effectuer des entrees sorties sur des entiers
   package P_Afficher_Entier is new P_Afficher.Integer_io(Integer);

   -- Pour les entrees/sorties sur le type de la maquette
   package Type_io is new P_Afficher.Enumeration_Io(T_Type_Maquette);

   -- Pour les entrees/sorties sur les modes de fonctionnement
   -- (contact et affichage)
   package Mode_Aff_Io is new P_Afficher.Enumeration_Io(P_Messages.T_Mode_Aff);

   package Mode_Reb_Io is new P_Afficher.Enumeration_Io(P_Messages.T_Mode_Reb);

   -- Pour les entrees/sorties sur le mode de fonctionnement du simulateur
   -- (pas a pas ou continu)
   package Mode_Execution_io is new
     P_Afficher.Enumeration_Io(P_Messages.T_Mode_Execution);

   --  Tableau pour convertir la lettre identifiant la maquette en nom
   --  de fichier
   Nom_Maquette : constant array (T_Type_Maquette) of  String(1..13)
     := ("Maquet_A1.txt", "Maquet_B1.txt",
         "Maquet_A2.txt", "Maquet_B2.txt");

   --  Tableau indiquant pour les locos posee sur la maquette leur
   --  numero interne selon un index qui correspond au numero externe
   --  de type "No_Loco_type"
   Train_Id_De_Loco : array (No_Loco_Type) of P_Train.T_Train_Id
     := (others => P_Train.Train_Null);

   --  Identificateur de train utilise pour trouver l'identificateur
   --  suivant l'identificateur de la derniere locomotive utilisee
   Train_Id_preced: P_Train.T_Train_Id:= P_Train.T_Train_Id'First;

   --  Derniere couleur affectee a une locomotive
   Last_Color : P_Couleur.T_Couleur := P_Couleur.T_Couleur'Last;

   --  Pour memoriser la reponse de l'utilisateur sur le nom de la
   --  maquette que le simulateur va remplacer
   Type_Maquette: T_Type_Maquette := a1;

   Reponse    : Character;     -- Caractere retourne par l'utilisateur
   A_la_ligne : Boolean;       -- Indique si le caractere suivant est un return



   --  Permet de terminer l'initialisation et dŽmarrer la simulation
   --  si la partie graphique est compltement ŽlaborŽe et prte.
   --
   --  Cette partie de code doit tre sŽparŽe et exŽcutŽe en
   --  parallle en raison de l'entrŽe dŽfinitive dans la boucle
   --  d'ŽvŽnement OpenGL.

   task Interface_Graphique_Task is
      entry start;
   end Interface_Graphique_Task;


   task body Interface_Graphique_Task is
   begin
      accept Start;
      --  Mise en attente de l'objet de synchronisation de dŽmarrage.
      P_Maquette.Etat_Maquette.Prete;

      Mettre_Maquette_En_Service;

      --  Determine les modes de fonctionement du simulateur
      P_Maquette.Mettremodesimulation
        (Continu   => Boolean'Val
           (P_Messages.T_Mode_Execution'Pos (P_Messages.Mode_fonc)),
         Affichage => not Boolean'Val
           (P_Messages.T_Mode_Aff'pos (P_Messages.Mode_Aff)),
         Rebond    => not Boolean'Val
           (P_Messages.T_Mode_Reb'pos (P_Messages.Mode_Rebond)));

   end Interface_Graphique_Task;



  ---------------------
  --  Init_Maquette  --
  ---------------------

  --  Cette procedure initialise le simulateur. Elle doit etre
  --  executee avant toute utilisation du simulateur. Elle effectue
  --  aussi le travail fournit par "Mettre_Maquette_En_Service"

  procedure Init_Maquette is
  begin

     --  Lancement du module graphique base sur Glut.
     Interface_Graphique_Task.Start;

     -- Creation et initialisation de la connexion avec un client.
     Network_Object.Server.Initialize (Connection);
     Network_Object.Server.Connect (Connection);

     --  Demarrage des taches de gestions de la transmission par
     --  TCP/IP.
     Dispatcher_Acc.Start (Conn_Acc, Sender_Acc, Dispatcher_Acc);
     Sender_Acc.Start (Conn_Acc, Dispatcher_acc);

     -- Presentation du programme
     P_Afficher.Reserver_Affichage;
     P_Afficher.New_Line_Dans_Zone_Reserv;
     P_Afficher.Put_Line_Dans_Zone_Reserv
       ("                    ---========---");
     P_Afficher.Put_Line_Dans_Zone_Reserv
       ("        ---=== " & P_Messages.Titre & " ===---");
     P_Afficher.Put_Line_Dans_Zone_Reserv
       ("                    ---========---");
     P_Afficher.New_Line_Dans_Zone_Reserv;
     P_Afficher.Put_Line_Dans_Zone_Reserv
       (" " & P_Messages.Copyright);
     P_Afficher.New_Line_Dans_Zone_Reserv;

     -- Demande le type de la maquette
     loop
        begin
           P_Afficher.New_Line_Dans_Zone_Reserv;
           P_Afficher.Put_Line_Dans_Zone_Reserv
             (" " & P_Messages.Quel_Maquette);
           P_Afficher.Put_Dans_Zone_Reserv
             (" " & P_Messages.Choix_Maquette);

           -- Memorise la reponse
           P_Afficher.look_Ahead(Reponse, A_la_ligne);

           if not A_la_ligne then

              Type_Io.Get(Type_Maquette);

           end if;
           P_Afficher.Skip_Line;
           -- Si il n'y a pas eu d'erreur on sort de la boucle
           exit;

        exception
           -- Caractere ou chiffre incorrect ou caractere speciaux

           when Constraint_Error | P_Afficher.Data_Error =>
              P_Afficher.New_Line_Dans_Zone_Reserv;
              P_Afficher.Put_Line_Dans_Zone_Reserv
                (" " & P_Messages.Erreur_Maquette);
              P_Afficher.Put_Line_Dans_Zone_Reserv
                (" " & P_Messages.Recommencer);
              P_Afficher.New_Line_Dans_Zone_Reserv;
              P_Afficher.Skip_Line;

        end; --  exception block

     end loop;

     -- Demande le mode de fonctionement
     loop
        begin
           P_Afficher.New_Line_Dans_Zone_Reserv;
           P_Afficher.Put_Line_Dans_Zone_Reserv
             (" " & P_Messages.Quel_Mode_Exe);
           P_Afficher.Put_Dans_Zone_Reserv
             (" " & P_Messages.Choix_Mode_Exe);

           -- Memorise la reponse
           P_Afficher.look_Ahead(Reponse, A_la_ligne);

           if not A_la_ligne then
              Mode_Execution_io.Get(P_Messages.Mode_fonc);

           end if;
           P_Afficher.Skip_line;

           -- Si il n'y a pas eu d'erreur on sort de la boucle
           exit;

        exception
           -- Caractere ou chiffre incorrect ou caractere speciaux
           when Constraint_error | P_Afficher.Data_Error =>
              P_Afficher.New_Line_Dans_Zone_Reserv;
              P_Afficher.Put_Line_Dans_Zone_Reserv
                (" " & P_Messages.Erreur_Mode);
              P_Afficher.Put_Line_Dans_Zone_Reserv
                (" " & P_Messages.Recommencer);
              P_Afficher.New_Line_Dans_Zone_Reserv;
              P_Afficher.Skip_line;

        end; -- exception block

     end loop;

     -- Demande le fonctionement avec ou sans affichage
     loop
        begin
           P_Afficher.New_Line_Dans_Zone_Reserv;
           P_Afficher.Put_Line_Dans_Zone_Reserv
             (" " & P_Messages.Quel_Mode_Aff);
           P_Afficher.Put_Dans_Zone_Reserv
             (" " & P_Messages.Choix_Mode_Aff);

           -- Memorise la reponse
           P_Afficher.look_Ahead(Reponse, A_la_ligne);

           if not A_la_ligne then
              Mode_Aff_Io.Get(P_Messages.Mode_Aff);

           end if;
           P_Afficher.Skip_line;
           -- Si il n'y a pas eu d'erreur on sort de la boucle
           exit;

        exception
           -- Caractere ou chiffre incorrect ou caractere speciaux
           when Constraint_error | P_Afficher.Data_Error =>
              P_Afficher.New_Line_Dans_Zone_Reserv;
              P_Afficher.Put_Line_Dans_Zone_Reserv
                (" " & P_Messages.Erreur_Mode);
              P_Afficher.Put_Line_Dans_Zone_Reserv
                (" " & P_Messages.Recommencer);
              P_Afficher.New_Line_Dans_Zone_Reserv;
              P_Afficher.Skip_line;

        end;  -- exception block

     end loop;

     -- Demande le fonctionement avec ou sans rebonds
     loop
        begin
           P_Afficher.New_Line_Dans_Zone_Reserv;
           P_Afficher.Put_Line_Dans_Zone_Reserv
             (" " & P_Messages.Quel_Mode_Reb);
           P_Afficher.Put_Dans_Zone_Reserv
             (" " & P_Messages.Choix_Mode_Reb);

           -- Memorise la reponse
           P_Afficher.look_Ahead(Reponse, A_la_ligne);

           if not A_la_ligne then
              Mode_Reb_Io.Get(P_Messages.Mode_Rebond);

           end if;
           P_Afficher.Skip_line;
           -- Si il n'y a pas eu d'erreur on sort de la boucle
           exit;

        exception
           -- Caractere ou chiffre incorrect ou caractere speciaux
           when Constraint_error | P_Afficher.Data_Error =>
              P_Afficher.New_Line_Dans_Zone_Reserv;
              P_Afficher.Put_Line_Dans_Zone_Reserv
                (" " & P_Messages.Erreur_Mode);
              P_Afficher.Put_Line_Dans_Zone_Reserv
                (" " & P_Messages.Recommencer);
              P_Afficher.New_Line_Dans_Zone_Reserv;
              P_Afficher.Skip_line;

        end; -- exception block

     end loop;

     P_Afficher.Liberer_Affichage;

     -- Initialisation du simulateur
     P_Maquette.Init (Nom_Maquette(Type_Maquette));

  end Init_Maquette;

  -------------------------------------------------------------------------
  --
  -- Procedure: Mettre_Maquette_Hors_Service
  -- But      : Cette procedure permet de couper l'alimentation de la
  --            maquette, donc de stopper toute activite sur la maquette
  --
  -------------------------------------------------------------------------
  procedure Mettre_Maquette_Hors_Service
  is
  begin

     P_Maquette.Desactiver;

  end Mettre_Maquette_Hors_Service;

  ----------------------------------
  --  Mettre_Maquette_En_Service  --
  ----------------------------------

  --  Cette procedure permet de retablir l'alimentation de la
  --  maquette, donc de reactive toute la maquette. Elle n'a pas
  --  besoin d'etre appelee apres "Init_Maquette"

  procedure Mettre_Maquette_En_Service is
  begin

     P_Maquette.Activer;

  end Mettre_Maquette_En_Service;


  --------------------------
  --  Diriger_Aiguillage  --
  --------------------------

  --  Procedure pour le pilotage des aiguillages. Elle permet de
  --  changer la direction de l'aiguillage mentionne
  --
  -- Entrees  : No_Aiguillage =>
  --                               Le numero de l'aiguillage.
  --            Direction  =>  La direction de l'aiguillage (Tout_droit ou
  --                           Devie)
  --
  --            Temps_alim =>  Le temps l'alimentation minimal du
  --                           bobinage de l'aiguillage
  --
  --
  -- NB       : Dans le cas d'un aiguillage courbe "Tout_Droit" correspond
  --            a la voie interieure.
  --
  -- Attention: Si un train se trouve sur l'aiguillage lors que l'on
  --            modifie sa direction, celui-ci va derailler.

  procedure Diriger_Aiguillage(No_Aiguillage  : in No_Aiguillage_Type;
                               Direction      : in T_Direction;
                               Temps_Alim     : in Natural := 0) is
     -- Type pour la direction d'une section aiguillage
     Dir: P_Section.T_Direction;

  begin
     -- On recherche la direction correspondante.
     if Direction = Devie
     then
        Dir := P_Section.Devie;

     else
        Dir := P_Section.Tout_Droit;

     end if;

     -- On dirige l'aiguillage.
     P_Maquette.Dirigeraiguillage
       (P_Aiguillage.T_Aiguillage_Id(No_Aiguillage), Dir);

  end Diriger_Aiguillage;


  ------------------------
  --  Attendre_Contact  --
  ------------------------

  --  Procedure pour la gestion des contacts. Elle fait attendre (la
  --  tache appelante) qu'une locomotive passe sur le contact transmis
  --  en parametre.
  --
  --  Entrees  : No_Contact =>  Numero du contact dont on attend
  --                            l'activation

  procedure Attendre_Contact(No_Contact: in No_Contact_Type) is
  begin
     -- On appelle l'entree de l'objet protege "Protmaquette"
     -- correspondant au contact sur lequel on desir attendre
     P_Maquette.Attendreactivationcontact(P_Contact.T_Contact_Id(No_Contact));

  end Attendre_Contact;


  --------------------
  --  Arreter_Loco  --
  --------------------

  --  Cette procedure arrete la locomotive demandee de maniere
  --  immediate
  --
  --  Entrees : No_loco => Numero de la locomotive que l'on veut
  --                       arreter

  procedure Arreter_Loco(No_Loco: in No_Loco_Type) is
  begin
    -- On affecte une vitesse nulle a la locomotive
     P_Maquette.Mettrevitessetrain(Train_Id_De_Loco(No_Loco),
                                   P_Train.Arret);

  end Arreter_Loco;


  ----------------------------------
  --  Mettre_Vitesse_Progressive  --
  ----------------------------------

  --  Cette procedure devrait effectuer un changement progressif de la
  --  vitesse de la locomotive demandee.  Cette variation de vitesse
  --  va de la vitesse actuelle a la vitesse passee en parametre, par
  --  palier.
  --
  --  Entrees  : No_loco   => Numero de la locomotive dont on veut faire
  --                          varier la vitesse
  --             Vitesse_Futur =>
  --                          Vitesse que la locomotive aura apres
  --                          le changement de vitesse
  --
  -- Remarque: Dans le simulateur cette procedure agit comme la fonction
  --           "Mettre_Vitesse_Loco". c'est-a-dire que l'acceleration est
  --           immediate( de la vitesse actuelle a la vitesse specifiee )

  procedure Mettre_Vitesse_Progressive (No_Loco       : in No_Loco_Type;
                                        Vitesse_Future: in Vitesse_Type) is
  begin
     -- On ne simule par l'acceleration.
     Mettre_Vitesse_Loco(No_Loco, Vitesse_Future);

  end Mettre_Vitesse_Progressive;



  ----------------------------
  --  Mettre_Fonction_Loco  --
  ----------------------------

  --  Cette procedure devrait permettre d'allumer ou d'eteindre les
  --  phares de la locomotive. Pour eteindre les phares "Etat" doit
  --  valoir "False", pour les allumer "Etat" doit valoir "True"
  --
  --  Entrees  : No_loco   => Numero de la locomotive dont on veut allumer
  --                          ou eteindre les phares
  --             Etat      => Indique si l'on effectue un allumage "True"
  --                          ou une extinction.
  --
  -- Remarque: Dans le simulateur cette fonction n'a aucun effet. Les
  --           locomotive representee par des rectangles possedent une
  --           partie jaune indiquant le sens de déplacement. L'utilisation
  --           des phares n'est donc plus utile.

  procedure Mettre_Fonction_Loco (No_Loco : in No_Loco_Type;
                                  Etat    : in Boolean) is
  begin
     null;
  end Mettre_Fonction_Loco;


  --------------------------
  --  Inverser_Sens_Loco  --
  --------------------------

  --  Cette procedure permet de changer les sens de marche de la
  --  locomotive. Elle l'arrete si sa vitesse est non nulle, puis la
  --  fait redemarrer dans l'autre sens a la meme vitesse.
  --
  --  Entrees  : No_loco   => Numero de la locomotive dont on veut modifier
  --                          le sens de marche

  procedure Inverser_Sens_Loco(No_Loco: in No_Loco_Type) is
  begin

     P_Maquette.Changerdirectiontrain(Train_Id_De_Loco(No_Loco));

  end Inverser_Sens_Loco;


  ---------------------------
  --  Mettre_Vitesse_Loco  --
  ---------------------------

  --  Cette procedure transmet l'ordre a la locomotive de passer a la
  --  vitesse transmise.
  --
  --  Entrees  : No_loco   => Numero de la locomotive dont on veut modifier
  --                          la vitesse
  --             Vitesse   => Vitesse que l'on veut affecter a la locomotive

  procedure Mettre_Vitesse_Loco(No_Loco: in No_Loco_Type;
                                Vitesse: in Vitesse_Type) is
  begin

     P_Maquette.Mettrevitessetrain(Train_Id_De_Loco(No_Loco),
                                   P_Train.T_Vitesse(Vitesse));

  end Mettre_Vitesse_Loco;


  ---------------------
  --  Demander_Loco  --
  ---------------------

  --  Cette procedure demande a l'utilisateur le numero de la
  --  locomotive qu'il desire utiliser.
  --  Elle demande a l'utilisateur la vitesse a laquelle il desire
  --  actionner la locomotive
  --  Elle place la locomotive entre deux contacts A et B
  --  donnes par l'appelant.
  --
  --  On suppose l'utilisateur averti et ne commettant pas d'erreurs
  --
  --  Entrees  : Contact_A => Contact delimitant la zone sur laquelle la
  --                          locomotive sera posee (elle va se diriger
  --                          vers ce contact
  --             Contact_B => Contact delimitant la zone sur laquelle la
  --                          locomotive sera posee
  --
  --  Sorties  : Numero    => Numero de la locomotive qui sera pose a
  --                          l'endroit determine
  --             Vitesse   => Vitesse de la locomotive qui sera pose a
  --                          l'endroit determine
  --
  -- 13.1.92, P. Breguet sur une idee de Conus et Rappaz EI3 91

  procedure Demander_Loco
    (Contact_A : in No_Contact_Type;
     Contact_B : in No_Contact_Type;
     Numero    : out No_Loco_Type;
     Vitesse   : out Vitesse_Type) is
     --
     use P_Couleur;

     -- Variables necessaires du fait du mode de passage des parametres
     Numero_Temp : No_Loco_Type ;
     Vitesse_Temp : Vitesse_Type ;

     -- DEMANDER_LOCO
  begin
     -- Recherche de la couleur a affecter a la locomotive
     if Last_Color = T_Couleur'Last
     then
        Last_Color := Magenta;

     else
        Last_Color := T_Couleur'succ(Last_Color);

     end if;

     -- Demander le numero de la locomotive
     P_Afficher.Reserver_Affichage;
     P_Afficher.New_Line_Dans_Zone_Reserv;
     P_Afficher.Put_Line_Dans_Zone_Reserv (" " & P_Messages.Quel_No_Loco);
     P_Afficher.Put_Dans_Zone_Reserv (" " & P_Messages.Quel_No_Loco2 & " (");
     P_Afficher_Entier.Put_Dans_Zone_Reserv (No_Loco_Type'First+1, 3);
     P_Afficher.Put_Dans_Zone_Reserv (" - ");
     P_Afficher_Entier.Put_Dans_Zone_Reserv (No_Loco_Type'Last, 3);
     P_Afficher.Put_Dans_Zone_Reserv (" ) => ");

     -- On saisi la reponse
     P_Afficher_Entier.Get (Numero_Temp);
     P_Afficher.Skip_Line;

     -- Positionnement de la locomotive sur la maquette
     P_Afficher.New_Line_Dans_Zone_Reserv( 2 ) ;
     P_Afficher.Put_Dans_Zone_Reserv(" " & P_Messages.Ind_Loco_Posee);
     P_Afficher_Entier.Put_Dans_Zone_Reserv( Contact_A, 3 ) ;
     P_Afficher.Put_Dans_Zone_Reserv(" " & P_Messages.Et & " ");
     P_Afficher_Entier.Put_Dans_Zone_Reserv( Contact_B, 3 ) ;
     P_Afficher.New_Line_Dans_Zone_Reserv( 2 ) ;


     -- On affecte le tableau de conversion numero externe - numero interne
     Train_Id_De_Loco(Numero_Temp):= P_Train.T_Train_Id'Succ(Train_Id_Preced);

     -- On fait evolue la variable pour y memoriser l'identificateur
    -- precedemment utilise
     Train_Id_Preced:= P_Train.T_Train_Id'Succ(Train_Id_Preced);

     -- On indique au simulateur le train que l'on veut poser sur la maquette
     P_Maquette.Posertrain( Notrain      => Numero_Temp,
                            Trainid      => Train_Id_De_Loco(Numero_Temp),
                            Contactid_A  => Contact_A,
                            Contactid_B  => Contact_B,
                            Couleur      => Last_Color);

     -- Attendre la quittance de l'utilisateur
     P_Afficher.Put_Dans_Zone_Reserv (" " & P_Messages.Ind_Continue ) ;
     P_Afficher.Skip_Line;

     -- Demander a l'utilisateur la vitesse a laquelle il veut actionner
     -- la locomotive
     P_Afficher.New_Line_Dans_Zone_Reserv( 2 ) ;
     P_Afficher.Put_Line_Dans_Zone_Reserv(" " & P_Messages.Quel_Vitesse_Loco);
     P_Afficher.Put_Dans_Zone_Reserv(" ( ");
     P_Afficher_Entier.Put_Dans_Zone_Reserv( Vitesse_Minimum, 2 );
     P_Afficher.Put_Dans_Zone_Reserv(" - ");
     P_Afficher_Entier.Put_Dans_Zone_Reserv( Vitesse_Maximum, 3 );
     P_Afficher.Put_Dans_Zone_Reserv(" ) => ");

     -- On saisi la reponse
     P_Afficher_Entier.Get(Vitesse_Temp);
     P_Afficher.Skip_Line;
     P_Afficher.New_Line_Dans_Zone_Reserv ( 2 ) ;
     P_Afficher.Liberer_Affichage;

     -- finalement, on redonne les vitesses et numero de la locomotive
     Numero  := Numero_Temp ;
     Vitesse := Vitesse_Temp ;

  exception
     -- Si les contacts fournit a la fonction sont incorrects
     when P_Maquette.Faux_Contact =>

        -- On remet le tableau de conversion no extern - no interne dans son
        -- etat initial
        Train_Id_De_Loco(Numero_Temp):= P_Train.Train_Null;

        -- On fait evolue la variable pour y memoriser l'identificateur
        -- precedemment utilise
        Train_Id_Preced:= P_Train.T_Train_Id'Pred(Train_Id_Preced);

        P_Afficher.New_Line_Dans_Zone_Reserv (2);
        P_Afficher.Put_Line_Dans_Zone_Reserv
          (" " & P_Messages.Erreur_Pos_Loco);
        P_Afficher.Put_Line_Dans_Zone_Reserv
          (" " & P_Messages.Erreur_Pos_Loco2);
        P_Afficher.Put_Line_Dans_Zone_Reserv
          (" " & P_Messages.Erreur_Pos_Loco3);
        P_Afficher.New_Line_Dans_Zone_Reserv;
        P_Afficher.Skip_Line;

        -- On libere l'affichage car l'exception a saute l'instruction
        P_Afficher.Liberer_Affichage;

        -- On retourne des valeurs par defaut
        Numero  := 0 ;
        Vitesse := 3 ;

  end Demander_Loco;

end Train_Handler.Server;
