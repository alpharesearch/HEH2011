using Gtk;

public void update_bar_gfx () {
	var labe111 = builder.get_object ("label11") as Label;
	var labe112 = builder.get_object ("label12") as Label;
	var labe113 = builder.get_object ("label13") as Label;
	labe111.label = "Technician";
	labe112.label = "General";
	labe113.label = "Extra";
}


public bool on_drawingarea1_expose_event  (Gdk.EventExpose event) {
  		printerr ("TEST\n");
        // Create a Cairo context
        var drawingarea1 = builder.get_object ("drawingarea1") as Gtk.DrawingArea;
        var cr = Gdk.cairo_create (drawingarea1.window);
 
        // Set clipping area in order to avoid unnecessary drawing
        cr.rectangle (event.area.x, event.area.y,
                      event.area.width, event.area.height);
                      
        cr.set_source_rgb (1, 0, 0);
		cr.set_line_width (4);
        cr.move_to (0, 3);
        cr.line_to (200, 3);
        cr.move_to (0, 10);
        cr.line_to (100, 10);
        cr.move_to (0, 17);
        cr.line_to (50, 17);
        cr.stroke ();
        cr.clip ();
          
        return false;
}  

public bool on_drawingarea2_expose_event  (Gdk.EventExpose event) {
  		printerr ("TEST\n");
        // Create a Cairo context
        var drawingarea1 = builder.get_object ("drawingarea2") as Gtk.DrawingArea;
        var cr = Gdk.cairo_create (drawingarea1.window);
 
        // Set clipping area in order to avoid unnecessary drawing
        cr.rectangle (event.area.x, event.area.y,
                      event.area.width, event.area.height);
                      
        cr.set_source_rgb (0, 1, 0);
		cr.set_line_width (2);
        cr.move_to (0, 2);
        cr.line_to (200, 2);
        cr.move_to (0, 8);
        cr.line_to (100, 8);
        cr.move_to (0, 14);
        cr.line_to (50, 14);
        cr.move_to (0, 20);
        cr.line_to (50, 20);
        cr.stroke ();
        cr.clip ();
          
        return false;
}  

public bool on_drawingarea3_expose_event  (Gdk.EventExpose event) {
  		printerr ("TEST\n");
        // Create a Cairo context
        var drawingarea1 = builder.get_object ("drawingarea3") as Gtk.DrawingArea;
        var cr = Gdk.cairo_create (drawingarea1.window);
 
        // Set clipping area in order to avoid unnecessary drawing
        cr.rectangle (event.area.x, event.area.y,
                      event.area.width, event.area.height);
                      
        cr.set_source_rgb (0, 0, 1);
		cr.set_line_width (3);
        cr.move_to (0, 3);
        cr.line_to (200, 3);
        cr.move_to (0, 9);
        cr.line_to (100, 9);
        cr.move_to (0, 15);
        cr.line_to (50, 15);
        cr.move_to (0, 21);
        cr.line_to (50, 21);
        cr.stroke ();
        cr.clip ();
          
        return false;
}  
