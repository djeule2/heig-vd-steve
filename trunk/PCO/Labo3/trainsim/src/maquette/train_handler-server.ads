--------------------------------------------------------------------------
--
-- Nom du fichier   : Train_Handler-server.ads
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
-- Raison           : Amélioration et adaptation aux nouvelles maquettes de trains
--
-- Modifications    : janvier 99 P. Girardet
-- Raison           : Amélioration
--
-- Modifications    : juillet 99 P. Girardet
-- Raison           : Traduction des messages utilisateurs en anglais
--
-- Modifications    : DŽcembre 2003 D. Madon
-- Raison           : Connexion au travers des sockets
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
package Train_Handler.Server is


-- ***********************************************************************
--
--  Sous-Programmes
--
-- ***********************************************************************

  -------------------------------------------------------------------------
  --                                                                     --
  -- Procedure: Demander_Loco                                            --
  -- But      : Cette procedure demande a l'utilisateur le numero        --
  --            de la locomotive  qu'il desire utiliser.                 --
  --                                                                     --
  --            Elle demande a l'utilisateur la vitesse a laquelle       --
  --            il desire faire rouler la locomotive                     --
  --                                                                     --
  --            Elle permet de placer  la locomotive entre deux contacts --
  --            A et B donnes par l'appelant.                            --
  --                                                                     --
  --            On suppose l'utilisateur averti et ne commettant         --
  --            pas d'erreurs                                            --
  --                                                                     --
  -- Entrees  : Contact_A => Contact delimitant la zone sur laquelle la  --
  --                         locomotive sera posee (elle va se diriger   --
  --                         vers ce contact)                             --
  --            Contact_B => Contact delimitant la zone sur laquelle la  --
  --                         locomotive sera posee                       --
  --                                                                     --
  --                                                                     --
  -- Sorties  : Numero    => Numero de la locomotive qui sera posee a    --
  --                         l'endroit determine                         --
  --            Vitesse   => Vitesse de la locomotive qui sera posee a   --
  --                         l'endroit determine                         --
  --                                                                     --
  -------------------------------------------------------------------------
  procedure Demander_Loco (Contact_A : in Train_Handler.No_Contact_Type;
                           Contact_B : in Train_Handler.No_Contact_Type;
                           Numero    : out Train_Handler.No_Loco_Type ;
                           Vitesse   : out Train_Handler.Vitesse_Type);

  -------------------------------------------------------------------------
  --
  -- Procedure: Init_Maquette
  -- But      : Cette procedure initialise la maquette reelle ou le
  --            simulateur. Elle doit etre executee avant toute utilisation
  --            des autres procedures. Elle effectue aussi le travail fourni
  --            par "Mettre_Maquette_En_Service"
  --
  -------------------------------------------------------------------------
  procedure Init_Maquette;

  -------------------------------------------------------------------------
  --
  -- Procedure: Mettre_Maquette_Hors_Service
  -- But      : Cette procedure permet de couper l'alimentation de la
  --            maquette, donc de stopper toute activite sur la maquette
  --
  -------------------------------------------------------------------------
  procedure Mettre_Maquette_Hors_Service;


  -------------------------------------------------------------------------
  --
  -- Procedure: Mettre_Maquette_En_Service
  -- But      : Cette procedure permet de retablir l'alimentation de la
  --            maquette, donc de reactive toute la maquette. Elle n'a
  --            pas besoin d'etre appelee apres "Init_Maquette"
  --
  -------------------------------------------------------------------------
  procedure Mettre_Maquette_En_Service;

  -------------------------------------------------------------------------
  --
  -- Procedure: Diriger_Aiguillage
  -- But      : Procedure pour le pilotage des aiguillages. Elle
  --            permet de changer la direction de l'aiguillage
  --            mentionne
  --
  -- Entrees  : No_Aiguillage => Le numero de l'aiguillage.
  --
  --            Direction  =>  La direction de l'aiguillage (Tout_droit ou
  --                           Devie)
  --
  --            Temps_alim =>  Le temps d'alimentation minimale de la bobine
  --                           de l'aiguillage, en dixiemes de seconde. En
  --                           general, la valeur par defaut (0) suffit.
  --
  -- NB       : Dans le cas d'un aiguillage courbe, "Tout_Droit" correspond
  --            a la voie interieure.
  --
  -- Attention: Si un train se trouve sur l'aiguillage lorsque l'on
  --            modifie sa direction, celui-ci va derailler.
  --            De plus, si l'aiguillage a deja ete positionne par un appel
  --            a "Diriger_Aiguillage" et qu'un nouvel appel est effectue
  --            pour le placer dabns la meme position, cet appel est annule
  --            et aucun ordre n'est envoye a l'aiguillage.

  ---------------------------------------------------------------------------
  procedure Diriger_Aiguillage
    (No_Aiguillage : in No_Aiguillage_Type;
     Direction     : in T_Direction;
     Temps_Alim    : in Natural := 0);

  -------------------------------------------------------------------------
  --
  -- Procedure: Attendre_Contact
  -- But      : Procedure pour la gestion des contacts. Elle fait
  --            attendre (la tache appelante) qu'une locomotive passe
  --            sur le contact transmis en parametre.
  --
  -- Entrees  : No_Contact=>   Numero du contact dont on attend
  --                           l'activation
  --
  -------------------------------------------------------------------------
  procedure Attendre_Contact(No_Contact: in No_Contact_Type);

  -------------------------------------------------------------------------
  --
  -- Procedure: Arreter_Loco
  -- But      : Cette procedure arrete la locomotive demandee de
  --            maniere immediate
  --
  -- Entrees  : No_loco   => Numero de la locomotive que l'on veut arreter
  --
  -------------------------------------------------------------------------
  procedure Arreter_Loco
    (No_Loco : in No_Loco_Type);

  -------------------------------------------------------------------------
  --
  -- Procedure: Mettre_Vitesse_Progressive
  -- But      : Cette procedure effectue un changement progressif
  --            de la vitesse de la locomotive demandee.
  --            Cette variation de vitesse va de la vitesse actuelle
  --            a la vitesse passee en parametre, par palier.
  --
  -- Entrees  : No_loco   => Numero de la locomotive dont on veut faire
  --                         varier la vitesse
  --            Vitesse_Futur => Vitesse que la locomotive aura apres
  --                             le changement de vitesse
  --
  -- REMARQUE: Dans le simulateur cette procedure agit comme la fonction
  --           "Mettre_Vitesse_Loco". c'est-a-dire que l'acceleration est
  --           immediate (de la vitesse actuelle a la vitesse specifiee)
  --
  -------------------------------------------------------------------------
  procedure Mettre_Vitesse_Progressive
    (No_Loco        : in No_Loco_Type;
     Vitesse_Future : in Vitesse_Type);

  -------------------------------------------------------------------------
  --
  -- Procedure: Mettre_Fonction_Loco
  -- But      : Cette procedure permet d'allumer ou d'eteindre les phares
  --            de la locomotive. Pour eteindre les phares "Etat" doit
  --            valoir "False", Pour les allumer "Etat" doit valoir "True"
  --
  -- Entrees  : No_loco   => Numero de la locomotive dont on veut allumer
  --                         ou eteindre les phares
  --            Etat      => Indique si l'on effectue un allumage "True"
  --                         ou une extinction.
  --
  -- REMARQUE: Dans le simulateur cette fonction n'a aucun effet. Les
  --           locomotives representees par des rectangles, possedent une
  --           partie jaune indiquant le sens de déplacement. L'utilisation
  --           des phares n'est donc plus utile.
  --
  -------------------------------------------------------------------------
  procedure Mettre_Fonction_Loco
    (No_Loco : in No_Loco_Type;
     Etat    : in Boolean);


  -------------------------------------------------------------------------
  --
  -- Procedure: Inverser_Sens_Loco
  -- But      : Cette procedure permet de changer les sens de marche de
  --            la locomotive. Elle l'arrete si sa vitesse est non nulle,
  --            puis la fait redemarrer dans l'autre sens a la meme vitesse.
  --
  -- Entrees  : No_loco   => Numero de la locomotive dont on veut modifier
  --                         le sens de marche
  --
  -------------------------------------------------------------------------
  procedure Inverser_Sens_Loco(No_Loco: in No_Loco_Type);


  -------------------------------------------------------------------------
  --
  -- Procedure: Mettre_Vitesse_Loco
  -- But      : Cette procedure transmet l'ordre a la locomotive de
  --            passer a la vitesse transmise.
  --
  -- Entrees  : No_loco   => Numero de la locomotive dont on veut modifier
  --                         la vitesse
  --            Vitesse   => Vitesse que l'on veut affecter a la locomotive
  --
  -------------------------------------------------------------------------
  procedure Mettre_Vitesse_Loco(No_Loco: in No_Loco_Type;
                                Vitesse: in Vitesse_Type);


end Train_Handler.Server;
