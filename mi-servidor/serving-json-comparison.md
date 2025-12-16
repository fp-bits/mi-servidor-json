# Serving JSON from Different Platforms

## 1. GitHub (Simplest: GitHub Pages)

**Setup:**
```bash
# In your repo, create a gh-pages branch
git checkout --orphan gh-pages
mkdir data
echo '{"message":"Hello from GitHub","timestamp":"2025-12-16"}' > data/api.json
git add data/api.json
git commit -m "Add JSON data"
git push origin gh-pages
```

**Access:**
```
https://username.github.io/repo-name/data/api.json
```

**Pros:** Zero config, free, CDN-backed, HTTPS automatic  
**Cons:** Static only, manual updates needed, 1GB size limit

---

## 2. Render (Free Tier - Static Site)

**Setup:**
```bash
# Create simple structure
mkdir public
echo '{"status":"ok","data":"From Render"}' > public/data.json

# render.yaml
cat > render.yaml << 'EOF'
services:
  - type: web
    name: json-api
    env: static
    buildCommand: ""
    staticPublishPath: ./public
EOF

git init && git add . && git commit -m "init"
# Connect to Render via dashboard
```

**Access:**
```
https://json-api.onrender.com/data.json
```

**Pros:** Also static, free SSL, auto-deploy from git  
**Cons:** 100GB bandwidth/month limit, cold starts if inactive

---

## 3. Render (Free Tier - Dynamic with Python)

```python
# main.py - KISS approach
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        data = {"endpoint": self.path, "method": "GET"}
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

if __name__ == '__main__':
    HTTPServer(('0.0.0.0', 10000), Handler).serve_forever()
```

**Pros:** Dynamic generation, full control  
**Cons:** Sleeps after 15min inactive (15-30s wake time)

---

## 4. VPS (Debian/Nginx)

```bash
# Install
apt install nginx

# Create data directory
mkdir -p /var/www/api/data
echo '{"server":"vps","status":"running"}' > /var/www/api/data/info.json

# /etc/nginx/sites-available/api
cat > /etc/nginx/sites-available/api << 'EOF'
server {
    listen 80;
    server_name api.yourdomain.com;
    root /var/www/api;
    
    location /data/ {
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
    }
}
EOF

ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

---

## Comparison Table

| Platform | Setup Time | Cost | Latency | Control | Best For |
|----------|-----------|------|---------|---------|----------|
| **GitHub Pages** | 2 min | Free | Low (CDN) | None | Static datasets, docs |
| **Render Static** | 5 min | Free | Medium | Low | Simple APIs, prototypes |
| **Render Dynamic** | 10 min | Free* | High† | Medium | Learning, demos |
| **VPS** | 30 min | €5+/mo | Very Low | Full | Production, real services |

*Free tier sleeps after inactivity  
†Cold start delays

---

## Recommendation for Teaching

**Start:** GitHub Pages (students already know Git)  
**Progress:** Render static → dynamic (understand deployment)  
**Production:** VPS (real sysadmin skills)

This progression teaches: version control → CI/CD → server administration.
