------------------------------------------------------------------------------
--
-- Nom du fichier     : P_Maquette-Display.ads
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
-------------------------------------------------------------------------------

package P_Maquette.Display
is

  -- Identificateur de la fenetre d'affichage du simulateur
  Simulator_Window : Integer;
  -- Identificateur de la fenetre d'affichage
  Legend_Window : Integer;

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
  -- Entree : Commencer   => Permet de faire demarrer l'execution
  --                              de la tache
  --
  -----------------------------------------------------------------------------

  procedure Display_Simulator;

private
  -- Tailles des fenetres
  SimWin_Width  : Integer := 700;
  SimWin_Height : Integer := 700;
  LegWin_Width  : Integer := 150;
  LegWin_Height : Integer := 80;

end P_Maquette.Display;
