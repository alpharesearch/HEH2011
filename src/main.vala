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
