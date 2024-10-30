with Ada.Real_Time; use Ada.Real_Time;
with devicesfss_v1; use devicesfss_v1;

package Scenario_V1 is

    ---------------------------------------------------------------------
    ------ Access time for devices
    ---------------------------------------------------------------------
    WCET_Distance: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_Light: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    
    WCET_Joystick: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_PilotPresence: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_PilotButton: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    
    WCET_Power: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(4);
    
    WCET_Speed: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(7);
    WCET_Altitude: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(18);

    WCET_Pitch: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(20);
    WCET_Roll: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(18);

    WCET_Display: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(15);
    WCET_Alarm: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);

    ---------------------------------------------------------------------
    ------ SCENARIO ----------------------------------------------------- 
    ---------------------------------------------------------------------
    -- Initial_Altitude: Altitude_Samples_Type := 8000;
    
    ---------------------------------------------------------------------
    ------ DISTANCE OK---------------------------------------------------
    cantidad_datos_Distancia: constant := 200;
    type Indice_Secuencia_Distancia is mod cantidad_datos_Distancia;
    type tipo_Secuencia_Distancia is array (Indice_Secuencia_Distancia) of Distance_Samples_Type;

    Distance_Simulation: tipo_Secuencia_Distancia :=  -- next sample every 100ms.
            ( 5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 1s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 2s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 3s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 4s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 5s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 6s. 
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 7s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 8s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 9s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 10s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 11s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 12s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 13s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 14s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 15s. 
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 16s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 17s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 18s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 19s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555);  -- 20s.
                   
    ---------------------------------------------------------------------
    ------ LIGHT OK------------------------------------------------------

    cantidad_datos_Light: constant := 200;
    type Indice_Secuencia_Light is mod cantidad_datos_Light;
    type tipo_Secuencia_Light is array (Indice_Secuencia_Light) of Light_Samples_Type;

    Light_Intensity_Simulation: tipo_Secuencia_Light :=  -- 1 muestra cada 100ms.
                 ( 700,700,700,700,700, 700,700,700,700,700,   -- 1s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 2s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 3s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 4s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 5s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 6s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 7s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 8s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 9s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 10s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 11s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 12s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 13s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 14s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 15s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 16s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 17s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 18s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 19s.
                   700,700,700,700,700, 700,700,700,700,700);  -- 20s.
    ---------------------------------------------------------------------
    ------ JOYSTICK OK---------------------------------------------------

    cantidad_datos_Joystick: constant := 200;
    type Indice_Secuencia_Joystick is mod cantidad_datos_Joystick;
    type tipo_Secuencia_Joystick is array (Indice_Secuencia_Joystick) 
                                             of Joystick_Samples_Type;

    Joystick_Simulation: tipo_Secuencia_Joystick :=  -- 1 muestra cada 100ms.
                ((+50,+03),(+50,+03),(+50,+01),(+50,+00),(+50,-03),  
                 (+50,+03),(+50,+03),(+50,+01),(+50,+00),(+50,-03),  --1s.Subida brusca
 
                 (+50,+03),(+50,+03),(+50,+01),(+50,+00),(+50,-03),  
                 (+50,+03),(+50,+03),(+50,+01),(+50,+00),(+50,-03),  --2s. Subida brusca

                 (+50,+03),(+50,+03),(+50,+01),(+50,+00),(+50,-03),  
                 (+50,+03),(+50,+03),(+50,+01),(+50,+00),(+50,-03),  --3s.Subida brusca

                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),  
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),   --4s. mantiene recto

                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),  
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),   --5s. mantiene recto
                  
                 (-50,+00),(-50,+00),(-50,+00),(-50,+00),(-50,+00),  
                 (-50,+00),(-50,+00),(-50,+00),(-50,+00),(-50,+00),  --6s. descenso brusco
 
                 (-50,+00),(-50,+00),(-50,+00),(-50,+00),(-50,+00),  
                 (-50,+00),(-50,+00),(-50,+00),(-50,+00),(-50,+00),  --7s. descenso brusco

                 (-50,+00),(-50,+00),(-50,+00),(-50,+00),(-50,+00),  
                 (-50,+00),(-50,+00),(-50,+00),(-50,+00),(-50,+00),  --8s. descenso brusco

                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),  
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),   --9s. mantiene recto

                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),  
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),   --10s. mantiene recto
                 
                 (+50,+03),(+50,+03),(+50,+01),(+50,+00),(+50,-03),  
                 (+50,+03),(+50,+03),(+50,+01),(+50,+00),(+50,-03),  --11s.Subida brusca
 
                 (+50,+03),(+50,+03),(+50,+01),(+50,+00),(+50,-03),  
                 (+50,+03),(+50,+03),(+50,+01),(+50,+00),(+50,-03),  --12s. Subida brusca

                 (+50,+03),(+50,+03),(+50,+01),(+50,+00),(+50,-03),  
                 (+50,+03),(+50,+03),(+50,+01),(+50,+00),(+50,-03),  --13s.Subida brusca

                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),  
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),   --14s. mantiene recto

                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),  
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),   --15s. mantiene recto
                  
                 (-50,+00),(-50,+00),(-50,+00),(-50,+00),(-50,+00),  
                 (-50,+00),(-50,+00),(-50,+00),(-50,+00),(-50,+00),  --16s. descenso brusco
 
                 (-50,+00),(-50,+00),(-50,+00),(-50,+00),(-50,+00),  
                 (-50,+00),(-50,+00),(-50,+00),(-50,+00),(-50,+00),  --17s. descenso brusco

                 (-50,+00),(-50,+00),(-50,+00),(-50,+00),(-50,+00),  
                 (-50,+00),(-50,+00),(-50,+00),(-50,+00),(-50,+00),  --18s. descenso brusco

                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),  
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),   --19s. mantiene recto

                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00),  
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,-00)); --20 mantiene recto
                 
    ---------------------------------------------------------------------
    ------ POWER OK------------------------------------------------------
    cantidad_datos_Power: constant := 200;
    type Indice_Secuencia_Power is mod cantidad_datos_Power;
    type tipo_Secuencia_Power is array (Indice_Secuencia_Power) of Power_Samples_Type;

    Power_Simulation: tipo_Secuencia_Power :=  -- next sample every 100ms.
                 ( 800,800,800,800,800, 800,800,800,800,800,   -- 1s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 2s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 3s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 4s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 5s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 6s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 7s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 8s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 9s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 10s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 11s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 12s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 13s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 14s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 15s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 16s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 17s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 18s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 19s.
                   900,900,800,800,800, 800,800,800,800,800 ); -- 20s.


    ---------------------------------------------------------------------
    ------ PILOT'S PRESENCE ---------------------------------------------

    cantidad_datos_PilotPresence: constant := 200;
    type Indice_Secuencia_PilotPresence is mod cantidad_datos_PilotPresence;
    type tipo_Secuencia_PilotPresence is array (Indice_Secuencia_PilotPresence) of PilotPresence_Samples_Type;

    PilotPresence_Simulation: tipo_Secuencia_PilotPresence :=  -- 1 muestra cada 100ms.
                 ( 1,1,1,1,1, 1,1,1,1,1,   -- 1s. 
                   1,1,1,1,1, 1,1,1,1,1,   -- 2s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 3s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 4s. 
                   1,1,1,1,1, 1,1,1,1,1,   -- 5s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 6s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 7s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 8s. 
                   1,1,1,1,1, 1,1,1,1,1,   -- 9s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 10s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 11s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 12s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 13s. 
                   1,1,1,1,1, 1,1,1,1,1,   -- 14s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 15s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 16s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 17s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 18s. 
                   1,1,1,1,1, 1,1,1,1,1,   -- 19s.
                   1,1,1,1,1, 1,1,1,1,1);  -- 20s.  


    cantidad_datos_PilotButton: constant := 200;
    type Indice_Secuencia_PilotButton is mod cantidad_datos_PilotButton;
    type tipo_Secuencia_PilotButton is array (Indice_Secuencia_PilotButton) of PilotButton_Samples_Type;

    PilotButton_Simulation: tipo_Secuencia_PilotButton :=  -- 1 muestra cada 100ms.
                 ( 0,0,0,0,0, 0,0,0,0,0,   -- 1s. 
                   0,0,0,0,0, 1,1,1,0,0,   -- 2s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 3s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 4s. 
                   1,1,1,1,0, 0,0,0,0,0,   -- 5s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 6s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 7s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 8s. 
                   0,0,0,0,0, 0,0,0,0,0,   -- 9s.
                   0,0,0,0,0, 0,0,0,0,0,  -- 10s.                   
                   0,0,0,0,0, 0,0,0,0,0,   -- 11s. 
                   0,0,0,0,0, 1,1,1,1,1,   -- 12s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 13s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 14s. 
                   0,0,0,0,0, 0,0,0,0,0,   -- 15s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 16s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 17s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 18s. 
                   0,0,0,0,0, 0,0,0,0,0,   -- 19s.
                   0,0,0,0,0, 0,0,0,0,0);  -- 20s.                 
end Scenario_V1;



