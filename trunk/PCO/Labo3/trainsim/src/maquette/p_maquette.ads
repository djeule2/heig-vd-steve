------------------------------------------------------------------------------
--
-- Nom du fichier   : P_Maquette.ads
-- Auteur           : P.Girardet sur la base du travail de
--                    M Pascal Binggeli & M Vincent Crausaz
--
-- Date de creation : 22.8.97
-- Derniere modifs. : Juin 1998
-- Raison de la
-- Modification     : 1) Ajout d'une interface graphique
--                    2) Modification de l'exclusion mutuelle sur les
--                       informations constituant la maquette
--
-- Version          : 4.0
-- Projet           : Simulateur de maquette
-- Module           : Maquette
--
-- But              : Module realisant la gestion d'une maquette de
--                    train ainsi que la simulation de l'avance des
--                    locomotives et finalement l'affichage a l'ecran
--                    de cette maquette.
--
--                    Les sous-modules le constituant sont:
--
--
--                    La tache "fenetre" qui cree et gere la fenetre
--                    d'affichage
--
--                    La tache "Simulateur" qui simule le mouvement des
--                    trains sur la maquette.
--
--                    L'objet protege "Objetpartager" qui gere la
--                    synchronisation et les variables partagee entre
--                    les taches "fenetre" et "simulateur"
--
-- Modules appeles   : Text_Io, P_Afficher, Calendar, P_Train, P_Section,
--                     P_Contact, Win32( Glaux, Gl, Glu),
--                     Interface( C, C( String)),
--                     Unchecked_Conversion
--                     Ada.Numerics.Elementary_Functions
--
-- Fonctions
-- exportees        : Activer
--                    Desactive
--                    Init
--                    PoserTrain
--                    EnleverTrain
--                    Mettremodesimulation
--                    MettreVitesseTrain
--                    ChangerDirectionTrain
--                    Dirigeraiguillage
--                    Attendreactivationcontact
--                    Afficherinfosmaquette
--
--
-- Materiel
-- particulier       : Les dll "OpenGl32.dll" et "Glu32.dll" doivent
--                     etre dans le repertoire systeme de windows
--
------------------------------------------------------------------------------

with P_Train; use P_Train;        -- Pour utiliser les objets locomotive
with P_Section;                   -- Pour utiliser les objets rail
with P_Contact;                   -- Pour utiliser les objets contact
with P_Aiguillage;                -- Pour utiliser les objets aiguillage
with P_Couleur;                   -- Pour utiliser les couleurs
with Calendar;                    -- Pour utilisation de l'horloge

