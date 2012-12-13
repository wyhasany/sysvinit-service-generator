#!/bin/bash

SERVICE_FILE=$(tempfile)

echo "--- Download template ---"
wget -q -O "$SERVICE_FILE" 'https://raw.github.com/gist/4275302/service.sh'
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
  sed -i "s/<$1>/$(printf '%q' "$VAL")/g" $SERVICE_FILE
}

prompt_token 'NAME'        'Service name'
prompt_token 'DESCRIPTION' ' Description'
prompt_token 'COMMAND'     '     Command'
prompt_token 'USER'        '        User'
echo ""

echo "--- Installation ---"
if [ ! -w /etc/init.d ]; then
  echo "You don't gave me enough permissions to install service myself."
  echo "That's smart, always be really cautious with third-party shell scripts!"
  echo "You should now type those commands as superuser to install and run your service:"
  echo ""
  echo "   mv \"$SERVICE_FILE\" \"/etc/init.d/$NAME\""
  echo "   update-rc.d \"$NAME\" defaults"
  echo "   service \"$NAME\" start"
else
  echo "1. mv \"$SERVICE_FILE\" \"/etc/init.d/$NAME\""
  mv -v "$SERVICE_FILE" "/etc/init.d/$NAME"
  echo "2. update-rc.d \"$NAME\" defaults"
  update-rc.d "$NAME" defaults
  echo "3. service \"$NAME\" start"
  service "$NAME" start
fi

echo ""
echo "---Uninstall instructions ---"
echo "The service can uninstall itself:"
echo "    service \"$NAME\" uninstall"
echo "It will simply run update-rc.d -f \"$NAME\" remove && rm -f \"/etc/init.d/$NAME\""
echo ""
echo "--- Terminated ---"
