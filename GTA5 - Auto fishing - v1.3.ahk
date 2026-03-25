#KeyHistory 0
Process, Priority, , High
SetBatchLines, -1
ListLines, Off
SendMode, Event
SetKeyDelay, -1, 60
CoordMode, Pixel, Window  
CoordMode, Mouse, Window  
CoordMode, ToolTip, Window 


mainWin := 0
coleccionReg := []
stopTimers := false

regionBarraNaranja := crearRegion(675,54,1243,66)
regionBarra := crearRegion(675, 66, 1243, 74)
regionZonaBaja := crearRegion(675, 66, 867, 74)
regionZonaMedio:= crearRegion(868, 66, 1047, 74)
regionZonaAlta := crearRegion(1048, 66, 1243, 74)

coleccionReg.push(regionBarraNaranja)
coleccionReg.push(regionZonaBaja)
coleccionReg.push(regionZonaMedio)
coleccionReg.push(regionZonaAlta)

if !(FileExist("settings.ini")){

	IniWrite, 3000, settings.ini, fishingDelay, fishingMinInterval
	IniWrite, 5000, settings.ini, fishingDelay, fishingMaxInterval

	IniWrite, 20, settings.ini, rescue, rescueTresshold
	IniWrite, 200, settings.ini, rescue, rescueTime
	IniWrite, 60, settings.ini, rescue, pressDuration
	IniWrite, -1, settings.ini, rescue, interval 

	IniWrite, 80, settings.ini, leftSide, pressDuration
	IniWrite, 60, settings.ini, leftSide, interval

	IniWrite, 80, settings.ini, rightSide, rigthDelayTresshold
	IniWrite, 120, settings.ini, rightSide, delay

}

IniRead, fishingMinInterval, settings.ini, fishingDelay, fishingMinInterval, 3000
IniRead, fishingMaxInterval, settings.ini, fishingDelay, fishingMaxInterval, 5000

rescateTiempo := cargarSetting("rescue", "rescueTime", 200)
rescatePuntoLimite := cargarSetting("rescue", "rescueTresshold", 20)
rescatePressDuration := cargarSetting("rescue", "pressDuration", 60)
rescateIntervalo := cargarSetting("rescue", "interval", -1)
	
derechaTiempoMuerto := cargarSetting("rightSide", "delay", 200)
derechaPuntoLimite := cargarSetting("rightSide", "rigthDelayTresshold", 70)

izquierdaPressDuration := cargarSetting("leftSide", "pressDuration", 60)
izquierdaIntervalo := cargarSetting("leftSide", "interval", -1)

puntoRescate := ((regionBarra.x2 - regionBarra.x1) * (rescatePuntoLimite/100)) + regionBarra.x1
;puntoRescatarHasta := ((regionBarra.x2 - regionBarra.x1) * rescatarHastaX) + regionBarra.x1
;puntoObjetivo := ((regionBarra.x2 - regionBarra.x1) * objetivoX) + regionBarra.x1
puntoRelajar := ((regionBarra.x2 - regionBarra.x1) * (derechaPuntoLimite/100)) + regionBarra.x1

Hotkey, ^f12, debugMode
tg:=false
idsReg:=false
gui()
return

f10::
	Critical
	if (tg:=!tg){

		stopTimers := false
		setTimer, script, 2
		showNotificationMsg("GTA5 - Auto fishing On")
	
	}else{

		setTimer, script, Off
		stopTimers := true

		showNotificationMsg("GTA5 - Auto fishing Off")
	}
	
return


2::
	tickCounter(1)
	pt := detectaBarra()
	Tooltip, % tickCounter(0)
	if(pt = 0){

		;showNotificationMsg("Orange bar no found")
		

	}else{

		;showNotificationMsg("Orange bar found!")
		
	}

return