package P_Maquette
is

  -- *************************************************************************
  --
  -- exception
  --
  -- *************************************************************************

  -- exception levee si les contacts specifie pour poser une loco sont
  -- incorrects
  Faux_Contact : exception;

  -- *************************************************************************
  --
  -- Types
  --
  -- *************************************************************************

  -- Type pour une longueur de chaine  de caractere.
  subtype T_Longueurchaine is Natural range 0..255;

  -- *************************************************************************
  --
  -- Constante
  --
  -- *************************************************************************

  -- Nombre d'affichage de la maquette par seconde
  Nbraffichageparseconde: constant := 10;

  -- *************************************************************************
  --
  -- Definition du type maquette
  --
  -- *************************************************************************

  -- Nombre d'objets voies qui compose la maquette
  type T_Maquette(Nbrsections         : P_Section.T_Section_Id        := 0;
                  -- Nombre de contacte qui compose la maquette
                  Nbrcontacts         : P_Contact.T_Contact_Id        := 0;
                  -- Nombre d'aiguillage qui compose la maquette
                  Nbraiguillages      : P_Aiguillage.T_Aiguillage_Id  := 0;
                  -- Nombre de train maximum que l'on va par la suite poser
                  -- sur la maquette
                  Nbrtrains           : P_Train.T_Train_Id            := 0;
                  -- Longueur de la chaine de caractere contenant le nom de
                  -- fichier definissant les caracteristiques de la maquette
                  Longueurnomfichier  :  T_Longueurchaine             := 0;
                  -- Longueur de la chaine de caractere contenant une
                  -- description de la maquette et qui se trouve au debut
                  -- du fichier caracterisant la maquette
                  Longueurdescription : T_Longueurchaine              := 0)
  is record
    -- Tableau contenant toutes les
    -- sections avec lesquelles la
    -- maquette est formee
    Sections: P_Section.T_Sections(1..Nbrsections);

    -- Tableau contenant tout les contacts existant sur la maquette.
    Contacts: P_Contact.T_Contacts(1..Nbrcontacts);

    -- Tableau indiquant les contacts les contacte qui ont ete actives
    -- par les locos
    Contacts_Actives : P_Contact.T_Contacts_Actives(1..Nbrcontacts);

    -- Tableau contanant tout les aiguillages de la maquette.
    Aiguillages: P_Aiguillage.T_Aiguillages(1..Nbraiguillages);

    -- Tableau contenant tout les trains qui sont poser sur la maquette
    Trains: P_Train.T_Trains(1..Nbrtrains);

    -- Flag qui indique que la maquette est en fonction.
    Active: Boolean := False;

    -- Nom du fichier de la maquette.
    Nomfichier : String(1..Longueurnomfichier);

    -- Ligne d'information sur la maquette.
    Description: String(1..Longueurdescription);

    -- Mode d'affichage.
    Affichage: Boolean := True;

    -- Mode de la simulation (continu-TRUE/pas a pas-FALSE).
    Continu: Boolean := True;

    -- Indique si les contacts se déclenches une seule fois ou tant que
    -- la locomotive est sur le contact
    Rebond: Boolean := False;

  end record;

  -- Type pour un pointeur sur
  -- une maquette.
  type T_Maquette_Ptr is access all T_Maquette;

  ----------------------------------------------------------------------------
  -- Procedure: Init
  -- But      : Procedure qui charge les caracteristiques
  --            d'une maquette a partir d'un fichier et prepare
  --            l'objet protege maquette a etre utilise
  --
  --            Lit les informations sur les sections,
  --            les contacts et les aiguillages et place les
  --            sections dans le plan en commencant a l'origine
  --            par la section spécifiee comme le centre de la
  --            maquette
  --
  --
  -- Entrees  : Nomfichier     => Nom du fichier descriptif qui
  --                              contient les informations utile
  --                              a la creation de la maquette.
  --                              ( Nom et extension)
  --
  --
  --
  --            Modifie la variable protegee "Maquette"
  --
  ----------------------------------------------------------------------------
  procedure Init(Nomfichier: in String);

  ----------------------------------------------------------------------------
  --
  -- Procedure: PoserTrain
  -- But      : Procedure qui pose un train sur la maquette en
  --            definissant son numero externe, son indexe dans la
  --            liste des train, sa position, sa taille et sa couleur
  --            et elle rend se train actif donc:
  --
  --               1) On peut modifier ces parametres vitesse,
  --                  sens de marche, etc.
  --               2) On voit le train affiche sur la maquette
  --
  --
  --
  -- Entrees  : TrainID    => Identificateur interne du train
  --                            (valeur de 1 a NbrTrainsMax
  --                            corespondant a l'index de l'ensemble
  --                            de train de la maquette)
  --
  --            NoTrain   => Le numero du train sur la maquette
  --                            (identificateur externe pouvant
  --                            prendre  n'inporte quelle valeur
  --                            entiere)
  --
  --            ContactID_A => Identificateur du Contact delimitant
  --                           la zone sur laquelle la locomotive
  --                           sera posee (elle va se diriger
  --                           vers ce contact)
  --
  --            ContactID_B => Identificateur du du Contact delimitant
  --                           la zone sur laquelle la locomotive
  --                           sera posee
  --
  --            Position    => Position de la tete du train sur la
  --                            section (defaut:0.0)
  --
  --            Couleur      => Couleur avec laquelle le train sera
  --                            dessine (defaut:Magenta)
  --
  --            Modifie la variable protegee "Maquette"
  --
  ----------------------------------------------------------------------------
  procedure Posertrain(Trainid: in P_Train.T_Train_Id;
                       Notrain: in Integer;
                       Contactid_A: in P_Contact.T_Contact_Id;
                       Contactid_B: in P_Contact.T_Contact_Id;
                       Position: in P_Section.T_Position := 0.0;
                       Couleur: in P_Couleur.T_Couleur :=
                                   P_Couleur.Magenta);


  ----------------------------------------------------------------------------
  -- Procedure: EnleverTrain
  -- But      : Procedure qui enleve un train de la maquette
  --            donc elle le rend inactif donc:
  --
  --               1) On ne peut plus modifier ces parametres vitesse,
  --                  sens de marche, etc.
  --               2) On ne le voie plus sur l'ecran
  --
  -- Entree   : TrainID    => Identificateur interne du train
  --                            (valeur de 1 a NbrTrainsMax
  --                            corespondant a l'index de l'ensemble
  --                            de train de la maquette)
  --
  --            Modifie la variable protegee "Maquette"
  --
  ----------------------------------------------------------------------------
  procedure Enlevertrain(Trainid: in P_Train.T_Train_Id);


  ----------------------------------------------------------------------------
  --
  -- Procedure: MettreModeSimulation
  -- But      : Procedure qui permet de fixer les modes de simulation
  --
  -- Entrees  : Continu      => Flag indiquant si on utilise le mode
  --                            continu. Soit Continu (true) le
  --                            simulateur ne s'arrete pas soit
  --                            Pas a pas (false) le simulateur
  --                            s'arrete apres chaque pas de simulation
  --                            et l'utilisateur doit cliquer sur
  --                            l'icone P pou continuer.
  --
  --            Affichage    => Flag indiquant si on utilise le mode
  --                            Affichage. Soit Affichage (true)
  --                            le simulateur affiche a l'ecran les
  --                            informations consernant la maquette
  --                            a chaque pas de simualtion.
  --                            Soit Pas d'affichage (false) et on
  --                            affiche rien.
  --            Rebond       => Flag indiquant si on utilise le mode
  --                            rebond. Soit avec rebond (true) le simulateur
  --                            declenche plusieurs fois un contacts au passage
  --                            d'une locomotive. Soit le mode sans rebond
  --                            (False) le simulateur declenche une seul fois
  --                            le contact au passage d'un train
  --
  -- Remarque  : Si une collision est detectee ou un deraillement
  --             est detectee on l'affiche toujours.
  --
  --            Modifie la variable protegee "Maquette"
  --
  ----------------------------------------------------------------------------
  procedure Mettremodesimulation (Continu   : in     Boolean ;
                                  Affichage : in     Boolean ;
                                  Rebond    : in     Boolean );

  ----------------------------------------------------------------------------
  -- Procedure: MettreVitesseTrain
  -- But      : Procedure qui permet de spécifier la vitesse
  --            d'un train.
  --
  --
  -- Entree   :  TrainID     => Identificateur interne du train
  --                            (valeur de 1 a NbrTrainsMax
  --                            corespondant a l'index de l'ensemble
  --                            de train de la maquette)
  --             Vitesse    => La vitesse du train
  --
  --             Modifie la variable protegee "Maquette"
  --
  ----------------------------------------------------------------------------
  procedure Mettrevitessetrain (Trainid: in     P_Train.T_Train_Id;
                                Vitesse: in     P_Train.T_Vitesse);

  ----------------------------------------------------------------------------
  --
  -- Procedure: ChangerDirectionTrain
  -- But      : Procedure qui permet d'inverser le sens de marche
  --            d'un train.
  --
  --
  -- Entree   :  TrainID     => Identificateur interne du train
  --                            (valeur de 1 a NbrTrainsMax
  --                            corespondant a l'index de l'ensemble
  --                            de train de la maquette)
  --
  --             Modifie la variable protegee "Maquette"
  --
  ----------------------------------------------------------------------------
  procedure Changerdirectiontrain(Trainid: in     P_Train.T_Train_Id);

  ----------------------------------------------------------------------------
  --
  -- Procedure: DirigerAiguillage
  -- But      : Procedure qui permet de modifier la direction d'un
  --            aiguillage
  --
  -- Entree   :  Aiguillageid=> Identificateur de l'aiguillage
  --                            (son numero externe qui correspond
  --                            a l'indexe de l'objet dans le
  --                            tableau des aiguillages)
  --
  --
  --             Direction   => La nouvelle direction que
  --                            aiguillage va prendre et qui va
  --                            peut etre modifier son etat
  --
  --            Modifie la variable protegee "Maquette"
  --            Modifie la variable protegee "Debut"
  --
  ----------------------------------------------------------------------------
  procedure Dirigeraiguillage(Aiguillageid: in P_Aiguillage.T_Aiguillage_Id;
                              Direction   : in P_Section.T_Direction);


  ----------------------------------------------------------------------------
  --
  -- Procedure : AttendreActivationContact
  -- But    : Procedure pour la gestion des contacts. Elle fait
  --          attendre (la tache appelante) qu'une locomotive passe
  --          sur le contact transmis en parametre.
  --
  -- Entrees  : No_Contact=>   Numero du contact dont on attend
  --                           l'activation
  --
  ----------------------------------------------------------------------------
  procedure Attendreactivationcontact(No_Contact : P_Contact.T_Contact_Id);

  ----------------------------------------------------------------------------
  --
  -- Procedure: Activer
  -- But      : Procedure qui active la simulation.
  --            A partir de ce moment la maquette est prete pour la
  --            simulation.
  --
  --            Elle active la maquette et fait demarrer la
  --            simulation
  --
  -- Remarque : Cette procedure est en dehors de l'objet protege
  --            "protmaquette" car on ne peut effectuer de
  --            rendez-vous avec une tache dans un objet protege
  --
  ----------------------------------------------------------------------------
  procedure Activer;

  ----------------------------------------------------------------------------
  --
  -- Procedure: Desactiver
  -- But      : Procedure qui desactive la simulation.
  --
  --            Elle desactive la maquette et arrete la simulation
  --
  -- Remarque : Cette procedure est en dehors de l'objet protege
  --            "protmaquette" car on ne peut effectuer de
  --            rendez-vous avec une tache dans un objet protege
  --
  ----------------------------------------------------------------------------
  procedure Desactiver;

  ----------------------------------------------------------------------------
  --
  -- Procedure: AfficherInfosMaquette
  -- But      : Procedure qui affiche dans la fenetre textuelle
  --            des informations generales sur la maquette.
  --
  --            Soit:
  --            1) La description qui etait au debut du fichier
  --               decrivant la maquette
  --            2) Le nom du fichier  decrivant la maquette
  --            3) Le nombre de section
  --            4) Le nombre de contacts
  --            5) Le nombre d'aiguillages
  --
  --            Consulte la variable protegee "Maquette"
  --
  ----------------------------------------------------------------------------
  procedure Afficherinfosmaquette;


  -------------------
  -- Etat_Maquette --
  -------------------

  --  Etat_maquette indique si l'objet protŽgŽ Etat_Maquette sera
  --  passant ou non.
  type Type_Etat is (Maquette_Prete, Maquette_Non_Disponible);

  --  Etat_maquette permet au backend openGL de bloquer momentanŽment
  --  l'entrŽe dans la boucle principale du simulateur.

  protected Etat_Maquette is
     entry Positionner (Nouvel_Etat : Type_Etat);
     entry Prete;
  private
     Etat : Type_Etat := Maquette_Non_Disponible;
  end Etat_Maquette;


