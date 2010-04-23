--------------------------------------------------------------------------
--
-- Nom du fichier   : P_Maquette.adb
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
--                    L'objet protege "Protmaquette" assure l'exclusion
--                    mutuelle sur les informations constituant la maquette
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
-- Modules appeles  : Text_Io, P_Afficher, Calendar, P_Train, P_Section,
--                    P_Contact, Win32( Glaux, Gl, Glu),
--                    Interface( C, C( String)),
--                    Unchecked_Conversion,
--                    Ada.Numerics.Elementary_Functions,
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
--
--
-- Materiel
-- particulier      : Les dll "OpenGl32.dll" et "Glu32.dll" doivent
--                    etre dans le repertoire systeme de windows
--
--------------------------------------------------------------------------

                                 -- Pour gerer les entrees/sorties sur
with Text_IO;                    -- des fichiers

                                 -- Pour gerer les entrees/sorties sur
with P_Afficher;                 -- l'ecran et le clavier

with Ada.Integer_Text_Io;use Ada.Integer_Text_Io;

-- Pour utiliser la librairie GLUT
with Glut; use Glut;

with Gl; use Gl;     -- Pour utiliser opengl

with Glu; use Glu;   -- Pour utiliser la librairie GLU

--                                 -- Pour utiliser les tableaux de
--                                 -- caractere de type C
-- Appel de la librairie d'interfacage avec le C
with Interfaces.C.Strings;

                                 -- Pour pouvoir construire de fonction
                                 -- de conversion
with Unchecked_Conversion;

                                 -- Pour utiliser les fonctions Sin,
                                 -- Cos, etc. sur des reel
with Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions;

with Ada.Command_Line;           -- Pour obtenir le nom du programme

with P_Messages;

-- Pour les fonction callback OpenGL
with P_Maquette.display;
use P_Maquette.display;

package body P_Maquette is

  --  Paquetages d'E/S pour les entiers
  --  qui gere l'exclusion mutuelle sur
  --  le moniteur
  package Aff_Int is new P_Afficher.Integer_Io(Integer);

  -- Paquetages d'E/S pour les durree
  -- (secondes)qui gere l'exclusion
  -- mutuelle sur le moniteur
  package Aff_Dur is new P_Afficher.Fixed_Io(Duration);

  -- Paquetage permettant des entree
  -- sortie sur les numero
  package Int_Io is new Text_Io.Integer_Io(Integer);

--   ***********************************************************************
--
--   Variables globales
--
--   ***********************************************************************

  -- Objet maquette contenant toutes
  -- les informations utile a la gestion
  -- de la maquette
  Maquette: T_Maquette_Ptr;

  -- Pour accelerer l'affichage on
  -- memorise dans un buffer l'image
  -- des sections de la maquette puis
  -- lors du deplacement de train on
  -- utilise cette image et on dessine
  -- les trains dessus. Cepandant lors de
  -- changement de point de vue il faut
  -- tout redessiner on revient donc au
  -- debut de la sequance d'affichage
  Debut: Boolean := True;

  -- Fichier contenant une trace
  -- de l'execution d'une simulation.
  Fichier_Trace: Text_Io.File_Type;


  protected body Etat_Maquette is

     entry Positionner (Nouvel_Etat : Type_Etat) when True is
     begin
        Etat := Nouvel_Etat;
     end Positionner;

     entry Prete when Etat = Maquette_Prete is
     begin
        null;
     end Prete;

  end Etat_Maquette;

