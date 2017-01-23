DATE=`date +%Y-%m-%d`

ronn --roff *.ronn --date="$DATE" --manual="Modulo manual" --organization="Modulo"

# copy all the .ronn files to .md so they can be viewed/linked on github.
for x in *.ronn; do n=${x/.ronn/.md}; cp $x $n; done
