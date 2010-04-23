------------------------------------------------------------------------------
--
-- Nom du fichier     : P_Maquette-Display.adb
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
-- But                : Module realisant l'affichage a l'ecran
--                      du simulateur de maquette de trains miniatures.
--
--                      Les sous-modules le constituant sont:
--
--
--                      La tache "fenetre" qui cree et gere la fenetre
--                      d'affichage
--
-- Modules appeles    : Glut, Win32.Gl, Win32.Glu, Interfaces.C.Strings,
--                      P_Maquette.display.opengl_callback, P_Afficher,
--                      P_Messages
--
-- Materiel
-- particulier        : Les dll "Glut32.dll", "OpenGl32.dll" et "Glu32.dll"
--                      doivent etre dans le repertoire systeme de Windows
--
------------------------------------------------------------------------------

-- Appel de la librairie GLUT
with Glut;
-- Appel de la librairie OpenGl
with Gl;
-- Appel de la librairie d'utilitaires OpenGL
with Glu;
-- Appel de la librairie d'interfacage avec le C
with Interfaces.C.Strings;
--
with P_Maquette.display.opengl_callback;
use P_Maquette.display.opengl_callback;

--
with P_Messages ; use P_Messages;

--
with P_Afficher;

package body P_Maquette.Display is
  -- Utilisation de la librairie OpenGL Utility Toolkit
  use Glut;
  -- Utilisation de la librairie OpenGL
  use Gl;
  -- Utilisation de la librairie OpenGL Utilities
  use Glu;

  use Interfaces.C;

  -- Type pointeur sur un caractere (Chaines a la C)
  type Chars_Ptr_Ptr is access Interfaces.C.Strings.Chars_Ptr;

  -- Utilisation d'un pragma de GNAT pour les arguments
  -- de la ligne de commande comme en C
  argc : aliased Integer;
  pragma Import (C, argc, "gnat_argc");

  -- Utilisation d'un pragma de GNAT pour les arguments
  -- de la ligne de commande comme en C
  argv : Chars_Ptr_Ptr;
  pragma Import (C, argv, "gnat_argv");

  -----------------------------------------------------------------------------
  -- Tache  : Fenetre
  -- But    : Tache qui cree et gere la fenetre graphique.
  --          Elle cree un fenetre a l'aide de la librairie GLUT puis
  --          elle specifie les procedures (callback) qui seront
  --          automatiquement appele lors de manipulation de la
  --          fenetre graphique par l'utilisateur.
  --
  --          Display_Callback      : Est appele lorsqu'un rafraichissement de
  --                                  la fenetre est necessaire (creation,
  --                                  lorsque elle revient en premier plan ou
  --                                  apres l'execution de la procedure "mouse"
  --          Reshape_Callback      : Est appele lorsque la fenetre  graphique
  --                                  a changer de taille (modification manuelle
  --                                  ou ouverture de la fenetre)
  --          Mouse_Callback        : Est appele lorsque l'utilisateur clique
  --                                  dans la fenetre graphique
  --          Keyboard_Callback     : Est appele lorsque l'utilsateur tappe
  --                                  une touche normale (lettres ou chiffres)
  --                                  du clavier
  --          Special_Key_Callback  : Est appele lorsque l'utilsateur tappe
  --                                  une touche speciale (fleches ou fonctions)
  --                                  du clavier
  --          Idle_Callback         : Est appele chaque fois qu'aucune des
  --                                  autres ne doit etre appelee.
  --
  --
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Procedure Display_Simulator
  -----------------------------------------------------------------------------
  -- But : Affichage du simulateur de trains miniatures 3D
  -----------------------------------------------------------------------------
  -- in     :
  --    out :
  -- in out :
  -----------------------------------------------------------------------------
  procedure Display_Simulator is
    ---------------------------------------------------------------------------
    -- Procedure Create_Menus
    ---------------------------------------------------------------------------
    -- But : Creation des menus qui seront proposes a l'utilisateur.
    ---------------------------------------------------------------------------
    -- in     :
    --    out :
    -- in out :
    ---------------------------------------------------------------------------
    procedure Create_Menus
    is

      -- Identificateur du menu principal
      Menu_Id       : Integer;
      -- Identificateurs des sous-menus
      -- Sous-menu pour la rotation de la maquette
      SM_Rotate_Id  : Integer;
      -- Sous-menu pour l'inclinaison de la maquette
      SM_Incline_Id : Integer;
      -- Sous-menu pour le zoom
      SM_Zoom_Id    : Integer;
      -- Sous_menu pour le mode d'avance
      SM_Mode_Id    : Integer;
      -- Sous-menu pour l'affichage des icones
      SM_Icones_Id  : Integer;

    begin   -- Create_Menus

      -- Creation du sous-menu de rotation de la maquette
      -- et enregistrement de la fonction de callback
      SM_Rotate_Id := glutCreateMenu(Sub_Menu_Rotate'access);
      -- Ajout des entrees du sous-menu
      glutAddMenuEntry("Rotation -180",  0);
      glutAddMenuEntry("Rotation - 90",  1);
      glutAddMenuEntry("Rotation - 45",  2);
      glutAddMenuEntry("Rotation - 30",  3);
      glutAddMenuEntry("Rotation - 15",  4);
      glutAddMenuEntry("Rotation   15",  5);
      glutAddMenuEntry("Rotation   30",  6);
      glutAddMenuEntry("Rotation   45",  7);
      glutAddMenuEntry("Rotation   90",  8);
      glutAddMenuEntry("Rotation  180",  9);

      -- Creation du sous-menu de rotation autour de Y
      -- et enregistrement de la fonction de callback
      SM_Incline_Id := glutCreateMenu(Sub_Menu_Rotate'access);
      -- Ajout des entrees du sous-menu
      glutAddMenuEntry("Inclinaison -60", 10);
      glutAddMenuEntry("Inclinaison -45", 11);
      glutAddMenuEntry("Inclinaison -30", 12);
      glutAddMenuEntry("Inclinaison -10", 13);
      glutAddMenuEntry("Inclinaison  -5", 14);
      glutAddMenuEntry("Inclinaison   5", 15);
      glutAddMenuEntry("Inclinaison  10", 16);
      glutAddMenuEntry("Inclinaison  30", 17);
      glutAddMenuEntry("Inclinaison  45", 18);
      glutAddMenuEntry("Inclinaison  60", 19);

      -- Creation du sous-menu pour zoomer
      -- et enregistrement de la fonction de callback
      SM_Zoom_Id := glutCreateMenu(Sub_Menu_Display'access);
      -- Ajout des entrees du sous-menu
      glutAddMenuEntry("Zoom In x2" , 0);
      glutAddMenuEntry("Zoom In"    , 1);
      glutAddMenuEntry("Zoom Out"   , 2);
      glutAddMenuEntry("Zoom Out x2", 3);

      -- Creation du sous-menu pour le choix du mode d'avance
      -- et enregistrement de la fonction de callback
      SM_Mode_Id := glutCreateMenu(Sub_Menu_Mode'access);
      -- Ajout des entrees du sous-menu
      glutAddMenuEntry("Lent", 0);
      glutAddMenuEntry("Rapide", 1);

      -- Creation du sous-menu pour l'affichage des icones
      -- et enregistrement de la fonction de callback
      SM_Icones_Id := glutCreateMenu(Sub_Menu_Icones'access);
      -- Ajout des entrees du sous-menu
      glutAddMenuEntry("Afficher", 0);
      glutAddMenuEntry("Ne pas afficher", 1);

      -- Creation du menu principal
      Menu_Id := glutCreateMenu(Menu'access);
      -- Ajout des sous-menus du menu
      glutAddSubMenu  ("Rotation de la maquette",         SM_Rotate_Id);
      glutAddSubMenu  ("Inclinaison de la maquette",      SM_Incline_Id);
      glutAddSubMenu  ("Zoom",                            SM_Zoom_Id);
      glutAddSubMenu  ("Mode d'avance",                   SM_Mode_Id);
      glutAddSubMenu  ("Icones de controle",              SM_Icones_Id);
      glutAddMenuEntry("Pause",                           100);
      glutAddMenuEntry("Affichage d'origine",             1);
      glutAddMenuEntry("Quitter",                         999);

      -- Finalement, on attache le menu au clic droit de la souris
      glutAttachMenu(GLUT_RIGHT_BUTTON);

    end Create_Menus;

  begin -- Display_Simulator

    -- Initialisation de la librairie Glut
    glutInit(argc'access, argv);

    -- Position et taille de depart de la fenetre d'affichage
    glutInitWindowPosition(0, 0);
    glutInitWindowSize(SimWin_Width, SimWin_Height);

    -- Initialisation du mode d'affichage
    -- Utilisation d'un affichage RGBA, double buffering et profondeur
    glutInitDisplayMode(GLUT_DOUBLE or GLUT_RGB or GLUT_DEPTH);

    -- Creation de la fenetre
    Simulator_Window := glutCreateWindow(P_Messages.Titre);

    -- Enregistrement des fonctions de Callback
    -- Affichage
    glutDisplayFunc(Display_Callback'access);
    -- Redimensionnement de la fenetre
    glutReshapeFunc(Reshape_Callback'access);
    -- Utilisation de la souris et des icones de controle
    glutMouseFunc(Mouse_Callback'access);
    -- Appui sur les touches "classiques" du clavier
    glutKeyboardFunc(Keyboard_Callback'access);
    -- Appui sur des touches speciales du clavier
    glutSpecialFunc(Special_Key_Callback'access);
    -- Processus de fond
    glutIdleFunc(Idle_Callback'access);

    -- Definition des menus associes a la souris
    Create_Menus;

    -- On initialise l'illumination
    -- et la supression des faces
    -- cachee
    Init_Scene;

      -- Position et taille de depart de la fenetre d'affichage
      glutInitWindowPosition(700, 0);
      glutInitWindowSize(LegWin_Width, LegWin_Height);

      -- Creation de la fenetre
      Legend_Window := glutCreateWindow(P_Messages.Titre_Legende);

      -- Affichage
      glutDisplayFunc(Legend_Display_Callback'access);
      -- On initialise l'illumination
      -- et la supression des faces
      -- cachee
      Legend_Init_Scene;

    -- Affichage de la fenetre OpenGL
    glutShowWindow;

    -- Fonction sans retour pour l'affichage de la scene
    glutMainLoop;


  exception
     -- Si une erreur s'est produite dans
     -- la tache d'affichage on l'indique
     -- a l'utilisateur
     when others =>
        P_Afficher.Put_Line_Dans_Zone_Reserv("P_Maquette-Display.adb");
        P_Afficher.Put_Line_Dans_Zone_Reserv(P_Messages.Erreur_Anormale );

  end Display_Simulator;


end P_Maquette.Display;
