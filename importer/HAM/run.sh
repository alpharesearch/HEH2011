#/bin/sh
rm pools.txt
perl tech.pl
perl general.pl
perl extra.pl
cat 2.txt 3.txt 4.txt >> pools.txt
