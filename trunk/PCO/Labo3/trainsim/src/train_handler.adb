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
-- Autre Modifs     : fŽvrier 1998
-- Raison           : Amelioration
--
-- Modification     : DŽcembre 2003
-- Raison           : Division de train_handler en une interface
--                    client et une serveur basées sur des sockets.
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
--                        Sous objectAda lie au projet la bibliotheque
--                        ..Objectada\Win32ada\binding\lib
--                        et seulement pour l'edition de lien la
--                        bibliotheque ..Objectada\apilib
--
--
--------------------------------------------------------------------------

--with P_Afficher;                  -- Pour les entrees/sorties sur l'ecran
--with P_Maquette;                  -- Pour le simulateur de maquette
--with P_Section;                   -- Pour les objets rails
--with P_Train;                     -- Pour les objets Trains
--with P_Contact;                   -- Pour les objets Contacts
--with P_Aiguillage;                -- Pour les objets Aiguillages
--with P_Messages;
--with P_Couleur;

with Tunnel;
with Text_IO;


package body Train_Handler is


   procedure Debug (Msg : in String) is
      use Text_IO;
   begin
      Put_Line ("### " & Msg);
   end Debug;

   package Network_Object is new Tunnel.Protocol
     (Packed_Arguments_Type => Arguments_Record_Type,
      Sequence_Type         => Seq_Type);

   Connection : Network_Object.Tcpip_Configuration_Type;

   -----------------------
   --  Emission_Reseau  --
   -----------------------

   --  Emission_Reseau permet de serialiser les communications entre
   --  le client et la maquette. En dehors de l'attente du passage
   --  d'un contact, les appels sont sŽrialisŽ simplement au travers
   --  d'un rendez-vous. L'attente d'un contact est divisŽ en un
   --  protocole ˆ deux phases qui implique la t‰che de
   --  Reception_Reseau.
   --

   task Emission_Reseau is
      entry Start;
      entry Stop;
      entry Envoi (Seq : out Seq_Type; Args : in Arguments_Record_Type);
   end Emission_Reseau;


   task body Emission_Reseau is
      Ticket : Seq_Type := Seq_Type'First;
   begin
      accept Start;  --  DŽmarre le cycle de service des communication.
      loop
         select
            accept Stop;
            exit; --  Sort de la boucle de fonctionnement normal.
         or
            accept Envoi (Seq  : out Seq_Type;
                          Args : in  Arguments_Record_Type) do
               Network_Object.Send (Connection, Ticket, Args);
               Seq := Ticket;
            end Envoi;
            Ticket := Ticket + 1;
         or
            terminate;
         end select;
      end loop;
   end Emission_Reseau;


   task Reception_Reseau is
     entry Start;
     entry Stop;
     entry Recoit (Seq_Type) (Args : out Arguments_Record_Type);
   end Reception_Reseau;

   task body Reception_Reseau is
      Packet       : Arguments_Record_Type;
      Received_Seq : Seq_Type;
   begin
      accept Start;  --  DŽmarre le cycle de service des communication.
      loop
         select
            accept Stop;
            exit; --  Sort de la boucle de fonctionnement normal.
         else
            Network_Object.Receive (Connection, Received_Seq, Packet);
            accept Recoit (Received_Seq)(Args : out Arguments_Record_Type) do
               Args := Packet;
            end Recoit;
         end select;
      end loop;
   end Reception_Reseau;

   Connected : Boolean := False;

   ---------------------
   --  Init_Maquette  --
   ---------------------

   --  La maquette est initialisŽe du c™tŽ simulateur (serveur).
   --  C'est la partie sockets qui est initialisŽe ici, profitant du
   --  fait que cette procedure est appelée par le client en dŽbut de
   --  simulation.

   procedure Init_Maquette is
   begin
      if not Connected then
         Network_Object.Client.Initialize (Connection);
         Network_Object.Client.Connect (Connection);

         Connected := True;

         Reception_Reseau.Start;
         Emission_Reseau.Start;
      end if;
   end Init_Maquette;



   ------------------------------------
   --  Mettre_Maquette_Hors_Service  --
   ------------------------------------

   --  On profite de l'appel obligatoire pour couper la connexion avec
   --  le simulateur.

   procedure Mettre_Maquette_Hors_Service is
   begin
      if Connected then
         Reception_Reseau.Stop;
         Emission_Reseau.Stop;

         Network_Object.Client.Disconnect (Connection);
         Network_Object.Client.Finalize (Connection);

         Connected := False;
      end if;
   end Mettre_Maquette_Hors_Service;


   ----------------------------------
   --  Mettre_maquette_en_service  --
   ----------------------------------

   --  Cette procedure permet de retablir l'alimentation de la
   --  maquette, donc de reactive toute la maquette. Elle n'a pas
   --  besoin d'etre appelee apres "Init_Maquette"
   --
   --  Comme prŽcŽdemment, on profite de l'appel pour connecter le
   --  client au simulateur.

   procedure Mettre_Maquette_En_Service is
   begin
      Init_Maquette;
   end Mettre_Maquette_En_Service;


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
      Temps_Alim     : in Natural := 0) is

      Args : Arguments_Record_Type;
      Seq  : Seq_Type;
   begin
      Args := Arguments_Record_Type'(Id            => Diriger_Aiguillage_Id,
                                     No_Aiguillage => No_Aiguillage,
                                     Direction     => Direction,
                                     Temps_Alim    => temps_alim);
      Emission_Reseau.Envoi (Seq => Seq, Args => Args);
      Reception_Reseau.Recoit (Seq) (Args => Args);
   end Diriger_Aiguillage;



   ------------------------
   --  Attendre_Contact  --
   ------------------------

   --  Cette procŽdure fait attendre (la tache appelante) qu'une
   --  locomotive passe sur le contact transmis en parametre.
   --
   --  Entrees  : No_Contact => Numero du contact dont on attend
   --                           l'activation

   procedure Attendre_Contact (No_Contact: in No_Contact_Type) is
      Args : Arguments_Record_Type;
      Seq  : Seq_Type;
   begin
      Args := Arguments_Record_Type'(Id          => Attendre_Contact_Id,
                                     No_Contact  => No_Contact);
      Emission_Reseau.Envoi (Seq => Seq, Args => Args);
      Reception_Reseau.Recoit (Seq) (Args => Args);
   end Attendre_Contact;


   --------------------
   --  Arreter_Loco  --
   --------------------

   --  Cette procedure arrete la locomotive demandee de maniere
   --  immediate
   --
   --  Entrees  : No_loco   => Numero de la locomotive que l'on veut arreter

   procedure Arreter_Loco (No_Loco: in No_Loco_Type) is
      Args : Arguments_Record_Type;
      Seq  : Seq_Type;
   begin
      Args := Arguments_Record_Type'(Id      => Arreter_Loco_Id,
                                     No_Loco_A => No_Loco);
      Emission_Reseau.Envoi (Seq => Seq, Args => Args);
      Reception_Reseau.Recoit (Seq) (Args => Args);
   end Arreter_Loco;


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
      Vitesse_Future : in Vitesse_Type) is

      Args : Arguments_Record_Type;
      Seq  : Seq_Type;
   begin
      Args := Arguments_Record_Type'
        (Id             => Mettre_Vitesse_Progressive_Id,
         No_Loco_B      => No_Loco,
         Vitesse_Future => Vitesse_Future);
      Emission_Reseau.Envoi (Seq => Seq, Args => Args);
      Reception_Reseau.Recoit (Seq) (Args => Args);
   end Mettre_Vitesse_Progressive;



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
      Etat    : in Boolean) is

      Args : Arguments_Record_Type;
      Seq  : Seq_Type;
   begin
      Args := Arguments_Record_Type'(Id        => Mettre_Fonction_Loco_Id,
                                     No_Loco_C => No_Loco,
                                     Etat      => Etat);
      Emission_Reseau.Envoi (Seq => Seq, Args => Args);
      Reception_Reseau.Recoit (Seq) (Args => Args);
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

   procedure Inverser_Sens_Loco (No_Loco: in No_Loco_Type) is
      Args : Arguments_Record_Type;
      Seq  : Seq_Type;
   begin
      Args := Arguments_Record_Type'(Id        => Inverser_Sens_Loco_Id,
                                     No_Loco_D => No_Loco);
      Emission_Reseau.Envoi (Seq => Seq, Args  => Args);
      Reception_Reseau.Recoit (Seq) (Args => Args);
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

   procedure Mettre_Vitesse_Loco
     (No_Loco: in No_Loco_Type;
      Vitesse: in Vitesse_Type) is

      Args : Arguments_Record_Type;
      Seq  : Seq_Type;
   begin
      Args := Arguments_Record_Type'(Id        => Mettre_Vitesse_Loco_Id,
                                     No_Loco_E => No_Loco,
                                     Vitesse_A => vitesse);
      Emission_Reseau.Envoi (Seq => Seq, Args => Args);
      Reception_Reseau.Recoit (Seq) (Args => Args);
   end Mettre_Vitesse_Loco;


   ---------------------
   --  Demander_Loco  --
   ---------------------

   --  Cette procedure demande a l'utilisateur le numero de la
   --  locomotive qu'il desire utiliser.
   --  Elle demande a l'utilisateur la vitesse a laquelle il desire
   --  actionner la locomotive.
   --  Elle place la locomotive entre deux contacts A et B donnes par
   --  l'appelant.
   --  On suppose l'utilisateur averti et ne commettant pas d'erreurs
   --
   --  Entrees  : Contact_A => Contact delimitant la zone sur laquelle
   --                          la locomotive sera posee (elle va se
   --                          diriger vers ce contact
   --             Contact_B => Contact delimitant la zone sur laquelle
   --                          la locomotive sera posee
   --
   --  Sorties  : Numero    => Numero de la locomotive qui sera pose
   --                          a l'endroit determine
   --             Vitesse   => Vitesse de la locomotive qui sera pose
   --                          a l'endroit determine
   --
   --  13.1.92, P. Breguet sur une idee de Conus et Rappaz EI3 91

   procedure Demander_Loco
     (Contact_A : in Train_Handler.No_Contact_Type;
      Contact_B : in Train_Handler.No_Contact_Type;
      Numero    : out Train_Handler.No_Loco_Type;
      Vitesse   : out Train_Handler.Vitesse_Type) is

      Args : Arguments_Record_Type;
      Seq  : Seq_Type;
   begin
      Args := Arguments_Record_Type'(Id        => Demander_Loco_Id,
                                     Contact_A => Contact_A,
                                     Contact_B => Contact_B,
                                     Numero    => Numero,
                                     Vitesse_B => Vitesse);
      Emission_Reseau.Envoi (Seq => Seq, Args => Args);
      Reception_Reseau.Recoit (Seq) (Args => Args);
      Vitesse := Args.Vitesse_B;
      Numero := Args.Numero;
   end Demander_Loco;

end Train_Handler;
