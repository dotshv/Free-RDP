# Remote Desktop Server

Real RDP server for Railway with TCP proxy support.

## Deploy on Railway

1. Push to GitHub
2. Railway → New Project → Deploy from GitHub
3. After deploy → **Settings → Networking → Enable TCP Proxy** on port `3389`
4. Copy the TCP proxy hostname (e.g. `monorail.proxy.rlwy.net:12345`)

## Connect via RDP

1. `Win+R` → `mstsc` → Enter
2. Computer: `your-tcp-proxy-hostname:port`
3. Username: `user`
4. Password: `rdp@12345`
5. Accept certificate → Connected

## Connect via Browser

Open Railway service URL in browser → Click "Launch Desktop"

## Environment Variables (Optional)

| Variable | Default | Description |
|----------|---------|-------------|
| USERNAME | user | RDP login username |
| PASSWORD | rdp@12345 | RDP login password |
| RESOLUTION | 1920x1080 | Screen resolution |
| RDP_PORT | 3389 | xRDP port (TCP proxy maps to this) |

## Run Locally

```bash
docker build -t rdp .
docker run -d -p 6080:6080 -p 3389:3389 --name rdp rdp
```

RDP: `localhost:3389` | Browser: `http://localhost:6080`
