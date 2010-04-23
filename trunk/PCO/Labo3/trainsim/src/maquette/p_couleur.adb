------------------------------------------------------------------------------
--
-- Nom du fichier     : P_Couleur.adb
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
-- Module             : Couleur
-- But                : Mettre a disposition un type couleur contenant des 
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

package body P_Couleur
is

-- ***************************************************************************
--
-- Types
--
-- ***************************************************************************

  -- type deffinissant une table  de conversion entre les couleurs et leur 
  -- equivalent en RVBA    
  type T_Table_Couleur is array(T_Couleur) of T_Couleur_Rvba;
  
-- ***************************************************************************
--
-- Constantes
--
-- ***************************************************************************    
   
  -- Table de conversion entre une couleur et son equivalent en RVBA
  Tablecouleur: constant T_Table_Couleur :=
    ( (0.3    , 0.25   , 1.0    , 1.0),   -- Bleu_Contact
      (0.55   , 0.55   , 0.55   , 1.0),   -- Couleur_Segment_Inactif
      (0.0    , 0.35   , 0.0    , 1.0),   -- Couleur_Segment_Actif
      (1.0    , 0.0    , 0.0    , 1.0),   -- Couleur_Risque_Deraillement
      (1.0    , 1.0    , 1.0    , 1.0),   -- Blanc
      (0.0    , 0.0    , 0.0    , 1.0),   -- Noir
      (1.0    , 0.0    , 0.0    , 1.0),   -- Rouge                         
      (0.0    , 1.0    , 0.0    , 1.0),   -- Vert
      (0.0    , 0.0    , 1.0    , 1.0),   -- Bleu
      (0.0    , 1.0    , 1.0    , 1.0),   -- Cyan
      (1.0    , 1.0    , 0.0    , 1.0),   -- Jaune
      (1.0    , 0.0    , 1.0    , 1.0),   -- Magenta      -+
      (1.0    , 0.25   , 0.25   , 1.0),   -- Rouge_Loco    +
      (1.0    , 0.6    , 0.1    , 1.0),   -- Orange_Loco   +- Couleurs locos
      (0.25   , 0.75   , 0.2    , 1.0),   -- Vert_Loco     +
      (0.15   , 0.55   , 1.0    , 1.0)    -- Bleu_Loco    -+
    );
   
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
    return T_Couleur_Rvba
  is
  begin
     -- Utilise la table de conversion
     return Tablecouleur(Couleur);
     
  end Transforme;         

end P_Couleur;   
