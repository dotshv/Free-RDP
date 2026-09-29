FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    xfce4 xfce4-session xfce4-terminal xfce4-goodies xfce4-whiskermenu-plugin \
    tigervnc-standalone-server \
    xrdp \
    dbus-x11 \
    sudo locales net-tools curl wget git nano vim htop unzip \
    fonts-noto fonts-liberation \
    thunar mousepad \
    gtk2-engines-murrine gtk2-engines-pixbuf \
    && locale-gen en_US.UTF-8 \
    && apt-get remove -y light-locker xscreensaver 2>/dev/null || true \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -G sudo,ssl-cert user \
    && echo "user:rdp@12345" | chpasswd \
    && echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user \
    && chmod 440 /etc/sudoers.d/user \
    && adduser xrdp ssl-cert 2>/dev/null || true

RUN git clone --depth 1 https://github.com/B00merang-Project/Windows-10.git /usr/share/themes/Windows-10 \
    && git clone --depth 1 https://github.com/B00merang-Project/Windows-10-Icons.git /usr/share/icons/Windows-10 \
    && rm -rf /usr/share/themes/Windows-10/.git /usr/share/icons/Windows-10/.git

RUN mkdir -p /home/user/.config/xfce4/xfconf/xfce-perchannel-xml

RUN cat > /home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'XEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Windows-10"/>
    <property name="IconThemeName" type="string" value="Windows-10"/>
    <property name="CursorThemeName" type="string" value="default"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Noto Sans 10"/>
    <property name="CursorThemeSize" type="int" value="16"/>
  </property>
  <property name="Xft" type="empty">
    <property name="Antialias" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintslight"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
</channel>
XEOF

RUN cat > /home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml << 'XEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="Windows-10"/>
    <property name="title_font" type="string" value="Noto Sans Bold 9"/>
    <property name="button_layout" type="string" value="O|HMC"/>
  </property>
</channel>
XEOF

RUN cat > /home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml << 'XEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=8;x=960;y=1064"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="40"/>
      <property name="background-style" type="uint" value="1"/>
      <property name="background-color" type="array">
        <value type="uint" value="13878"/>
        <value type="uint" value="16962"/>
        <value type="uint" value="20046"/>
        <value type="uint" value="65535"/>
      </property>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="7"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu"/>
    <property name="plugin-2" type="string" value="separator">
      <property name="expand" type="bool" value="false"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-3" type="string" value="tasklist">
      <property name="flat-buttons" type="bool" value="true"/>
      <property name="show-labels" type="bool" value="true"/>
      <property name="grouping" type="uint" value="1"/>
    </property>
    <property name="plugin-4" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-5" type="string" value="systray">
      <property name="square-icons" type="bool" value="true"/>
    </property>
    <property name="plugin-6" type="string" value="clock">
      <property name="digital-format" type="string" value="%I:%M %p"/>
      <property name="digital-date-format" type="string" value="%m/%d/%Y"/>
      <property name="digital-date-font" type="string" value="Noto Sans 8"/>
    </property>
    <property name="plugin-7" type="string" value="showdesktop"/>
  </property>
</channel>
XEOF

RUN cat > /home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << 'XEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitorscreen" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="rgba1" type="array">
            <value type="uint" value="10537"/>
            <value type="uint" value="27756"/>
            <value type="uint" value="48573"/>
            <value type="uint" value="65535"/>
          </property>
          <property name="image-style" type="int" value="0"/>
        </property>
      </property>
    </property>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="style" type="int" value="2"/>
    <property name="file-icons" type="empty">
      <property name="show-home" type="bool" value="true"/>
      <property name="show-filesystem" type="bool" value="true"/>
      <property name="show-trash" type="bool" value="true"/>
    </property>
  </property>
</channel>
XEOF

RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm -f google-chrome-stable_current_amd64.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/user/.config \
    && printf '[Default Applications]\nx-scheme-handler/http=google-chrome.desktop\nx-scheme-handler/https=google-chrome.desktop\ntext/html=google-chrome.desktop\napplication/xhtml+xml=google-chrome.desktop\n' > /home/user/.config/mimeapps.list \
    && update-alternatives --set x-www-browser /usr/bin/google-chrome-stable 2>/dev/null || true

RUN mkdir -p /home/user/Desktop \
    && printf '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Google Chrome\nExec=google-chrome-stable --no-sandbox --disable-gpu\nIcon=google-chrome\nStartupNotify=true\n' > /home/user/Desktop/chrome.desktop \
    && printf '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Terminal\nExec=xfce4-terminal\nIcon=utilities-terminal\nStartupNotify=true\n' > /home/user/Desktop/terminal.desktop \
    && printf '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Files\nExec=thunar\nIcon=system-file-manager\nStartupNotify=true\n' > /home/user/Desktop/files.desktop \
    && chmod +x /home/user/Desktop/*.desktop

RUN chown -R user:user /home/user

RUN sed -i 's/^max_bpp=.*/max_bpp=16/' /etc/xrdp/xrdp.ini \
    && sed -i 's/^crypt_level=.*/crypt_level=none/' /etc/xrdp/xrdp.ini \
    && sed -i 's/^#tcp_nodelay=.*/tcp_nodelay=true/' /etc/xrdp/xrdp.ini \
    && sed -i 's/^tcp_nodelay=.*/tcp_nodelay=true/' /etc/xrdp/xrdp.ini

RUN printf '#!/bin/bash\nunset DBUS_SESSION_BUS_ADDRESS\nunset XDG_RUNTIME_DIR\nexec startxfce4\n' > /etc/xrdp/startwm.sh \
    && chmod 755 /etc/xrdp/startwm.sh

RUN printf '#!/bin/bash\nrm -rf /var/run/xrdp/* /var/run/dbus/pid /tmp/.X*\nmkdir -p /var/run/dbus /var/run/xrdp /tmp/.X11-unix\nchmod 1777 /tmp/.X11-unix\ndbus-daemon --system --fork\nxrdp-keygen xrdp auto 2>/dev/null\n/usr/sbin/xrdp-sesman --nodaemon &\nsleep 2\nexec /usr/sbin/xrdp --nodaemon\n' > /opt/start.sh \
    && chmod +x /opt/start.sh

EXPOSE 3389

CMD ["/opt/start.sh"]
