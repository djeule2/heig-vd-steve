--  Tunnel
--
--  $Id$
--
--  This file is part of Dominik Madon Ada Public Library.
--
--  Copyright 2004 Dominik Madon
--
--  Madon Ada Public Library is free software; you can redistribute it
--  and/or modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2 of
--  the License, or (at your option) any later version.
--
--  GNU Va Temps is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--
--  Package description
--
--  This package provides a two way protocol for distant invocation of
--  procedures. Basically this package exports only two procedures
--  used to transmit parameters and get them back.
--
--  A simple sequence check type is transmitted also to give the
--  server a way to easily bind a request to a response (to the client
--  point of view).



with Ada.Streams;
with GNAT.Sockets;


package body Tunnel is

  --  Main (generic) package to make the connections for a server or a
  --  client. This part depends of the role played in the
  --  communication.

  package body Protocol is


    --  Exports an initialization procedure, a connection procedure, a
    --  disconnection procedure and a finlization procedures. The
    --  second and third procedures can be used to establish
    --  individual connections to a particular client. Note that in
    --  that particular case the data structure must be copied in
    --  order to prevent the multiple connections to interfer.

    package body Server is

      ------------------
      --  Initialize  --
      ------------------

      procedure Initialize (Conn : out Tcpip_Configuration_Type) is
         use GNAT.Sockets;
      begin
         Conn.Role := Act_As_Server;

         Conn.Address.Port := TCP_Port;
         Conn.Address.Addr := Addresses (Get_Host_By_Name ("localhost"), 1);
         Initialize (Process_Blocking_IO => False);
         Create_Socket (Conn.Socket);

         --  Allow reuse of local addresses.
         Set_Socket_Option (Conn.Socket, Socket_Level, (Reuse_Address, True));
         Bind_Socket (Conn.Socket, Conn.Address);

         --  A server marks a socket as willing to receive connect events.
         Listen_Socket (Conn.Socket);

      end Initialize;


      ---------------
      --  Connect  --
      ---------------

      procedure Connect
        (Conn : in out Tcpip_Configuration_Type) is

        use GNAT.Sockets;
      begin
         -- Accepting a connection
         Accept_Socket (Conn.Socket, Conn.Client, Conn.Address);
         Conn.Channel := Stream (Conn.Client);
      end Connect;


      ------------------
      --  Disconnect  --
      ------------------

      procedure Disconnect
        (Conn : in out Tcpip_Configuration_Type) is

        use GNAT.Sockets;
      begin
        Close_Socket (Conn.Client);
      end Disconnect;


      ----------------
      --  Finalize  --
      ----------------

      procedure Finalize (Conn : in out Tcpip_Configuration_Type) is
        use GNAT.Sockets;
      begin
         Close_Socket (Conn.Socket);
         Finalize;
      end Finalize;

    end Server;


    --  The client package exports also an initialization procedure, a
    --  connection procedure, a disconnection procedure and a
    --  finlization procedures. The second and third procedures can be
    --  used to establish individual connections to a particular
    --  server.  In order to prevent different server to interfer, the
    --  data structure (tcpip_configuration_type) used to initialize
    --  the sockets must be copied.

    package body Client is

      ------------------
      --  Initialize  --
      ------------------

      procedure Initialize (Conn : out Tcpip_Configuration_Type) is
        use GNAT.Sockets;
      begin
         Initialize (Process_Blocking_IO => False);

         Conn.Role := Act_As_Client;

         --  SpŽcification du Serveur.
         Conn.Address.Port := TCP_Port;
         Conn.Address.Addr := Addresses (Get_Host_By_Name (Host), 1);

      end Initialize;


      ---------------
      --  Connect  --
      ---------------

      procedure Connect (Conn : in out Tcpip_Configuration_Type) is
        use GNAT.Sockets;
      begin
        --  CrŽation du socket et connexion.
         Create_Socket (Conn.Socket);
         Set_Socket_Option (Conn.Socket, Socket_Level, (Reuse_Address, True));

         Connect_Socket (Conn.Socket, Conn.Address);
         Conn.Channel := Stream (Conn.Socket);

      end Connect;


      ------------------
      --  Disconnect  --
      ------------------

      procedure Disconnect (Conn : in out Tcpip_Configuration_Type) is
        use GNAT.Sockets;
      begin
         Close_Socket (Conn.Socket);
      end Disconnect;


      ----------------
      --  Finalize  --
      ----------------

      procedure Finalize (Conn : in out Tcpip_Configuration_Type) is
        use GNAT.Sockets;
      begin
         Finalize;
      end Finalize;

    end Client;



    --  Here starts the send/receive procedure exported by the
    --  generic protocol package.

    ------------
    --  Send  --
    ------------

    --  Send the argument packed and its sequence number.

    procedure Send
      (Conn : in Tcpip_Configuration_Type;
       Seq  : in Sequence_Type;
       Proc : in Packed_Arguments_Type) is

    begin
      Sequence_Type'Output (Conn.Channel, Seq);
      Packed_Arguments_Type'Output (Conn.Channel, Proc);
    end Send;



    ---------------
    --  Receive  --
    ---------------

    --  Receive the argument packed and its sequence number.

    procedure Receive
      (Conn : in Tcpip_Configuration_Type;
       Seq  : out Sequence_Type;
       Proc : out Packed_Arguments_Type) is

    begin
      Seq := Sequence_Type'Input (Conn.Channel);
      Proc := Packed_Arguments_Type'Input (Conn.Channel);
    end Receive;



    ---------------
    --  Receive  --
    ---------------

    --  Same functionality as previous receive but with an added
    --  feature that can stop listening for data after a timeout.

    procedure Receive
      (Conn     : in Tcpip_Configuration_Type;
       Seq      : out Sequence_Type;
       Proc     : out Packed_Arguments_Type;
       Deadline : in Duration;
       Timeout  : out Boolean) is

      use GNAT.Sockets;

      Selector      : Selector_Type;
      Read_Sockets  : Socket_Set_Type;
      Write_Sockets : Socket_Set_Type;
      Status        : Selector_Status;

    begin

      Create_Selector (Selector);

      if (Conn.Role = Act_As_Server) then
        Set (Read_Sockets, Conn.Client);
      else
        Set (Read_Sockets, Conn.Socket);
      end if;
      Empty (Write_Sockets);

      Check_Selector (Selector     => Selector,
                      R_Socket_Set => Read_Sockets,
                      W_Socket_Set => Write_Sockets,
                      Status       => Status,
                      Timeout      => Deadline);

      if (Status = Completed and not Is_Empty (Read_Sockets)) then
        Seq := Sequence_Type'Input (Conn.Channel);
        Proc := Packed_Arguments_Type'Input (Conn.Channel);
        Timeout := False;
      else
        Timeout := True;
      end if;

      Close_Selector (Selector);

    end Receive;



    ---------------------
    --  Address_Image  --
    ---------------------

    --  Returns a string representing a GNAT socket address which
    --  appears as a serie of two digits separeted by dot and
    --  terminated by a colon and the tcpip portnumber used to
    --  communicate.

    function Address_Image
      (Conn : in Tcpip_Configuration_Type) return String is

      use GNAT.Sockets;
    begin
      return Image (Get_Address (Conn.Channel));
    end Address_Image;

  end Protocol;

end Tunnel;

