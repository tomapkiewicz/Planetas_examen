USE [Examen]
GO
/****** Object:  StoredProcedure [dbo].[pronostico_calcular]    Script Date: 09/10/2019 19:14:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[pronostico_calcular] as 
begin
	delete PicoLluvia
	delete Planeta_posicion
	delete Pronostico
		 
	declare @i numeric(25,10) = 1 

   declare @picoLluvia int = 0
   declare @max numeric(25,10) =0
        
	declare @disFerengi numeric(25,10)  = (select distancia from Planeta where Nombre ='Ferengi')
	
	declare @disBetasoide numeric(25,10) = (select distancia from Planeta where Nombre ='Betasoide')
	declare @disVulcano numeric(25,10) = (select distancia from Planeta where Nombre ='Vulcano')

	declare @VelFerengi numeric(25,10) = (select Velocidad_angular from Planeta where Nombre ='Ferengi')
	declare @VelBetasoide numeric(25,10) = (select Velocidad_angular from Planeta where Nombre ='Betasoide')
	declare @VelVulcano numeric(25,10) = (select Velocidad_angular from Planeta where Nombre ='Vulcano')

	while(@i<3651)
	begin
			declare @XF numeric(25,10) =  @disFerengi * cos(@velFerengi*PI()/180 * @i)
			declare @YF numeric(25,10) =  @disFerengi * sin(@velFerengi*PI()/180 * @i)
			declare @MFerengi numeric(25,10) = @YF / nullif(@XF,0)
	
			declare @XB numeric(25,10) =  @disBetasoide * cos(@velBetasoide*PI()/180 * @i)
			declare @YB numeric(25,10) =  @disBetasoide * sin(@velBetasoide*PI()/180 * @i)
	
			declare @XV numeric(25,10) =  @disVulcano * cos(@velVulcano*PI()/180 * @i)
			declare @YV numeric(25,10) =  @disVulcano * sin(@velVulcano*PI()/180 * @i)
	
			declare @MFB numeric(25,10) = (@YF-@YB)/nullif((@XF- @XB),0)
            declare @MVB numeric(25,10) = (@YV-@YB)/nullif((@XV- @XB),0)
            
            insert into Pronostico(Dia,Hay_lluvia,Hay_optimas_condiciones,Hay_sequia)
            values(@i,0,0,0)

			declare @hay_optimas bit = 0 
            if(abs(@MFerengi-@MFB)>0.0001 and abs(@MFB-@MVB)<0.01 )
            begin 
				set @hay_optimas = 1 
				update Pronostico set hay_optimas_condiciones = @hay_optimas where Dia = @i 
			end
           declare @ii int=  @i%360
		declare @auxFerengi numeric(25,10) = abs(@velFerengi*@ii)%180
		declare @auxBetasoide numeric(25,10) = abs(@velBetasoide*@ii)%180
		declare @auxVulcano numeric(25,10) = abs(@velVulcano*@ii)%180
  
		declare @hay_sequia bit = 0 
		 if(@auxFerengi=@auxBetasoide and @auxBetasoide = @auxVulcano)
             begin
            set @hay_sequia = 1 
            update Pronostico set Hay_sequia = @hay_sequia where Dia = @i 
			end 
			--  Point2D posSol =  new Point2D.Double(0,0);
            declare @hayLluvia bit = dbo.ptInTriangle(0,0,@XV,@YV,@XB,@YB,@XF,@YF)
 
			declare @lluvias int 
            if(@hayLluvia = 1 and @hay_sequia= 0 and @hay_optimas = 0 )
            update Pronostico set Hay_lluvia = 1 where Dia = @i
           
         declare @ladoA numeric(25,10) =  sqrt (square(@xf-@xb) + square (@yf-@yb) )
         declare @ladoB numeric(25,10) =  sqrt (square(@xf-@xv) + square (@yf-@yv) )
         declare @ladoC numeric(25,10) =  sqrt (square(@xb-@xv) + square (@yb-@yv) )
          declare @perimetro numeric(25,10) = @ladoA + @ladoB + @ladoC 
          update Pronostico set Perimetro = @perimetro where Dia= @i  
          
             if (@perimetro > @max)
            begin
              set  @max = @perimetro
               set @picoLluvia = @i
            end
            update picoLluvia set 
            Dia_pico_lluvia  = @i ,
            perimetro = @perimetro
            
            insert into Planeta_posicion (Dia,Planeta_nombre,Posicion_X,Posicion_Y)
            values(@i,'Ferengi',@XF,@YF)
            insert into Planeta_posicion (Dia,Planeta_nombre,Posicion_X,Posicion_Y)
            values(@i,'Betasoide',@XB,@YB)
            insert into Planeta_posicion (Dia,Planeta_nombre,Posicion_X,Posicion_Y)
            values(@i,'Vulcano',@XV,@YV)
            
			set @i=@i+1
	
	
	end 

end 

 