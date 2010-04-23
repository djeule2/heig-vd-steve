--
--  Ce paquetage exporte un type queue auquel sont associés une
--  procédure d'ajout, une procédure de retrait de la queue ainsi
--  qu'un itérateur.
--
--  Dominik Madon <dominik.madon@eivd.ch> on Tue 17.02.2004 at 16:06:17
--    Création,
--

with Unchecked_Deallocation;


package body Queue is



   ---------------
   --  Ajouter  --
   ---------------

   procedure Ajouter
     (Queue   : in  Queue_Type;
      Element : in  Element_Type) is

      Nouvel_Element : Queue_Access_Type := new Queue_Type'(Element => Element,
                                                            Suivant => null);
   begin
      if Compteur_Element = 0 then
         Racine := Nouvel_Element;
         Dernier := Racine;
      else
         Dernier.Suivant := Nouvel_Element;
         Dernier := Dernier.Suivant;
      end if;
      Compteur_Element := Compteur_Element + 1;
   end Ajouter;



   ---------------
   --  Enlever  --
   ---------------

   procedure Enlever
     (Queue   : in  Queue_Type;
      Element : out Element_Type) is

      procedure Liberer is new
        Unchecked_Deallocation (Queue_Type, Queue_Access_Type);
      Temp : Queue_Access_Type;

   begin
      if Compteur_Element > 0 then
         Element := Racine.Element;
         Temp := Racine;
         Racine := Racine.Suivant;
         Compteur_Element := Compteur_Element - 1;
         Liberer (Temp);
      else
         raise Program_Error;
      end if;
   end Enlever;



   ----------------
   --  Compteur  --
   ----------------

   function Compteur (Queue : in  Queue_Type) return Natural is
   begin
      return Compteur_Element;
   end Compteur;




   -------------------------------
   --  Iteration_Dans_La_Queue  --
   -------------------------------

   procedure Iteration_Dans_La_Queue (Queue : in Queue_Type) is
      Temp : Queue_Access_Type;
   begin
      Temp := Racine;
      while (Temp /= null) loop
         Action (Element => Temp.Element);
         Temp := Temp.Suivant;
      end loop;
   end Iteration_Dans_La_Queue;

end Queue;

