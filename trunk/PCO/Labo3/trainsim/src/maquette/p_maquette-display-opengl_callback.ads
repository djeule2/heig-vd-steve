-------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------

-- Appel du paquetage d'interfacage avec le C
with Interfaces.C;

package P_Maquette.Display.OpenGL_Callback is
  -----------------------------------------------------------------------------
  -- Procedure Init_Scene
  -----------------------------------------------------------------------------
  -- But : Procedure initialisant tous les parametres OpenGL
  -----------------------------------------------------------------------------
  -- in     : 
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Init_Scene;
  
  -----------------------------------------------------------------------------
  -- Procedure Display_Callback
  -----------------------------------------------------------------------------
  -- But : Procedure de callback pour l'affichage du labyrinthe
  -----------------------------------------------------------------------------
  -- in     : 
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Display_Callback;
  
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
  procedure Reshape_Callback(Width   : in     Integer;
                             Height  : in     Integer);
  
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
                            X, Y    : in     Integer);
  
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
  procedure Keyboard_Callback(Key   : in     Interfaces.C.Unsigned_Char; 
                              X, Y  : in     Integer);
  
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
  procedure Special_Key_Callback(Key, X, Y : in     Integer);
  
  -----------------------------------------------------------------------------
  -- Procedure Idle_Callback
  -----------------------------------------------------------------------------
  -- But : Procedure appelee lorsqu'il n'y a rien d'autre a faire
  -----------------------------------------------------------------------------
  -- in     : 
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Idle_Callback;
  
  -----------------------------------------------------------------------------
  -- Procedure Menu
  -----------------------------------------------------------------------------
  -- But : Procedure lors de l'activation d'une entree du menu principal
  -----------------------------------------------------------------------------
  -- in     : Value  /  Integer         (Entree du menu selectionnee)
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Menu ( Value : in     Integer );

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
  procedure Sub_Menu_Rotate ( Value : in     Integer );

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
  procedure Sub_Menu_Display(Value : in     Integer);

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
  procedure Sub_Menu_Mode(Value : Integer);
  
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
  procedure Sub_Menu_Icones(Value : Integer);
  
  -----------------------------------------------------------------------------
  -- Procedure Legend_Init_Scene                                                    --
  -----------------------------------------------------------------------------
  -- But : Procedure initialisant tous les parametres OpenGL
  -----------------------------------------------------------------------------
  -- in     : 
  --    out : 
  -- in out : 
  -----------------------------------------------------------------------------
  procedure Legend_Init_Scene;
  
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
  procedure Legend_Display_Callback;
  
end P_Maquette.Display.OpenGL_Callback;