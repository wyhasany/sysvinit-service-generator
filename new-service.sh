#!/bin/bash

SERVICE_FILE=$(tempfile)

echo "--- Download template ---"
wget -q -O "$SERVICE_FILE" 'https://raw.githubusercontent.com/jasonblewis/sample-service-script/master/service.sh' || { echo 'ERROR: Could not retreive service.sh from github'; exit 1;}

chmod +x "$SERVICE_FILE"
echo ""

echo "--- Customize ---"
echo "I'll now ask you some information to customize script"
echo "Press Ctrl+C anytime to abort."
echo "Empty values are not accepted."
echo ""

prompt_token() {
  local VAL=""
  while [ "$VAL" = "" ]; do
    echo -n "${2:-$1} : "
    read VAL
    if [ "$VAL" = "" ]; then
      echo "Please provide a value"
    fi
  done
  VAL=$(printf '%q' "$VAL")
  eval $1=$VAL
  local rstr=$(printf '%q' "$VAL")
  rstr=$(echo $rstr | sed -e 's/[\/&]/\\&/g') # escape search string for sed http://stackoverflow.com/questions/407523/escape-a-string-for-a-sed-replace-pattern
  sed -i "s/<$1>/$rstr/g" $SERVICE_FILE
}

prompt_token 'SERVICE_NAME'        'Service name'
if [ -f "/etc/init.d/$NAME" ]; then
  echo "Error: service '$NAME' already exists"
  exit 1
fi

prompt_token 'DESCRIPTION' ' Description'
prompt_token 'COMMAND'     '     Command'
prompt_token 'USERNAME'    '        User'
if ! id -u "$USERNAME" &> /dev/null; then
  echo "Error: user '$USERNAME' not found"
  exit 1
fi

echo ""

echo "--- Installation ---"
if [ ! -w /etc/init.d ]; then
  echo "You don't gave me enough permissions to install service myself."
  echo "That's smart, always be really cautious with third-party shell scripts!"
  echo "You should now type those commands as superuser to install and run your service:"
  echo ""
  echo "   mv \"$SERVICE_FILE\" \"/etc/init.d/$NAME\""
  echo "   touch \"/var/log/$NAME.log\" && chown \"$USERNAME\" \"/var/log/$NAME.log\""
  echo "   update-rc.d \"$NAME\" defaults"
  echo "   service \"$NAME\" start"
else
  echo "1. mv \"$SERVICE_FILE\" \"/etc/init.d/$NAME\""
  mv -v "$SERVICE_FILE" "/etc/init.d/$NAME"
  echo "2. touch \"/var/log/$NAME.log\" && chown \"$USERNAME\" \"/var/log/$NAME.log\""
  touch "/var/log/$NAME.log" && chown "$USERNAME" "/var/log/$NAME.log"
  echo "3. update-rc.d \"$NAME\" defaults"
  update-rc.d "$NAME" defaults
  echo "4. service \"$NAME\" start"
  service "$NAME" start
fi

echo ""
echo "---Uninstall instructions ---"
echo "The service can uninstall itself:"
echo "    service \"$NAME\" uninstall"
echo "It will simply run update-rc.d -f \"$NAME\" remove && rm -f \"/etc/init.d/$NAME\""
echo ""
echo "--- Terminated ---"
