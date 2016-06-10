#!/bin/bash
#http://agateau.com/2014/template-for-shell-based-command-line-scripts/
set -e

PROGNAME=$(basename $0)

die() {
    echo "$PROGNAME: $*" >&2
    exit 1
}

usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF

Usage: $PROGNAME [OPTION ...] file
Convert pdf bank statements into text. Rows of tab seperated 'date'-'balance'
pairs are printed out. Additionlally, The following files are created:
 %Y%m%d.bal:       original balance values
 %Y%m%d_final.bal: standartized balance values
 %Y%m%d.dat:       original dates
 %Y%m%d_final.dat: standartized date values
 %Y%m%d.in:        income
 %Y%m%d.out:       spent
 %Y%m%d.tab:       original values seperated by whitespaces

Options:
-h, --help          display this usage message and exit
-a, --append        append to output file
-o, --output [FILE] write output to file

EOF

    exit 1
}

input=""
output=""
append=0
while [ $# -gt 0 ] ; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -a|--append)
            append=1
            ;;
        -o|--output)
            output="$2"
            shift
            ;;
        -*)
            usage "Unknown option '$1'"
            ;;
        *)
            if [ -z "$input" ] ; then
                input="$1"
                filename=$(basename "$input")
                extension="${filename##*.}"
                filename="${filename%.*}"
            else
                usage "Too many arguments"
            fi
            ;;
    esac
    shift
done

if [ -z "$input" ] ; then
    usage "Not enough arguments"
fi
if [ -z "$output" ] ; then
    output=/dev/stdout
fi

tabfile=${filename}.tab
infile=${filename}.in
outfile=${filename}.out
balfile=${filename}.bal
datfile=${filename}.dat
fbalfile=${filename}_final.bal
fdatfile=${filename}_final.dat

# convert pdf to text file by keeping the layout
# cut away the first 55 characters
# cut away anything following (and including) the line starting with "Statement closing balance"
# cut away anything before (and including) the line "BROUGHT FORWARD"
# remove empty lines
# clean up balance values (remove ' S' and commas)
pdftotext -layout $input /dev/stdout | cut -c55- | sed '/Statement closing balance.*/,$d' | sed '0,/BROUGHT FORWARD .*$/d' | sed '/^\s*$/d' | sed 's/\(\.[0-9][0-9]\) S/\1/ig' | sed 's/,//g' > $tabfile
cut -c109- $tabfile | awk '{$1=$1};1' > $balfile
cut -c-21 $tabfile | awk '{$1=$1};1' > $datfile
cut -c-76 $tabfile | cut -c60- | awk '{$1=$1};1' > $outfile
cut -c-97 $tabfile | cut -c80- | awk '{$1=$1};1' > $infile
date -f $datfile +${filename:0:4}%m%d | uniq > $fdatfile
sed '/^\s*$/d' $balfile > $fbalfile

if [ $append -eq 0 ]; then
    paste $fdatfile $fbalfile > $output
else
    paste $fdatfile $fbalfile >> $output
fi
