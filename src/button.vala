using Gtk;
using Gdk;
using GLib;
using Sqlite;
using Gee;

public void on_button1_clicked (Button source) {
	check_answer(1);
    if(OK==true) next_question ();
}

public void on_button2_clicked (Button source) {
	check_answer(2);
    if(OK==true) next_question ();
}

public void on_button3_clicked (Button source) {
    check_answer(3);
    if(OK==true) next_question ();
}

public void on_button4_clicked (Button source) {
    check_answer(4);
    if(OK==true) next_question ();
}

public void on_button5_clicked (Button source) {
    check_answer(0);
    next_question ();
}

public void create_selected_questions () {
	var cb1 = builder.get_object ("checkbutton1") as CheckButton;
	var cb2 = builder.get_object ("checkbutton2") as CheckButton;
	var cb3 = builder.get_object ("checkbutton3") as CheckButton;
	var cb4 = builder.get_object ("checkbutton4") as CheckButton;
	var cb5 = builder.get_object ("checkbutton5") as CheckButton;
	var cb6 = builder.get_object ("checkbutton6") as CheckButton;
	var cb7 = builder.get_object ("checkbutton7") as CheckButton;
	var cb8 = builder.get_object ("checkbutton8") as CheckButton;
	var cb9 = builder.get_object ("checkbutton9") as CheckButton;
	var cb10 = builder.get_object ("checkbutton10") as CheckButton;
	var cb11 = builder.get_object ("checkbutton11") as CheckButton;
	var cb12 = builder.get_object ("checkbutton12") as CheckButton;
	var cb13 = builder.get_object ("checkbutton13") as CheckButton;
	var cb14 = builder.get_object ("checkbutton14") as CheckButton;
	var cb15 = builder.get_object ("checkbutton15") as CheckButton;
	var cb16 = builder.get_object ("checkbutton16") as CheckButton;
	var cb17 = builder.get_object ("checkbutton17") as CheckButton;
	var cb18 = builder.get_object ("checkbutton18") as CheckButton;
	var cb19 = builder.get_object ("checkbutton19") as CheckButton;
	var cb20 = builder.get_object ("checkbutton20") as CheckButton;
	var cb21 = builder.get_object ("checkbutton21") as CheckButton;
	var cb22 = builder.get_object ("checkbutton22") as CheckButton;
	var cb23 = builder.get_object ("checkbutton23") as CheckButton;
	var cb24 = builder.get_object ("checkbutton24") as CheckButton;
	var cb25 = builder.get_object ("checkbutton25") as CheckButton;
	var cb26 = builder.get_object ("checkbutton26") as CheckButton;
	var cb27 = builder.get_object ("checkbutton27") as CheckButton;
	var cb28 = builder.get_object ("checkbutton28") as CheckButton;
	var cb29 = builder.get_object ("checkbutton29") as CheckButton;
	var cb30 = builder.get_object ("checkbutton30") as CheckButton;
	
	string buffer="";
	
	if(cb1.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb1.label + "%\"";
	if(cb2.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb2.label + "%\"";
	if(cb3.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb3.label + "%\"";
	if(cb4.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb4.label + "%\"";
	if(cb5.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb5.label + "%\"";
	if(cb6.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb6.label + "%\"";
	if(cb7.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb7.label + "%\"";
	if(cb8.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb8.label + "%\"";
	if(cb9.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb9.label + "%\"";		
	if(cb10.active) buffer= buffer + " OR elnum LIKE " + "\"" + cb10.label + "%\"";		
	if(cb11.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb11.label + "%\"";
	if(cb12.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb12.label + "%\"";
	if(cb13.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb13.label + "%\"";
	if(cb14.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb14.label + "%\"";
	if(cb15.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb15.label + "%\"";
	if(cb16.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb16.label + "%\"";
	if(cb17.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb17.label + "%\"";
	if(cb18.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb18.label + "%\"";
	if(cb19.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb19.label + "%\"";		
	if(cb20.active) buffer= buffer + " OR elnum LIKE " + "\"" + cb20.label + "%\"";	
	if(cb21.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb21.label + "%\"";
	if(cb22.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb22.label + "%\"";
	if(cb23.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb23.label + "%\"";
	if(cb24.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb24.label + "%\"";
	if(cb25.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb25.label + "%\"";
	if(cb26.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb26.label + "%\"";
	if(cb27.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb27.label + "%\"";
	if(cb28.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb28.label + "%\"";
	if(cb29.active) buffer = buffer + " OR elnum LIKE " + "\"" + cb29.label + "%\"";		
	if(cb30.active) buffer= buffer + " OR elnum LIKE " + "\"" + cb30.label + "%\"";		
	selected_questions = """SELECT * FROM "main"."examquestions" WHERE """ + buffer.offset(3);
	printerr ("SQL output: %s\n", selected_questions);
}

public void on_togglebutton_toggled (ToggleButton source) {
var tb1 = builder.get_object ("togglebutton1") as ToggleButton;
var tb2 = builder.get_object ("togglebutton2") as ToggleButton;
var tb3 = builder.get_object ("togglebutton3") as ToggleButton;
var cb1 = builder.get_object ("checkbutton1") as CheckButton;
var cb2 = builder.get_object ("checkbutton2") as CheckButton;
var cb3 = builder.get_object ("checkbutton3") as CheckButton;
var cb4 = builder.get_object ("checkbutton4") as CheckButton;
var cb5 = builder.get_object ("checkbutton5") as CheckButton;
var cb6 = builder.get_object ("checkbutton6") as CheckButton;
var cb7 = builder.get_object ("checkbutton7") as CheckButton;
var cb8 = builder.get_object ("checkbutton8") as CheckButton;
var cb9 = builder.get_object ("checkbutton9") as CheckButton;
var cb10 = builder.get_object ("checkbutton10") as CheckButton;
var cb11 = builder.get_object ("checkbutton11") as CheckButton;
var cb12 = builder.get_object ("checkbutton12") as CheckButton;
var cb13 = builder.get_object ("checkbutton13") as CheckButton;
var cb14 = builder.get_object ("checkbutton14") as CheckButton;
var cb15 = builder.get_object ("checkbutton15") as CheckButton;
var cb16 = builder.get_object ("checkbutton16") as CheckButton;
var cb17 = builder.get_object ("checkbutton17") as CheckButton;
var cb18 = builder.get_object ("checkbutton18") as CheckButton;
var cb19 = builder.get_object ("checkbutton19") as CheckButton;
var cb20 = builder.get_object ("checkbutton20") as CheckButton;
var cb21 = builder.get_object ("checkbutton21") as CheckButton;
var cb22 = builder.get_object ("checkbutton22") as CheckButton;
var cb23 = builder.get_object ("checkbutton23") as CheckButton;
var cb24 = builder.get_object ("checkbutton24") as CheckButton;
var cb25 = builder.get_object ("checkbutton25") as CheckButton;
var cb26 = builder.get_object ("checkbutton26") as CheckButton;
var cb27 = builder.get_object ("checkbutton27") as CheckButton;
var cb28 = builder.get_object ("checkbutton28") as CheckButton;
var cb29 = builder.get_object ("checkbutton29") as CheckButton;
var cb30 = builder.get_object ("checkbutton30") as CheckButton;

	if(source.label=="Technician Class") {
		cb1.active  = tb1.active;
		cb2.active  = tb1.active; 
		cb3.active  = tb1.active; 
		cb4.active  = tb1.active; 
		cb5.active  = tb1.active; 
		cb6.active  = tb1.active; 
		cb7.active  = tb1.active; 
		cb8.active  = tb1.active; 
		cb9.active  = tb1.active; 
		cb10.active  = tb1.active; 
	}
	if(source.label=="General Class") {	
		cb11.active  = tb2.active;
		cb12.active  = tb2.active; 
		cb13.active  = tb2.active; 
		cb14.active  = tb2.active; 
		cb15.active  = tb2.active; 
		cb16.active  = tb2.active; 
		cb17.active  = tb2.active; 
		cb18.active  = tb2.active; 
		cb19.active  = tb2.active; 
		cb20.active  = tb2.active;	
	}
	if(source.label=="Extra Class") {
		cb21.active  = tb3.active;
		cb22.active  = tb3.active; 
		cb23.active  = tb3.active; 
		cb24.active  = tb3.active; 
		cb25.active  = tb3.active; 
		cb26.active  = tb3.active; 
		cb27.active  = tb3.active; 
		cb28.active  = tb3.active; 
		cb29.active  = tb3.active; 
		cb30.active  = tb3.active; 		
	}
	if(cb1.active==false&&
	   cb2.active==false&&
	   cb3.active==false&&
	   cb4.active==false&&
	   cb5.active==false&&
	   cb6.active==false&&
	   cb7.active==false&&
	   cb8.active==false&&
	   cb9.active==false&&
	   cb10.active==false&&
	   cb11.active==false&&
	   cb12.active==false&&
	   cb13.active==false&&
	   cb14.active==false&&
	   cb15.active==false&&
	   cb16.active==false&&
	   cb17.active==false&&
	   cb18.active==false&&
	   cb19.active==false&&
	   cb20.active==false&&
	   cb21.active==false&&
	   cb22.active==false&&
	   cb23.active==false&&
	   cb24.active==false&&
	   cb25.active==false&&
	   cb26.active==false&&
	   cb27.active==false&&
	   cb28.active==false&&
	   cb29.active==false&&
	   cb30.active==false)  {
	   if(source.label=="Technician Class") cb1.active=true;
	   else if(source.label=="General Class") cb11.active=true;
	   else if(source.label=="Extra Class") cb21.active=true;
	   else cb1.active=true;
   	}
	select_questions ();
	next_question ();
}