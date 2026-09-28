FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

ENV USERNAME=user \
    PASSWORD=rdp@12345 \
    RESOLUTION=1920x1080 \
    PORT=6080 \
    RDP_PORT=3389

RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 xfce4-terminal xfce4-goodies xfce4-whiskermenu-plugin \
    tigervnc-standalone-server tigervnc-common \
    xrdp xorgxrdp \
    python3 python3-pip python3-numpy \
    wget curl git nano vim htop neofetch unzip \
    dbus-x11 x11-utils xdg-utils \
    fonts-noto fonts-noto-color-emoji fonts-liberation fonts-dejavu-core \
    firefox thunar mousepad \
    net-tools iputils-ping locales sudo \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC \
    && git clone --depth 1 https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify \
    && cd /opt/noVNC/utils/websockify && pip3 install . \
    && chmod -R 755 /opt/noVNC

RUN sed -i 's/^crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini \
    && sed -i '/^\[Xvnc\]/,/^\[/ s/^param=.SecurityTypes$/param=-SecurityTypes\nparam=None/' /etc/xrdp/sesman.ini 2>/dev/null || true \
    && echo "xfce4-session" > /root/.xsession \
    && chmod +x /root/.xsession \
    && mkdir -p /root/.vnc /root/Desktop /root/Downloads /var/run/dbus

RUN printf '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Terminal\nExec=xfce4-terminal\nIcon=utilities-terminal\nStartupNotify=true' > /root/Desktop/terminal.desktop \
    && printf '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Files\nExec=thunar\nIcon=system-file-manager\nStartupNotify=true' > /root/Desktop/files.desktop \
    && printf '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Firefox\nExec=firefox\nIcon=firefox\nStartupNotify=true' > /root/Desktop/firefox.desktop \
    && chmod +x /root/Desktop/*.desktop

RUN cat > /opt/start.sh << 'STARTSCRIPT'
#!/bin/bash
set -e

NOVNC_PORT=${PORT:-6080}
XRDP_PORT=${RDP_PORT:-3389}

if [ "$USERNAME" != "root" ]; then
    if ! id "$USERNAME" &>/dev/null; then
        useradd -m -s /bin/bash -G sudo "$USERNAME"
    fi
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "xfce4-session" > /home/$USERNAME/.xsession
    chmod +x /home/$USERNAME/.xsession
    chown $USERNAME:$USERNAME /home/$USERNAME/.xsession
    mkdir -p /home/$USERNAME/Desktop /home/$USERNAME/Downloads
    cp /root/Desktop/*.desktop /home/$USERNAME/Desktop/ 2>/dev/null || true
    chown -R $USERNAME:$USERNAME /home/$USERNAME/
fi
echo "root:$PASSWORD" | chpasswd

sed -i "s/^port=.*/port=$XRDP_PORT/" /etc/xrdp/xrdp.ini

mkdir -p /var/run/dbus
dbus-daemon --system --fork 2>/dev/null || true

rm -f /var/run/xrdp/xrdp.pid /var/run/xrdp/xrdp-sesman.pid 2>/dev/null || true
mkdir -p /var/run/xrdp
xrdp-keygen xrdp auto 2>/dev/null || true
/usr/sbin/xrdp-sesman --nodaemon &
sleep 1
/usr/sbin/xrdp --nodaemon &
sleep 2

if netstat -tlnp | grep -q ":$XRDP_PORT"; then
    echo "[OK] xRDP running on port $XRDP_PORT"
else
    echo "[RETRY] Restarting xRDP..."
    /usr/sbin/xrdp --nodaemon &
    sleep 2
fi

mkdir -p ~/.vnc
echo "$PASSWORD" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
cat > ~/.vnc/xstartup << 'XS'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
eval $(dbus-launch --sh-syntax) 2>/dev/null
exec startxfce4
XS
chmod +x ~/.vnc/xstartup
cat > ~/.vnc/config << VCONF
geometry=$RESOLUTION
depth=24
localhost=yes
SecurityTypes=VncAuth
AlwaysShared=yes
VCONF

vncserver -kill :1 2>/dev/null || true
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true
vncserver :1
sleep 2

echo ""
echo "=========================================="
echo "  RDP Server Ready"
echo ""
echo "  xRDP:  port $XRDP_PORT (use TCP proxy hostname)"
echo "  Web:   port $NOVNC_PORT"
echo "  User:  $USERNAME"
echo "  Pass:  $PASSWORD"
echo "=========================================="
echo ""

exec /opt/noVNC/utils/novnc_proxy \
    --vnc localhost:5901 \
    --listen $NOVNC_PORT \
    --web /opt/noVNC \
    --heartbeat 30
STARTSCRIPT
chmod +x /opt/start.sh

RUN cat > /opt/noVNC/index.html << 'HTMLPAGE'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Remote Desktop</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Inter',sans-serif;background:#06060f;color:#e4e4ed;min-height:100vh;overflow-x:hidden}
.bg{position:fixed;inset:0;z-index:0;background:radial-gradient(ellipse 80% 50% at 20% 40%,rgba(99,102,241,.12) 0%,transparent 70%),radial-gradient(ellipse 60% 40% at 80% 20%,rgba(139,92,246,.1) 0%,transparent 60%),radial-gradient(ellipse 50% 50% at 50% 90%,rgba(6,182,212,.08) 0%,transparent 60%)}
.grid{position:fixed;inset:0;z-index:0;background-image:linear-gradient(rgba(255,255,255,.02) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.02) 1px,transparent 1px);background-size:60px 60px}
.orb{position:fixed;border-radius:50%;filter:blur(80px);opacity:.4;animation:fl 20s ease-in-out infinite;z-index:0}
.o1{width:400px;height:400px;background:linear-gradient(135deg,#6366f1,#8b5cf6);top:-100px;right:-100px}
.o2{width:300px;height:300px;background:linear-gradient(135deg,#06b6d4,#3b82f6);bottom:-50px;left:-50px;animation-delay:-7s}
@keyframes fl{0%,100%{transform:translate(0,0) scale(1)}25%{transform:translate(30px,-40px) scale(1.05)}50%{transform:translate(-20px,20px) scale(.95)}75%{transform:translate(40px,30px) scale(1.02)}}
.wrap{position:relative;z-index:1;max-width:900px;margin:0 auto;padding:40px 24px}
.hdr{text-align:center;margin-bottom:48px;animation:fu .8s ease-out}
.badge{display:inline-flex;align-items:center;gap:8px;padding:8px 18px;background:rgba(99,102,241,.12);border:1px solid rgba(99,102,241,.25);border-radius:100px;font-size:13px;font-weight:500;color:#a5b4fc;margin-bottom:24px}
.pulse{width:8px;height:8px;background:#22c55e;border-radius:50%;animation:p 2s infinite}
@keyframes p{0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.5)}50%{box-shadow:0 0 0 8px rgba(34,197,94,0)}}
h1{font-size:2.8rem;font-weight:800;letter-spacing:-.03em;background:linear-gradient(135deg,#fff,#a5b4fc,#818cf8);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;margin-bottom:14px}
.sub{font-size:1.05rem;color:#9ca3af;max-width:500px;margin:0 auto;line-height:1.6}
.card{background:rgba(15,15,30,.7);backdrop-filter:blur(20px);border:1px solid rgba(99,102,241,.15);border-radius:20px;padding:32px;margin-bottom:20px;transition:.3s;animation:fu .8s ease-out}
.card:hover{border-color:rgba(99,102,241,.35);box-shadow:0 8px 40px rgba(99,102,241,.08)}
.ch{display:flex;align-items:center;gap:14px;margin-bottom:24px}
.ic{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0}
.ic.r{background:linear-gradient(135deg,rgba(99,102,241,.2),rgba(139,92,246,.2));border:1px solid rgba(99,102,241,.3)}
.ic.w{background:linear-gradient(135deg,rgba(6,182,212,.2),rgba(59,130,246,.2));border:1px solid rgba(6,182,212,.3)}
.ic.g{background:linear-gradient(135deg,rgba(34,197,94,.2),rgba(16,185,129,.2));border:1px solid rgba(34,197,94,.3)}
.ct{font-size:1.15rem;font-weight:700;color:#fff}
.cs2{font-size:.8rem;color:#6b7280;margin-top:2px}
.cg{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:14px;margin-bottom:24px}
.ci{background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.06);border-radius:12px;padding:16px;transition:.2s}
.ci:hover{background:rgba(255,255,255,.05);border-color:rgba(99,102,241,.2)}
.cl{font-size:.7rem;font-weight:600;text-transform:uppercase;letter-spacing:.08em;color:#6b7280;margin-bottom:6px}
.cv{font-size:1rem;font-weight:600;font-family:'Courier New',monospace;color:#e4e4ed;display:flex;align-items:center;gap:8px;word-break:break-all}
.cp{width:28px;height:28px;border-radius:7px;border:1px solid rgba(255,255,255,.1);background:rgba(255,255,255,.05);color:#9ca3af;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:13px;transition:.2s;flex-shrink:0}
.cp:hover{background:rgba(99,102,241,.15);border-color:rgba(99,102,241,.3);color:#a5b4fc}
.cp.ok{background:rgba(34,197,94,.15);border-color:rgba(34,197,94,.3);color:#22c55e}
.btn{display:inline-flex;align-items:center;gap:10px;padding:14px 32px;background:linear-gradient(135deg,#06b6d4,#3b82f6);color:#fff;font-family:'Inter',sans-serif;font-size:1rem;font-weight:600;border:none;border-radius:14px;cursor:pointer;text-decoration:none;transition:.3s;box-shadow:0 4px 20px rgba(6,182,212,.3)}
.btn:hover{transform:translateY(-2px);box-shadow:0 8px 30px rgba(6,182,212,.45)}
.btn2{background:rgba(255,255,255,.08);box-shadow:none;border:1px solid rgba(255,255,255,.12)}
.btn2:hover{box-shadow:0 4px 20px rgba(255,255,255,.08)}
.steps{list-style:none;counter-reset:s}
.steps li{counter-increment:s;display:flex;align-items:flex-start;gap:14px;padding:12px 0;border-bottom:1px solid rgba(255,255,255,.04);font-size:.9rem;line-height:1.5;color:#d1d5db}
.steps li:last-child{border-bottom:none}
.steps li::before{content:counter(s);width:26px;height:26px;border-radius:8px;background:rgba(99,102,241,.12);border:1px solid rgba(99,102,241,.25);color:#a5b4fc;font-size:.75rem;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0;margin-top:1px}
.steps code{background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.08);border-radius:6px;padding:2px 8px;font-family:'Courier New',monospace;font-size:.85em;color:#a5b4fc}
.ft{display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:10px}
.fi{display:flex;align-items:center;gap:10px;padding:10px 14px;background:rgba(255,255,255,.02);border:1px solid rgba(255,255,255,.05);border-radius:10px;font-size:.85rem;color:#9ca3af}
.note{background:rgba(234,179,8,.06);border:1px solid rgba(234,179,8,.15);border-radius:12px;padding:16px 20px;font-size:.88rem;color:#fbbf24;line-height:1.6;margin-top:16px}
.ftr{text-align:center;padding:40px 0 20px;color:#4b5563;font-size:.8rem}
@keyframes fu{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
@media(max-width:768px){h1{font-size:2rem}.card{padding:20px}.cg{grid-template-columns:1fr}.wrap{padding:24px 16px}}
</style>
</head>
<body>
<div class="bg"></div>
<div class="grid"></div>
<div class="orb o1"></div>
<div class="orb o2"></div>
<div class="wrap">
<div class="hdr">
<div class="badge"><span class="pulse"></span>Server Active</div>
<h1>Remote Desktop</h1>
<p class="sub">Real RDP server — connect via mstsc.exe using TCP proxy hostname</p>
</div>

<div class="card">
<div class="ch">
<div class="ic r">🔗</div>
<div><div class="ct">RDP Connection (mstsc.exe)</div><div class="cs2">Use the TCP proxy hostname from Railway</div></div>
</div>
<div class="cg">
<div class="ci" style="grid-column:1/-1"><div class="cl">TCP Proxy Hostname (from Railway)</div><div class="cv"><span id="h" contenteditable="true" style="outline:none;min-width:200px;padding:4px 8px;background:rgba(255,255,255,.03);border-radius:6px">paste-your-hostname.proxy.rlwy.net:PORT</span><button class="cp" onclick="cc('h')">📋</button></div></div>
<div class="ci"><div class="cl">Username</div><div class="cv"><span id="u">user</span><button class="cp" onclick="cc('u')">📋</button></div></div>
<div class="ci"><div class="cl">Password</div><div class="cv"><span id="pw">rdp@12345</span><button class="cp" onclick="cc('pw')">📋</button></div></div>
</div>
<ol class="steps">
<li>Railway dashboard → your service → Settings → Networking → Enable <strong>TCP Proxy</strong> on port <code>3389</code></li>
<li>Copy the TCP proxy hostname (e.g. <code>monorail.proxy.rlwy.net:12345</code>)</li>
<li>Open <code>Win+R</code> → type <code>mstsc</code> → press Enter</li>
<li>Paste the hostname in <strong>Computer</strong> field → click <strong>Connect</strong></li>
<li>Enter username &amp; password → Accept certificate → Done ✅</li>
</ol>
<div class="note">⚠️ Railway TCP Proxy se hostname milega jaise <strong>monorail.proxy.rlwy.net:12345</strong> — wahi paste karo mstsc me</div>
</div>

<div class="card">
<div class="ch">
<div class="ic w">🌐</div>
<div><div class="ct">Web Access (Browser)</div><div class="cs2">Backup access — no install needed</div></div>
</div>
<div style="display:flex;gap:12px;flex-wrap:wrap">
<a href="/vnc.html?autoconnect=true&resize=scale&quality=9&compression=0" class="btn" target="_blank">🚀 Launch Desktop</a>
<a href="/vnc.html?autoconnect=true&resize=scale&quality=5&compression=6" class="btn btn2" target="_blank">⚡ Low Bandwidth</a>
</div>
</div>

<div class="card">
<div class="ch">
<div class="ic g">⚡</div>
<div><div class="ct">Features</div></div>
</div>
<div class="ft">
<div class="fi">🖥️ Full Desktop (XFCE)</div>
<div class="fi">🔒 Encrypted RDP</div>
<div class="fi">📋 Clipboard Sync</div>
<div class="fi">📁 File Manager</div>
<div class="fi">🌐 Firefox Browser</div>
<div class="fi">⌨️ Terminal</div>
<div class="fi">📐 1920x1080</div>
<div class="fi">🔄 Auto Recovery</div>
</div>
</div>
<div class="ftr">Real RDP Server • xRDP + noVNC</div>
</div>
<script>
function cc(id){var t=document.getElementById(id).textContent;navigator.clipboard.writeText(t).then(function(){var b=document.getElementById(id).nextElementSibling;b.classList.add('ok');b.textContent='✓';setTimeout(function(){b.classList.remove('ok');b.textContent='📋'},1500)}).catch(function(){})}
</script>
</body>
</html>
HTMLPAGE

EXPOSE ${PORT} 3389

CMD ["/opt/start.sh"]
