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
int Q_ID;
int answerg;

public void on_button1_clicked (Button source) {
	check_answer(1);
    next_question ();
}

public void on_button2_clicked (Button source) {
	check_answer(2);
    next_question ();
}

public void on_button3_clicked (Button source) {
    check_answer(3);
    next_question ();
}

public void on_button4_clicked (Button source) {
    check_answer(4);
    next_question ();
}

public void check_answer (int myanswer) {
	if (answerg == myanswer) OK=true;
	else OK=false;
	string a="0",b="0",c="0";
	string buff = """SELECT * FROM "main"."stats" WHERE question LIKE """ + @"$Q_ID";
	printerr ("%s\n",buff);
	rc = db.exec(buff, (n_columns, values, column_names) => {
    	a = values[1];
    	b = values[2];
    	c = values[3];
        return 0;
    }, null);
    int ai,bi,ci;
    ai = a.to_int();
    bi = b.to_int();
    ci = c.to_int();
    stderr.printf ("%i, %i, %i\n", ai, bi, ci);
    ai++;
    if(OK) bi++;
    else bi--;
    if(ai>=3 && bi>2)ci++;
    string dbstr = """INSERT OR REPLACE INTO stats ("question","tries","failed","learnd") VALUES (""" + @"$Q_ID, $ai, $bi, $ci" +""")""";
	rc = db.exec(dbstr, (n_columns, values, column_names) => {
	for (int i = 0; i < n_columns; i++) {
			stdout.printf ("%s = %s\n", column_names[i], values[i]);
		}
		stdout.printf ("\n");

		return 0;
	}, null);

	if (rc != Sqlite.OK) { 
		stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
		stderr.printf(dbstr + "\n");
	}
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
        rc = stmt.step();
        switch (rc) {
        case Sqlite.DONE:
            break;
        case Sqlite.ROW:
   			Q_ID = stmt.column_int(0);
            set_text(stmt.column_text(2),stmt.column_text(4),stmt.column_text(5),stmt.column_text(6),stmt.column_text(7),stmt.column_text(8));
            if (stmt.column_blob(9) != null)
            {
	            unowned uint8[] data = (uint8[]) stmt.column_blob(9);
				data.length = stmt.column_bytes(9);
				var data2 = data;
				FileUtils.set_data("temp.jpg", data2);
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

public void set_text (string el, string q, string k, string d1, string d2, string d3) {
	var labe11 = builder.get_object ("label1") as Label;
	var labe12 = builder.get_object ("label2") as Label;
	var labe13 = builder.get_object ("label3") as Label;
	var labe17 = builder.get_object ("label7") as Label;
	var button1 = builder.get_object ("button1") as Button;
	var button2 = builder.get_object ("button2") as Button;
	var button3 = builder.get_object ("button3") as Button;
	var button4 = builder.get_object ("button4") as Button;
	var image1 = builder.get_object ("image1") as Gtk.Image;
	image1.set_from_stock("", IconSize.BUTTON);
	labe11.label = q;
	
	switch (Random.int_range (1, 17)) {
	case 1:
		button1.label = "A. "+k;
		button2.label = "B. "+d1;
		button3.label = "C. "+d2;
		button4.label = "D. "+d3;
		answerg = 1;
		break;
	case 2:
		button1.label = "A. "+d1;
		button2.label = "B. "+k;
		button3.label = "C. "+d2;
		button4.label = "D. "+d3;
		answerg = 2;
		break;
	case 3:
		button1.label = "A. "+d1;
		button2.label = "B. "+d2;
		button3.label = "C. "+k;
		button4.label = "D. "+d3;
		answerg = 3;
		break;
	case 4:
		button1.label = "A. "+d1;
		button2.label = "B. "+d2;
		button3.label = "C. "+d3;
		button4.label = "D. "+k;
		answerg = 4;
		break;
	case 5:
		button1.label = "A. "+k;
		button2.label = "B. "+d3;
		button3.label = "C. "+d2;
		button4.label = "D. "+d1;
		answerg = 1;
		break;
	case 6:
		button1.label = "A. "+d3;
		button2.label = "B. "+k;
		button3.label = "C. "+d2;
		button4.label = "D. "+d1;
		answerg = 2;
		break;
	case 7:
		button1.label = "A. "+d3;
		button2.label = "B. "+d2;
		button3.label = "C. "+k;
		button4.label = "D. "+d1;
		answerg = 3;
		break;
	case 8:
		button1.label = "A. "+d3;
		button2.label = "B. "+d2;
		button3.label = "C. "+d1;
		button4.label = "D. "+k;
		answerg = 4;
		break;
	case 9:
		button1.label = "A. "+k;
		button2.label = "B. "+d3;
		button3.label = "C. "+d1;
		button4.label = "D. "+d2;
		answerg = 1;
		break;
	case 10:
		button1.label = "A. "+d3;
		button2.label = "B. "+k;
		button3.label = "C. "+d1;
		button4.label = "D. "+d2;
		answerg = 2;
		break;
	case 11:
		button1.label = "A. "+d3;
		button2.label = "B. "+d1;
		button3.label = "C. "+k;
		button4.label = "D. "+d2;
		answerg = 3;
		break;
	case 12:
		button1.label = "A. "+d3;
		button2.label = "B. "+d2;
		button3.label = "C. "+d1;
		button4.label = "D. "+k;
		answerg = 4;
		break;
	case 13:
		button1.label = "A. "+k;
		button2.label = "B. "+d2;
		button3.label = "C. "+d3;
		button4.label = "D. "+d1;
		answerg = 1;
		break;
	case 14:
		button1.label = "A. "+d2;
		button2.label = "B. "+k;
		button3.label = "C. "+d3;
		button4.label = "D. "+d1;
		answerg = 2;
		break;
	case 15:
		button1.label = "A. "+d2;
		button2.label = "B. "+d3;
		button3.label = "C. "+k;
		button4.label = "D. "+d1;
		answerg = 3;
		break;
	case 16:
		button1.label = "A. "+d2;
		button2.label = "B. "+d1;
		button3.label = "C. "+d3;
		button4.label = "D. "+k;
		answerg = 4;
		break;
	}
	
	labe12.label = qg;
	labe13.label = kg;
	labe17.label = el;
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
