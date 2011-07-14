valac HEH2011.vala --pkg gee-1.0 --pkg sqlite3
./HEH2011 testdb "SELECT *  FROM "main"."ham" WHERE element LIKE '%A%';"

-- Describe HAM
CREATE TABLE ham(
    "ID" INTEGER PRIMARY KEY AUTOINCREMENT,
    "removed" INTEGER
    "elementID" TEXT,
    "element" TEXT,
    "subelement" TEXT,
    "subgroup" TEXT,
    "question" TEXT,
    "questionnum" INTEGER
    "FCC" TEXT,
    "stem" TEXT,
    "key" TEXT,
    "distractor1" TEXT,
    "distractor2" TEXT,
    "distractor3" TEXT,
    "illustration" BLOB,
    "hint" TEXT,
    "teaching" TEXT,
    "teaching_illustration" BLOB
)
