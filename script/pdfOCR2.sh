#!/bin/sh
SOURCE=$@ # set to the file name of the PDF
OUTPUT=$@.txt # set to the final output file
STARTPAGE=1 # set to pagenumber of the first page of PDF you wish to convert
ENDPAGE="$(pdfinfo $SOURCE | grep Pages | sed 's/[^0-9]*//')" # set to pagenumber of the last page of PDF you wish to convert
RESOLUTION=600 # set to the resolution the scanner used (the higher, the better)

touch $OUTPUT
for i in `seq $STARTPAGE $ENDPAGE`; do
    echo converting page $i
    convert -posterize 2 -density $RESOLUTION $SOURCE\[$(($i - 1 ))\] page.gif
    echo processing page $i
    tesseract page.gif tempoutput
    cat tempoutput.txt >> $OUTPUT
done