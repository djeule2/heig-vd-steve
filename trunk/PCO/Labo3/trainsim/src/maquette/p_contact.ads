------------------------------------------------------------------------------
--
-- Nom du fichier		: P_contact.ads
-- Auteur				    : P.Girardet sur la base du paquetage de
--                    M Pascal Binggeli & M Vincent Crausaz
--
-- Date de creation  : 22.8.97
-- Derniere Modifs.  : Decembre 97
-- Raison de la 
-- Modification      : Ajout d'une interface graphique
--
-- Version				   : 3.0
-- Projet				     : Simulateur de maquette
-- Module				     : Contact
-- But				       : Fournir l'objet contact anisi que les primitives
--                     necessaire a sa manipulation
-- Modules appeles   : P_Section
-- 
-- Fonctions exportees: Estactive,
--                      Est_Un_Contact,
--                      Newcontact,
--                      Paint
--
------------------------------------------------------------------------------

-- Pour utiliser les objets sections
with P_Section;

package P_Contact 
is

-- ***************************************************************************
--
-- Types
--
-- ***************************************************************************
   
  -- Type pour un identificateur de contact.
  subtype T_Contact_Id is Natural range 0..64;

  ----------------------------------------------------------------------------
  -- Definition de l'objet Contact
  ----------------------------------------------------------------------------
  
  -- Type de l'objet contact.
  type T_Contact is private;
  
  -- Type pointeur sur un objet contact
  type T_Contact_Ptr is access T_Contact;

  -- Type pour un tableau de contacts.
  type T_Contacts is array (T_Contact_Id range <>) of T_Contact_Ptr;
  
  -- Type pour un tableau indiquant les contacts actives
  type T_Contacts_Actives is array (T_Contact_Id range <>) of Boolean;
  
-- ***************************************************************************
--
-- Constantes
--
-- ***************************************************************************
    
  -- Contact qui n'existe pas
  Contact_Null : constant T_Contact_Id := 0;

  ----------------------------------------------------------------------------
  --
  -- Fonction : Estactive
  -- But      : Indiquer si un contact est actif donc si un train est sur le 
  --            contact
  --    
  -- Entree   : Contact => L'objet contact dont on veut savoir si il est
  --                       active
  --
  -- Retour   : L'indication si le contact est active ( True => Active
  --            False => Pas Active)
  --      
  ----------------------------------------------------------------------------
  function Estactive(Contact: in     T_Contact) 
    return Boolean;
  
  ----------------------------------------------------------------------------
  --
  -- Procedure: Est_Un_Contact
  -- But      : Indiquer si une section est un contact et si elle
  --            l'est on lui indique le numero de ce contact
  --            
  --    
  -- Entrees  : Section_ID => L'identificateur de la section
  --                            
  --            Contacts   => L'ensemble des contacts de la maquette
  --
  -- Sorties  : Contact_ID => L'identificateur du contact si la section est un
  --                          contact
  --            Vrai       => L'indication si la section est un contact (True)
  --                          ou n'est pas un contact (False)
  --      
  ----------------------------------------------------------------------------
  procedure Est_Un_Contact(Section_Id: in     P_Section.T_Section_Id;
                           Contacts  : in     T_Contacts; 
                           Contact_Id:    out T_Contact_Id;
                           Vrai      :    out Boolean);
  
  ----------------------------------------------------------------------------
  --
  -- Fonction : Section_Id
  -- But      : Indiquer l'identificateur de la section sur laquelle est le 
  --            contact
  --    
  -- Entree   : Contact => L'objet contact dont on veut connaitre la section
  --                       sur laquelle il se trouve
  --
  -- Retour   : L'identificateur de la section sur laquelle se trouve le 
  --            contact
  --      
  ----------------------------------------------------------------------------
  function Section_Id(Contact: in     T_Contact) 
    return P_Section.T_Section_Id;
  
  ----------------------------------------------------------------------------
  --
  -- Fonction : New_Contact
  -- But      : Creer un nouvelle instance de l'objet contact et retourne un 
  --            pointeur sur cet objet
  --    
  -- Entree   : NoContact => Numero du contact
  --                            
  --            Section   => Pointeur sur l'objet section sur lequel se trouve
  --                         le contact        
  --
  -- Retour   : Un pointeur sur le nouvelle objet contact
  --            
  --      
  ----------------------------------------------------------------------------                                                          
  function Newcontact(Nocontact: T_Contact_Id; 
                      Section  : P_Section.T_Section_Ptr) 
    return T_Contact_Ptr;
  
  ----------------------------------------------------------------------------
  --
  -- Procedure: Paint
  -- But      : Differntier les contacts des autres sections a l'ecran et pour
  --            cela on modifie la couleur des sections
  --            
  --    
  -- Entree   : Contact => L'objet contact dont on veut modifier la couleur
  --
  ----------------------------------------------------------------------------               
  procedure Paint ( Contact: in     T_Contact);
  
private
   -- Type de l'objet contact
   type T_Contact
   is record
     -- Num du contact sur la maquette.
		 Nocontact: T_Contact_Id;	
     -- Pointeur sur la section du contact.
		 Section: P_Section.T_Section_Ptr;	
		 
   end record;
   
end P_Contact;

