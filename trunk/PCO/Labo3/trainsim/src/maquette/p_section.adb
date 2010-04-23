--------------------------------------------------------------------------
--
-- Nom du fichier   : P_Section.adb
-- Auteur           : P. Girardet sur la base du travail de
--                    M.Pascal Binggeli & M.Vincent Crausaz
--
-- Date de creation : 12.10.97
-- Version          : 3.0
-- Derniere modifs. : Decembre 1997
-- Raison de la
-- Modification     : Ajout d'une interface graphique
--
-- Projet           : Simulateur de maquette
-- Module           : Section
--
-- But              : Module mettant a disposition des objets sections
--                    derivant tous d'un meme objet. Ils peuvent donc
--                    etre gerer de facon similaire.
--
-- Fonctions exportees  :
--
-- Materiel
-- particulier       : Les dll "OpenGl32.dll" et "Glu32.dll" doivent
--                     etre dans le repertoire systeme de windows
--
--------------------------------------------------------------------------

-- Pour utiliser les fonctions Sin, Cos, etc. sur des reel
with Ada.Numerics.Elementary_Functions;
  use Ada.Numerics.Elementary_Functions;

-- Pour gerer les entrees/sorties sur l'ecran
with P_Afficher;

-- Pour utiliser opengl
with Gl; use Gl;

-- Pour utiliser la librairie GLU
with Glu; use Glu;


package body P_Section is

-- ***********************************************************************
--
-- Paquetages
--
-- ***********************************************************************

  -- Pour gerer les entrees/sorties d'entier a l'ecran.
  package Int_Io is new P_Afficher.Integer_Io(Integer);

  -- Pour gerer les entrees/sorties de reel a l'ecran.
  package Flo_Io is new P_Afficher.Float_Io(Float);

  -- Pour gerer les entrees/sorties de boolean a l'ecran.
  package Bool_Io is new P_Afficher.Enumeration_Io(Boolean);

-- ***********************************************************************
--
-- Sous-programme interne au paquetage
--
-- ***********************************************************************
  --------------------------------------------------------------------
  --
  -- Fonction : Inverse
  -- But      : Inverse la valeur du type enumere T_Orientation
  --
  --            C'est-a-dire que si la valeur est "droite: on
  --            retourne "gauche" et si c'est "gauche" on retourne
  --            "droite"
  --
  -- Entree   : Orientation    => Valeur du type enumere
  --                              T_Orientation que l'on desir
  --                              inverser
  -- Retour   : La valeur du type enumere inverse a celle donnee
  --            en parametre
  --
  --------------------------------------------------------------------
  function Inverse (Orientation : in T_Orientation)
    return T_Orientation
  is
  begin
    if Orientation = Droite
    then
      return Gauche;

    else
      return Droite;

    end if;

  end Inverse;

  -----------------------------------------------------------------------
  --
  -- Fonction : Chercherentree
  -- But      : Fonction qui recherche dans un table de connection
  --            l'index correspondant a la section passee en parametre
  --
  --            On peut donc trouver l'entree ou la sortie de la section
  --            a qui appartient la table a laquelle est fixee la
  --            section dont l'identificateur est fournit
  --
  --
  -- Entree   : Connections     => Une Table des connections
  --         SectionID       => L'identificateur de la section voulu
  --
  --
  -- La fonction retourne l'index correspondant.
  --------------------------------------------------------------------------
  function Chercherentree(Connections : in T_Connections;
                          Sectionid   : in T_Section_Id)
    return T_Connection_Id
  is
  begin
    -- Si la section specifiee n'existe
    -- pas on retourne un index null
    if Sectionid = Section_Null then
      return Connection_Null;
    else
      -- On parcourt les connections.
      for Index in Connections'range loop
        -- Si on a trouve l'identificateur correspondant,
        -- on retourne l'index.
        if Connections(Index) = Sectionid
        then
          return Index;

        end if;

      end loop;

    end if;

    -- Si on ne trouve pas, on retourne un identificateur
    -- par defaut.
    return 0;

  end Chercherentree;

  -----------------------------------------------------------------------
  --
  -- Fonction : Point_Suivant_Droit
  -- But      : Calcule la position dans le plan du point se touvant
  --            a l'autre bout d'une section droite dont la dimension et
  --            le point de depart sont fournit
  --
  --                           *  Point recherche
  --                           |
  --         Vecteur    |      |
  --                           |
  --                           *    Point de depart
  --
  -- Entree   : Point       => Point dans le plan qui est le depart
  --                           de la section
  --            Vecteur     => Vecteur indiquant la direction de la
  --                           section depuis ce point
  --            Longueur    => Indique la taille de la section
  --
  --
  -- Retour   : Un point se trouvant a l'autre bout de la section
  --            droite
  --
  -----------------------------------------------------------------------
  function Point_Suivant_Droit (Point     : in T_Point;
                                Vecteur   : in T_Vecteur;
                                Longueur  : in Float)
    return T_Point
  is
    -- Le point recherche
    Le_Point_Suivant: T_Point;

  begin
    -- Selon les parametre on calcule le point
    Le_Point_Suivant.X := Point.X + Longueur *
                          Cos(Arctan(Vecteur.Y,Vecteur.X,360.0), 360.0);
    Le_Point_Suivant.Y := Point.Y + Longueur *
                          Sin(Arctan(Vecteur.Y,Vecteur.X,360.0), 360.0);

    -- On retourne les point calcule
    return Le_Point_Suivant;

  end Point_Suivant_Droit;

  -----------------------------------------------------------------------
  --
  -- Procedure: Segment_Droit
  -- But      : Dessine avec la librairie OpenGl un section droite
  --            dont la dimension et le point de depart sont fournit
  --
  --
  --                           *  Point recherche
  --                           |
  --         Vecteur    |      |
  --                           |
  --                           *    Point de depart
  --
  -- Entree   : Point       => Point dans le plan qui est le depart
  --                           de la section
  --            Vecteur     => Vecteur indiquant la direction de la
  --                           section depuis ce point
  --            Longueur    => Indique la taille de la section
  --            Largueur    => Indique la largueur de la section
  --
  --
  -----------------------------------------------------------------------
  procedure Segment_Droit(Point     : in     T_Point;
                          Vecteur   : in     T_Vecteur;
                          Longueur  : in     Float;
                          Largueur  : in     Float)
  is
  begin
    -- Sauve la matrice "modelview" sur la
    -- pile, on la retablira a la fin de la
    -- procedure ainsi les transformations
    -- effectuee n'agiront que sur les
    -- objets dessine dans la procedure
    Glpushmatrix;

    -- Place la section a l'endroit demande
    Gltranslatef (Glfloat(Point.X), Glfloat(Point.Y), 0.0);

    -- Oriente la section selon le vecteur
    Glrotatef (Glfloat(Arctan(Vecteur.Y,Vecteur.X,360.0)),
       0.0, 0.0, 1.0);

    -- dessine la section droite
    Glrectf(0.0, Glfloat(Largueur/2.0), Glfloat(Longueur),
       Glfloat(-Largueur/2.0));

    -- On retablit le contexte precedant l'execution de la fonction
    Glpopmatrix;

  end Segment_Droit;

  -----------------------------------------------------------------------
  --
  -- Fonction : Point_Suivant_Courbe
  -- But      : Calcule la position dans le plan du point se touvant
  --            a l'autre bout d'une section courbe dont la dimension et
  --            le point de depart sont fournit
  --
  --                             *  Point recherche
  --                            |
  --         Vecteur    |      |
  --                           |
  --                           *    Point de depart
  --
  -- Entree   : Point       => Point dans le plan qui est le depart
  --                           de la section
  --            Vecteur     => Vecteur indiquant la direction de la
  --                           section depuis ce point
  --            Rayon       => Indique le rayon de la section
  --            Orientation => Indique dans quel direction droite ou
  --                           est la courbure de la section
  --            Angle       => Indique la portion du cercle realise
  --                           par la section
  --
  -- Retour   : Un point se trouvant a l'autre bout de la section
  --            courbe
  --
  -----------------------------------------------------------------------
  function Point_Suivant_Courbe(Point       : in T_Point;
                                Vecteur     : in T_Vecteur;
                                Rayon       : in Float;
                                Orientation : in T_Orientation;
                                Angle       : in Float)
    return T_Point
  is
    -- Point recherche
    Le_Point_Suivant: T_Point;

  begin
    -- Selon les parametres on calcul le point
    if Orientation = Droite
    then
      Le_Point_Suivant.X := Point.X +
        ( (-Rayon * Sin(-Angle, 360.0)) *
          Cos(Arctan(Vecteur.Y, Vecteur.X, 360.0),360.0) -
          (Rayon * Cos(-Angle, 360.0) - Rayon) *
          Sin(Arctan(Vecteur.Y, Vecteur.X, 360.0),360.0)
        );

      Le_Point_Suivant.Y := Point.Y +
        ( (-Rayon * Sin(-Angle, 360.0)) *
          Sin(Arctan(Vecteur.Y, Vecteur.X, 360.0),360.0) +
          (Rayon * Cos(-Angle, 360.0) - Rayon) *
          Cos(Arctan(Vecteur.Y, Vecteur.X, 360.0),360.0)
        );

    else
       Le_Point_Suivant.X := Point.X +
        ( (Rayon * Sin(Angle, 360.0)) *
          Cos(Arctan(Vecteur.Y, Vecteur.X, 360.0),360.0) -
          (-Rayon * Cos(Angle, 360.0) + Rayon) *
          Sin(Arctan(Vecteur.Y, Vecteur.X, 360.0),360.0)
        );

       Le_Point_Suivant.Y := Point.Y +
        ( (Rayon * Sin(Angle, 360.0)) *
          Sin(Arctan(Vecteur.Y, Vecteur.X, 360.0),360.0) +
          (-Rayon * Cos(Angle, 360.0) + Rayon) *
          Cos(Arctan(Vecteur.Y, Vecteur.X, 360.0),360.0)
        );

    end if;

    -- On retourne le point calcule
    return  Le_Point_Suivant;

  end Point_Suivant_Courbe;

  -----------------------------------------------------------------------
  --
  -- Fonction : Vecteur_Suivant_Courbe
  -- But      : Calcule le vecteur indiquant le direction de la de
  --            section suivante qui sera placee au bout d'une
  --            section courbe dont on connait la direction au depart
  --            et la portion de cercle realisee.
  --
  --
  --                             *
  --                            |
  --   Vecteur depart  |       |     Vecteur recherche   /
  --                           |
  --                           *
  --
  -- Entree   : Vecteur     => Vecteur indiquant la direction de la
  --                           section
  --            Orientation => Indique dans quel direction droite ou
  --                           est la courbure de la section
  --            Angle       => Indique la portion du cercle realise
  --                           par la section
  --
  -- Retour   : Le vecteur indiquant la direction de la section
  --            suivante
  --
  -----------------------------------------------------------------------
  function Vecteur_Suivant_Courbe (Vecteur     : in T_Vecteur;
                                   Orientation : in T_Orientation;
                                   Angle       : in Float)
    return T_Vecteur
  is
    -- Le vecteur recherche
    Le_Vecteur_Suivant: T_Vecteur;

  begin
    -- Selon les parametres on calcule
    -- le vecteur
    if Orientation = Droite
    then
      Le_Vecteur_Suivant.X :=
        Cos((Arctan(Vecteur.Y, Vecteur.X, 360.0) - Angle), 360.0);
      Le_Vecteur_Suivant.Y :=
        Sin((Arctan(Vecteur.Y, Vecteur.X, 360.0) - Angle), 360.0);

    else
       Le_Vecteur_Suivant.X:=
          Cos((Arctan(Vecteur.Y, Vecteur.X, 360.0) + Angle), 360.0);
       Le_Vecteur_Suivant.Y:=
          Sin((Arctan(Vecteur.Y, Vecteur.X, 360.0) + Angle), 360.0);

    end if;

    -- Onre tourne le resultat du
    -- calcul
    return Le_Vecteur_Suivant;

  end Vecteur_Suivant_Courbe;

  -----------------------------------------------------------------------
  --
  -- Procedure : Segment_Courbe
  -- But       : Dessine avec la librairie OpenGl  une section
  --             courbe dont la dimension et le point de depart sont
  --             fournis
  --
  --                             *
  --                            |
  --         Vecteur    |      |
  --                           |
  --                           *    Point de depart
  --
  -- Entree   : Point       => Point dans le plan qui est le depart
  --                           de la section
  --            Vecteur     => Vecteur indiquant la direction de la
  --                           section depuis ce point
  --            Rayon       => Indique le rayon de la section
  --            Orientation => Indique dans quel direction droite ou
  --                           est la courbure de la section
  --            Angle       => Indique la portion du cercle realise
  --                           par la section
  --            Largueur    => Indique la largueur de la section
  --
  --
  -----------------------------------------------------------------------
  procedure Segment_Courbe (Point       : in     T_Point;
                            Vecteur     : in     T_Vecteur;
                            Rayon       : in     Float;
                            Orientation : in     T_Orientation;
                            Largueur    : in     Float;
                            Angle       : in     Float)
  is
    -- Definition d'un objet quadric.
    -- Les quadric font partie de la GLU et sont utiles pour dessiner
    -- des formes geometriques simples
    Portion_De_Disque: gluquadricobjptr;

  begin
    -- Cree une instance d'un Quadric
    Portion_De_Disque:= Glunewquadric;

    -- Sauve la matrice "modelview" sur la pile, on la retablira a la fin
    -- de la procedure ainsi les transformations effectuee n'agiront que
    -- sur les objets dessine dans la procedure
    Glpushmatrix;

    -- Place la section a l'endroit demande
    Gltranslatef (Glfloat(Point.X), Glfloat(Point.Y), 0.0);

    -- Oriente la section selon le vecteur
    Glrotatef (Glfloat(Arctan(Vecteur.Y,Vecteur.X,360.0)),
       0.0, 0.0, 1.0);

    -- selon l'orientation on dessine differement
    if Orientation = Droite
    then
      -- Place une extremite de la portion
      -- de cercle a l'origine
      Gltranslatef (0.0, Glfloat(-Rayon), 0.0);

      -- Dessine la portion de cercle
      Glupartialdisk(Portion_De_Disque,
                     Gldouble(Rayon-Largueur/2.0),
                     Gldouble(Rayon+ Largueur/2.0),
                     20, 20, 0.0, Gldouble(Angle));

    else
      -- Place la portion de cercle en
      -- direction de l'axe x positif
      Glrotatef(180.0, 0.0, 0.0, 1.0);

      -- Place une extremite de la portion
      -- de cercle a l'origine
      Gltranslatef (0.0, Glfloat(-Rayon), 0.0);

      -- Dessine la portion de cercle
      Glupartialdisk(Portion_De_Disque,
                     Gldouble(Rayon-Largueur/2.0),
                     Gldouble(Rayon+ Largueur/2.0),
                     20, 20, 0.0, Gldouble(-Angle));
    end if;

    -- On retablit le contexte precedant l'execution de la fonction
    Glpopmatrix;
    -- Detruit l'instance du Quadric
    Gludeletequadric(Portion_De_Disque);

  end Segment_Courbe;

  -----------------------------------------------------------------------
  --
  -- Fonction : Point_Suivant_Decale
  -- But      : Calcule la position dans le plan du point se touvant
  --            decale sur la droite ou sur la gauche d'un angle
  --            determine selon un centre calcule a partir du point
  --            et d'une direction de depart. Calcule le point a
  --            cote pour une section croix.
  --
  --                           *  *
  --                           |  |
  --                            ||
  --         Vecteur   /        ||
  --                           |  |
  --       Point de depart     *  *   Point recherche
  --
  -- Entree   : Point       => Point dans le plan qui est le depart
  --                           de la section
  --            Vecteur     => Vecteur indiquant la direction de la
  --                           section depuis ce point
  --            Orientation => Indique dans quel direction droite ou
  --                           est est le point recherche
  --            Angle       => Indique l'angle entre les deux
  --                           section droite realisant la section
  --                           croix
  --
  -- Retour   : Un point se trouvant a cote du point fournit
  --            est qui est une autre extremite d'une section croix
  --
  -----------------------------------------------------------------------
  function Point_Suivant_Decale(Point       : in T_Point;
                                Vecteur     : in T_Vecteur;
                                Longueur    : in Float;
                                Orientation : in T_Orientation;
                                Angle       : in Float)
    return T_Point
  is
    -- Le point cherche
    Le_Point_Suivant: T_Point;

  begin
    -- On calcul le point recherche selon les parametres
    if Orientation = Droite
    then
      Le_Point_Suivant.X := Point.X + (
      ((-Longueur/2.0) * Cos(Angle,360.0) + (Longueur/2.0)) *
      Cos(Arctan(Vecteur.Y, Vecteur.X, 360.0), 360.0) -
      ((-Longueur/2.0) * Sin(Angle,360.0)) *
      Sin(Arctan(Vecteur.Y, Vecteur.X, 360.0), 360.0));

      Le_Point_Suivant.Y := Point.Y + (
      ((-Longueur/2.0) * Cos(Angle,360.0) + (Longueur/2.0)) *
      Sin(Arctan(Vecteur.Y, Vecteur.X, 360.0), 360.0) +
      ((-Longueur/2.0) * Sin(Angle,360.0)) *
      Cos(Arctan(Vecteur.Y, Vecteur.X, 360.0), 360.0));

    else
      Le_Point_Suivant.X := Point.X + (
      ((-Longueur/2.0) * Cos(-Angle,360.0) + (Longueur/2.0)) *
      Cos(Arctan(Vecteur.Y, Vecteur.X, 360.0), 360.0) -
      ((-Longueur/2.0) * Sin(-Angle,360.0)) *
      Sin(Arctan(Vecteur.Y, Vecteur.X, 360.0), 360.0));

      Le_Point_Suivant.Y := Point.Y + (
      ((-Longueur/2.0) * Cos(-Angle,360.0) + (Longueur/2.0)) *
      Sin(Arctan(Vecteur.Y, Vecteur.X, 360.0), 360.0) +
      ((-Longueur/2.0) * Sin(-Angle,360.0)) *
      Cos(Arctan(Vecteur.Y, Vecteur.X, 360.0), 360.0));

    end if;

    -- On retourne le resultat du calcul
    return Le_Point_Suivant;

  end Point_Suivant_Decale;

  -----------------------------------------------------------------------
  --
  -- Fonction : Vecteur_Suivant_Decale
  -- But      : Calcule le vecteur indiquant la direction de la
  --            section droite composant une section croix qui
  --            croise la section dont on connait le point et la
  --            direction de depart.
  --
  --                           *  *
  --                           |  |
  --                            ||
  --   Vecteur de depart   /    ||    Vecteur recherche \
  --                           |  |
  --                           *  *
  --
  -- Entree   : Vecteur     => Vecteur indiquant la direction de la
  --                           premiere section droite depuis le
  --                           depart
  --            Orientation => Indique dans quel direction droite ou
  --                           est l'autre section droite
  --            Angle       => Indique l'angle entre les deux
  --                           section droite realisant la section
  --                           croix
  --
  -- Retour   : Un vecteur indiquant la direction la deuxieme
  --            section droite lorsqu'on a fourni la direction de
  --            la premiere
  --
  -----------------------------------------------------------------------
  function Vecteur_Suivant_Decale (Vecteur      : in T_Vecteur;
                                   Orientation  : in T_Orientation;
                                   Angle        : in Float)
    return T_Vecteur
  is
    -- Le vecteur recherche
    Le_Vecteur_Suivant: T_Vecteur;

  begin
    -- Selon les parametres on calcul le vecteur
    if Orientation = Droite
    then
      Le_Vecteur_Suivant.X :=
         Cos((Arctan(Vecteur.Y, Vecteur.X, 360.0) + Angle),360.0);

      Le_Vecteur_Suivant.Y :=
         Sin((Arctan(Vecteur.Y, Vecteur.X, 360.0) + Angle),360.0);

    else
      Le_Vecteur_Suivant.X :=
         Cos((Arctan(Vecteur.Y, Vecteur.X, 360.0) - Angle),360.0);

      Le_Vecteur_Suivant.Y :=
         Sin((Arctan(Vecteur.Y, Vecteur.X, 360.0) - Angle),360.0);

    end if;

    -- On retourne le resultat
    return Le_Vecteur_Suivant;

  end Vecteur_Suivant_Decale;