debugMode:


	winActiva := WinExist("A")
	if (winActiva = 0){
		return
	}

	if (winActiva!=mainWin){
		mainWin := winActiva
		if (idsReg!=false){
			destruirColeccionCuadrados(idsReg)
		}
		idsReg := crearColeccionCuadros(winActiva, coleccionReg)
		toggleDebug:=false
		return
	}


	if (toggleDebug:=!toggleDebug){
		
		ocultarColeccionCuadrados(idsReg)
	
	}else{

		mostrarColeccionCuadrados(idsReg)
	}


return


script(){

	Global
	
	static iniciado := 0, prevBar := 0, rescatando := 0, relajar := 0
	static eIntervalo := 0, ePress := 0, eTickFin := 0, eTickIni := 0, eDown := 0
	static empezar := 1
	;static count := 0
	;count++
	;Tooltip, Ejecuciones: %count%, 100, 100, 15

	if (!detectaBarra()){

		if (prevBar = 1){
			
			GoSub, reset
			showNotificationMsg("Catched!?")

			Random, interval, fishingMinInterval, fishingMaxInterval
			Sleep, interval
			SendEvent, {q down}
			Sleep, % normalPD()
			SendEvent, {q up}
			Sleep, % normalIn()
			SendEvent, {e down}
			Sleep, % normalPD()
			SendEvent, {e up}

		}

		showNotificationMsg("No bar!")
		return
	
	}

	prevBar := 1

	agujaPos := trackAguja()
	if (agujaPos = 0){

		if(iniciado){
			GoSub, eControl ;Ejecuta la última configuración si no encuentra la aguja
		}
		return
	
	}
	/*
	if(rescatando = 1){

		;showNotificationMsg("Needle: Rescuing")
		if(agujaPos.x >= puntoRescatarHasta){	
			
			rescatando := 0
			
		}else{
			
			eIntervalo := rescateIn()
			ePress := rescatePD()
			GoSub, eControl
			return
		
		}
	
	}
	*/
	if (agujaPos.x <= puntoRescate){
		
		;showNotificationMsg("Needle: Rescuing")
		
		;iniciado := 1
		;eIntervalo := rescateIn()
		;ePress := rescatePD()
		rescatando := 1
		;GoSub, eControl
		setTimer, rescate, -0, 1
		return
	
	}
	
	
	if (agujaPos.x >= puntoRelajar){

		showNotificationMsg("Needle: Right")
		;iniciado := 1
		;eIntervalo := rightSideDelay
		;GoSub, eControl
		if(iniciado){
			relajarIni := A_tickCount
			relajar := 1
		}
		return
	
	}


	if (agujaPos.x > puntoRescate){
		
		showNotificationMsg("Needle: Left")
		iniciado := 1
		if(relajar){
			if((A_tickCount - relajarIni) >= derechaTiempoMuerto){
				
				relajar := 0

			}else{
				return
			}
		}

		ePress := normalPD()
		eIntervalo := normalIn()
		GoSub, eControl
		
		return
	}

	return



	eControl:
		
		if(!eDown){


			if((A_tickCount - eTickFin) >= eIntervalo){
			
			send, {e down}
			
			eDown := true
			eTickIni := A_tickCount
			eTickFin := 0

			}

			
		}else if(eDown){
		
			if((A_tickCount - eTickIni) >= ePress){ 
				
				send, {e up}
				
				eDown := false
				eTickIni := 0
				eTickFin := A_tickCount
		
			}

		}
		
	return

	rescate:
		
		showNotificationMsg("Rescuing")
		if (empezar){
			;SetKeyDelay, -1, 60
			ini := A_tickCount
			empezar := false
		}
		send, {e down}
		Sleep, % rescatePD()
		send, {e up}
		Sleep, % rescateIn()
		if((A_tickCount - ini) >= rescateTiempo){
			empezar := true
			ini := 0
			setTimer, , off
			return
		}
		setTimer, , -0, 1

	return

	reset:
		iniciado := 0, prevBar := 0, rescatando := 0, relajar := 0, eIntervalo := 0, ePress := 0, eTickFin := 0, eTickIni := 0, eDown := 0
	return	


}

