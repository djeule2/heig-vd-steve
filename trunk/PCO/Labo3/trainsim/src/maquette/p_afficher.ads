------------------------------------------------------------------------------
--
-- Nom du fichier	     : P_Afficher.ads 
-- Auteur				       : P.Girardet 
--
-- Date de creation    : Decembre 97
-- Derniere Modifs.    : 
-- Raison de la 
-- Modification        : 
--
-- Version				     : 3.1.2
-- Projet				       : Simulateur de maquette
-- Module			    	   : Afficher
-- But					       : Fournir les fonctions d'affichage et de saisie de 
--                       text_io en assurant l'exclusion mutuelle sur le 
--                       moniteur.
--                       Les paquetage generique pour les entree/sortie
--                       d'entier, de reel, etc. sont egalement disponibles
--                     
-- Modules appeles     : Text_io
-- 
-- Fonctions exportees : Les fonctions d'affichage et de saisie de text_io
--                       pour l'entree et la sortie standard 
--                       (ecran et clavier). Les fonctions sur les fichiers 
--                       ne sont pas disponibles
--                      
--                       Les memes fonctions suivies de la chaine de caractere
--                       "_dans_Zone_Reserv" par exemple Put_Dans_Zone_Reserv
--
--                       Reserver_Affichage
--
--                       Liberer affichage
--
------------------------------------------------------------------------------

-- Pour utiliser les entrees/sortie
with Text_Io;
 
-- Pour utiliser les exceptions predefinis 
with Ada.IO_Exceptions;

