#!/bin/bash

cd $(dirname $0)

function extract {
  candidat=$1
  idx=$2
  out=$3
  value=$(grep "$candidat" resultats.csv |
   awk -F ";" '{print $'$idx'}')
  sed -i '$s/$/;'"$value"'/' $out
}

awk -F ";" '{print $1}' resultats.csv  | tr "\n" ";" | sed "s/candidat/datetime/" | sed 's/$/\n/' > historique-voix.csv.tmp
awk -F ";" '{print $1}' resultats.csv  | tr "\n" ";" | sed "s/candidat/datetime/" | sed 's/$/\n/' > historique-%inscrits.csv.tmp
awk -F ";" '{print $1}' resultats.csv  | tr "\n" ";" | sed "s/candidat/datetime/" | sed 's/$/\n/' > historique-%exprimes.csv.tmp

git log resultats.csv           |
 grep "commit\|Date"            |
 tr "\n" ";"                    |
 sed "s/ +0200;commit /\n/g"    |
 sed 's/commit //'              |
 sed 's/ +0200;/\n/'            |
 sed 's/Date:   //'             |
 tac                            |
 while read line; do
  commit=$(echo $line | awk -F ";" '{print $1}')
  dt=$(echo $line | awk -F ";" '{print $2}')
  dat=$(date -d "$dt" --iso-8601=minutes)
  echo $commit $dat
  git checkout $commit
  datetime="$dat"
  echo "$datetime" >> historique-voix.csv.tmp
  echo "$datetime" >> historique-%inscrits.csv.tmp
  echo "$datetime" >> historique-%exprimes.csv.tmp
  head -1 historique-voix.csv.tmp |
   sed 's/;/\n/g'             |
   grep -v datetime           |
   while read candidat; do
    extract "$candidat" 2 historique-voix.csv.tmp
    extract "$candidat" 3 historique-%inscrits.csv.tmp
    extract "$candidat" 4 historique-%exprimes.csv.tmp
   done
done

git checkout main
mv historique-voix.csv.tmp historique-voix.csv
mv historique-%inscrits.csv.tmp historique-%inscrits.csv
mv historique-%exprimes.csv.tmp historique-%exprimes.csv

