#!/bin/bash
#
# Put this script under /opt/
# Set the cron (managed by Ansible for now)
# * * * * * root bash /opt/mail_monitor.sh >> /var/log/mail_monitor.log 2>&1
#

SLACK_TOKEN="https://hooks.slack.com/services/SAMPLE/TEST/TEST"
PUSHGATEWAY_ADDR="http://localhost:9091/metrics/job/mail_checker/instance/mail"
MAIL_ADDR="test@example.com"


# Check if running by root
if [ "$EUID" -ne 0 ]
  then echo "Please run the script as root :)"
  exit
fi

check_disk_usage() {
  # Check all mount points and do a pushgateway job
  # Do a for loop for each and check if it's above 95
  for mount_path in $(df -H | grep -vE '^Filesystem|tmpfs|cdrom|overlay' | awk '{ print $5 }' | cut -d '%' -f1);
  do
      # Let's first push metrics since we love prometheus :)
      pushgateway_metrics $mount_path
      if [ $mount_path -gt 95 ];
        then
           echo "$(date --iso) Disk is almost full, please check."
       alert_slack "Check mail server disk - currently $mount_path%"
       alert_email "Check mail server disk - currently $mount_path%"
    fi
  done
}

# Check services status
check_smtp_server() {
      POSTFIX_STATUS="$(systemctl is-active postfix.service)"
    if [ "${POSTFIX_STATUS}" != "active" ]; then
        echo "$(date --iso) Postfix is not running!"
        alert_slack "Postfix is not running!"
        alert_email "Postfix is not running!"
    fi
      DOVECOT_STATUS="$(systemctl is-active dovecot.service)"
    if [ "${DOVECOT_STATUS}" != "active" ]; then
        echo "$(date --iso) Dovecot is not running!"
        alert_slack "Dovecot is not running!"
        alert_email "Dovecot is not running!"
    fi
}

# Send metrics to prometheus pushgateway
pushgateway_metrics() {
    cat <<EOF | curl --data-binary @- $PUSHGATEWAY_ADDR
# TYPE disk_size gauge
# HELP disk_size Size of mount points
disk_size $1
EOF
}

# Send metrics to Slack
alert_slack() {
   echo curl -X POST -H 'Content-type: application/json' --data '{"text":"'$1'"}' $SLACK_ADDR
}

# Send email if sth is broken
alert_email() {
    echo "$1" | sendmail $MAIL_ADDR
}

# Run the functions
check_disk_usage
check_smtp_server
