#!/bin/bash

TYPE=$1
NAME=$2
STATE=$3

modify_probe_status() {
    STATUS=$1

    LB_PROBE_PORT=80
    LB_PROBE_DEV=eth0

    if [[ $STATUS == "down" ]]; then
        # Add firewall rule to block LB probe port
        /sbin/iptables -A INPUT -p tcp --dport $LB_PROBE_PORT -j REJECT -i $LB_PROBE_DEV
    elif [[ $STATUS == "up" ]]; then
        # Remove all entries to block LB probe port
        RC=0
        while [[ $RC -eq 0 ]]; do
            RC=`/sbin/iptables -D INPUT -p tcp --dport $LB_PROBE_PORT -j REJECT -i $LB_PROBE_DEV 2>/dev/null; echo $?`
        done
    else
        echo "Unknown probe status"
    fi
}

if [[ "$NAME" == "VI_1" ]]; then
    case $STATE in
        "MASTER") modify_probe_status up
             exit 0
             ;;
        "BACKUP"|"STOP") modify_probe_status down
             exit 0
                          ;;
        "FAULT")  modify_probe_status down
             exit 0
             ;;
        *)        echo "unknown state"
             exit 1
             ;;
    esac
else
        echo "Nothing to do"
        exit 0
fi

