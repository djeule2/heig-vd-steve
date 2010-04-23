--                              -*- Mode: Ada -*-
--  Filename        : simulator.adb
--  Description     : Simulator Server application
--  Author          : Dominik Madon
--  Created On      : Mon Dec 29 15:14:11 2003
--  Last Modified By: .
--  Last Modified On: .
--  Update Count    : 0
--  Status          : Unknown, Use with caution!


With Ada.Command_Line;
with Train_Handler.Server;



----------------
--  TrainSim  --
----------------

procedure TrainSim is

begin
   Train_Handler.Server.Init_Maquette;
   Train_Handler.Server.Mettre_maquette_hors_service;
end TrainSim;
