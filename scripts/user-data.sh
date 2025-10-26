#!/bin/bash
set -e

# Log everything
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=================================="
echo "Starting EC2 Flask App Setup"
echo "Time: $(date)"
echo "=================================="

# Update system
echo "[1/8] Updating system packages..."
sudo yum update -y

# Install Python 3 and pip
echo "[2/8] Installing Python 3..."
sudo yum install -y python3 python3-pip

# Install Nginx
echo "[3/8] Installing Nginx..."
sudo yum install -y nginx

# Create application directory
echo "[4/8] Setting up application directory..."
sudo mkdir -p /var/www/flask-app
cd /var/www/flask-app

# Create virtual environment
echo "[5/8] Creating Python virtual environment..."
sudo python3 -m venv venv
sudo chown -R ec2-user:ec2-user /var/www/flask-app

# Create Flask app files
cat > /var/www/flask-app/app.py << 'PYEOF'
from flask import Flask, jsonify, render_template_string
import socket
import os
from datetime import datetime
import psutil

app = Flask(__name__)

HTML_TEMPLATE = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EC2 Flask Server</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 2rem;
        }
        .container { max-width: 900px; margin: 0 auto; }
        header { text-align: center; color: white; margin-bottom: 2rem; }
        header h1 { font-size: 2.5rem; margin-bottom: 0.5rem; }
        .card {
            background: white;
            border-radius: 10px;
            padding: 2rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .card h2 { color: #667eea; margin-bottom: 1rem; }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }
        .info-item {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }
        .info-item label {
            font-weight: bold;
            color: #666;
            font-size: 0.9rem;
            display: block;
            margin-bottom: 0.5rem;
        }
        .info-item span { color: #333; font-size: 1.1rem; }
        .badge {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.9rem;
            margin: 0.5rem 0.5rem 0 0;
        }
        .status {
            display: inline-block;
            width: 10px;
            height: 10px;
            background: #28a745;
            border-radius: 50%;
            margin-right: 0.5rem;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🚀 EC2 Flask Server</h1>
            <p>Deployed with Terraform on AWS</p>
        </header>
        <div class="card">
            <h2><span class="status"></span>Server Status</h2>
            <div class="info-grid">
                <div class="info-item"><label>Hostname</label><span>{{ hostname }}</span></div>
                <div class="info-item"><label>Private IP</label><span>{{ private_ip }}</span></div>
                <div class="info-item"><label>Current Time</label><span>{{ current_time }}</span></div>
                <div class="info-item"><label>Python Version</label><span>{{ python_version }}</span></div>
            </div>
        </div>
        <div class="card">
            <h2>📊 System Metrics</h2>
            <div class="info-grid">
                <div class="info-item"><label>CPU Usage</label><span>{{ cpu_usage }}%</span></div>
                <div class="info-item"><label>Memory Usage</label><span>{{ memory_usage }}%</span></div>
                <div class="info-item"><label>Disk Usage</label><span>{{ disk_usage }}%</span></div>
            </div>
        </div>
        <div class="card">
            <h2>🛠️ Tech Stack</h2>
            <span class="badge">Python</span>
            <span class="badge">Flask</span>
            <span class="badge">EC2</span>
            <span class="badge">Terraform</span>
            <span class="badge">Nginx</span>
        </div>
    </div>
</body>
</html>
'''

@app.route('/')
def home():
    import sys
    return render_template_string(
        HTML_TEMPLATE,
        hostname=socket.gethostname(),
        private_ip=socket.gethostbyname(socket.gethostname()),
        current_time=datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        python_version=f"{sys.version_info.major}.{sys.version_info.minor}",
        cpu_usage=round(psutil.cpu_percent(interval=1), 2),
        memory_usage=round(psutil.virtual_memory().percent, 2),
        disk_usage=round(psutil.disk_usage('/').percent, 2)
    )

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()}), 200

@app.route('/api/info')
def info():
    import sys
    return jsonify({
        'hostname': socket.gethostname(),
        'private_ip': socket.gethostbyname(socket.gethostname()),
        'python_version': sys.version,
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
PYEOF

# Create requirements.txt
cat > /var/www/flask-app/requirements.txt << 'REQEOF'
Flask==3.0.0
gunicorn==21.2.0
psutil==5.9.6
REQEOF

# Install Python dependencies
echo "[6/8] Installing Python dependencies..."
source /var/www/flask-app/venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Create systemd service
echo "[7/8] Creating systemd service..."
sudo tee /etc/systemd/system/flask-app.service > /dev/null << 'SERVICEEOF'
[Unit]
Description=Flask Application
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/var/www/flask-app
Environment="PATH=/var/www/flask-app/venv/bin"
ExecStart=/var/www/flask-app/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
SERVICEEOF

# Configure Nginx
echo "[8/8] Configuring Nginx..."
sudo tee /etc/nginx/conf.d/flask-app.conf > /dev/null << 'NGINXEOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINXEOF

# Start services
echo "Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable flask-app
sudo systemctl start flask-app
sudo systemctl enable nginx
sudo systemctl start nginx

echo "=================================="
echo "Setup Complete!"
echo "Flask app running on port 5000"
echo "Nginx proxying on port 80"
echo "=================================="
