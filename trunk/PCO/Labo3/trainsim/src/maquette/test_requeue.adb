with Text_IO; use Text_IO;

procedure Test_Requeue is

   type Contacts is range 0..10;

   type Happened_Type is array (Contacts) of Boolean;

   protected Two_Phase is
      entry Enqueue (Contacts);
      entry Waitqueue (Contacts);
      procedure Set (Contact : in Contacts);
   private
      Happened : Happened_Type := (0..10 => False);
   end Two_Phase;

   protected body Two_Phase is
      entry Enqueue (for I in Contacts) when True is
      begin
         Put_Line ("Enqueue  " & Contacts'Image(I));
         requeue Waitqueue (I);
      end Enqueue;

      entry Waitqueue (for I in Contacts) when Happened (I) is
      begin
         Put_Line ("Weakup   " & Contacts'Image(I));
         if Waitqueue (I)'Count = 0  then
            Happened (I) := False;
         end if;
      end Waitqueue;

      procedure Set (Contact : in Contacts) is
      begin
         if Waitqueue (Contact)'Count > 0 then
            Put_Line ("Set      " & Contacts'Image(Contact));
            Happened (Contact) := True;
         end if;
      end Set;
   end Two_Phase;

   task Client;
   task Server;

   task body Client is
   begin
      Two_Phase.Enqueue (1);
      Two_Phase.Enqueue (2);
      Two_Phase.Enqueue (1);
      Two_Phase.Enqueue (1);
      Two_Phase.Enqueue (3);
      Two_Phase.Enqueue (1);
      Two_Phase.Enqueue (1);
      Two_Phase.Enqueue (4);
   end Client;

   task body Server is
   begin
      for Index in 0..10 loop
         delay 1.0;
         Two_Phase.Set (1);
         Two_Phase.Set (2);
         Two_Phase.Set (3);
         Two_Phase.Set (4);
      end loop;
   end Server;

begin
   delay 10.0;
end Test_Requeue;


