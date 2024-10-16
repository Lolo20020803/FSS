
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
    protected objeto_compartido is
      function getJoystick return Joystick_Samples_Type;
      procedure updateJoystick(setJoystick: in Joystick_Samples_Type); 
      function getPotencia return Power_Samples_Type;
      procedure updatePotencia (setPotencia: in Power_Samples_Type);
      private 
        joystick: Joystick_Samples_Type;
        potencia : Power_Samples_Type;
    end objeto_compartido;

    protected body objeto_compartido is
      function getJoystick return Joystick_Samples_Type is 
      begin
        return joystick;
      end getJoystick;

      procedure updateJoystick(setJoystick: in Joystick_Samples_Type) is 
      begin
        joystick := setJoystick;
      end updateJoystick;

      function getPotencia return Power_Samples_Type is
      begin
        return potencia;
      end getPotencia;

      procedure updatePotencia (setPotencia: in Power_Samples_Type) is
      begin
        potencia:= setPotencia;
      end updatePotencia;
    end objeto_compartido;
    -----------------------------------------------------------------------
    ------------- declaration of tasks 
    -----------------------------------------------------------------------

    --Comprueba la incliancion del joystick y comprueba que no pase de 45º de roll y 30º de pitch
    task check_Jostick is 
      pragma Priority(1);
    end check_Jostick;

    --Actualiza el objeto protegido del joystick cada 10 ms
    task read_Joystick_task is 
      pragma Priority(1);
    end read_Joystick_task;
    
    --Detecta la colsision con un objeto y avisa con una luz
    task collision_Detector is 
      pragma Priority(1);
    end collision_Detector;
    
    --Comprueba el modo del avion
    task changeMode is 
      pragma Priority(1);
    end changeMode;

    --Hace un display de las variables del avion
    task visualizacion is 
      pragma Priority(1);
    end visualizacion;

    --Varias cosas
    task control_Velocidad is 
      pragma Priority(1);
    end control_Velocidad;

    -----------------------------------------------------------------------
    ------------- body of tasks 
    -----------------------------------------------------------------------
    -- Aqui se escriben los cuerpos de las tareas 
    task body read_Joystick_task is 
      Siguiente_Instante : Time;
      Intervalo : Time_Span := Milliseconds(10);

      Current_Joystick: Joystick_Samples_Type:= (0,0);
     
    begin
      Siguiente_Instante := Clock + Intervalo;
    loop
      Start_Activity ("Leer Joystick");    
      Read_Joystick(Current_Joystick);
     objeto_compartido.updateJoystick(Current_Joystick);
      Finish_Activity("Leer Joystick");
      delay until Siguiente_Instante;
      Siguiente_Instante := Siguiente_Instante + Intervalo;

    end loop;
    end read_Joystick_task;


    task body check_Jostick is 
        Current_J: Joystick_Samples_Type := (0,0);
        Target_Pitch: Pitch_Samples_Type := 0;
        Target_Roll: Roll_Samples_Type := 0; 
        Aircraft_Pitch: Pitch_Samples_Type; 
        Aircraft_Roll: Roll_Samples_Type;

        Current_A: Altitude_Samples_Type := 8000;
        Siguiente_Instante : Time;
        Intervalo :  Time_Span := Milliseconds(50);
        Leer: Boolean := True;
    begin
      Siguiente_Instante := Clock + Intervalo;
      Start_Activity("check_Jostick_task");
      loop
        Start_Activity ("Prueba_Altitud");    
        -- Lee Joystick del piloto
        
     
        Current_J := objeto_compartido.getJoystick;        
    
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
        
        if (Target_Roll > 35) then 
            Display_Message("Se esta superando los 35º de pitch");
          else if Target_Roll < -30 then 
            Display_Message("Se esta reduciendo los -35º de pitch");
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
        if (Current_A >= 10000 and Target_Pitch > 0 ) then 
          Target_Pitch:=0;
          Target_Roll:=0;
          Display_Message ("To high");
        else if (Current_A>=9500 and Current_A < 10000) then 
          Light_1(On);
        else if (Current_A <=2500 and Current_A > 2000) then
          Light_1(On);
        else if (Current_A <=2000 and Target_Pitch < 0) then 
          Target_Pitch:=0;
          Target_Roll:=0;
        else 
          Light_1(Off);
        end if;
        end if;
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
            
        Finish_Activity ("Prueba_Altitud");   
        delay until Siguiente_Instante;
        Siguiente_Instante := Siguiente_Instante + Intervalo;
      end loop;
      Finish_Activity("check_Jostick_task");
    end check_Jostick;

    
    task body collision_Detector is 
      Distancia_obstaculo: Distance_Samples_Type := 0;
      Velocidad : Speed_Samples_Type := 0;
      tiempo_Impacto : Float := 0.0;
      altitud : Altitude_Samples_Type := 0;
      iteraciones : Integer := 0;
      modo_esquiva : PilotPresence_Samples_Type;
      tesquiva : Float := 5.0;
      tesquiva1 : Float := 10.0;
      visibilidad: Light_Samples_Type;

      Siguiente_Instante : Time;
      Intervalo : Time_Span := Milliseconds(250);


    begin
      Siguiente_Instante := Clock + Intervalo;
    loop
      
      Read_Distance(Distancia_obstaculo);
      Set_Speed(1100);
      Velocidad:= Read_Speed;
      modo_esquiva := Read_PilotPresence;
      Read_Light_Intensity(visibilidad);
      if natural(modo_esquiva) = 1 or natural(visibilidad)< 500 then 
        tesquiva := 10.0;
        tesquiva1 := 15.0;
      end if;
      Display_Message("Distancia Impacto "& Float'Image(Float(Distancia_obstaculo)));
      if Distancia_obstaculo <= 5000 then 
        Display_Message("Obstaculo Detectado");
        Display_Message("Velocidad "& Float'Image(Float(Velocidad)));
        tiempo_Impacto :=   Float((Float(Distancia_obstaculo)/Float(Velocidad)));
        Display_Message("Tiempo Colision "& Float'Image(tiempo_Impacto));
        if tiempo_Impacto <= tesquiva then
          altitud:= Read_Altitude;
          if  (altitud > 8500 and iteraciones < 12)   then 
            Display_Message("Esquiva Pitch");
            Set_Aircraft_Pitch(45);
            iteraciones := iteraciones + 1;
          else
            Display_Message("Esquiva Roll");
            Set_Aircraft_Roll(20);
            iteraciones := iteraciones + 1;
          end if;
        else if tiempo_Impacto <= tesquiva1 then
          Alarm(4);
        else 
          iteraciones := 0;
        end if;
        end if;
      end if;
      delay until Siguiente_Instante;
      Siguiente_Instante := Siguiente_Instante + Intervalo;
    end loop;
    end collision_Detector;

    --Si pilot 0 esta en modo manual si 1 esta en auto
    task body changeMode is
      mode : PilotButton_Samples_Type;
    begin
      mode := Read_PilotButton;
    end changeMode;

    task body visualizacion is 

      Siguiente_Instante : Time;
      Intervalo : Time_Span := Milliseconds(1000);
      power : Power_Samples_Type;

    begin      
      Siguiente_Instante := Clock + Intervalo;
      loop
        Start_Activity("Monitoreo");
        
        Display_Altitude(Read_Altitude);
        
        power := objeto_compartido.getPotencia;
        Display_Pilot_Power(power);        
        Display_Speed(Read_Speed);

        Display_Joystick (objeto_compartido.getJoystick);

        Finish_Activity("Monitoreo");
        delay until Siguiente_Instante;
        Siguiente_Instante := Siguiente_Instante + Intervalo;
      end loop;
    end visualizacion;



    task body control_Velocidad is
      pilot_Power : Power_Samples_Type;
      velocidad : Speed_Samples_Type;
      Current_JT : Joystick_Samples_Type;
      required_power : Power_Samples_Type;
      Siguiente_Instante : Time;
      Intervalo : Time_Span := Milliseconds(5);  -- Intervalo ajustable

    begin
      loop
      pilot_Power := objeto_compartido.getPotencia;
      --velocidad := Speed_Samples_Type(Integer(pilot_Power) * 1.2);
      velocidad := Read_Speed;

      if velocidad >= 1000 then
        Light_2(On);
        Set_Speed(Speed_Samples_Type(Float(1000)));
      elsif velocidad <= 300 then
          Light_2(On);
          Set_Speed(Speed_Samples_Type(Float(300)));
      else
        Set_Speed(velocidad);
      end if;

      velocidad := Read_Speed;
      Current_JT := objeto_compartido.getJoystick;

      if Current_JT(y) > 0 then
          if velocidad + 150 > 1000 then
              Set_Speed(1000);
          else
              Set_Speed(Speed_Samples_Type(Float(velocidad)) + 150);
          end if;
      end if;


      velocidad := Read_Speed;
      if Current_JT(x) /= 0 then
          if  pilot_Power < 1000 then
        if pilot_Power + 100 > 1000 then
            objeto_compartido.updatePotencia(1000);
        else
            objeto_compartido.updatePotencia(pilot_Power + 100);
        end if;

        velocidad := Read_Speed;
        if velocidad > 1000 then
            Set_Speed(1000);
        else
            Set_Speed(velocidad);
        end if;
     end if;
     end if;

    velocidad := Read_Speed;
    if Current_JT(x) /= 0 and Current_JT(y) > 0 then
        if  pilot_Power < 1000 then
            if pilot_Power + 250 > 1000 then
            objeto_compartido.updatePotencia(1000);
        else
            objeto_compartido.updatePotencia(pilot_Power + 250);
        end if;

        velocidad := Read_Speed;
        if velocidad > 1000 then
            Set_Speed(1000);
        else
            Set_Speed(velocidad);
        end if;
     end if;
     end if;

     velocidad := Read_Speed;
     if pilot_Power < 300 then
         Alarm (5);
     end if;

     if velocidad < 250 then
    	required_power := Power_Samples_Type(Float(300)/Float(1.2));
    	objeto_compartido.updatePotencia(required_power);
    	Set_Speed(Speed_Samples_Type(Float(required_power) * Float(1.2)));
     end if;

     Finish_Activity("control_Velocidad");
        delay until Siguiente_Instante;
        Siguiente_Instante := Siguiente_Instante + Intervalo;

     end loop;
    end control_Velocidad;


begin
   null;
end fss;



