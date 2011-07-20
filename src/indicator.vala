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
	int[] rbuff = new int[4];
	rbuff[0] = 0;
    rbuff[1] = 0;
    rbuff[2] = 0;
    rbuff[3] = 0;
	string a="0",b="0",c="0";
	string buff = """SELECT * FROM "main"."stats" JOIN "main"."examquestions" ON examquestions.ID=stats.ID WHERE "elnum" LIKE """ + @"\"$pool\""; 
	rc = db.exec(buff, (n_columns, values, column_names) => {
    	a = values[1]; //tries
    	b = values[2]; //fail
    	c = values[3]; //learnd
    	int aa = int.parse(a);
    	int bb =  int.parse(b);
    	int cc =  int.parse(c);    	
    	if(aa == 0) rbuff[0]++;//not touched, new
        else if(bb < 0) rbuff[1]++;//failed 
        	 else if(cc > 2) rbuff[2]++;//learnd
        		  else rbuff[3]++; //reinforce 	
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
	
	//red
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
