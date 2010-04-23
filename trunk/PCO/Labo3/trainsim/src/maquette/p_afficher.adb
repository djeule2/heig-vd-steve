------------------------------------------------------------------------------
--
-- Nom du fichier     : P_Afficher.adb
-- Auteur             : P.Girardet  
--
-- Date de creation   : Decembre  97
-- Derniere Modifs.   : 
-- Raison de la 
-- Modification       : 
--
-- Version            : 3.1.2
-- Projet             : Simulateur de maquette
-- Module             : Afficher
-- But                : Fournir les fonctions d'affichage et de saisie de
--                      text_io en assurant l'exclusion mutuelle sur le 
--                      moniteur.                
--                      Les paquetages generiques pour les entree/sortie
--                      d'entier, de reel, etc. sont egalement disponibles
--                   
-- Modules appeles    : Text_io
-- 
-- Fonctions exportees: Les fonctions d'affichage et de saisie de text_io
--                      pour l'entree et la sortie standard (ecran et clavier)
--                      Les fonctions sur les fichiers ne sont pas disponibles                      disponibles
--                      
--                      Les memes fonctions suivies de la chaine de caractere 
--                      "_dans_Zone_Reserv" par exemple Put_Dans_Zone_Reserv
--
--                      Reserver_Affichage
--
--                      Liberer affichage
--
------------------------------------------------------------------------------
package body P_Afficher
is
   
  -- Specification de l'objet protege qui gere l'affichage des messages sur
  -- le moniteur  
  protected Gardien_Moniteur 
  is
    -- Pour obtenir la ressource critique moniteur
    entry Acquerir;  
    -- Pour rendre la ressource critique moniteur
    entry Rendre;   
     
   private
     -- Variable proteger indiquant la ressource critique moniteur est
     -- utilisee
     Aqui: Boolean:=False; 
       
   end Gardien_Moniteur; 

  
   -- Corps de l'objet protege qui gere l'affichage des messages sur
   -- le moniteur
   protected body Gardien_Moniteur
   is
     -- On peut obtenir la ressource critique que si elle est pas utilisee
     entry Acquerir
       when not Aqui
     is
     begin
       -- Indique que la ressource est utilisee
       Aqui:=True;
      
     end Acquerir;
     
     -- On peut effectuer le protocole de liberation sans contrainte
     entry Rendre 
       when True 
     is
     begin
       Aqui:= False;
      
     end Rendre;
     
   end Gardien_Moniteur;  
   
   ---------------------------------------------------------------------------
   --
   -- Procedure : Reserver_Affichage
   -- But       : Specifie la reservation de l'ecran par la tache appelant la
   --             procedure. Les autres taches ne pourrons pas afficher des
   --             messages tant que l'affichage n'est pas liberer
   -- 
   -- Remarque  : Lorsque l'on a reserve l'affichage il faut utiliser les 
   --             fonctions d'affichage dont le nom est suivit de la chaine de
   --             caractere "_Dans_Zone_Reserv"
   --
   ---------------------------------------------------------------------------
   procedure Reserver_Affichage
   is
   begin
      Gardien_Moniteur.Acquerir;
   
   end Reserver_Affichage;
     
   ---------------------------------------------------------------------------
   --
   -- Procedure : Liberer_Affichage
   -- But       : Specifie la liberation de l'ecran par la tache appelant la
   --             procedure. Les autres taches ne pourrons a nouveau afficher
   --             des messages 
   -- 
   ---------------------------------------------------------------------------
   procedure Liberer_Affichage
   is
   begin
      Gardien_Moniteur.Rendre; 
   
   end Liberer_Affichage; 
   
   -- Les autres procedure ont un fonctionement similaire aux procedures de 
   -- meme nom fournies par text_io par contre elles utilisent le gardien de
   -- la resource critique moniteur dont en les utilisant l'exclusion mutuelle
   -- sur l'ecran est assuree 
   
   -- Les procedures auquelles on a ajoute la chaine de caractere 
   -- "_dans_Zone_Reserv" realisent la meme action que les procedures de meme 
   -- nom sans la chaine mais peuvent etre utilisees lorsque l'affichage est
   -- reserve 
 
   procedure Get(Item :    out Character)
   is
   begin   
      Text_Io.Get(Item);
      
   end Get;

   procedure Get_Immediate(Item:    out Character)
   is
   begin
      Text_Io.Get_Immediate(Item);
           
   end Get_Immediate;

   procedure Look_Ahead(Item        :    out Character;
                        End_Of_Line :    out Boolean)
   is
   begin
      Text_Io.Look_Ahead(Item, End_Of_Line);
      
   end Look_Ahead;
  
   procedure Set_Col(To: in     Text_io.Positive_Count)
   is
   begin
      Text_Io.Set_Col(To);
      
   end Set_Col;
   
   function Col
     return Text_io.Positive_Count
   is
   begin
      return Text_io.Col;
      
   end Col;
  
    
   procedure Put_Dans_Zone_Resrev(Item : in    Character)
   is
   begin
      Text_Io.Put(Item);
      
   end Put_Dans_Zone_Resrev;

 
   procedure Put(Item : in     Character)
   is
   begin
      Gardien_Moniteur.Acquerir;
      Text_Io.Put(Item);
      Gardien_Moniteur.Rendre;
      
   end Put;
 
 
 
   procedure New_Line_Dans_Zone_Reserv
             (Spacing : in     Text_Io.Positive_Count := 1)
   is
   begin
      Text_Io.New_Line(Spacing);
      
   end New_Line_Dans_Zone_Reserv;

 
   procedure New_Line(Spacing : in     Text_Io.Positive_Count := 1) 
   is
   begin
      Gardien_Moniteur.Acquerir;
      Text_Io.New_Line(Spacing);
      Gardien_Moniteur.Rendre;
      
   end New_Line;

  
   procedure Skip_Line(Spacing : in     Text_Io.Positive_Count := 1) 
   is
   begin
      Text_Io.Skip_Line(Spacing);
      
   end Skip_Line;   
 
   procedure Get(Item :    out String) 
   is
   begin
      Text_Io.Get(Item);
      
   end Get;

  
   procedure Put_Dans_Zone_Reserv(Item: in     String)
   is
   begin
      Text_Io.Put(Item);
      
   end Put_Dans_Zone_Reserv;
  
   procedure Put(Item : in     String)
   is
   begin
      Gardien_Moniteur.Acquerir;
      Text_Io.Put(Item);
      Gardien_Moniteur.Rendre;
      
   end Put; 

   procedure Get_Line(Item :    out String; 
                      Last :    out Natural)
   is
   begin
      Text_Io.Get_Line(Item, Last);
      
   end Get_Line;


   procedure Put_Line_Dans_Zone_Reserv(Item : in     String)
   is
   begin
      Text_Io.Put_Line(Item);
      
   end Put_Line_Dans_Zone_Reserv;

 
   procedure Put_Line(Item : in     String)
   is
   begin
      Gardien_Moniteur.Acquerir;
      Text_Io.Put_Line(Item);
      Gardien_Moniteur.Rendre;
      
   end Put_Line;  
  
   function  End_Of_Line 
     return Boolean 
   is
   begin
      return Text_Io.End_Of_Line;
      
   end End_Of_Line;
  
   -- Generic packages for Input-Output of Integer Types
   package body Integer_Io 
   is
  
      package Int_Io is new Text_Io.Integer_Io(Num);
   
      procedure Get(Item  :    out Num;
                    Width : in     Text_Io.Field := 0)
      is
      begin
         Int_Io.Get(Item, Width);
         
      end Get;

      procedure Put_Dans_Zone_Reserv
               (Item  : in     Num;
                Width : in     Text_Io.Field := Default_Width;
                Base  : in     Text_Io.Number_Base := Default_Base)
      is
      begin
         Int_Io.Put(Item, Width, Base);
         
      end Put_Dans_Zone_Reserv;
          
      procedure Put(Item  : in     Num;
                    Width : in     Text_Io.Field := Default_Width;
                    Base  : in     Text_Io.Number_Base := Default_Base)
      is
      begin
         Gardien_Moniteur.Acquerir;
         Int_Io.Put(Item, Width, Base);
         Gardien_Moniteur.Rendre;
         
      end Put;  
               
      procedure Get(From : in     String;
                    Item :    out Num;
                    Last :    out Positive)
      is
      begin 
         Int_Io.Get(From, Item, Last);
         
      end Get;                   
   
    
      procedure Put(To   :    out String;
                    Item : in     Num;
                    Base : in     Text_Io.Number_Base := Default_Base)
      is
      begin     
         Int_Io.Put(To, Item, Base);
         
      end Put;  
  
   end Integer_Io;
  

   package body Modular_Io is
  
      package Mod_Io is new Text_Io.Modular_Io(Num);
    
      procedure Get(Item  :    out Num;
                    Width : in     Text_Io.Field := 0) 
      is
      begin
         Mod_Io.Get(Item, Width);
         
      end Get;
     
      procedure Put_Dans_Zone_Reserv
               (Item  : in     Num;
                Width : in     Text_Io.Field := Default_Width;
                Base  : in     Text_Io.Number_Base := Default_Base)
      is
      begin
        Mod_Io.Put(Item, Width, Base);
        
      end Put_Dans_Zone_Reserv;
 
      procedure Put(Item  : in     Num;
                    Width : in     Text_Io.Field := Default_Width;
                    Base  : in     Text_Io.Number_Base := Default_Base)
      is
                     
      begin
         Gardien_Moniteur.Acquerir;
         Mod_Io.Put(Item, Width, Base);
         Gardien_Moniteur.Rendre;
      
      end Put; 
                        
      procedure Get(From : in     String;
                    Item :    out Num;
                    Last :    out Positive)
      is
                     
      begin
         Mod_Io.Get(From, Item, Last);
         
      end Get; 
                    
      procedure Put(To   :    out String;
                    Item : in     Num;
                    Base : in     Text_Io.Number_Base := Default_Base)
      is
      begin
         Mod_Io.Put(To, Item, Base);
         
      end Put;                  
  
   end Modular_Io;
  