private

  -- Types necessaires pour la memorisation des numeros
  -- des locomotives utilises dans la legende
  type Assoc_Numero_Couleur_Type
    is record
      Numero  : P_Train.T_Train_Id := P_Train.T_Train_Id'First;
      Couleur : P_Couleur.T_Couleur;
    end record;
  type Tab_Numeros_Et_Couleurs_Locos_Type is array (T_Train_Id)
    of Assoc_Numero_Couleur_Type;

  -- Controles de redimensionnement de la fenetre de legende
  -- La taille de la fenetre de legende est prevue pour afficher les
  -- informations de 3 locomotives. Si ce nombre est depasse, il est
  -- necesaire d'agrandir la fenetre.
  Max_Nb_Locos_Affichables : constant Integer := 3;
  Cpt_Locos : Natural := 0;
  AgrandirFenetre : Boolean := False;


  --   ***********************************************************************
  --
  --   Objet protege utilise par les taches Affichage et simulation
  --
  --   ***********************************************************************
  ----------------------------------------------------------------------------
  -- Objet protege: Objetpatager
  -- But          : Realiser la sychronisation entre la tache affichage
  --                et la tache simulation pour permettre:
  --
  --               1) Afficher que lorsque c'est necessaire
  --               2) Attendre que l'affichage soit termine avant de
  --                  simuler le pas suivant
  --               3) Attendre un temps minimum entre deux pas de
  --                  simulation (pour ne pas avoir de deplacement
  --                  trops rapide
  --
  --
  ----------------------------------------------------------------------------
  protected Objetpartager
  is

    --------------------------------------------------------------------------
    --
    -- Procedure: Maquettemodifiee
    -- But      : Indiquer que la maquette a ete modifiee pour
    --            que le nouvel affichage soit realise.
    --
    --            Procedure utilisee par le simulateur pour
    --            indiquer a la tache fenetre que la maquette a
    --            change (les trains ont bouge) et qu'il doit
    --            rafraichir l'affichage.
    --
    --            Modifie la variable protegee "Nouveau" qui indique
    --            que la maquette a ete modifiee
    --
    --            Memorise l'heure a laquelle le simulateur demande
    --            l'affichage de la maquette pour (dans le cas ou
    --            l'affichage est rapide) maintenir cette affichage
    --            un certain temps et que ainsi les trains ne se
    --            deplace pas trop vite
    --
    --------------------------------------------------------------------------
    procedure Maquettemodifiee;

    --------------------------------------------------------------------------
    --
    -- Procedure: Affichagetermine
    -- But      : Indiquer que la maquette affichee pour
    --            que le simulateur puisse effectuer le pas suivant.
    --
    --            Procedure utilisee par la tache d'affichage pour
    --            indiquer a la tache simulateur que la maquette a
    --            ete affichee et qu'il peut continuer la simulation
    --
    --            Modifie la variable protegee "Continue" qui indique
    --            que la maquette a ete affichee
    --
    --------------------------------------------------------------------------
    procedure Affichagetermine;

    --------------------------------------------------------------------------
    --
    -- Procedure: Quittance
    -- But      : Indiquer que l'utilisateur a effectue une quittance
    --            ( il a clique sur l'icone P (pas a pas))
    --
    --            Procedure utilisee lorsque l'utilisateur clique sur
    --            l'icone representant la lettre P pour indiquer
    --            au simulateur que que l'on peut continuer la
    --            simulation.
    --
    --            Modifie la variable protegee "La_quittance" qui
    --            indique si une quittance de l'utilisateur a ete
    --            effectuee
    --
    --------------------------------------------------------------------------
    procedure Quittance;

    --------------------------------------------------------------------------
    --
    -- Procedure: Mettre_Mode_Rapide
    -- But      : Mettre en fonction le mode rapide de simulation
    --
    --            Procedure utilisee lorsque l'utilisateur clique sur
    --            l'icone representant la lettre L pour indiquer
    --            au simulateur que l'on passe en mode rapide de
    --            simulation (plusieurs pas de simulation sans affichage)
    --
    --            Modifie la variable protegee "Simulationrapide" qui
    --            indique le mode de simulation
    --
    --------------------------------------------------------------------------
    procedure Mettre_Mode_Rapide;

    --------------------------------------------------------------------------
    --
    -- Procedure: Mettre_Mode_Lent
    -- But      : Mettre en fonction le mode lent de simulation
    --
    --            Procedure utilisee lorsque l'utilisateur clique sur
    --            l'icone representant la lettre R pour indiquer
    --            au simulateur que l'on passe en mode lent de
    --            simulation (un seul pas de simulation par affichage)
    --
    --            Modifie la variable protegee "Simulationrapide" qui
    --            indique le mode de simulation
    --
    --------------------------------------------------------------------------
    procedure Mettre_Mode_Lent;

    --------------------------------------------------------------------------
    --
    -- Procedure: Mode_Rapide
    -- But      : Indique si le mode de simulation rapide est en
    --            fonction
    --
    --            Fonction utilisee par le simavance
    --            dans quel mode on se trouve et pour pouvoir
    --            simuler en consequence (un seul ou plusieurs pas
    --            de simulation par affichage)
    --
    -- Retour   : Une indication sur le mode de simulation
    --            (Rapide => true, Lent => false)
    --
    --            Consulte la variable protegee "Simulationrapide" qui
    --            indique le mode de simulation
    --
    --------------------------------------------------------------------------
    function Mode_Rapide return Boolean;

    --------------------------------------------------------------------------
    --
    -- Entree   : Quittance_effectuee
    -- But      : Entree bloquante tant que l'utilisateur n'a pas
    --            Effectue le quittancement en appuyant sur l'icone
    --            repesentant la lettre P.
    --
    --            Entree utilisee pour bloquer le simulateur
    --            jusqu'a ce que l'utilisateur demande la poursuite
    --            de la simulation. En cliquant sur La lettre P
    --            l'utilisateur active la procedure "Quittance" qui
    --            modifie la variable protegee "La_quittance" et qui
    --            va permettre au simulateur de continuer si il
    --            attend ou de passer directement au pas suivant
    --            si il attend pas
    --
    --------------------------------------------------------------------------
    entry Quittance_Effectuee;

    --------------------------------------------------------------------------
    --
    -- Entree   : Besoinafficher
    -- But      : Entree bloquante tant qu'un affichage de la maquette
    --            n'est pas necessaire
    --
    --            Entree utilisee par la tache d'affichage pour ne pas
    --            afficher la maquette tant que le simulateur ne
    --            l'a pas modifie
    --
    --            Modifie la variable protegee "Nouveau" qui indique
    --            que la maquette a ete modifiee
    --
    --------------------------------------------------------------------------
    entry Besoinafficher;

    --------------------------------------------------------------------------
    --
    -- Entree   : Peutcontinuer
    -- But      : Entree bloquante tant que la tache d'affichage
    --            n'a pas terminer le dessin de la maquette a l'ecran
    --            et que un temps minimum ne soit passe.
    --
    --            Entree utilisee pour bloquer le simulateur soit:
    --
    --            1) jusqu'a ce que l'affichage d'un nouvel etat
    --               de la maquette soit terminee pour le cas ou
    --               l'affichage et lent.
    --
    --            2) jusqu'a un temps determine pour que le vitesse
    --               des trains a l'ecran ne soit pas trop grande
    --               pour le cas ou l'affichage est rapide
    --
    --            Le temps est determine par une constante indiquant
    --            le nombre d'affichage par seconde. On attend donc
    --            la fraction de seconde necessaire a N affichage
    --            par seconde
    --
    --            Modifie la variable protegee "Continue" qui indique
    --            que la maquette a ete affichee
    --
    --------------------------------------------------------------------------
    entry Peutcontinuer;

    --------------------------------------------------------------------------
    --
    -- Procedure: Mettre_Pause
    -- But      : Mettre le simulateur en pause lors du fonctionement
    --            continu
    --
    --            Procedure utilisee lorsque l'utilisateur clique sur
    --            l'icone representant la lettre P pour indiquer
    --            au simulateur qu'il veut une pause
    --
    --            Modifie la variable protegee "Pause" qui indique si on
    --            est en pause ou pas
    --
    --------------------------------------------------------------------------
    procedure Mettre_Pause;

    --------------------------------------------------------------------------
    --
    -- Procedure: Enlever_Pause
    -- But      : Redemarre le simulateur lorsqu'il est en pause lors du
    --            fonctionement continu
    --
    --            Procedure utilisee lorsque l'utilisateur clique sur
    --            l'icone representant la lettre P pour indiquer
    --            au simulateur qu'il veut redemarrer la simulation
    --
    --            Modifie la variable protegee "Pause" qui indique si on
    --            est en pause ou pas
    --
    --------------------------------------------------------------------------
    procedure Enlever_Pause;

    --------------------------------------------------------------------------
    --
    -- Entree   : Attendre_Pause
    -- But      : Entree bloquante tant que l'on est en pause
    --
    --            Entree appelee par la tache de simulation qui
    --            attendra lorsque l'on est en pause ou qui sinon
    --            continuera
    --
    --            Consulte la variable protegee "Pause" qui indique
    --            si on est en pause ou pas
    --
    --------------------------------------------------------------------------
    entry Attendre_Pause;

    --------------------------------------------------------------------------
    --
    -- Fonction : Mode_Pause
    -- But      : Indique si on est en pause ou pas
    --
    -- Retour   : Une indication si la pause est active ou pas
    --            (Pause => true, Pas de pause => false)
    --
    --            Consulte la variable protegee "Pause" qui indique
    --            si on est en pause ou pas
    --
    --------------------------------------------------------------------------
    function Mode_Pause
      return Boolean;

    --------------------------------------------------------------------------
    --
    -- Procedure: LegendeModifiee
    -- But      : Indiquer que la legende a ete modifiee pour
    --            que le nouvel affichage soit realise.
    --
    --            Procedure utilisee par le simulateur pour
    --            indiquer a la tache fenetre que la legende a
    --            change.
    --
    --            Modifie la variable protegee "MiseAJourLegende" qui
    --            indique que la legende a ete modifiee
    --
    --------------------------------------------------------------------------
    procedure LegendeModifiee;

    --------------------------------------------------------------------------
    --
    -- Entree   : MettreAJourLegende
    -- But      : Entree bloquante tant qu'un affichage de la legende
    --            n'est pas necessaire
    --
    --            Entree utilisee par la tache d'affichage pour ne pas
    --            afficher la legende tant que le simulateur ne
    --            l'a pas modifie
    --
    --            Modifie la variable protegee "MiseAJourLegende" qui
    --            indique que la legende a ete modifiee
    --
    --------------------------------------------------------------------------
    entry MettreAJourLegende;

    --------------------------------------------------------------------------
    --
    -- Procedure : MemoriserComposantsLoco
    -- But       : Memoriser le numero et la couleur de la nieme locomotive
    --
    --------------------------------------------------------------------------
    procedure MemoriserComposantsLoco (Numero  : T_Train_Id;
                                       Couleur : P_Couleur.T_Couleur);

    --------------------------------------------------------------------------
    --
    -- Function : FournirComposantsDeLoco
    -- But      : Fournir le numero et la couleur de la nieme locomotive
    -- Retour   : Le numero
    --
    --------------------------------------------------------------------------
    function FournirComposantsDeLoco (Indice : T_Train_Id)
      return Assoc_Numero_Couleur_Type;

  private
    -- Indique si l'utilisateur
    -- demande une pause en mode continu
    Pause : Boolean := False;

    -- Indique si la maquette a ete
    -- modifiee par le simulateur
    Nouveau : Boolean := True;

    -- Indique si la tache d'affichage
    -- a termine de dessiner la fenetre
    Continue : Boolean := False;

    -- Contient l'heure du debut de
    -- l'affichage
    Heuredebutaffichage : Calendar.Day_Duration;

    -- Indique si l'utilisateur a
    -- effectue un quittancement pour
    -- que le simulateur puisse passer
    -- au pas suivant en mode pas a pas
    La_Quittance : Boolean := False;

    -- Indique si le simulateur
    -- fonctionne en mode rapide ou lent
    Simulationrapide : Boolean := False;

    -- Indique si il faut remettre la legende a jour
    MiseAJourLegende : Boolean := False;

    -- Tableau des numeros et des couleurs des locomotives
    Tab_Numeros_Et_Couleurs_Locos : Tab_Numeros_Et_Couleurs_Locos_Type;

  end Objetpartager;


  --  ************************************************************************
  --
  --  Objet protege Protmaquette
  --
  --  ************************************************************************
  ----------------------------------------------------------------------------
  -- Objet protege: Protmaquette
  -- But          : Garantir l'exclusion mutuelle sur l'objet maquette
  --                qui contient les informations sur l'etat des trains,
  --                des contacts et des aiguillage.
  --
  ----------------------------------------------------------------------------
  protected Protmaquette
  is
    -- Pour obtenir la ressource critique
    -- maquette
    entry Acquerir;

    -- Pour rendre la ressource critique
    -- maquette
    entry Rendre;

    -- Entree bloquante tant qu'un train n'est passe ou et
    -- pose sur un contact.
    --
    -- Il y a une entree par contact et cette entree est
    -- fermee tant que:
    -- 1) un train n'est pas poser sur le contacte (Estactive)
    --
    -- 2) un train n'est pas passe dessus sans s'arreter
    --    (contacts_actives)
    -- 3) la maquette n'est pas alimentee
    --
    -- le tableau "contact_actives" enregistre tout les contacts
    -- qui ont ete occupes durant les procedures "poser" et
    -- surtout "avancer" ainsi on grade une trace des contacts
    -- occupe puis liberer dans la meme procedure et grace a cela
    -- on peut liberer une tache qui attendait ce contact
    --
    --
    -- Modifie la variable "Maquette"
    entry Attendreactivationcontact(P_Contact.T_Contact_Id);

    --------------------------------------------------------------------------
    --
    -- Fonction : NbrTachesAttend
    -- But      : Indique le nombre de taches qui attendent sur le contact
    --            passe en parametre
    --
    -- Retour   : le nombre de contact
    --
    --
    --------------------------------------------------------------------------
    function NbrTachesAttend (Contact_Id :P_Contact.T_Contact_Id)
      return Integer;

  private
    -- Variable proteger indiquant si
    -- ressource critique maquette est
    -- utilisee
    Aqui: Boolean:=False;

  end Protmaquette;

  ----------------------------------------------------------------------------
  --
  -- Procedure : Reinitialiseraffichage
  -- But       : Demande a la procedure d'affichage de la maquette
  --             de recalculer tout les sections et de ne pas
  --             afficher l'image memorisee de la maquette
  --
  --             Modifie la variable protegee "Debut"
  --
  ----------------------------------------------------------------------------
  procedure Reinitialiseraffichage;

  ----------------------------------------------------------------------------
  --
  -- procedure: AfficherMaquette
  -- But      : Dessine la maquette (section et train) avec les
  --            fonctions de la librairie graphique OpenGL.
  --
  --            Pour accelerer l'affichage on ne calcule pas a
  --            chaque affichage les sections. Elles sont calculee
  --            lors de la premiere execution de la procedure puis
  --            on memorise l'image dans un buffer et comme cela
  --            lors des execution suivante on affichera le buffer
  --            sur lequel on dessine les train.
  --
  --            Mais certaine modification necessite de recalculer
  --            toute la maquette on sit que c'est le cas si la
  --            variable protegee "Debut" est mise a True
  --
  --            Consulte la variable protegee "Maquette"
  --            Modifie la variable protegee "Debut"
  --
  ----------------------------------------------------------------------------
  procedure Affichermaquette;

  ----------------------------------------------------------------------------
  --
  -- Fonction : ModeContinu
  -- But      : Fonction indiquant si le mode de simulation
  --            continu est active. Soit il est active et les trains
  --            se deplacent sans interuption ou il ne l'est pas
  --            et on fonctionne en mode Pas a pas, c'est-a-dire
  --            que l'on arrete la simulation apres chaque deplacement
  --            des locomotives et on attent une quittance de
  --            l'utilisateur (quittance fournie en cliquant sur
  --            l'icone P en bas d ela fenetre graphique
  --
  -- Retour   : Indication si le mode continu est actif
  --            (True  => actif donc simulation sans arret
  --             False => inactif donc simulation pas a pas)
  --
  --            Consulte la variable protegee "Maquette"
  --
  ----------------------------------------------------------------------------
  function Modecontinu
    return Boolean;

  ----------------------------------------------------------------------------
  --
  -- Procedure : AfficherLegende
  -- But       : (Re)afficher la legende de correspondance des numeros et
  --             des couleurs des locomotives
  --
  ----------------------------------------------------------------------------
  procedure AfficherLegende;

end P_Maquette;
