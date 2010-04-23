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
--  You should have received a copy of the GNU General Public License
--  along with GNU Va Temps; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
--  This package provides a two way protocol for distant invocation of
--  procedures. Basically this package exports only two procedures
--  used to transmit parameters and get them back.
--
--  A simple sequence check type is transmitted also to give the
--  server a way to easily bind a request to a response (to the client
--  point of view).
--
--  This package should be considered as not completely satisfactory
--  from a clean design point of view. But it works.


with GNAT.Sockets;


package Tunnel is


  --  Main (generic) package to make the connections for a server or a
  --  client. This part depends of the role played in the
  --  communication.

  generic
    --  Arguments sent and received to and from the distant procedure
    --  host.
    type Packed_Arguments_Type is private;

    --  Sequence type for tying together requests to answers.
    type Sequence_Type is private;

    --  Host where the procedure will be executed and the TCP/IP port
    --  number used to establish the conneciton.
    Host     : String := "localhost";
    TCP_Port : GNAT.Sockets.Port_Type := 5551;

  package Protocol is

    type Tcpip_Configuration_Type is private;


    --  Exports an initialization procedure, a connection procedure, a
    --  disconnection procedure and a finlization procedures. The
    --  second and third procedures can be used to establish
    --  individual connections to a particular client. Note that in
    --  that particular case the data structure must be copied in
    --  order to prevent the multiple connections to interfer.

    package Server is

      procedure Initialize (Conn : out Tcpip_Configuration_Type);
      procedure Connect (Conn : in out Tcpip_Configuration_Type);
      procedure Disconnect (Conn : in out Tcpip_Configuration_Type);
      procedure Finalize (Conn : in out Tcpip_Configuration_Type);

    end Server;

    --  The client package exports also an initialization procedure, a
    --  connection procedure, a disconnection procedure and a
    --  finlization procedures. The second and third procedures can be
    --  used to establish individual connections to a particular
    --  server.  In order to prevent different server to interfer, the
    --  data structure (tcpip_configuration_type) used to initialize
    --  the sockets must be copied.

    package Client is

      procedure Initialize (Conn : out Tcpip_Configuration_Type);
      procedure Connect (Conn : in out Tcpip_Configuration_Type);
      procedure Disconnect (Conn : in out Tcpip_Configuration_Type);
      procedure Finalize (Conn : in out Tcpip_Configuration_Type);

    end Client;

    --  Send the argument packed and its sequence number.
    procedure Send
      (Conn : in Tcpip_Configuration_Type;
       Seq  : in Sequence_Type;
       Proc : in Packed_Arguments_Type);


    --  Receive the argument packed and its sequence number.
    procedure Receive
      (Conn : in Tcpip_Configuration_Type;
       Seq  : out Sequence_Type;
       Proc : out Packed_Arguments_Type);

    --  As previous with a timeout.
    procedure Receive
      (Conn     : in Tcpip_Configuration_Type;
       Seq      : out Sequence_Type;
       Proc     : out Packed_Arguments_Type;
       Deadline : in Duration;
       Timeout  : out Boolean);

    --  Return connection image (ip number and tcp port).
    function Address_Image (Conn : in Tcpip_Configuration_Type) return String;


  private

    type Role_Type is (Act_As_Server, Act_As_Client);

    type Tcpip_Configuration_Type is record
      Role    : Role_Type;
      Address : GNAT.Sockets.Sock_Addr_Type;
      Client  : GNAT.Sockets.Socket_Type;
      Socket  : GNAT.Sockets.Socket_Type;
      Channel : GNAT.Sockets.Stream_Access;
    end record;


  end Protocol;

end Tunnel;