--  ***********************************************************************
--
--  Objet protege Protmaquette
--
--  ***********************************************************************

  protected body Protmaquette is
    --  On peut obtenir la ressource critique que si elle est pas
    --  utilisee
    entry Acquerir when not Aqui is
    begin
      --  Indique que la ressource est utilisee
      Aqui :=True;
    end Acquerir;

    --  On peut effectuer le protocole de liberation sans contrainte
    entry Rendre when True is
    begin
      Aqui := False;
    end Rendre;

    ---------------------------------------------------------------------
    --
    -- Fonction : NbrTachesAttend
    -- But      : Indique le nombre de taches qui attendent sur le contact
    --            passe en parametre
    --
    -- Retour   : le nombre de contact
    --
    --
    ---------------------------------------------------------------------
    function NbrTachesAttend (Contact_Id :P_Contact.T_Contact_Id)
      return Integer is
    begin
      return AttendreActivationContact(Contact_Id)'Count;
    end;

    ---------------------------------------------------------------------
    --
    -- Entree : AttendreActivationContact
    -- But    : Entree bloquante tant qu'un train n'est passe ou et
    --          pose sur un contact.
    --
    --          Il y a une entree par contact et cette entree est
    --          fermee tant que:
    --          1) un train n'est pas poser sur le contacte
    --             (Estactive)
    --          2) un train n'est pas passe dessus sans s'arreter
    --             (contacts_actives)
    --          3) la maquette n'est pas alimentee
    --
    --          le tableau "contact_actives" enregistre tout les contacts
    --          qui ont ete occupes durant les procedures "poser" et
    --          surtout "avancer" ainsi on grade une trace des contacts
    --          occupe puis liberer dans la meme procedure et grace a cela
    --          on peut liberer une tache qui attendait ce contact
    --
    --
    --          Modifie la variable protegee "Maquette"
    --
    ---------------------------------------------------------------------
    entry Attendreactivationcontact(for Contactid in P_Contact.T_Contact_Id)
      when ( (Maquette.Active
              and (Contactid in 1..Maquette.Nbrcontacts) and (not Aqui))
              and then (Maquette.Contacts_Actives(Contactid)
                or (P_Contact.Estactive(Maquette.Contacts(Contactid).all)
                and Maquette.Rebond))
           )
    is
    begin
      -- Apres avoir traiter l'activation du
      -- contact on met a jour le tableau des
      -- contacts activee
      Maquette.Contacts_Actives(Contactid):= False;

    end Attendreactivationcontact;

  end Protmaquette;

  --------------------------------------------------------------------
  --
  -- Fonction : Modeaffichage
  -- But      : Fonction indiquant si le mode de simulation avec
  --            affichage sur l'ecran textuelle de l'etat de la
  --            maquette est active
  --
  -- Retour   : Indication si le mode affichage est actif
  --            (True  => actif donc affichage
  --             False => inactif donc pas d'affichage)
  --
  --            Consulte la variable protegee "Maquette"
  --
  --------------------------------------------------------------------
  function Modeaffichage return Boolean is

          Result : Boolean;

      begin
     Protmaquette.Acquerir;
     Result := Maquette.Affichage;
         Protmaquette.Rendre;
         return (Result);
  end Modeaffichage;

  --------------------------------------------------------------------
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
  --------------------------------------------------------------------
  function Modecontinu
    return Boolean
  is
    Result : Boolean;

  begin
    Protmaquette.Acquerir;
    Result := Maquette.Continu;
    Protmaquette.Rendre;
    return (Result);

  end Modecontinu;

  ------------------------------------------------------------------------
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
  --            Modifie la variable protegee "Maquette"
  --
  ------------------------------------------------------------------------
  procedure Init (Nomfichier: in String) is
    -- **************************************************************
    --
    -- Types contenant les types des voies utilisables dans la
    --    creation des circuits (maquettes)
    --
    -- ***************************************************************


    -- Type regroupant les numeros de serie
    -- des elements de voie utilise dans les
    -- maquette.
    type T_Voie is (N2200, N2201, N2202, N2203, N2204,-- Voie droite
                    N2206, N2207, N2208, N2293,
                    N2210, N2221, N2223, N2224, N2231,-- Voie courbe
                    N2232, N2233, N2234, N2235,
                    N2258,                      -- Croisement
                    N7391,                      -- Heutoir
                    N2261,                      -- Aiguillage droit
                    N2267,                      -- Aiguillage courbe
                    N2270,                      -- Aiguillage 3 voies
                    N2260);                     -- Aiguillage croix


    -- Sous-type regroupant les numeros de
    -- serie des elements de voie droit
    subtype T_Voie_Droite is T_Voie range N2200..N2293;

    -- Sous-type regroupant les numeros de
    -- serie des elements de voie courbe
    subtype T_Voie_Courbe is T_Voie range N2210..N2235;

    -- Sous-type regroupant les numeros de
    -- serie des elements de croisement
    subtype T_Voie_Croix  is T_Voie range N2258..N2258;

    -- Sous-type regroupant les numeros de
    -- serie des elements de fin de voie
    -- (heurtoir)
    subtype T_Voie_Fin    is T_Voie range N7391..N7391;

    -- Sous-type regroupant les numeros de
    -- serie des aiguillages droit
    subtype T_Voie_Aigui_Simple_Droit is T_Voie range N2261..N2261;

    -- Sous-type regroupant les numeros de
    -- serie des aiguillage courbe
    subtype T_Voie_Aigui_Simple_Courbe is T_Voie range N2267..N2267;

    -- Sous-type regroupant les numeros de
    -- serie des aiguillages doubles
    subtype T_Voie_Aigui_Double is T_Voie range N2270..N2270;

    -- Sous-type regroupant les numeros de
    -- serie des aiguillages croix
    subtype T_Voie_Aigui_Croix is T_Voie range N2260..N2260;

    -- ***************************************************************
    --
    -- Constantes contenant les dimensions des voies utilisables dans
    --    la creation des circuits (maquettes)
    --
    -- ***************************************************************

    -- Longueurs des voies droites selon
    -- leur numero de serie
    Longvoiedroite: constant array (T_Voie_Droite)
      of Float :=
      (N2200 =>180.0, N2201 =>90.0, N2202 =>45.0, N2203 =>30.0,
       N2204 =>22.5, N2206 =>168.9, N2207 =>156.0, N2208 =>35.1,
       N2293 =>41.3);

    -- Portion du cercle indiquant la
    -- longueur du rail selon leur numero
    -- de serie
    Anglevoiecourbe: constant array (T_Voie_Courbe)
      of Float :=
      (N2210 =>45.0, N2221 =>30.0, N2223 =>15.0, N2224 =>7.5,
       N2231 =>30.0, N2232 =>22.5, N2233 =>15.0, N2234 =>7.5,
       N2235 =>3.75);

    -- Rayon du cercle realise par les rails
    -- selon leur numero de serie
    Rayonvoiecourbe : constant array (T_Voie_Courbe)
      of Float :=
      (N2210 =>295.4, N2221 =>360.0, N2223 =>360.0, N2224 =>360.0,
       N2231 =>424.6, N2232 =>424.6, N2233 =>424.6, N2234 =>424.6,
       N2235 =>424.6);

    -- Longueurs de la traversee direct
    -- des section croisement selon leur
    -- numero de serie
    Longvoiecroix: constant array (T_Voie_Croix)
      of Float :=
      (N2258 =>90.0);
    -- Angle de croisement des section
    -- croisement selon leur numero de
    -- serie
    Anglevoiecroix: constant array (T_Voie_Croix)
      of Float :=
      (N2258 =>45.0);

    -- Longueurs des section fin de voie
    -- selon leur numero de serie
    Longvoiefin : constant array (T_Voie_Fin)
      of Float :=
      (N7391 =>70.0);

    -- Longueurs de la traversee direct
    -- des aiguillages droits selon leur
    -- numero de serie
    Longvoieaiguisimpledroit : constant array (T_Voie_Aigui_Simple_Droit)
      of Float := (N2261 =>168.9);

    -- Portion du cercle indiquant la
    -- longueur de la traversee deviee
    -- des aiguillages droits selon leur
    -- numero de serie
    Anglevoieaiguisimpledroit : constant array (T_Voie_Aigui_Simple_Droit)
      of Float := (N2261 =>22.5);

    -- Rayon du cercle realise par la
    -- traversee deviee des aiguillages
    -- droit selon leur numero de serie
    Rayonvoieaiguisimpledroit : constant array (T_Voie_Aigui_Simple_Droit)
      of Float := (N2261 =>424.6);

    -- Longueur du decalage entre le depart
    -- du rail exterieur par rapport
    -- a celui de l'interieur dans les
    -- aiguillages courbes selon leur numero
    -- de serie
    Decalagevoieaiguisimplecourbe : constant array
      (T_Voie_Aigui_Simple_Courbe) of Float := (N2267 =>64.6);

    -- Portion du cercle indiquant la
    -- longueur de chaqun des deux rails
    -- des aiguillages courbe selon leur
    -- numero de serie
    Anglevoieaiguisimplecourbe : constant array
      (T_Voie_Aigui_Simple_Courbe) of Float := (N2267 =>30.0);

    -- Rayon du cercle realise par les
    -- chaqun des deux rails des aiguillages
    -- courbe selon leur numero de serie
    Rayonvoieaiguisimplecourbe : constant array
      (T_Voie_Aigui_Simple_Courbe) of Float := (N2267 =>360.0);

    -- Longueurs de la traversee direct
    -- des aiguillages double selon leur
    -- numero de serie
    Longvoieaiguidouble : constant array (T_Voie_Aigui_Double)
      of Float := (N2270 =>168.9);

    -- Portion du cercle indiquant la
    -- longueur des deux traversees deviees
    -- des aiguillages double selon leur
    -- numero de serie
    Anglevoieaiguidouble : constant array (T_Voie_Aigui_Double)
      of Float := (N2270 =>22.5);

    -- Rayon du cercle realise par les
    -- deux traversees deviees des
    -- aiguillages double selon leur numero
    -- de serie
    Rayonvoieaiguidouble : constant array (T_Voie_Aigui_Double)
      of Float := (N2270 =>424.6);

    -- Longueurs de la traversee direct
    -- des aiguillage croix selon leur
    -- numero de serie
    Longaiguicroix: constant array (T_Voie_Aigui_Croix)
      of Float := (N2260 =>168.9);

    -- Angle de croisement des aiguillages
    -- croix selon leur numero de
    -- serie
    Angleaiguicroix: constant array (T_Voie_Aigui_Croix)
      of Float := (N2260 =>22.5);

    -- ***************************************************************
    --
    -- Types
    --
    -- ***************************************************************

    -- Type pour indiquer les section deja
    -- placee dans le plan ( si elle ont
    -- deja leur position en X et Y le
    -- flag correspondant et a "True"
    type T_Deja_Placer is array (P_Section.T_Section_Id range <>) of
      Boolean;


    -- ***************************************************************
    --
    -- Variables
    --
    -- ***************************************************************

    -- Le fichier descriptif de la maquette
    Fichier: Text_Io.File_Type;

    -- Chaine de caractere utilisee pour memoriser la description de
    -- la maquette
    Description: String(1..255);

    -- Longueur reel de la chaine de description de la maquette
    Longueurdescription: Integer;

    -- Variable utilisee pour contenir les information sur les sections
    -- connectee a la premiere section posee
    Section_A_placer : P_Section.T_Section_A_placer(1..4) :=
                        (others =>(0,(0.0,0.0),(0.0,0.0),0));


    ------------------------------------------------------------------
    --
    -- Fonction: ChargerSections
    -- But      : Fonctions qui charge les sections a partir
    --            d'un fichier et les places dans une liste
    --
    --
    -- Entrees  : Fichier   => le fichier de description de la
    --                         maquette ouvert et placee au bonne
    --                         endroit (sur le chiffre exprimant
    --                         le nombre de sections)
    --
    -- Retour   : Le tableau contenant toute les sections
    --            de la maquette.
    --
    ------------------------------------------------------------------
    function Chargersections(Fichier: in Text_Io.File_Type)
      return P_Section.T_Sections
    is
      -- Nombre de sections dans la maquette
      Nombresections: Integer;

      -- Numero de la section dont on charge
      -- les informations
      Numerosection: Integer;

      -- Numero de serie de la section qui
      -- permetra de definir le type de la
      -- section
      Numero_Serie: Integer;
      -- Type de la section dont on charge
      -- les informations
      Typesection: T_Voie;

      -- Orientation (gauche ou droite) de
      -- la section dont on charge les
      -- informations utilisee que par les
      -- sections courbes et les aiguillages
      -- (orientation toujours donnee par
      -- en allant de l'entree a la sortie
      -- (de la connexion 1 a la suivante))
      Orientation: P_Section.T_Orientation;

      -- Tableau des sections connectee a la
      -- section dont on charge les
      -- informations
      Connections: P_Section.T_Connections(1..P_Section.Max_Connections);

    begin
      -- On lit le nombre de sections de la
      -- maquette
      Int_Io.Get(Fichier, Nombresections);

      declare
        -- Tableau pour stocker les sections.
        Sections: P_Section.T_Sections(1..Nombresections);

      begin
        -- On parcourt les sections donc les
        -- lignes du fichier
        for Section in 1..Nombresections
        loop
          -- On lit le numero de la section.
          Int_Io.Get(Fichier, Numerosection);

          -- On lit le numero de serie de la section.
          Int_Io.Get(Fichier, Numero_Serie);

          -- On converti en type de section
          case Numero_Serie is

            when 2200 => Typesection:= N2200;
            when 2201 => Typesection:= N2201;
            when 2202 => Typesection:= N2202;
            when 2203 => Typesection:= N2203;
            when 2204 => Typesection:= N2204;
            when 2206 => Typesection:= N2206;
            when 2207 => Typesection:= N2207;
            when 2208 => Typesection:= N2208;
            when 2293 => Typesection:= N2293;
            when 2210 => Typesection:= N2210;
            when 2221 => Typesection:= N2221;
            when 2223 => Typesection:= N2223;
            when 2224 => Typesection:= N2224;
            when 2231 => Typesection:= N2231;
            when 2232 => Typesection:= N2232;
            when 2233 => Typesection:= N2233;
            when 2234 => Typesection:= N2234;
            when 2235 => Typesection:= N2235;
            when 2258 => Typesection:= N2258;
            when 7391 => Typesection:= N7391;
            when 2261 => Typesection:= N2261;
            when 2267 => Typesection:= N2267;
            when 2270 => Typesection:= N2270;
            when 2260 => Typesection:= N2260;
            when others =>
              -- Si le numero de serie est faux
             raise Constraint_Error;
          end case;
          -- On traite chaque section selon son type

          case Typesection is

            -- Sections droites
            when N2200..N2293 =>
              -- On lit la section connectee a
              --  l'entree de la section.
              Int_Io.Get(Fichier, Connections(1));

              -- On lit la section connectee a la
              -- sortie de la section.
              Int_Io.Get(Fichier, Connections(2));

              -- On cree l'objet section droite
              -- selon les donnees du fichier et
              -- et selon son type
              Sections(Section) :=
                P_Section.T_Section_Ptr(
                  P_Section.New_Section_Droite(
                    Numerosection,
                    Connections(1..2),
                    Longvoiedroite(Typesection)));

            -- Sections courbes
            when N2210..N2235 =>
              -- On lit la section connectee a
              -- l'entree de la section.
              Int_Io.Get(Fichier, Connections(1));

              -- On lit la section connectee a la
              -- sortie de la section.
              Int_Io.Get(Fichier, Connections(2));

              -- On lit si la section tourne a
              -- droite ou a gauche
              P_Section.P_Orientation_Io.Get(Fichier, Orientation);

              -- On cree l'objet section courbe
              -- selon les donnees du fichier et
              -- et selon son type
              Sections(Section) :=
                P_Section.T_Section_Ptr(
                  P_Section.New_Section_Courbe(
                    Numerosection,
                    Connections(1..2),
                    Anglevoiecourbe(Typesection),
                    Rayonvoiecourbe(Typesection),
                    Orientation));

            -- Sections fin de voie heurtoir
            when  N7391 =>
              -- On lit la section connectee a
              -- l'entree de la section.
              Int_Io.Get(Fichier, Connections(1));

              -- On cree l'objet section fin de
              -- voie selon les donnees du fichier
              -- et selon son type
              Sections(Section) :=
                P_Section.T_Section_Ptr(
                  P_Section.New_Section_Fin_De_Voie(
                    Numerosection,
                    Connections(1..1),
                    Longvoiefin(Typesection)));

            -- Sections aiguillage simple droit
            when  N2261=>
              -- On lit la section connectee a
              -- l'entree de la section.
              Int_Io.Get(Fichier, Connections(1));

              -- On lit la section connectee a la
              -- sortie en face de la section.
              Int_Io.Get(Fichier, Connections(2));

              -- On lit la section connectee a la
              -- sortie deviee de la section.
              Int_Io.Get(Fichier, Connections(3));

              -- On lit si la sortie deviee
              -- tourne a droite ou a gauche
              P_Section.P_Orientation_Io.Get(Fichier, Orientation);

              -- On cree l'objet aiguillage simple
              -- droit selon les donnees du fichier
              -- et selon son type
              Sections(Section) :=
                P_Section.T_Section_Ptr(
                  P_Section.New_Aiguillage_Simple_Droit(
                    Numerosection,
                    Connections(1..3),
                    Anglevoieaiguisimpledroit(Typesection),
                    Rayonvoieaiguisimpledroit(Typesection),
                    Orientation,
                    Longvoieaiguisimpledroit(Typesection)));

            -- Sections aiguillage simple courbe
            when N2267 =>
              -- On lit la section connectee a
              -- l'entree de la section.
              Int_Io.Get(Fichier, Connections(1));

              -- On lit la section connectee a
              -- la sortie deviee interne de la
              -- section.
              Int_Io.Get(Fichier, Connections(2));

              -- On lit la section connectee a la
              -- sortie deviee externe de la section.
              Int_Io.Get(Fichier, Connections(3));

              -- On lit si la section tourne a
              -- droite ou a gauche
              P_Section.P_Orientation_Io.Get(Fichier, Orientation);

              -- On cree l'objet aiguillage simple
              -- courbe selon les donnees du fichier
              -- et selon son type
              Sections(Section) :=
                P_Section.T_Section_Ptr(
                  P_Section.New_Aiguillage_Simple_Courbe(
                    Numerosection,
                    Connections(1..3),
                    Anglevoieaiguisimplecourbe(Typesection),
                    Rayonvoieaiguisimplecourbe(Typesection),
                    Orientation,
                    Decalagevoieaiguisimplecourbe(Typesection)));

            -- Section aiguillage a trois voies
            when N2270 =>
              -- On lit la section connectee a
              -- l'entree de la section.
              Int_Io.Get(Fichier, Connections(1));

              -- On lit la section connectee a la
              -- sortie en face de la section.
              Int_Io.Get(Fichier, Connections(2));

              -- On lit la section connectee a la
              -- sortie deviee a gauche de la section.
              Int_Io.Get(Fichier, Connections(3));

              -- On lit la section connectee a la
              -- sortie deviee a droite de la section.
              Int_Io.Get(Fichier, Connections(4));

              -- On cree l'objet aiguillage a trois
              -- voies selon les donnees du fichier et
              -- et selon son type
              Sections(Section) :=
                P_Section.T_Section_Ptr(
                  P_Section.New_Aiguillage_Double(
                    Numerosection,
                    Connections(1..4),
                    Anglevoieaiguidouble(Typesection),
                    Rayonvoieaiguidouble(Typesection),
                    Longvoieaiguidouble(Typesection)));


            -- Section croisement
            when N2258=>
              -- On lit la section connectee
              -- a l'entree de la section.
              Int_Io.Get(Fichier, Connections(1));

              -- On lit la section connectee a la
              -- sortie en face de la section.
              Int_Io.Get(Fichier, Connections(2));

              -- On lit la section connectee a la
              -- sortie decalee a droite de la
              -- section.
              Int_Io.Get(Fichier, Connections(3));

              -- On lit la section connectee a la
              -- sortie en face de la sortie
              -- decalee a droite de la section.
              Int_Io.Get(Fichier, Connections(4));

              -- On cree l'objet section croisement
              -- selon les donnees du fichier et
              -- et selon son type
              Sections(Section) :=
                P_Section.T_Section_Ptr(
                  P_Section.New_Section_Croix(
                    Numerosection,
                    Connections(1..4),
                    Anglevoiecroix(Typesection),
                    Longvoiecroix(Typesection)));


            -- Section aiguillage croix
            when  N2260=>
              -- On lit la section connectee a
              -- l'entree de la section.
              Int_Io.Get(Fichier, Connections(1));

              -- On lit la section connectee a la
              -- sortie en face de la section.
              Int_Io.Get(Fichier, Connections(2));

              -- On lit la section connectee a la
              -- sortie decalee a droite de la
              -- section.
              Int_Io.Get(Fichier, Connections(3));

              -- On lit la section connectee a la
              -- sortie en face de la sortie
              -- decalee a droite de la section.
              Int_Io.Get(Fichier, Connections(4));

              -- On cree l'objet aiguillage
              -- croix selon les donnees du fichier
              -- et selon son type
              Sections(Section) :=
                P_Section.T_Section_Ptr(
                  P_Section.New_Aiguillage_Croix(
                    Numerosection,
                    Connections(1..4),
                    Angleaiguicroix(Typesection),
                    Longaiguicroix(Typesection)));

          -- Fin de chargement de la section
          end case;      -- selon son type

        -- Fin du chargement de toutes les
        end loop;        -- sections

        -- Retourne les tableau contenant
        -- toute les section de la maquette
        return Sections;

        -- Fin du bloc qui a servi a creer
      end;               -- le tableau de section

    end Chargersections;

    ------------------------------------------------------------------
    --
    -- Fonction  : ChargerContacts
    -- But       : Fonction qui charge les contacts a partir
    --             d'un fichier et les met dans une liste
    --
    -- Entrees  : Fichier   => Le fichier de description de la
    --                         maquette ouvert et placee au bonne
    --                         endroit (sur le chiffre exprimant
    --                         le nombre de contacts)
    --            Sections  => Le tableau de section qui compose
    --                         la maquette et sur lesquels on
    --                         defini des contacts
    --
    -- Retour   : Le tableau contenant toute les contacts de
    --            la maquette.
    --
    ------------------------------------------------------------------
    function Chargercontacts (Fichier : in Text_Io.File_Type;
                              Sections: in P_Section.T_Sections)
      return P_Contact.T_Contacts
    is
      -- Nombre de contacts place sur
      -- la maquette
      Nbrcontacts: Integer;

      -- Numero du contact dont on charge
      -- les informations
      Nocontact : P_Contact.T_Contact_Id;

      -- Identificateur de la section du
      -- contact dont on charge les
      -- informations.
      Sectionid: P_Section.T_Section_Id;

    begin
      -- On lit le nombre de sections.
      Int_Io.Get(Fichier, Nbrcontacts);

      declare
        -- Tableau pour stocker les contacts
        Contacts: P_Contact.T_Contacts(1..Nbrcontacts);

      begin
        -- On parcourt les contacts donc les
        -- lignes du fichier
        for Contact in Contacts'range
        loop

          -- On lit le numero du contact.
          Int_Io.Get(Fichier, Nocontact);

          -- On lit la section sur laquelle
          -- est pose le contact.
          Int_Io.Get(Fichier, Sectionid);

          -- On cree un nouvelle objet contact
          -- selon les informations lue dans
          -- le fichier
          Contacts(Nocontact) :=
            P_Contact.Newcontact (Nocontact,
                                  Sections(Sectionid));
        end loop;

        -- On retourne la liste de tous les
        -- contact de la maquette
        return Contacts;

      -- Fin du bloc qui a servi a creer
      end;                   -- le tableau de contact

    end Chargercontacts;

    ------------------------------------------------------------------
    --
    -- Fonction  : ChargerAiguillages
    -- But       : Fonction qui charge les aiguillages a partir
    --             d'un fichier et les places dans une liste
    --
    --
    -- Entrees  : Fichier   => Le fichier de description de la
    --                         maquette ouvert et placee au bonne
    --                         endroit (sur le chiffre exprimant
    --                         le nombre d'aiguillage)
    --            Sections  => Le tableau de section qui compose
    --                         la maquette et dont certains
    --                         sont des aiguillages
    --
    -- Retour   : Le tableau contenant toute les aiguillages
    --            de la maquette.
    --
    ------------------------------------------------------------------
    function Chargeraiguillages (Fichier : in Text_Io.File_Type;
                                 Sections: in P_Section.T_Sections)
      return P_Aiguillage.T_Aiguillages
    is
      -- Nombre d'aiguillage sur la
      -- maquette
      Nbraiguillages: Integer;

      -- Numero de l'aiguillage dont on
      -- charge les informations
      Noaiguillage: Integer;

      -- Variable exprimant si
      -- l'aiguillage dont on charge les
      -- informations est independant
      -- (il est dependant que si il
      -- s'agit du deuxieme aiguillage
      -- d'un aiguillage double)
      Sousaiguillage: P_Section.T_Aiguillage_Type;

      -- Numero de la section
      -- correspondante a l'aiguillage
      -- dont on charge les information
      Section: P_Section.T_Section_Id;

      -- Variable pour lire le caractere
      -- suivant le numero de la section
      -- qui est l'aiguillage
      Caractere: Character := ' ';

      -- Indique si le caractere lu est une
      -- fin de ligne
      Fin_Ligne: Boolean:= False;

    begin
      -- On lit le nombre d'aiguillages
      Int_Io.Get(Fichier, Nbraiguillages);

      declare
        -- Tableau pour stocker les aiguillages
        Aiguillages: P_Aiguillage.T_Aiguillages(1..Nbraiguillages);

      begin
        -- On parcourt les aiguillages donc
        -- les lignes du fichier
        for Aiguillage in Aiguillages'range
        loop

          -- On lit le numero de l'aiguillage
          Int_Io.Get(Fichier, Noaiguillage);

          -- On lit la section correspondante
          -- a l'aiguillage.
          Int_Io.Get(Fichier, Section);


          -- On cherche un caractere qui ne
          -- soit pas l'espace sur la ligne
          -- courante
          loop
            -- On regarde le caractere suivant
            -- sans faire avancer la lecture
            Text_Io.Look_Ahead (Fichier,
                               Caractere,
                               Fin_Ligne);

            -- On sort si on est a la fin
            -- de la ligne ou si le caractere
            -- n'est pas un espace
            exit when ((Caractere /= ' ') or (Fin_Ligne));

            -- On avance reelement dans le fichier
            -- on passe au caractere suivant
            -- l'espace
            Text_Io.Get(Fichier, Caractere);

          end loop;

          -- Si on a trouve un caractere sur la
          -- ligne
          if not Fin_Ligne
          then
            -- On lit l'indication qu'il
            -- s'agit d'un aiguillage secondaire
            P_Section.P_Aiguillage_Type_Io.Get (Fichier,
                                                Sousaiguillage);

          else
            -- Si on a rien trouve il s'agit
            -- d'un aiguillage principal
            Sousaiguillage:= P_Section.Principal;

          end if;

          -- On cree un nouvelle objet aiguillage
          -- selon les informations lue dans le
          -- fichier
          Aiguillages(Aiguillage) :=
            P_Aiguillage.Newaiguillage (Noaiguillage, Sousaiguillage,
              P_Section.T_Aiguillage_Ptr(Sections(Section)));

        end loop;

        -- Retourne la liste de tous les aiguillages
        -- de la maquette
        return Aiguillages;

      -- Fin du bloc qui a servi a definir le
      end;                     -- tableau d'aiguillage

    end Chargeraiguillages;

    ------------------------------------------------------------------
    --
    -- Procedure : ChargerPosition
    -- But       : Fonction qui charge un numero de section
    --             sa position dans le plan et son orientation
    --
    --
    -- Entrees  : Fichier   => Le fichier de description de la
    --                         maquette ouvert et placee au bonne
    --                         endroit (sur le chiffre exprimant
    --                         le premiere section a placer)
    --
    -- Sorties  : Section   => Iden tificateur de la section dont on
    --                         determiner la position
    --            Position  => Position en X et Y dans le plan du debut
    --                         de la section
    --            Orientation
    --                      => Vecteur indiquant l'orientation de la
    --                         section dans le plan
    --
    ------------------------------------------------------------------
    procedure Charger_Position (Fichier     : in Text_Io.File_Type;
                                Section     : out P_Section.T_Section_Id;
                                Position    : out P_Section.T_Point;
                                Orientation : out P_Section.T_Vecteur)
    is
      -- Numero de la section
      Numerosection: Integer;

      -- Position en X de la section dans le plan
      Valeur_X_pos : Integer;

      -- Position en Y de la section dans le plan
      Valeur_Y_pos : Integer;

      -- Composante  X du vecteur d'orientation
      -- dans le plan
      Valeur_X_vec : Integer;

      -- Composante  Y du vecteur d'orientation
      -- dans le plan
      Valeur_Y_vec : Integer;

    begin
      -- On lit le numero de la section.
      Int_Io.Get(Fichier, Numerosection);

      -- On lit la position en X
      Int_Io.Get(Fichier, Valeur_X_pos);

      -- On lit la position en Y
      Int_Io.Get(Fichier, Valeur_Y_pos);

      -- On lit la composante X de l'orientation
      Int_Io.Get(Fichier, Valeur_X_vec);

      -- On lit la composante Y de l'orientation
      Int_Io.Get(Fichier, Valeur_Y_vec);

      -- Retourne ce numero
      Section:= P_Section.T_Section_Id(Numerosection);

      -- Retourne la position
      Position.X:= Float(Valeur_X_pos);
      Position.Y:= Float(Valeur_Y_pos);

      -- Retourne l'orientation
      Orientation.X:= Float(Valeur_X_vec);
      Orientation.Y:= Float(Valeur_Y_vec);

    end Charger_Position;

    ------------------------------------------------------------------
    --
    -- Procedure: Placer_les_section
    -- But      : Procedure qui determine l'emplacement dans un
    --            plan selon les axes X et Y des sections de la
    --            maquette.
    --
    --            A partir des informations fournie par le
    --            placement d'une section place toutes les
    --            autres.
    --
    -- Entrees  : Section_A_Placer
    --                     => Informations pour chaque section a
    --                        placer
    --                        1) Numero de la section
    --                        2) Direction de la section
    --                        3) Point de depart de la section
    --                        4) Section qui fournit la
    --                           direction et le point de
    --                           depart
    --            Sections => Le tableau de section qui compose
    --                         la maquette et qu'il faut placer
    --            Deja_Placer
    --                     => Tableau indiquant les sections qui
    --                        ont deja ete placee donc qui ont
    --                        une position dans le plan
    --
    ------------------------------------------------------------------
    procedure Placer_Les_Section
      (Section_A_placer : in     P_Section.T_Section_A_placer;
       Sections         : in     P_Section.T_Sections;
       Deja_Placer      : in out T_Deja_Placer)
    is

      -- Tableau contenamt les informations
      -- sur les sections a poser (sections
      -- connectee a la section que l'on
      -- pose et dont la position sera
      -- determineepar cette section
      Section_Suivante : P_Section.T_Section_A_placer(1..4):=
        (others =>(0,(0.0,0.0),(0.0,0.0),0));

    begin
      -- Tant qu'il y a des section a placer
      for I in Section_A_placer'range loop

        -- On verifie si il s'agit bien d'une
        -- section et si elle n'a pas deja ete
        -- placee
        if (not(Section_A_placer(I).Section_Id = 0)) and then
           (not Deja_Placer(Section_A_placer(I).Section_Id))
        then
          -- On indique que maintenant elle est
          -- placee
          Deja_Placer(Section_A_placer(I).Section_Id):= True;

          -- On la place dans le plan a partir
          -- d'un point et d'un vecteur et de
          -- l'indication de qui fournit ces
          -- informations et on recupere les
          -- meme informations pour les sections
          -- connectee a la section que l'on place
          P_Section.Placer(
            Sections(Section_A_placer(I).Section_Id).all,
            Section_A_placer(I).Point,
            Section_A_placer(I).Vecteur,
            Section_A_placer(I).Section_Id_Preced,
            Section_Suivante);

          -- On place toute les sections connectee
          -- a cette section que l'on vient de
          -- placer
          Placer_Les_Section(Section_Suivante, Sections, Deja_Placer);

        end if;
        -- On reinitialise le tableau des
        -- sections connectee a la section que
        -- l'on vient de poser pour l'utiliser
        -- avec la section suivante
        Section_Suivante:= (others=>(0,(0.0,0.0),(0.0,0.0),0));

      end loop;

    end Placer_Les_Section;

  begin  --  Debut de la procedure Init

    Protmaquette.Acquerir;

    -- On ouvre le fichier decrivant la maquette
    Text_IO.Open
      (File => Fichier, Mode => Text_Io.In_File, Name => Nomfichier);

    --  On recupere dans le fichier la ligne de description de la
    --  Maquette ainsi que sa longueur
    Text_Io.Get_Line (Fichier, Description, Longueurdescription);

    declare
      --  On charge les sections.
      Sections: P_Section.T_Sections := Chargersections(Fichier);

      --  Indique que les sections de la maquette n'ont pas ete placee
      Deja_Placer: T_Deja_Placer(1..Sections'Length) := (others=> False);
      --  On charge les contacts.
      Contacts: P_Contact.T_Contacts := Chargercontacts(Fichier, Sections);
      --  On charge les aiguillages.
      Aiguillages: P_Aiguillage.T_Aiguillages :=
        Chargeraiguillages(Fichier, Sections);

      --  Identificateur de la section que l'on va poser en premier
      Section: P_Section.T_Section_Id;

      --  Position dans le plan de la section que l'on va poser en
      --  premier
      Position:P_Section.T_Point;

      --  Orientation de la section que l'on va poser en premier
      Orientation: P_Section.T_Vecteur;

      --  Tableau des trains de la maquette (sans objet train)
      Trains: P_Train.T_Trains(1..P_Train.Nbr_Max_Train) :=
        (others=> null);

    begin
      --  On rempli la maquette avec les tableaux obtenu par le
      --  chargement du fichier
      Maquette := new T_Maquette'(
        Nbrsections         => Sections'Length,
        Nbrcontacts         => Contacts'Length,
        Nbraiguillages      => Aiguillages'Length,
        Nbrtrains           => Trains'Length,
        Longueurnomfichier  => Nomfichier'Last,
        Longueurdescription => Longueurdescription,
        Sections            => Sections,
        Contacts            => Contacts,
        -- Aucun contact actif
        Contacts_Actives    => (others => False),
        Aiguillages         => Aiguillages,
        Trains              => Trains,
        -- Maquette est hors tension
        Active              => False,
        Nomfichier          => Nomfichier,
        Description         =>
        Description(1..Longueurdescription),
        -- Le mode pas a pas (non continu)
        -- est par defaut
        Continu             => False,
        -- Le mode Affichage est active par
        -- defaut
        Affichage           => True,
        Rebond              => False);

      --  On charge les donnees pour placer la premiere section sur le
      --  plan
      Charger_Position (Fichier => Fichier,
                        Section => Section,
                        Position => Position,
                        Orientation => Orientation);

      --  On place la section qui est le plus au centre de la maquette
      --  sur l'origine et on recupere les informations pour placer
      --  les sections suivantes
      P_Section.Placer(Maquette.Sections(Section).all,
                       Position,
                       Orientation,
      --  On lui indique que le point et le vecteur n'ont pas ete
      --  fournit par le placement d'une autre section
      P_Section.Connection_Null, Section_A_placer);

      --  On indique que cette section est placee
      Deja_Placer(Section):= True;

      --  On place toutes les autres section de la maquette
      Placer_Les_Section(Section_A_placer, Maquette.Sections, Deja_Placer );

      --  on modifie la couleur de tout les section qui sont des
      --  contacts pour qu'ils soit reconaisable
      for I in Maquette.Contacts'range
      loop
        P_Contact.Paint(Maquette.Contacts(I).all);

      end loop;

    -- Fin du bloc ayant permit de
    end;                      -- charger les information du fichier

    -- On ferme le fichier.
    Text_Io.Close(File => Fichier);
    Protmaquette.Rendre;

    --  Debloque le moteur de simulation
    Etat_Maquette.Positionner (Maquette_Prete);

    -- Demarre l'affichage graphique
    Display_Simulator;

    --  Si il y a eu des probleme avec le fichier descripteur
  exception
    -- Probleme d'ouverture
    when Text_Io.Name_Error =>
      Protmaquette.Rendre;
      loop
        P_Afficher.New_Line_Dans_Zone_Reserv(2);
        P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Erreur_fich_maq
        & Nomfichier & P_Messages.Erreur_fich_maq2);
        P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Invite_Quitter);
        P_Afficher.New_Line_Dans_Zone_Reserv;
        P_Afficher.Skip_Line;
      end loop;

    -- probleme de lecture
    when others =>
      Protmaquette.Rendre;
      loop
        P_Afficher.New_Line_Dans_Zone_Reserv(2);
        P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Erreur_fich_maq
        & Nomfichier & P_Messages.Erreur_fich_maq3);
        P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Invite_Quitter);
        P_Afficher.New_Line_Dans_Zone_Reserv;
        P_Afficher.Skip_Line;
      end loop;

  end Init;

  ---------------------------------------------------------------------
  --
  -- Procedure: PoserTrain
  -- But      : Procedure qui pose un train sur la maquette en
  --            definissant son numero externe, son indexe dans la
  --            liste des train, sa position et sa couleur
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
  ---------------------------------------------------------------------
  procedure Posertrain (Trainid    : in P_Train.T_Train_Id;
                        Notrain    : in Integer;
                        Contactid_A: in P_Contact.T_Contact_Id;
                        Contactid_B: in P_Contact.T_Contact_Id;
                        Position   : in P_Section.T_Position := 0.0;
                        Couleur    : in P_Couleur.T_Couleur
                          := P_Couleur.Magenta)
  is
    -- Indique si on a trouve un contact
    -- en cherchant le suivant
    Trouver: Boolean := False;

    -- Section entre le "contactId_A" et
    -- et le contact suivant
    Section_Ou_Placer: P_Section.T_Section_Ptr;

    -- Indique la connection sur laquelle
    -- la tete du train sera place (pour
    -- que la queue du train ne soit pas sur
    -- un aiguillage
    Entree_Ou_Placer: P_Section.T_Connection_Id;

    ----------------------------------------------------------------------
    --
    -- Procedure: Chercher_contact_Suivant
    -- But      : A partir d'une section et d'un sens on cherche sur la
    --            maquette un contact specifie. On effectue cette
    --            recherche en parcourant les voies comme l'aurai fait un
    --            train mais si un aiguillage est sur le chemin on test
    --            les sorties possibles de cet aiguillage.
    --
    --            On met egalement a jour une donnee indiquant la section
    --            placee entre les deux contacts specifiant la place de la
    --            locomotive
    --
    --            (la section de depart peut ne pas etre le contact de depart
    --             car on va utiliser cette fonction de maniere recursive
    --             depuis un aiguillage pour explorer ces divers branches)
    --
    --            Finalement on indique le succes de l'operation, la section
    --            placee entre les contacts ainsi que le numero de la
    --            connexion indiquant ou l'on doit placer la tete du train
    --
    --
    -- Entrees  : Section_depart => Objet section depuis lequel on cherche
    --            Entree_depart  => Numero de connexion indiquant le sens de
    --                              la recherche pour la section courante
    --            Section_ou_poser_depart
    --                           => Objet section place entre le contact de
    --                              depart et la section de depart
    --            Entree_ou_poser_depart
    --                           => Numero de connexion indiquant le sens de
    --                              la recherche pour la section entre-deux
    --            Sections_parcourue
    --                           => Compteur indiquant le nombre de section
    --                              depuis le contact de depart (initialiser
    --                              a 1 lors de la premiere utilisation)
    --            Contact_a_trouver
    --                           => Identificateur du contact recherche
    --            Contacts       => Liste des contacts de la maquette
    --            Sections       => Liste des sections de la maquette
    --
    -- Sortie   : Section_ou_poser
    --                           => Section entre les deux contacts
    --                              (obtenu apres avoir trouver le bon
    --                               contact a partir de la
    --                               "section_ou_poser_depart")
    --            Entree_ou_poser
    --                           => Numero de connexion indiquant ou on
    --                              doit poser la tete du train sur
    --                              la section
    --            Trouver_contact
    --                           => Indique si le contact a ete trouve
    --
    ------------------------------------------------------------------------
    procedure Contact_Suivant
      ( Section_Depart          : in     P_Section.T_Section_Ptr;
        Entree_Depart           : in     P_Section.T_Connection_Id;
        Section_Ou_Poser_Depart : in     P_Section.T_Section_Ptr;
        Entree_Ou_Poser_Depart  : in     P_Section.T_Connection_Id;
        Sections_Parcourue      : in     Integer;
        Contact_A_trouver       : in     P_Contact.T_Contact_Id;
        Contacts                : in     P_Contact.T_Contacts;
        Sections                : in     P_Section.T_Sections;
        Section_Ou_Poser        :    out P_Section.T_Section_Ptr;
        Entree_Ou_Poser         :    out P_Section.T_Connection_Id;
        Trouver                 :    out Boolean )
    is
      -- Section permettant de parcourir les
      -- section de la maquette
      Section_Courante: P_Section.T_Section_Ptr:= Section_Depart;

      -- Section sur laquelle le train sera
      -- pose permet egalement de parcourir
      -- les section de la maquette
      Section_Ou_Poser_Courante: P_Section.T_Section_Ptr
        := Section_Ou_Poser_Depart;

      -- Section que l'on retourne et ou
      -- le train sera pose
      Section_Resultat: P_Section.T_Section_Ptr:= null;

      -- Numero de connexion retourne et ou
      -- la tete du train sera posee
      Entree_Resultat: P_Section.T_Connection_Id:= 1;

      -- Sens de propagation de la recherche
      Entree_Courante: P_Section.T_Connection_Id:= Entree_Depart;

      -- Sens de propagation de la recherche
      -- pour la section entre-deux
      Entree_Ou_Poser_Courante: P_Section.T_Connection_Id
        := Entree_Ou_Poser_Depart;

      -- Numero du contact trouve lorsque
      -- l'on trouve un contact
      Numero_Contact: P_Contact.T_Contact_Id;

      -- Indique si la section est un contact
      Vrai: Boolean := False;

      -- Compteur de section parcourue
      Nbr_Sections_Parcourue: Integer := Sections_Parcourue;

      -- Indique si le contact a ete trouve
      Trouver_Bon_Contact: Boolean := False;

      -- Indique la direction d'un aiguillage
      -- avant l'execution de la procedure
      Direction_Aiguillage: P_Section.T_Direction;

      -- Indique la direction avant
      -- l'execution de la procedure du deuxieme
      -- aiguillage (pour un aiguillage double)
      Direction_Aiguillage_Sec: P_Section.T_Direction;

    begin
      -- On avance dans les sections tant
      -- que l'on a pas trouve de contact
      -- ou de section fin de voie
      loop
        -- On va voir la section voisine
        P_Section.Prendresectionsuivante(Section_Courante,
                                         Entree_Courante,
                                         Sections);

        -- Une fois sur deux on deplace la
        -- reference sur la section ou devrait
        -- etre pose le train ainsi on obtient la
        -- section entre-deux
        if (Nbr_Sections_Parcourue rem 2) = 0
        then
          P_Section.Prendresectionsuivante(Section_Ou_Poser_Courante,
                                           Entree_Ou_Poser_Courante,
                                           Sections);

        end if;

        -- On incremente le compteur de section
        Nbr_Sections_Parcourue:= Nbr_Sections_Parcourue+1;

        -- Si on est sur un aiguillage simple et
        -- sur l'entree commune on recherche le
        -- contact sur les divers chemins de
        -- l'aiguillage
        if ((Section_Courante.all in P_Section.T_Aiguillage_Simple'Class)
           and (Entree_Courante = 1))
        then
          -- On memorise la position precedante de
          -- l'aiguillage
          Direction_Aiguillage := P_Section.Direction(
            P_Section.T_Aiguillage_Generic'Class(Section_Courante.all),
            P_Section.Principal);

          -- On le dirige pour observer sa
          -- premiere branche
          P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                              (Section_Courante.all),
                            P_Section.Tout_Droit, P_Section.Principal);

          -- On cherche le contact de maniere
          -- recursive a partir de l'aiguillage
          Contact_Suivant
            ( Section_Depart          => Section_Courante,
              Entree_Depart           => Entree_Courante,
              Section_Ou_Poser_Depart => Section_Ou_Poser_Courante,
              Entree_Ou_Poser_Depart  => Entree_Ou_Poser_Courante,
              Sections_Parcourue      => Nbr_Sections_Parcourue,
              Contact_A_trouver       => Contact_A_trouver,
              Contacts                => Contacts,
              Sections                => Sections,
              Section_Ou_Poser        => Section_Resultat,
              Entree_Ou_Poser         => Entree_Resultat,
              Trouver                 => Trouver_Bon_Contact);

          -- Si cette branche ne conduit pas
          -- au contact recherche
          if not Trouver_Bon_Contact
          then
            -- On le dirige pour observer sa
            -- deuxieme branche
            P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                                (Section_Courante.all),
                              P_Section.Devie, P_Section.Principal);

            -- On cherche le contact de maniere
            -- recursive a partir de l'aiguillage
            Contact_Suivant
              ( Section_Depart          => Section_Courante,
                Entree_Depart           => Entree_Courante,
                Section_Ou_Poser_Depart => Section_Ou_Poser_Courante,
                Entree_Ou_Poser_Depart  => Entree_Ou_Poser_Courante,
                Sections_Parcourue      => Nbr_Sections_Parcourue,
                Contact_A_trouver       => Contact_A_trouver,
                Contacts                => Contacts,
                Sections                => Sections,
                Section_Ou_Poser        => Section_Resultat,
                Entree_Ou_Poser         => Entree_Resultat,
                Trouver                 => Trouver_Bon_Contact);

          end if;
          -- On remet l'aiguillage dans l'etat
          -- initial
          P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                              (Section_Courante.all),
                            Direction_Aiguillage, P_Section.Principal);

          -- On sort de la boucle car on est
          -- arrive au bout des chemins possibles
          exit;

        -- Si on est sur un aiguillage double et
        -- sur l'entree commune on recherche le
        -- contact sur les divers chemins de
        -- l'aiguillage
        elsif ((Section_Courante.all in P_Section.T_Aiguillage_Double'Class)
           and (Entree_Courante = 1))
        then

          -- On memorise la position precedante de
          -- l'aiguillage
          -- pour l'aiguillage principal
          Direction_Aiguillage := P_Section.Direction(
            P_Section.T_Aiguillage_Generic'Class(Section_Courante.all),
            P_Section.Principal);

          -- et pour le secondaire
          Direction_Aiguillage_Sec := P_Section.Direction(
            P_Section.T_Aiguillage_Generic'Class(Section_Courante.all),
            P_Section.Secondaire);

          -- On les dirige pour observer la
          -- premiere branche
          P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                              (Section_Courante.all),
                            P_Section.Tout_Droit, P_Section.Principal);

          P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                              (Section_Courante.all),
                            P_Section.Tout_Droit, P_Section.Secondaire);

          -- On cherche le contact de maniere
          -- recursive a partir de l'aiguillage
          Contact_Suivant
            ( Section_Depart          => Section_Courante,
              Entree_Depart           => Entree_Courante,
              Section_Ou_Poser_Depart => Section_Ou_Poser_Courante,
              Entree_Ou_Poser_Depart  => Entree_Ou_Poser_Courante,
              Sections_Parcourue      => Nbr_Sections_Parcourue,
              Contact_A_trouver       => Contact_A_trouver,
              Contacts                => Contacts,
              Sections                => Sections,
              Section_Ou_Poser        => Section_Resultat,
              Entree_Ou_Poser         => Entree_Resultat,
              Trouver                 => Trouver_Bon_Contact);

          -- Si cette branche ne conduit pas
          -- au contact recherche
          if not Trouver_Bon_Contact
          then
            -- On les dirige pour observer la
            -- deuxieme branche
            P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                                (Section_Courante.all),
                              P_Section.Devie, P_Section.Principal);

            P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                                (Section_Courante.all),
                              P_Section.Tout_Droit, P_Section.Secondaire);

            -- On cherche le contact de maniere
            -- recursive a partir de l'aiguillage
            Contact_Suivant
              ( Section_Depart          => Section_Courante,
                Entree_Depart           => Entree_Courante,
                Section_Ou_Poser_Depart => Section_Ou_Poser_Courante,
                Entree_Ou_Poser_Depart  => Entree_Ou_Poser_Courante,
                Sections_Parcourue      => Nbr_Sections_Parcourue,
                Contact_A_trouver       => Contact_A_trouver,
                Contacts                => Contacts,
                Sections                => Sections,
                Section_Ou_Poser        => Section_Resultat,
                Entree_Ou_Poser         => Entree_Resultat,
                Trouver                 => Trouver_Bon_Contact);

            -- Si cette branche ne conduit pas
            -- au contact recherche
            if not Trouver_Bon_Contact
            then
              -- On les dirige pour observer la
              -- troisieme branche
              P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                                  (Section_Courante.all),
                                P_Section.Tout_Droit, P_Section.Principal);

              P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                                  (Section_Courante.all),
                                P_Section.Devie, P_Section.Secondaire);

              -- On cherche le contact de maniere
              -- recursive a partir de l'aiguillage
              Contact_Suivant
                ( Section_Depart          => Section_Courante,
                  Entree_Depart           => Entree_Courante,
                  Section_Ou_Poser_Depart => Section_Ou_Poser_Courante,
                  Entree_Ou_Poser_Depart  => Entree_Ou_Poser_Courante,
                  Sections_Parcourue      => Nbr_Sections_Parcourue,
                  Contact_A_trouver       => Contact_A_trouver,
                  Contacts                => Contacts,
                  Sections                => Sections,
                  Section_Ou_Poser        => Section_Resultat,
                  Entree_Ou_Poser         => Entree_Resultat,
                  Trouver                 => Trouver_Bon_Contact);

            end if;

          end if;
           -- On remet les aiguillages dans l'etat
           -- initial
          P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                              (Section_Courante.all),
                            Direction_Aiguillage, P_Section.Principal);

          P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                              (Section_Courante.all),
                            Direction_Aiguillage_Sec, P_Section.Secondaire);

          -- On sort de la boucle car on est
          -- arrive au bout des chemins possibles
          exit;

        -- Si on est sur un aiguillage croix
        -- et quelle que soit son entree on
        -- cherche le contact sur les divers
        -- chemin de l'aiguillage
        elsif ((Section_Courante.all in P_Section.T_Aiguillage_Croix'Class)
              and (Entree_Courante = 1))
        then

          -- On memorise la position precedante de
          -- l'aiguillage
          Direction_Aiguillage:= P_Section.Direction(
            P_Section.T_Aiguillage_Generic'Class(Section_Courante.all),
            P_Section.Principal);

          -- On le dirige pour observer sa
          -- premiere branche
          P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class(Section_Courante.all),
            P_Section.Tout_Droit, P_Section.Principal);

          -- On cherche le contact de maniere
          -- recursive a partir de l'aiguillage
          Contact_Suivant
            ( Section_Depart          => Section_Courante,
              Entree_Depart           => Entree_Courante,
              Section_Ou_Poser_Depart => Section_Ou_Poser_Courante,
              Entree_Ou_Poser_Depart  => Entree_Ou_Poser_Courante,
              Sections_Parcourue      =>  Nbr_Sections_Parcourue,
              Contact_A_trouver       => Contact_A_trouver,
              Contacts                => Contacts,
              Sections                => Sections,
              Section_Ou_Poser        => Section_Resultat,
              Entree_Ou_Poser         => Entree_Resultat,
              Trouver                 => Trouver_Bon_Contact);

          -- Si cette branche ne conduit pas
          -- au contact recherche
          if not Trouver_Bon_Contact
          then
            -- On le dirige pour observer sa
            -- deuxieme branche
            P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                                (Section_Courante.all),
                              P_Section.Devie, P_Section.Principal);

            -- On cherche le contact de maniere
            -- recursive a partir de l'aiguillage
            Contact_Suivant
              ( Section_Depart          => Section_Courante,
                Entree_Depart           => Entree_Courante,
                Section_Ou_Poser_Depart => Section_Ou_Poser_Courante,
                Entree_Ou_Poser_Depart  => Entree_Ou_Poser_Courante,
                Sections_Parcourue      => Nbr_Sections_Parcourue,
                Contact_A_trouver       => Contact_A_trouver,
                Contacts                => Contacts,
                Sections                => Sections,
                Section_Ou_Poser        => Section_Resultat,
                Entree_Ou_Poser         => Entree_Resultat,
                Trouver                 => Trouver_Bon_Contact);

          end if;
          -- On remet l'aiguillage dans l'etat
          -- initial
          P_Section.Diriger(P_Section.T_Aiguillage_Generic'Class
                              (Section_Courante.all),
                            Direction_Aiguillage, P_Section.Principal);

          -- On sort de la boucle car on est
          -- arrive au bout des chemins possibles
          exit;

        -- Si on n'est sur une section normale
        else
          -- Cherche si la section est un contact
          P_Contact.Est_Un_Contact(P_Section.Numero(Section_Courante),
                                   Contacts,
                                   Numero_Contact,
                                   Vrai);

          -- Si c'est un contact et si c'est le
          -- contact recherche
          if (Vrai and (Numero_Contact = Contact_A_trouver))
          then
            -- On indique le resultat de
            -- la recherche
            Trouver_Bon_Contact:= True;

            -- Pour ne pas poser la locomotive
            -- sur un aiguillage on deplace la
            -- section entre-deux jusqu'a la
            -- section normale suivante
            while Section_Ou_Poser_Courante.all
              in P_Section.T_Aiguillage_Generic'Class
            loop
              P_Section.Prendresectionsuivante(Section_Ou_Poser_Courante,
                                               Entree_Ou_Poser_Courante,
                                               Sections);
            end loop;

            -- On affecte les variables resultat
            Section_Resultat:= Section_Ou_Poser_Courante;
            Entree_Resultat := Entree_Ou_Poser_Courante;

          end if;                 -- Fin du test si on est sur le bon contact

        -- Fin du test si la section est un
        end if;                   -- aiguillage

        -- Si c'est un contact ou si c'est une
        -- fin de voie on stoppe la recherche
        exit when ((Section_Courante.all
                    in P_Section.T_Section_Fin_De_Voie'Class)
                   or Vrai );

      end loop;                   -- fin de la boucle de recherche

      -- On affecte les variables de sortie
      Section_Ou_Poser := Section_Resultat;
      Entree_Ou_Poser  := Entree_Resultat;
      Trouver          := Trouver_Bon_Contact;

    end Contact_Suivant;

    ----------------------------------------------------------------------
    --
    -- Procedure: Rechercher_Contact
    -- But      : Trouver la section ou placer un train a partir de deux
    --            contacts fournit par l'utilisateur
    --
    -- Entrees  : Contact_depart => Identificateur du contact vers lequel
    --                              le train sera tourne
    --            Contact_a_trouver
    --                           => Identificateur du deuxieme contacts
    --                              limitant la position du train
    --            Contacts       => Liste des contacts de la maquette
    --            Sections       => Liste des sections de la maquette
    --
    -- Sorties  : Section_ou_poser
    --                           => Section  ou le train devra etre pose
    --            Entree_ou_poser
    --                           => Identificateur de connexion indiquant
    --                              ou la tete du train devra etre pose
    --                              sur la section
    --            Trouver        => Indique si le contact recherche a ete
    --                              trouve
    --
    ----------------------------------------------------------------------
    procedure Rechercher_Contact
      (Contact_Depart     : in     P_Contact.T_Contact_Id;
       Contact_A_trouver  : in     P_Contact.T_Contact_Id;
       Contacts           : in     P_Contact.T_Contacts;
       Sections           : in     P_Section.T_Sections;
       Section_Ou_Poser   :    out P_Section.T_Section_Ptr;
       Entree_Ou_Poser    :    out P_Section.T_Connection_Id;
       Trouver            :    out Boolean)
    is
      -- Variables necessaires du fait
      -- du mode de passage des parametres
      Trouver_Contact: Boolean:= False;
      Section_Resultat: P_Section.T_Section_Ptr;
      Entree_Resultat: P_Section.T_Connection_Id;

    begin
      -- On cherche a partir du premier contact
      -- dans un sens
      Contact_Suivant
        ( Section_Depart          => Sections(P_Contact.Section_Id(Contacts
                                              (Contact_Depart).all)),
          Entree_Depart           => 1,
          Section_Ou_Poser_Depart => Sections(P_Contact.Section_Id(Contacts
                                              (Contact_Depart).all)),
          Entree_Ou_Poser_Depart  => 1,
          Sections_Parcourue      => 1,
          Contact_A_trouver       => Contact_A_trouver,
          Contacts                => Contacts,
          Sections                => Sections,
          Section_Ou_Poser        => Section_Resultat,
          Entree_Ou_Poser         => Entree_Resultat,
          Trouver                 => Trouver_Contact);

      -- Si on a pas trouver on cherche
      -- dans l'autre direction
      if not Trouver_Contact
      then
        Contact_Suivant
          ( Section_Depart          => Sections(P_Contact.Section_Id(Contacts
                                                (Contact_Depart).all)),
            Entree_Depart           => 2,
            Section_Ou_Poser_Depart => Sections(P_Contact.Section_Id(Contacts
                                                (Contact_Depart).all)),
            Entree_Ou_Poser_Depart  => 2,
            Sections_Parcourue      => 1,
            Contact_A_trouver       => Contact_A_trouver,
            Contacts                => Contacts,
            Sections                => Sections,
            Section_Ou_Poser        => Section_Resultat,
            Entree_Ou_Poser         => Entree_Resultat,
            Trouver                 => Trouver_Contact);

      end if;
      -- On retourne les valeurs trouvee
      Trouver:= Trouver_Contact;
      Section_Ou_Poser:=Section_Resultat;
      Entree_Ou_Poser:= Entree_Resultat;

    end Rechercher_Contact;


  begin -- PoserTrain
    Protmaquette.Acquerir;
    -- recherche la section ou poser le
    -- train a partir des deux contacts
    -- passe en parametre
    Rechercher_Contact(Contact_Depart => Contactid_A,
                       Contact_A_trouver => Contactid_B,
                       Contacts => Maquette.Contacts,
                       Sections => Maquette.Sections,
                       Section_Ou_Poser => Section_Ou_Placer,
                       Entree_Ou_Poser => Entree_Ou_Placer,
                       Trouver => Trouver);

    -- Si on a trouve le contact recherche
    if Trouver
    then
      begin
        -- On cree l'objet train qui
        -- sera utilise sur la maquette
        Maquette.Trains(Trainid):= P_Train.Newtrain;

        -- On initialise l'objet train
        -- concerne
        P_Train.Poser(Train    => Maquette.Trains(Trainid).all,
                      Notrain  => Notrain,
                      Section  => Section_Ou_Placer,
                      Entree   => Entree_Ou_Placer,
                      Sections => Maquette.Sections,
                      Position => Position,
                      Couleur  => Couleur,
                      Contacts => Maquette.Contacts,
                      Contacts_Actives => Maquette.Contacts_Actives);

        -- Pour que la locomotive posee
        -- s'affiche a l'ecran on indique
        -- a la tache d'affichage que la
        -- maquette a ete modifiee
        Objetpartager.Maquettemodifiee;

         -- Pour tout les contacts on verifie si
         -- il ont ete active et si oui on
         -- regarde si une tache est en attente
         -- sur ce contact
        for Contact_Id in Maquette.Contacts_Actives'range
        loop
          if Maquette.Contacts_Actives(Contact_Id)
          then
            -- Si il n'y a pas de tache en attente
            -- l'activation a ete inutile on remet
            -- le tableau a jour sinon on laisse
            -- le tableau dans l'etat et il
            -- permettra a la tache en attente de
            -- continuer et c'est elle qui va
            -- remetre le tableau dans son etat
            -- initial
            if Protmaquette.NbrTachesAttend(Contact_Id) = 0
            then
              Maquette.Contacts_Actives(Contact_Id):= False;

            end if;

          end if;
        end loop;
        Protmaquette.Rendre;
      exception
        -- Si on pose deux locos a la meme
        -- place on leve une exception
        when P_Section.Collision =>
          Protmaquette.Rendre;
          P_Afficher.New_Line_Dans_Zone_Reserv(2);
          P_Afficher.Put_Line_Dans_Zone_Reserv("              ------------");
          P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Alarme_Simul);
          P_Afficher.Put_Line_Dans_Zone_Reserv("              ------------");
          P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Collision);
          P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Invite_Quitter);
          P_Afficher.New_Line_Dans_Zone_Reserv;
          Text_Io.New_Line(Fichier_Trace);
          Text_Io.Put_Line(Fichier_Trace, P_Messages.Alarme_Simul);
          Text_Io.Put(Fichier_Trace, P_Messages.Collision);
          Text_Io.New_Line(Fichier_Trace);

        when others =>
          Protmaquette.Rendre;
          raise;

      end;

    -- on indique l'erreur de contact
    else
      Protmaquette.Rendre;
      raise Faux_Contact;

    end if;

    -- Memoriser le numero et la couleur du train
    Objetpartager.MemoriserComposantsLoco (Notrain, Couleur);

    -- Pour que la legende soit mise a jour
    Objetpartager.LegendeModifiee;

  end Posertrain;

  ---------------------------------------------------------------------
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
  ---------------------------------------------------------------------
  procedure Enlevertrain(Trainid: in P_Train.T_Train_Id)
  is
  begin
    Protmaquette.Acquerir;
    -- Si l'identificateur interne
    -- correspond a un train qui
    -- existe pas on ne fait rien
    if not (Trainid = P_Train.Train_Null)
    then
      -- Le train n'est simplement plus actif.
      P_Train.Enlever(Maquette.Trains(Trainid).all);

    end if;

    Protmaquette.Rendre;

  end Enlevertrain;


  ---------------------------------------------------------------------
  --
  -- Procedure: MettreModeSimulation
  -- But      : Procedure qui permet de fixer les modes de simulation
  --
  -- Entrees  : Continu      => Flag indiquant si on utilise le mode
  --                            continu. Soit Continu (true) le
  --                            simulateur ne s'arrete pas soit
  --                            Pas a pas (false) le simulateur
  --                            s'arrete apres chaque pas de simulation
  --                            et l'utilisateur doit clique
  --                            sur l'icone P pour continuer.
  --
  --             Affichage    =>Flag indiquant si on utilise le mode
  --                            Affichage. Soit Affichage (true)
  --                            le simulateur affiche a l'ecran les
  --                            informations consernant la maquette
  --                            a chaque pas de simualtion.
  --                            Soit Pas d'affichage (false) et on
  --                            affiche rien.
  --
  --               Rebond   => Flag indiquant si on utilise le mode
  --              rebond. Soit avec rebond (true) le simulateur
  --                            declenche plusieurs fois un contacts au passage
  --                            d'une locomotive. Soit le mode sans rebond (False)
  --                            le simulateur declenche une seul fois le contact au
  --                            passage d'un train
  --
  -- Remarque  : Si une collision est detectee ou un deraillement
  --             est detectee on l'affiche toujours.
  --
  --            Modifie la variable protegee "Maquette"
  --
  ---------------------------------------------------------------------------
  procedure Mettremodesimulation (Continu   : in Boolean ;
                                  Affichage : in Boolean ;
                                  Rebond    : in Boolean )
  is
  begin
    Protmaquette.Acquerir;

    -- Affecte les modes de simulation
    Maquette.Continu := Continu;
    Maquette.Affichage := Affichage;
    Maquette.Rebond := Rebond;

    Protmaquette.Rendre;

  end Mettremodesimulation;

  ---------------------------------------------------------------------
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
  ---------------------------------------------------------------------
  procedure Mettrevitessetrain (Trainid : in     P_Train.T_Train_Id;
                                Vitesse : in     P_Train.T_Vitesse)
  is
  begin
    Protmaquette.Acquerir;

    -- On agi que si la maquette est
    -- alimentee
    if Maquette.Active
    then
      -- Si l'identificateur interne
      -- correspond a un train qui
      -- existe pas on ne fait rien
      if not (Trainid = P_Train.Train_Null)
      then
        -- On affecte la vitesse au train
        P_Train.Mettrevitesse(Maquette.Trains(Trainid).all,
                              Vitesse);

      end if;

    end if;
    Protmaquette.Rendre;

  end Mettrevitessetrain;

  ---------------------------------------------------------------------
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
  ---------------------------------------------------------------------
  procedure Changerdirectiontrain(Trainid: in P_Train.T_Train_Id)
  is
  begin
    Protmaquette.Acquerir;

    -- On agi que si la maquette est
    -- alimentee
    if Maquette.Active
    then
      -- Si l'identificateur interne
      -- correspond a un train qui
      -- existe pas on ne fait rien
      if not (Trainid = P_Train.Train_Null)
      then
        -- On modifie le sens de marche
        -- du train
        P_Train.Changerdirection(Maquette.Trains(Trainid).all);
        -- Pour que la locomotive dont
        -- modifie le sens de marche soit
        -- afficher on indique a la tache
        -- d'affichage que la maquette
        -- a ete modifiee
        Objetpartager.Maquettemodifiee;

      end if;

    end if;
    Protmaquette.Rendre;

  end Changerdirectiontrain;

  ---------------------------------------------------------------------
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
  ---------------------------------------------------------------------
  procedure Dirigeraiguillage
    (Aiguillageid : in     P_Aiguillage.T_Aiguillage_Id;
     Direction    : in     P_Section.T_Direction)
  is
  begin
    Protmaquette.Acquerir;

    -- On agi que si la maquette est
    -- alimentee
    if Maquette.Active
    then
      -- Si l'aiguillage existe
      if Aiguillageid in 1..Maquette.Nbraiguillages
      then
        -- Si aucune loco n'est dessus
        if not P_Section.Estoccuper(P_Aiguillage.Section(
          Maquette.Aiguillages(Aiguillageid).all))
        then
          -- On specifie la directionde
          -- l'aiguillage
          P_Aiguillage.Dirigeraiguillage(
              Maquette.Aiguillages(Aiguillageid).all,
              Direction);

        else
          -- Si un train est sur la voie
          -- il deraille
          raise P_Section.Derailler;

        end if;
        -- On demande un affichage complet
        -- de la maquette car elle a
        -- peut etre change (direction de
        -- l'aiguillage notee en couleur)
        Debut:= True;

      end if;

    end if;
    Protmaquette.Rendre;

  exception
    -- Si la mofification de la
    -- direction de l'aiguillage
    -- est effectuee alors qu'un
    -- train et dessus cela provoque
    -- un deraillement
    when P_Section.Derailler =>
      Protmaquette.Rendre;
      P_Afficher.Reserver_Affichage;
      P_Afficher.New_Line_Dans_Zone_Reserv(2);
      P_Afficher.Put_Line_Dans_Zone_Reserv("                ------------");
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Alarme_Simul);
      P_Afficher.Put_Line_Dans_Zone_Reserv("                ------------");
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Deraillement);
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Deraillement2);
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Deraillement3);
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Propose_Quitter);
      P_Afficher.New_Line_Dans_Zone_Reserv;
      P_Afficher.Liberer_Affichage;
      Text_Io.New_Line(Fichier_Trace);
      Text_Io.Put_Line(Fichier_Trace, P_Messages.Alarme_Simul);
      Text_Io.Put(Fichier_Trace, P_Messages.Deraillement);
      Text_Io.Put(Fichier_Trace, P_Messages.Deraillement2);
      Text_Io.Put(Fichier_Trace, P_Messages.Deraillement3);
      Text_Io.New_Line(Fichier_Trace);

    when others =>
      Protmaquette.Rendre;
      raise;

  end Dirigeraiguillage;

  ---------------------------------------------------------------------
  --
  -- Procedure: Simuler
  -- But      : Procedure qui fait avancer tout les trains de la
  --            maquette d'une distance en rapport avec leur vitesse
  --            et avec le nombre d'affichage que l'on realise par
  --            seconde (si on peut)
  --
  --            On appelle chaqun de ces mouvements un pas de simulation
  --
  --            Modifie la variable protegee "Maquette"
  --
  ---------------------------------------------------------------------------
  procedure Simuler
  is
  begin
    Protmaquette.Acquerir;

    -- On agi que si la maquette est
    -- alimentee
    if Maquette.Active
    then
      -- On avance tous les trains.
      for Trainid in Maquette.Trains'range loop
        -- Si il sont pose sur la maquette
        if Maquette.Trains(Trainid) /= null
        then
          P_Train.Avancer(Maquette.Trains(Trainid).all,
                          Maquette.Sections,
                          Contacts => Maquette.Contacts,
                          Nbraffichageparseconde => Nbraffichageparseconde,
                          Contacts_Actives => Maquette.Contacts_Actives);
        end if;

      end loop;
      --  Pour tout les contacts on verifie si il ont ete active et si
      --  oui on regarde si une tache est en attente
      for Contact_Id in Maquette.Contacts_Actives'range
      loop
        if Maquette.Contacts_Actives(Contact_Id)
        then
          --  Si il n'y a pas de tache en attente l'activation a ete
          --  inutile on remet le tableau a jour sinon on laisse le
          --  tableau dans l'etat et il permettra a la tache en
          --  attente de continuer et c'est elle qui va remetre le
          --  tableau dans son etat initial
          if Protmaquette.NbrTachesAttend(Contact_Id) = 0
          then
            Maquette.Contacts_Actives(Contact_Id):= False;

          end if;

        end if;

      --  Fin de la boucle parcourant les contacts
      end loop;

    end if;

    Protmaquette.Rendre;

  exception
    when P_Section.Collision =>
      Protmaquette.Rendre;
      raise;

    when P_Section.Derailler =>
      Protmaquette.Rendre;
      raise;

    when others =>
       raise;

  end Simuler;

  ---------------------------------------------------------------------
  --
  -- Procedure: Verifie_attente_contact
  -- But      : Procedure qui vérifie si plus d'une tache est en attente
  --            sur un contact
  --
  --            Consulte la variable protegee "Maquette"
  --
  ---------------------------------------------------------------------
  procedure Verifie_attente_contact
  is
  begin
    Protmaquette.Acquerir;

    -- On agi que si la maquette est
    -- alimentee
    if Maquette.Active
    then
      -- Parcoure les contacts
      for Contact_Id in Maquette.Contacts_Actives'range
      loop
        -- Affiche un message d'erreur si plus d'une tache
        -- attend sur le contact
        if Protmaquette.NbrTachesAttend(Contact_Id) > 1
        then
          P_Afficher.Reserver_Affichage;
          P_Afficher.New_Line_Dans_Zone_Reserv(2);
          P_Afficher.Put_Line_Dans_Zone_Reserv("               ------------");
          P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Alarme_Simul);
          P_Afficher.Put_Line_Dans_Zone_Reserv("               ------------");
          P_Afficher.Put_Dans_Zone_Reserv(P_Messages.Mult_Attente);
          Aff_Int.Put_Dans_Zone_Reserv(Contact_Id,3);
          P_Afficher.New_Line_Dans_Zone_Reserv(2);
          Text_Io.New_Line(Fichier_Trace);
          Text_Io.Put_Line(Fichier_Trace, P_Messages.Alarme_Simul);
          Text_Io.Put(Fichier_Trace, P_Messages.Mult_Attente);
          Int_Io.Put(Fichier_Trace, Contact_Id,3);
          Text_Io.New_Line(Fichier_Trace);
          P_Afficher.Liberer_Affichage;

        end if;

      end loop;

    end if;
    Protmaquette.Rendre;

  end Verifie_attente_contact;

  ---------------------------------------------------------------------
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
  ---------------------------------------------------------------------
  procedure Afficherinfosmaquette
  is
  begin
    Protmaquette.Acquerir;

    P_Afficher.New_Line_Dans_Zone_Reserv(2);
    P_Afficher.Put_Line_Dans_Zone_Reserv(" " & P_Messages.Titre_Info_Maquette);
    P_Afficher.Put_Line_Dans_Zone_Reserv(" " & P_Messages.Description
                                         & Maquette.Description);
    P_Afficher.Put_Line_Dans_Zone_Reserv(" " & P_Messages.Nom_Fichier
                                         & Maquette.Nomfichier);
    P_Afficher.Put_Dans_Zone_Reserv(" " & P_Messages.Nbr_Section);
    Aff_Int.Put_Dans_Zone_Reserv(Maquette.Nbrsections, 1);
    P_Afficher.New_Line_Dans_Zone_Reserv;
    P_Afficher.Put_Dans_Zone_Reserv(" " & P_Messages.Nbr_Contact);
    Aff_Int.Put_Dans_Zone_Reserv(Maquette.Nbrcontacts, 1);
    P_Afficher.New_Line_Dans_Zone_Reserv;
    P_Afficher.Put_Dans_Zone_Reserv(" " & P_Messages.Nbr_Aiguillage);
    Aff_Int.Put_Dans_Zone_Reserv(Maquette.Nbraiguillages, 1);
    P_Afficher.New_Line_Dans_Zone_Reserv(2);

    Protmaquette.Rendre;

  end Afficherinfosmaquette;

  ---------------------------------------------------------------------
  --
  -- Procedure: Afficheretatmaquette
  -- But      : Procedure qui affiche dans la fenetre textuelle
  --            des informations concernant l'Etat de la
  --            maquette
  --
  --            Soit:
  --            1) L'heure
  --            2) La liste des trains (Numero, vitesse)
  --            3) La liste des contacts actifs
  --
  --            Consulte la variable protegee "Maquette"
  --
  -- Entree   : Affichage_Ecran => Indique si l'on ecrit sur l'ecran
  --                               ou seulement dans le fichier trace
  --
  --
  -- Remarque : Cette procedure doit etre utilisee alors que le
  --            moniteur est reserve donc un exclusion mutuelle
  --
  --------------------------------------------------------------------
  procedure Afficheretatmaquette (Affichage_Ecran : Boolean)is

    -----------------------------------------------------------------
    --
    -- Fonction : Livre_temps
    -- But      : Transformer une heure donnee en secondes depuis le
    --            debut du jour en une chaine de caractere commosee
    --            du heure : minute: seconde
    --
    -- Entree   : Heure    => L'heure que l'on desir convertir exprimee
    --                        en secondes depuis le debut du jour 0h00
    --
    -- Retour   : Une chaine de caracteres exprimant l'heure sous la
    --            forme heures:minutes:secondes
    --
    ------------------------------------------------------------------
    function Livre_Temps (Heure: in Duration)
      return String
    is
      -- Conversion pour permettre
      -- l'utilisation de l'attribut image
      -- (LONG_INTEGER car le type
      -- INTEGER n'est pas suffisament long
      -- sur certain systeme)
      Heure_Courante: Long_Integer:= Long_Integer(Heure);

    begin
      -- Conversion en HMS,
      -- concatenation pour rassembler
      -- les elements en
      -- une seule chaine et on la retourne
      return (Long_Integer'Image(Heure_Courante/3600) & ':' &
              Long_Integer'Image((Heure_Courante/60) mod 60) & ':' &
              Long_Integer'Image(Heure_Courante mod 60) & '.');

    end Livre_Temps;

  -- Debut de Afficheretatmaquette
  begin
    Protmaquette.Acquerir;

    -- On affiche l'heure actuelle
    if Affichage_Ecran
    then
      P_Afficher.Put_Dans_Zone_Reserv(P_Messages.Heure);
      P_Afficher.Put_Dans_Zone_Reserv(Livre_Temps(Calendar.Seconds
                                        (Calendar.Clock)));
      P_Afficher.New_Line_Dans_Zone_Reserv;

    end if;

    Text_Io.Put(Fichier_Trace, P_Messages.Heure);
    Text_Io.Put(Fichier_Trace, Livre_Temps(Calendar.Seconds(Calendar.Clock)));
    Text_Io.New_Line(Fichier_Trace);

    -- On affiche l'etat de la maquette
    -- que si elle est alimentee
    if Maquette.Active
    then
      -- On affiche les information sur
      -- les trains
      if Affichage_Ecran
      then
        P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Liste_Train);

      end if;

      Text_Io.Put_Line(Fichier_Trace, P_Messages.Liste_Train);

      for Train in Maquette.Trains'range
      loop
        -- Si ils sont poses sur la maquette
        if Maquette.Trains(Train) /= null
        then
          -- Appel la primitive de l'objet train
          P_Train.Put (Maquette.Trains(Train).all,
                       Affichage_Ecran,
                       Fichier_Trace);
          if Affichage_Ecran
          then
            P_Afficher.New_Line_Dans_Zone_Reserv;

          end if;

        end if;

      end loop;

      if Affichage_Ecran
      then
        P_Afficher.New_Line_Dans_Zone_Reserv;

      end if;

      Text_Io.New_Line(Fichier_Trace);

      -- On affiche la liste des contacts
      -- actif
      if Affichage_Ecran
      then
        P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Liste_Contact);

      end if;

      Text_Io.Put_Line (Fichier_Trace,
                        P_Messages.Liste_Contact);
      for Contact in Maquette.Contacts'range
      loop
        if P_Contact.Estactive(Maquette.Contacts(Contact).all)
        then
          if Affichage_Ecran
          then
            P_Afficher.Put_Dans_Zone_Reserv(P_Messages.Numero);
            Aff_Int.Put_Dans_Zone_Reserv(Contact, 2);
            P_Afficher.Put_Dans_Zone_Reserv(P_Messages.Active);
            P_Afficher.New_Line_Dans_Zone_Reserv;

          end if;

          Text_Io.Put(Fichier_Trace,P_Messages.Numero);
          Int_Io.Put(Fichier_Trace, Contact, 2);
          Text_Io.Put(Fichier_Trace, P_Messages.Active);

        end if;

      end loop;

      if Affichage_Ecran
      then
        P_Afficher.New_Line_Dans_Zone_Reserv(2);

      end if;

      Text_Io.New_Line(Fichier_Trace);

    else
      -- Si la maquette n'est pas activee
      -- on l'affiche
      if Affichage_Ecran
      then
        P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Maq_Off);

      end if;

      Text_Io.Put_Line(Fichier_Trace, P_Messages.Maq_Off);
    end if;

    Protmaquette.Rendre;

  end Afficheretatmaquette;

  ---------------------------------------------------------------------
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
  ---------------------------------------------------------------------
  procedure Affichermaquette
  is
  begin
    Protmaquette.Acquerir;

    -- Si on doit recalculer tout
    -- l'affichage
    --if Debut
    if TRUE
    then
      -- On dessine toutes les sections
      for I in Maquette.Sections'range
      loop
        P_Section.Paint(Maquette.Sections(I).all);

      end loop;

      -- On memorise le dessin obtenu
      -- dans le buffer accumulateur
      Glaccum(Gl_Load, 1.0);

      -- On indique qu'un calcul complet
      -- n'est plus necessaire
      Debut := False;

      -- On affiche les trains sur la
      -- maquette
      for I in Maquette.Trains'range
      loop
        -- Si il sont pose sur la maquette
        if Maquette.Trains(I) /= null
        then
           P_Train.Paint(Maquette.Trains(I).all);

        else
          -- Comme le trains pose occupe les
          -- prmier cases du tableau "Trains"
          -- des qu'une case est vide on sort
          -- de la boucle
          exit;

        end if;

      end loop;

    -- Si un calcul complet n'est pas necessaire
    else
      -- On affiche l'image de la maquette
      Glaccum(Gl_Return, 1.0);

      -- On affiche les trains sur la
      -- maquette
      for I in Maquette.Trains'range
      loop
        -- Si ils sont pose sur la maquette
        if Maquette.Trains(I) /= null
        then
          P_Train.Paint(Maquette.Trains(I).all);

        else
          -- Comme le trains pose occupe les
          -- permieres cases du tableau "Trains"
          -- des qu'une case est vide on sort
          -- de la boucle
          exit;

        end if;

      end loop;

    end if;
    Protmaquette.Rendre;

  end Affichermaquette;

  --------------------------------------------------------------------
  --
  -- Procedure : Reinitialiseraffichage
  -- But       : Demande a la procedure d'affichage de la maquette
  --             de recalculer tout les sections et de ne pas
  --             afficher l'image memorisee de la maquette
  --
  --             Modifie la variable protegee "Debut"
  --
  --------------------------------------------------------------------
  procedure Reinitialiseraffichage
  is
  begin
    Protmaquette.Acquerir;
    Debut := True;
    Protmaquette.Rendre;

  end Reinitialiseraffichage;

