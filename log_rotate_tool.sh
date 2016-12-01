#!/bin/bash

function help(){
    echo -e "This tool is used for rotate logs once a day\n"
    echo -e "Usage:\n\t$0 -d /home/work/log -f [filename]\n"
    echo -e "Options:"
    echo -e "\t-h\tShow this message and exit"
    echo -e "\t-d\tlog dir (necessary)"
    echo -e "\t-f\tlog file (necessary)"
    echo -e "\t-s\trotate size (default 5M), if the file is large then this, file while be rotated"
    echo -e "\t-r\tlog rotate time (default 5), max storage number of log rotate file"
    exit 0
}

size='5'
rotate='5'

while getopts "hd:f:s:r:" Option
    # b and d take arguments
    #
do
    case $Option in
        h) help;;
        d) dir=$OPTARG;;
        f) file=$OPTARG;;
        s) size=$OPTARG;;
        r) rotate=$OPTARG;;
    esac
done
shift $(($OPTIND - 1))

[[ x$dir == x ]] || [[ x$file == x ]] && help

[[ x`echo $size |awk '/^[0-9]*[1-9][0-9]*$/'` == x ]] && echo -e "size should be a positive integer" && exit 1
[[ x`echo $rotate |awk '/^[0-9]*[1-9][0-9]*$/'` == x ]] && echo -e "rotate should be a positive integer" && exit 1
size=$size'M'

lrfile=$dir/$file'.lr'
touch $lrfile
touch /etc/cron.d/$file'_rotate_cron'

cat <<EOF >$lrfile
$dir/$file {
    size=$size
    rotate $rotate
    create 644 root root
}
EOF

cat <<EOF >/etc/cron.d/$file'_rotate_cron'
0 0 * * * /usr/sbin/logrotate  $lrfile
EOF

crontab /etc/cron.d/$file'_rotate_cron'
