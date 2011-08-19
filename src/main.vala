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
int listg_new_questions;

enum st {
 TRIES,
 FAIL,
 LEARND,
}

public int64[] get_stats(int ID){
	int rc; 
	string a="0",b="0",c="0",d="0",e="0",f="0",g="0";
	string buff = """SELECT * FROM "main"."stats" WHERE "ID" LIKE """ + @"$ID";
	rc = db.exec(buff, (n_columns, values, column_names) => {
    	a = values[1];
    	b = values[2];
    	c = values[3];
    	d = values[4];
    	e = values[5];
    	f = values[6];
    	g = values[7];
        return 0;
    }, null);
    int64[] rbuff = new int64[7];
    rbuff[0] = int64.parse(a);
    rbuff[1] = int64.parse(b);
    rbuff[2] = int64.parse(c);
    rbuff[3] = int64.parse(d);
    rbuff[4] = int64.parse(e);
    rbuff[5] = int64.parse(f);
    rbuff[6] = int64.parse(g);
    return rbuff;
}

public void set_stats(int ID, int64[] stats){
	int rc; 
    int64 a=stats[0],b=stats[1],c=stats[2],d=stats[3],e=stats[4],f=stats[5],g=stats[6];
    string dbstr = """REPLACE INTO stats ("ID","tries","failed","learnd","time","read","timei","interval") VALUES (""" + @"$ID, $a, $b, $c, $d, $e, $f, $g" +""")""";
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
    int64[7] stats = get_stats(Q_ID);
    //var mytime = new DateTime.from_unix_utc (stats[3]);
    //printerr ("Last time: %s\n", mytime.to_string());
    if(radiobutton==0 || radiobutton==1 || radiobutton==2 || radiobutton==4){
	    stats[0]++; //add to tries
	
		if(OK){ 
	    	if(stats[1]<-2) stats[1] = -1; // if he faild before and gets it right set to -1
	    		else stats[1]++; // if ok add one to fails
	    	stats[6]++;
	    }
	    else{ 
	    	if(stats[1]>=0) stats[1] = -2; // for first time or if later fail set to -2
	    		else stats[1]--; // if not OK sub fails
	    	stats[4]=0; //reset the read
	    	stats[6]--; 
	    }
	    
	    if(stats[0]>=3 && stats[1]>2)stats[2]++; // if try > 3 and fails also > 2 count learnd
	    
	    if(radiobutton==0 && OK && stats[0]==1) {
	    	stats[0]=3;
	    	stats[1]=3;
	    	stats[2]=1;
	    	stats[6]=2;
    	}
    }
    
    var time = new DateTime.now_local();
    if(radiobutton==3)
    {
	    stats[3] = time.to_unix();
	    stats[4]++;
    }
    if(radiobutton==4)
    {
	    stats[5] = time.to_unix();
    }
    
    set_stats(Q_ID, stats);
    
	cols2++;
    var labe14 = builder.get_object ("label4") as Label;
    int count = listg.size;
	if(OK) {
        statusbar1.push(0,@"Good Job! Question $listg_index of $count. $listg_new_questions new questions left in the query.");
        labe14.label = "You got it!";
    }
    else{ 
        statusbar1.push(0,@"Wrong! Question $listg_index of $count. $listg_new_questions new questions left in the query.");
        labe14.label = "Nice try!";
    }
    update_bar_gfx();
    color_checkmark();
}

public void next_question () {
	if(non_selected) return;
	if(listg_index==-1 || listg_index>=listg.size) select_questions ();
	cont_next_question(listg[listg_index++]);
	statusbar1 = builder.get_object ("statusbar1") as Statusbar;
	int count = listg.size;
    statusbar1.push(0,@"Question $listg_index of $count. $listg_new_questions new questions left in the query.");
}

