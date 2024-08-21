#!/bin/bash

TIMEFORMAT="-u --rfc-3339=seconds" # date format for log line entries
RPC="http://127.0.0.1:8899"
LOGPATH="/var/log/nodemonitor"
LOGNAME="nodemonitor-sol.log"
LOGSIZE="200"
SLEEP1="5"
BINDIR=""               # auto detection of the solana binary directory can fail, or an alternative custom installation can be specified
CONFIGDIR="$HOME/.config/solana"            # the directory for the config files, eg.: '$HOME/.config/solana'

logfile="${LOGPATH}/${LOGNAME}"
touch $logfile
nloglines=$(wc -l <$logfile)
if [ $nloglines -gt $LOGSIZE ]; then sed -i "1,$(($nloglines - $LOGSIZE))d" $logfile; fi # the log file is trimmed for LOGSIZE

if [ -n "$BINDIR" ]; then
    cli="timeout -k 8 6 ${BINDIR}/solana"
else
    if [ -z "$CONFIGDIR" ]; then
        echo "please configure the config directory"
        exit 1
    fi
    installDir="$(cat ${CONFIGDIR}/install/config.yml | grep 'active_release_dir\:' | awk '{print $2}')/bin"
    if [ -n "$installDir" ]; then cli="${installDir}/solana"; else
        echo "please configure the cli manually or check the CONFIGDIR setting"
        exit 1
    fi
fi

while true; do
    pub_rpc=`$cli config get | grep "RPC URL:" | awk '{print $NF}'`
    #pub_rpc="http://asdasd.com:8899"
    err=0
    VERSION=`$cli cluster-version -u ${RPC}`
    if [[ $? -ne 0 ]]; then
        err=1
    fi
    PUB_HEIGHT=`$cli block-height -u ${pub_rpc} --commitment confirmed`
    if [[ $? -ne 0 ]]; then
        err=1
    fi
    HEIGHT=`$cli block-height -u ${RPC} --commitment confirmed`
    if [[ $? -ne 0 ]]; then
        err=1
    fi

    if [[ err -eq 0 ]]; then
        LAG=$(expr $PUB_HEIGHT - $HEIGHT)
        if (( LAG < 0 )); then
            LAG=0
        fi
        now=$(date $TIMEFORMAT)
        logentry="version=$VERSION lag=$LAG"
        echo "$logentry"
        echo "[$now] $logentry" >>$logfile
        nloglines=$(wc -l <$logfile)
        if [ $nloglines -gt $LOGSIZE ]; then
            mv $logfile "${logfile}.1"
            touch $logfile
        fi
    fi
    sleep $SLEEP1
done

