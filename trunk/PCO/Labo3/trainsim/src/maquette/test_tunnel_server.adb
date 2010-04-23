--  Test_Tunnel_Server
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
--  test_tunnel_client).


with Text_IO; use Text_IO;

with Tunnel;
with Common_Stuff;
with Unchecked_Deallocation;


procedure Test_Tunnel_Server is

  --  Custom tunnel package.
  package Custom_Protocol is new Tunnel.Protocol
    (Packed_Arguments_Type => Common_Stuff.Record_Type,
     Sequence_Type         => Common_Stuff.Seq_Type);

  --  tcpip connection parameters holder.
  Conn : aliased Custom_Protocol.Tcpip_Configuration_Type;

  --  Reference type to tcpip connection.
  type Tcpip_Configuration_Type_Access is
    access all Custom_Protocol.Tcpip_Configuration_Type;

  --  Reference to connection variable.
  Conn_Acc : Tcpip_Configuration_Type_Access := Conn'access;

  --  My record type to be transfered through the tunnel.
  M : Common_Stuff.Record_Type;


  type Executor_Type; -- forward declaration.
  type Executor_Access is access all Executor_Type;


  type Dispatcher_Type; -- forward declaration;
  type Dispatcher_Access is access all Dispatcher_Type;


  --  Task responsible for sending packets to the client.
  task type Sender_Type is

    --  Starts the task given the tcpip configuration of the
    --  connection and the dispatcher's access (in order to
    --  communicate with them).
    entry Start
      (Conn_Acc       : in Tcpip_Configuration_Type_access;
       Dispatcher_Acc : in Dispatcher_Access);

    --  Send a record to the client.
    entry Send
      (Seq : in Common_Stuff.Seq_Type;
       Z   : in Common_Stuff.Record_Type);
    entry Stop;
  end Sender_Type;

  type Sender_Access is access all Sender_Type;

  --  Deallocation procedure for the Sender.
  procedure Free is
    new Unchecked_Deallocation (Sender_Type, Sender_Access);


  --  Task responsible for receiving information from the client and
  --  dispathing the messages to the executr tasks.
  task type Dispatcher_Type is

    --  Starts the dispatcher given the tcpip configuration, the
    --  sender access and the dispatcher acces itself (used to provide
    --  executor a way to talk back to the right dispatcher).
    entry Start
      (Conn_Acc            : in Tcpip_Configuration_Type_Access;
       Sender_Acc_Init     : in Sender_Access;
       Dispatcher_Acc_Init : in Dispatcher_Access);

    --  Hook for the executor tasks when it has finished its work.
    entry Wait
      (Seq : out Common_Stuff.Seq_Type;
       Rec : out Common_Stuff.Record_Type;
       Id  : in Executor_Access);

    entry Stop;

    --  Special entry to wait before termination (used as a last point
    --  of synchronisation).
    entry Terminated;

  end Dispatcher_Type;

  procedure Free is
    new Unchecked_Deallocation (Dispatcher_Type, Dispatcher_Access);


  --  Task responsible for consuming the packets received from
  --  network. After having started it will loop waiting for new data
  --  and consuming them.
  task type Executor_Type is

    --  Starts the task given its access (used to get it back to the
    --  diuspatcher for destruction), the sender access and the
    --  dispatcher acces.
    entry start  (Id_Init             : Executor_Access;
                  Sender_Acc_Init     : Sender_Access;
                  Dispatcher_Acc_Init : Dispatcher_Access);

    --  This entry provides a last synchronisation point before dying.
    entry Terminated;
  end Executor_Type;

  procedure Free is
    new Unchecked_Deallocation (Executor_Type, Executor_Access);


  task body Executor_Type is

    use Common_Stuff;

    Id : Executor_Access;
    Dispatcher_Acc : Dispatcher_Access;
    Sender_Acc : Sender_Access;

    Seq : Seq_Type;
    Rec : Record_Type;

  begin

    accept Start (Id_Init             : Executor_Access;
                  Sender_Acc_Init     : Sender_Access;
                  Dispatcher_Acc_Init : Dispatcher_Access) do
      Id := Id_Init;
      Sender_Acc := Sender_Acc_Init;
      Dispatcher_Acc := Dispatcher_Acc_Init;
    end Start;

    loop
      Dispatcher_Acc.Wait (Seq, Rec, Id);
      exit when Rec.Id = Null_Id;
      Common_Stuff.Print_Record (Seq, Rec);
      Common_Stuff.Two_Int (Rec.A, Rec.B);
      Sender_Acc.Send (Seq, Rec);
    end loop;

    Put_Line ("Executor type finished.");

    loop
      select
        accept Terminated;
      or
        terminate;
      end select;
    end loop;

  end Executor_Type;


  task body Dispatcher_Type is

    M       : Common_Stuff.Record_Type;
    My_Seq  : Common_Stuff.Seq_Type;
    End_Rec :
      constant Common_Stuff.Record_Type := (Id => Common_Stuff.Null_ID);

    Executor_Acc   : Executor_Access;
    Sender_Acc     : Sender_Access;
    Dispatcher_Acc : Dispatcher_Access;

    Timeout : Boolean;

  begin

    accept Start (Conn_Acc            : in Tcpip_Configuration_Type_access;
                  Sender_Acc_Init     : in Sender_Access;
                  Dispatcher_Acc_Init : in Dispatcher_Access) do
      Dispatcher_Acc := Dispatcher_Acc_Init;
      Sender_Acc := Sender_Acc_Init;
    end Start;

    loop

      Custom_Protocol.Receive (Conn_Acc.all, My_Seq, M);

      exit when Common_Stuff."=" (M, End_Rec);

      if Wait'Count = 0 then
        Executor_Acc := new Executor_Type;
        Executor_Acc.Start (Executor_Acc, Sender_Acc, Dispatcher_Acc);
      end if;

      select
        accept Wait
          (Seq : out Common_Stuff.Seq_Type;
           Rec : out Common_Stuff.Record_Type;
           Id  : in Executor_Access) do
          Seq := My_Seq;
          Rec := M;
        end Wait;
      or
        accept Stop;
        exit;
      end select;

    end loop;

    --  Check and stop executor tasks.
    while Wait'Count > 0 loop
      accept Wait (Seq : out Common_Stuff.Seq_Type;
                   Rec : out Common_Stuff.Record_Type;
                   Id  : in Executor_Access) do
        Seq := Common_Stuff.Seq_Type'First;
        Rec := End_Rec;
        Executor_Acc := Id;
      end Wait;

      Executor_Acc.terminated;
      Free (Executor_Acc);
    end loop;

    Sender_Acc.Stop;
    Put_Line ("Dispatcher finished.");

    loop
      select
        accept Terminated;
      or
        terminate;
      end select;
    end loop;

  end Dispatcher_Type;


  task body Sender_Type is
  begin

    accept Start
      (Conn_Acc       : in Tcpip_Configuration_Type_Access;
       Dispatcher_Acc : in Dispatcher_Access);

    loop
      select
        accept Send
          (Seq : in Common_Stuff.Seq_Type;
           Z   : in Common_Stuff.Record_Type) do
          Custom_Protocol.Send (Conn_Acc.all, Seq, Z);
        end Send;
      or
        accept Stop;
        exit;
      end select;
      Put_Line ("Sender finished.");
    end loop;

    --  Check and stop executor tasks.
    while Send'Count > 0 loop
      accept Send (Seq : in Common_Stuff.Seq_Type;
                   Z   : in Common_Stuff.Record_Type) do
        Custom_Protocol.Send (Conn_Acc.all, Seq, Z);
      end Send;
    end loop;
  end Sender_Type;


  Dispatcher_Acc : Dispatcher_Access;
  Sender_Acc     : Sender_Access;

begin
  Custom_Protocol.Server.Initialize (Conn);

  Put_Line ("Tunnel testing prog.");
  Put_Line ("Server.");

  loop
    select
      delay 5.0;
      Put_Line ("Timeout. Shuting down.");
      exit;
    then abort
      Custom_Protocol.Server.Connect (Conn);
      Put_Line ("Connection from " & Custom_Protocol.Address_Image (Conn));
    end select;

    Sender_acc := new Sender_Type;
    Dispatcher_acc := new Dispatcher_Type;

    Dispatcher_Acc.Start (Conn_Acc, Sender_Acc, Dispatcher_Acc);
    Sender_Acc.Start (Conn_Acc, Dispatcher_acc);

    Dispatcher_Acc.Terminated;

    Free (Sender_Acc);
    Free (Dispatcher_Acc);

    Custom_Protocol.Server.Disconnect (Conn);
  end loop;

  Custom_Protocol.Server.Finalize (Conn);
end Test_Tunnel_Server;
