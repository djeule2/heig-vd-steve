--  Test_Tunnel_Client
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


with Tunnel;       use Tunnel;
with Text_IO;      use Text_IO;
with Common_Stuff;

procedure Test_Tunnel_Client is

  --  Sequence counter;
  My_Seq : Common_Stuff.Seq_Type := 0;

  --  Custom tunnel package and make it visible.
  package Test is new Tunnel.Protocol
    (Packed_Arguments_Type => Common_Stuff.Record_Type,
     Sequence_Type         => Common_Stuff.Seq_Type);
  use Test;

  --  Tcpip configuration holding variable.
  Conn : Tcpip_Configuration_Type;

  --  Reference type on the connection (in order to share it
  --  with all the dialoguing tasks).
  type Tcpip_Configuration_Type_Access is access Tcpip_Configuration_Type;

  --  Task responsible for sending requests over the tunnel.
  task type Dispatcher (Conn : Tcpip_Configuration_Type_access) is
    entry Start;
    entry Send
      (Seq : in Common_Stuff.Seq_Type;
       Z   : in out Common_Stuff.Record_Type);
    entry Receive
      (Seq : in Common_Stuff.Seq_Type;
       Z   : in out Common_Stuff.Record_Type);
    entry Stop;
  private
    entry Send_Wait
      (Seq : in Common_Stuff.Seq_Type;
       Z   : in out Common_Stuff.Record_Type);
  end Dispatcher;


  task body Dispatcher is
  begin
    accept Start;
    select
      accept Stop;
    or
      accept Send
        (Seq : in Common_Stuff.Seq_Type;
         Z   : in out Common_Stuff.Record_Type) do
        null;
      end Send;
    or
      accept Send_Wait
        (Seq : in Common_Stuff.Seq_Type;
         Z   : in out Common_Stuff.Record_Type) do
        null;
      end Send_Wait;
    or
      accept Receive
        (Seq : in Common_Stuff.Seq_Type;
         Z   : in out Common_Stuff.Record_Type) do
        null;
      end Receive;
    end select;
  end Dispatcher;

  M : Common_Stuff.Record_Type;

begin
  Client.Initialize (Conn);
  Put_Line ("Tunnel testing prog.");
  Put_Line ("Client.");
  Client.Connect (Conn);
  Common_Stuff.Print_Record (My_Seq, M);
  Send (Conn, My_Seq, (Id => Common_Stuff.Two_Int_Id, A => 1234, B => 1010));
  Receive (Conn, My_Seq, M);
  Common_Stuff.Print_Record (My_Seq, M);
  My_Seq := Common_Stuff.Seq_Type'Succ (My_Seq);
  Send (Conn, My_Seq, (Id => Common_Stuff.Null_Id));
  Client.Disconnect (Conn);
  Client.Finalize (Conn);
end Test_Tunnel_Client;
