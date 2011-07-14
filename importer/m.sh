valac HEH2011.vala --pkg gee-1.0 --pkg sqlite3
./HEH2011 testdb "SELECT *  FROM "main"."ham" WHERE element LIKE '%A%';"
