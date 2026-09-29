FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    xfce4 xfce4-session xfce4-terminal xfce4-goodies \
    tigervnc-standalone-server \
    xrdp \
    dbus-x11 \
    sudo locales net-tools curl wget git nano vim htop \
    fonts-noto fonts-liberation \
    firefox thunar mousepad \
    && locale-gen en_US.UTF-8 \
    && apt-get remove -y light-locker xscreensaver 2>/dev/null || true \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -G sudo,ssl-cert user \
    && echo "user:rdp@12345" | chpasswd \
    && echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user \
    && chmod 440 /etc/sudoers.d/user

RUN adduser xrdp ssl-cert 2>/dev/null || true

RUN echo "startxfce4" > /home/user/.xsession \
    && chmod +x /home/user/.xsession \
    && chown user:user /home/user/.xsession \
    && mkdir -p /home/user/Desktop /home/user/Downloads \
    && chown -R user:user /home/user

RUN printf '#!/bin/bash\nunset DBUS_SESSION_BUS_ADDRESS\nunset XDG_RUNTIME_DIR\nexec startxfce4\n' > /etc/xrdp/startwm.sh \
    && chmod 755 /etc/xrdp/startwm.sh

RUN sed -i 's/^max_bpp=.*/max_bpp=24/' /etc/xrdp/xrdp.ini \
    && sed -i 's/^crypt_level=.*/crypt_level=low/' /etc/xrdp/xrdp.ini

RUN printf '#!/bin/bash\nrm -rf /var/run/xrdp/* /var/run/dbus/pid /tmp/.X*\nmkdir -p /var/run/dbus /var/run/xrdp /tmp/.X11-unix\nchmod 1777 /tmp/.X11-unix\ndbus-daemon --system --fork\nxrdp-keygen xrdp auto 2>/dev/null\n/usr/sbin/xrdp-sesman --nodaemon &\nsleep 2\nexec /usr/sbin/xrdp --nodaemon\n' > /opt/start.sh \
    && chmod +x /opt/start.sh

EXPOSE 3389

CMD ["/opt/start.sh"]
