#!/bin/sh
# schedule task in cron and start daemon

# assert env vars exist with bash parameter expansion (http://wiki.bash-hackers.org/syntax/pe#display_error_if_null_or_unset)
: ${CRON_SCHEDULE:?}

redirectToDockerLogs='> /proc/1/fd/1 2> /proc/1/fd/2'
echo "$CRON_SCHEDULE sh /run.sh $redirectToDockerLogs" > /var/spool/cron/crontabs/root
crond -l 2 -f