--************************************************************************
--
-- Corps de l'objet partage entre les taches de simulation et d'affichage
--
--************************************************************************

  protected body Objetpartager
  is

    ---------------------------------------------------------------------
    --
    -- Procedure: Mette_Mode_Rapide
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
    ---------------------------------------------------------------------
    procedure Mettre_Mode_Rapide
    is
    begin

      Simulationrapide := True;

    end Mettre_Mode_Rapide;

    ---------------------------------------------------------------------
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
    ---------------------------------------------------------------------
    procedure Mettre_Mode_Lent
    is
    begin

      Simulationrapide := False;

    end Mettre_Mode_Lent;

    ---------------------------------------------------------------------
    --
    -- Procedure: Mode_Rapide
    -- But      : Indique si le mode de simulation rapide est en
    --            fonction
    --
    --            Fonction utilisee par le simulateur pour savoir
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
    ---------------------------------------------------------------------
    function Mode_Rapide
      return Boolean
    is
    begin

      return Simulationrapide;

    end Mode_Rapide;

    ---------------------------------------------------------------------
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
    ---------------------------------------------------------------------
    procedure Quittance
    is
    begin

      La_Quittance := True;

    end Quittance;

    ---------------------------------------------------------------------
    --
    -- Entree   : Quittance_effectuee
    -- But      : Entree bloquante tant que l'utilisateur n'a pas
    --            effectue le quittancement en appuyant sur l'icone
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
    ---------------------------------------------------------------------
    entry Quittance_Effectuee
      when La_Quittance
    is
    begin

      La_Quittance:= False;

    end Quittance_Effectuee;

    ---------------------------------------------------------------------
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
    ---------------------------------------------------------------------
    procedure Maquettemodifiee
    is
    begin
      Nouveau:= True;
      -- On memorise l'heure du debut de
      -- demande de l'affichage
      Heuredebutaffichage:= Calendar.Seconds(Calendar.Clock);

    end;

    ---------------------------------------------------------------------
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
    ---------------------------------------------------------------------
    procedure Affichagetermine
    is
    begin

      Continue:= True;

    end;

    ---------------------------------------------------------------------
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
    ---------------------------------------------------------------------
    entry Peutcontinuer
      when (Continue and
           (Calendar.Seconds(Calendar.Clock) - Heuredebutaffichage) >
           1.0/ Duration(Nbraffichageparseconde))
    is
    begin

      Continue := False;

    end Peutcontinuer;

    ---------------------------------------------------------------------
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
    ---------------------------------------------------------------------
    entry Besoinafficher
      when Nouveau
    is
    begin

      Nouveau := False;

    end Besoinafficher;

    ---------------------------------------------------------------------
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
    ---------------------------------------------------------------------
    procedure Mettre_Pause
    is
    begin

      Pause := True;

    end Mettre_Pause;

    ---------------------------------------------------------------------
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
    ---------------------------------------------------------------------
    procedure Enlever_Pause
    is
    begin

      Pause := False;

    end Enlever_Pause;

    ---------------------------------------------------------------------
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
    ---------------------------------------------------------------------
    entry Attendre_Pause
      when not Pause
    is
    begin

      null;

    end Attendre_Pause;
    ---------------------------------------------------------------------
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
    ---------------------------------------------------------------------
    function Mode_Pause
      return Boolean
    is
    begin

      return Pause;

    end Mode_Pause;

    ---------------------------------------------------------------------
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
    ---------------------------------------------------------------------
    entry MettreAJourLegende
      when MiseAJourLegende
    is
    begin -- MettreAJourLegende
      MiseAJourLegende := False;

    end MettreAJourLegende;

    ---------------------------------------------------------------------
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
    ---------------------------------------------------------------------
    procedure LegendeModifiee
    is
    begin -- LegendeModifiee
      -- Indique que la legende doit etre modifiee
      MiseAJourLegende := True;

    end LegendeModifiee;

    --------------------------------------------------------------------------
    --
    -- Procedure : MemoriserComposantsLoco
    -- But       : Memoriser le numero et la couleur de la nieme locomotive.
    --             Controler simultanement que l'on ne depasse pas 4
    --             locomotives. Si tel est la cas, signaler que la fenetre
    --             doit etre redimensionnee.
    --
    --------------------------------------------------------------------------
    procedure MemoriserComposantsLoco (Numero  : T_Train_Id;
                                       Couleur : P_Couleur.T_Couleur)
    is
    begin -- MemoriserComposantsLoco
      -- Rechercher la premiere case libre du tableau (=0), memoriser
      -- et sortir de la boucle de recherche
      for I in Tab_Numeros_Et_Couleurs_Locos'Range
      loop
        if Tab_Numeros_Et_Couleurs_Locos(I).Numero = 0
        then
          Tab_Numeros_Et_Couleurs_Locos(I).Numero  := Numero;
          Tab_Numeros_Et_Couleurs_Locos(I).Couleur := Couleur;
          exit;

        end if;

      end loop;
      -- Une locomotive de plus dans la liste
      Cpt_Locos := Natural'Succ (Cpt_Locos);
      -- Controle de redimensionnement de la fenetre
      if Cpt_Locos > Max_Nb_Locos_Affichables
      then
        -- Signaler qu'il faut agrandir la fenetre
        AgrandirFenetre := True;

      end if;

    end MemoriserComposantsLoco;

    --------------------------------------------------------------------------
    --
    -- Function : FournirComposantsDeLoco
    -- But      : Fournir le numero et la couleur de la nieme locomotive
    -- Retour   : Variable enregistrement contenant les informations
    --
    --------------------------------------------------------------------------
    function FournirComposantsDeLoco (Indice : T_Train_Id)
      return Assoc_Numero_Couleur_Type
    is
    begin -- FournirComposantsDeLoco
      return Tab_Numeros_Et_Couleurs_Locos(Indice);

    end FournirComposantsDeLoco;

  end Objetpartager;


