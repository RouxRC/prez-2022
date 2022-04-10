#!/bin/bash

echo "candidat;voix;%inscrits;%exprimés" > resultats.csv
curl -s https://www.resultats-elections.interieur.gouv.fr/presidentielle-2022/FE.html |
 iconv -f iso-8859-15       |
 grep '<td style'           |
 head -n 48                 |
 sed 's/\s*<[^>]*>\s*//g'   |
sed 's/;M/\nM/g' >> resulats.csv

git add resultats.csv
git commit -m "update data"
git push

