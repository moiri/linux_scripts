# execute this line
# by numerating the pages take care to use 01 or 0..01 accoring to the width of
# the page count

#!/bin/sh
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

Usage: $PROGNAME [OPTION] [infile_1] [infile_2] ... [infile_n]

Merge multiple pdf files into one large pdf file. When using * character take
care to numerate the pages with leading zeros accoring to the width of the page
count (to keep the order).

Options:
-h, --help          display this usage message and exit
-o, --output [FILE] specify an output file

EOF

    exit 1
}

infile=""
outfile="out.pdf"
while [ $# -gt 0 ] ; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -o|--output)
            outfile="$2"
            shift
            ;;
        -*)
            usage "Unknown option '$1'"
            ;;
        *)
            infile="$infile$1 "
            ;;
    esac
    shift
done

if [ -z "$infile" ] ; then
    usage "Not enough arguments"
fi

gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=$outfile $infile
