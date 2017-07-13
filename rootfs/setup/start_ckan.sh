#!/bin/bash
python prerun.py
if [ $? -eq 0 ]
then
  if [ "$PASSWORD_PROTECT" = true ]
  then
    if [ "$HTPASSWD_USER" ] || [ "$HTPASSWD_PASSWORD" ]
    then
      cp -a /srv/app/nginx-wauth.conf /etc/nginx/nginx.conf
      htpasswd -b -c /srv/app/.htpasswd $HTPASSWD_USER $HTPASSWD_PASSWORD
      nginx
      gunicorn --log-file=- -k gevent -w 4 -b 127.0.0.1:4000 --paste production.ini
    else
      echo "Missing HTPASSWD_USER or HTPASSWD_PASSWORD environment variables. Exiting..."
      exit 1
    fi
  else
    cp -a /srv/app/nginx.conf /etc/nginx/nginx.conf
    nginx
    gunicorn --log-file=- -k gevent -w 4 -b 127.0.0.1:4000 --paste production.ini
  fi
else
  echo "[prerun] failed...not starting CKAN."
fi
