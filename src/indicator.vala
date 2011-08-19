using Gtk;
using Cairo;
using GLib;

public void update_bar_gfx () {
	var labe111 = builder.get_object ("label11") as Label;
	var labe112 = builder.get_object ("label12") as Label;
	var labe113 = builder.get_object ("label13") as Label;
	labe111.label = "Technician 100% ";
	labe112.label = "General 100% ";
	labe113.label = "Extra 100% ";
	var drawingarea1 = builder.get_object ("drawingarea1") as Gtk.DrawingArea;
	drawingarea1.queue_draw();
	var drawingarea2 = builder.get_object ("drawingarea2") as Gtk.DrawingArea;
	drawingarea2.queue_draw();
	var drawingarea3 = builder.get_object ("drawingarea3") as Gtk.DrawingArea;
	drawingarea3.queue_draw();
}

public int[] create_stats_for_bar(string pool){
	int rc; 
	int[] rbuff = new int[7];
	rbuff[0] = 0; //big new
    rbuff[1] = 0; // failed
    rbuff[2] = 0; //learnd
    rbuff[3] = 0; //reinforce
    rbuff[4] = 0; // small new
    rbuff[5] = 0; // needs reading
    rbuff[6] = 0; // no yet
    var vlocal_time = new DateTime.now_local();
	int64 local_time = vlocal_time.to_unix();
	string a="0",b="0",c="0",t="0",d="0";
	string buff = """SELECT * FROM "main"."stats" JOIN "main"."examquestions" ON examquestions.ID=stats.ID WHERE "elnum" LIKE """ + @"\"$pool\""; 
	rc = db.exec(buff, (n_columns, values, column_names) => {
    	a = values[1]; //tries
    	b = values[2]; //fail
    	c = values[3]; //learnd
    	t = values[4]; //time
    	d = values[5]; //read
    	int aa = int.parse(a);
    	int bb =  int.parse(b);
    	int cc =  int.parse(c);
    	int64 tt =  int64.parse(t);  
    	int dd =  int.parse(d);   	
    	if(aa == 0) rbuff[0]++;//not touched, new
        else if(bb < 0) rbuff[1]++;//failed 
        	 else if(cc > 2) rbuff[2]++;//learnd
        		  else rbuff[3]++; //reinforce
        
        bool add = false;
        if(dd==1 && (local_time-tt)>5) add = true;
    	if(dd==2 && (local_time-tt)>25) add = true;
    	if(dd==3 && (local_time-tt)>120) add = true;
    	if(dd==4 && (local_time-tt)>300) add = true;
    	if(dd==5 && (local_time-tt)>800) add = true;
    	if(dd==6 && (local_time-tt)>1800) add = true;
    	if(dd==7 && (local_time-tt)>3600) add = true;
    	if(dd==8 && (local_time-tt)>3600*2) add = true;
    	if(dd==9 && (local_time-tt)>3600*24) add = true;
    	if(dd==10 && (local_time-tt)>3600*24*2) add = true;
    	if(dd==11 && (local_time-tt)>3600*24*7) add = true;
    	if(dd==12 && (local_time-tt)>3600*24*14) add = true;
        if(dd == 0) rbuff[4]++; 
        //else if (dd < 9) rbuff[5]++;
        //	 else rbuff[6]++; 
        else if (add) rbuff[5]++;
        	else rbuff[6]++; 
        	
        return 0;
    }, null);
    return rbuff;
}

public static int Round(double num) {
    (num > 0) ? (num+= 0.5) : (num+= (-0.5));
    return (int)num;
    }

public void create_gfx_for_bar (Context cr, int[] stats) {
	//                                          white     red       green      blue
	//                                          all       faild    learnd    reinfoce
	//stderr.printf ("BAR: %d %d %d %d\n", stats[0], stats[1], stats[2], stats[3]);
	
	int all = stats[0]+stats[1]+stats[2]+stats[3];

	int red   = Round((738.0 / (double) all) * (double) stats[1]);
	int blue   = Round((738.0 / (double) all) * (double) stats[3]);
	int green   = Round((738.0 / (double) all) * (double) stats[2]);
	int white = Round((738.0 / (double) all) * (double) stats[0]);
	//stderr.printf ("BAR: %d %d %d %d\n", red, blue, green, white);
	
	int red_start = 0;
	int red_stop = red;
	int blue_start = red + 1;
	int blue_stop = red + blue;
	int green_start = red + blue + 1;
	int green_stop = red + blue + green;
	int white_start = red + blue + green +1;
	int white_stop = red + blue + green + white;

	cr.set_line_width (30);
	
	//big bar
	cr.set_source_rgb (1, 0, 0);
    cr.move_to (10, red_start);
    cr.line_to (10, red_stop);
    cr.stroke ();   
	cr.set_source_rgb (0, 0, 1);
    cr.move_to (10, blue_start);
    cr.line_to (10, blue_stop);
    cr.stroke ();    
	cr.set_source_rgb (0, 1, 0);
    cr.move_to (10, green_start);
    cr.line_to (10, green_stop);
    cr.stroke ();   
	cr.set_source_rgb (1, 1, 1);
    cr.move_to (10, white_start);
    cr.line_to (10, white_stop);
    cr.stroke ();
    
    //start small bar
    all = stats[4]+stats[5]+stats[6];
    
	blue   = Round((738.0 / (double) all) * (double) stats[5]);
	green  = Round((738.0 / (double) all) * (double) stats[6]);
	white  = Round((738.0 / (double) all) * (double) stats[4]);
    
	blue_start = 0;
	blue_stop = blue;
	green_start = blue + 1;
	green_stop = blue + green;
	white_start = blue + green +1;
	white_stop = blue + green + white;
    
 	cr.set_line_width (10);
	
	//small bar 
	cr.set_source_rgb (0, 0, 1);
    cr.move_to (20, blue_start);
    cr.line_to (20, blue_stop);
    cr.stroke ();    
	cr.set_source_rgb (0, 1, 0);
    cr.move_to (20, green_start);
    cr.line_to (20, green_stop);
    cr.stroke ();   
	cr.set_source_rgb (1, 1, 1);
    cr.move_to (20, white_start);
    cr.line_to (20, white_stop);
    cr.stroke ();
    
    cr.clip ();
}