-- ***********************************************************************
--
-- Primitives d'une section elementaire
--
-- ***********************************************************************
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
  procedure Put (Section: in     T_Section_Generic)
  is
  begin
    -- On affiche son numero
    P_Afficher.Put_Dans_Zone_Reserv("Num: ");
    Int_Io.Put_Dans_Zone_Reserv(Section.Numero, 4);

    -- On affiche si elle est occupee ou non
    P_Afficher.Put_Dans_Zone_Reserv(" Occupe: ");
    Bool_Io.Put_Dans_Zone_Reserv(Section.Occupe);
    P_Afficher.New_Line_Dans_Zone_Reserv;

    -- On affiche les sections connectee
    P_Afficher.Put_Dans_Zone_Reserv(" Conn:");
    for C in Section.Connections'range
    loop
      P_Afficher.Put_Dans_Zone_Reserv(" ");
      Int_Io.Put_Dans_Zone_Reserv(Section.Connections(C), 4);

    end loop;

  end;

-- ***********************************************************************
--
-- Primitives d'une section simple
--
-- ***********************************************************************
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
  function Prendresortie (Section : in T_Section_Simple;
                          Entree  : in T_Connection_Id)
    return T_Connection_Id
  is
  begin
    -- Retoure l'extremite opposee
    return Entree mod 2 + 1;

  end Prendresortie;