detectaBarra(){

	Global regionZonaBaja, regionZonaMedio, regionZonaAlta

	static cache := 0

	if (cache){

		PixelSearch, fx, fy, cache.x, cache.y, cache.x, cache.y, 0x0312FD , 24
		if (!ErrorLevel){
			return true
		}

		cache := 0
	
	}

	if (cache := pixelSearchDesdeArribaIzquierda(regionZonaBaja, 0x0312FD, 24) 
		&& pixelSearchDesdeArribaIzquierda(regionZonaMedio, 0x04fa0d, 24) 
		&& pixelSearchDesdeArribaIzquierda(regionZonaAlta, 0x01e5fc, 24)){
			return true
		}

	cache := 0
	return false
}


trackAguja(){

	Global regionBarraNaranja
	;regionZonaBaja, regionZonaMedio, regionZonaAlta
	;aguja 24, RGB(0xD09315)  
	static cache := 0
	;punto := 0

	/*
	if (cache){
		punto := pixelSearchDesdeArribaDerecha(cache, 0x1593D0, 32)
		if(punto){
			return punto
		}
		cache := 0
	}
	*/

	
	punto := pixelSearchDesdeArribaIzquierda(regionBarraNaranja, 0x1593D0, 32)
	if(punto){
		;cache := {"x1":regionBarraNaranja.x1, "y1":punto.y, "x2":regionBarraNaranja.x2, "y2":punto.y}
		
		return punto
	}
	
	return 0



	/*
	if (cache){
		
		if (cache = regionZonaBaja){
			punto := pixelSearchDesdeArribaDerecha(regionZonaBaja, 0x1593D0, 24)
			if(punto){
				return punto
			}
		}

		punto := pixelSearchDesdeArribaIzquierda(cache, 0x1593D0, 24)
		if(punto){
			return punto
		}
		
		cache := 0
	}

	punto := pixelSearchDesdeArribaDerecha(regionZonaBaja, 0x1593D0, 24)
	if(punto){
		cache := regionZonaBaja
		return punto
	}

	punto := pixelSearchDesdeArribaIzquierda(regionZonaMedio, 0x1593D0, 24)
	if(punto){
		cache := regionZonaMedio
		return punto
	}

	punto := pixelSearchDesdeArribaIzquierda(regionZonaAlta, 0x1593D0, 24)
	if(punto){
		cache := regionZonaAlta
		return punto
	}

	cache := 0
	return 0 

	*/
}



