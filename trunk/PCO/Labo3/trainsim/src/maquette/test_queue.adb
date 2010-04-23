With Text_IO;  use Text_IO;
with Queue;


------------------
--  Test_Queue  --
------------------

procedure Test_Queue is


  task T is
    entry E;
  end T;

  task body T is
  begin
    null;
    T.E;
    accept E;
    null;
  end T;


   --  Pour gŽnŽrer une suite d'identifiant.
   Task_Id : Natural := 0;

   function Next_Task_Id return Natural is
   begin
      Task_Id := Task_Id + 1;
      return Task_Id;
   end Next_Task_Id;

   --  T‰che simplisime qui ne rŽagit qu'ˆ un stop et un ping, le ping
   --  renvoyant sa valeur identifiante.
   task type Work_Type (Init_Id : Natural := Next_Task_Id) is
      entry Ping (My_Id : out Natural);
      entry Stop;
   end Work_Type;

   task body Work_Type is
      Id : Natural;
   begin
      Id := Init_Id;
      loop
         select
            accept Ping (My_Id : out Natural) do
               My_Id := Id;
            end Ping;
         or
            accept Stop;
            exit;
         or
            terminate;
         end select;
      end loop;
   end Work_Type;

   type Work_Access_Type is access Work_Type;


   --  CrŽation d'un type queue de naturels et d'un type de t‰ches
   --  simplisimes.
   package Natural_Queue is new Queue (Natural);
   package Task_Queue is new Queue (Work_Access_Type);

   --  DŽclaration d'une queue de naturels et d'une queue de t‰ches
   --  simplisimes.
   Nat_Q   : Natural_Queue.Queue_Type;
   Tache_Q : Task_Queue.Queue_Type;

   --  Pour les Žlements temporaires de la queue.
   Element_Naturel : Natural;
   Element_Tache   : Work_Access_Type;

   --  ProcŽdure d'affichage des naturels.
   procedure Affiche (Element : in out Natural) is
   begin
      Put_Line ("**" & Natural'Image (Element));
   end Affiche;

   --  ProcŽdure d'affichage des iddentifiants des t‰ches.
   procedure Affiche (Element : in out Work_Access_Type) is
      Id : Natural;
   begin
      Element.Ping (Id);
      Put_Line ("**" & Natural'Image (id));
   end Affiche;

   --  Instanciations des procŽdures gŽnŽriques d'itŽrations.
   procedure Affiche_Tout is
      new Natural_Queue.Iteration_Dans_La_Queue (Affiche);
   procedure Affiche_Tout is
      new Task_Queue.Iteration_Dans_La_Queue (Affiche);

   --  CrŽation de deux t‰ches simplisimes.
   A : Work_Access_type := new Work_Type (1);
   B : Work_Access_Type := new Work_Type (2);
   C : Work_Access_Type := new Work_Type (3);

begin
   Put_Line ("Test queue de naturels");
   Natural_Queue.Ajouter (Queue => Nat_Q, Element => 10);
   Natural_Queue.Ajouter (Queue => Nat_Q, Element => 11);
   Affiche_Tout (Nat_Q);
   Natural_Queue.Enlever (Queue => Nat_Q, Element => Element_Naturel);
   Put_Line ("Suppression: " & Natural'Image (Element_Naturel));
   Natural_Queue.Enlever (Queue => Nat_Q, Element => Element_Naturel);
   Put_Line ("Suppression: " & Natural'Image (Element_Naturel));

   Put_Line ("Test queue des t‰ches (type accs)");
   Task_Queue.Ajouter (Queue => Tache_Q, Element => A);
   Task_Queue.Ajouter (Queue => Tache_Q, Element => B);
   Affiche_Tout (Tache_Q);
   Task_Queue.Enlever (Queue => Tache_Q, Element => Element_Tache);
   Element_Tache.Ping (Element_Naturel);
   Put_Line ("Suppression: " & Natural'Image (Element_Naturel));
   Task_Queue.Ajouter (Queue => Tache_Q, Element => C);
   Affiche_Tout (Tache_Q);
   Task_Queue.Enlever (Queue => Tache_Q, Element => Element_Tache);
   Element_Tache.Ping (Element_Naturel);
   Put_Line ("Suppression: " & Natural'Image (Element_Naturel));
   Task_Queue.Enlever (Queue => Tache_Q, Element => Element_Tache);
   Element_Tache.Ping (Element_Naturel);
   Put_Line ("Suppression: " & Natural'Image (Element_Naturel));

   A.Stop;
   B.Stop;
   C.Stop;
end Test_Queue;