-- ***********************************************************************
--
-- Primitives d'une section simple droite
--
-- ***********************************************************************

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
  function New_Section_Droite(Numero      : in T_Section_Id;
                              Connections : in T_Connections;
                              Longueur    : in Float)
    return T_Section_Droite_Ptr
  is
  begin
    -- Cree et initialise l'objet
    return new T_Section_Droite'
      ( Nbrconnections => 2,
        Numero         => Numero,
        Occupe         => False,
        Connections    => Connections(1..2),
        Longueur       => Longueur,
        Point          => (0.0, 0.0),
        Vecteur        => (0.0, 0.0),
        Couleur        => P_Couleur.Couleur_Segment_Inactif );

  end New_Section_Droite;

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
  procedure Placer(Section  : in out T_Section_Droite;
                   Point    : in     T_Point;
                   Vecteur  : in     T_Vecteur;
                   Preced   : in     T_Section_Id;
                   Suivant  :    out T_Section_A_placer )
  is
    -- Information pour placer les sections connectees
    Section_Connectee: T_Section_A_placer(1..2):=
      (others=>(0,(0.0,0.0),(0.0,0.0),0));

    -- Le point a l'autre extremite de la section
    Le_Point_Suivant: T_Point;

  begin
    -- On calcul le point a l'autre extremite de la section
    Le_Point_Suivant := Point_Suivant_Droit(Point, Vecteur,
                                            Section.Longueur);

    -- Selon la section precedante on
    -- determine les sections qui
    -- devront etre placees et
    -- on s'arrange pour memoriser
    -- la position de l'entree 1
    case Chercherentree(Section.Connections, Preced)
    is
      -- Si la section precedante est  connectee a l'entree 1
      when 1 =>
        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- Fournit les informations pour placer les sections connectee

        -- Le numero
        Section_Connectee(1).Section_Id := Section.Connections(2);

        -- La position
        Section_Connectee(1).Vecteur:= Vecteur;
        Section_Connectee(1).Point:= Le_Point_Suivant;

        -- On indique qui a fournit les informations
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 2
      when 2 =>
        -- On memorise la position
        Section.Point:= Le_Point_Suivant;
        Section.Vecteur.X := -Vecteur.X;
        Section.Vecteur.Y := -Vecteur.Y;

        -- Fournit les informations pour placer les sections connectee

        -- Le numero
        Section_Connectee(1).Section_Id := Section.Connections(1);

        -- La position
        Section_Connectee(1).Vecteur:= Vecteur;
        Section_Connectee(1).Point:= Le_Point_Suivant;

        -- On indique qui a fournit les informations
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est la section null on commence
      -- le placement des section
      when Connection_Null =>
        -- On admet commencer par l'entree 1

        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- Fournit les informations pour placer les sections connectee

        -- Le numero
        Section_Connectee(1).Section_Id := Section.Connections(2);

        -- La position
        Section_Connectee(1).Vecteur:= Vecteur;
        Section_Connectee(1).Point:= Le_Point_Suivant;

        -- On indique qui a fournit les informations
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        -- Le numero
        Section_Connectee(2).Section_Id := Section.Connections(1);

        -- La position
        Section_Connectee(2).Vecteur.X:= -Vecteur.X;
        Section_Connectee(2).Vecteur.Y:= -Vecteur.Y;
        Section_Connectee(2).Point:= Point;

        -- On indique qui a fournit les informations
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;
      
      when others => null;
        
    end case;

    -- On retourne les informations sur les sections a placer
    Suivant(1..2) := Section_Connectee(1..2);

  end Placer;

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
  procedure Paint (Section: in     T_Section_Droite)
  is
    Couleur : P_Couleur.T_Couleur_Rvba
            := P_Couleur.Transforme(Section.Couleur);

  begin
    -- On dessine la section droite selon sa couleur
    Glmaterialfv (Gl_Front, Gl_Ambient, Couleur (1)'Unchecked_Access);
    Glmaterialfv (Gl_Front, Gl_Diffuse, Couleur (1)'Unchecked_Access);
    Segment_Droit (Section.Point, Section.Vecteur,
                   Section.Longueur, Largueur_Section);
  end Paint;

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
  function Positiondansplan(Section         : in T_Section_Droite;
                            Entree          : in T_Connection_Id;
                            Posdanssection  : in T_Position)
    return T_Point
  is
  begin
    -- Selon l'entree et la
    -- position dans la section on
    -- calcul le point dans le plan
    if Entree = 1
    then
      return Point_Suivant_Droit (Section.Point,
                                  Section.Vecteur,
                                  Posdanssection);

    else
      return Point_Suivant_Droit (Section.Point,
                                  Section.Vecteur,
                                  (Section.Longueur - Posdanssection));

    end if;

  end Positiondansplan;

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
  procedure Positiondanssection (Section        : in     T_Section_Droite;
                                 Entree         : in     T_Connection_Id;
                                 Posdanssection : in out T_Position;
                                 Dehors         :    out Boolean)
  is
  begin
    if Posdanssection <= Section.Longueur
    then
      Dehors:= False;

    else
      Posdanssection:= Posdanssection - Section.Longueur;
      Dehors:= True;

    end if;

  end Positiondanssection;

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
  function Positiondepuissortie(Section         : in T_Section_Droite;
                                Entree          : in T_Connection_Id;
                                Posdepuisentree : in T_Position)
    return T_Position
  is
  begin
    return Section.Longueur - Posdepuisentree;

  end Positiondepuissortie;

-- ***********************************************************************
--
-- Primitives d'une section simple courbe
--
-- ***********************************************************************

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
  function New_Section_Courbe(Numero      : in T_Section_Id;
                              Connections : in T_Connections;
                              Angle       : in Float;
                              Rayon       : in Float;
                              Orientation : in T_Orientation )
    return T_Section_Courbe_Ptr
  is
  begin
    -- Cree et initialise l'objet
    return new T_Section_Courbe'
      ( Nbrconnections => 2,
        Numero         => Numero,
        Occupe         => False,
        Connections    => Connections(1..2),
        Angle          => Angle,
        Rayon          => Rayon,
        Orientation    => Orientation,
        Point          => (0.0, 0.0),
        Vecteur        => (0.0, 0.0),
        Couleur        => P_Couleur.Couleur_Segment_Inactif );

  end New_Section_Courbe;

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
  procedure Placer(Section  : in out T_Section_Courbe;
                   Point    : in     T_Point;
                   Vecteur  : in     T_Vecteur;
                   Preced   : in     T_Section_Id;
                   Suivant  :    out T_Section_A_placer)
  is
    -- Information pour placer les
    -- sections connectees
    Section_Connectee: T_Section_A_placer(1..2) :=
       (others=>(0,(0.0,0.0),(0.0,0.0),0));

    -- Le point a l'autre extremite
    -- de la section
    Le_Point_Suivant : T_Point := Point;

    -- Le Vecteur a l'autre extremite
    -- de la section
    Le_Vecteur_Suivant : T_Vecteur := Vecteur;

  begin
    -- Selon la section precedante on determine les sections qui
    -- devront etre placees et on s'arrange pour memoriser
    -- la position de l'entree 1
    case Chercherentree(Section.Connections, Preced)
    is
      -- Si la section precedante est connectee a l'entree 1
      when 1 =>
        -- On calcul le point et le vecteur a l'autre extremite de la section
        Le_Point_Suivant :=
          Point_Suivant_Courbe( Point,
                                Vecteur,
                                Section.Rayon,
                                Section.Orientation,
                                Section.Angle );
        Le_Vecteur_Suivant :=
          Vecteur_Suivant_Courbe( Vecteur,
                                  Section.Orientation,
                                  Section.Angle );

        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id:= Section.Connections(2);
        Section_Connectee(1).Point:= Le_Point_Suivant;
        Section_Connectee(1).Vecteur:= Le_Vecteur_Suivant;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;


      -- Si la section precedante est
      -- connectee a l'entree 2
      when 2 =>
        -- On calcul le point et le vecteur a l'autre extremite de la section
        Le_Point_Suivant :=
          Point_Suivant_Courbe( Point,
                                Vecteur,
                                Section.Rayon,
                                (Inverse(Section.Orientation)),
                                Section.Angle );
        Le_Vecteur_Suivant :=
          Vecteur_Suivant_Courbe( Vecteur,
                                  (Inverse(Section.Orientation)),
                                  Section.Angle );

        -- On memorise la position
        Section.Point:= Le_Point_Suivant;
        Section.Vecteur.X := -Le_Vecteur_Suivant.X;
        Section.Vecteur.Y := -Le_Vecteur_Suivant.Y;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id:= Section.Connections(1);
        Section_Connectee(1).Point:= Le_Point_Suivant;
        Section_Connectee(1).Vecteur:= Le_Vecteur_Suivant;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;


      -- Si la section precedante est la section null on commence
      -- le placement des section
      when Connection_Null =>
        -- On calcul le point et le vecteur a l'autre extremite de la section
        Le_Point_Suivant :=
          Point_Suivant_Courbe( Point,
                                Vecteur,
                                Section.Rayon,
                                Section.Orientation,
                                Section.Angle );
        Le_Vecteur_Suivant :=
          Vecteur_Suivant_Courbe( Vecteur,
                                  Section.Orientation,
                                  Section.Angle );

        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id:= Section.Connections(2);
        Section_Connectee(1).Point:= Le_Point_Suivant;
        Section_Connectee(1).Vecteur:= Le_Vecteur_Suivant;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;
        Section_Connectee(2).Section_Id:= Section.Connections(1);
        Section_Connectee(2).Point:= Point;
        Section_Connectee(2).Vecteur.X:= -Vecteur.X;
        Section_Connectee(2).Vecteur.Y:= -Vecteur.Y;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

      when others =>
        null;

    end case;

    -- On retourne les informations sur les sections a placer
    Suivant(1..2) := Section_Connectee(1..2);

  end Placer;

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
  procedure Paint (Section: in     T_Section_Courbe)
  is
    Couleur : P_Couleur.T_Couleur_Rvba
            := P_Couleur.Transforme(Section.Couleur);

  begin
    -- On dessine la section courbe selon sa couleur
    Glmaterialfv (Gl_Front, Gl_Ambient, Couleur (1)'Unchecked_Access);
    Glmaterialfv (Gl_Front, Gl_Diffuse, Couleur (1)'Unchecked_Access);
    Segment_Courbe( Section.Point,
                    Section.Vecteur,
                    Section.Rayon,
                    Section.Orientation,
                    Largueur_Section,
                    Section.Angle );

  end Paint;

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
  function Positiondansplan(Section         : in T_Section_Courbe;
                            Entree          : in T_Connection_Id;
                            Posdanssection  : in T_Position)
    return T_Point
  is
    -- calcul de la longueur de la section
    Circonferance: Float := 2.0*Section.Rayon*Pi;
    Longueur: Float:= (Circonferance*Section.Angle)/360.0;

  begin
    -- Selon l'entree et la position dans la section on
    -- calcul le point dans le plan
    if Entree = 1
    then
      return Point_Suivant_Courbe(Section.Point,
                                  Section.Vecteur,
                                  Section.Rayon,
                                  Section.Orientation,
                                  ((Posdanssection * 360.0) / Circonferance));

    else
      return Point_Suivant_Courbe(Section.Point,
                                  Section.Vecteur,
                                  Section.Rayon,
                                  Section.Orientation,
                                  (((Longueur - Posdanssection) * 360.0) /
                                    Circonferance) );

    end if;

  end Positiondansplan;

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
  procedure Positiondanssection (Section        : in     T_Section_Courbe;
                                 Entree         : in     T_Connection_Id;
                                 Posdanssection : in out T_Position;
                                 Dehors         :    out Boolean)
  is
    -- calcul de la longueur de la section
    Longueur : Float := (2.0*Section.Rayon*Pi*Section.Angle)/360.0;

  begin
    if Posdanssection <= Longueur
    then
      Dehors:= False;

    else
      Posdanssection := Posdanssection - Longueur;
      Dehors:= True;

    end if;

  end Positiondanssection;

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
  function Positiondepuissortie(Section         : in T_Section_Courbe;
                                Entree          : in T_Connection_Id;
                                Posdepuisentree : in T_Position)
    return T_Position
  is
  begin
    -- calcul de la longueur de la section a la quelle on retranche
    -- la position depuis l'entree
    return (2.0*Section.Rayon*Pi*Section.Angle/360.0) - Posdepuisentree;

  end Positiondepuissortie;

-- ***********************************************************************
--
-- Primitives d'une section fin de voie (heurtoir)
--
-- ***********************************************************************

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
  function New_Section_Fin_De_Voie( Numero      : in T_Section_Id;
                                    Connections : in T_Connections;
                                    Longueur    : in Float)
    return T_Section_Fin_De_Voie_Ptr
  is
  begin
    -- Cree et initialise l'objet
    return new T_Section_Fin_De_Voie'(Nbrconnections  => 1,
                                      Numero          => Numero,
                                      Occupe          => False,
                                      Connections     => Connections(1..1),
                                      Longueur        => Longueur,
                                      Point           => (0.0, 0.0),
                                      Vecteur         => (0.0, 0.0),
                                      Couleur         => P_Couleur.Rouge);

  end New_Section_Fin_De_Voie;

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
  function Prendresortie( Section : in T_Section_Fin_De_Voie;
                          Entree  : in T_Connection_Id)
    return T_Connection_Id
  is
  begin
    -- On ne peut pas se trouver sur une section fin de voie donc on ne
    -- peux pas prendre sa sortie
    raise Collision;
    return 0;

  end Prendresortie;

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
  procedure Placer (Section : in out T_Section_Fin_De_Voie;
                    Point   : in     T_Point;
                    Vecteur : in     T_Vecteur;
                    Preced  : in     T_Section_Id;
                    Suivant :    out T_Section_A_placer)
  is
    -- Information pour placer les sections connectees
    Section_Connectee : T_Section_A_placer(1..1)
                      := (others=>(0,(0.0,0.0),(0.0,0.0),0));

    -- Le point a l'autre extremite de la section
    Le_Point_Suivant : T_Point := Point;

  begin
    -- On calcul le point a l'autre
    -- extremite de la section
    Le_Point_Suivant := Point_Suivant_Droit(Point, Vecteur,
                                            Section.Longueur);

    -- Selon la section precedante on determine les sections qui
    -- devront etre placees et on s'arrange pour memoriser
    -- la position de l'entree oppose a l'entree 1

    -- Si la section precedante est la section null on commence
    -- le placement des section
    if Preced = Section_Null
    then
      -- On memorise la position
      Section.Point:= Point;
      Section.Vecteur:= Vecteur;

      -- Fournit les informations pour placer les sections connectee
      Section_Connectee(1).Section_Id := Section.Connections(1);
      Section_Connectee(1).Vecteur := Vecteur;
      Section_Connectee(1).Point := Le_Point_Suivant;
      Section_Connectee(1).Section_Id_Preced:= Section.Numero;

      -- On retourne les informations sur les sections a placer
      Suivant(1..1):= Section_Connectee(1..1);

    else
      -- Si la section precedante est connectee a l'entree 1

      -- On memorise la position
      Section.Point:=Le_Point_Suivant;
      Section.Vecteur.X:= -Vecteur.X;
      Section.Vecteur.Y:= -Vecteur.Y;

    end if;

  end Placer;

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
  procedure Paint (Section: in     T_Section_Fin_De_Voie)
  is
    Couleur: P_Couleur.T_Couleur_Rvba
           := P_Couleur.Transforme(Section.Couleur);

  begin
    -- On dessine la section fin de voie selon sa couleur
    Glmaterialfv (Gl_Front, Gl_Ambient, Couleur (1)'Unchecked_Access);
    Glmaterialfv (Gl_Front, Gl_Diffuse, Couleur (1)'Unchecked_Access);

    Segment_Droit (Section.Point, Section.Vecteur,
                   Section.Longueur, Largueur_Section);

  end Paint;

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
  function Positiondansplan(Section        : in T_Section_Fin_De_Voie;
                            Entree         : in T_Connection_Id;
                            Posdanssection : in T_Position)
    return T_Point
  is
  begin
    -- Un train ne peut pas entrer sur une section fin de voie
    -- on le maintient donc au debut
    return Point_Suivant_Droit(Section.Point,
                               Section.Vecteur,
                               Section.Longueur);

  end Positiondansplan;

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
  procedure Positiondanssection
    (Section        : in     T_Section_Fin_De_Voie;
     Entree         : in     T_Connection_Id;
     Posdanssection : in out T_Position;
     Dehors         :    out Boolean)
  is
  begin
    -- Un train ne peut pas se touver sur une section fin de voie
    raise Collision;

  end Positiondanssection;

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
  function Positiondepuissortie(Section         : in T_Section_Fin_De_Voie;
                                Entree          : in T_Connection_Id;
                                Posdepuisentree : in T_Position)
    return T_Position
  is
  begin
    -- On ne peut pas se trouver sur une section fin de voie donc on ne
    -- peux pas obtenir la position depuis la sortie
    raise Collision;
    return 0.0;

  end Positiondepuissortie;

-- ***********************************************************************
--
-- Primitives d'une section croisement
--
-- ***********************************************************************---------------

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
  function New_Section_Croix( Numero      : in T_Section_Id;
                              Connections : in T_Connections;
                              Angle       : in Float;
                              Longueur    : in Float)
    return T_Section_Croix_Ptr
  is
  begin
    -- Cree et initialise l'objet
    return new T_Section_Croix'
      ( Nbrconnections  => 4,
        Numero          => Numero,
        Occupe          => False,
        Connections     => Connections(1..4),
        Longueur        => Longueur,
        Angle           => Angle,
        Point           => (0.0, 0.0),
        Vecteur         => (0.0, 0.0),
        Couleur         => P_Couleur.Couleur_Segment_Inactif );

  end New_Section_Croix;

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
  function Prendresortie( Section : in T_Section_Croix;
                          Entree  : in T_Connection_Id)
    return T_Connection_Id
  is
  begin
    if Entree = 1
    then
      return 2;

    elsif Entree = 2
    then
      return 1;

    elsif Entree = 3
    then
      return 4;

    else
      return 3;

    end if;

  end Prendresortie;

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
  procedure Placer( Section : in out T_Section_Croix;
                    Point   : in     T_Point;
                    Vecteur : in     T_Vecteur;
                    Preced  : in     T_Section_Id;
                    Suivant :    out T_Section_A_placer )
  is
    -- Information pour placer les sections connectees
    Section_Connectee: T_Section_A_placer(1..4):=
       (others=>(0,(0.0,0.0),(0.0,0.0),0));

    -- Variables pour memeoriser les points et les vecteur de
    -- autres extremites
    Le_Point_Suivant_En_Face : T_Point;

    -- Le point et le vecteur a l'autre extremite a cote
    Le_Point_Suivant_En_Face_Decale: T_Point;
    Le_Vecteur_Suivant_A_cote: T_Vecteur;

    -- Le point a l'autre extremite en face
    Le_Point_Suivant_A_cote: T_Point;

  begin
    -- On calcul le point a l'autre extremite en face
    Le_Point_Suivant_En_Face := Point_Suivant_Droit(Point, Vecteur,
                                                    Section.Longueur);

    -- Selon la section precedante on determine les sections qui
    -- devront etre placees et on s'arrange pour memoriser
    -- la position de l'entree 1
    case Chercherentree(Section.Connections, Preced)
    is
      -- Si la section precedante est connectee a l'entree 1
      when 1 =>
        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- On calcul le point et le vecteur a l'autre extremite a cote
        Le_Point_Suivant_A_cote := Point_Suivant_Decale(Point, Vecteur,
                                                        Section.Longueur,
                                                        Droite,
                                                        Section.Angle);

        Le_Vecteur_Suivant_A_cote:= Vecteur_Suivant_Decale(Vecteur,
                                                           Droite,
                                                           Section.Angle);

        -- On calcul le point et le vecteur a l'autre extremite
        -- en face a cote
        Le_Point_Suivant_En_Face_Decale :=
          Point_Suivant_Droit(Le_Point_Suivant_A_cote,
                              Le_Vecteur_Suivant_A_cote,
                              Section.Longueur);

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(2);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(3);
        Section_Connectee(2).Point := Le_Point_Suivant_A_cote;
        Section_Connectee(2).Vecteur.X := -Le_Vecteur_Suivant_A_cote.X;
        Section_Connectee(2).Vecteur.Y := -Le_Vecteur_Suivant_A_cote.Y;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(4);
        Section_Connectee(3).Point := Le_Point_Suivant_En_Face_Decale;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_A_cote;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 2
      when 2 =>
        -- On memorise la position
        Section.Point:= Le_Point_Suivant_En_Face;
        Section.Vecteur.X:= -Vecteur.X;
        Section.Vecteur.Y:= -Vecteur.Y;

        -- On calcul les autres points et vecteur
        Le_Point_Suivant_A_cote := Point_Suivant_Decale(Point, Vecteur,
                                                        Section.Longueur,
                                                        Droite,
                                                        Section.Angle);


        Le_Vecteur_Suivant_A_cote := Vecteur_Suivant_Decale(Vecteur, Droite,
                                                            Section.Angle);

        Le_Point_Suivant_En_Face_Decale :=
          Point_Suivant_Droit(Le_Point_Suivant_A_cote,
                              Le_Vecteur_Suivant_A_cote,
                              Section.Longueur);


        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(1);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(4);
        Section_Connectee(2).Point := Le_Point_Suivant_A_cote;
        Section_Connectee(2).Vecteur.X := -Le_Vecteur_Suivant_A_cote.X;
        Section_Connectee(2).Vecteur.Y := -Le_Vecteur_Suivant_A_cote.Y;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(3);
        Section_Connectee(3).Point := Le_Point_Suivant_En_Face_Decale;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_A_cote;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 3
      when 3 =>
        -- On calcul les autres points et vecteurs
        Le_Point_Suivant_A_cote := Point_Suivant_Decale(Point, Vecteur,
                                                        Section.Longueur,
                                                        Gauche,
                                                        Section.Angle);



        Le_Vecteur_Suivant_A_cote := Vecteur_Suivant_Decale(Vecteur, Gauche,
                                                            Section.Angle);

        Le_Point_Suivant_En_Face_Decale :=
          Point_Suivant_Droit(Le_Point_Suivant_A_cote,
                              Le_Vecteur_Suivant_A_cote,
                              Section.Longueur);

        -- On memorise la position
        Section.Point:= Le_Point_Suivant_A_cote;
        Section.Vecteur:= Le_Vecteur_Suivant_A_cote;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(4);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(1);
        Section_Connectee(2).Point := Le_Point_Suivant_A_cote;
        Section_Connectee(2).Vecteur.X := -Le_Vecteur_Suivant_A_cote.X;
        Section_Connectee(2).Vecteur.Y := -Le_Vecteur_Suivant_A_cote.Y;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(2);
        Section_Connectee(3).Point := Le_Point_Suivant_En_Face_Decale;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_A_cote;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 4
      when 4 =>
        -- On calcul les autres points et vecteurs
        Le_Point_Suivant_A_cote := Point_Suivant_Decale(Point, Vecteur,
                                                        Section.Longueur,
                                                        Gauche,
                                                        Section.Angle);


        Le_Vecteur_Suivant_A_cote := Vecteur_Suivant_Decale(Vecteur,
                                                            Gauche,
                                                            Section.Angle);

        Le_Point_Suivant_En_Face_Decale :=
          Point_Suivant_Droit(Le_Point_Suivant_A_cote,
                              Le_Vecteur_Suivant_A_cote,
                              Section.Longueur);

        -- On memorise la position
        Section.Point:= Le_Point_Suivant_En_Face_Decale;
        Section.Vecteur.X:= -Le_Vecteur_Suivant_A_cote.X;
        Section.Vecteur.Y:= -Le_Vecteur_Suivant_A_cote.Y;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(3);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(2);
        Section_Connectee(2).Point := Le_Point_Suivant_A_cote;
        Section_Connectee(2).Vecteur.X := -Le_Vecteur_Suivant_A_cote.X;
        Section_Connectee(2).Vecteur.Y := -Le_Vecteur_Suivant_A_cote.Y;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(1);
        Section_Connectee(3).Point := Le_Point_Suivant_En_Face_Decale;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_A_cote;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est la section null on commence
      -- le placement des section
      when Connection_Null =>
        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- On calcul les autres points et vecteurs
        Le_Point_Suivant_A_cote := Point_Suivant_Decale(Point, Vecteur,
                                                        Section.Longueur,
                                                        Droite,
                                                        Section.Angle);

        Le_Vecteur_Suivant_A_cote:= Vecteur_Suivant_Decale(Vecteur,
                                                          Droite,
                                                          Section.Angle);

        Le_Point_Suivant_En_Face_Decale :=
          Point_Suivant_Droit(Le_Point_Suivant_A_cote,
                              Le_Vecteur_Suivant_A_cote,
                              Section.Longueur);

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(2);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(3);
        Section_Connectee(2).Point := Le_Point_Suivant_A_cote;
        Section_Connectee(2).Vecteur.X := -Le_Vecteur_Suivant_A_cote.X;
        Section_Connectee(2).Vecteur.Y := -Le_Vecteur_Suivant_A_cote.Y;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(4);
        Section_Connectee(3).Point := Le_Point_Suivant_En_Face_Decale;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_A_cote;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

        Section_Connectee(4).Section_Id := Section.Connections(1);
        Section_Connectee(4).Point := Point;
        Section_Connectee(4).Vecteur.X := -Vecteur.X;
        Section_Connectee(4).Vecteur.Y := -Vecteur.Y;
        Section_Connectee(4).Section_Id_Preced:= Section.Numero;

      when others => null;

    end case;
    -- On retourne les informations sur les sections a placer
    Suivant(1..4) := Section_Connectee(1..4);

  end Placer;

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
  procedure Paint (Section: in     T_Section_Croix)
  is
    -- On a memorise la position de la jambe gauche du X alors on
    -- cherche celle de la jambe droite
    Le_Point_Suivant_A_cote: T_Point;
    Le_Vecteur_Suivant_A_cote: T_Vecteur;
    Couleur : P_Couleur.T_Couleur_Rvba
            := P_Couleur.Transforme(Section.Couleur);

  begin
    -- On dessine les deux sections droite du croisement selon
    -- la couleur de la section
    Glmaterialfv (Gl_Front, Gl_Ambient, Couleur (1)'Unchecked_Access);
    Glmaterialfv (Gl_Front, Gl_Diffuse, Couleur (1)'Unchecked_Access);
    Segment_Droit (Section.Point, Section.Vecteur,
                   Section.Longueur, Largueur_Section);
    
    Le_Point_Suivant_A_cote :=
      Point_Suivant_Decale(Section.Point, Section.Vecteur,
                           Section.Longueur, Droite,
                           Section.Angle);

    Le_Vecteur_Suivant_A_cote :=
      Vecteur_Suivant_Decale(Section.Vecteur, Droite,
                             Section.Angle);

    Segment_Droit (Le_Point_Suivant_A_cote, Le_Vecteur_Suivant_A_cote,
                   Section.Longueur, Largueur_Section);

  end Paint;

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
  function Positiondansplan(Section         : in T_Section_Croix;
                            Entree          : in T_Connection_Id;
                            Posdanssection  : in T_Position)
    return T_Point
  is
  begin
    -- Selon l'entree et la position dans la section on
    -- calcul le point dans le plan
    case Entree is
      when 1 =>
        return Point_Suivant_Droit( Section.Point,
                                    Section.Vecteur,
                                    Posdanssection);
      when 2 =>
        return Point_Suivant_Droit( Section.Point,
                                    Section.Vecteur,
                                    (Section.Longueur - Posdanssection));
      when 3 =>
        return Point_Suivant_Droit(
          Point_Suivant_Decale( Section.Point,
                                Section.Vecteur,
                                Section.Longueur,
                                Droite,
                                Section.Angle),
          Vecteur_Suivant_Decale( Section.Vecteur,
                                  Droite,
                                  Section.Angle),
          Posdanssection);

      when 4 =>
        return Point_Suivant_Droit(
          Point_Suivant_Decale( Section.Point,
                                Section.Vecteur,
                                Section.Longueur,
                                Droite,
                                Section.Angle),
          Vecteur_Suivant_Decale( Section.Vecteur,
                                  Droite,
                                  Section.Angle),
          (Section.Longueur - Posdanssection));

      when others =>  return (0.0,0.0); -- null;

    end case;

  end Positiondansplan;

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
  procedure Positiondanssection (Section        : in     T_Section_Croix;
                                 Entree         : in     T_Connection_Id;
                                 Posdanssection : in out T_Position;
                                 Dehors         :    out Boolean)
  is
  begin
    if Posdanssection <= Section.Longueur
    then
      Dehors:= False;

    else
      Posdanssection := Posdanssection - Section.Longueur;
      Dehors:= True;

    end if;

  end Positiondanssection;

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
  function Positiondepuissortie(Section         : in T_Section_Croix;
                                Entree          : in T_Connection_Id;
                                Posdepuisentree : in T_Position)
    return T_Position
  is
  begin
     return Section.Longueur - Posdepuisentree;

  end Positiondepuissortie;

-- ***********************************************************************
--
-- Primitives d'un aiguillage simple
--
-- ***********************************************************************

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
  procedure Diriger(Section         : in out T_Aiguillage_Simple;
                    Direction       : in     T_Direction;
                    Sousaiguillage  : in     T_Aiguillage_Type)
  is
  begin
    -- On dirige l'aiguille
    if Direction = Devie
    then
      Section.Etat := Etat_Devie;

    else
      Section.Etat := Etat_Droit;

    end if;

  end Diriger;

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
  -- Retour  :             => Indique la  direction de
  --                           aiguillage selon son etat actuel
  --
  -----------------------------------------------------------------------
  function Direction( Section         : in T_Aiguillage_Simple;
                      Sousaiguillage  : in T_Aiguillage_Type)
    return T_Direction
  is
  begin
    -- Selon l'etat de l'aiguillage on indique la direction
    if Section.Etat = Etat_Devie
    then
      return Devie;

    else
      return Tout_Droit;

    end if;

  end Direction;

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
  function Prendresortie( Section : in T_Aiguillage_Simple;
                          Entree  : in T_Connection_Id)
    return T_Connection_Id
  is
  begin
    -- Si on est rentrer du cote de l'aiguille.
    if Entree = 1
    then
      -- La sortie depend de l'etat de l'aiguille.
      if Section.Etat = Etat_Droit
      then
        return 2;

      else
        return 3;

      end if;

    else
      -- La sortie est independante de l'etat de l'aiguille.
      return 1;

    end if;

  end Prendresortie;

-- ***********************************************************************
--
-- Primitives d'un aiguillage simple droit
--
-- ***********************************************************************

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
  function New_Aiguillage_Simple_Droit( Numero      : in T_Section_Id;
                                        Connections : in T_Connections;
                                        Angle       : in Float;
                                        Rayon       : in Float;
                                        Orientation : in T_Orientation;
                                        Longueur    : in Float)
    return T_Aiguillage_Simple_Droit_Ptr
  is
  begin
    -- Cree et initialise l'objet
    return new T_Aiguillage_Simple_Droit'
      ( Nbrconnections  => 3,
        Numero          => Numero,
        Occupe          => False,
        Connections     => Connections(1..3),
        Longueur        => Longueur,
        Angle           => Angle,
        Rayon           => Rayon,
        Orientation     => Orientation,
        Etat            => Etat_Droit,
        Point           => (0.0, 0.0),
        Vecteur         => (0.0, 0.0),
        Couleur         => P_Couleur.Couleur_Segment_Inactif );

  end New_Aiguillage_Simple_Droit;

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
  procedure Placer( Section : in out T_Aiguillage_Simple_Droit;
                    Point   : in     T_Point;
                    Vecteur : in     T_Vecteur;
                    Preced  : in     T_Section_Id;
                    Suivant :    out T_Section_A_placer )
  is
    -- Information pour placer les sections connectees
    Section_Connectee : T_Section_A_placer(1..3)
                      := (others=>(0,(0.0,0.0),(0.0,0.0),0));

    -- Variables pour memeoriser les points et les vecteur de
    -- autres extremites
    Le_Point_Suivant_En_Face : T_Point;
    Le_Vecteur_Suivant_En_Face : T_Vecteur;
    Le_Point_Suivant_De_Cote: T_Point;
    Le_Vecteur_Suivant_De_Cote: T_Vecteur;

  begin
    -- Selon la section precedante on determine les sections qui
    -- devront etre placees et on s'arrange pour memoriser
    -- la position de l'entree 1
    case Chercherentree(Section.Connections, Preced)
    is
      -- Si la section precedante est connectee a l'entree 1
      when 1 =>
        -- On calcul les autres points et vecteur
        Le_Point_Suivant_En_Face := Point_Suivant_Droit(Point, Vecteur,
                                                        Section.Longueur);

        Le_Point_Suivant_De_Cote:= Point_Suivant_Courbe(Point, Vecteur,
                                                        Section.Rayon,
                                                        Section.Orientation,
                                                        Section.Angle);

        Le_Vecteur_Suivant_De_Cote:= Vecteur_Suivant_Courbe(Vecteur,
                                                      Section.Orientation,
                                                      Section.Angle);

        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(2);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(3);
        Section_Connectee(2).Point := Le_Point_Suivant_De_Cote;
        Section_Connectee(2).Vecteur := Le_Vecteur_Suivant_De_Cote;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 2
      when 2 =>
        -- On calcul les autres points et vecteurs
        Le_Point_Suivant_En_Face := Point_Suivant_Droit(Point, Vecteur,
                                                       Section.Longueur);

        Le_Vecteur_Suivant_En_Face.X := -Vecteur.X;
        Le_Vecteur_Suivant_En_Face.Y := -Vecteur.Y;

        Le_Point_Suivant_De_Cote :=
          Point_Suivant_Courbe(Le_Point_Suivant_En_Face,
                               Le_Vecteur_Suivant_En_Face,
                               Section.Rayon,
                               Section.Orientation,
                               Section.Angle);

        Le_Vecteur_Suivant_De_Cote :=
          Vecteur_Suivant_Courbe(Le_Vecteur_Suivant_En_Face,
                                 Section.Orientation,
                                 Section.Angle);

        -- On memorise la position
        Section.Point:= Le_Point_Suivant_En_Face;
        Section.Vecteur:= Le_Vecteur_Suivant_En_Face;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(1);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(3);
        Section_Connectee(2).Point := Le_Point_Suivant_De_Cote;
        Section_Connectee(2).Vecteur := Le_Vecteur_Suivant_De_Cote;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 3
      when 3 =>
        -- On calcul les autres points et vecteurs
        Le_Point_Suivant_En_Face :=
          Point_Suivant_Courbe(Point,
                               Vecteur,
                               Section.Rayon,
                               (Inverse(Section.Orientation)),
                               Section.Angle);

        Le_Vecteur_Suivant_En_Face :=
          Vecteur_Suivant_Courbe(Vecteur,
                                 (Inverse (Section.Orientation)),
                                 Section.Angle);

        Le_Vecteur_Suivant_De_Cote.X := -Le_Vecteur_Suivant_En_Face.X;
        Le_Vecteur_Suivant_De_Cote.Y := -Le_Vecteur_Suivant_En_Face.Y;

        Le_Point_Suivant_De_Cote :=
          Point_Suivant_Droit(Le_Point_Suivant_En_Face,
                              Le_Vecteur_Suivant_De_Cote,
                              Section.Longueur);

        -- On memorise la position
        Section.Point:= Le_Point_Suivant_En_Face;
        Section.Vecteur:= Le_Vecteur_Suivant_De_Cote;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(1);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Le_Vecteur_Suivant_En_Face;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(2);
        Section_Connectee(2).Point := Le_Point_Suivant_De_Cote;
        Section_Connectee(2).Vecteur := Le_Vecteur_Suivant_De_Cote;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est la section null on commence
      -- le placement des section
      when Connection_Null =>
        -- On calcul les autres points et vecteurs
        Le_Point_Suivant_En_Face := Point_Suivant_Droit(Point, Vecteur,
                                                        Section.Longueur);

        Le_Point_Suivant_De_Cote := Point_Suivant_Courbe(Point, Vecteur,
                                                         Section.Rayon,
                                                         Section.Orientation,
                                                         Section.Angle);

        Le_Vecteur_Suivant_De_Cote :=
          Vecteur_Suivant_Courbe(Vecteur,
                                 Section.Orientation,
                                 Section.Angle);

        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(2);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(3);
        Section_Connectee(2).Point := Le_Point_Suivant_De_Cote;
        Section_Connectee(2).Vecteur := Le_Vecteur_Suivant_De_Cote;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(1);
        Section_Connectee(3).Point := Point;
        Section_Connectee(3).Vecteur.X := -Vecteur.X;
        Section_Connectee(3).Vecteur.Y := -Vecteur.Y;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      when others => null;

    end case;
    -- On retourne les informations sur les sections a placer
    Suivant(1..3) := Section_Connectee(1..3);

  end Placer;

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
  procedure Paint (Section: in     T_Aiguillage_Simple_Droit)
  is
    Couleur : P_Couleur.T_Couleur_Rvba
            := P_Couleur.Transforme(Section.Couleur);

    Couleur_Segment_Actif : P_Couleur.T_Couleur_Rvba
                          := P_Couleur.Transforme
                            (P_Couleur.Couleur_Segment_Actif);

  begin
    -- Selon l'etat on met en evidance le chemin actif de l'aiguillage
    if Section.Etat = Etat_Devie
    then
      Glmaterialfv (Gl_Front, Gl_Ambient,
                    Couleur (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
                    Couleur (1)'Unchecked_Access);

      Segment_Droit ( Section.Point, Section.Vecteur,
                      Section.Longueur, Largueur_Section);

      Glmaterialfv (Gl_Front, Gl_Ambient,
                    Couleur_Segment_Actif (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
                    Couleur_Segment_Actif (1)'Unchecked_Access);

      -- Dessine la section active au-dessus de la section inactive
      glTranslatef (0.0,0.0,0.5);
      
      Segment_Courbe( Section.Point, Section.Vecteur,
                      Section.Rayon, Section.Orientation,
                      Largueur_Section,
                      Section.Angle);

      glTranslatef (0.0,0.0,-0.5);

    else
      Glmaterialfv (Gl_Front, Gl_Ambient,
                    Couleur (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
                    Couleur (1)'Unchecked_Access);


      Segment_Courbe( Section.Point, Section.Vecteur,
                      Section.Rayon, Section.Orientation,
                      Largueur_Section,
                      Section.Angle);

      Glmaterialfv (Gl_Front, Gl_Ambient,
                    Couleur_Segment_Actif (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
                    Couleur_Segment_Actif (1)'Unchecked_Access);

      -- Dessine la section active au-dessus de la section inactive
      glTranslatef (0.0,0.0,0.5);
      
      Segment_Droit ( Section.Point, Section.Vecteur,
                      Section.Longueur, Largueur_Section);

      glTranslatef (0.0,0.0,-0.5);

    end if;

  end Paint;

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
  function Positiondansplan(Section         : in T_Aiguillage_Simple_Droit;
                            Entree          : in T_Connection_Id;
                            Posdanssection  : in T_Position)
    return T_Point
  is
    -- calcul de la longueur de la section courbe
    Circonferance: Float := 2.0*Section.Rayon*Pi;
    Longueur: Float:= (Circonferance*Section.Angle)/360.0;

  begin
    -- Selon l'entree, l'etat et la position dans la section on
    -- calcul le point dans le plan
    case Entree
    is
      when 1 =>
        if Section.Etat = Etat_Droit
        then
          return Point_Suivant_Droit( Section.Point,
                                      Section.Vecteur,
                                      Posdanssection );

        else
          return Point_Suivant_Courbe(Section.Point,
                                      Section.Vecteur,
                                      Section.Rayon,
                                      Section.Orientation,
                                      ((Posdanssection*360.0)/
                                      Circonferance));

        end if;

      when 2 =>
        return Point_Suivant_Droit( Section.Point,
                                    Section.Vecteur,
                                    (Section.Longueur - Posdanssection) );

      when 3 =>
        return Point_Suivant_Courbe(Section.Point,
                                    Section.Vecteur,
                                    Section.Rayon,
                                    Section.Orientation,
                                    (((Longueur-Posdanssection)*360.0)/
                                    Circonferance));

      when others => return (0.0,0.0); -- null;

    end case;

  end Positiondansplan;

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
  procedure Positiondanssection
    (Section        : in     T_Aiguillage_Simple_Droit;
     Entree         : in     T_Connection_Id;
     Posdanssection : in out T_Position;
     Dehors         :    out Boolean)
  is
    -- calcul de la longueur de la section courbe
    Longueur: Float:= (2.0*Section.Rayon*Pi*Section.Angle)/360.0;

  begin
    case Entree
    is
      when 1 =>
        if Section.Etat = Etat_Droit
        then
          if Posdanssection <= Section.Longueur
          then
             Dehors:= False;

          else
             Posdanssection:= Posdanssection - Section.Longueur;
             Dehors:= True;

          end if;

        else
          if Posdanssection <= Longueur
          then
             Dehors:= False;

          else
             Posdanssection:= Posdanssection - Longueur;
             Dehors:= True;

          end if;

        end if;

      when 2 =>
         if Posdanssection <= Section.Longueur
         then
           Dehors:= False;

         else
           Posdanssection:= Posdanssection - Section.Longueur;
           Dehors:= True;

         end if;

      when 3 =>
         if Posdanssection <= Longueur
         then
           Dehors:= False;

         else
           Posdanssection:= Posdanssection - Longueur;
           Dehors:= True;

         end if;

      when others => null;

    end case;

  end Positiondanssection;

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
  function Positiondepuissortie
    (Section          : in T_Aiguillage_Simple_Droit;
     Entree           : in T_Connection_Id;
     Posdepuisentree  : in T_Position)
    return T_Position
  is
  begin
    -- Selon l'etat, la longueur, la position dans la section,
    -- et l'entree on calcul la position depuis la sortie
    case Entree
    is
      when 1 =>
        if Section.Etat = Etat_Droit
        then
           return Section.Longueur - Posdepuisentree;

        else
           return (2.0*Section.Rayon*Pi*Section.Angle/360.0) -
             Posdepuisentree;

        end if;

      when 2 =>
        return Section.Longueur - Posdepuisentree;

      when 3 =>
        return (2.0*Section.Rayon*Pi*Section.Angle/360.0) -
          Posdepuisentree;

      when others => return 0.0; -- null;

    end case;

  end Positiondepuissortie;

-- ***********************************************************************
--
-- Primitives d'un aiguillage simple courbe
--
-- ***********************************************************************

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
  function New_Aiguillage_Simple_Courbe
    (Numero       : in T_Section_Id;
     Connections  : in T_Connections;
     Angle        : in Float;
     Rayon        : in Float;
     Orientation  : in T_Orientation;
     Decalage     : in Float)
    return T_Aiguillage_Simple_Courbe_Ptr
  is
  begin
    -- Cree et initialise l'objet
    return new T_Aiguillage_Simple_Courbe'
      ( Nbrconnections => 3,
        Numero         => Numero,
        Occupe         => False,
        Connections    => Connections(1..3),
        Decalage       => Decalage,
        Angle          => Angle,
        Rayon          => Rayon,
        Orientation    => Orientation,
        Etat           => Etat_Droit,
        Point          => (0.0, 0.0),
        Vecteur        => (0.0, 0.0),
        Couleur        => P_Couleur.Couleur_Segment_Inactif );

  end New_Aiguillage_Simple_Courbe;

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
  procedure Placer( Section : in out T_Aiguillage_Simple_Courbe;
                    Point   : in     T_Point;
                    Vecteur : in     T_Vecteur;
                    Preced  : in     T_Section_Id;
                    Suivant :    out T_Section_A_placer )
  is
    -- Information pour placer les sections connectees
    Section_Connectee : T_Section_A_placer(1..3)
                      := (others=>(0,(0.0,0.0),(0.0,0.0),0));

    -- Variables pour memeoriser les points et les vecteur
    -- de autres extremites
    Le_Point_Decale : T_Point;
    Le_Point_Suivant_En_Face : T_Point;
    Le_Vecteur_Suivant_En_Face : T_Vecteur;
    Le_Point_Suivant_De_Cote: T_Point;
    Le_Vecteur_Suivant_De_Cote: T_Vecteur;

  begin
    -- Selon la section precedante on determine les sections qui
    -- devront etre placees et on s'arrange pour memoriser
    -- la position de l'entree 1
    case Chercherentree(Section.Connections, Preced)
    is
      -- Si la section precedante est connectee a l'entree 1
      when 1 =>
        -- On calcul les autres points et vecteurs
        Le_Point_Decale.X := Point.X + Section.Decalage *
                             Cos(Arctan(Vecteur.Y,Vecteur.X,360.0), 360.0);

        Le_Point_Decale.Y := Point.Y + Section.Decalage *
                             Sin(Arctan(Vecteur.Y,Vecteur.X,360.0), 360.0);

        Le_Point_Suivant_En_Face:=  Point_Suivant_Courbe(Le_Point_Decale,
                                                         Vecteur,
                                                         Section.Rayon,
                                                         Section.Orientation,
                                                         Section.Angle);

        Le_Point_Suivant_De_Cote := Point_Suivant_Courbe(Point, Vecteur,
                                                         Section.Rayon,
                                                         Section.Orientation,
                                                         Section.Angle);

        Le_Vecteur_Suivant_De_Cote :=
          Vecteur_Suivant_Courbe(Vecteur,
                                 Section.Orientation,
                                 Section.Angle);

        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(3);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Le_Vecteur_Suivant_De_Cote;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(2);
        Section_Connectee(2).Point := Le_Point_Suivant_De_Cote;
        Section_Connectee(2).Vecteur := Le_Vecteur_Suivant_De_Cote;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 2
      when 2 =>
        -- On calcul les autres points et vecteurs
        Le_Point_Suivant_En_Face :=
          Point_Suivant_Courbe(Point, Vecteur,
                               Section.Rayon,
                               (Inverse(Section.Orientation)),
                               Section.Angle);

        Le_Vecteur_Suivant_En_Face :=
          Vecteur_Suivant_Courbe(Vecteur,
                                 (Inverse (Section.Orientation)),
                                 Section.Angle);

        Le_Vecteur_Suivant_En_Face.X := -Le_Vecteur_Suivant_En_Face.X;
        Le_Vecteur_Suivant_En_Face.Y := -Le_Vecteur_Suivant_En_Face.Y;

        Le_Point_Decale.X := Le_Point_Suivant_En_Face.X + Section.Decalage *
                             Cos(Arctan(Le_Vecteur_Suivant_En_Face.Y,
                             Le_Vecteur_Suivant_En_Face.X,360.0), 360.0);

        Le_Point_Decale.Y := Le_Point_Suivant_En_Face.Y + Section.Decalage *
                             Sin(Arctan(Le_Vecteur_Suivant_En_Face.Y,
                             Le_Vecteur_Suivant_En_Face.X,360.0), 360.0);

        Le_Point_Suivant_De_Cote :=
          Point_Suivant_Courbe(Le_Point_Decale,
                               Le_Vecteur_Suivant_En_Face,
                               Section.Rayon,
                               Section.Orientation,
                               Section.Angle);
        -- On memorise la position
        Section.Point:= Le_Point_Suivant_En_Face;
        Section.Vecteur:= Le_Vecteur_Suivant_En_Face;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(1);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur.X := -Le_Vecteur_Suivant_En_Face.X;
        Section_Connectee(1).Vecteur.Y := -Le_Vecteur_Suivant_En_Face.Y;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(3);
        Section_Connectee(2).Point := Le_Point_Suivant_De_Cote;
        Section_Connectee(2).Vecteur.X := -Vecteur.X;
        Section_Connectee(2).Vecteur.Y := -Vecteur.Y;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 3
      when 3 =>
        -- On calcul les autres points et vecteurs
        Le_Point_Decale := Point_Suivant_Courbe(Point, Vecteur,
                                                Section.Rayon,
                                                (Inverse(Section.Orientation)),
                                                Section.Angle);

        Le_Vecteur_Suivant_En_Face :=
          Vecteur_Suivant_Courbe(Vecteur,
                                 (Inverse (Section.Orientation)),
                                 Section.Angle);

        Le_Point_Suivant_En_Face.X := Le_Point_Decale.X + Section.Decalage *
                                      Cos(Arctan(Le_Vecteur_Suivant_En_Face.Y,
                                      Le_Vecteur_Suivant_En_Face.X,360.0),
                                      360.0);

        Le_Point_Suivant_En_Face.Y := Le_Point_Decale.Y + Section.Decalage *
                                      Sin(Arctan(Le_Vecteur_Suivant_En_Face.Y,
                                      Le_Vecteur_Suivant_En_Face.X,360.0),
                                      360.0);

        Le_Vecteur_Suivant_En_Face.X := -Le_Vecteur_Suivant_En_Face.X;
        Le_Vecteur_Suivant_En_Face.Y := -Le_Vecteur_Suivant_En_Face.Y;

        Le_Point_Suivant_De_Cote :=
          Point_Suivant_Courbe(Le_Point_Suivant_En_Face,
                               Le_Vecteur_Suivant_En_Face,
                               Section.Rayon,
                               Section.Orientation,
                               Section.Angle);
        
        -- On memorise la position
        Section.Point:= Le_Point_Suivant_En_Face;
        Section.Vecteur:= Le_Vecteur_Suivant_En_Face;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(1);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur.X := -Le_Vecteur_Suivant_En_Face.X;
        Section_Connectee(1).Vecteur.Y := -Le_Vecteur_Suivant_En_Face.Y;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(2);
        Section_Connectee(2).Point := Le_Point_Suivant_De_Cote;
        Section_Connectee(2).Vecteur.X := -Vecteur.X;
        Section_Connectee(2).Vecteur.Y := -Vecteur.Y;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est la section null on commence
      -- le placement des section
      when Connection_Null =>
        -- On calcul les autres points et vecteurs
        Le_Point_Decale.X := Point.X + Section.Decalage *
                             Cos(Arctan(Vecteur.Y,Vecteur.X,360.0), 360.0);

        Le_Point_Decale.Y := Point.Y + Section.Decalage *
                             Sin(Arctan(Vecteur.Y,Vecteur.X,360.0), 360.0);

        Le_Point_Suivant_En_Face:=  Point_Suivant_Courbe(Le_Point_Decale,
                                                         Vecteur,
                                                         Section.Rayon,
                                                         Section.Orientation,
                                                         Section.Angle);

        Le_Point_Suivant_De_Cote := Point_Suivant_Courbe(Point, Vecteur,
                                                         Section.Rayon,
                                                         Section.Orientation,
                                                         Section.Angle);

        Le_Vecteur_Suivant_De_Cote := Vecteur_Suivant_Courbe(Vecteur,
                                                        Section.Orientation,
                                                             Section.Angle);
        
        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(3);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Le_Vecteur_Suivant_De_Cote;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(2);
        Section_Connectee(2).Point := Le_Point_Suivant_De_Cote;
        Section_Connectee(2).Vecteur := Le_Vecteur_Suivant_De_Cote;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(1);
        Section_Connectee(3).Point := Point;
        Section_Connectee(3).Vecteur.X := -Vecteur.X;
        Section_Connectee(3).Vecteur.Y := -Vecteur.Y;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      when others => null;
    
    end case;
    -- On retourne les informations sur les sections a placer
    Suivant(1..3) := Section_Connectee(1..3);
  
  end Placer;

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
  procedure Paint (Section : in     T_Aiguillage_Simple_Courbe)
  is
    Le_Point_Decale : T_Point;
    Couleur : P_Couleur.T_Couleur_Rvba
            := P_Couleur.Transforme(Section.Couleur);

    Couleur_Segment_Actif : P_Couleur.T_Couleur_Rvba
                          := P_Couleur.Transforme
                            (P_Couleur.Couleur_Segment_Actif);

  begin
    Le_Point_Decale := Point_Suivant_Droit(Section.Point,
                                           Section.Vecteur,
                                           Section.Decalage);

    -- Selon l'etat on met en evidance le chemin actif de l'aiguillage
    if Section.Etat = Etat_Droit
    then
      Glmaterialfv (Gl_Front, Gl_Ambient, Couleur (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse, Couleur (1)'Unchecked_Access);

      Segment_Courbe(Le_Point_Decale, Section.Vecteur,
                   Section.Rayon, Section.Orientation, Largueur_Section,
                   Section.Angle);

      Glmaterialfv (Gl_Front, Gl_Ambient,
                    Couleur_Segment_Actif (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
                    Couleur_Segment_Actif (1)'Unchecked_Access);

      -- Dessine la section active au-dessus de la section inactive
      glTranslatef (0.0,0.0,0.5);
      
      Segment_Courbe( Section.Point, Section.Vecteur,
                      Section.Rayon, Section.Orientation,
                      Largueur_Section, Section.Angle);
    
      glTranslatef (0.0,0.0,-0.5);
      
    else
      Glmaterialfv (Gl_Front, Gl_Ambient, Couleur (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse, Couleur (1)'Unchecked_Access);

      Segment_Courbe(Section.Point, Section.Vecteur,
                     Section.Rayon, Section.Orientation,
                     Largueur_Section, Section.Angle);

      Glmaterialfv (Gl_Front, Gl_Ambient,
                    Couleur_Segment_Actif (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
                    Couleur_Segment_Actif (1)'Unchecked_Access);

      -- Dessine la section active au-dessus de la section inactive
      glTranslatef (0.0,0.0,0.5);
     
      Segment_Courbe(Le_Point_Decale, Section.Vecteur,
                     Section.Rayon, Section.Orientation,
                     Largueur_Section, Section.Angle);

      glTranslatef (0.0,0.0,-0.5);
      
    end if;

  end Paint;

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
  function Positiondansplan(Section         : in T_Aiguillage_Simple_Courbe;
                            Entree          : in T_Connection_Id;
                            Posdanssection  : in T_Position)
    return T_Point
  is
    -- calcul de la longueur des sections courbes
    Circonferance: Float := 2.0*Section.Rayon*Pi;
    Longueur: Float:= (Circonferance*Section.Angle)/360.0;

    -- calcul du point de depart de la courbe exterieur
    Le_Point_Decale: T_Point := Point_Suivant_Droit(Section.Point,
                                                    Section.Vecteur,
                                                    Section.Decalage);
  begin
    -- Selon l'entree, l'etat et la position dans la section on
    -- calcul le point dans le plan
    case Entree
    is
      when 1 =>
        if Section.Etat = Etat_Droit
        then
          return Point_Suivant_Courbe(Section.Point,
                                      Section.Vecteur,
                                      Section.Rayon,
                                      Section.Orientation,
                                      ((Posdanssection * 360.0)/
                                        Circonferance));
        
        else
          if Posdanssection < Section.Decalage
          then
            return Point_Suivant_Droit( Section.Point,
                                        Section.Vecteur,
                                        Posdanssection);
          
          else
            return Point_Suivant_Courbe(Le_Point_Decale,
                                        Section.Vecteur,
                                        Section.Rayon,
                                        Section.Orientation,
                                        (((Posdanssection-Section.Decalage) *
                                          360.0)/ Circonferance));
          
          end if;
        
        end if;
      
      when 2 =>
        return Point_Suivant_Courbe(Section.Point,
                                    Section.Vecteur,
                                    Section.Rayon,
                                    Section.Orientation,
                                    (((Longueur-Posdanssection) * 360.0) /
                                      Circonferance));
      
      when 3 =>
        if Posdanssection < Longueur
        then
          return Point_Suivant_Courbe(Le_Point_Decale,
                                      Section.Vecteur,
                                      Section.Rayon,
                                      Section.Orientation,
                                      (((Longueur-Posdanssection) * 360.0) /
                                        Circonferance));
        
        else
          return Point_Suivant_Droit( Section.Point,
                                      Section.Vecteur,
                                      ((Longueur + Section.Decalage) -
                                        Posdanssection));
        
        end if;
      
      when others => return (0.0,0.0); -- null;
    
    end case;
  
  end Positiondansplan;

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
  procedure Positiondanssection
    (Section        : in     T_Aiguillage_Simple_Courbe;
     Entree         : in     T_Connection_Id;
     Posdanssection : in out T_Position;
     Dehors         :    out Boolean)
  is
    -- calcul de la longueur des sections courbes
    Longueur: Float:= (2.0*Section.Rayon*Pi*Section.Angle)/360.0;

  begin
    case Entree
    is
      when 1 =>
        if Section.Etat = Etat_Droit
        then
           if Posdanssection <= Longueur
           then
             Dehors:= False;
             
           else
             Posdanssection:= Posdanssection - Longueur;
             Dehors:= True;
             
           end if;
        
        else
           if Posdanssection <= (Longueur+ Section.Decalage)
           then
             Dehors:= False;
             
           else
             Posdanssection:= Posdanssection - (Longueur+ Section.Decalage);
             Dehors:= True;
             
           end if;
           
        end if;
        
      when 2 =>
        if Posdanssection <= Longueur
        then
          Dehors:= False;
          
        else
          Posdanssection:= Posdanssection - Longueur;
          Dehors:= True;
          
        end if;
        
      when 3 =>
        if Posdanssection <= (Longueur+ Section.Decalage)
        then
          Dehors:= False;
      
        else
          Posdanssection:= Posdanssection - (Longueur+ Section.Decalage);
          Dehors:= True;
          
        end if;
        
      when others => null;
      
    end case;
    
  end Positiondanssection;

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
  function Positiondepuissortie
    ( Section         : in T_Aiguillage_Simple_Courbe;
      Entree          : in T_Connection_Id;
      Posdepuisentree : in T_Position)
    return T_Position
  is
  begin
    -- Selon l'etat, la longueur, la position dans la section,
    -- et l'entree on calcul la position depuis la sortie
    case Entree
    is
      when 1=>
        if Section.Etat = Etat_Droit
        then
          return (2.0*Section.Rayon*Pi*Section.Angle/360.0) -
            Posdepuisentree;
        
        else
          return ((2.0*Section.Rayon*Pi*Section.Angle/360.0)+
            Section.Decalage) - Posdepuisentree;
        
        end if;

      when 2=>
         return (2.0*Section.Rayon*Pi*Section.Angle/360.0) -
           Posdepuisentree;

      when 3 =>
         return ((2.0*Section.Rayon*Pi*Section.Angle/360.0)+
           Section.Decalage) - Posdepuisentree;

      when others => return 0.0; -- null;
    
    end case;
  
  end Positiondepuissortie;

-- ***********************************************************************
--
-- Primitives d'un aiguillage double
--
-- ***********************************************************************

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
  function New_Aiguillage_Double( Numero      : in T_Section_Id;
                                  Connections : in T_Connections;
                                  Angle       : in Float;
                                  Rayon       : in Float;
                                  Longueur    : in Float)
    return T_Aiguillage_Double_Ptr
  is
  begin
    -- Cree et initialise l'objet
    return new T_Aiguillage_Double'
      ( Nbrconnections  => 4,
        Numero          => Numero,
        Occupe          => False,
        Connections     => Connections(1..4),
        Longueur        => Longueur,
        Angle           => Angle,
        Rayon           => Rayon,
        Etat            => Etat_Droit,
        Point           => (0.0, 0.0),
        Vecteur         => (0.0, 0.0),
        Couleur         => P_Couleur.Couleur_Segment_Inactif );
  
  end New_Aiguillage_Double;

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
  procedure Diriger(Section         : in out T_Aiguillage_Double;
                    Direction       : in     T_Direction;
                    Sousaiguillage  : in     T_Aiguillage_Type)
  is
  begin
    -- Si on dirige l'aiguillage principal
    -- donc a gauche en regardant depuis l'extremite commune
    if Sousaiguillage = Principal
    then
      if Direction = Devie
      then
        if Section.Etat = Etat_Droit
        then
          Section.Etat := Etat_Devie;
        
        elsif Section.Etat = Etat_Droit_Devie
        then
          Section.Etat := Etat_Devie_Devie;
        
        end if;
      
      elsif Direction = Tout_Droit
      then
        if Section.Etat = Etat_Devie
        then
          Section.Etat := Etat_Droit;
        
        elsif Section.Etat = Etat_Devie_Devie
        then
          Section.Etat := Etat_Droit_Devie;
        
        end if;
      
      end if;
    
    -- Si on dirige l'aiguillage secondaire
    -- donc a droite en regardant depuis l'extremite commune
    else
      if Direction = Devie
      then
        if Section.Etat = Etat_Droit
        then
          Section.Etat := Etat_Droit_Devie;
        
        elsif Section.Etat = Etat_Devie
        then
          Section.Etat := Etat_Devie_Devie;
        
        end if;
      
      elsif Direction = Tout_Droit
      then
        if Section.Etat = Etat_Devie_Devie
        then
          Section.Etat := Etat_Devie;
        
        elsif Section.Etat = Etat_Droit_Devie
        then
          Section.Etat := Etat_Droit;
        
        end if;
      
      end if;
    
    end if;

  end Diriger;

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
  function Direction( Section         : in T_Aiguillage_Double;
                      Sousaiguillage  : in T_Aiguillage_Type)
    return T_Direction
  is
  begin
    -- Si on observe la direction de l'aiguillage principal
    -- donc a gauche en regardant depuis l'extremite commune
    if Sousaiguillage = Principal
    then
      -- Selon l'etat de l'aiguillage on indique sa direction
      if ((Section.Etat = Etat_Droit) or
          (Section.Etat = Etat_Droit_Devie))
      then
        return Tout_Droit;
      
      else
        return Devie;
      
      end if;

    -- Si on observe la direction de l'aiguillage secondaire
    -- donc a droite en regardant depuis l'extremite commune
    else
      -- Selon l'etat de l'aiguillage on indique sa direction
      if ((Section.Etat = Etat_Droit) or
          (Section.Etat = Etat_Devie))
      then
        return Tout_Droit;
      
      else
        return Devie;
      
      end if;
    
    end if;
  
  end Direction;

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
  function Prendresortie( Section : in T_Aiguillage_Double;
                          Entree  : in T_Connection_Id)
    return T_Connection_Id
  is
  begin
    -- Si l'entree correspond a l'extremite commune la sortie
    -- depend de l'etat
    if Entree = 1
    then
      if Section.Etat = Etat_Droit
      then
        return 2;
      
      elsif Section.Etat = Etat_Devie
      then
        return 3;
      
      elsif Section.Etat = Etat_Devie_Devie
      then
        raise Derailler;
        return 3;
      
      elsif Section.Etat = Etat_Droit_Devie
      then
        return 4;
      
      end if;
      return 0;
    
    -- Sinon la sortie est l'extremite commune
    else
      return 1;
    
    end if;
  
  end Prendresortie;

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
  procedure Placer( Section : in out T_Aiguillage_Double;
                    Point   : in     T_Point;
                    Vecteur : in     T_Vecteur;
                    Preced  : in     T_Section_Id;
                    Suivant :    out T_Section_A_placer )
  is
    -- Information pour placer les sections connectees
    Section_Connectee : T_Section_A_placer(1..4)
                      := (others=>(0,(0.0,0.0),(0.0,0.0),0));

    -- Variables pour memeoriser les points
    -- et les vecteur de autres extremites
    Le_Point_Suivant_En_Face : T_Point;
    Le_Vecteur_Suivant_En_Face: T_Vecteur;
    Le_Point_Suivant_Droite: T_Point;
    Le_Vecteur_Suivant_Droite: T_Vecteur;
    Le_Point_Suivant_Gauche: T_Point;
    Le_Vecteur_Suivant_Gauche: T_Vecteur;
  
  begin
    -- Selon la section precedante on determine les sections qui
    -- devront etre placees et on s'arrange pour memoriser
    -- la position de l'entree 1
    case Chercherentree(Section.Connections, Preced)
    is
      -- Si la section precedante est connectee a l'entree 1
      when 1 =>
        -- On calcul les autres points et vecteur
        Le_Point_Suivant_En_Face := Point_Suivant_Droit(Point, Vecteur,
                                                        Section.Longueur);

        Le_Point_Suivant_Droite := Point_Suivant_Courbe(Point, Vecteur,
                                                        Section.Rayon,
                                                        Droite,
                                                        Section.Angle);

        Le_Vecteur_Suivant_Droite := Vecteur_Suivant_Courbe(Vecteur,
                                                            Droite,
                                                            Section.Angle);

        Le_Point_Suivant_Gauche := Point_Suivant_Courbe(Point, Vecteur,
                                                        Section.Rayon,
                                                        Gauche,
                                                        Section.Angle);

        Le_Vecteur_Suivant_Gauche := Vecteur_Suivant_Courbe(Vecteur,
                                                            Gauche,
                                                            Section.Angle);
        
        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(2);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(3);
        Section_Connectee(2).Point := Le_Point_Suivant_Gauche;
        Section_Connectee(2).Vecteur := Le_Vecteur_Suivant_Gauche;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(4);
        Section_Connectee(3).Point := Le_Point_Suivant_Droite;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_Droite;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 2
      when 2 =>
        -- On calcul les autres points et vecteur
        Le_Point_Suivant_En_Face := Point_Suivant_Droit(Point, Vecteur,
                                                        Section.Longueur);

        Le_Vecteur_Suivant_En_Face.X := -Vecteur.X;
        Le_Vecteur_Suivant_En_Face.Y := -Vecteur.Y;

        Le_Point_Suivant_Droite :=
          Point_Suivant_Courbe(Le_Point_Suivant_En_Face,
                               Le_Vecteur_Suivant_En_Face,
                               Section.Rayon,
                               Droite,
                               Section.Angle);

        Le_Vecteur_Suivant_Droite :=
          Vecteur_Suivant_Courbe(Le_Vecteur_Suivant_En_Face,
                                 Droite,
                                 Section.Angle);

        Le_Point_Suivant_Gauche :=
          Point_Suivant_Courbe(Le_Point_Suivant_En_Face,
                               Le_Vecteur_Suivant_En_Face,
                               Section.Rayon,
                               Gauche,
                               Section.Angle);

        Le_Vecteur_Suivant_Gauche :=
          Vecteur_Suivant_Courbe(Le_Vecteur_Suivant_En_Face,
                                 Gauche,
                                 Section.Angle);
        
        -- On memorise la position
        Section.Point:= Le_Point_Suivant_En_Face;
        Section.Vecteur:= Le_Vecteur_Suivant_En_Face;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(1);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur.X := -Le_Vecteur_Suivant_En_Face.X;
        Section_Connectee(1).Vecteur.Y := -Le_Vecteur_Suivant_En_Face.Y;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(3);
        Section_Connectee(2).Point := Le_Point_Suivant_Gauche;
        Section_Connectee(2).Vecteur := Le_Vecteur_Suivant_Gauche;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(4);
        Section_Connectee(3).Point := Le_Point_Suivant_Droite;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_Droite;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 3
      when 3 =>
        -- On calcul les autres points et vecteur
        Le_Point_Suivant_Gauche := Point_Suivant_Courbe(Point, Vecteur,
                                                        Section.Rayon,
                                                        Droite,
                                                        Section.Angle);

        Le_Vecteur_Suivant_Gauche := Vecteur_Suivant_Courbe(Vecteur,
                                                            Droite,
                                                            Section.Angle);

        Le_Vecteur_Suivant_Gauche.X := -Le_Vecteur_Suivant_Gauche.X;
        Le_Vecteur_Suivant_Gauche.Y := -Le_Vecteur_Suivant_Gauche.Y;

        Le_Point_Suivant_En_Face :=
          Point_Suivant_Droit(Le_Point_Suivant_Gauche,
                              Le_Vecteur_Suivant_Gauche,
                              Section.Longueur);

        Le_Point_Suivant_Droite :=
          Point_Suivant_Courbe(Le_Point_Suivant_Gauche,
                               Le_Vecteur_Suivant_Gauche,
                               Section.Rayon,
                               Droite,
                               Section.Angle);

        Le_Vecteur_Suivant_Droite :=
          Vecteur_Suivant_Courbe(Le_Vecteur_Suivant_Gauche,
                                 Droite,
                                 Section.Angle);
        
        -- On memorise la position
        Section.Point:= Le_Point_Suivant_Gauche;
        Section.Vecteur:= Le_Vecteur_Suivant_Gauche;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(1);
        Section_Connectee(1).Point := Le_Point_Suivant_Gauche;
        Section_Connectee(1).Vecteur.X := -Le_Vecteur_Suivant_Gauche.X;
        Section_Connectee(1).Vecteur.Y := -Le_Vecteur_Suivant_Gauche.Y;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(2);
        Section_Connectee(2).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(2).Vecteur := Le_Vecteur_Suivant_Gauche;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(4);
        Section_Connectee(3).Point := Le_Point_Suivant_Droite;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_Droite;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 4
      when 4 =>
        -- On calcul les autres points et vecteur
        Le_Point_Suivant_Droite := Point_Suivant_Courbe(Point, Vecteur,
                                                        Section.Rayon,
                                                        Gauche,
                                                        Section.Angle);

        Le_Vecteur_Suivant_Droite := Vecteur_Suivant_Courbe(Vecteur,
                                                            Gauche,
                                                            Section.Angle);

        Le_Vecteur_Suivant_Droite.X := -Le_Vecteur_Suivant_Droite.X;
        Le_Vecteur_Suivant_Droite.Y := -Le_Vecteur_Suivant_Droite.Y;

        Le_Point_Suivant_En_Face :=
          Point_Suivant_Droit(Le_Point_Suivant_Droite,
                              Le_Vecteur_Suivant_Droite,
                              Section.Longueur);

        Le_Point_Suivant_Gauche :=
          Point_Suivant_Courbe(Le_Point_Suivant_Droite,
                               Le_Vecteur_Suivant_Droite,
                               Section.Rayon,
                               Gauche,
                               Section.Angle);

        Le_Vecteur_Suivant_Gauche :=
          Vecteur_Suivant_Courbe(Le_Vecteur_Suivant_Droite,
                                 Gauche,
                                 Section.Angle);

        -- On memorise la position
        Section.Point:= Le_Point_Suivant_Droite;
        Section.Vecteur:= Le_Vecteur_Suivant_Droite;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(1);
        Section_Connectee(1).Point := Le_Point_Suivant_Droite;
        Section_Connectee(1).Vecteur.X := -Le_Vecteur_Suivant_Droite.X;
        Section_Connectee(1).Vecteur.Y := -Le_Vecteur_Suivant_Droite.Y;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(2);
        Section_Connectee(2).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(2).Vecteur := Le_Vecteur_Suivant_Droite;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(3);
        Section_Connectee(3).Point := Le_Point_Suivant_Gauche;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_Gauche;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est la section null on commence
      -- le placement des section
      when Connection_Null =>
        -- On calcul les autres points et vecteur
        Le_Point_Suivant_En_Face := Point_Suivant_Droit(Point,
                                                        Vecteur,
                                                        Section.Longueur);

        Le_Point_Suivant_Droite :=
          Point_Suivant_Courbe(Point, Vecteur,
                               Section.Rayon,
                               Droite,
                               Section.Angle);

        Le_Vecteur_Suivant_Droite := Vecteur_Suivant_Courbe(Vecteur,
                                                            Droite,
                                                            Section.Angle);

        Le_Point_Suivant_Gauche :=
          Point_Suivant_Courbe(Point,
                               Vecteur,
                               Section.Rayon,
                               Gauche,
                               Section.Angle);

        Le_Vecteur_Suivant_Gauche :=
          Vecteur_Suivant_Courbe(Vecteur,
                                 Gauche,
                                 Section.Angle);
        
        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(2);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(3);
        Section_Connectee(2).Point := Le_Point_Suivant_Gauche;
        Section_Connectee(2).Vecteur := Le_Vecteur_Suivant_Gauche;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(4);
        Section_Connectee(3).Point := Le_Point_Suivant_Droite;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_Droite;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

        Section_Connectee(4).Section_Id := Section.Connections(1);
        Section_Connectee(4).Point := Point;
        Section_Connectee(4).Vecteur.X := -Vecteur.X;
        Section_Connectee(4).Vecteur.Y := -Vecteur.Y;
        Section_Connectee(4).Section_Id_Preced:= Section.Numero;
      
      when others => null;
    
    end case;
    
    -- On retourne les informations sur les sections a placer
    Suivant(1..4):= Section_Connectee(1..4);
  
  end Placer;

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
  procedure Paint (Section: in     T_Aiguillage_Double)
  is
     Couleur  : P_Couleur.T_Couleur_Rvba
              := P_Couleur.Transforme(Section.Couleur);

     Couleur_Segment_Actif  : P_Couleur.T_Couleur_Rvba
                            := P_Couleur.Transforme
                              (P_Couleur.Couleur_Segment_Actif);

     Couleur_Risque_De_Deraillement : P_Couleur.T_Couleur_Rvba
                                    := P_Couleur.Transforme
                                      (P_Couleur.Couleur_Risque_Deraillement);

  begin
    -- Selon l'etat on met en evidance le chemin actif de l'aiguillage
    if Section.Etat = Etat_Droit_Devie
    then
      Glmaterialfv (Gl_Front, Gl_Ambient, Couleur (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse, Couleur (1)'Unchecked_Access);

      Segment_Droit ( Section.Point, Section.Vecteur,
                      Section.Longueur, Largueur_Section);

      Segment_Courbe( Section.Point, Section.Vecteur,
                      Section.Rayon, Gauche,
                      Largueur_Section, Section.Angle);

      Glmaterialfv (Gl_Front, Gl_Ambient,
                    Couleur_Segment_Actif (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
                    Couleur_Segment_Actif (1)'Unchecked_Access);

      -- Dessine la section active au-dessus de la section inactive
      glTranslatef (0.0,0.0,0.5);
      
      Segment_Courbe( Section.Point, Section.Vecteur,
                      Section.Rayon, Droite,
                      Largueur_Section, Section.Angle);
    
      glTranslatef (0.0,0.0,-0.5);
      
    elsif Section.Etat = Etat_Droit
    then
      Glmaterialfv (Gl_Front, Gl_Ambient, Couleur (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse, Couleur (1)'Unchecked_Access);

      Segment_Courbe( Section.Point, Section.Vecteur,
                      Section.Rayon, Droite,
                      Largueur_Section, Section.Angle);

      Segment_Courbe( Section.Point, Section.Vecteur,
                      Section.Rayon, Gauche,
                      Largueur_Section, Section.Angle);

      Glmaterialfv (Gl_Front, Gl_Ambient,
                     Couleur_Segment_Actif (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
                     Couleur_Segment_Actif (1)'Unchecked_Access);

      -- Dessine la section active au-dessus de la section inactive
      glTranslatef (0.0,0.0,0.5);
      
      Segment_Droit ( Section.Point, Section.Vecteur,
                      Section.Longueur, Largueur_Section);

    
      glTranslatef (0.0,0.0,-0.5);
      
    elsif (Section.Etat = Etat_Devie)
    then
      Glmaterialfv (Gl_Front, Gl_Ambient, Couleur (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse, Couleur (1)'Unchecked_Access);

      Segment_Droit ( Section.Point, Section.Vecteur,
                      Section.Longueur, Largueur_Section);

      Segment_Courbe( Section.Point, Section.Vecteur,
                      Section.Rayon, Droite,
                      Largueur_Section, Section.Angle);

      Glmaterialfv (Gl_Front, Gl_Ambient,
                    Couleur_Segment_Actif (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
                    Couleur_Segment_Actif (1)'Unchecked_Access);

      -- Dessine la section active au-dessus de la section inactive
      glTranslatef (0.0,0.0,0.5);
      
      Segment_Courbe( Section.Point, Section.Vecteur,
                      Section.Rayon, Gauche,
                      Largueur_Section, Section.Angle);

      glTranslatef (0.0,0.0,-0.5);
      
    elsif (Section.Etat = Etat_Devie_Devie)
    then
      Glmaterialfv (Gl_Front, Gl_Ambient,
                    Couleur_Risque_De_Deraillement (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
                    Couleur_Risque_De_Deraillement (1)'Unchecked_Access);

      Segment_Courbe( Section.Point, Section.Vecteur,
                      Section.Rayon, Droite,
                      Largueur_Section, Section.Angle);

      Segment_Courbe( Section.Point, Section.Vecteur,
                      Section.Rayon, Gauche,
                      Largueur_Section, Section.Angle);

      Segment_Droit ( Section.Point, Section.Vecteur,
                      Section.Longueur, Largueur_Section);

    end if;

  end Paint;

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
  function Positiondansplan(Section         : in T_Aiguillage_Double;
                            Entree          : in T_Connection_Id;
                            Posdanssection  : in T_Position)
    return T_Point
  is
    -- Calcul de la longueur des sections courbes
    Circonferance: Float := 2.0*Section.Rayon*Pi;
    Longueur: Float:= (Circonferance*Section.Angle)/360.0;
  
  begin
    -- Selon l'entree, l'etat et la position dans la section on
    -- calcul le point dans le plan
    case Entree
    is
      when 1 =>
        case Section.Etat
        is
          when Etat_Droit =>
            return Point_Suivant_Droit( Section.Point,
                                        Section.Vecteur,
                                        Posdanssection);

          when Etat_Devie | Etat_Devie_Devie =>
            return Point_Suivant_Courbe(Section.Point,
                                        Section.Vecteur,
                                        Section.Rayon,
                                        Gauche,
                                        ((Posdanssection*360.0)/
                                          Circonferance));
          
          when Etat_Droit_Devie =>
            return Point_Suivant_Courbe(Section.Point,
                                        Section.Vecteur,
                                        Section.Rayon,
                                        Droite,
                                        ((Posdanssection*360.0)/
                                          Circonferance));
        end case;
      
      when 2 =>
        return Point_Suivant_Droit( Section.Point,
                                    Section.Vecteur,
                                    (Section.Longueur - Posdanssection));
      
      when 3 =>
        return Point_Suivant_Courbe(Section.Point,
                                    Section.Vecteur,
                                    Section.Rayon,
                                    Gauche,
                                    (((Longueur-Posdanssection)*360.0)/
                                      Circonferance));
      
      when 4 =>
        return Point_Suivant_Courbe(Section.Point,
                                    Section.Vecteur,
                                    Section.Rayon,
                                    Droite,
                                    (((Longueur-Posdanssection)*360.0)/
                                      Circonferance));
      
      when others => return (0.0,0.0); -- null;
    
    end case;
  
  end Positiondansplan;

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
  procedure Positiondanssection
    (Section        : in     T_Aiguillage_Double;
     Entree         : in     T_Connection_Id;
     Posdanssection : in out T_Position;
     Dehors         :    out Boolean)
  is
    -- calcul de la longueur des sections courbes
    Longueur: Float:= (2.0*Section.Rayon*Pi*Section.Angle)/360.0;
  
  begin
    case Entree
    is
      when 1 =>
        case Section.Etat
        is
          when Etat_Droit =>
            if Posdanssection <= Section.Longueur
            then
              Dehors:= False;
            
            else
              Posdanssection:= Posdanssection - Section.Longueur;
              Dehors:= True;
            
            end if;
          
          when Etat_Devie | Etat_Devie_Devie | Etat_Droit_Devie =>
            if Posdanssection <= Longueur
            then
              Dehors:= False;
            
            else
              Posdanssection:= Posdanssection - Longueur;
              Dehors:= True;
            
            end if;
        
        end case;
      
      when 2 =>
        if Posdanssection <= Section.Longueur
        then
           Dehors:= False;
        
        else
           Posdanssection:= Posdanssection - Section.Longueur;
           Dehors:= True;
       
        end if;
      
      when 3 | 4=>
        if Posdanssection <= Longueur
        then
           Dehors:= False;
        
        else
           Posdanssection:= Posdanssection - Longueur;
           Dehors:= True;
        
        end if;
      
      when others => null;
    
    end case;
  
  end Positiondanssection;

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
  function Positiondepuissortie(Section         : in T_Aiguillage_Double;
                                Entree          : in T_Connection_Id;
                                Posdepuisentree : in T_Position)
    return T_Position
  is
  begin
    -- Selon l'etat, la longueur, la position dans la section,
    -- et l'entree on calcul la position depuis la sortie
    case Entree
    is
      when 1 =>
        case Section.Etat
        is
          when Etat_Droit =>
            return Section.Longueur - Posdepuisentree;
          
          when others =>
            return (2.0*Section.Rayon*Pi*Section.Angle/360.0) -
              Posdepuisentree;
        
        end case;
      
      when 2 =>
        return  Section.Longueur - Posdepuisentree;

      when others =>
        return (2.0*Section.Rayon*Pi*Section.Angle/360.0) -
          Posdepuisentree;
    
    end case;
 
  end Positiondepuissortie;

-- ***********************************************************************
--
-- Primitives d'un aiguillage croix
--
-- ***********************************************************************

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
  function New_Aiguillage_Croix(Numero      : in T_Section_Id;
                                Connections : in T_Connections;
                                Angle       : in Float;
                                Longueur    : in Float)
    return T_Aiguillage_Croix_Ptr
  is
  begin
    -- Cree et initialise l'objet
    return new T_Aiguillage_Croix'
      ( Nbrconnections  => 4,
        Numero          => Numero,
        Occupe          => False,
        Connections     => Connections(1..4),
        Longueur        => Longueur,
        Angle           => Angle,
        Etat            => Etat_Droit,
        Point           => (0.0, 0.0),
        Vecteur         => (0.0, 0.0),
        Couleur         => P_Couleur.Couleur_Segment_Inactif );
  
  end New_Aiguillage_Croix;

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
  procedure Diriger(Section         : in out T_Aiguillage_Croix;
                    Direction       : in     T_Direction;
                    Sousaiguillage  : in     T_Aiguillage_Type)
  is
  begin
    -- On commande l'aiguille
    if Direction = Devie
    then
      Section.Etat := Etat_Devie;
    
    else
      Section.Etat := Etat_Droit;
    
    end if;

  end Diriger;

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
  function Direction( Section         : in T_Aiguillage_Croix;
                      Sousaiguillage  : in T_Aiguillage_Type)
    return T_Direction
  is
  begin
    -- Selon l'etat de l'aiguillage on indique la direction
    if Section.Etat = Etat_Droit
    then
      return Tout_Droit;
    
    else
      return Devie;
    
    end if;
  
  end Direction;

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
  function Prendresortie( Section : in T_Aiguillage_Croix;
                          Entree  : in T_Connection_Id)
    return T_Connection_Id
  is
  begin
    -- Selon l'entree et l'etat on cherche la sortie
    if Section.Etat = Etat_Droit
    then
      if Entree = 1
      then
        return 2;
      
      elsif Entree = 2
      then
        return 1;
      
      elsif Entree = 3
      then
        return 4;
      
      else
        return 3;
      
      end if;
    
    elsif Section.Etat = Etat_Devie
    then
      if Entree = 1
      then
        return 4;
      
      elsif Entree = 4
      then
        return 1;
      
      elsif Entree = 2
      then
        return 3;
      
      else
        return 2;
      
      end if;
    
    end if;
    return 0;
  
  end Prendresortie;

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
  procedure Placer( Section : in out T_Aiguillage_Croix;
                    Point   : in     T_Point;
                    Vecteur : in     T_Vecteur;
                    Preced  : in     T_Section_Id;
                    Suivant :    out T_Section_A_placer )
  is
    -- Information pour placer les sections connectees
    Section_Connectee : T_Section_A_placer(1..4)
                      := (others=>(0,(0.0,0.0),(0.0,0.0),0));
    Le_Point_Suivant_En_Face : T_Point;

    Le_Point_Suivant_En_Face_Decale: T_Point;

    Le_Point_Suivant_A_cote: T_Point;

    Le_Vecteur_Suivant_A_cote: T_Vecteur;

  begin
    -- calcul le point en face de l'entree une
    Le_Point_Suivant_En_Face := Point_Suivant_Droit(Point, Vecteur,
                                                    Section.Longueur);

    -- Selon la section precedante on determine les sections qui
    -- devront etre placees et on s'arrange pour memoriser
    -- la position de l'entree 1
    case Chercherentree(Section.Connections, Preced)
    is
      -- Si la section precedante est connectee a l'entree 1
      when 1 =>
        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;

        -- On calcul les autres points et vecteur
        Le_Point_Suivant_A_cote :=
          Point_Suivant_Decale(Point,
                               Vecteur,
                               Section.Longueur,
                               Droite,
                               Section.Angle);
                      
         Le_Vecteur_Suivant_A_cote :=
          Vecteur_Suivant_Decale(Vecteur,
                                 Droite,
                                 Section.Angle);

         Le_Point_Suivant_En_Face_Decale :=
          Point_Suivant_Droit(Le_Point_Suivant_A_cote,
                              Le_Vecteur_Suivant_A_cote,
                              Section.Longueur);

         -- Fournit les informations pour placer les sections connectee
         Section_Connectee(1).Section_Id := Section.Connections(2);
         Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
         Section_Connectee(1).Vecteur := Vecteur;
         Section_Connectee(1).Section_Id_Preced:= Section.Numero;

         Section_Connectee(2).Section_Id := Section.Connections(3);
         Section_Connectee(2).Point := Le_Point_Suivant_A_cote;
         Section_Connectee(2).Vecteur.X := -Le_Vecteur_Suivant_A_cote.X;
         Section_Connectee(2).Vecteur.Y := -Le_Vecteur_Suivant_A_cote.Y;
         Section_Connectee(2).Section_Id_Preced:= Section.Numero;

         Section_Connectee(3).Section_Id := Section.Connections(4);
         Section_Connectee(3).Point := Le_Point_Suivant_En_Face_Decale;
         Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_A_cote;
         Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 2
      when 2 =>
        -- On memorise la position
        Section.Point:= Le_Point_Suivant_En_Face;
        Section.Vecteur.X:= -Vecteur.X;
        Section.Vecteur.Y:= -Vecteur.Y;

        -- On calcul les autres points et vecteur
        Le_Point_Suivant_A_cote := Point_Suivant_Decale(Point, Vecteur,
                                                        Section.Longueur,
                                                        Droite,
                                                        Section.Angle);
             
        Le_Vecteur_Suivant_A_cote := Vecteur_Suivant_Decale(Vecteur,
                                                         Droite,
                                                         Section.Angle);

        Le_Point_Suivant_En_Face_Decale :=
          Point_Suivant_Droit(Le_Point_Suivant_A_cote,
                              Le_Vecteur_Suivant_A_cote,
                              Section.Longueur);

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(1);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(4);
        Section_Connectee(2).Point := Le_Point_Suivant_A_cote;
        Section_Connectee(2).Vecteur.X := -Le_Vecteur_Suivant_A_cote.X;
        Section_Connectee(2).Vecteur.Y := -Le_Vecteur_Suivant_A_cote.Y;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(3);
        Section_Connectee(3).Point := Le_Point_Suivant_En_Face_Decale;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_A_cote;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 3
      when 3 =>
        Le_Point_Suivant_A_cote := Point_Suivant_Decale(Point,
                                                        Vecteur,
                                                        Section.Longueur,
                                                        Gauche,
                                                        Section.Angle);

        Le_Vecteur_Suivant_A_cote := Vecteur_Suivant_Decale(Vecteur,
                                                            Gauche,
                                                            Section.Angle);

        Le_Point_Suivant_En_Face_Decale :=
          Point_Suivant_Droit(Le_Point_Suivant_A_cote,
                              Le_Vecteur_Suivant_A_cote,
                              Section.Longueur);

        -- On memorise la position
        Section.Point:= Le_Point_Suivant_A_cote;
        Section.Vecteur:= Le_Vecteur_Suivant_A_cote;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(4);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(1);
        Section_Connectee(2).Point := Le_Point_Suivant_A_cote;
        Section_Connectee(2).Vecteur.X := -Le_Vecteur_Suivant_A_cote.X;
        Section_Connectee(2).Vecteur.Y := -Le_Vecteur_Suivant_A_cote.Y;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(2);
        Section_Connectee(3).Point := Le_Point_Suivant_En_Face_Decale;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_A_cote;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est connectee a l'entree 4
      when 4 =>
        -- On calcul les autres points et vecteur
        Le_Point_Suivant_A_cote := Point_Suivant_Decale(Point,
                                                        Vecteur,
                                                        Section.Longueur,
                                                        Gauche,
                                                        Section.Angle);

        Le_Vecteur_Suivant_A_cote :=
          Vecteur_Suivant_Decale(Vecteur,
                                 Gauche,
                                 Section.Angle);

        Le_Point_Suivant_En_Face_Decale :=
          Point_Suivant_Droit(Le_Point_Suivant_A_cote,
                              Le_Vecteur_Suivant_A_cote,
                              Section.Longueur);

        -- On memorise la position
        Section.Point:= Le_Point_Suivant_En_Face_Decale;
        Section.Vecteur.X:= -Le_Vecteur_Suivant_A_cote.X;
        Section.Vecteur.Y:= -Le_Vecteur_Suivant_A_cote.Y;

        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(3);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;

        Section_Connectee(2).Section_Id := Section.Connections(2);
        Section_Connectee(2).Point := Le_Point_Suivant_A_cote;
        Section_Connectee(2).Vecteur.X := -Le_Vecteur_Suivant_A_cote.X;
        Section_Connectee(2).Vecteur.Y := -Le_Vecteur_Suivant_A_cote.Y;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;

        Section_Connectee(3).Section_Id := Section.Connections(1);
        Section_Connectee(3).Point := Le_Point_Suivant_En_Face_Decale;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_A_cote;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;

      -- Si la section precedante est la section null on commence
      -- le placement des section
      when Connection_Null =>
        -- On memorise la position
        Section.Point:= Point;
        Section.Vecteur:= Vecteur;
    
        -- On calcul les autres points et vecteur
        Le_Point_Suivant_A_cote := Point_Suivant_Decale(Point,
                                                        Vecteur,
                                                        Section.Longueur,
                                                        Droite,
                                                        Section.Angle);
    
    
    
        Le_Vecteur_Suivant_A_cote :=
          Vecteur_Suivant_Decale(Vecteur,
                                 Droite,
                                 Section.Angle);
    
    
        Le_Point_Suivant_En_Face_Decale :=
          Point_Suivant_Droit(Le_Point_Suivant_A_cote,
                              Le_Vecteur_Suivant_A_cote,
                              Section.Longueur);
    
        -- Fournit les informations pour placer les sections connectee
        Section_Connectee(1).Section_Id := Section.Connections(2);
        Section_Connectee(1).Point := Le_Point_Suivant_En_Face;
        Section_Connectee(1).Vecteur := Vecteur;
        Section_Connectee(1).Section_Id_Preced:= Section.Numero;
    
        Section_Connectee(2).Section_Id := Section.Connections(3);
        Section_Connectee(2).Point := Le_Point_Suivant_A_cote;
        Section_Connectee(2).Vecteur.X := -Le_Vecteur_Suivant_A_cote.X;
        Section_Connectee(2).Vecteur.Y := -Le_Vecteur_Suivant_A_cote.Y;
        Section_Connectee(2).Section_Id_Preced:= Section.Numero;
    
        Section_Connectee(3).Section_Id := Section.Connections(4);
        Section_Connectee(3).Point := Le_Point_Suivant_En_Face_Decale;
        Section_Connectee(3).Vecteur := Le_Vecteur_Suivant_A_cote;
        Section_Connectee(3).Section_Id_Preced:= Section.Numero;
    
        Section_Connectee(4).Section_Id := Section.Connections(1);
        Section_Connectee(4).Point := Point;
        Section_Connectee(4).Vecteur.X := -Vecteur.X;
        Section_Connectee(4).Vecteur.Y := -Vecteur.Y;
        Section_Connectee(4).Section_Id_Preced:= Section.Numero;
    
      when others => null;
    
    end case;
    
    -- On retourne les informations sur les sections a placer
    Suivant(1..4) := Section_Connectee(1..4);
  
  end Placer;

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
  procedure Paint (Section: in     T_Aiguillage_Croix)
  is
    -- Le point memorise est le debut de la jambe gauche du X on va
    -- donc cherche celui de la jambe droite
    Le_Point_Suivant_A_cote: T_Point;

    Lepointintermediaire : T_Point;
    Le_Vecteur_Suivant_A_cote: T_Vecteur;
    Couleur : P_Couleur.T_Couleur_Rvba
            := P_Couleur.Transforme(Section.Couleur);

    Couleur_Segment_Actif : P_Couleur.T_Couleur_Rvba
                          := P_Couleur.Transforme
                            (P_Couleur.Couleur_Segment_Actif);

  begin
    -- On cherche la position du centre de la croix
    Lepointintermediaire:= Point_Suivant_Droit(Section.Point,
                                               Section.Vecteur,
                                               Section.Longueur/2.0);

    Le_Point_Suivant_A_cote := Point_Suivant_Decale(Section.Point,
                                                    Section.Vecteur,
                                                    Section.Longueur,
                                                    Droite,
                                                    Section.Angle);

    Le_Vecteur_Suivant_A_cote :=
      Vecteur_Suivant_Decale(Section.Vecteur, Droite,
                             Section.Angle);

    -- Selon l'etat on met en evidance le chemin actif de l'aiguillage
    if Section.Etat = Etat_Droit
    then
      Glmaterialfv (Gl_Front, Gl_Ambient, Couleur (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse, Couleur (1)'Unchecked_Access);
      -- on dessine la traversee directe en deux morceau pour pouvoir afficher
      -- l'etat courbe de l'aiguillage
      Segment_Droit ( Le_Point_Suivant_A_cote, Le_Vecteur_Suivant_A_cote,
                      Section.Longueur/2.0, Largueur_Section);


      Segment_Droit (Lepointintermediaire, Le_Vecteur_Suivant_A_cote,
                  Section.Longueur/2.0, Largueur_Section);
      Glmaterialfv (Gl_Front, Gl_Ambient,
                    Couleur_Segment_Actif (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
                    Couleur_Segment_Actif (1)'Unchecked_Access);

      -- Dessine la section active au-dessus de la section inactive
      glTranslatef (0.0,0.0,0.5);
      
      Segment_Droit ( Section.Point, Section.Vecteur,
                      Section.Longueur/2.0, Largueur_Section);


      Segment_Droit ( Lepointintermediaire, Section.Vecteur,
                      Section.Longueur/2.0, Largueur_Section);
    
      glTranslatef (0.0,0.0,-0.5);
      
    else
      Glmaterialfv (Gl_Front, Gl_Ambient,
         Couleur (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
         Couleur (1)'Unchecked_Access);

      -- on dessine la traversee directe en deux morceau pour pouvoir afficher
      -- l'etat courbe de l'aiguillage
      Segment_Droit ( Le_Point_Suivant_A_cote,
                      Le_Vecteur_Suivant_A_cote,
                      Section.Longueur/2.0, Largueur_Section);

      Segment_Droit ( Lepointintermediaire, Section.Vecteur,
                      Section.Longueur/2.0, Largueur_Section);

      Glmaterialfv (Gl_Front, Gl_Ambient,
                    Couleur_Segment_Actif (1)'Unchecked_Access);
      Glmaterialfv (Gl_Front, Gl_Diffuse,
                    Couleur_Segment_Actif (1)'Unchecked_Access);

      -- Dessine la section active au-dessus de la section inactive
      glTranslatef (0.0,0.0,0.5);
      
      Segment_Droit ( Section.Point, Section.Vecteur,
                      Section.Longueur/2.0, Largueur_Section);

      Segment_Droit ( Lepointintermediaire, Le_Vecteur_Suivant_A_cote,
                      Section.Longueur/2.0, Largueur_Section);

      glTranslatef (0.0,0.0,-0.5);
      
    end if;
  
  end Paint;

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
  function Positiondansplan(Section         : in T_Aiguillage_Croix;
                            Entree          : in T_Connection_Id;
                            Posdanssection  : in T_Position)
    return T_Point
  is
  begin
    -- Selon l'entree, l'etat et la position dans la section on
    -- calcul le point dans le plan
    case Entree
    is
      when 1 =>
        if Section.Etat = Etat_Droit
        then
          return Point_Suivant_Droit( Section.Point,
                                      Section.Vecteur,
                                      Posdanssection);
        
        else
          if Posdanssection < (Section.Longueur/2.0)
          then
            return Point_Suivant_Droit( Section.Point,
                                        Section.Vecteur,
                                        Posdanssection);
          
          else
            return Point_Suivant_Droit(
              Point_Suivant_Decale(Section.Point,
                                   Section.Vecteur,
                                   Section.Longueur,
                                   Droite,
                                   Section.Angle),
              Vecteur_Suivant_Decale(Section.Vecteur,
                                     Droite,
                                     Section.Angle),
              Posdanssection);
          
          end if;
        
        end if;
      
      when 2 =>
        if Section.Etat = Etat_Droit
        then
          return Point_Suivant_Droit( Section.Point,
                                      Section.Vecteur,
                                      (Section.Longueur - Posdanssection));
        else
          if Posdanssection < (Section.Longueur/2.0)
          then
            return Point_Suivant_Droit( Section.Point,
                                        Section.Vecteur,
                                        (Section.Longueur - Posdanssection));
          
          else
            return Point_Suivant_Droit(
               Point_Suivant_Decale(Section.Point,
                                    Section.Vecteur,
                                    Section.Longueur,
                                    Droite,
                                    Section.Angle),
               Vecteur_Suivant_Decale(Section.Vecteur,
                                      Droite,
                                      Section.Angle),
               (Section.Longueur - Posdanssection));
          
          end if;
        
        end if;
      
      when 3 =>
        if Section.Etat = Etat_Droit
        then
          return Point_Suivant_Droit(
            Point_Suivant_Decale(Section.Point,
                                 Section.Vecteur,
                                 Section.Longueur,
                                 Droite,
                                 Section.Angle),
            Vecteur_Suivant_Decale(Section.Vecteur,
                                   Droite,
                                   Section.Angle),
            Posdanssection);
        
        else
          if Posdanssection < (Section.Longueur/2.0)
          then
            return Point_Suivant_Droit(
              Point_Suivant_Decale(Section.Point,
                                   Section.Vecteur,
                                   Section.Longueur,
                                   Droite,
                                   Section.Angle),
              Vecteur_Suivant_Decale(Section.Vecteur,
                                     Droite,
                                     Section.Angle),
              Posdanssection);
          
          else
            return Point_Suivant_Droit(Section.Point,
                                       Section.Vecteur,
                                       Posdanssection);
          
          end if;
        
        end if;
      
      when 4 =>
        if Section.Etat = Etat_Droit
        then
          return Point_Suivant_Droit(
             Point_Suivant_Decale(Section.Point,
                                  Section.Vecteur,
                                  Section.Longueur,
                                  Droite,
                                  Section.Angle),
             Vecteur_Suivant_Decale(Section.Vecteur,
                                  Droite,
                                  Section.Angle),
                                  (Section.Longueur - Posdanssection));
        else
          if Posdanssection < (Section.Longueur/2.0)
          then
            return Point_Suivant_Droit(
              Point_Suivant_Decale(Section.Point,
                                   Section.Vecteur,
                                   Section.Longueur,
                                   Droite,
                                   Section.Angle),
              Vecteur_Suivant_Decale(Section.Vecteur,
                                     Droite,
                                     Section.Angle),
                                     (Section.Longueur - Posdanssection));
          
          else
            return Point_Suivant_Droit(Section.Point,
                                       Section.Vecteur,
                                       (Section.Longueur - Posdanssection));
          
          end if;
        
        end if;
      
      when others => return (0.0,0.0); -- null;
    
    end case;
  
  end Positiondansplan;

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
  procedure Positiondanssection
    (Section        : in     T_Aiguillage_Croix;
     Entree         : in     T_Connection_Id;
     Posdanssection : in out T_Position;
     Dehors         :    out Boolean)
  is
  begin
    if  Posdanssection <= Section.Longueur
    then
      Dehors:= False;
    
    else
      Posdanssection:= Posdanssection - Section.Longueur;
      Dehors:= True;
    
    end if;
  
  end Positiondanssection;

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
  function Positiondepuissortie(Section         : in T_Aiguillage_Croix;
                                Entree          : in T_Connection_Id;
                                Posdepuisentree : in T_Position)
    return T_Position
  is
  begin
    return Section.Longueur - Posdepuisentree;
  
  end Positiondepuissortie;

-- ***********************************************************************
--
-- Sous-programme a l'echelle de classe (Procedures et fonctions
--    utilisatbles avec n'importe quel objet de la classe section
--
-- ***********************************************************************
  ------------------------------------------------------------------------
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
  ------------------------------------------------------------------------
  procedure Prendresectionsuivante
    (Section  : in out T_Section_Ptr;
     Entree   : in out T_Connection_Id;
     Sections : in     T_Sections)
  is
    -- On stocke l'id de la section.
    Sectionid: T_Section_Id := Section.Numero;

  begin
    -- On recherche la section suivante de la section courante.
    Section := Sections(Section.Connections
                        (Prendresortie(Section.all, Entree)));

    -- On recherche l'entree de la section.
    Entree := Chercherentree(Section.Connections, Sectionid);

  end Prendresectionsuivante;

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
  procedure Mettrecouleur (Section: in     T_Section_Ptr;
                           Couleur: in     P_Couleur.T_Couleur)
  is
  begin
    Section.Couleur:= Couleur;
  
  end Mettrecouleur;

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
  procedure Occuper(Section: in     T_Section_Ptr)
  is
  begin
    -- On teste si la section est occupee.
    if Section.Occupe
    then
      raise Collision;                   -- Oui, exception.
    
    end if;

    -- On occupe la section.
    Section.Occupe := True;
    
  end Occuper;

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
  procedure Liberer (Section : in     T_Section_Ptr)
  is
  begin
    Section.Occupe := False;
    
  end Liberer;

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
  function Estoccuper (Section : in T_Section_Ptr)
    return Boolean
  is
  begin
    return Section.Occupe;
    
  end Estoccuper;

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
  function Numero (Section : in T_Section_Ptr)
    return T_Section_Id
  is
  begin
    return Section.Numero;
    
  end Numero;

end P_Section;