gui(){
	
	Global puntoRescate, puntoRelajar
	Global rescateTiempo, rescatePuntoLimite, rescatePressDuration, rescateIntervalo, 
	Global derechaTiempoMuerto, derechaPuntoLimite, izquierdaPressDuration, izquierdaIntervalo
	
	;mapa seccion y clave
	static mapa := []
	mapa["rescatePuntoLimite"] := ["rescue","rescueTresshold"]
	mapa["rescateTiempo"] := ["rescue","rescueTime"]
	mapa["rescatePressDuration"] := ["rescue","pressDuration"]
	mapa["rescateIntervalo"] := ["rescue","interval"]
	
	mapa["derechaPuntoLimite"] := ["rightSide", "rigthDelayTresshold"]
	mapa["derechaTiempoMuerto"] := ["rightSide", "delay"]

	mapa["izquierdaPressDuration"] := ["leftSide", "pressDuration"]
	mapa["izquierdaIntervalo"] := ["leftSide", "interval"]

	width := 600
	centroX := width//2
	fontSize := 9
	Global LeftText := 0
	Gui, main:New,
	Gui, main:Color, 272727, E0E0E0
	Gui, Font, cECECEC s%fontSize%, Verdana
	Gui, Margin, 0, 10
	Gui, Add, Slider,  vLeftText

	;RESCUE SECTION
	Gui, main:Add, GroupBox, section x20  w560 Center h160, Rescue Settings
	Gui, main:Add, Text, yp+20 xs+20 w260 Center, Rescue Tresshold (`%):
	Gui, main:Add, Slider, yp xs+%centroX% w250 TickInterval10  Range1-100 ToolTipBottom vrescatePuntoLimite gSave, %rescatePuntoLimite%
	
	Gui, main:Add, Text, xs+20 yp+30 w260 Center, Rescue Time (ms):
	Gui, main:Add, Slider,  yp xs+%centroX% w250 TickInterval100  Range1-1000 ToolTipBottom vrescateTiempo gSave, %rescateTiempo%

	Gui, main:Add, Text, xs+20 yp+30 w260 Center, Rescue Key Press Duration (ms):
	Gui, main:Add, Slider,  yp xs+%centroX% w250 TickInterval20  Range-1-200 ToolTipBottom vrescatePressDuration gSave, %rescatePressDuration%

	Gui, main:Add, Text, xs+20 yp+30 w260 Center, Rescue Key Interval (ms):
	Gui, main:Add, Slider,  yp xs+%centroX% w250 TickInterval20  Range-1-200 ToolTipBottom vrescateIntervalo gSave, %rescateIntervalo%

	;LEFT SIDE SECTION
	Gui, main:Add, GroupBox, section xs ys+180 w560 Center h90, Left Side Settings
	Gui, main:Add, Text, xs+20 yp+20 w260 Center, Key Press Duration (ms):
	Gui, main:Add, Slider, yp xs+%centroX% w250 TickInterval20  Range-1-200 ToolTipBottom vizquierdaPressDuration gSave, %izquierdaPressDuration%

	
	Gui, main:Add, Text, xs+20 yp+30 w260 Center, Key Interval (ms):
	Gui, main:Add, Slider,  Buddy1LeftText yp xs+%centroX% w120 TickInterval20  Range-1-200 ToolTipBottom vizquierdaIntervalo gSave  , %izquierdaIntervalo%
	

	;RIGHT SIDE SECTION
	Gui, main:Add, GroupBox, xs ys+110 w560 Center h90, Right Side Settings
	Gui, main:Add, Text, yp+20 xs+20 w260 Center, Right Side Tresshold (`%):
	Gui, main:Add, Slider, yp xs+%centroX% w250 TickInterval10  Range1-100 ToolTipBottom vderechaPuntoLimite gSave, %derechaPuntoLimite%

	Gui, main:Add, Text, xs+20 yp+30 w260 Center, Delay (ms):
	Gui, main:Add, Slider, yp xs+%centroX% w250 TickInterval100  Range-1-1000 ToolTipBottom vderechaTiempoMuerto gSave, %derechaTiempoMuerto%

	Gui, main:Show, w%width%

	return


	mainGuiClose:
		ExitApp
	return

	save:
		Gui, Submit, NoHide
		registrarSetting(mapa[A_GuiControl][1], mapa[A_GuiControl][2], %A_GuiControl%)
		actualisaPuntosLimite()
	return

	
}

actualisaPuntosLimite(){

	Global puntoRescate, puntoRelajar, regionBarra, rescatePuntoLimite, derechaPuntoLimite

	puntoRescate := ((regionBarra.x2 - regionBarra.x1) * (rescatePuntoLimite/100)) + regionBarra.x1
	puntoRelajar := ((regionBarra.x2 - regionBarra.x1) * (derechaPuntoLimite/100)) + regionBarra.x1

}

rescatePD(){

	Global rescatePressDuration
    Return rescatePressDuration

}

rescateIn(){

	Global rescateIntervalo
    return rescateIntervalo

}

normalPD(){

	Global izquierdaPressDuration
	return izquierdaPressDuration

}

normalIn(){

	Global izquierdaIntervalo
	return izquierdaIntervalo

}	


;###############################################
crearRegion(x1, y1, x2, y2){

	if (x1<0 or y1<0 or x2<0 or y2<0){
		return 0
	}

	if(x2 < x1){
		temp := x1
		x1 := x2
		x2 := temp
	}

	if(y2 < y1){
		temp := y1
		y1 := y2
		y2 := temp
	}

	return {"x1":x1, "y1":y1, "x2":x2, "y2":y2}

}

