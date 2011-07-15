/**
 * Using SQLite in Vala Sample Code
 * Port of an example found on the SQLite site.
 * http://www.sqlite.org/quickstart.html
 */

using GLib;
using Sqlite;

public class SqliteSample : GLib.Object {

    public static int main (string[] args) {
        Database db;
        int rc;

        rc = Database.open ("testdb", out db);

        if (rc != Sqlite.OK) {
            stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
            return 1;
        }

		string test = """CREATE TABLE examquestions(
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

        rc = db.exec(test, (n_columns, values, column_names) => {
            for (int i = 0; i < n_columns; i++) {
                stdout.printf ("%s = %s\n", column_names[i], values[i]);
            }
            stdout.printf ("\n");

            return 0;
            }, null);

        if (rc != Sqlite.OK) { 
            stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
        }
        
    var file = File.new_for_path ("pools.txt");

    if (!file.query_exists ()) {
        stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
        return 1;
    }

Regex tRegEx = /~~~/;
Regex regtest = /(^(T|G|E)\d[a-zA-Z]\d\d)*.\(([A-D])\)(.*)/;

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
            string ansA = dis.read_line (null).offset(2).chomp();
            string ansB = dis.read_line (null).offset(2).chomp();
            string ansC = dis.read_line (null).offset(2).chomp();
            string ansD = dis.read_line (null).offset(2).chomp();
            string test2="";
            
            if(answer=="A") test2 = """INSERT INTO examquestions ("elnum","FCC","stem","key","distractor1","distractor2","distractor3") VALUES (""" + @"'$elnum','$fcc','$quest','$ansA','$ansB','$ansC','$ansD'"+""")""";
            if(answer=="B") test2 = """INSERT INTO examquestions ("elnum","FCC","stem","key","distractor1","distractor2","distractor3") VALUES (""" + @"'$elnum','$fcc','$quest','$ansB','$ansA','$ansC','$ansD'"+""")""";
            if(answer=="C") test2 = """INSERT INTO examquestions ("elnum","FCC","stem","key","distractor1","distractor2","distractor3") VALUES (""" + @"'$elnum','$fcc','$quest','$ansC','$ansB','$ansA','$ansD'"+""")""";
            if(answer=="D") test2 = """INSERT INTO examquestions ("elnum","FCC","stem","key","distractor1","distractor2","distractor3") VALUES (""" + @"'$elnum','$fcc','$quest','$ansD','$ansB','$ansC','$ansA'"+""")""";

			rc = db.exec(test2, (n_columns, values, column_names) => {
            for (int i = 0; i < n_columns; i++) {
                stdout.printf ("%s = %s\n", column_names[i], values[i]);
            }
            stdout.printf ("\n");

            return 0;
            }, null);

        if (rc != Sqlite.OK) { 
            stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
            stderr.printf(test2+"\n");
        }
            
			}
        }
    } catch (Error e) {
        error ("%s", e.message);
    }



        return 0;
    }
}

