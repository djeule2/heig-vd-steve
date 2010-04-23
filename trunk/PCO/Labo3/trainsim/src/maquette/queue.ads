--
--  Ce paquetage exporte un type queue auquel sont associés une
--  procédure d'ajout, une procédure de retrait de la queue ainsi
--  qu'un itérateur.
--
--  Dominik Madon <dominik.madon@eivd.ch> on Tue 17.02.2004 at 16:06:17
--    Création,
--

generic
   type Element_Type is private;
package Queue is

   type Queue_Type is private;

   ---------------
   --  Ajouter  --
   ---------------

   procedure Ajouter
     (Queue   : in  Queue_Type;
      Element : in  Element_Type);


   ---------------
   --  Enlever  --
   ---------------

   procedure Enlever
     (Queue   : in  Queue_Type;
      Element : out Element_Type);


   ----------------
   --  Compteur  --
   ----------------

   function Compteur (Queue : in  Queue_Type) return Natural;


   -------------------------------
   --  Iteration_Dans_La_Queue  --
   -------------------------------

   generic
      with procedure Action (Element : in out Element_Type) is <>;
   procedure Iteration_Dans_La_Queue (Queue : in Queue_Type);

private

   type Queue_Access_Type is access Queue_Type;

   type Queue_Type is record
      Element : Element_Type;
      Suivant : Queue_Access_Type := null;
   end record;

   Racine, Dernier : Queue_Access_Type := null;

   Compteur_Element : Natural := 0;

end Queue;

