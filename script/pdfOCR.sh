#!/bin/sh
mkdir tmp
cp $@ tmp
cd tmp
pdftoppm * -f 1 -l 10 -r 600 ocrbook
for i in *.ppm; do convert "$i" "`basename "$i" .ppm`.tif"; done
for i in *.tif; do tesseract "$i" "`basename "$i" .tif`" -l nld; done
for i in *.txt; do cat $i >> ${name}.txt; echo "[pagebreak]" >> pdf-ocr-output.txt; done
mv pdf-ocr-output.txt ..
rm *
cd ..
rmdir tmp