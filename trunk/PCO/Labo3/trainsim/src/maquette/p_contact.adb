------------------------------------------------------------------------------
--
-- Nom du fichier		: P_Contact.adb
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
-- But					     : Fournir l'objet contact ainsi que les primitives
--                     necessaire a sa manipulation
-- Modules appeles   : P_Section, P_Couleur
-- 
-- Fonctions exportees: Estactive,
--                      Est_Un_Contact,
--                      Newcontact,
--                      Paint
--
------------------------------------------------------------------------------

-- Pour utiliser les couleurs
with P_Couleur;

package body P_Contact
is
   ---------------------------------------------------------------------------
   --
   -- Fonction : New_Contact
   -- But      : Creer un nouvelle instance de l'objet contact et retourne un
   --            pointeur sur cet objet
   --    
	 -- Entree   : NoContact => Numero du contact
   --                            
   --            Section   => Pointeur sur l'objet section sur lequel se
   --            trouve le contact        
   --
   -- Retour   : Un pointeur sur le nouvelle objet contact            
   --      
	 ---------------------------------------------------------------------------
   function Newcontact(Nocontact: T_Contact_Id; 
                       Section  : P_Section.T_Section_Ptr) 
     return T_Contact_Ptr 
   is
   begin     
     -- Cree un objet contact et retourne un pointeur
     return new T_Contact'(Nocontact, Section);
      
   end Newcontact;

   
   ---------------------------------------------------------------------------
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
	 ---------------------------------------------------------------------------
   function Section_Id(Contact: in     T_Contact) 
     return P_Section.T_Section_Id
   is
   begin      
      return P_Section.Numero(Contact.Section);
      
   end Section_Id;

   ---------------------------------------------------------------------------
   --
   -- Procedure: Est_Un_Contact
   -- But      : Indiquer si une section est un contact et si elle l'est on
   --            lui indique le numero de ce contact
   --            
   --    
	 -- Entrees  : Section_ID => L'identificateur de la section
   --                            
   --            Contacts   => L'ensemble des contacts de la maquette
   --
   -- Sorties  : Contact_ID => L'identificateur du contact si la section est
   --                          un contact
   --            Vrai       => L'indication si la section est un contact
   --                          (True) ou n'est pas un contact (False)
   --      
	 ---------------------------------------------------------------------------
   procedure Est_Un_Contact(Section_Id: in     P_Section.T_Section_Id;
                            Contacts  : in     T_Contacts; 
                            Contact_Id:    out T_Contact_Id;
                            Vrai      :    out Boolean) 
   is
   begin
      -- On cherche parmit tous les contacts
      for Id in Contacts'range
      loop
         
        -- Si la section du contact correspond avec la section recherchee
        if Section_Id = P_Section.Numero(Contacts(Id).Section)
        then
           
          -- Si on a trouve on l'indique on fournit l'identificateur du
          -- contact et on quitte la porcedure
          Vrai:= True;
          Contact_Id:= Contacts(Id).Nocontact;
          exit;
          
        else
           -- Si on trouve rien on l'indique on fournit un identificateur
           -- de contact qui n'existe pas
           Vrai:= False;
           Contact_Id:= Contact_Null;
           
        end if;
             
      end loop; 
      
   end Est_Un_Contact;     


   ---------------------------------------------------------------------------
   --
   -- Fonction : Estactive
   -- But      : Indiquer si un contact est actif donc si un train est sur le
   --            contact
   --    
	 -- Entree   : Contact => L'objet contact dont on veut savoir si il est 
	 --                       active
   --
   -- Retour   : L'indication si le contact est active ( True => Active
   --            False => Pas Active
   --      
	 ---------------------------------------------------------------------------
	 function Estactive(Contact: in     T_Contact) 
	   return Boolean 
	 is
   begin
     -- Indique si la section est occupee
		 return P_Section.Estoccuper(Contact.Section);
		 
	 end Estactive;
 	
   ---------------------------------------------------------------------------
   --
   -- Procedure: Paint
   -- But      : Differntier les contacts des autres sections a l'ecran et
   --            pour cela on modifie la couleur des sections            
   --    
	 -- Entree   : Contact => L'objet contact dont on veut modifier la couleur
   --
	 ---------------------------------------------------------------------------
   procedure Paint ( Contact: in     T_Contact) 
   is 
   begin    
      -- Affecte un couleur a la section du contact
      P_Section.Mettrecouleur(Contact.Section, P_Couleur.Bleu_Contact);
      
   end Paint;
   
end P_Contact;
