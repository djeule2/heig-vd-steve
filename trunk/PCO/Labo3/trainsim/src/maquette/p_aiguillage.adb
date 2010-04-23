------------------------------------------------------------------------------
--
-- Nom du fichier		   : P_Aiguillage.adb
-- Auteur              : P.Girardet sur la base du paquetage de
--                       M Pascal Binggeli & M Vincent Crausaz
--
-- Date de creation    : 22.8.97
-- Derniere Modifs.    : Decembre 97
-- Raison de la 
-- Modification        : Ajout d'une interface graphique
--
-- Version				     : 3.0
-- Projet				       : Simulateur de maquette
-- Module				       : Aiguillage
-- But					       : Fournir l'objet aiguillage anisi que les primitives
--                       necessaire a sa manipulation
-- Modules appeles     : P_Section
-- 
-- Fonctions exportees : Newaiguillage,
--                       Dirigeraiguillage,
--
------------------------------------------------------------------------------
package body P_Aiguillage
is
  
  ---------------------------------------------------------------------------
  --
  -- Fonction : Newaiguillage
  -- But      : Creer un nouvelle instance de l'objet aiguillage et retourne 
  --            un pointeur sur cet objet
  --   
  -- Entree   : Noaiguillage => Numero de l'aiguillage sur la maquette
  --            Sousaiguillage
  --                         => Indication si l'aiguillage est un aiguillage
  --                            principal ou secondaire
  --
  --            Section      => Pointeur sur l'objet section qui est 
  --                            l'aiguillage
  --
  -- Retour   : Un pointeur sur le nouvelle objet aiguillage
  --
  ---------------------------------------------------------------------------
  function Newaiguillage 
           (Noaiguillage  : in     T_Aiguillage_Id;
            Sousaiguillage: in     P_Section.T_Aiguillage_Type;
            Section       : in     P_Section.T_Aiguillage_Ptr)
    return T_Aiguillage_Ptr 
  is
  begin
     return new T_Aiguillage'(Noaiguillage, Sousaiguillage, Section);
     
  end Newaiguillage;
  
  ---------------------------------------------------------------------------
  --
  -- Fonction : Dirigeraiguillage
  -- But      : Procedure qui permet de modifier la direction d'un
  --            aiguillage
  --   
  --            Direction   => La nouvelle direction que aiguillage va 
  --                           prendre et qui va peut etre modifier son etat
  -- Entrees &
  -- Sorties  : Aiguillage  => Objet aiguillage dont on desir modifier la 
  --                           direction
  --
  --
  ---------------------------------------------------------------------------
  procedure Dirigeraiguillage (Aiguillage: in out T_Aiguillage;
                               Direction : in     P_Section.T_Direction)
  is
  begin
    -- On dirige la section aiguillage
    P_Section.Diriger(Aiguillage.Section.all,Direction,
                      Aiguillage.Sousaiguillage);
  
  end Dirigeraiguillage; 
   
  ---------------------------------------------------------------------------
  -- 
  -- Fonction: Section
  -- But     : Fournir la section sur laquelle se trouve l'aiguillage
  --
  -- Entree  : Aiguillage  => Objet aiguillage dont on desir connaitre la
  --                          section
  --
  ---------------------------------------------------------------------------
  function Section (Aiguillage: in T_Aiguillage) 
    return P_Section.T_Section_Ptr
  is       
  begin
    return P_Section.T_Section_Ptr(Aiguillage.Section);
  
  end;    
         
end P_Aiguillage;   
