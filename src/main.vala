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

enum st {
 TRIES,
 FAIL,
 LEARND,
}

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
    stats[0]++; //add to tries
    
	if(OK){ 
    	if(stats[1]<-2) stats[1] = -1; // if he faild before and gets it right set to -1
    		else stats[1]++; // if ok add one to fails
    }
    else{ 
    	if(stats[1]>=0) stats[1] = -2; // for first time or if later fail set to -2
    		else stats[1]--; // if not OK sub fails
    }
    
    if(stats[0]>=3 && stats[1]>2)stats[2]++; // if try > 3 and fails also > 2 count learnd
    set_stats(Q_ID, stats);
    
	cols2++;
    var labe14 = builder.get_object ("label4") as Label;
    int count = listg.size;
	if(OK) {
        statusbar1.push(0,@"Good Job! Question $listg_index of $count");
        labe14.label = "You got it!";
    }
    else{ 
        statusbar1.push(0,@"Wrong! Question $listg_index of $count");
        labe14.label = "Nice try!";
    }
    update_bar_gfx();
}

public void next_question () {
	if(listg_index==-1 || listg_index>=listg.size) select_questions ();
	cont_next_question(listg[listg_index++]);
	statusbar1 = builder.get_object ("statusbar1") as Statusbar;
	int count = listg.size;
    statusbar1.push(0,@"Question $listg_index of $count");
}

public void select_questions () {
	statusbar1 = builder.get_object ("statusbar1") as Statusbar;
    statusbar1.push(0,"Loading... WAIT");
	//get list of IDs from slected questions
	create_selected_questions ();
	//sort so that if multible lessions are selected it goes changes...
	// sort all in different list, one list for failed one for learnd one list for new  
	//put questions with less tries to the front 
	//sprinkel wrong aswerd questions after 3 new learnd for example
	//short the list
	//keep track of wrong answerd and put back in list
	//keep track of right answerd and put back in list the reinforce
	put_all_questions_in_list();
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
	ArrayList<int?> list_temp = new ArrayList<int?>();
	ArrayList<int?> list_failed = new ArrayList<int?>();
	ArrayList<int?> list_reinforce = new ArrayList<int?>();
	ArrayList<int?> list_learnd = new ArrayList<int?>();
	ArrayList<int?> list_new = new ArrayList<int?>();
	
	ArrayList<int?> list_failed_r = new ArrayList<int?>();
	ArrayList<int?> list_reinforce_r = new ArrayList<int?>();
	ArrayList<int?> list_new_r = new ArrayList<int?>();

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
        	list_temp.add(stmt2.column_int(0));
            break;
        default:
            printerr ("Error: %d, %s\n", rc, db.errmsg ());
            break;
        }
    } while (rc == Sqlite.ROW);
        
    //sort into the different lists
    foreach (int i in list_temp) {
        int[3] stats = get_stats(i);
        if(stats[0] == 0) list_new.add(i);
        else if(stats[1] < 0) list_failed.add(i);
        	 else if(stats[2] > 2) list_learnd.add(i);
        		  else list_reinforce.add(i);
    } 
    
     int mysize = list_failed.size + list_reinforce.size +list_new.size + list_learnd.size;
     if(mysize > 15) mysize = 15;
     if(mysize < 1) listg.add(1);
    
     //move 15 questions in the main list, sort by exam groups and add failed (6) and some reinfoce (5) and also some new questions (2) and a learnd (1) one...
	 else {
    	list_failed.sort(compare_failed);	 
		list_learnd.sort(compare_learnd);	
		list_reinforce.sort(compare_reinforce);
		list_new.sort(compare_new);
		
		foreach ( int i in list_failed ) {
    		if(mysize<=15&&mysize>=10) {
    		listg.add(i);
    		mysize--;
    		printerr ("failed %i - %s\n", i, get_elnum(i));
    		}
    		else list_failed_r.add(i);
  		}
  		foreach ( int i in list_reinforce ) {
    		if(mysize<=15&&mysize>=5) {
    		listg.add(i);
    		mysize--;
    		printerr ("reinf %i - %s\n", i, get_elnum(i));
    		}
    		else list_reinforce_r.add(i);
  		}
  		foreach ( int i in list_new ) {
    		if(mysize<=15&&mysize>=3) {
    		listg.add(i);
    		mysize--;
    		printerr ("new %i - %s\n", i, get_elnum(i));
    		}
    		else list_new_r.add(i);
  		}
  		foreach ( int i in  list_learnd) {
    		if(mysize<=15&&mysize>=1) {
    		listg.add(i);
    		mysize--;
    		printerr ("learnd %i - %s\n", i, get_elnum(i));
    		}
    	}
    	foreach ( int i in list_new_r ) {
    		if(mysize<=15&&mysize>=1) {
    		listg.add(i);
    		mysize--;
    		printerr ("new %i - %s\n", i, get_elnum(i));
    		}
  		}
  		foreach ( int i in list_reinforce_r ) {
    		if(mysize<=15&&mysize>=1) {
    		listg.add(i);
    		mysize--;
    		printerr ("reinf %i - %s\n", i, get_elnum(i));
    		}
  		}
  		foreach ( int i in list_failed_r ) {
    		if(mysize<=15&&mysize>=1) {
    		listg.add(i);
    		mysize--;
    		printerr ("failed %i - %s\n", i, get_elnum(i));
    		}
  		}
    }
}

public int compare_failed (int? a, int? b) { 
	int[3] stats_a = get_stats(a);
	int[3] stats_b = get_stats(b);
	int x = stats_a[1];
	int y = stats_b[1];
	return (x < y) ? -1 : ((y < x) ? 1 : 0);
}

public int compare_learnd (int? a, int? b) { 
	int[3] stats_a = get_stats(a);
	int[3] stats_b = get_stats(b);
	int x = stats_a[2];
	int y = stats_b[2];
	return (x < y) ? -1 : ((y < x) ? 1 : 0);
}

public int compare_reinforce (int? a, int? b) { 
	int[3] stats_a = get_stats(a);
	int[3] stats_b = get_stats(b);
	int x = stats_a[2];
	int y = stats_b[2];
	return (x < y) ? -1 : ((y < x) ? 1 : 0);
}

public int compare_new (int? a, int? b) { 
	string xs = get_elnum(a);
	string ys = get_elnum(b);
	int x = xs.offset(3).to_int();
	int y = ys.offset(3).to_int();;
	return (x < y) ? -1 : ((y < x) ? 1 : 0);
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
        window.show_all ();
        statusbar1 = builder.get_object ("statusbar1") as Statusbar;
        statusbar1.push(0,"Loading DB...");
        var cb1 = builder.get_object ("checkbutton1") as CheckButton;
        cb1.active = true;
        update_bar_gfx();
        next_question ();
        Gtk.main ();
        
    } catch (Error e) {
        stderr.printf ("Could not load UI: %s\n", e.message);
        return 1;
    } 

    return 0;
}
