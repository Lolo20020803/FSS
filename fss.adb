
with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;
with Tools; use Tools;
with devicesFSS_V1; use devicesFSS_V1;

-- NO ACTIVAR ESTE PAQUETE MIENTRAS NO SE TENGA PROGRAMADA LA INTERRUPCION
-- Packages needed to generate button interrupts       
 with Ada.Interrupts.Names;
with Button_Interrupt; use Button_Interrupt;


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
      procedure changeModo;
      function getModo return Boolean;
      private 
        joystick: Joystick_Samples_Type;
        potencia : Power_Samples_Type;
        --Si el modo esta en true esta en modo automatico
        modo: Boolean := False; 
    end objeto_compartido;

    protected body objeto_compartido is
      function getJoystick return Joystick_Samples_Type is 
      auxJoystick : Joystick_Samples_Type;
      begin
        Read_Joystick(auxJoystick);
        return auxJoystick;
      end getJoystick;

      procedure updateJoystick(setJoystick: in Joystick_Samples_Type) is 
      begin
        joystick := setJoystick;
      end updateJoystick;

      function getPotencia return Power_Samples_Type is
        auxPotencia : Power_Samples_Type;
      begin
        Read_Power(auxPotencia);
        return auxPotencia;
      end getPotencia;

      procedure updatePotencia (setPotencia: in Power_Samples_Type) is
      begin
        potencia:= setPotencia;
      end updatePotencia;

      procedure changeModo  is 
      begin
        modo := not modo;
      end changeModo;

      function getModo return Boolean is 
      begin
        return modo;
      end getModo;
    end objeto_compartido;
    -----------------------------------------------------------------------
    ------------- declaration of interruptions 
    -----------------------------------------------------------------------
    protected Objeto_Interrupcion is
      pragma Priority (System.Interrupt_Priority'First+9);
      procedure interrupcion;
      pragma Attach_Handler (interrupcion,
      Ada.Interrupts.Names.External_Interrupt_2);
      entry Esperar_evento;
    private
      Barrera : Boolean := False;
    end Objeto_Interrupcion;
    


    -----------------------------------------------------------------------
    ------------- declaration of tasks 
    -----------------------------------------------------------------------

    --Comprueba la incliancion del joystick y comprueba que no pase de 45º de roll y 30º de pitch
    task altura_y_cabeceo is 
      pragma Priority(3);
    end altura_y_cabeceo;


    --Detecta la colsision con un objeto y avisa con una luz
    task collision_Detector is 
      pragma Priority(4);
    end collision_Detector;
    
    --Comprueba el modo del avion
    task changeMode is 
      pragma Priority(5);
    end changeMode;

    --Hace un display de las variables del avion
    task visualizacion is 
      pragma Priority(1);
    end visualizacion;

    --Varias cosas
    task control_Velocidad is 
      pragma Priority(2);
    end control_Velocidad;


    -----------------------------------------------------------------------
    ------------- body of interruptions------------------------------------ 
    -----------------------------------------------------------------------
    protected body Objeto_Interrupcion is
      procedure Interrupcion is
      begin
        Barrera := True;
      end Interrupcion;
      entry Esperar_Evento when Barrera is
      begin
        Barrera := False;
      end Esperar_Evento;
    end Objeto_Interrupcion;
    -----------------------------------------------------------------------
    ------------- body of tasks 
    -----------------------------------------------------------------------
    -- Aqui se escriben los cuerpos de las tareas 

    task body changeMode is
    begin
      loop
      Start_Activity("Change Mode");
      Objeto_Interrupcion.Esperar_evento;
      objeto_compartido.changeModo;
      Finish_Activity("Change Mode");
      end loop;
    end changeMode;

    task body altura_y_cabeceo is 
        Current_J: Joystick_Samples_Type := (0,0);
        Target_Pitch: Pitch_Samples_Type := 0;
        Target_Roll: Roll_Samples_Type := 0; 
        Aircraft_Pitch: Pitch_Samples_Type; 
        Aircraft_Roll: Roll_Samples_Type;

        Current_A: Altitude_Samples_Type := 8000;
        Siguiente_Instante : Time;
        Intervalo :  Time_Span := Milliseconds(200);
        Leer: Boolean := True;
    begin
      Siguiente_Instante := Clock + Intervalo;
      loop
        Start_Activity ("Prueba_Altitud y Cabeceo");    
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
        
        if (Target_Roll > 35 and Target_Roll <45) then 
            Display_Message("Se esta superando los 35º de roll");
        else if (Target_Roll < -30 and Target_Roll > -45) then 
            Display_Message("Se esta reduciendo los -35º de roll");
        end if;
        end if;

        if (Target_Roll >= 45) then 
          Target_Roll := 45;
          Display_Message("No se puede superar los 45º de roll");
        else if (Target_Roll <= -45)then 
          Target_Roll := -45;
          Display_Message("No se puede reducir los -45º de roll");
        end if;
        end if;
      --El sistema de altura solo funciona en modo automatico es decir modo = true
      if objeto_compartido.getModo then
        if (Current_A >= 10000 and Target_Pitch > 0 ) then 
          Target_Pitch:=0;
          Target_Roll:=0;
          Display_Message ("Altura mayor a 10000 no se puede ascender mas");
        else if (Current_A>=9500 and Current_A < 10000) then 
          Light_1(On);
        else if (Current_A <=2500 and Current_A > 2000) then
          Light_1(On);
        else if (Current_A <=2000 and Target_Pitch < 0) then 
          Target_Pitch:=0;
          Target_Roll:=0;
          Display_Message("Altura menor a 2000 no se puede descender mas");
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


      end if;




      -- Comprueba altitud
      Current_A := Read_Altitude;         -- lee y muestra por display la altitud de la aeronave  
      Finish_Activity("Prueba_Altitud y Cabeceo");
      delay until Siguiente_Instante;
      Siguiente_Instante := Siguiente_Instante + Intervalo;
      end loop;
      
    end altura_y_cabeceo;

    
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
      Start_Activity ("collision_Detector");  
      Read_Distance(Distancia_obstaculo);
      Velocidad:= Read_Speed;
      modo_esquiva := Read_PilotPresence;
      Read_Light_Intensity(visibilidad);
      if natural(modo_esquiva) = 1 or natural(visibilidad)< 500 then 
        tesquiva := 10.0;
        tesquiva1 := 15.0;
      end if;
      --Display_Message("Distancia Impacto "& Float'Image(Float(Distancia_obstaculo)));
      if Distancia_obstaculo <= 5000 then 
        Display_Message("Obstaculo Detectado");
        Display_Message("Velocidad "& Float'Image(Float(Velocidad)));
        tiempo_Impacto :=   Float((Float(Distancia_obstaculo)/Float(Velocidad)));
        Display_Message("Tiempo Colision "& Float'Image(tiempo_Impacto));
      --El sistema solo actua para esquivar en modo automatico es decir modo = true
      if objeto_compartido.getModo then
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
      end if;
      Finish_Activity ("collision_Detector");
      delay until Siguiente_Instante;
      Siguiente_Instante := Siguiente_Instante + Intervalo;
    end loop;
    end collision_Detector;

    --Si pilot 0 esta en modo manual si 1 esta en auto
    
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
      required_power : Power_Samples_Type;
      pitch : Pitch_Samples_Type;
      roll : Roll_Samples_Type;
      Siguiente_Instante : Time;
      Intervalo : Time_Span := Milliseconds(300);  -- Intervalo ajustable

    begin
      Siguiente_Instante := Clock + Intervalo;
      loop
      Start_Activity("control_Velocidad");
      pilot_Power := objeto_compartido.getPotencia;
      velocidad := Speed_Samples_Type(Integer(pilot_Power) * 1.2);
      --Las actuaciones sobre la velocidad solo son en modo automatico modo = true
      if objeto_compartido.getModo then
        if velocidad >= 1000 then
          Light_2(On);
            Set_Speed(Speed_Samples_Type(Float(1000)));
        elsif velocidad <= 300 then
            Light_2(On);
            Set_Speed(Speed_Samples_Type(Float(300)));
        else
          Light_2(Off);
          Set_Speed(velocidad);
        end if;
      else
        Set_Speed(velocidad);
      end if;


      velocidad := Read_Speed;
      pitch := Read_Pitch;
      roll := Read_Roll;
    if objeto_compartido.getModo then
      if roll > 0 then
          if velocidad + 150 > 1000 then
              Set_Speed(1000);
          else
              Set_Speed(Speed_Samples_Type(Float(velocidad)) + 150);
          end if;
      end if;

    
      if pitch /= 0 then
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

      if pitch /= 0 and roll > 0 then
        if  pilot_Power < 1000 then
            if pilot_Power + 250 > 1000 then
            objeto_compartido.updatePotencia(1000);
        else
            objeto_compartido.updatePotencia(pilot_Power + 250);
        end if;


        if velocidad > 1000 then
            Set_Speed(1000);
        else
            Set_Speed(velocidad);
        end if;
      end if;
      end if;
     if pilot_Power < 300 then
         Alarm (5);
     end if;

     if velocidad < 250 then
        required_power := Power_Samples_Type(Float(300)/Float(1.2));
        objeto_compartido.updatePotencia(required_power);
        Set_Speed(Speed_Samples_Type(Float(required_power) * Float(1.2)));
     end if;
    end if;
        Finish_Activity("control_Velocidad");
        delay until Siguiente_Instante;
        Siguiente_Instante := Siguiente_Instante + Intervalo;

     end loop;
    end control_Velocidad;


begin
   null;
end fss;
