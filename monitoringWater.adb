--- Concurrency with synchronous messages in ADA

--- Author: Filipe Mesquita

with Calendar, Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Discrete_Random; use Calendar, Ada.Text_IO, Ada.Integer_Text_IO;

procedure monitoringWater is

   type RandWater is range 0 .. 1;
   package RandWaterInt is new Ada.Numerics.Discrete_Random(RandWater);

   task type WaterSensor is
      entry Get(L: out RandWater);
   end WaterSensor;

   task body WaterSensor is
      seed: RandWaterInt.Generator;
   begin
      delay 10.0;
      RandWaterInt.Reset(seed);
      loop
         select
             accept Get(L: out RandWater) do
                  L:=RandWaterInt.Random(seed);
               end Get;
            delay 3.0;
         end select;
      end loop;
   end WaterSensor;

   type WaterSensorArray is array (Integer range 1 .. 5) of WaterSensor;
   WaterSensors : WaterSensorArray;

   task CentralTask;

   task body CentralTask is
      N : Integer := 5; -- number of sensors
      Interval : constant Duration := Duration (1);
      L: RandWater;
   begin
      loop
         for I in 1 .. N loop
            select
               WaterSensors(I).Get(L);
               if L = 1 then
                 Put_Line("For Water Sensor " & Integer'Image(I) & " water was detected");
               else
                 Put_Line("For Water Sensor " & Integer'Image(I) & " water wasn't detect");
               end if;
            or
               delay Interval;
               Put_Line("For Water Sensor " & Integer'Image(I) & " Malfunction");
            end select;
         end loop;
         delay 5.0;
      end loop;
   end CentralTask;

begin
   null;

end monitoringWater;