package P_Afficher is
   
  subtype Positive_Count is Text_Io.Positive_Count;
   
  ----------------------------------------------------------------------------
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
  ----------------------------------------------------------------------------
  procedure Reserver_Affichage;
   
	----------------------------------------------------------------------------
	--
	-- Procedure : Liberer_Affichage
	-- But       : Specifie la liberation de l'ecran par la tache appelant la 
	--             procedure. Les autres taches ne pourrons a nouveau afficher 
	--             des messages 
	-- 
	----------------------------------------------------------------------------
	procedure Liberer_Affichage; 
   
   
	-- Les autres procedures ont un fonctionement similaire aux procedures de 
	-- meme nom fournie par text_io.
	
	-- Les procedures auquelles on a ajoute la chaine de caractere
	-- "_dans_Zone_Reserv" realisent la meme action que les procedures de meme 
	-- nom sans la chaine mais peuvent etre utilisees lorsque l'affichage est 
	-- reserve

	procedure Get(Item :    out Character);
	
	procedure Put_Dans_Zone_Resrev(Item : in     Character);
	
	procedure Put(Item : in     Character);
	
	procedure Get_Immediate(Item:    out Character);  
    
  procedure Look_Ahead (Item        :    out Character;
	                      End_Of_Line :    out Boolean);
	
  procedure Set_Col(To: in     Text_io.Positive_Count);
    
  function Col 
    return Text_io.Positive_Count;
    
	procedure New_Line_Dans_Zone_Reserv
	          (Spacing : in     Text_Io.Positive_Count := 1);
	
	procedure New_Line(Spacing : in     Text_Io.Positive_Count := 1);
	
	procedure Skip_Line(Spacing : in     Text_Io.Positive_Count := 1);
	
	procedure Get(Item :    out String);
	
	procedure Put_Dans_Zone_Reserv( Item: in String); 
	
	procedure Put(Item : in  String);
	
	procedure Get_Line(Item :    out String; 
	                   Last :    out Natural);
	
	procedure Put_Line_Dans_Zone_Reserv(Item : in     String);
	
	procedure Put_Line(Item : in    String);
	
  function  End_Of_Line 
    return Boolean;
    
  generic
    type Num is range <>;
  
  package Integer_Io 
  is
    
    Default_Width : Text_Io.Field := Num'Width;
    Default_Base  : Text_Io.Number_Base := 10;
    
    procedure Get(Item  :    out Num;
                  Width : in     Text_Io.Field := 0);
    
    procedure Put_Dans_Zone_Reserv
                 (Item  : in     Num;
                  Width : in     Text_Io.Field := Default_Width;
                  Base  : in     Text_Io.Number_Base := Default_Base);
                    
    procedure Put(Item  : in     Num;
                  Width : in     Text_Io.Field := Default_Width;
                  Base  : in     Text_Io.Number_Base := Default_Base);
                    
    procedure Get(From : in     String;
                  Item :    out Num;
                  Last :    out Positive);
                    
    procedure Put(To   :    out String;
                  Item : in     Num;
                  Base : in     Text_Io.Number_Base := Default_Base);
    
  end Integer_Io;
    
  generic
    type Num is mod <>;
    
  package Modular_Io
  is
    
    Default_Width : Text_Io.Field := Num'Width;
    Default_Base  : Text_Io.Number_Base := 10;
    
    procedure Get(Item  :    out Num;
                  Width : in     Text_Io.Field := 0);
    
    procedure Put_Dans_Zone_Reserv
                 (Item  : in     Num;
                  Width : in     Text_Io.Field := Default_Width;
                  Base  : in     Text_Io.Number_Base := Default_Base);
                    
    procedure Put(Item  : in     Num;
                  Width : in     Text_Io.Field := Default_Width;
                  Base  : in     Text_Io.Number_Base := Default_Base);
                    
    procedure Get(From : in     String;
                  Item :    out Num;
                  Last :    out Positive);
                    
    procedure Put(To   :    out String;
                  Item : in     Num;
                  Base : in     Text_Io.Number_Base := Default_Base);
    
  end Modular_Io;
    
   
  generic
    type Num is digits <>;
  
  package Float_Io
  is
    
    Default_Fore : Text_Io.Field := 2;
    Default_Aft  : Text_Io.Field := Num'digits-1;
    Default_Exp  : Text_Io.Field := 3;
    
    procedure Get(Item  :    out Num;
                  Width : in     Text_Io.Field := 0);
    
    procedure Put_Dans_Zone_Reserv
                 (Item : in     Num;
                  Fore : in     Text_Io.Field := Default_Fore;
                  Aft  : in     Text_Io.Field := Default_Aft;
                  Exp  : in     Text_Io.Field := Default_Exp);
                    
    procedure Put(Item : in     Num;
                  Fore : in     Text_Io.Field := Default_Fore;
                  Aft  : in     Text_Io.Field := Default_Aft;
                  Exp  : in     Text_Io.Field := Default_Exp);
    
    procedure Get(From : in     String;
                  Item :    out Num;
                  Last :    out Positive);
                    
    procedure Put(To   :    out String;
                  Item : in     Num;
                  Aft  : in     Text_Io.Field := Default_Aft;
                  Exp  : in     Text_Io.Field := Default_Exp);
                  
  end Float_Io;
    
  generic
    type Num is delta <>;
    
  package Fixed_Io
  is
    
    Default_Fore : Text_Io.Field := Num'Fore;
    Default_Aft  : Text_Io.Field := Num'Aft;
    Default_Exp  : Text_Io.Field := 0;
    
    procedure Get(Item  :    out Num;
                  Width : in     Text_Io.Field := 0);
    
      
    procedure Put_Dans_Zone_Reserv
                 (Item : in     Num;
                  Fore : in     Text_Io.Field := Default_Fore;
                  Aft  : in     Text_Io.Field := Default_Aft;
                  Exp  : in     Text_Io.Field := Default_Exp);
    
    procedure Put(Item : in     Num;
                  Fore : in     Text_Io.Field := Default_Fore;
                  Aft  : in     Text_Io.Field := Default_Aft;
                  Exp  : in     Text_Io.Field := Default_Exp);  
                                
    procedure Get(From : in     String;
                  Item :    out Num;
                  Last :    out Positive);
                    
    procedure Put(To   :    out String;
                  Item : in     Num;
                  Aft  : in     Text_Io.Field := Default_Aft;
                  Exp  : in     Text_Io.Field := Default_Exp);
                  
  end Fixed_Io;
    
  generic
    type Num is delta <> digits <>;
    
  package Decimal_Io
  is
    
    Default_Fore : Text_Io.Field := Num'Fore;
    Default_Aft  : Text_Io.Field := Num'Aft;
    Default_Exp  : Text_Io.Field := 0;
    
    procedure Get(Item  :    out Num;
                  Width : in     Text_Io.Field := 0);
    
    procedure Put_Dans_Zone_Resrv
                 (Item : in     Num;
                  Fore : in     Text_Io.Field := Default_Fore;
                  Aft  : in     Text_Io.Field := Default_Aft;
                  Exp  : in     Text_Io.Field := Default_Exp);
                    
    procedure Put(Item : in     Num;
                  Fore : in     Text_Io.Field := Default_Fore;
                  Aft  : in     Text_Io.Field := Default_Aft;
                  Exp  : in     Text_Io.Field := Default_Exp);
    
    procedure Get(From : in     String;
                  Item :    out Num;
                  Last :    out Positive);
                    
    procedure Put(To   :    out String;
                  Item : in     Num;
                  Aft  : in     Text_Io.Field := Default_Aft;
                  Exp  : in     Text_Io.Field := Default_Exp);
                  
  end Decimal_Io;
    
   
  generic
    type Enum is (<>);
    
  package Enumeration_Io
  is
    
    Default_Width   : Text_Io.Field := 0;
    Default_Setting : Text_Io.Type_Set := Text_Io.Upper_Case;
    
    procedure Get(Item :    out Enum);
  
    procedure Put_Dans_Zone_Reserv
                 (Item  : in     Enum;
                  Width : in     Text_Io.Field    := Default_Width;
                  Set   : in     Text_Io.Type_Set := Default_Setting);
                    
    procedure Put(Item  : in     Enum;
                  Width : in     Text_Io.Field    := Default_Width;
                  Set   : in     Text_Io.Type_Set := Default_Setting);
    
    procedure Get(From : in     String;
                  Item :    out Enum;
                  Last :    out Positive);
                    
    procedure Put(To   :    out String;
                  Item : in     Enum;
                  Set  : in     Text_Io.Type_Set := Default_Setting);
                  
  end Enumeration_Io;

  Status_Error : exception renames ada.IO_Exceptions.Status_Error;
  Mode_Error   : exception renames ada.IO_Exceptions.Mode_Error;
  Name_Error   : exception renames ada.IO_Exceptions.Name_Error;
  Use_Error    : exception renames ada.IO_Exceptions.Use_Error;
  Device_Error : exception renames ada.IO_Exceptions.Device_Error;
  End_Error    : exception renames ada.IO_Exceptions.End_Error;
  Data_Error   : exception renames ada.IO_Exceptions.Data_Error;
  Layout_Error : exception renames ada.IO_Exceptions.Layout_Error;
  
end P_Afficher;   