-- Generic packages for Input-Output of Real Types
   package body Float_Io is
        
      package Flo_Io is new Text_Io.Float_Io(Num);
    
      procedure Get(Item  :    out Num;
                    Width : in     Text_Io.Field := 0)is
      begin
         Flo_Io.Get(Item, Width);
         
      end Get;
  
      procedure Put_Dans_Zone_Reserv
               (Item : in     Num;
                Fore : in     Text_Io.Field := Default_Fore;
                Aft  : in     Text_Io.Field := Default_Aft;
                Exp  : in     Text_Io.Field := Default_Exp)
      is
      begin
         Flo_Io.Put(Item, Fore, Aft, Exp);
         
      end Put_Dans_Zone_Reserv;
  
      procedure Put(Item : in     Num;
                    Fore : in     Text_Io.Field := Default_Fore;
                    Aft  : in     Text_Io.Field := Default_Aft;
                    Exp  : in     Text_Io.Field := Default_Exp)
      is                    
      begin
         Gardien_Moniteur.Acquerir;
         Flo_Io.Put(Item, Fore, Aft, Exp);
         Gardien_Moniteur.Rendre;
         
      end Put;                  
  
      procedure Get(From : in     String;
                    Item :    out Num;
                    Last :    out Positive)
      is
      begin
        Flo_Io.Get(From, Item, Last);
        
      end Get;  
                                  
      procedure Put(To   :    out String;
                    Item : in     Num;
                    Aft  : in     Text_Io.Field := Default_Aft;
                    Exp  : in     Text_Io.Field := Default_Exp)
      is                    
      begin
        Flo_Io.Put(To, Item, Aft, Exp);
        
      end Put;                  
    
   end Float_Io;
   
   package body Fixed_Io is
  
      package Fix_Io is new Text_Io.Fixed_Io(Num);
    
      procedure Get(Item  :    out Num;
                    Width : in     Text_Io.Field := 0)
      is
      begin
         Fix_Io.Get(Item, Width);
         
      end Get;
         
      procedure Put_Dans_Zone_Reserv
               (Item : in     Num;
                Fore : in     Text_Io.Field := Default_Fore;
                Aft  : in     Text_Io.Field := Default_Aft;
                Exp  : in     Text_Io.Field := Default_Exp)
      is
      begin
         Fix_Io.Put(Item, Fore, Aft, Exp);
         
      end Put_Dans_Zone_Reserv;
 
    
      procedure Put(Item : in     Num;
                    Fore : in     Text_Io.Field := Default_Fore;
                    Aft  : in     Text_Io.Field := Default_Aft;
                    Exp  : in     Text_Io.Field := Default_Exp)
      is                    
      begin
         Gardien_Moniteur.Acquerir;
         Fix_Io.Put(Item, Fore, Aft, Exp);
         Gardien_Moniteur.Rendre;
         
      end Put;                  
  
      procedure Get(From : in     String;
                    Item :    out Num;
                    Last :    out Positive)
      is              
      begin
         Fix_Io.Get(From, Item, Last);
         
      end Get; 
                        
      procedure Put(To   :    out String;
                    Item : in     Num;
                    Aft  : in     Text_Io.Field := Default_Aft;
                    Exp  : in     Text_Io.Field := Default_Exp)
      is
                     
      begin
         Fix_Io.Put(To, Item, Aft, Exp);
         
      end Put;  
                  
   end Fixed_Io;
  
 
   package body Decimal_Io is
  
    
      package Dec_Io is new Text_Io.Decimal_Io(Num);
    
      procedure Get(Item  :    out Num;
                    Width : in     Text_Io.Field := 0)
      is
      begin
         Dec_Io.Get(Item, Width);
         
      end Get;
  
      procedure Put_Dans_Zone_Resrv
               (Item : in     Num;
                Fore : in     Text_Io.Field := Default_Fore;
                Aft  : in     Text_Io.Field := Default_Aft;
                Exp  : in     Text_Io.Field := Default_Exp)
      is
      begin
         Dec_Io.Put(Item, Fore, Aft, Exp);
         
      end Put_Dans_Zone_Resrv;
                  
      procedure Put(Item : in     Num;
                    Fore : in     Text_Io.Field := Default_Fore;
                    Aft  : in     Text_Io.Field := Default_Aft;
                    Exp  : in     Text_Io.Field := Default_Exp)
      is               
      begin
         Gardien_Moniteur.Acquerir;
         Dec_Io.Put(Item, Fore, Aft, Exp);
         Gardien_Moniteur.Rendre;
         
      end Put;                  
  
      procedure Get(From : in      String;
                    Item :     out Num;
                    Last :     out Positive)
      is
                     
      begin
         Dec_Io.Get(From, Item, Last);
         
      end Get;  
                               
      procedure Put(To   :    out String;
                    Item : in     Num;
                    Aft  : in     Text_Io.Field := Default_Aft;
                    Exp  : in     Text_Io.Field := Default_Exp)
      is               
      begin
         Dec_Io.Put(To, Item, Aft, Exp);
         
      end Put; 
                   
   end Decimal_Io;
  
