FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
ENV USERNAME=user PASSWORD=rdp@12345 RDP_PORT=3389

RUN apt-get update && apt-get install -y \
    xfce4 xfce4-session xfce4-terminal xfce4-goodies \
    tigervnc-standalone-server \
    xrdp \
    dbus-x11 policykit-1 \
    sudo locales net-tools curl wget git nano vim htop \
    fonts-noto fonts-noto-color-emoji fonts-liberation \
    firefox thunar mousepad \
    && locale-gen en_US.UTF-8 \
    && adduser xrdp ssl-cert 2>/dev/null || true \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN cat > /etc/xrdp/startwm.sh << 'EOF'
#!/bin/bash
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
if [ -r /etc/default/locale ]; then
    . /etc/default/locale
    export LANG LANGUAGE
fi
exec dbus-run-session -- startxfce4
EOF

RUN chmod +x /etc/xrdp/startwm.sh

RUN cat > /opt/start.sh << 'EOF'
#!/bin/bash
if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USERNAME"
    usermod -aG sudo "$USERNAME"
fi
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
chmod 440 /etc/sudoers.d/$USERNAME
mkdir -p /home/$USERNAME/Desktop /home/$USERNAME/Downloads
chown -R $USERNAME:$USERNAME /home/$USERNAME
sed -i "s/^port=.*/port=$RDP_PORT/" /etc/xrdp/xrdp.ini
sed -i "s/^max_bpp=.*/max_bpp=24/" /etc/xrdp/xrdp.ini
mkdir -p /var/run/dbus /var/run/xrdp
rm -f /var/run/dbus/pid /var/run/xrdp/*.pid
dbus-daemon --system --fork
echo "RDP Ready sir| Port: $RDP_PORT | User: $USERNAME | Pass: $PASSWORD"
/usr/sbin/xrdp-sesman
exec /usr/sbin/xrdp --nodaemon
EOF

RUN chmod +x /opt/start.sh

EXPOSE 3389

CMD ["/opt/start.sh"]
