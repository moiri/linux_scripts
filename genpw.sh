#!/bin/bash
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
-p, --pattern [STRING]  specify a pattern to compose the random string
                        (default: "a-zA-Z0-9")
-s, --special [STRING]  specify a string of charcters where each character must
                        be contained in the final password (default: "_$")
                        note: special regEx characters have to be escaped

EOF

    exit 1
}

rand=""
pattern="a-zA-Z0-9"
special="_$"
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
        -s|--special)
            special="$2"
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
    spec_len=$(expr length $special)
    spec_str=$special
    pw=$(cat /dev/urandom | tr -dc $pattern | fold -w $(( 10#$length - 10#$spec_len )) | head -n 1)
    while [[ -n $spec_str ]]
    do
        char=${spec_str:(-1)}
        pos=$(( RANDOM % $(( 10#$length - 10#$spec_len + 1 )) ))
        pw=$(echo ${pw:0:$pos}$char${pw:$pos:$(( 10#$length - 10#$spec_len ))-$pos})
        spec_str=$(echo ${spec_str%?})
        spec_len=$(( 10#$spec_len - 1 ))
    done
    echo $pw
done
