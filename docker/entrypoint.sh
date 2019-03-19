#!/bin/sh
# schedule task in cron and start daemon
set -euxo pipefail
cd `dirname "$0"`

# assert env vars exist with bash parameter expansion (http://wiki.bash-hackers.org/syntax/pe#display_error_if_null_or_unset)
: ${CRON_SCHEDULE:?}

echo "$CRON_SCHEDULE sh $(pwd)/run.sh" > /var/spool/cron/crontabs/root
exec crond -f