public bool on_drawingarea1_expose_event  (Gdk.EventExpose event) {
        // Create a Cairo context
        var drawingarea1 = builder.get_object ("drawingarea1") as Gtk.DrawingArea;
        var cr = Gdk.cairo_create (drawingarea1.window);
 
        // Set clipping area in order to avoid unnecessary drawing
        cr.rectangle (event.area.x, event.area.y,
                      event.area.width, event.area.height);
        create_gfx_for_bar(cr,create_stats_for_bar("T%"));
        return false;
}  

public bool on_drawingarea2_expose_event  (Gdk.EventExpose event) {
        // Create a Cairo context
        var drawingarea1 = builder.get_object ("drawingarea2") as Gtk.DrawingArea;
        var cr = Gdk.cairo_create (drawingarea1.window);
 
        // Set clipping area in order to avoid unnecessary drawing
        cr.rectangle (event.area.x, event.area.y,
                      event.area.width, event.area.height);             
        create_gfx_for_bar(cr,create_stats_for_bar("G%"));
        return false;
}  

public bool on_drawingarea3_expose_event  (Gdk.EventExpose event) {
        // Create a Cairo context
        var drawingarea1 = builder.get_object ("drawingarea3") as Gtk.DrawingArea;
        var cr = Gdk.cairo_create (drawingarea1.window);
 
        // Set clipping area in order to avoid unnecessary drawing
        cr.rectangle (event.area.x, event.area.y,
                      event.area.width, event.area.height);          
		create_gfx_for_bar(cr,create_stats_for_bar("E%"));
        return false;
}  

public void color_checkmark () {
	Gdk.Color white;
	Gdk.Color.parse("white", out white);
	Gdk.Color red;
	Gdk.Color.parse("red", out red);
	Gdk.Color blue;
	Gdk.Color.parse("blue", out blue);
	Gdk.Color skyblue;
	Gdk.Color.parse("skyblue", out skyblue);
	Gdk.Color green;
	Gdk.Color.parse("green", out green);

	CheckButton cbt[31];
	for (int i=1; i<= 30;i++) {
	cbt[i-1] = builder.get_object ("checkbutton"+i.to_string()) as CheckButton;
	}
	string search="";
	
	for (int i=0, ii=1; i<= 29;i++) {
		if(i==9) ii=0;
		if(i>=0 && i<=9) search="T"+ii.to_string();
		
		if(i==19) ii=0;
		if(i>=10 && i<=19) search="G"+ii.to_string();
		
		if(i==29) ii=0;
		if(i>=20 && i<=29) search="E"+ii.to_string();
		
		int[] stats = create_stats_for_bar(search+"%");
	//                                          white     red       green      blue
	//                                          all       faild    learnd    reinfoce
	//stderr.printf ("BAR: %d %d %d %d\n", stats[0], stats[1], stats[2], stats[3]);
		
		if(radiobutton==0 || radiobutton==1 || radiobutton==2 || radiobutton==4){
			if(stats[1]+stats[2]+stats[3] == 0) cbt[i].modify_base(StateType.NORMAL, white);
			  else if(stats[2] > ((stats[0]+stats[1]+stats[2]+stats[3])*0.9)) cbt[i].modify_base(StateType.NORMAL, green);
			   else if(stats[1] >= 1) cbt[i].modify_base(StateType.NORMAL, red);  
				else if(stats[3] > stats[0]+stats[2]+stats[1]) cbt[i].modify_base(StateType.NORMAL, blue);
				 else cbt[i].modify_base(StateType.NORMAL, skyblue);
		}
		else{
			if(stats[5]+stats[6] == 0) cbt[i].modify_base(StateType.NORMAL, white);  
			  else if(stats[5] > 0) cbt[i].modify_base(StateType.NORMAL, blue);
				else if(stats[6] >= stats[5]+stats[4]) cbt[i].modify_base(StateType.NORMAL, green);
				  else cbt[i].modify_base(StateType.NORMAL, skyblue);
		}
		ii++;
	}
	
	
}