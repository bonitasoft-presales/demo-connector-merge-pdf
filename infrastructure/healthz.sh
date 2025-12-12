#! /bin/bash

interval=5;
code=200;
url="http://localhost:8085/bonita/healthz"
username="monitoring"
password="mon1tor1ng_adm1n"

function poll_status {
  while true;
  do
    auth=""
    if [[ "$username" != "" ]]; then
      auth="-u $username:$password"
    fi;
#    echo "interval set to [$interval]";
    STATUS_CODE=`curl -A "Web Check" -sL --connect-timeout 3 -w "%{http_code}\n" $auth $url -o /dev/null`
    echo "$(date +%H:%M:%S): The status code is $STATUS_CODE";
    if [[ "$STATUS_CODE" == "${code}" ]]; then
          echo "success";
          exit 0;
        break;
    fi;
    sleep $interval;
  done
}

echo "Polling '${url%\?*}' every $interval seconds, until status is '$code'"
poll_status
