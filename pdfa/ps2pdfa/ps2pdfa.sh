#!/bin/sh
# ps2pdfa - Yer Friendly PostScript to PDF/A converter, using GhostScript
# You need PDFA_def.ps and rgb.icc both, in addition to your PS.
#
# (C) Kacper "out of the goodness of his heart" Wysocki, kacper@cs.mcgill.ca
# Licensed under the GNU Public License - May 2007
#
# Version 00 - real programmers start at zero - May 15th, 2007

# where do we search for those files?
roots=$ROOTS
if [ -z "$roots" ]; then
	roots=". `dirname $0`"
fi
# and the GhostScript command?
if [ -z "$GS" ];then
	GS=gs
fi
# what params?
GSOPTS="-dPDFA -dBATCH -dNOPAUSE -dNOOUTERSAVE -dUseCIEColor -sProcessColorModel=DeviceGray -sDEVICE=pdfwrite"

usage(){
	echo "ps2pdfa - a near-PDF/A creator"
	echo "Converts your PostScript to PDF/A format by embedding fonts and more."
	echo "  Usage:"
	echo "    `basename $0` INPUT.ps [OUTPUT.pdf] [TITLE]"
	echo
	echo -n "Parameters in brackets are optional. If you don't specify OUTPUT "
	echo -n "then the output will be named INPUT (anything before "
	echo -n "the '.ps'). If you don't specify TITLE it'll default to OUTPUT, or "
	echo -n "INPUT if the former is lacking."
	echo
	echo
	echo -n "ACHTUNG! The files PDFA_def.ps and rgb.icc must be found via "
	echo -n "the ROOTS variable or the current directory for this to work, "
	echo
	echo -n "AND you will likely need the gsfonts and gsfonts-x11 packages "
	echo -n "installed on the system. Ask your admin. "
	echo
	echo
	echo "Also check out http://www.mcgill.ca/library-support/teaching/etheses/"
}

# necessary files rgb.icc and PDFA_def.ps
iccfile=rgb.icc
pdfadef=PDFA_def.ps
for root in $roots
do
	if [ -r $root/rgb.icc ];then
		iccfile=$root/rgb.icc
	fi
	if [ -r $root/PDFA_def.ps ];then
		pdfadef=$root/PDFA_def.ps
	fi
done
if [ ! -r $pdfadef ]; then
	echo "Couldn't find PDFA_def.ps in $roots"
	echo
	usage
	exit 1
fi
if [ ! -r $iccfile ]; then
	echo "Couldn't find rgb.icc in $roots"
	echo
	usage
	exit 1
fi

# parse the args - input, output and title
if [ -z "$1" ]; then
	echo "You must specify an input file"
	echo
	usage
	exit 1
fi

infile=""
if [ -r "$1" ]; then
	infile="$1"
else
	echo "Can't find input file $1"
	echo
	usage
	exit 1
fi

outfile=${1%.ps}.pdf
if [ -n "$2" ]; then
	outfile="$2"
fi

title=${outfile%.pdf}
if [ -n "$3" ]; then
	title="$3"
fi

# Generate a PDFA_def.ps with the correct title.
cat $root/PDFA_def.ps |
	sed "s/Title (title)/Title ($title)/" |
	sed "s/ICCProfile (rgb.icc)/ICCProfile ($iccfile)/" > myPDFA_def.ps

echo "==== ps2pdfa ==== Will do $infile > $outfile with title '$title' ===="
echo -n "--- This usually takes a bit of time and generates output. Patience. "
echo "Go have some tea or something."
echo
# The actual command.
if $GS $GSOPTS -sOutputFile=$outfile myPDFA_def.ps $infile
	then
	echo
	echo "Done. You should probably go look at $outfile now."
else
	echo
	echo "Oh noes! GhostScript seems to have failed. Look about for clues!"
fi
rm -f myPDFA_def.ps
