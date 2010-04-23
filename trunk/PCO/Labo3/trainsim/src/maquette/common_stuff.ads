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



package Common_Stuff is

  type Seq_Type is mod 30;

  type Procedure_Id_Type is (Two_Int_Id, One_Char_Id, Null_Id);

  type Record_Type (Id : Procedure_Id_Type := Null_Id ) is record
    case Id is
       when Null_Id =>
         null;
       when One_Char_Id =>
         C : Character;
       when Two_Int_Id =>
         A : Integer;
         B : Integer;
    end case;
  end record;

  procedure Two_Int (A : in Integer; B : out Integer);

  procedure One_Char (C : in out Character);

  procedure Print_Record (Seq : in Seq_Type; My_Record : in Record_Type);

end Common_Stuff;
