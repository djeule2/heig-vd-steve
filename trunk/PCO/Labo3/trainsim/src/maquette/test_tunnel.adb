with Tunnel; use Tunnel;
with Text_IO; use Text_IO;


procedure Test_Tunnel is

  type Procedure_Id_Type is (Null_Id, Two_Args_Id);

  type My_Record_Type (Id : Procedure_Id_Type := Null_Id ) is record
    case Id is
       when Null_Id =>
         Card : Integer;
         Blob : String (1..5);
       when others =>
         Titi : Natural;
         C    : Character;
    end case;
  end record;

  type Seq_Type is mod 30;

  My_Seq : Seq_Type := 0;

  package Test is new Tunnel.Protocol
    (Packed_Arguments_Type => My_Record_Type,
     Sequence_Type         => Seq_Type);

  M : My_Record_Type := (Id => Null_Id, Card => 19, Blob => "astra");


  procedure Print_My_Record (My_Record : My_Record_Type) is
  begin
    case My_Record.Id is
       when Null_Id  =>
         Put_Line ("-- Null_Id");
         Put_Line ("---- Card:" & Integer'Image (My_Record.Card));
         Put_Line ("---- Blob:" & My_Record.Blob);
       when Two_Args_Id =>
         Put_Line ("-- Null_Id");
         Put_Line ("---- Titi:" & Natural'Image (My_Record.Titi));
         Put_Line ("---- C:" & My_Record.C);
       when others =>
         null;
    end case;
  end Print_My_Record;

  Conn : Test.Tcpip_Configuration_Type;

begin
  Put_Line ("Tunnel testing prog.");
  Put_Line ("Writing.");
  Print_My_Record (M);
  Test.Send (Conn, My_Seq, M);
  Test.Send (Conn, My_Seq, (Id => Two_Args_Id, Titi => 1234, C => 'X'));
  Put_Line ("Reading.");
  Test.Receive (Conn, My_Seq, M);
  Print_My_Record (M);
end Test_Tunnel;
