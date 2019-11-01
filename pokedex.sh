#!/usr/bin/env bash

readonly HEADER="<!DOCTYPE html>
<html>
    <body>
        <h2>Pokedex</h2>"
readonly FOOTER="   </body>
</html>"
readonly FILENAME="pokedex.html"

pages=""

while [[ $pages = "" ]]; do
    echo "Select the option:
        a - static pokemon (.png)
        b - dynamic pokemon (.gif)
        c - all

    selected option"
    read option

    case $option in
        a) pages="$(seq 1 8)";;
        b) pages="9";;
        c) pages="$(seq 1 9)";;
        *) echo -e "Invalid option\n";;
    esac
done

echo "$HEADER" > $FILENAME

echo $pages |
    xargs -n1 -P9 bash -c 'num=$(if [ "1" -eq $0 ]; then echo ""; else echo $0; fi); curl "https://www.pokeyplay.com/info_pokedex$num.php"' |
    grep -o "<img src=\"http://urpgstatic.com.*/strong>" |
    sort |
    sed "s/<img/        <div style=\"float:left;\"><a href=\"https:\/\/www.pokemon.com\/us\/pokedex\/my-pokemon\" target=\"_blank\"><img/g; \
    s/\/strong>/\/strong><\/div>/g; \
    s/#[0-9]* -/<\/a><br\/>/g"  >> $FILENAME


finalNames=`grep -o "<strong>.*</strong>" $FILENAME |
            grep -o ">.*<" |
            sed -E 's/<|>|Mega| X| Y//g; s/-M/-Male/g; s/-F/-Female/g' |
            tr '[:upper:]' '[:lower:]'`

for i in $finalNames
do
    sed -i "" "1,/my-pokemon/s/my-pokemon/$i/" $FILENAME
done

echo "$FOOTER" >> $FILENAME