buscaPixelesRegion(region, coleccionPixeles, variacion := 0){

	loop, % coleccionPixeles.Count(){
		
		PixelSearch, fx, fy, region.x1, region.y1, region.x2, region.y2, coleccionPixeles[A_Index], variacion, fast
		if ErrorLevel
			return false

	}

	return true	

}



crearCuadro(cc:="0xE0E0E0") {
	
	Gui, New, +HwndhwndSquare +AlwaysOnTop -Caption +ToolWindow +E0x08000000 ;+E0x80020
	Gui, Color, %cc%
	return hwndSquare

}

ocultarCuadro(hwndSquare){

	if (!hwndSquare)
		return

	Gui, %hwndSquare%:Hide

}

mostrarCuadro(hwndSquare){

	if (!hwndSquare)
		return

	Gui, %hwndSquare%:Show, NA
}

dibujarCuadro(parentId:=0, hwndSquare:=0, x1:=0, y1:=0, x2:=0, y2:=0, T:=2){
    
    if (!hwndSquare or x1<0 or y1<0 or x2<0 or y2<0)
        return
    if (parentId != 0){
        win := WinExist("ahk_id " parentId)
        if !win
            return
        WinGetPos, wx, wy, _, _, ahk_id %win%
        x1+=wx
        y1+=wy
        x2+=wx
        y2+=wy

    }

    W := x2 - x1
    H := y2 - y1
    w2:=W-T
    h2:=H-T
    Gui, %hwndSquare%: +LastFound 
    Gui, %hwndSquare%: Show, w%W% h%H% x%x1% y%y1% NA
    WinSet, Region, 0-0 %W%-0 %W%-%H% 0-%H% 0-0 %T%-%T% %w2%-%T% %w2%-%h2% %T%-%h2% %T%-%T%

}



crearColeccionCuadros(winHwnd, coleccion){

	ids := []
	loop, % coleccion.Count(){

		ids[A_Index] := crearCuadro()
		dibujarCuadro(winHwnd, ids[A_Index], coleccion[A_Index].x1, coleccion[A_Index].y1, coleccion[A_Index].x2, coleccion[A_Index].y2)
	}

	return ids

}

mostrarColeccionCuadrados(ids){
	
	loop, % ids.Count()
		mostrarCuadro(ids[A_Index]) 
	
}


ocultarColeccionCuadrados(ids){

	loop, % ids.Count()
		ocultarCuadro(ids[A_Index]) 
			
}

destruirColeccionCuadrados(ids){
	
	loop, % ids.Count()
		destruirCuadro(ids[A_Index]) 
	
}

destruirCuadro(hwndSquare){
	
	if (!hwndSquare)
		return

	Gui, %hwndSquare%:Destroy
}

pixelSearchDesdeArribaIzquierda(region, colorID, variacion:=0){
	
	PixelSearch, fx, fy, region.x1, region.y1, region.x2, region.y2, colorID, variacion, fast
	if(ErrorLevel){
		return 0
	}

	return {"x":fx, "y":fy}
}


showNotificationMsg(msg:=""){
    
    Tooltip, % msg,,, 20
    setTimer, quitarTooltip, -2000
    return

    quitarTooltip:
        Tooltip,,,, 20
    return

}

showErrorMsg(msg){

	CoordMode, ToolTip, Screen 
    static toolX := A_ScreenWidth//2
    static toolY := A_ScreenHeight//2

    Tooltip, %msg%, toolX, toolY

}


tickCounter(reset := 0){

    static PrvTick := 0, tickCount := 0
    
    tickCount := A_TickCount

    if (reset){
        
        PrvTick := tickCount
        return tickCount

    }else{

        return (tickCount - PrvTick)

    }
    

}



registrarSetting(seccion, key, valor){

	IniWrite, %valor%, settings.ini, %seccion%, %key%

}

cargarSetting(seccion, key, default:=0){
	
	;Recorrer el archivo i guardar todo en un array, con nombre de seccion y key, transformandolas en globales
	IniRead, OutputVar, settings.ini, %seccion%, %key% , %default%
	return OutputVar

}