public void select_questions () {
	statusbar1 = builder.get_object ("statusbar1") as Statusbar;
    statusbar1.push(0,"Loading... WAIT");
    if(non_selected) return;
	//get list of IDs from slected questions
	create_selected_questions ();
	//sort so that if multible lessions are selected it goes changes...
	// sort all in different list, one list for failed one for learnd one list for new  
	//put questions with less tries to the front 
	//sprinkel wrong aswerd questions after 3 new learnd for example
	//short the list
	//keep track of wrong answerd and put back in list
	//keep track of right answerd and put back in list the reinforce
	//I'm thinking to use some of Pimsleur's graduated-interval recall times as well:
	//The intervals published in his paper were: 5 seconds, 25 seconds, 2 minutes, 10 minutes, 1 hour, 5 hours, 1 day, 5 days, 25 days, (stop here for our purpose)4 months, 2 years.
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
	listg_new_questions=0;
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
    
    if(list_temp.size==0) list_temp.add(0);
    
    //eval
    if(radiobutton==0) {
	    list_temp.sort(compare_new);
	    foreach ( int i in list_temp ) {
	    	listg.add(i);
	    	int64[7] stats = get_stats(i);
	    	if(stats[0]==0) listg_new_questions++;
	    	printerr ("eval %i - %s\n", i, get_elnum(i));
	  	}
    }
    //study
    if(radiobutton==1) {    
	    //sort into the different lists
	    foreach (int i in list_temp) {
	        int64[7] stats = get_stats(i);
	        if(stats[0] == 0) {
	        	list_new.add(i);
	        	listg_new_questions++;
	        }
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
	    		printerr ("reinfr %i - %s\n", i, get_elnum(i));
	    		}
	  		}
	  		foreach ( int i in list_failed_r ) {
	    		if(mysize<=15&&mysize>=1) {
	    		listg.add(i);
	    		mysize--;
	    		printerr ("failedr %i - %s\n", i, get_elnum(i));
	    		}
	    	}
//	  		foreach ( int i in list_failed ) {
//	    		if(mysize<=15&&mysize>=10) {
//	    		listg.add(i);
//	    		mysize--;
//	    		printerr ("failed2 %i - %s\n", i, get_elnum(i));
//	    		}
//	  		}	
			foreach ( int i in  list_learnd) {
	    		if(mysize<=15&&mysize>=1) {
	    		listg.add(i);
	    		mysize--;
	    		printerr ("learndr %i - %s\n", i, get_elnum(i));
	    		}
	    	}
	    }
	    printerr ("mysize %i \n", mysize);
    }
    //just random list
    if(radiobutton==2) {
	    int tempint,j;
	    for (int i=(list_temp.size-1); i>= 1;i--) {
		    j = Random.int_range (0, i);
	    	tempint = list_temp[j];
	    	list_temp[j] = list_temp[i];
	    	list_temp[i] = tempint;
	    }
	    foreach ( int i in list_temp ) {
	    	listg.add(i);
	    	int64[7] stats = get_stats(i);
	    	if(stats[0]==0) listg_new_questions++;
	    	printerr ("random %i - %s\n", i, get_elnum(i));
	  	}
    }
    //read and interval is time based
	if(radiobutton==3) {
		var cbNew = builder.get_object ("checkbuttonNew") as CheckButton;
		int tempint,j;
		bool oneshot = true;
		var vlocal_time = new DateTime.now_local();
		int64 local_time = vlocal_time.to_unix();
	    for (int i=(list_temp.size-1); i>= 1;i--) {
		    j = Random.int_range (0, i);
	    	tempint = list_temp[j];
	    	list_temp[j] = list_temp[i];
	    	list_temp[i] = tempint;
	    }
	    foreach ( int i in list_temp ) {
		    bool add = false;
		    bool addo = false;
		    int64[7] stats = get_stats(i);
	    	if(stats[4]==0) {
	    		addo = true;
	    		listg_new_questions++;
    		}
	    	//The intervals published in his paper were: 5 seconds, 25 seconds, 2 minutes 120, 10 minutes 600, 1 hour 3600, 5 hours 3600*5, 1 day 3600*24, 5 days 3600*24*5, 25 days 3600*24*25, (stop here for our purpose)4 months, 2 years.
	
	    	if(stats[4]==1 && (local_time-stats[3])>5) add = true;
	    	if(stats[4]==2 && (local_time-stats[3])>25) add = true;
	    	if(stats[4]==3 && (local_time-stats[3])>120) add = true;
	    	if(stats[4]==4 && (local_time-stats[3])>300) add = true;
	    	if(stats[4]==5 && (local_time-stats[3])>800) add = true;
	    	if(stats[4]==6 && (local_time-stats[3])>1800) add = true;
	    	if(stats[4]==7 && (local_time-stats[3])>3600) add = true;
	    	if(stats[4]==8 && (local_time-stats[3])>3600*2) add = true;
	    	if(stats[4]==9 && (local_time-stats[3])>3600*24) add = true;
	    	if(stats[4]==10 && (local_time-stats[3])>3600*24*2) add = true;
	    	if(stats[4]==11 && (local_time-stats[3])>3600*24*7) add = true;
	    	if(stats[4]==12 && (local_time-stats[3])>3600*24*14) add = true;
		    
			if(addo && oneshot && cbNew.active == true){
	    		listg.add(i);
	    		oneshot = false;
	    		printerr ("one shoot new interval %i - %s\n", i, get_elnum(i));
    		}
    		if(add){
	    		listg.add(i);
	    		oneshot = false;
	    		printerr ("interval %i - %s ", i, get_elnum(i));
	    		printerr ("/ num: %lld / time: %lld\n", stats[4],local_time-stats[3]);
	    	
    		}
	  	}
	  	if(listg.size==0)listg.add(0);
	  	
    }
    if(radiobutton==4) {
	    var cbNew = builder.get_object ("checkbuttonNew") as CheckButton;
		int tempint,j;
		bool oneshot = true;
		var vlocal_time = new DateTime.now_local();
		int64 local_time = vlocal_time.to_unix();
	    for (int i=(list_temp.size-1); i>= 1;i--) {
		    j = Random.int_range (0, i);
	    	tempint = list_temp[j];
	    	list_temp[j] = list_temp[i];
	    	list_temp[i] = tempint;
	    }
	    foreach ( int i in list_temp ) {
		    bool add = false;
		    bool addo = false;
		    int64[7] stats = get_stats(i);
	    	if(stats[6]<=0){
	    		addo = true;
	    		listg_new_questions++;
    		}
	    	//The intervals published in his paper were: 5 seconds, 25 seconds, 2 minutes 120, 10 minutes 600, 1 hour 3600, 5 hours 3600*5, 1 day 3600*24, 5 days 3600*24*5, 25 days 3600*24*25, (stop here for our purpose)4 months, 2 years.
	
	    	if(stats[6]==1 && (local_time-stats[5])>5) add = true;
	    	if(stats[6]==2 && (local_time-stats[5])>25) add = true;
	    	if(stats[6]==3 && (local_time-stats[5])>120) add = true;
	    	if(stats[6]==4 && (local_time-stats[5])>300) add = true;
	    	if(stats[6]==5 && (local_time-stats[5])>800) add = true;
	    	if(stats[6]==6 && (local_time-stats[5])>1800) add = true;
	    	if(stats[6]==7 && (local_time-stats[5])>3600) add = true;
	    	if(stats[6]==8 && (local_time-stats[5])>3600*2) add = true;
	    	if(stats[6]==9 && (local_time-stats[5])>3600*24) add = true;
	    	if(stats[6]==10 && (local_time-stats[5])>3600*24*2) add = true;
	    	if(stats[6]==11 && (local_time-stats[5])>3600*24*7) add = true;
	    	if(stats[6]==12 && (local_time-stats[5])>3600*24*14) add = true;
		    
			if(addo && oneshot && cbNew.active == true){
	    		listg.add(i);
	    		oneshot = false;
	    		printerr ("one shoot new interval %i - %s\n", i, get_elnum(i));
    		}
    		if(add){
	    		listg.add(i);
	    		oneshot = false;
	    		printerr ("interval %i - %s ", i, get_elnum(i));
	    		printerr ("/ num: %lld / time: %lld\n", stats[6],local_time-stats[5]);	
	    	
    		}
	  	}
	  	if(listg.size==0)listg.add(0);
	  	
    }
}

