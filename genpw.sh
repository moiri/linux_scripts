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

Usage: $PROGNAME [OPTION ...]

Generate a random string

Options:
-h, --help              display this usage message and exit
-n, --numeric           only use numeric characters
-a, --alphanumeric      only use alphanumeric characters
-l, --length [#]        length of the random string (default: 16)
-c, --count [#]         number of generated strings (default: 1)
-p, --pattern [STRING]  specify a pattren to compose the random string
                        (defualt: "a-zA-Z0-9_$")

EOF

    exit 1
}

rand=""
pattern="a-zA-Z0-9_$"
length=16
count=1
output="-"
while [ $# -gt 0 ] ; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -n|--numeric)
            pattern="0-9"
            ;;
        -a|--alphanumeric)
            pattern="a-zA-Z0-9"
            ;;
        -l|--length)
            length="$2"
            shift
            ;;
        -c|--count)
            count="$2"
            shift
            ;;
        -p|--pattern)
            pattern="$2"
            shift
            ;;
        -*)
            usage "Unknown option '$1'"
            ;;
        *)
            usage "Too many arguments"
            ;;
    esac
    shift
done

for i in $(seq 1 $count); do
    cat /dev/urandom | tr -dc $pattern | fold -w $length | head -n 1
done
