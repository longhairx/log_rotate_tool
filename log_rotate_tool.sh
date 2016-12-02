#!/bin/bash
########################################
#	> File Name: log_rotate_tool.sh
#	> Author: Meng Zhuo
#	> Mail: mengzhuo@xiaomi.com
#	> Created Time: 2016年12月01日 星期四 16时12分58秒
########################################


function help(){
    echo -e "This tool is used for rotate logs once a day\n"
    echo -e "Usage:\n\t$0 -d /home/work/log -f [filename]\n"
    echo -e "Options:"
    echo -e "\t-h\tShow this message and exit"
    echo -e "\t-d\tlog dir (necessary)"
    echo -e "\t-f\tlog file (necessary)"
    echo -e "\t-s\trotate size (default 5M), if the file is large then this, file while be rotated"
    echo -e "\t-r\tlog rotate time (default 5), max storage number of log rotate files"
    echo -e "\t-H\trotate every hour"
    echo -e "\t-D\trotate every day"
    echo -e "\t-M\trotate every month"

    exit 0
}

size='5'
rotate='5'
day='0'
month='*'
hour='0'

while getopts "hd:f:s:r:DHM" Option
    # b and d take arguments
    #
do
    case $Option in
        h) help;;
        d) dir=$OPTARG;;
        f) file=$OPTARG;;
        s) size=$OPTARG;;
        r) rotate=$OPTARG;;
        H) day='*';month='*';hour='0';;
        D) day='0';month='*';hour='0';;
        M) day='0';month='0';hour='0';;
    esac
done
shift $(($OPTIND - 1))

[[ x$dir == x ]] || [[ x$file == x ]] && help

[[ x`echo $size |awk '/^[0-9]*[1-9][0-9]*$/'` == x ]] && echo -e "size should be a positive integer" && exit 1
[[ x`echo $rotate |awk '/^[0-9]*[1-9][0-9]*$/'` == x ]] && echo -e "rotate should be a positive integer" && exit 1
size=$size'M'

lrfile=$dir/$file'.lr'
cronfile=$dir/$file'_rotate_cron'
touch $lrfile
touch $cronfile
cat <<EOF >$lrfile
$dir/$file {
    size=$size
    rotate $rotate
    create 644 root root
}
EOF

historycron=`crontab -l`

#cat <<EOF >/etc/cron.d/$file'_rotate_cron'
cat <<EOF >$cronfile
$historycron
$hour $day $month * * /usr/sbin/logrotate  $lrfile
EOF

crontab $cronfile