-- Generic package for Input-Output of Enumeration Types 
   package body Enumeration_Io is
   
      package Enu_Io is new Text_Io.Enumeration_Io(Enum);
    
      procedure Get(Item :    out Enum)
      is
      begin
         Enu_Io.Get(Item);
         
      end Get;
    
      procedure Put_Dans_Zone_Reserv
               (Item  : in     Enum;
                Width : in     Text_Io.Field    := Default_Width;
                Set   : in     Text_Io.Type_Set := Default_Setting)
      is
      begin
         Enu_Io.Put(Item, Width, Set);
         
      end Put_Dans_Zone_Reserv;
                      
      procedure Put(Item  : in     Enum;
                    Width : in     Text_Io.Field    := Default_Width;
                    Set   : in     Text_Io.Type_Set := Default_Setting)
      is                 
      begin
         Gardien_Moniteur.Acquerir;
         Enu_Io.Put(Item, Width, Set);
         Gardien_Moniteur.Rendre;
         
      end Put;                  
  
      procedure Get(From : in     String;
                    Item :    out Enum;
                    Last :    out Positive)
      is
                             
      begin
         Enu_Io.Get(From, Item, Last);
         
      end Get;
                                    
      procedure Put(To   :    out String;
                    Item : in     Enum;
                    Set  : in     Text_Io.Type_Set := Default_Setting)
      is
                             
      begin
         Enu_Io.Put(To, Item, Set);
         
      end Put;  
                  
   end Enumeration_Io;

end P_Afficher;  
