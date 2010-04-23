------------------------------------------------------------------------------
--
-- Nom du fichier     : P_Maquette-Display-OpenGL_Callback.ads
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
-- Projet             : Simulateur de maquette
-- Module             : Maquette
--
-- But                : Module contenant les fonction de callback OpenGL
--                      necessaires a l'affichage du simulateur
--
-- Modules appeles    : Glut, Win32.Gl, Win32.Glu, P_Afficher,
--                      Interfaces.C.Strings, GNAT.OS_Lib,
--                      Ada.Numerics.Elementary_Functions
--                    
-- Fonctions exportees: Init_Scene               
--                      Display_Callback
--                      Reshape_Callback
--                      Mouse_Callback
--                      Keyboard_Callback
--                      Special_Key_Callback
--                      Idle_Callback
--                      Menu
--                      Sub_Menu_Rotate
--                      Sub_Menu_Display
--                      Sub_Menu_Mode
--                      Sub_Menu_Icones
-- 
-- Materiel 
-- particulier        : Les dll "Glut32.dll", "OpenGl32.dll" et "Glu32.dll"
--                      doivent etre dans le repertoire systeme de Windows
--
------------------------------------------------------------------------------

-- Appel de la librairie OpenGl
with Gl;
-- Appel de la librairie d'utilitaires OpenGL
with Glu;
-- Appel de la librairie GLUT
with Glut;
-- Appel de la librairie de GNAT pour l'acces au systeme d'exploitation
with GNAT.OS_Lib;

-- Mettre les fonctions mathematiques elementaires a disposition
with Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions;

