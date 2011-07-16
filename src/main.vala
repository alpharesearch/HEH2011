using Gtk;
using Gdk;
using GLib;
using Sqlite;

Builder builder;
Statusbar statusbar1;
Database db;
Statement stmt;
int rc; 
int cols;
int cols2;
string qg;
string kg;
bool OK;

public void on_button1_clicked (Button source) {
	OK=true;
    next_question ();
}

public void on_button2_clicked (Button source) {
	OK=false;
    next_question ();
}

public void on_button3_clicked (Button source) {
    next_question ();
}

public void on_button4_clicked (Button source) {
    next_question ();
}

public void prep_questions () {
	string buff = """SELECT * FROM "main"."examquestions" WHERE  elnum LIKE "G%"""";    
	if ((rc = db.prepare_v2 (buff, -1, out stmt, null)) == 1) {
        printerr ("SQL error: %d, %s\n", rc, db.errmsg ());
        return;
    }

    cols = stmt.column_count();
	cols2 = 0;
}

public void next_question () {
        cols2++;
        var labe14 = builder.get_object ("label4") as Label;
	    if(OK) {
        	statusbar1.push(0,@"Good Job! Question $cols2 of 456");
        	labe14.label = "You got it!";
        }
        else{ 
        	statusbar1.push(0,@"Wrong! Question $cols2 of 456");
        	labe14.label = "Nice try, here is the right answer!";
        }
        rc = stmt.step();
        switch (rc) {
        case Sqlite.DONE:
            break;
        case Sqlite.ROW:
   
            set_text(stmt.column_text(4),stmt.column_text(5),stmt.column_text(6),stmt.column_text(7),stmt.column_text(8));
            if (stmt.column_blob(9) != null)
            {
	            {
	            	unowned uint8[] data = (uint8[]) stmt.column_blob(9);
					data.length = stmt.column_bytes(9);
					var data2 = data;
					FileUtils.set_data("temp.jpg", data2);
	            	
            	}
	            Pixbuf pixbuf = new Pixbuf.from_file_at_scale("temp.jpg",320,240,true);
	            var image1 = builder.get_object ("image1") as Gtk.Image;
	            image1.set_from_pixbuf(pixbuf);
            }
   
            break;
        default:
            printerr ("Error: %d, %s\n", rc, db.errmsg ());
            break;
        }
}

public void set_text (string q, string k, string d1, string d2, string d3) {
	var labe11 = builder.get_object ("label1") as Label;
	var labe12 = builder.get_object ("label2") as Label;
	var labe13 = builder.get_object ("label3") as Label;
	var button1 = builder.get_object ("button1") as Button;
	var button2 = builder.get_object ("button2") as Button;
	var button3 = builder.get_object ("button3") as Button;
	var button4 = builder.get_object ("button4") as Button;
	var image1 = builder.get_object ("image1") as Gtk.Image;
	image1.set_from_stock("", IconSize.BUTTON);
	labe11.label = q;
	button1.label = k;
	button2.label = d1;
	button3.label = d2;
	button4.label = d3;
	labe12.label = qg;
	labe13.label = kg;
	qg=q;
	kg=k;
}

int main (string[] args) {     
    Gtk.init (ref args);
    qg="";
    kg="";
	rc = Database.open ("src/hamdb", out db);
	if (rc != Sqlite.OK) {
    	stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
    	return 1;
    }
    try {
	    builder = new Builder ();
        builder.add_from_file ("src/sample.ui");
        builder.connect_signals (null);
        var window = builder.get_object ("window") as Gtk.Window;
        statusbar1 = builder.get_object ("statusbar1") as Statusbar;
        window.show_all ();
        statusbar1.push(0,"Loading DB... Done");
        prep_questions ();
        next_question ();
        Gtk.main ();
        
    } catch (Error e) {
        stderr.printf ("Could not load UI: %s\n", e.message);
        return 1;
    } 

    return 0;
}
