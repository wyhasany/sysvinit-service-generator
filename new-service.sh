#!/bin/bash

SERVICE_FILE=$(tempfile)

if [ ! -e service.sh ]; then
  echo "--- Download template ---"
  echo "I'll now download the service.sh, because is is not downloaded."
  echo "..."
  wget -q https://raw.githubusercontent.com/wyhasany/sample-service-script/master/service.sh
  if [ "$?" != 0 ]; then
    echo "I could not download the template!"
    echo "You should now download the service.sh file manualy. Run therefore:"
    echo "wget https://raw.githubusercontent.com/wyhasany/sample-service-script/master/service.sh"
    exit 1
  else
    echo "I donloaded the tmplate sucessfully"
    echo ""
  fi
fi


echo "--- Copy template ---"
cp service.sh "$SERVICE_FILE"
chmod +x "$SERVICE_FILE"
echo ""

echo "--- Customize ---"
echo "I'll now ask you some information to customize script"
echo "Press Ctrl+C anytime to abort."
echo "Empty values are not accepted."
echo ""

prompt_token() {
  local VAL=""
  if [ "$3" = "" ]; then
    while [ "$VAL" = "" ]; do
      echo -n "${2:-$1} : "
      read VAL
      if [ "$VAL" = "" ]; then
        echo "Please provide a value"
      fi
    done
  else
    VAL=${@:3:($#-2)}
  fi
  VAL=$(printf '%s' "$VAL")
  eval $1=$VAL
  local rstr=$(printf '%q' "$VAL")
  rstr=$(echo $rstr | sed -e 's/[\/&]/\\&/g') # escape search string for sed http://stackoverflow.com/questions/407523/escape-a-string-for-a-sed-replace-pattern
  sed -i "s/<$1>/$rstr/g" $SERVICE_FILE
}

prompt_token 'NAME'        'Service name' $1
if [ -f "/etc/init.d/$NAME" ]; then
  echo "Error: service '$NAME' already exists"
  exit 1
fi

prompt_token 'DESCRIPTION' ' Description' $2
prompt_token 'COMMAND'     '     Command' $3
prompt_token 'USERNAME'    '        User' $4
if ! id -u "$USERNAME" &> /dev/null; then
  echo "Error: user '$USERNAME' not found"
  exit 1
fi

echo ""

echo "--- Installation ---"
if [ ! -w /etc/init.d ]; then
  echo "You didn't give me enough permissions to install service myself."
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
