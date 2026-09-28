FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:10 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

ENV USERNAME=user \
    PASSWORD=rdp@12345 \
    RESOLUTION=1920x1080 \
    RDP_PORT=3389

RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 xfce4-terminal xfce4-goodies \
    xrdp xorgxrdp \
    dbus-x11 x11-utils xdg-utils \
    wget curl git nano vim htop neofetch unzip \
    fonts-noto fonts-noto-color-emoji fonts-liberation fonts-dejavu-core \
    firefox thunar mousepad \
    net-tools iputils-ping locales sudo \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN printf '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Terminal\nExec=xfce4-terminal\nIcon=utilities-terminal\nStartupNotify=true' > /root/Desktop/terminal.desktop \
    && printf '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Files\nExec=thunar\nIcon=system-file-manager\nStartupNotify=true' > /root/Desktop/files.desktop \
    && printf '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Firefox\nExec=firefox\nIcon=firefox\nStartupNotify=true' > /root/Desktop/firefox.desktop \
    && chmod +x /root/Desktop/*.desktop 2>/dev/null || true

RUN cat > /opt/start.sh << 'SCRIPT'
#!/bin/bash

USERNAME=${USERNAME:-user}
PASSWORD=${PASSWORD:-rdp@12345}
RDP_PORT=${RDP_PORT:-3389}

if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash -G sudo "$USERNAME"
fi
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd

echo "xfce4-session" > /home/$USERNAME/.xsession
chmod +x /home/$USERNAME/.xsession
chown $USERNAME:$USERNAME /home/$USERNAME/.xsession
mkdir -p /home/$USERNAME/Desktop /home/$USERNAME/Downloads
cp /root/Desktop/*.desktop /home/$USERNAME/Desktop/ 2>/dev/null || true
chown -R $USERNAME:$USERNAME /home/$USERNAME/

sed -i "s/^port=.*/port=$RDP_PORT/" /etc/xrdp/xrdp.ini
sed -i 's/^crypt_level=.*/crypt_level=low/' /etc/xrdp/xrdp.ini

mkdir -p /var/run/dbus /var/run/xrdp
rm -f /var/run/xrdp/*.pid /var/run/dbus/pid 2>/dev/null || true

dbus-daemon --system --fork 2>/dev/null || true

xrdp-keygen xrdp auto 2>/dev/null || true

echo ""
echo "=========================================="
echo "  RDP Server Starting"
echo "  Port: $RDP_PORT"
echo "  User: $USERNAME"
echo "  Pass: $PASSWORD"
echo "=========================================="
echo ""

/usr/sbin/xrdp-sesman --nodaemon &
exec /usr/sbin/xrdp --nodaemon
SCRIPT

RUN chmod +x /opt/start.sh

RUN mkdir -p /root/Desktop /var/run/dbus /var/run/xrdp \
    && echo "xfce4-session" > /root/.xsession \
    && chmod +x /root/.xsession

EXPOSE 3389

CMD ["/opt/start.sh"]
