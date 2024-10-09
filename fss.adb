
with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;
with Tools; use Tools;
with devicesFSS_V1; use devicesFSS_V1;

-- NO ACTIVAR ESTE PAQUETE MIENTRAS NO SE TENGA PROGRAMADA LA INTERRUPCION
-- Packages needed to generate button interrupts       
-- with Ada.Interrupts.Names;
-- with Button_Interrupt; use Button_Interrupt;


package body fss is

    ----------------------------------------------------------------------
    ------------- procedure exported 
    ----------------------------------------------------------------------
    procedure Background is
    begin
      loop
        null;
      end loop;
    end Background;
    ----------------------------------------------------------------------

    -----------------------------------------------------------------------
    ------------- declaration of protected objects 
    -----------------------------------------------------------------------

    -- Aqui se declaran los objetos protegidos para los datos compartidos  
    protected joystick_compartido is
      function getJoystick return Joystick_Samples_Type;
      procedure updateJoystick(setJoystick: Joystick_Samples_Type); 
      private 
        joystick: Joystick_Samples_Type;
    end joystick_compartido;

    protected body joystick_compartido is
      function getJoystick return Joystick_Samples_Type is 
      begin
        return joystick;
      end getJoystick;
      procedure updateJoystick(setJoystick: Joystick_Samples_Type) is 
      begin
        joystick := setJoystick;
      end updateJoystick;
    end joystick_compartido;
    -----------------------------------------------------------------------
    ------------- declaration of tasks 
    -----------------------------------------------------------------------

    -- Aqui se declaran las tareas que forman el STR
    task check_Jostick is 
      pragma Priority(1);
    end check_Jostick;

    task read_Joystick is 
      pragma Priority(1);
    end read_Joystick;
    
    task collision_Detector is 
      pragma Priority(1);
    end collision_Detector;

    -----------------------------------------------------------------------
    ------------- body of tasks 
    -----------------------------------------------------------------------
    -- Aqui se escriben los cuerpos de las tareas 
    task body read_Joystick is 
      Siguiente_Instante : Time;
      Intervalo : Time_Span := Milliseconds(10);

      Current_Joystick: Joystick_Samples_Type:= (0,0);
     
    begin
      Siguiente_Instante := Clock + Intervalo;
    loop
      Start_Activity ("Leer Joystick");    
      --Read_Joystick(Current_Joystick);
      joystick_compartido.updateJoystick(Current_Joystick);
      Finish_Activity("Leer Joystick");
      delay until Siguiente_Instante;
      Siguiente_Instante := Siguiente_Instante + Intervalo;

    end loop;
    end read_Joystick;



    task body check_Jostick is 
        Current_J: Joystick_Samples_Type := (0,0);
        Target_Pitch: Pitch_Samples_Type := 0;
        Target_Roll: Roll_Samples_Type := 0; 
        Aircraft_Pitch: Pitch_Samples_Type; 
        Aircraft_Roll: Roll_Samples_Type;

        Current_A: Altitude_Samples_Type := 8000;
        Siguiente_Instante : Time;
        Intervalo :  Time_Span := Milliseconds(50);
    begin
      Siguiente_Instante := Clock + Intervalo;
      Start_Activity("check_Jostick_task");
      loop
        Start_Activity ("Prueba_Altitud");    
        -- Lee Joystick del piloto

        Current_J := joystick_compartido.getJoystick;        
        -- establece Pitch y Roll en la aeronave
        Target_Pitch := Pitch_Samples_Type (Current_J(x));
        Target_Roll := Roll_Samples_Type (Current_J(y));

        if (Target_Pitch > 30) then 
          Target_Pitch := 30;
            Display_Message("No se puede superar los 30º de pitch");
          else if Target_Pitch < -30 then 
            Target_Pitch := -30;
            Display_Message("No se puede reducir los -30º de pitch");
        end if;
        end if;

        if (Target_Roll > 45) then 
          Target_Roll := 45;
          Display_Message("No se puede superar los 45º de roll");
        else if Target_Roll < -45 then 
          Target_Roll := -45;
          Display_Message("No se puede reducir los -45º de roll");
        end if;
        end if;

        Set_Aircraft_Pitch (Target_Pitch);  -- transfiere el movimiento pitch a la aeronave
        Set_Aircraft_Roll (Target_Roll);    -- transfiere el movimiento roll  a la aeronave 
                       
        Aircraft_Pitch := Read_Pitch;       -- lee la posición pitch de la aeronave
        Aircraft_Roll := Read_Roll;         -- lee la posición roll  de la aeronave
            
        Display_Joystick (Current_J);       -- muestra por display el joystick  
        Display_Pitch (Aircraft_Pitch);     -- muestra por display la posición de la aeronave  
        Display_Roll (Aircraft_Roll);

        -- Comprueba altitud
        Current_A := Read_Altitude;         -- lee y muestra por display la altitud de la aeronave  
        Display_Altitude (Current_A);
            
        if (Current_A >= 10000) then Alarm (2); 
          Display_Message ("To high");
        end if; 
        Finish_Activity ("Prueba_Altitud");   
        delay until Siguiente_Instante;
        Siguiente_Instante := Siguiente_Instante + Intervalo;
      end loop;
      Finish_Activity("check_Jostick_task");
    end check_Jostick;

    -- dist > 5000 no obs
    -- si timpac < 10 s alarma 4 
    -- si timpac < 5 s esquiva
    -- si visib < 500 / no piloto lo de nates pasa a 15 y 10 s respec
    -- Esquivo: si alt <= 8500 cabeceo +20 en 3 seg 
    --          si alt > 8500 alabeo = 45º derecha en 3 seg 
    -- Luego estabiliza 
    -- Cada 250 ms 
          

    task body collision_Detector is 
      Distancia_obstaculo: Distance_Samples_Type := 0;
      Velocidad : Speed_Samples_Type := 0;
      tiempo_Impacto : Float := 0.0;
      altitud : Altitude_Samples_Type := 0;
      iteraciones : Integer := 0;
      modo_esquiva : PilotPresence_Samples_Type;
      tesquiva : Float := 5.0;
      tesquiva1 : Float := 10.0;
    begin
    loop
      
      Read_Distance(Distancia_obstaculo);
      Velocidad:= Read_Speed;
      modo_esquiva := Read_PilotPresence;
      if natural(modo_esquiva) = 1 then 
        tesquiva := 10.0;
        tesquiva1 := 15.0;
      end if;
      if Distancia_obstaculo <= 5000 then 
        tiempo_Impacto :=   Float((Float(Distancia_obstaculo)/Float(Velocidad))) * Float(3600) ;      
        if tiempo_Impacto <= tesquiva then
          altitud:= Read_Altitude;
          if altitud > 8500 and iteraciones < 12   then 
            Set_Aircraft_Pitch(45);
            iteraciones := iteraciones + 1;
          else
            Set_Aircraft_Roll(20);
            iteraciones := iteraciones + 1;
          end if;
        else if tiempo_Impacto <= tesquiva1 then
          Alarm(4);
        end if;
        end if;
      end if;
    end loop;
    end collision_Detector;



    ----------------------------------------------------------------------
    ------------- procedimientos para probar los dispositivos 
    ------------- SE DEBERÁN QUITAR PARA EL PROYECTO
    ----------------------------------------------------------------------
    Procedure Prueba_Sensores_Piloto is
        Current_Pp: PilotPresence_Samples_Type := 1;
        Current_Pb: PilotButton_Samples_Type := 0;
    begin

         for I in 1..120 loop
            Start_Activity ("Prueba_Piloto");                
            -- Prueba presencia piloto
            Current_Pp := Read_PilotPresence;
            if (Current_Pp = 0) then Alarm (1); end if;   
            Display_Pilot_Presence (Current_Pp);
                 
            -- Prueba botón para selección de modo 
            Current_Pb := Read_PilotButton;            
            Display_Pilot_Button (Current_Pb); 
            
            Finish_Activity ("Prueba_Piloto");  
         delay until (Clock + To_time_Span(0.1));
         end loop;

         Finish_Activity ("Prueba_Piloto");
    end Prueba_Sensores_Piloto;


begin
   null;
end fss;



