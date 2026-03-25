#SingleInstance, Force

gui()
return




gui(){
	
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

	Gui, main:New,
	Gui, main:Color, 272727, E0E0E0
	Gui, Font, cECECEC s%fontSize%, Verdana
	Gui, Margin, 0, 10

	;RESCUE SECTION
	Gui, main:Add, GroupBox, section x20  w560 Center h160, Rescue Settings
	Gui, main:Add, Text, yp+20 xs+20 w260 Center, Rescue Tresshold:
	Gui, main:Add, Slider, yp xs+%centroX% w250 TickInterval10  Range1-100 ToolTipBottom vrescatePuntoLimite gSave, %rescatePuntoLimite%
	
	Gui, main:Add, Text, xs+20 yp+30 w260 Center, Rescue Time:
	Gui, main:Add, Slider,  yp xs+%centroX% w250 TickInterval100  Range1-1000 ToolTipBottom vrescateTiempo gSave, %rescateTiempo%

	Gui, main:Add, Text, xs+20 yp+30 w260 Center, Rescue Key Press Duration:
	Gui, main:Add, Slider,  yp xs+%centroX% w250 TickInterval20  Range-1-200 ToolTipBottom vrescatePressDuration gSave, %rescatePressDuration%

	Gui, main:Add, Text, xs+20 yp+30 w260 Center, Rescue Key Interval:
	Gui, main:Add, Slider,  yp xs+%centroX% w250 TickInterval20  Range-1-200 ToolTipBottom vrescateIntervalo gSave, %rescateIntervalo%

	;LEFT SIDE SECTION
	Gui, main:Add, GroupBox, section xs ys+180 w560 Center h90, Left Side Settings
	Gui, main:Add, Text, xs+20 yp+20 w260 Center, Key Press Duration:
	Gui, main:Add, Slider, yp xs+%centroX% w250 TickInterval20  Range-1-200 ToolTipBottom vizquierdaPressDuration gSave, %izquierdaPressDuration%

	Gui, main:Add, Text, xs+20 yp+30 w260 Center, Key Interval:
	Gui, main:Add, Slider,  yp xs+%centroX% w250 TickInterval20  Range-1-200 ToolTipBottom vizquierdaIntervalo gSave, %izquierdaIntervalo%

	;RIGHT SIDE SECTION
	Gui, main:Add, GroupBox, xs ys+110 w560 Center h90, Right Side Settings
	Gui, main:Add, Text, yp+20 xs+20 w260 Center, Right Side Tresshold:
	Gui, main:Add, Slider, yp xs+%centroX% w250 TickInterval10  Range1-100 ToolTipBottom vderechaPuntoLimite gSave, %derechaPuntoLimite%

	Gui, main:Add, Text, xs+20 yp+30 w260 Center, Delay:
	Gui, main:Add, Slider, yp xs+%centroX% w250 TickInterval100  Range-1-1000 ToolTipBottom vderechaTiempoMuerto gSave, %derechaTiempoMuerto%

	Gui, main:Show, w%width%

	return


	mainGuiClose:
		ExitApp
	return

	save:
		Gui, Submit, NoHide
		registrarSetting(mapa[A_GuiControl][1], mapa[A_GuiControl][2], %A_GuiControl%)
	return
}


registrarSetting(seccion, key, valor){

	IniWrite, %valor%, settings.ini, %seccion%, %key%

}

cargarSetting(seccion, key){
	
	;Recorrer el archivo i guardar todo en un array, con nombre de seccion y key, transformandolas en globales
	IniRead, OutputVar, settings.ini, %seccion%, %key% , 0
	return OutputVar

}




/*
	IniWrite, 0.20, settings.ini, rescue, rescueTresshold
	IniWrite, 200, settings.ini, rescue, rescueTime
	IniWrite, 60, settings.ini, rescue, pressDuration
	IniWrite, -1, settings.ini, rescue, interval 

	IniWrite, 60, settings.ini, leftSide, pressDuration
	IniWrite, -1, settings.ini, leftSide, interval

	IniWrite, 0.80, settings.ini, rightSide, rigthDelayTresshold
	IniWrite, 120, settings.ini, rightSide, delay



*/

/*
	modoId := cargarSettings("mode")
	if(!modoId){
		modoId := 1
	}

	delayDropdown := cargarSettings("delayDropdown")
	if(!delayDropdown){
		delayDropdown := 30
	}

	Gui, main:New, AlwaysOnTop
	Gui, main:Add, Text, Center , Mode


	if(modoId = 1){
		Gui, main:Add, Radio, Group vmodoId Checked, Hidden Click
	}else{
		Gui, main:Add, Radio, Group vmodoId, Hidden Click
	}

	if(modoId = 2){
		Gui, main:Add, Radio,  Checked, Fast Clik
	}else{
		Gui, main:Add, Radio, , Fast Clik
	}
	
	Gui, main:Add, Text, Center , Ajust delay menu in milliseconds
	Gui, main:Add, Slider, TickInterval100 vdelayMenu Range-1-1000 w150 ToolTipBottom , %delayMenu%
	Gui, main:Add, Text, Center , Ajust delay dropdown in milliseconds
	Gui, main:Add, Slider, TickInterval100 vdelayDropdown Range-1-1000 w150 ToolTipBottom , %delayDropdown%
	Gui, main:Add, Text, Center , Ajust mouse speed
	Gui, main:Add, Slider, TickInterval10 vmouseSpeed Range0-100 w150 ToolTipBottom , %mouseSpeed%
	Gui, main:Add, Button, x40 gSave w80, Save
	Gui, main:Show

	return

	Save:
		Gui, Submit
		registrarSetting("delayMenu", delayMenu)
		registrarSetting("mode", modoId)
		registrarSetting("mouseSpeed", mouseSpeed)
		registrarSetting("delayDropdown", delayDropdown)
		SetDefaultMouseSpeed, mouseSpeed
		;showNotificationMsg("Settings saved")
	return

	mainGuiClose:
		ExitApp
	r

	*/