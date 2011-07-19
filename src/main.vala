using Gtk;
using Gdk;
using GLib;
using Sqlite;
using Gee;

Builder builder;
Statusbar statusbar1;
Database db;
Statement stmt;
int cols;
int cols2;
string qg;
string kg;
bool OK;
int Q_ID;
string selected_questions;
int answerg;
ArrayList<int> listg;
int listg_index;

public int[] get_stats(int ID){
	int rc; 
	string a="0",b="0",c="0";
	string buff = """SELECT * FROM "main"."stats" WHERE "ID" LIKE """ + @"$ID";
	rc = db.exec(buff, (n_columns, values, column_names) => {
    	a = values[1];
    	b = values[2];
    	c = values[3];
        return 0;
    }, null);
    int[] rbuff = new int[3];
    rbuff[0] = int.parse(a);
    rbuff[1] = int.parse(b);
    rbuff[2] = int.parse(c);
    return rbuff;
}

public void set_stats(int ID, int[] stats){
	int rc; 
    int a=stats[0],b=stats[1],c=stats[2];
    string dbstr = """INSERT OR REPLACE INTO stats ("ID","tries","failed","learnd") VALUES (""" + @"$ID, $a, $b, $c" +""")""";
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
}

public void check_answer (int myanswer) {
	var labe12 = builder.get_object ("label2") as Label;
	var labe13 = builder.get_object ("label3") as Label;
	var labe16 = builder.get_object ("label6") as Label;
	if (answerg == myanswer) {
		OK=true;
		labe16.label = "";
	}
	else {
		OK=false;
		labe12.label = "";
		labe13.label = "";
		labe16.label = "Wrong!";
	}
    int[3] stats = get_stats(Q_ID);
    stats[0]++;
    if(OK) stats[1]++;
    else stats[1]=stats[1]-2;
    if(stats[0]>=3 && stats[1]>2)stats[2]++;
    set_stats(Q_ID, stats);
    
	cols2++;
    var labe14 = builder.get_object ("label4") as Label;
	if(OK) {
        statusbar1.push(0,@"Good Job! Question $cols2 of $cols");
        labe14.label = "You got it!";
    }
    else{ 
        statusbar1.push(0,@"Wrong! Question $cols2 of $cols");
        labe14.label = "Nice try!";
    }
}

public void next_question () {
	if(listg_index==-1 || listg_index>=listg.size) select_questions ();
	cont_next_question(listg[listg_index++]);
}

public void select_questions () {
	//get list of IDs from slected questions
	create_selected_questions ();
	put_all_questions_in_list();
	//create smaller list (or sort and remove) of questions from selected questoins list and get_stats; 
	//remove learnd questions
	for(int i=(listg.size-1); i!=-1;i--) {
        int[3] stats = get_stats(listg[i]);
        if(stats[2]>=1){
	       listg.remove_at(i);
        }
    }
	//sort so that if multible lessions are selected it goes changes...
	// sort all in different list, one list for failed one for learnd one list for new  
	sort_questions_list ();
	
	//put questions with less tries to the front 
	//sprinkel wrong aswerd questions after 3 new learnd for example
	//short the list
	
	//keep track of wrong answerd and put back in list
	//SELECT * FROM "main"."stats" WHERE  failed < 0 ORDER BY tries DESC
	//SELECT * FROM "main"."stats" WHERE  tries > 0 ORDER BY tries DESC
	//SELECT * FROM "main"."stats" WHERE  learnd > 0
	//SELECT * FROM "main"."stats" WHERE  tries > 0 AND failed < 0 ORDER BY tries DESC
	//SELECT * FROM "main"."stats" WHERE  tries > 0 AND learnd > 0
    //SELECT * FROM "main"."stats" JOIN "main"."examquestions" ON examquestions.ID=stats.ID 
    //WHERE  tries > 0 AND failed < 0 ORDER BY tries DESC
    //WHERE  elnum LIKE "G1A%"
	//keep track of right answerd and put back in list the reinforce
	
}

public void sort_questions_list () {
}

public string get_elnum(int ID){
	int rc;
	string retbuff=""; 
	string buff = """SELECT * FROM "main"."examquestions" WHERE ID LIKE """ + @"$ID";
	rc = db.exec(buff, (n_columns, values, column_names) => {
    	retbuff = values[2];
        return 0;
    }, null);
    return retbuff;
}

public void put_all_questions_in_list () {
	int rc; 
	listg_index=0;
	listg = new ArrayList<int>();

	Statement stmt2;
	if ((rc = db.prepare_v2 (selected_questions, -1, out stmt2, null)) == 1) {
        printerr ("SQL error: %d, %s\n", rc, db.errmsg ());
        return;
    }
    do {
        rc = stmt2.step();
        switch (rc) {
        case Sqlite.DONE:
            break;
        case Sqlite.ROW:
        	listg.add(stmt2.column_int(0));
            break;
        default:
            printerr ("Error: %d, %s\n", rc, db.errmsg ());
            break;
        }
    } while (rc == Sqlite.ROW);
}

public void cont_next_question (int ID) {
	int rc; 
    string buff = """SELECT * FROM "main"."examquestions" WHERE  ID LIKE """ + @"$ID";
	if ((rc = db.prepare_v2 (buff, -1, out stmt, null)) == 1) {
        printerr ("SQL error: %d, %s\n", rc, db.errmsg ());
        return;
    }
    cols = stmt.data_count();
	cols2 = 0;
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
				//FileUtils.set_data("temp.jpg", data2);
	            //Pixbuf pixbuf = new Pixbuf.from_file_at_scale("temp.jpg",320,240,true);
	            var imgstream = new GLib.MemoryInputStream.from_data(data2, null);
                Pixbuf pixbuf = new Gdk.Pixbuf.from_stream(imgstream,null);
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
	var labe16 = builder.get_object ("label6") as Label;
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
	labe16.label = "";
	labe17.label = el;
	qg=q;
	kg=k;
}

int main (string[] args) {
	int rc;      
    Gtk.init (ref args);
    qg="";
    kg="";
    Q_ID=0;
    listg_index=-1;
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
        var cb1 = builder.get_object ("checkbutton1") as CheckButton;
        cb1.active = true;
        next_question ();
        Gtk.main ();
        
    } catch (Error e) {
        stderr.printf ("Could not load UI: %s\n", e.message);
        return 1;
    } 

    return 0;
}