package body P_Maquette.Display.OpenGL_Callback is
  -- Utilisation de la librairie OpenGL
  use Gl;
  -- Utilisation de la librairie d'utilitaires OpenGL
  use Glu;
  -- Utilisation de la librairie GLUT
  use Glut;
  -- Utilisation de la librairie d'interfacage vers le C
  use Interfaces.C;

  -- Definition d'un type vecteur a quatre composantes pour faciliter
  -- la definition des couleurs et des lumieres
  type glFloat4 is array ( 1 .. 4 ) of aliased GlFloat;

  Largueur: Float;            -- Largueur de la fenetre graphique
  Hauteur : Float;            -- Hauteur de la fenetre graphique
  
  -- Angle de la projection du segment origine -> observateur et de l'axe
  -- Z dans le plan ZY (utiliser pour definir l'emplacement de
  -- l'observateur)
  Alpha: Float:= 0.0;
  
  -- Angle de la projection du segment origine -> observateur et de l'axe
  -- Y dans le plan XY (utiliser pour definir l'emplacement de
  -- l'observateur)
  Beta: Float:= 0.0;
  
  -- Distance entre l'origine et l'observateur (utiliser pour
  -- definir l'emplacement de l'observateur)
  Distance: Float:= 1750.0;
  
  -- Angle alpha maximum pour que l'observateur ne passe pas sous
  -- la maquette
  Alpha_Max : constant Float:= 75.0;

  -- Angle alpha minimum pour que l'observateur ne passe pas sous
  -- la maquette
  Alpha_Min : constant Float:= -75.0;

  -- Distance maximum entre l'observateur et la maquette
  Distance_Max: constant Float:= 5000.0;

  -- Distance minimum entre l'observateur et la maquette
  Distance_Min: constant Float:= 500.0;

  -- Affichage des icones
  Afficher_Icones : Boolean := False;

  -----------------------------------------------------------------------------
  -- Procedure Init_Scene
  -----------------------------------------------------------------------------
  -- But : Procedure initialisant tous les parametres OpenGL
  -----------------------------------------------------------------------------
  -- in     : 
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Init_Scene
  is
    -- type utilise pour specifier la position d'une source de lumiere
    type Glfloat_4 is array (1 .. 4) of aliased Glfloat;

    -- Definit la couleur de la source de lumiere pour sa composante ambiante
    Ambient        : P_Couleur.T_Couleur_Rvba := ( 0.5, 0.5, 0.5, 1.0 );

    -- Definit la couleur de la source de lumiere pour sa composante diffuse
    Diffuse        : P_Couleur.T_Couleur_Rvba := ( 0.5, 0.5, 0.5, 1.0 );

    -- Definit la position de la source de lumiere
    Position       : Glfloat_4                := ( 0.0, 0.0, 10.0, 0.0 );

  begin -- Init_Scene
    -- Deffinit le model de coloration les objets seront colore de maniere
    -- uniforme
    Glshademodel (GL_FLAT);

    -- Definit la comparaison utilisee par le Z-buffer pour determiner les
    -- faces cachee (dans ce cas on affiche les element les plus proche
    -- et on supprime ceux qui sont derriere
    Gldepthfunc (Gl_Less);
    
    -- Met en fonction la suppression des face cachee a l'aide du Z-buffer
    Glenable (Gl_Depth_Test);

    -- Met l'illumination en fonction
    Glenable (Gl_Lighting);

    -- Definit les caracteristique de la source de lumiere zero
    Gllightfv (Gl_Light0, Gl_Ambient, Ambient(1)'Unchecked_Access);
    Gllightfv (Gl_Light0, Gl_Diffuse, Diffuse(1)'Unchecked_Access);
    Gllightfv (Gl_Light0, Gl_Position, Position(1)'Unchecked_Access);

    -- Definit une illumination d'ambiance la scene est illuminee partout de
    -- maniere egale
    Gllightmodelfv (Gl_Light_Model_Ambient,
                    Ambient(1)'Unchecked_Access);

    -- Met en fonction la source de lumiere zero
    Glenable (Gl_Light0);

    -- Definit la couleur de fond
    Glclearcolor (0.1, 0.1, 0.2, 0.0);

  end Init_Scene;
  
  -----------------------------------------------------------------------------
  -- Procedure Display_Callback
  -----------------------------------------------------------------------------
  -- But : Procedure de callback pour l'affichage du simulateur
  --       Dessiner, avec la Libarairie Opengl, la fenetre
  --       graphique. Cette fonction sera automatiquement appellee
  --       lorsque la fenetre graphique devra etre rafraichie
  --       (par exemple si on place une fenetre devant ou lorsque
  --        ouvre la fenetre)
  --     
  --       On va dessiner: la maquette (les sections) et les trains
  --                       en perspective selon la position de
  --                       l'observateur.
  --     
  --                       Et les icones sans perspective en bas
  --                       de l'ecran.
  --                       Icones : Double fleche verticale pour
  --                                  regler la hauteur du point de
  --                                  vue
  --                                Double fleche horizontale pour
  --                                  regler la rotation du point
  --                                  de vue autour du centre de
  --                                  la maquette
  --                                Rond avec un point au centre
  --                                  pour augmenter la distance
  --                                  entre le centre de la
  --                                  maquette et le point de vue
  --                                Rond barre pour diminuer cette
  --                                  meme distance
  --                                Lettre R ou L pour indiquer et
  --                                  modifier le mode de
  --                                  simulation rapide
  --                                Lettre P pour fournir la
  --                                  quittance de l'utilisateur
  --                                  au simulateur lors de
  --                                  l'utilisation en mode pas a
  --                                  pas
  -- Variables
  -- globales
  -- lues     : Alpha          => Valeur indiquant l'angle de rotation
  -- (globales                    de l'obervateur sur le plan ZY
  -- a fenetre) Beta           => Valeur indiquant l'angle de rotation
  --                              de l'obervateur sur le plan XY
  --            Distance       => Valeur indiquant la distance de
  --                              l'observateur au centre de la maquette
  --
  -- Remarque : La procedure a les parametres exige pour que l'on
  --            puisse la specifier comme fonction appelable
  --            automatiquement par un mecanisme de callback
  --
  -----------------------------------------------------------------------------
  -- in     :
  --    out :
  -- in out :
  -----------------------------------------------------------------------------
  procedure Display_Callback
  is
    -- Type utiliser pour definir le sens d'affichage d'un icone en forme de
    -- fleche
    type T_Sens is (Vertical, Horizontal);

    -- Couleur utiliser pour specifier les proprietes de reflexion
    -- de la lumiere d'un objet
    Blanc_Diffuse : P_Couleur.T_Couleur_Rvba :=
      P_Couleur.Transforme(P_Couleur.Blanc);
      
    Blanc_Ambient : P_Couleur.T_Couleur_Rvba :=
      P_Couleur.Transforme(P_Couleur.Blanc);

    --------------------------------------------------------------------
    --
    -- procedure: Fleche
    -- But      : Dessiner, avec La Libarairie Opengl, une fleche a
    --            deux pointes. Cette fleche sera en deux
    --            dimensions sur le plan XY (Z = 0)
    --
    -- Entrees  : Pos_X       => Position sur l'axe X ou la fleche
    --                           sera dessine (milieu du trait
    --                           separant les deux pointes)
    --            Pos_Y       => Position sur l'axe Y ou la fleche
    --                           sera dessine (milieu du trait
    --                           separant les deux pointes)
    --            Largueur    => Largueur du rectangle contenant la
    --                           fleche
    --            Hauteur     => Hauteur du rectangle contenant la
    --                           fleche
    --
    -- Remarque : On divise le rectangle contenant la fleche en trois
    --            dans le sens de la hauteur puis on dessine deux
    --            triangles dans les parties exterieurs et on les relie
    --            par un trait, on aura ainsi une double fleche
    --
    --------------------------------------------------------------------
    procedure Fleche (Pos_X     : in     Float;
                      Pos_Y     : in     Float;
                      Largueur  : in     Float;
                      Hauteur   : in     Float;
                      Sens      : in     T_Sens)
    is
    begin
      -- Sauve la matrice "modelview" sur la pile, on la retablira a la fin
      -- de la procedure ainsi les transformations effectuee n'agiront que
      -- sur les objets dessine dans la procedure
      Glpushmatrix;

      -- On specifie la couleur du dessin en determinant les proprietes de
      -- reflexion de la lumiere de l'objet dessine
      Glmaterialfv (Gl_Front,
                    Gl_Ambient,
                    Blanc_Ambient (1)'Unchecked_Access);
        
      Glmaterialfv (Gl_Front,
                    Gl_Diffuse,
                    Blanc_Diffuse (1)'Unchecked_Access);

      -- Place la fleche a l'endroit demande
      Gltranslatef (Glfloat(Pos_X), Glfloat(Pos_Y), 0.0);

      -- On place la fleche dans le sens demande
      if Sens = Horizontal
      then
        -- Pour obtenir une fleche horizontale on effectue une rotation
        -- de 90 degres
        Glrotatef (90.0, 0.0, 0.0, 1.0);

      end if;
      
      -- On dessine la fleche centree a l'origine
      -- On commence par le triangle du bas
      Glbegin(Gl_Triangles);
        Glvertex3f(0.0,
                   Glfloat(-Hauteur/2.0),
                   0.0);
                   
        Glvertex3f(Glfloat(-Largueur/2.0),
                   Glfloat(-Hauteur/6.0),
                   0.0);
                   
        Glvertex3f(Glfloat(Largueur/2.0),
                   Glfloat(-Hauteur/6.0),
                   0.0);
                   
      Glend;
      
      -- Ensuite celui du haut
      Glbegin(Gl_Triangles);
        Glvertex3f(Glfloat(-Largueur/2.0),
                   Glfloat(Hauteur/6.0),
                   0.0);
                   
        Glvertex3f(0.0,
                   Glfloat(Hauteur/2.0),
                   0.0);
                   
        Glvertex3f(Glfloat(Largueur/2.0),
                   Glfloat(Hauteur/6.0),
                   0.0); 
                   
      Glend;
      
      -- On determine la largueur du trait separant les deux triangles
      Gllinewidth(Glfloat(Largueur/5.0));
      
      -- On dessine le trait
      Glbegin(Gl_Line_Strip);
        Glvertex3f(0.0,
                   Glfloat(Hauteur/6.0),
                   0.0);  
                   
        Glvertex3f(0.0,
                   Glfloat(-Hauteur/6.0),
                   0.0);
                   
      Glend;
      
      -- On retablit le contexte precedant l'execution de la fonction
      Glpopmatrix;
      
    end Fleche;

    --------------------------------------------------------------------
    --
    -- procedure: Cercle_Pointe
    -- But      : Dessiner, avec La Libarairie Opengl, un cercle dans
    --            lequelle se trouve un petit disque. Ce cercle sera
    --            en deux dimension sur le plan XY (Z = 0)
    --
    -- Entrees  : Pos_X       => Position sur l'axe X ou le cercle
    --                           sera dessine (centre du cercle)
    --            Pos_Y       => Position sur l'axe Y ou le cercle
    --                           sera dessine (centre du cercle)
    --            Rayon       => Rayon exterieur du cercle
    --            Largueur    => Epaisseur du trait formant le cercle
    --
    --------------------------------------------------------------------
    procedure Cercle_Pointe(Pos_X     : in     Float;
                            Pos_Y     : in     Float;
                            Rayon     : in     Float;
                            Largueur  : in     Float )
    is
      -- Definition d'un objet quadric. Les quadric font partie de la
      -- GLU et sont utilent pour dessiner des formes geometrique simple
      Disque: gluquadricobjptr;

    begin
      -- Sauve la matrice "modelview" sur la pile, on la retablira a la fin
      -- de la procedure ainsi les transformations effectuee n'agiront que
      -- sur les objets dessine dans la procedure
      Glpushmatrix;

      -- On specifie la couleur du dessin en determinant les proprietes de
      -- reflexion de la lumiere de l'objet dessine
      Glmaterialfv (Gl_Front,
                    Gl_Ambient,
                    Blanc_Ambient (1)'Unchecked_Access);
        
      Glmaterialfv (Gl_Front,
                    Gl_Diffuse,
                    Blanc_Diffuse (1)'Unchecked_Access);

      -- Place le cercle a l'endroit demande
      Gltranslatef (Glfloat(Pos_X), Glfloat(Pos_Y), 0.0);

      -- Cree une instance d'un Quadric
      Disque := Glunewquadric;

      -- Dessine une couronne centree a l'origine
      Gludisk(Disque,
              Gldouble(Rayon-(Largueur/2.0)),
              Gldouble(Rayon),
              20,
              2);

      -- On detruit l'instance de l'objet Quadric
      Gludeletequadric(Disque);

      Disque := Glunewquadric;
      
      -- On dessine un disque centre a l'origine
      Gludisk(Disque, 0.0, Gldouble(Largueur/2.0), 20, 2);

      -- Detruit l'instance du Quadric
      Gludeletequadric(Disque);

      -- On retablit le contexte precedant l'execution de la fonction
      Glpopmatrix;
      
    end Cercle_Pointe;

    --------------------------------------------------------------------
    --
    -- procedure: Cercle_Barre
    -- But      : Dessiner, avec La Libarairie Opengl, un cercle dans
    --            lequelle se trouve une croix. Ce cercle sera
    --            en deux dimension sur le plan XY (Z = 0)
    --
    -- Entrees  : Pos_X       => Position sur l'axe X ou le cercle
    --                           sera dessine (centre du cercle)
    --            Pos_Y       => Position sur l'axe Y ou le cercle
    --                           sera dessine (centre du cercle)
    --            Rayon       => Rayon exterieur du cercle
    --            Largueur    => Epaisseur du trait formant le cercle
    --                           et la croix
    --
    --------------------------------------------------------------------
    procedure Cercle_Barre (Pos_X     : in     Float;
                            Pos_Y     : in     Float;
                            Rayon     : in     Float;
                            Largueur  : in     Float )
    is
      -- Longueur d'un petit cote d'un triangle dont l'hypotenuse est
      -- le rayon. Utile pour tracer la croix
      Pos_Trait : Float := Sqrt(((Rayon-Largueur/2.0)**2)/2.0);

      -- Definition d'un objet quadric. Les quadric font partie de la
      -- GLU et sont utilent pour dessiner des formes geometrique simple
      Disque : gluquadricobjptr;
       
    begin
      -- Sauve la matrice "modelview" sur la pile, on la retablira a la fin
      -- de la procedure ainsi les transformations effectuee n'agiront que
      -- sur les objets dessine dans la procedure
      Glpushmatrix;

      -- On specifie la couleur du dessin en determinant les proprietes de
      -- reflexion de la lumiere de l'objet dessine
      Glmaterialfv (Gl_Front,
                    Gl_Ambient,
                    Blanc_Ambient (1)'Unchecked_Access);
        
      Glmaterialfv (Gl_Front,
                    Gl_Diffuse,
                    Blanc_Diffuse (1)'Unchecked_Access);

      -- Place le cercle a l'endroit demande
      Gltranslatef (Glfloat(Pos_X), Glfloat(Pos_Y), 0.0);

      -- Cree une instance d'un Quadric
      Disque := Glunewquadric;

      -- Dessine une couronne centree a l'origine
      Gludisk(Disque,
              Gldouble(Rayon-(Largueur/2.0)),
              Gldouble(Rayon),
              20,
              2);

      -- On detruit l'instance de l'objet Quadric
      Gludeletequadric(Disque);

      -- On fixe la largueur des traits
      Gllinewidth(Glfloat(Largueur));

      -- On dessine un trait en travers du cercle
      Glbegin(Gl_Line_Strip);
      
        Glvertex3f (Glfloat(Pos_Trait),
                    Glfloat(Pos_Trait),
                    0.0);
                    
        Glvertex3f (Glfloat(-Pos_Trait),
                    Glfloat(-Pos_Trait),
                    0.0);
        
      Glend;
      
      -- On dessine un deuxieme trait en travers du cercle
      Glbegin(Gl_Line_Strip);
      
        Glvertex3f (Glfloat(-Pos_Trait),
                    Glfloat(Pos_Trait),
                    0.0);
                    
        Glvertex3f (Glfloat(Pos_Trait),
                    Glfloat(-Pos_Trait),
                    0.0);
        
      Glend;
      
      -- On retablit le contexte precedant l'execution de la fonction
      Glpopmatrix;
      
    end Cercle_Barre;

    --------------------------------------------------------------------
    --
    -- procedure: Dessine_r
    -- But      : Dessiner, avec la Libarairie Opengl, la lettre R
    --            Cette lettre sera en deux dimension sur le
    --            plan XY (Z = 0)
    --
    -- Entrees  : Pos_X       => Position sur l'axe X ou la lettre
    --                           sera dessine (centre de la lettre)
    --            Pos_Y       => Position sur l'axe Y ou la lettre
    --                           sera dessine (centre de la lettre)
    --            Taille      => Hauteur de la lettre (la largueur
    --                           et l'epaisseur des traits en sera
    --                           deduit
    --
    --------------------------------------------------------------------
    procedure Dessine_R (Pos_X: in Float; Pos_Y: in Float;
                         Taille: in Float) is

    begin
      -- Sauve la matrice "modelview" sur la pile, on la retablira a la fin
      -- de la procedure ainsi les transformations effectuee n'agiront que
      -- sur les objets dessine dans la procedure
      Glpushmatrix;

      -- On specifie la couleur du dessin en determinant les proprietes de
      -- reflexion de la lumiere de l'objet dessine
      Glmaterialfv (Gl_Front,
                    Gl_Ambient,
                    Blanc_Ambient (1)'Unchecked_Access);
        
      Glmaterialfv (Gl_Front,
                    Gl_Diffuse,
                    Blanc_Diffuse (1)'Unchecked_Access);

      -- Place la lettre a l'endroit demande
      Gltranslatef (Glfloat(Pos_X), Glfloat(Pos_Y), 0.0);

      -- On fixe la largueur des traits
      Gllinewidth(Glfloat(Taille/5.0));

      -- On dessine la lettre centree a l'origine
      Glbegin(Gl_Line_Strip);
      
        Glvertex3f(Glfloat(Taille/4.0),
                   Glfloat(-Taille/2.0),
                   0.0);
                   
        Glvertex3f(Glfloat(-Taille/4.0),
                   0.0,
                   0.0);
                   
        Glvertex3f(Glfloat(Taille/4.0),
                   0.0,
                   0.0);
                   
        Glvertex3f(Glfloat(Taille/4.0),
                   Glfloat(Taille/2.0),
                   0.0);
                   
        Glvertex3f(Glfloat(-Taille/4.0),
                   Glfloat(Taille/2.0),
                   0.0);
                   
        Glvertex3f(Glfloat(-Taille/4.0),
                   Glfloat(-Taille/2.0),
                   0.0);
                   
     Glend;
     
     -- On retablit le contexte precedant l'execution de la fonction
     Glpopmatrix;

    end Dessine_R;

    --------------------------------------------------------------------
    --
    -- procedure: Dessine_L
    -- But      : Dessiner, avec la Libarairie Opengl, la lettre L
    --            Cette lettre sera en deux dimension sur le
    --            plan XY (Z = 0)
    --
    -- Entrees  : Pos_X       => Position sur l'axe X ou la lettre
    --                           sera dessine (centre de la lettre)
    --            Pos_Y       => Position sur l'axe Y ou la lettre
    --                           sera dessine (centre de la lettre)
    --            Taille      => Hauteur de la lettre (la largueur
    --                           et l'epaisseur des traits en sera
    --                           deduit
    --
    --------------------------------------------------------------------
    procedure Dessine_L(Pos_X     : in     Float;
                        Pos_Y     : in     Float;
                        Taille    : in     Float)
    is
    begin
      -- Sauve la matrice "modelview" sur la pile, on la retablira a la fin
      -- de la procedure ainsi les transformations effectuee n'agiront que
      -- sur les objets dessine dans la procedure
      Glpushmatrix;

      -- On specifie la couleur du dessin en determinant les proprietes de
      -- reflexion de la lumiere de l'objet dessine
      Glmaterialfv (Gl_Front,
                    Gl_Ambient,
                    Blanc_Ambient (1)'Unchecked_Access);
        
      Glmaterialfv (Gl_Front,
                    Gl_Diffuse,
                    Blanc_Diffuse (1)'Unchecked_Access);

      -- Place la lettre a l'endroit demande
      Gltranslatef (Glfloat(Pos_X), Glfloat(Pos_Y), 0.0);

      -- On fixe la largueur des traits
      Gllinewidth(Glfloat(Taille/5.0));

      -- On dessine la lettre centree a l'origine
      Glbegin(Gl_Line_Strip);
        Glvertex3f(Glfloat(Taille/4.0),
                   Glfloat(-Taille/2.0),
                   0.0);
                   
        Glvertex3f(Glfloat(-Taille/4.0),
                   Glfloat(-Taille/2.0),
                   0.0);
                   
        Glvertex3f(Glfloat(-Taille/4.0),
                   Glfloat(Taille/2.0),
                   0.0);
                   
      Glend;                     
     
       -- On retablit le contexte precedant l'execution de la fonction
      Glpopmatrix;
      
    end Dessine_L;

    --------------------------------------------------------------------
    --
    -- procedure: Dessine_P
    -- But      : Dessiner, avec la Libarairie Opengl, la lettre P
    --            Cette lettre sera en deux dimension sur le
    --            plan XY (Z = 0)
    --
    -- Entrees  : Pos_X       => Position sur l'axe X ou la lettre
    --                           sera dessine (centre de la lettre)
    --            Pos_Y       => Position sur l'axe Y ou la lettre
    --                           sera dessine (centre de la lettre)
    --            Taille      => Hauteur de la lettre (la largueur
    --                           et l'epaisseur des traits en sera
    --                           deduit
    --
    --------------------------------------------------------------------
    procedure Dessine_P(Pos_X   : in     Float;
                        Pos_Y   : in     Float;
                        Taille  : in     Float)
    is
    begin
      -- Sauve la matrice "modelview" sur la pile, on la retablira a la fin
      -- de la procedure ainsi les transformations effectuee n'agiront que
      -- sur les objets dessine dans la procedure
      Glpushmatrix;

      -- On specifie la couleur du dessin en determinant les proprietes de
      -- reflexion de la lumiere de l'objet dessine
      Glmaterialfv (Gl_Front,
                    Gl_Ambient,
                    Blanc_Ambient (1)'Unchecked_Access);
        
      Glmaterialfv (Gl_Front,
                    Gl_Diffuse,
                    Blanc_Diffuse (1)'Unchecked_Access);

      -- Place la lettre a l'endroit demande
      Gltranslatef (Glfloat(Pos_X),Glfloat(Pos_Y), 0.0);

      -- On fixe la largueur des traits
      Gllinewidth(Glfloat(Taille)/5.0);

      -- On dessine la lettre centree a l'origine
      Glbegin(Gl_Line_Strip);
        Glvertex3f(Glfloat(-Taille/4.0),
                   0.0,
                   0.0);
                   
        Glvertex3f(Glfloat(Taille/4.0),
                   0.0,
                   0.0);
                   
        Glvertex3f(Glfloat(Taille/4.0),
                  Glfloat(Taille/2.0),
                  0.0);
                  
        Glvertex3f(Glfloat(-Taille/4.0),
                  Glfloat(Taille/2.0),
                  0.0);
                  
        Glvertex3f(Glfloat(-Taille/4.0),
                  Glfloat(-Taille/2.0),
                   0.0); 
                   
      Glend;

      -- On retablit le contexte precedant l'execution de la fonction
      Glpopmatrix;
     
    end Dessine_P;

  ----------------------------------------------------------------------------
  begin -- Display_Callback
    -- Vide le buffer de couleur (buffer contenant l'image affichee a
    -- l'ecran) et le Z-buffer (buffer contenant pour chaque pixel une
    -- valeur, distance objet -> observateur, utilisee pour supprimer les
    -- faces cachees des objets a dessiner)
    Glclear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
    -- Faut'il afficher les icones ou pas ?
    if Afficher_Icones
    then
      Glloadidentity;
  
      -- Definit un projection orthogonale (sans effet de perspective). Pour
      -- cela on place un matrice identite dans la matrice de projection puis
      -- on retablit la matrice de transformation
      Glmatrixmode (Gl_Projection);
      Glloadidentity;
      Glmatrixmode (Gl_Modelview);
  
      -- Defini le volume de coupage pour une projection orthogonale
      -- (les objets exterieur a ce volume ne seront pas visibles
      Glortho(0.0, Gldouble(Largueur), 0.0, Gldouble(Hauteur), 1.0,-1.0);

      -- On dessine ensuite les icones Double fleche verticale pour
      -- regler la hauteur du point de vue (taille en fonction de la
      -- fenetre)
      Fleche (Largueur/7.0,
              Hauteur/15.0,
              Largueur/20.0,
              Hauteur/6.5,
              Vertical);
  
      -- Double fleche horizontale pour regler la rotation du point
      -- de vue autour du centre de la maquette (taille en fonction de
      -- la fenetre
      Fleche (2.0 *Largueur/7.0,
              Hauteur/15.0,
              Hauteur/20.0,
              Largueur/6.5,
              Horizontal);
  
      -- Rond avec un point au centre pour augmenter la distance
      -- entre le centre de la maquette et le point de vue
      Cercle_Pointe (3.0 * Largueur/7.0,
                     Hauteur/15.0,
                     Largueur/40.0,
                     Largueur/100.0);
  
      -- Rond barre pour diminuer cette meme distance
      Cercle_Barre(4.0 * Largueur/7.0,
                   Hauteur/15.0,
                   Largueur/40.0,
                   Largueur/100.0);
                              
      -- Lettre R ou L pour indiquer et modifier le mode de simulation
      -- (rapide ou lent)
      if Objetpartager.Mode_Rapide
      then
        Dessine_R(5.0 * Largueur/7.0,
                  Hauteur/15.0,
                  Largueur/20.0);
                  
      else
        Dessine_L(5.0 * Largueur/7.0,
                  Hauteur/15.0,
                  Largueur/20.0);
                  
      end if;
  
      -- Lettre P pour fournir la quittance de l'utilisateur
      -- au simulateur lors de l'utilisation en mode pas a pas
      Dessine_P(6.0 * Largueur/7.0,
                Hauteur/15.0,
                Largueur/20.0);
      
    end if;

    -- On definit une projection perspective et un volume de
    -- coupage pour dessiner la maquette elle-meme
    Glmatrixmode (Gl_Projection);
    Glloadidentity;
    Gluperspective(67.4,Gldouble(Largueur)/Gldouble(Hauteur),1.5, 6000.0);

    -- On initialise la matrice de transformation (modelview)
    -- avec une matrice identite
    Glmatrixmode (Gl_Modelview);
    Glloadidentity;

    -- Place l'oeil de l'observateur a la position definie par alpha,
    -- beta et distance
    Glulookat(Gldouble(Sin(Beta, 360.0)*Sin(Alpha, 360.0)*Distance),
              Gldouble(Cos(Beta, 360.0)*Sin(Alpha, 360.0)*Distance),
              Gldouble(Cos(Alpha, 360.0)*Distance),
              0.0, 0.0, 0.0,
              Gldouble(Sin(Beta, 360.0)*Sin(Alpha+90.0, 360.0)*
              Distance),
              Gldouble(Cos(Beta, 360.0)*Sin(Alpha+90.0, 360.0)*
              Distance),
              Gldouble(Cos(Alpha+90.0, 360.0)*Distance));

    Affichermaquette;

    -- Pour accelerer le dessin Opengl utilise un tampon et ainsi accede
    -- moins souvent aux peripheriques. Alors pour etre sur de tout afficher
    -- on vide le tampon
    Glflush;

    -- On change le buffer d'affichage, dessine le buffer que l'on vient
    -- de remplir (c'est la technique du double buffering pour accelerer
    -- l'affichage on dessine dans un buffer puis on l'affiche d'un coup)
    glutSwapBuffers;
    
  end Display_Callback;
  
  -----------------------------------------------------------------------------
  -- Procedure Reshape_Callback
  -----------------------------------------------------------------------------
  -- But : Procedure appelee lors d'un redimensionnement de la fenetre
  -----------------------------------------------------------------------------
  -- in     : Width   / Integer  (Largeur de la fenetre)
  -- in     : Height  / Integer  (Hauteur de la fenetre)
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Reshape_Callback ( Width   : in     Integer;
                               Height  : in     Integer )
  is
    
    -- Dimension du volume a afficher
    View_Range : glDouble := 100.0;
    
    -- Dimensions de la fenetre
    Win_Width  : glDouble := glDouble( Width );
    Win_Height : glDouble := glDouble( Height );
    
  begin
    -- Afin d'eviter une division par zero
    if Win_Height = 0.0 then
      Win_Height := 1.0;
    end if;
    
    -- Zone d'affichage sur toute la fenetre
    GlViewPort (0, 0, glSizei(Win_Width), glSizei(Win_Height));

    -- On affecte la largueur de la fenetre
    -- a une variable globale a la tache
    Largueur:= Float(Width);

    -- On affecte la largueur de la fenetre
    -- a une variable globale a la tache
    Hauteur:= Float(Height);

    -- Remise a zero du systeme de projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    
    -- Definition de la projection orthogonale
    if Width <= Height then
    
      -- Definition du volume de decoupe
      glOrtho(
        -View_Range, View_Range,
        -View_Range*Win_Height/Win_Width, View_Range*Win_Height/Win_Width,
        -View_Range*10.0, View_Range*10.0 );
    
    else
    
      -- Definition du volume de decoupe
      glOrtho(
        -View_Range*Win_Width/Win_Height, View_Range*Win_Width/Win_Height,
        -View_Range, View_Range,
        -View_Range*10.0, View_Range*10.0 );
    
    end if;   -- Width <= Height
    
    -- Remise a zero du systeme de coordonnees
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;

    -- L'affichage suivant n'utilisera pas le buffer mais redessinera tout
    Reinitialiseraffichage;

  end Reshape_Callback;
  
  -----------------------------------------------------------------------------
  -- Procedure Keyboard_Callback
  -----------------------------------------------------------------------------
  -- But : Procedure appelee lors de l'appui sur une touche
  -----------------------------------------------------------------------------
  -- in     : Key  / Interfaces.C.Unsigned_Char  (Caractere appuye)
  -- in     : X    / Integer            (Position horizontale du curseur)
  -- in     : Y    / Integer            (Position verticale du curseur)
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Keyboard_Callback(Key : in Interfaces.C.Unsigned_Char; 
                              X, Y : in Integer)
  is
  begin -- Keyboard_Callback
    -- Le comportement change selon la touche appuyee
    case Key is

      -- L'utilisateur a appuye sur Q, on quitte le programme
      when Character'Pos('Q') | Character'Pos('q') =>
        GNAT.OS_Lib.OS_Exit (0);

      -- L'utilisateur a appuye sur Z, remise a zero de l'affichage
      when Character'Pos('Z') | Character'Pos('z') =>
        Alpha     := 0.0;
        Beta      := 0.0;
        Distance  := 1750.0;

      -- L'utilisateur a appuye sur I, (des)affichage des icones
      when Character'Pos('I') | Character'Pos('i') =>
        Afficher_Icones := not Afficher_Icones;

      -- L'utilisateur a appuye sur R, passage en mode d'avance rapide
      when Character'Pos('R') | Character'Pos('r') =>
        Objetpartager.Mettre_Mode_Rapide;

      -- L'utilisateur a appuye sur L, passage en mode d'avance lent
      when Character'Pos('L') | Character'Pos('l') =>
        Objetpartager.Mettre_Mode_Lent;

      -- L'utilisateur a appuye sur P, mettre l'execution en pause
      when Character'Pos('P') | Character'Pos('p') =>
        -- Selon le mode de fonctionement l'icone "P" a plusieurs fonction
        if Modecontinu
        then
          -- On arrete ou on redemarre la simulation (bouton pause) en mode
          -- continu
          if Objetpartager.Mode_Pause
          then
             Objetpartager.Enlever_Pause;
             
          else
             Objetpartager.Mettre_Pause;
             
          end if;
          
        else
          -- On indique au simulateur la demande de quittance de
          -- l'utilisateur en mode Pas a pas
          Objetpartager.Quittance;
          
        end if;

      -- L'utilisateur veut augmenter le zoom
      when Character'Pos('+') =>
        -- Si on n'est pas trop pres de la maquette
        if Distance > Distance_Min
        then
          -- On diminue la distance
          Distance:= Distance - 250.0;
      
          -- On demande un affichage complet car l'image de la
          -- maquette va changer
          Reinitialiseraffichage;
      
        end if;
              
      -- L'utilisateur veut diminuer le zoom
      when Character'Pos('-') =>
        -- Si on n'est pas trop loin de la maquette
        if Distance < Distance_Max
        then
          -- On augmente la distance
          Distance := Distance + 250.0;
      
          -- On demande un affichage complet car l'image de la
          -- maquette va changer
          Reinitialiseraffichage;
        
        end if;
      
      -- On ignore toutes les autres touches
      when others => null;

    end case;   -- Key
    -- Demande le reaffichage de la fenetre
    Reinitialiseraffichage;

  end Keyboard_Callback;
  
  -----------------------------------------------------------------------------
  -- Procedure Special_Key_Callback
  -----------------------------------------------------------------------------
  -- But : Procedure appelee lors de l'appui sur une touche speciale
  --       (F1 a F12, touches flechees, ...)
  -----------------------------------------------------------------------------
  -- in     : Key  / Integer            (Code designant la touche enfoncee)
  -- in     : X    / Integer            (Position horizontale du curseur)
  -- in     : Y    / Integer            (Position verticale du curseur)
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Special_Key_Callback(Key, X, Y : in Integer)
  is
  begin -- Special_Key_Callback
    -- Comportement different selon la touche
    case Key is

      -- L'utilisateur a appuye sur la fleche vers le haut
      when GLUT_KEY_UP =>
        -- Si on est pas a la limite
        if Alpha < Alpha_Max
        then
          -- On augmente Alpha
          Alpha := Alpha + 15.0;
      
          -- On demande un affichage complet car l'image de la
          -- maquette va changer
          Reinitialiseraffichage;
      
        end if;
      -- L'utilisateur a appuye sur la fleche vers le bas
      when GLUT_KEY_DOWN =>
        -- Si on est pas a la limite
        if Alpha > Alpha_Min
        then
          -- On diminue Alpha
          Alpha := Alpha - 15.0;
          
          -- Demande le reaffichage de la fenetre
          Reinitialiseraffichage;
        
        end if;

              
      -- L'utilisateur a appuye sur la fleche vers la gauche
      when GLUT_KEY_LEFT =>
        Beta := Beta + 15.0;
        -- Demande le reaffichage de la fenetre
        Reinitialiseraffichage;
        
      -- L'utilisateur a appuye sur la fleche vers la droite
      when GLUT_KEY_RIGHT =>
        Beta := Beta - 15.0;
        -- Demande le reaffichage de la fenetre
        Reinitialiseraffichage;
        
      -- On ignore toutes les autres touches speciales
      when others => null;

    end case;
    
  end Special_Key_Callback;
  
  -----------------------------------------------------------------------------
  -- Procedure Mouse_Callback
  -----------------------------------------------------------------------------
  -- But : Procedure appelee lors de l'utilisation des boutons de la souris
  -----------------------------------------------------------------------------
  -- in     : Button  / Integer            (Bouton appuye)
  -- in     : State   / Integer            (Etat de reaction)
  -- in     : X       / Integer            (Position horizontale du curseur)
  -- in     : Y       / Integer            (Position verticale du curseur)
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Mouse_Callback (Button  : in     Integer;
                            State   : in     Integer;
                            X, Y    : in     Integer)
  is
    X_Coord : Float := Float(X);  -- Coordonnees du pointeur souris
    Y_Coord : Float := Float(Y);  -- lors de l'appui sur un bouton
  
  begin -- Mouse_Callback
    -- Bloquer les reactions si les icines ne sont pas affichees
    if Afficher_Icones
    then
      case Button is
        -- L'utilisateur appuye sur le bouton gauche de la souris
        when GLUT_LEFT_BUTTON =>
          case State is
            when GLUT_DOWN =>
              -- Si l'utilisateur a appuye sur la fleche du haut de la
              -- fleche double verticale
              if (X_Coord in Largueur/7.0-Largueur/40.0 ..
                             Largueur/7.0+Largueur/40.0)
                and
                 (Y_Coord in Hauteur-(Hauteur/15.0+Hauteur/13.5) ..
                             Hauteur-(Hauteur/15.0+Hauteur/40.0))
              then
                -- Si on est pas a la limite
                if Alpha < Alpha_Max
                then
                  -- On augmente Alpha
                  Alpha := Alpha + 15.0;
        
                  -- On demande un affichage complet car l'image de la
                  -- maquette va changer
                  Reinitialiseraffichage;
        
                end if;
        
              -- Si l'utilisateur a appuye sur la fleche du bas de la
              -- fleche double verticale
              elsif (X_Coord in Largueur/7.0-Largueur/40.0 ..
                                Largueur/7.0+Largueur/40.0)
                and (Y_Coord in Hauteur-(Hauteur/15.0-Hauteur/40.0) ..
                                Hauteur-(Hauteur/15.0-Hauteur/13.5))
              then
                -- Si on est pas a la limite
                if Alpha > Alpha_Min
                then
                  -- On diminue Alpha
                  Alpha := Alpha - 15.0;
        
                  -- On demande un affichage complet
                  Reinitialiseraffichage;
                  
                end if;
                
              -- Si l'utilisateur a appuye sur la fleche de gauche de la
              -- fleche double horizontal
              elsif (X_Coord in 2.0*Largueur/7.0-Largueur/13.5 ..
                                2.0*Largueur/7.0-Largueur/40.0)
                and (Y_Coord in Hauteur-(Hauteur/15.0+Hauteur/40.0) ..
                                Hauteur-(Hauteur/15.0-Hauteur/40.0))
              then
                -- Si on a effectue un tour complet
                -- on reinitialise l'angle pour ne
                -- pas avoir une valeur trop elevee
                if Beta < 360.0
                then
                  -- On augmente Beta
                  Beta:= Beta + 15.0;
                  
                else
                  Beta:= 15.0;
                  
                end if;
        
                -- On demande un affichage complet car'image de la
                -- maquette va changer
                Reinitialiseraffichage;
        
              -- Si l'utilisateur a appuye sur la fleche de droite de la
              -- fleche double horizontal
              elsif (X_Coord in 2.0*Largueur/7.0+Largueur/40.0 ..
                                2.0*Largueur/7.0+Largueur/13.5)
                and (Y_Coord in Hauteur-(Hauteur/15.0+Hauteur/40.0) ..
                                Hauteur-(Hauteur/15.0-Hauteur/40.0))
              then
                -- Si on a effectue un tour complet on reinitialise l'angle
                -- pour ne pas avoir une valeur trop elevee
                if Beta > -360.0
                then
                  -- On augmente Beta
                  Beta:= Beta - 15.0;
                  
                else
                  Beta:= -15.0;
                  
                end if;
                
                -- On demande un affichage complet car l'image de la maquette
                -- va changer
                Reinitialiseraffichage;
        
              -- Si l'utilisateur a appuye sur le rond avec un point au centre
              elsif (X_Coord in 3.0*Largueur/7.0-Largueur/40.0 ..
                                3.0*Largueur/7.0+Largueur/40.0)
                and (Y_Coord in Hauteur-(Hauteur/15.0+Largueur/40.0) ..
                                Hauteur-(Hauteur/15.0-Largueur/40.0))
              then
                -- Si on n'est pas trop loin de la maquette
                if Distance < Distance_Max
                then
                  -- On augmente la distance
                  Distance := Distance + 250.0;
        
                  -- On demande un affichage complet car l'image de la
                  -- maquette va changer
                  Reinitialiseraffichage;
        
                end if;
                
              -- Si l'utilisateur a appuye sur le rond barre
              elsif (X_Coord in 4.0*Largueur/7.0-Largueur/40.0 ..
                                4.0*Largueur/7.0+Largueur/40.0)
                and (Y_Coord in Hauteur-(Hauteur/15.0+Largueur/40.0) ..
                                Hauteur-(Hauteur/15.0-Largueur/40.0))
              then
                -- Si on n'est pas trop pres de la maquette
                if Distance > Distance_Min
                then
                  -- On diminue la distance
                  Distance:= Distance - 250.0;
        
                  -- On demande un affichage complet car l'image de la
                  -- maquette va changer
                  Reinitialiseraffichage;
        
                end if;
                
              -- Si l'utilisateur appuye sur le R ou le L (selon le mode)
              elsif (X_Coord in 5.0*Largueur/7.0-Largueur/40.0 ..
                                5.0*Largueur/7.0+Largueur/40.0)
                and (Y_Coord in Hauteur-(Hauteur/15.0+Largueur/40.0) ..
                                Hauteur-(Hauteur/15.0-Largueur/40.0))
              then
                -- On active ou on desactive le mode de simulation rapide
                if Objetpartager.Mode_Rapide
                then
                  Objetpartager.Mettre_Mode_Lent;
                  
                else
                  Objetpartager.Mettre_Mode_Rapide;
                  
                end if;
        
                -- On demande un affichage complet car l'image de la
                -- maquette va changer
                Reinitialiseraffichage;
        
              -- Si l'utilisateur a appuye sur le P
              elsif (X_Coord in 6.0*Largueur/7.0-Largueur/40.0 ..
                                6.0*Largueur/7.0+Largueur/40.0)
                and (Y_Coord in Hauteur-(Hauteur/15.0+Largueur/40.0) ..
                                Hauteur-(Hauteur/15.0-Largueur/40.0))
              then
                -- Selon le mode de fonctionement l'icone "P" a plusieurs
                -- fonction
                if Modecontinu
                then
                  -- On arrete ou on redemarre la simulation (bouton pause)
                  -- en mode continu
                  if Objetpartager.Mode_Pause
                  then
                     Objetpartager.Enlever_Pause;
                     
                  else
                     Objetpartager.Mettre_Pause;
                     
                  end if;
                  
                else
                  -- On indique au simulateur la demande de quittance de
                  -- l'utilisateur en mode Pas a pas
                  Objetpartager.Quittance;
                  
                end if;
        
              end if;
  
            when others => null;
            
          end case;
        
        when others => null;
      
      end case;
    
    end if;
      
  end Mouse_Callback;
  
  -----------------------------------------------------------------------------
  -- Procedure Idle_Callback
  -----------------------------------------------------------------------------
  -- But : Procedure appelee lorsqu'il n'y a rien d'autre a faire
  -----------------------------------------------------------------------------
  -- in     : 
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Idle_Callback
  is
  begin -- Idle_Callback
    -- On verifie si la maquette a ete modifiee et donc si elle
    -- a besoin d'etre affichee
    select
      Objetpartager.Besoinafficher;
      -- On indique que la fenetre courante est la fenetre de simulation
      glutSetWindow (Simulator_Window);
      -- On appelle la fonction qui va la dessiner
      Display_Callback;
      -- On annonce que l'affichage est termine donc que la simulation
      -- peut reprendre
      Objetpartager.Affichagetermine;
      
      select
        Objetpartager.MettreAJourLegende;
        -- On indique que la fenetre courante est la fenetre de legende
        glutSetWindow (Legend_Window);
        -- On appelle la fonction qui va la dessiner
        Legend_Display_Callback;
      else
        delay 0.2;
      end select;
    
    -- Si un affichage n'est pas necessaire a ce moment on sort
    -- de la procedure pour que les autres fonctions (Mouse, Display
    -- Reshape) puissent etre appelle si besoin est.
    else
      -- Pour eviter l'utilisation de toutes les ressources de la machine.
      delay 0.2;
      
    end select;
    
  end Idle_Callback;
  
  -----------------------------------------------------------------------------
  -- Procedure Menu
  -----------------------------------------------------------------------------
  -- But : Procedure lors de l'activation d'une entree du menu principal
  -----------------------------------------------------------------------------
  -- in     : Value  /  Integer         (Entree du menu selectionnee)
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Menu ( Value : Integer )
  is
  begin   -- Menu

    -- Entree du menu activee
    case Value is

      -- Cet entree correspond a la remise a zero
      -- des valeurs modifiables par l'utilisateur (sauf l'etage courant)
      when 1 =>
        Alpha     := 0.0;
        Beta      := 0.0;
        Distance  := 1750.0;

      -- Mise en pause de l'execution du programme
      when 100 =>
        -- Selon le mode de fonctionement l'icone "P" a plusieurs fonction
        if Modecontinu
        then
          -- On arrete ou on redemarre la simulation (bouton pause) en mode
          -- continu
          if Objetpartager.Mode_Pause
          then
             Objetpartager.Enlever_Pause;
             
          else
             Objetpartager.Mettre_Pause;
             
          end if;
          
        else
          -- On indique au simulateur la demande de quittance de
          -- l'utilisateur en mode Pas a pas
          Objetpartager.Quittance;
          
        end if;

      -- L'utilisateur a decide de quitter le programme
      when 999 =>
        GNAT.OS_Lib.OS_Exit (0);

      -- Il n'y a pas d'autres valeurs definies
      when others => null;

    end case;   -- Value

    -- Demande le reaffichage de la fenetre
    Reinitialiseraffichage;

  end Menu;

  -----------------------------------------------------------------------------
  -- Procedure Sub_Menu_Rotate
  -----------------------------------------------------------------------------
  -- But : Procedure lors de l'activation d'une entree du sous-menu
  --       dedie a la rotation
  -----------------------------------------------------------------------------
  -- in     : Value  /  Integer         (Entree du sous-menu selectionnee)
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Sub_Menu_Rotate ( Value : in     Integer )
  is
    procedure Rotate_Alpha ( Increment : in     Float )
    is
    begin -- Rotate_Alpha
      -- En fonction de l'increment, verfifier si on ne depasse pas
      -- les valeurs Alpha_Max ...
      if Increment > 0.0 and then Alpha <= Alpha_Max - Increment
      then
        Alpha := Alpha + Increment;
        
      -- ... ou Alpha_Min
      elsif Increment < 0.0 and then Alpha >= Alpha_Min - Increment
      then
        Alpha := Alpha + Increment;
      
      end if;
    
    end Rotate_Alpha;
    
  begin   -- Sub_Menu_Rotate
    
    -- Entree du sous-menu activee
    case Value is

      -- Rotation autour de X, divers increments
      when  0 => Beta := Beta -180.0;
      when  1 => Beta := Beta - 90.0;
      when  2 => Beta := Beta - 45.0;
      when  3 => Beta := Beta - 30.0;
      when  4 => Beta := Beta - 15.0;
      when  5 => Beta := Beta + 15.0;
      when  6 => Beta := Beta + 30.0;
      when  7 => Beta := Beta + 45.0;
      when  8 => Beta := Beta + 90.0;
      when  9 => Beta := Beta +180.0;

      -- Rotation autour de Y, divers increments
      when 10 => Rotate_Alpha (-60.0);
      when 11 => Rotate_Alpha (-45.0);
      when 12 => Rotate_Alpha (-30.0);
      when 13 => Rotate_Alpha (-10.0);
      when 14 => Rotate_Alpha (- 5.0);
      when 15 => Rotate_Alpha (  5.0);
      when 16 => Rotate_Alpha ( 10.0);
      when 17 => Rotate_Alpha ( 30.0);
      when 18 => Rotate_Alpha ( 45.0);
      when 19 => Rotate_Alpha ( 60.0);

      -- Il n'y a pas d'autres valeurs definies
      when others => null;

    end case;   -- Value

    -- Demande le reaffichage de la fenetre
    Reinitialiseraffichage;

  end Sub_Menu_Rotate;

  -----------------------------------------------------------------------------
  -- Procedure Sub_Menu_Display
  -----------------------------------------------------------------------------
  -- But : Procedure lors de l'activation d'une entree du sous-menu
  --       dedie aux parametres d'affichage
  -----------------------------------------------------------------------------
  -- in     : Value  /  Integer         (Entree du sous-menu selectionnee)
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Sub_Menu_Display(Value : Integer)
  is
  begin -- Sub_Menu_Display

    -- Entree du sous-menu activee
    case Value is

      -- Changement de zoom, divers increments
      when 0 => 
        -- Si on n'est pas trop pres de la maquette
        if Distance > Distance_Min + 500.0
        then
          -- On diminue la distance
          Distance:= Distance - 500.0;
      
        end if;
              
      when 1 =>
        -- Si on n'est pas trop pres de la maquette
        if Distance > Distance_Min + 250.0
        then
          -- On diminue la distance
          Distance:= Distance - 250.0;
      
        end if;
              
      when 2 =>
        -- Si on n'est pas trop loin de la maquette
        if Distance < Distance_Max - 250.0
        then
          -- On augmente la distance
          Distance := Distance + 250.0;
      
        end if;
      
      when 3 =>
        -- Si on n'est pas trop loin de la maquette
        if Distance < Distance_Max - 500.0
        then
          -- On augmente la distance
          Distance := Distance + 500.0;
      
        end if;
      
      -- Il n'y a pas d'autres valeurs definies
      when others => null;

    end case;   -- Value

    -- Demande le reaffichage de la fenetre
    Reinitialiseraffichage;

  end Sub_Menu_Display;

  -----------------------------------------------------------------------------
  -- Procedure Sub_Menu_Mode
  -----------------------------------------------------------------------------
  -- But : Procedure lors de l'activation d'une entree du sous-menu
  --       dedie au mode d'avance de la locomotive
  -----------------------------------------------------------------------------
  -- in     : Value  /  Integer         (Entree du sous-menu selectionnee)
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Sub_Menu_Mode(Value : Integer)
  is
  begin -- Sub_Menu_Mode

    -- Entree du sous-menu activee
    case Value is

      -- Changement de zoom, divers increments
      when  0 => Objetpartager.Mettre_Mode_Lent;
      when  1 => Objetpartager.Mettre_Mode_Rapide;

      -- Il n'y a pas d'autres valeurs definies
      when others => null;

    end case;   -- Value

    -- Demande le reaffichage de la fenetre
    Reinitialiseraffichage;

  end Sub_Menu_Mode;

  -----------------------------------------------------------------------------
  -- Procedure Sub_Menu_Icones
  -----------------------------------------------------------------------------
  -- But : Procedure lors de l'activation d'une entree du sous-menu
  --       dedie a l'affichage des icones de controle
  -----------------------------------------------------------------------------
  -- in     : Value  /  Integer         (Entree du sous-menu selectionnee)
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Sub_Menu_Icones(Value : Integer)
  is
  begin -- Sub_Menu_Icones

    -- Entree du sous-menu activee
    case Value is

      -- Changement de zoom, divers increments
      when  0 => Afficher_Icones := True;
      when  1 => Afficher_Icones := False;

      -- Il n'y a pas d'autres valeurs definies
      when others => null;

    end case;   -- Value

    -- Demande le reaffichage de la fenetre
    Reinitialiseraffichage;

  end Sub_Menu_Icones;
  
  -----------------------------------------------------------------------------
  -- Procedure Legend_Init_Scene                                                    --
  -----------------------------------------------------------------------------
  -- But : Procedure initialisant tous les parametres OpenGL
  -----------------------------------------------------------------------------
  -- in     : 
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Legend_Init_Scene
  is
    -- type utilise pour specifier la position d'une source de lumiere
    type Glfloat_4 is array (1 .. 4) of aliased Glfloat;

    -- Definit la couleur de la source de lumiere pour sa composante ambiante
    Ambient        : P_Couleur.T_Couleur_Rvba := ( 0.5, 0.5, 0.5, 1.0 );

    -- Definit la couleur de la source de lumiere pour sa composante diffuse
    Diffuse        : P_Couleur.T_Couleur_Rvba := ( 0.5, 0.5, 0.5, 1.0 );

    -- Definit la position de la source de lumiere
    Position       : Glfloat_4                := ( 0.0, 0.0, 10.0, 0.0 );

  begin -- Legend_Init_Scene
    -- Deffinit le model de coloration les objets seront colore de maniere
    -- uniforme
    Glshademodel (GL_FLAT);

    -- Met l'illumination en fonction
    Glenable (Gl_Lighting);

    -- Definit les caracteristique de la source de lumiere zero
    Gllightfv (Gl_Light1, Gl_Ambient, Ambient(1)'Unchecked_Access);
    Gllightfv (Gl_Light1, Gl_Diffuse, Diffuse(1)'Unchecked_Access);
    Gllightfv (Gl_Light1, Gl_Position, Position(1)'Unchecked_Access);

    -- Definit une illumination d'ambiance la scene est illuminee partout de
    -- maniere egale
    Gllightmodelfv (Gl_Light_Model_Ambient,
                    Ambient(1)'Unchecked_Access);

    -- Met en fonction la source de lumiere zero
    Glenable (Gl_Light1);

    -- Definit la couleur de fond
    Glclearcolor (0.0, 0.0, 0.0, 0.0);

  end Legend_Init_Scene;
  
  
  -----------------------------------------------------------------------------
  -- Procedure Legend_Display_Callback                                              --
  -----------------------------------------------------------------------------
  -- But : Procedure de callback pour l'affichage de la legende
  --       Dessiner, avec la Libarairie Opengl, la fenetre
  --       graphique. Cette fonction sera automatiquement appellee
  --       lorsque la fenetre graphique devra etre rafraichie
  --       (par exemple si on place une fenetre devant ou lorsque
  --        ouvre la fenetre)
  --     
  -- Remarque : La procedure a les parametres exige pour que l'on
  --            puisse la specifier comme fonction appelable
  --            automatiquement par un mecanisme de callback
  --
  -----------------------------------------------------------------------------
  -- in     :
  --    out :
  -- in out :
  -----------------------------------------------------------------------------
  procedure Legend_Display_Callback
  is
  begin -- Legend_Display_Callback
    -- Vide le buffer de couleur (buffer contenant l'image affichee a
    -- l'ecran)
    Glclear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
    
    -- On initialise la matrice de transformation (modelview)
    -- avec une matrice identite
    Glmatrixmode (Gl_Modelview);
    Glloadidentity;
    
    glOrtho ( 0.0, glDouble(glutGet(GLUT_WINDOW_WIDTH)) / 10.0,
             glDouble(glutGet(GLUT_WINDOW_HEIGHT)) / 10.0, 0.0,
             -1.0, 1.0);

    -- 
    if AgrandirFenetre
    then
      AgrandirFenetre := False;
      LegWin_Height := LegWin_Height + 20;
      glutReshapeWindow (LegWin_Width, LegWin_Height);
    
    end if;
    
    -- Affichage de la legende
    AfficherLegende;
    
    -- Pour accelerer le dessin Opengl utilise un tampon et ainsi accede
    -- moins souvent aux peripheriques. Alors pour etre sur de tout afficher
    -- on vide le tampon
    Glflush;

    -- On change le buffer d'affichage, dessine le buffer que l'on vient
    -- de remplir (c'est la technique du double buffering pour accelerer
    -- l'affichage on dessine dans un buffer puis on l'affiche d'un coup)
    glutSwapBuffers;
    
  end Legend_Display_Callback;
  
end P_Maquette.Display.OpenGL_Callback;