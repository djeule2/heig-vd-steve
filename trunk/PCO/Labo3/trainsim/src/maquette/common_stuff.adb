--  Common_Stuff
--
--  $Id$
--
--
--  This file is part of Dominik Madon Ada Public Library.
--
--  Copyright 2004 Dominik Madon
--
--  GNU Va Temps is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  GNU Va Temps is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--
--  Package description
--
--  This application "tests" the tunnel package (see also
--  test_tunnel_server).
--
--  Demonstration package exporting two routines and a packed argument
--  type holding arguments for both routines.

with Text_IO; use Text_IO;


package body Common_Stuff is

  procedure Two_Int (A : in Integer; B : out Integer) is
  begin
    delay 1.0;
    B := A + 29;
  end Two_Int;

  procedure One_Char (C : in out Character) is
  begin
    C := Character'Succ (C);
  end One_Char;

  procedure Print_Record
    (Seq       : in Seq_Type;
     My_Record : in Common_Stuff.Record_Type) is
  begin
    Put_Line ("Seq:" & Seq_Type'Image (Seq));
    case My_Record.Id is
       when Two_Int_Id =>
         Put_Line ("---- A:" & Integer'Image (My_Record.A));
         Put_Line ("---- B:" & Integer'Image (My_Record.B));
       when One_Char_Id =>
         Put_Line ("---- C:" & My_Record.C);
       when others =>
         null;
    end case;
  end Print_Record;

end Common_Stuff;
