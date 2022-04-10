#!/bin/bash

cd $(dirname $0)

echo "candidat;voix;%inscrits;%exprimés" > resultats.csv
curl -s https://www.resultats-elections.interieur.gouv.fr/presidentielle-2022/FE.html |
 iconv -f iso-8859-15       |
 grep '<td style'           |
 head -n 48                 |
 sed 's/\s*<[^>]*>\s*//g'   |
 tr "\n" ";"                |
 sed 's/;$//'               |
 sed 's/;M/\nM/g' >> resultats.csv

function extract {
  candidat=$1
  idx=$2
  out=$3
  value=$(grep "$candidat" resultats.csv |
   awk -F ";" '{print $'$idx'}'          |
   sed 's/,/./'                          |
   sed 's/ //')
  sed -i '$s/$/,'"$value"'/' $out
}

if git diff resultats.csv | grep . > /dev/null && grep "ARTHAUD" resultats.csv > /dev/null; then

  datetime=$(date --iso-8601=minutes)
  echo "$datetime" >> historique-voix.csv
  echo "$datetime" >> historique-%inscrits.csv
  echo "$datetime" >> historique-%exprimes.csv
  head -1 historique-voix.csv |
   sed 's/,/\n/g'             |
   grep -v datetime           |
   while read candidat; do
    extract "$candidat" 2 historique-voix.csv
    extract "$candidat" 3 historique-%inscrits.csv
    extract "$candidat" 4 historique-%exprimes.csv
   done

  git add resultats.csv historique*.csv
  git commit -m "update data"
  git push
fi
