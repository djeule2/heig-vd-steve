------------------------------------------------------------------------------
--
-- Nom du fichier		   : P_Aiguillage.ads
-- Auteur			         : P.Girardet sur la base du paquetage de
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
--
------------------------------------------------------------------------------

-- pour utiliser les objets section
with P_Section;

package P_Aiguillage 
is
   
--****************************************************************************
--
--Types
--
--****************************************************************************
	-- Type pour un identificateur d'aiguillage.
	subtype T_Aiguillage_Id is Natural range 0..80;
   
  -- Type pour objet aiguillage
	type T_Aiguillage is private;
   
  -- Type pointeur sur un objet aiguillage
  type T_Aiguillage_Ptr is access T_Aiguillage;

	-- Type pour un tableau d'aiguillages
	type T_Aiguillages is array (T_Aiguillage_Id range <>) of T_Aiguillage_Ptr;
   
   
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
     return T_Aiguillage_Ptr;

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
                                Direction : in     P_Section.T_Direction);
   
   ---------------------------------------------------------------------------
   -- 
   -- Fonction: Section
   -- But     : Fournir la section sur laquelle se trouve l'aiguillage
   --
   -- Entree  : Aiguillage  => Objet aiguillage dont on desir connaitre la 
   --                          section
   --
   ---------------------------------------------------------------------------                                                                      
   function Section (Aiguillage: in     T_Aiguillage) 
     return P_Section.T_Section_ptr;                               
       
       
private
   -- Type de l'objet aiguillage
   type T_Aiguillage is record
   
     -- Le numero de l'aiguillage.
	   Numeroaiguillage: T_Aiguillage_Id;	 
      
     -- Indication si l'aiguillage est un aiguillage principal ou secondaire
	   Sousaiguillage: P_Section.T_Aiguillage_Type;	
                                     
     -- Pointeur sur l'objet section qui est l'aiguillage
     Section: P_Section.T_Aiguillage_Ptr;	
   
   end record;  
    
end P_Aiguillage;   
