------------------------------------------------------------------------------
--
-- Nom du fichier		  : P_Couleur.ads
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
-- Projet			    	  : Simulateur de maquette
-- Module				      : Couleur
-- But					      : Mettre a disposition un type couleur contenant des 
--                      couleurs de base puis un type couleur qui permet 
--                      d'exprimer ces couleurs selon les trois couleurs
--                      soustractives de base le Rouge, Le Vert et le bleu et le
--                      coefficient alpha (type utilise par OpenGL).
--
-- Modules appeles    : Win32.Gl
-- 
-- Fonctions exportees: Transforme,                   
--
------------------------------------------------------------------------------

-- Pour utiliser le type Glfloat
with GL; use GL;

package P_Couleur
is

-- ***************************************************************************
--
-- Type
--
-- ***************************************************************************   
    
  -- type definissant les couleurs a disposition
  type T_Couleur is ( Bleu_Contact, Couleur_Segment_Inactif,
                      Couleur_Segment_Actif, Couleur_Risque_Deraillement,
                      Blanc, Noir, Rouge, Vert, Bleu, Cyan, Jaune,
                      Magenta, Rouge_Loco, Orange_Loco, Vert_Loco, Bleu_Loco );
                                                    
  -- Type permettant d'exprimer ces couleurs par quatre valeur de 0.0 a 1.0
  -- qui represente respectivement la quantite de rouge, de vert et de bleu
  -- qui compose la couleur
  type T_Couleur_Rvba is array(1..4) of aliased Glfloat;
   
-- ***************************************************************************
--
-- Fonctions et procedures
--
-- ***************************************************************************
   
   -- ------------------------------------------------------------------------
   --
   -- Fonction : transforme
   -- But      : Transformer une couleur nommee et sa representation dans les
   --            trois couleurs soustractives
   --
   -- Entree   : Couleur => Une couleur
   --
   -- retour   : Sa representation dans les trois couleur RVBA
   --
   -- ------------------------------------------------------------------------
   function Transforme (Couleur: T_Couleur) 
     return T_Couleur_Rvba;

end P_Couleur;                                         