public int compare_failed (int? a, int? b) { 
	int64[7] stats_a = get_stats(a);
	int64[7] stats_b = get_stats(b);
	int64 x = stats_a[1];
	int64 y = stats_b[1];
	return (x < y) ? -1 : ((y < x) ? 1 : 0);
}

public int compare_learnd (int? a, int? b) { 
	int64[7] stats_a = get_stats(a);
	int64[7] stats_b = get_stats(b);
	int64 x = stats_a[2];
	int64 y = stats_b[2];
	return (x < y) ? -1 : ((y < x) ? 1 : 0);
}

public int compare_reinforce (int? a, int? b) { 
	int64[7] stats_a = get_stats(a);
	int64[7] stats_b = get_stats(b);
	int64 x = stats_a[2];
	int64 y = stats_b[2];
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
	            //Pixbuf pixbuf = new Gdk.Pixbuf.from_stream(imgstream,null);
                Pixbuf pixbuf = new Gdk.Pixbuf.from_stream_at_scale(imgstream, 540, 380, true, null);
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
	if(radiobutton==3){
		Regex tRegEx = /choices are correct/;
		button1.label = k;
		if(tRegEx.match(k)){
			button2.label = d1;
			button3.label = d2;
			button4.label = d3;
		}
		else{
			button2.label = "";
			button3.label = "";
			button4.label = "";			
		}
		answerg = 1;
	}
	else{
		
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
    radiobutton = 1;
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
        //var cb1 = builder.get_object ("checkbutton1") as CheckButton;
        //cb1.active = true;
        non_selected=true;
        update_bar_gfx();
        color_checkmark ();
        next_question ();
        Gtk.main ();
        
    } catch (Error e) {
        stderr.printf ("Could not load UI: %s\n", e.message);
        return 1;
    } 

    return 0;
}