--***********************************************************************
--
-- Tache Simulation
--
--***********************************************************************

  -----------------------------------------------------------------------
  -- Tache       : Simulation
  -- But         : Tache qui simule le compotement de la maquette dans
  --               le temps.
  --               Elle effectue le deplacement des trains sur
  --               la maquette puis, si l'utilisateur l'a demande,
  --               elle affiche l'etat de la maquette et demande une
  --               quittance pour continue apres chaque pas de
  --               simulation
  --
  -- Entree      : Demarrer    => Permet l'exectution de la simulation
  --               Stopper     => Permet l'arret de la simulation
  --               Continuer   => Permet de poursuivre la simulation
  --                              lorsqu'un pas de simulation a ete
  --                              effectue
  --
  -----------------------------------------------------------------------

  -- specification de la tache
  -- simulation.
  task Simulation is
    -- Entree qui permet de demarrer la
    -- simulation.
    entry Demarrer;

    -- Entree qui permet de stopper la
    -- simulation.
    entry Stopper;

  end Simulation;

  -- Corps de la tache simulation
  task body Simulation is
    -- Nombre de fois que l'on avance
    -- les train lors d'un pas
    -- en simulation rapide
    Nbrpassimulationrapide : constant := 5;

  begin
    -- Boucle infinie.
    -- Permet de stopper et demarrer la
    -- maquette plusieurs fois
    -- avec les procedures
    -- activer/desactiver.
    loop
      -- Attente du demarrage de la
      -- simulation.
      accept Demarrer;

      -- Boucle infinie realisant les pas
      -- de simulation
      loop
        -- A chaque pas on verifie si
        -- l'utilisateur desactive la
        -- maquette
        select
          accept Stopper;    -- Si c'est cas on sort de la boucle
            exit;            -- des pas de simulation.
        else

          -- On simule l'avance de tous
          -- les Trains.
          if Objetpartager.Mode_Rapide
          then
            -- En fonctionement rapide on avance
            -- plusieurs fois les trains avant
            -- d'afficher la maquette
            for I in 1..Nbrpassimulationrapide
            loop
              Simuler;

            end loop;

          else
            -- En fonctionement normal on avance
            -- les trains une seule fois
            Simuler;

          end if;

          -- Annonce a l'objet protege que
          -- la maquette a ete modifiee et
          -- qu'il faut la redessiner
          Objetpartager.Maquettemodifiee;

          -- Attent que l'affichage soit termine
          -- avant de continuer
          Objetpartager.Peutcontinuer;

          -- Selon le mode on affiche ou pas
          -- l'etat de la maquette

          -- Comme le trains poses occupent les
          -- premieres cases du tableau "Trains"
          -- si il n'y a pas de train on affiche
          -- rien
          if Maquette.Trains(Maquette.Trains'First) /= null
          then
            if Modeaffichage
            then
              -- Reserve la fenetre textuelle pour
              -- afficher les informations
              -- a propos de la maquette en un seul
              -- bloc (pas entre-coupe d'autres
              -- messages
              P_Afficher.Reserver_Affichage;
              P_Afficher.New_Line_Dans_Zone_Reserv;
              P_Afficher.Put_Line_Dans_Zone_Reserv("****************" &
                                                   "****************");
              P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Info_Simul);

            end if;

            Text_Io.New_Line(Fichier_Trace);
            Text_Io.Put_Line(Fichier_Trace, "****************" &
                                            "****************");

            -- On affiche les informations sur
            -- la Console.

            Afficheretatmaquette(Modeaffichage);

            if Modeaffichage
            then
              P_Afficher.Put_Line_Dans_Zone_Reserv("****************" &
                                                   "****************");
              -- On libere la fenetre textuelle pour
              -- permettre aux autres processus
              -- d'afficher leur message
              P_Afficher.Liberer_Affichage;
            end if;

            Text_Io.Put_Line(Fichier_Trace, "****************" &
                                            "****************");

          end if;

          -- Test si plusieurs taches sont en attente sur un contact
          Verifie_attente_contact;

          -- Selon le mode on attend ou pas
          -- une validation de l'utilisateur
          if Modecontinu
          then
            -- On test si l'utilisateur veut une
            -- pause en mode continu
            Objetpartager.Attendre_Pause;

          else
            -- Attente d'une validation clavier
            -- pour le Mode Pas A Pas.
            Objetpartager.Quittance_Effectuee;

          end if;

        end select;
        -- Pour eviter l'utilisation de toutes
        delay 0.1;                -- les ressources de la machine.

      end loop;                   -- Fin de la boucle des pas de Simulation

    end loop;                     -- Fin de la boucle permetant la
                                  -- l'activation/desactivation de la
                                  -- maquette.

  exception
    --  Si durant l'avancement des trains un probleme c'est produit on
    --  l'affiche a l'ecran avant que le simulateur ne s'arrete
    when P_Section.Collision =>
      P_Afficher.Reserver_Affichage;
      P_Afficher.New_Line_Dans_Zone_Reserv(2);
      P_Afficher.Put_Line_Dans_Zone_Reserv("                ------------");
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Alarme_Simul);
      P_Afficher.Put_Line_Dans_Zone_Reserv("                ------------");
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Collision);
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Invite_Quitter);
      P_Afficher.New_Line_Dans_Zone_Reserv;
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Etat_maq_coll);
      P_Afficher.New_Line_Dans_Zone_Reserv;

      Text_Io.New_Line(Fichier_Trace);
      Text_Io.Put_Line(Fichier_Trace, P_Messages.Alarme_Simul);
      Text_Io.Put_Line(Fichier_Trace, P_Messages.Collision);
      Text_Io.Put_Line(Fichier_Trace, P_Messages.Etat_maq_coll);
      Text_Io.New_Line(Fichier_Trace);
      --  On affiche les informations sur l'etat de la maquette lors
      --  de l'erreur.
      Afficheretatmaquette(True);
      P_Afficher.Liberer_Affichage;

    when P_Section.Derailler =>
      P_Afficher.Reserver_Affichage;
      P_Afficher.New_Line_Dans_Zone_Reserv(2);
      P_Afficher.Put_Line_Dans_Zone_Reserv("                ------------");
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Alarme_Simul);
      P_Afficher.Put_Line_Dans_Zone_Reserv("                ------------");
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Erreur_deraillement);
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Invite_Quitter);
      P_Afficher.New_Line_Dans_Zone_Reserv;
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Etat_maq_derail);
      P_Afficher.New_Line_Dans_Zone_Reserv;

      Text_Io.New_Line(Fichier_Trace);
      Text_Io.Put_Line(Fichier_Trace, P_Messages.Alarme_Simul);
      Text_Io.Put_Line(Fichier_Trace, P_Messages.Erreur_deraillement);
      Text_Io.Put_Line(Fichier_Trace, P_Messages.Etat_maq_derail);
      Text_Io.New_Line(Fichier_Trace);

      --  On affiche les informations sur l'etat de la maquette lors
      --  de l'erreur.
      Afficheretatmaquette(True);
      P_Afficher.Liberer_Affichage;

    --  Si une autre erreur ce produit dans la tache simulateur on
    --  indique que la tache s'est arrete
    when others =>
      P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Erreur_Anormale);

  end Simulation;                -- Fin de la tache simulation

  -----------------------------------------------------------------------
  --
  -- Procedure: Activer
  -- But      : Procedure qui active la simulation.
  --            A partir de ce moment la maquette est prete pour la
  --            simulation.
  --
  --            Cela permet d'utiliser les sous-programmes
  --            agissant sur la maquette (avant l'activation
  --            ils n'auraient pas fonctionne)
  --
  --            Elle active la maquette et fait demarrer la
  --            simulation
  --
  --            Modifie la variable protegee "Maquette"
  --
  ------------------------------------------------------------------------
  procedure Activer
  is
    -- Pour le nom du fichier trace
    Nom_Fichier: String(1..255);

    -- Taille du nom de fichier
    Taille: Integer;

  begin
    -- On active la maquette
    Protmaquette.Acquerir;
    Maquette.Active := True;
    Protmaquette.Rendre;

    begin
      Taille:= Ada.Command_Line.Command_Name'Length;

      if Taille <= Nom_Fichier'Length
      then
        -- On recupere le nom du fichier executable.
        Nom_Fichier(1..Taille) := Ada.Command_Line.Command_Name;

        -- On utilise le nom de l'executable avec
        -- l'extension "txt"
        Nom_Fichier(Taille-3..Taille) := ".txt";

        -- On ouvre le fichier trace
        Text_Io.Create(File => Fichier_Trace,
                       Mode => Text_Io.Out_File,
                       Name => Nom_Fichier(1..Taille));

      else
        P_Afficher.Reserver_Affichage;
        P_Afficher.New_Line_Dans_Zone_Reserv(2);
        P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Err_Nom_Fich_trace);
        P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Err_Nom_Fich_trace2);
        P_Afficher.New_Line_Dans_Zone_Reserv(2);
        P_Afficher.Liberer_Affichage;

      end if;

    exception
      when Text_io.Name_Error | Text_io.Status_error | Text_io.Use_Error=>
        P_Afficher.Reserver_Affichage;
        P_Afficher.New_Line_Dans_Zone_Reserv(2);
        P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Erreur_Fich_Trace);
        P_Afficher.New_Line_Dans_Zone_Reserv(2);
        P_Afficher.Liberer_Affichage;

    end;
    -- On demarre la simulation.
    Simulation.Demarrer;

  end Activer;

  ------------------------------------------------------------------------
  --
  -- Procedure: Desactiver
  -- But      : Procedure qui desactive la simulation.
  --
  --            Cela rend les sous-programme agissant sur
  --            la maquette inutilent
  --
  --            Elle desactive la maquette et arrete la simulation
  --
  --            Modifie la variable protegee "Maquette"
  --------------------------------------------------------------------------
  procedure Desactiver
  is
  begin
    -- On desactive la maquette
    Protmaquette.Acquerir;
    Maquette.Active := False;
    Protmaquette.Rendre;

    -- On stoppe la simulation.
    Simulation.Stopper;
    -- On ferme le fichier trace
    Text_Io.Close(Fichier_Trace);

  end Desactiver;

  ---------------------------------------------------------------------
  --
  -- Procedure : AttendreActivationContact
  -- But       : Procedure pour la gestion des contacts. Elle fait
  --             attendre (la tache appelante) qu'une locomotive passe
  --             sur le contact transmis en parametre.
  --
  -- Entrees  :  No_Contact=>   Numero du contact dont on attend
  --                            l'activation
  --
  ---------------------------------------------------------------------
  procedure Attendreactivationcontact(No_Contact : P_Contact.T_Contact_Id)
  is
  begin

    Protmaquette.Attendreactivationcontact(No_Contact);

  end;

  ----------------------------------------------------------------------------
  --
  -- Procedure : AfficherLegende
  -- But       : (Re)afficher la legende de correspondance des numeros et
  --             des couleurs des locomotives
  --
  ----------------------------------------------------------------------------
  procedure AfficherLegende
  is
    Numero_Et_Couleur_Temp  : Assoc_Numero_Couleur_Type;
    Couleur                 : P_Couleur.T_Couleur_Rvba;

  begin -- AfficherLegende

    -- Afficher les informations
    glPushMatrix;
    glDisable(GL_LIGHTING);
    glRasterPos3f(1.0, 1.0, 0.0);
    for C in P_Messages.Chaine_Couleur_Loco'range
    loop
      glutBitmapCharacter(GLUTBITMAPHELVETICA12'access,
                          Character'Pos(P_Messages.Chaine_Couleur_Loco(C)));

    end loop;
    glRasterPos3f(5.0, 1.0, 0.0);
    for C in P_Messages.Chaine_Numero_Loco'range
    loop
      glutBitmapCharacter(GLUTBITMAPHELVETICA12'access,
                          Character'Pos(P_Messages.Chaine_Numero_Loco(C)));

    end loop;
    glEnable(GL_LIGHTING);
    glPopMatrix;
    gltranslatef (2.5, 3.0, 0.0);
    -- Parcourir le tableau de memorisation des numeros des locomotives
    for I in Tab_Numeros_Et_Couleurs_Locos_Type'Range
    loop
      Numero_Et_Couleur_Temp := Objetpartager.FournirComposantsDeLoco(I);
      -- Afficher la legende si necessaire : par defaut, le tableau est
      -- initialise avec les numeros a 0, si la valeur du numero chnage,
      -- il faut (re)afficher la legende
      if Numero_Et_Couleur_Temp.Numero /= 0
      then
        Couleur := P_Couleur.Transforme(Numero_Et_Couleur_Temp.Couleur);

        -- Afficher la couleur de la locomotive
        glPushMatrix;
        -- On specifie la couleur du dessin en determinant les proprietes de
            -- reflexion de la lumiere de l'objet dessine
        Glmaterialfv (Gl_Front,
                      Gl_Ambient,
                      Couleur(1)'Unchecked_Access);
        Glmaterialfv (Gl_Front,
                      Gl_Diffuse,
                      Couleur(1)'Unchecked_Access);

        glScalef (4.0, 1.0, 1.0);
        glutSolidCube (1.0);
        glPopMatrix;

        Couleur := P_Couleur.Transforme(P_Couleur.Blanc);

        -- Dessiner le numero de la locomotive
        glPushMatrix;
        glDisable(GL_LIGHTING);

        -- En fonction du nombre a afficher
        case Numero_Et_Couleur_Temp.Numero is
          -- le nombre est compose d'un seul chiffre
          when 0 .. 9 =>
            glRasterPos3f(4.0, 0.35, 0.0);
            glutBitmapCharacter(GLUTBITMAPHELVETICA12'access,
                                Character'Pos('0') +
                                  Numero_Et_Couleur_Temp.Numero);

          -- le nombre est compose de deux chiffres
          when 10 .. 80 =>
            glRasterPos3f(3.75, 0.35, 0.0);
            glutBitmapCharacter(GLUTBITMAPHELVETICA12'access,
                                Character'Pos('0') +
                                  (Numero_Et_Couleur_Temp.Numero / 10));
            glutBitmapCharacter(GLUTBITMAPHELVETICA12'access,
                                Character'Pos('0') +
                                  (Numero_Et_Couleur_Temp.Numero rem 10));

          when others => null;

        end case;

        glEnable(GL_LIGHTING);
        glPopMatrix;

        glTranslatef (0.0, 2.0, 0.0);

      end if;

    end loop;

  end AfficherLegende;

end P_Maquette;
