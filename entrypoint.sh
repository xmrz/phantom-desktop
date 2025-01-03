#!/usr/bin/env bash

sudo mkdir -p "/home/${USERNAME}/.vnc"
sudo chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}"
touch "/home/${USERNAME}/.Xauthority"
if test -n "${PASSWORD}"; then
    echo "${PASSWORD}" | vncpasswd -f > "/home/${USERNAME}/.vnc/passwd"
    chmod 0600 "/home/${USERNAME}/.vnc/passwd"
fi;

cd "/home/${USERNAME}"
if test ! -f "/home/${USERNAME}/.entrypoint_lock"; then
    touch "/home/${USERNAME}/.entrypoint_lock"
    tar xvf /default_home.tar.gz
fi;
nohup python /server.py 1>http_server.log 2>&1 &
cd -
if test -n "${PASSWORD}"; then
    vncserver -geometry 1200x800 -localhost no -rfbport 5900 -xstartup /usr/bin/mate-session
else
    vncserver -SecurityTypes None --I-KNOW-THIS-IS-INSECURE -geometry 1200x800 -localhost no -rfbport 5900 -xstartup /usr/bin/mate-session
fi;

cd /novnc
CERT="$TLS_CERTIFICATE_CHAIN"
KEY="$TLS_CERTIFICATE_PRIVATE_KEY"
if test -n "$CERT" && test -n "$KEY"; then
    CERT="--cert $CERT"
    KEY="--key $KEY"
fi;
./utils/novnc_proxy --listen 7000 $CERT $KEY --vnc localhost:5900

