/**
 * Using SQLite in Vala Sample Code
 * Port of an example found on the SQLite site.
 * http://www.sqlite.org/quickstart.html
 */

using GLib;
using Sqlite;

public class SqliteSample : GLib.Object {
	
	public static int callback (int n_columns, string[] values,
                                string[] column_names)
    {
        for (int i = 0; i < n_columns; i++) {
            stdout.printf ("%s = %s\n", column_names[i], values[i]);
        }
        stdout.printf ("\n");

        return 0;
    }

    public static int main (string[] args) {
        Database db;
        int rc;

        rc = Database.open ("testdb", out db);

        if (rc != Sqlite.OK) {
            stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
            return 1;
        }

		string examquestions = """CREATE TABLE examquestions(
"ID" INTEGER PRIMARY KEY AUTOINCREMENT,
"removed" INTEGER,
"elnum" TEXT,
"FCC" TEXT,
"stem" TEXT,
"key" TEXT,
"distractor1" TEXT,
"distractor2" TEXT,
"distractor3" TEXT,
"illustration" BLOB
)""";

		string stats = """CREATE TABLE "stats" (
    "ID" INTEGER PRIMARY KEY,
    "tries" INTEGER,
    "failed" INTEGER,
    "learnd" INTEGER
)""";

		string viewt ="""CREATE VIEW "T" AS SELECT * FROM "main"."examquestions" WHERE  elnum LIKE "T%"""";
		string viewg ="""CREATE VIEW "G" AS SELECT * FROM "main"."examquestions" WHERE  elnum LIKE "G%"""";
		string viewe ="""CREATE VIEW "E" AS SELECT * FROM "main"."examquestions" WHERE  elnum LIKE "E%"""";
        /*rc = db.exec(examquestions, (n_columns, values, column_names) => {
            for (int i = 0; i < n_columns; i++) {
                stdout.printf ("%s = %s\n", column_names[i], values[i]);
            }
            stdout.printf ("\n");

            return 0;
            }, null);*/

        if ((rc = db.exec (examquestions, callback, null)) != Sqlite.OK) { 
            stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
            }
        if ((rc = db.exec (stats, callback, null)) != Sqlite.OK) { 
            stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
            }
        if ((rc = db.exec (viewt, callback, null)) != Sqlite.OK) { 
            stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
            }
        if ((rc = db.exec (viewg, callback, null)) != Sqlite.OK) { 
            stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
            }
        if ((rc = db.exec (viewe, callback, null)) != Sqlite.OK) { 
            stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
            }
    var file = File.new_for_path ("pools.txt");

    if (!file.query_exists ()) {
        stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
        return 1;
    }

Regex tRegEx = /~~~/;
Regex regtest = /(^(T|G|E)\d[a-zA-Z]\d\d)*.\(([A-D])\)(.*)/;
Regex filereg = /figure\s([TGE0-9-]*)(\s|\?|,)/i;
int counter=0;
    try {
        var dis = new DataInputStream (file.read());
        string line;

        while ((line = dis.read_line (null)) != null) {
            
            if(tRegEx.match(line)){
            line = dis.read_line (null);
            string[] strbuf = regtest.split(line);
            string elnum = strbuf[1]; //elnum
            string answer = strbuf[3]; //answer
            string fcc = "";
            if (strbuf[4]!=null) fcc = strbuf[4];
            string quest = dis.read_line (null).chomp(); //stem
            string ansA = dis.read_line (null).offset(2)._strip ().chomp();
            string ansB = dis.read_line (null).offset(2)._strip ().chomp();
            string ansC = dis.read_line (null).offset(2)._strip ().chomp();
            string ansD = dis.read_line (null).offset(2)._strip ().chomp();
            
            string ba= @"'$elnum','$fcc','$quest',";
            
            string qa="";
            if(answer=="A") qa = @"'$ansA','$ansB','$ansC','$ansD'";
            if(answer=="B") qa = @"'$ansB','$ansA','$ansC','$ansD'";
            if(answer=="C") qa = @"'$ansC','$ansB','$ansA','$ansD'";
            if(answer=="D") qa = @"'$ansD','$ansB','$ansC','$ansA'";
			
			string[] fname = filereg.split(quest);
			if (fname[1] != null)
			{
				var file2 = File.new_for_path (fname[1]+".jpg");
				counter++;
				stdout.printf ("%i blob file %s\n", counter ,fname[1]);
				if (!file2.query_exists ()) {
					stderr.printf ("File '%s' doesn't exist.\n", file2.get_path ());
					return 1;
				}
				var file_info = file2.query_info ("*", FileQueryInfoFlags.NONE);
				
				var file_stream = file2.read ();
				var data_stream = new DataInputStream (file_stream);
				uint8[] buffer = new uint8[file_info.get_size ()];
				//file_stream.seek (image_data_offset, SeekType.CUR);
				data_stream.read (buffer);
				string dbstr = """INSERT INTO examquestions ("elnum","FCC","stem","key","distractor1","distractor2","distractor3","illustration") VALUES (""" + ba + qa +""",?)""";
				Statement stmt;
				if ((rc = db.prepare_v2 (dbstr, -1, out stmt, null)) == 1) {
					printerr ("SQL error: %d, %s\n", rc, db.errmsg ());
					return 1;
				}
				stmt.bind_blob(1, buffer, (int) file_info.get_size (), null);
				stmt.step();
			}
			else 
			{
				string dbstr = """INSERT INTO examquestions ("elnum","FCC","stem","key","distractor1","distractor2","distractor3") VALUES (""" + ba + qa +""")""";
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
			
			string dbstr = """INSERT INTO "stats" ("tries","failed","learnd") VALUES (0,0,0)""";
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
        }
    } catch (Error e) {
        error ("%s", e.message);
    }



        return 0;
    }
}

