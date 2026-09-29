FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

ENV USERNAME=user \
    PASSWORD=rdp@123456 \
    RDP_PORT=3389

RUN apt-get update && apt-get install -y \
    xfce4 xfce4-session xfce4-terminal xfce4-goodies \
    xrdp \
    dbus-x11 x11-xserver-utils \
    policykit-1 \
    wget curl git nano vim htop neofetch unzip \
    fonts-noto fonts-noto-color-emoji fonts-liberation \
    firefox thunar mousepad \
    net-tools locales sudo \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN adduser xrdp ssl-cert

RUN mv /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak

RUN cat > /etc/xrdp/startwm.sh << 'STARTWM'
#!/bin/sh
if [ -r /etc/default/locale ]; then
    . /etc/default/locale
    export LANG LANGUAGE
fi
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
exec startxfce4
STARTWM

RUN chmod +x /etc/xrdp/startwm.sh

RUN cat > /opt/start.sh << 'SCRIPT'
#!/bin/bash

USERNAME=${USERNAME:-user}
PASSWORD=${PASSWORD:-rdp@12345}
RDP_PORT=${RDP_PORT:-3389}

if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USERNAME"
    usermod -aG sudo "$USERNAME"
fi
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

mkdir -p /home/$USERNAME/Desktop /home/$USERNAME/Downloads
chown -R $USERNAME:$USERNAME /home/$USERNAME/

sed -i "s/^port=.*/port=$RDP_PORT/" /etc/xrdp/xrdp.ini
sed -i 's/^crypt_level=.*/crypt_level=low/' /etc/xrdp/xrdp.ini
sed -i 's/^max_bpp=.*/max_bpp=24/' /etc/xrdp/xrdp.ini

mkdir -p /var/run/dbus /var/run/xrdp
rm -f /var/run/dbus/pid /var/run/xrdp/*.pid 2>/dev/null

dbus-daemon --system --fork 2>/dev/null || true

echo ""
echo "=========================================="
echo "  RDP Server Starting"
echo "  Port: $RDP_PORT"
echo "  User: $USERNAME"
echo "  Pass: $PASSWORD"
echo "=========================================="
echo ""

/usr/sbin/xrdp-sesman
exec /usr/sbin/xrdp --nodaemon
SCRIPT

RUN chmod +x /opt/start.sh

EXPOSE 3389

CMD ["/opt/start.sh"]
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

ENV USERNAME=user \
    PASSWORD=rdp@12345 \
    RDP_PORT=3389

RUN apt-get update && apt-get install -y \
    xfce4 xfce4-session xfce4-terminal xfce4-goodies \
    xrdp \
    dbus-x11 x11-xserver-utils \
    policykit-1 \
    wget curl git nano vim htop neofetch unzip \
    fonts-noto fonts-noto-color-emoji fonts-liberation \
    firefox thunar mousepad \
    net-tools locales sudo \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN adduser xrdp ssl-cert

RUN mv /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak

RUN cat > /etc/xrdp/startwm.sh << 'STARTWM'
#!/bin/sh
if [ -r /etc/default/locale ]; then
    . /etc/default/locale
    export LANG LANGUAGE
fi
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
exec startxfce4
STARTWM

RUN chmod +x /etc/xrdp/startwm.sh

RUN cat > /opt/start.sh << 'SCRIPT'
#!/bin/bash

USERNAME=${USERNAME:-user}
PASSWORD=${PASSWORD:-rdp@12345}
RDP_PORT=${RDP_PORT:-3389}

if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USERNAME"
    usermod -aG sudo "$USERNAME"
fi
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

mkdir -p /home/$USERNAME/Desktop /home/$USERNAME/Downloads
chown -R $USERNAME:$USERNAME /home/$USERNAME/

sed -i "s/^port=.*/port=$RDP_PORT/" /etc/xrdp/xrdp.ini
sed -i 's/^crypt_level=.*/crypt_level=low/' /etc/xrdp/xrdp.ini
sed -i 's/^max_bpp=.*/max_bpp=24/' /etc/xrdp/xrdp.ini

mkdir -p /var/run/dbus /var/run/xrdp
rm -f /var/run/dbus/pid /var/run/xrdp/*.pid 2>/dev/null

dbus-daemon --system --fork 2>/dev/null || true

echo ""
echo "=========================================="
echo "  RDP Server Starting"
echo "  Port: $RDP_PORT"
echo "  User: $USERNAME"
echo "  Pass: $PASSWORD"
echo "=========================================="
echo ""

/usr/sbin/xrdp-sesman
exec /usr/sbin/xrdp --nodaemon
SCRIPT

RUN chmod +x /opt/start.sh

EXPOSE 3389

CMD ["/opt/start.sh"]
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

ENV USERNAME=user \
    PASSWORD=rdp@12345 \
    RDP_PORT=3389

RUN apt-get update && apt-get install -y \
    xfce4 xfce4-session xfce4-terminal xfce4-goodies \
    xrdp \
    dbus-x11 x11-xserver-utils \
    policykit-1 \
    wget curl git nano vim htop neofetch unzip \
    fonts-noto fonts-noto-color-emoji fonts-liberation \
    firefox thunar mousepad \
    net-tools locales sudo \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN adduser xrdp ssl-cert

RUN mv /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak

RUN cat > /etc/xrdp/startwm.sh << 'STARTWM'
#!/bin/sh
if [ -r /etc/default/locale ]; then
    . /etc/default/locale
    export LANG LANGUAGE
fi
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
exec startxfce4
STARTWM

RUN chmod +x /etc/xrdp/startwm.sh

RUN cat > /opt/start.sh << 'SCRIPT'
#!/bin/bash

USERNAME=${USERNAME:-user}
PASSWORD=${PASSWORD:-rdp@12345}
RDP_PORT=${RDP_PORT:-3389}

if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USERNAME"
    usermod -aG sudo "$USERNAME"
fi
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

mkdir -p /home/$USERNAME/Desktop /home/$USERNAME/Downloads
chown -R $USERNAME:$USERNAME /home/$USERNAME/

sed -i "s/^port=.*/port=$RDP_PORT/" /etc/xrdp/xrdp.ini
sed -i 's/^crypt_level=.*/crypt_level=low/' /etc/xrdp/xrdp.ini
sed -i 's/^max_bpp=.*/max_bpp=24/' /etc/xrdp/xrdp.ini

mkdir -p /var/run/dbus /var/run/xrdp
rm -f /var/run/dbus/pid /var/run/xrdp/*.pid 2>/dev/null

dbus-daemon --system --fork 2>/dev/null || true

echo ""
echo "=========================================="
echo "  RDP Server Starting"
echo "  Port: $RDP_PORT"
echo "  User: $USERNAME"
echo "  Pass: $PASSWORD"
echo "=========================================="
echo ""

/usr/sbin/xrdp-sesman
exec /usr/sbin/xrdp --nodaemon
SCRIPT

RUN chmod +x /opt/start.sh

EXPOSE 3389

CMD ["/opt/start.sh"]
