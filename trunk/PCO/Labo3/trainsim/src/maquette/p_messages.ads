--------------------------------------------------------------------------
--
-- Nom du fichier    : P_Messages.ads
-- Auteur            : P.Girardet
--
-- Date de creation  : Mars 99
-- Derniere Modifs.  : Juillet 99
-- Raison de la        Ajout de messages
-- Modification      :
--
-- Version           : 3.1
-- Projet            : Simulateur de maquette
-- Module            : Messages
-- But               : Fournit les types, les constants et les Paquetages utiles
--                     pour le dialogue avec l'utilisateur.
--                     Permet ainsi de ne modifier que le present fichier pour
--                     adapter le simulateur dans une autre langue.
--
-- Modules appeles   :
--
--------------------------------------------------------------------------
package P_Messages is

                                  -- Type pour identifier le mode d'affichage
  type T_Mode_Aff is (m,n);
                                  -- Type pour identifier le mode avec ou
                                  -- sans rebonds
  type T_Mode_Reb is (r,n);
                                  -- Type pour identifier le mode
                                  -- d'execution pas a pas ou continu
  type T_Mode_Execution is (s,c);

                                  -- Pour memoriser la reponse de
                                  -- l'utilisateur sur le mode de
                                  -- fonctionnement "Pas a pas" ou "Continu"
  Mode_fonc: T_Mode_Execution := c;

                                  -- Pour memoriser la reponse de
                                  -- l'utilisateur sur le mode avec ou sans
                                  -- affichage
  Mode_Aff: T_Mode_Aff := n;

                                  -- Pour memoriser la reponse de l'utilisateur
  Mode_Rebond : T_Mode_Reb := r;  -- sur le mode avec ou sans rebonds





  Titre              : constant string := "Railroad Model Simulator";
  Titre_Legende      : constant string := "Legende";

  -- Corps Train_Handler
  Copyright          : constant string := "(C) 1999-2004 eivd, Real Time Laboratory, Version 4.0";
  Quel_Maquette      : constant string := "Select the model to use";
  Choix_Maquette     : constant string := "Choose A1, A2, B1, or B2 : ";
  Erreur_Maquette    : constant string := "The model you selected is invalid";
  Recommencer        : constant string := "Please retry";
  Quel_Mode_Exe      : constant string := "Select the operating mode step by step or continous execution";
  Choix_Mode_Exe     : constant string := "Choose (S)tep by step ou (C)ontinous execution (default C): ";
  Erreur_Mode        : constant string := "The operating mode you selected is invalid";
  Quel_Mode_Aff      : constant string := "Select the operating mode with or without simulator messages";
  Choix_Mode_Aff     : constant string := "Choose (M)essages or (N)o messages (default N)            : ";
  Quel_Mode_Reb      : constant string := "Select the operating mode with rebounds or without rebounds";
  Choix_Mode_Reb     : constant string := "Choose (R)ebounds ou (N)o rebounds (default R)            : ";
  Ind_Fin_Simul      : constant string := "Type CTRL-C to stop the simulation.";
  Ind_Debut_Simul    : constant string := "Type RETURN to begin the simulation.";
  Connexion_Socket   : constant string := "Connection established from node ";

  -- Demander_Loco
  Quel_No_Loco       : constant string := "What number of locomotive will you";
  Quel_No_Loco2      : constant string := "use";
  Ind_Loco_Posee     : constant string := "It is between the contacts ";
  Et                 : constant string := "and";
  Ind_Continue       : constant string := "To continue type <RETURN>";
  Quel_Vitesse_Loco  : constant string := "What is the speed of this locomotive";
  Erreur_Pos_Loco    : constant string := "The contacts specifing the locomotive are";
  Erreur_Pos_Loco2   : constant string := "invalid";
  Erreur_Pos_Loco3   : constant string := "This locomotive will not be considered during simulation.";


  -- AfficherInfoMaquette
  Titre_Info_Maquette: constant string := "Railroad Model Information";    -- "Informations sur la maquette:"
  Description        : constant string := "Description          : ";       -- "Description          : "
  Nom_Fichier        : constant string := "File name            : ";       -- "Nom du fichier       : "
  Nbr_Section        : constant string := "Number of tracks     : ";       -- "Nombre de sections   : "
  Nbr_Contact        : constant string := "Number of contacts   : ";       -- "Nombre de contacts   : "
  Nbr_Aiguillage     : constant string := "Number of switches   : ";       -- "Nombre d'aiguillages : "

  -- Erreur init
  Erreur_Fich_maq    : constant string := " Error: The descriptive file: "; -- " Erreur: Le fichier descriptif: "
  Erreur_Fich_maq2   : constant string := " cannot be read";                -- " ne peut etre lu"
  Erreur_Fich_maq3   : constant string := " contains errors";               -- " contient des erreurs"
  Invite_Quitter     : constant string := " Type CTRL-C to leave the simulator ."; -- " Tapez CTRL-C pour quitter le simulateur."

  -- Erreur collision
  Alarme_Simul       : constant string := "       --- ALARM OF THE SIMULATOR ---"; -- "        --- ALARME DU SIMULATEUR ---"
  Collision          : constant string := " Collision - > Stop of simulation. "; -- " Collision -> Arret de la simulation."

  -- Erreur deraillement possible
  Deraillement       : constant string := " Warning derailment possible by handling of one"; -- " Attention deraillement possible par manipulation d'un"
  Deraillement2      : constant string := " switche occupied -> No stop of simulation."; -- " aiguillage occupe  ->   Pas d'arret de la simulation."
  Deraillement3      : constant string := " But the modification of direction is not realise"; -- " Mais la modification de direction n'est pas realise"
  Propose_Quitter    : constant string := " You can type CTRL-C to leave the simulator."; -- " Vous pouvez tapez CTRL-C pour quitter le simulateur."

  -- Erreur plusieurs attentes sur un contact
  Mult_Attente       : constant string := " Warning several tasks are in waitings on the contact No ";-- " Attention plusieurs taches sont en attentes sur le contact no "

  -- AfficherEtatMaquette
  Heure              : constant string := " Time: ";   -- " Heure: "
  Liste_Train        : constant string := " List trains: "; -- " Liste des trains: "
  Liste_Contact      : constant string := " List contacts activated: "; -- " Liste des contacts actives: "
  Numero             : constant string := " No: ";
  Active             : constant string := " Activated"; -- " Active"
  Maq_Off            : constant string := " Railroad Model is no running"; -- " La maquette est hors service"

  -- Autres erreurs
  Erreur_Anormale    : constant string := " Abnormal error of the simulator"; -- " Erreur anormale dans le simulateur"

  -- tache simulation
  Info_Simul         : constant string := " Information from the simulator"; -- "   Informations du simulateur"
  Etat_maq_coll      : constant string := " State of the railroad model at the time of the collision"; -- " Etat de la maquette au moment de la collision."
  Erreur_deraillement: constant string := " Derailment - > Stop of simulation"; -- " Deraillement detectee -> arret de la simulation."
  Etat_maq_derail    : constant string := " State of the railroad model at the time of the derailment"; -- " Etat de la maquette lors du deraillement."
  Err_Nom_Fich_trace : constant string := " Error, the complete name of the executable file is too long";  -- " Erreur le nom complet du fichier executable est trop long"
  Err_Nom_Fich_trace2: constant string := " the trace file will not be creates"; -- Le fichier trace ne sera pas crée"
  Erreur_Fich_Trace  : constant string := " Error, impossible to create the trace file"; -- "Erreur impossible de creer le fichier trace"

  -- Put (train)
  Vitesse            : constant string := "Speed: ";  -- "Vit: "
  Pas_Active         : constant string := "Not activated"; -- "Pas active"

  -- Fenetre Legende
  Chaine_Couleur_Loco: constant String := "Color";  -- "Couleur"
  Chaine_Numero_Loco : constant String := "Number";  -- "Numero"
end P_Messages;

