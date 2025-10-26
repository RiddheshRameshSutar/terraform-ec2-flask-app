from flask import Flask, jsonify, render_template_string
import socket
import os
from datetime import datetime
import psutil

app = Flask(__name__)

# HTML Template
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EC2 Flask Server</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 2rem;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
        }
        header {
            text-align: center;
            color: white;
            margin-bottom: 2rem;
        }
        header h1 {
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
        }
        .card {
            background: white;
            border-radius: 10px;
            padding: 2rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .card h2 {
            color: #667eea;
            margin-bottom: 1rem;
            font-size: 1.5rem;
        }
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
        .info-item span {
            color: #333;
            font-size: 1.1rem;
        }
        .badge {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.9rem;
            margin: 0.5rem 0.5rem 0 0;
        }
        .endpoint-list {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 8px;
            margin-top: 1rem;
        }
        .endpoint-list a {
            color: #667eea;
            text-decoration: none;
            display: block;
            padding: 0.5rem;
            border-bottom: 1px solid #e0e0e0;
        }
        .endpoint-list a:hover {
            background: #e9ecef;
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
                <div class="info-item">
                    <label>Hostname</label>
                    <span>{{ hostname }}</span>
                </div>
                <div class="info-item">
                    <label>Private IP</label>
                    <span>{{ private_ip }}</span>
                </div>
                <div class="info-item">
                    <label>Current Time</label>
                    <span>{{ current_time }}</span>
                </div>
                <div class="info-item">
                    <label>Python Version</label>
                    <span>{{ python_version }}</span>
                </div>
            </div>
        </div>

        <div class="card">
            <h2>📊 System Metrics</h2>
            <div class="info-grid">
                <div class="info-item">
                    <label>CPU Usage</label>
                    <span>{{ cpu_usage }}%</span>
                </div>
                <div class="info-item">
                    <label>Memory Usage</label>
                    <span>{{ memory_usage }}%</span>
                </div>
                <div class="info-item">
                    <label>Disk Usage</label>
                    <span>{{ disk_usage }}%</span>
                </div>
                <div class="info-item">
                    <label>Uptime</label>
                    <span>{{ uptime }}</span>
                </div>
            </div>
        </div>

        <div class="card">
            <h2>🛠️ Tech Stack</h2>
            <div>
                <span class="badge">Python {{ python_version }}</span>
                <span class="badge">Flask</span>
                <span class="badge">EC2</span>
                <span class="badge">Terraform</span>
                <span class="badge">Nginx</span>
                <span class="badge">Systemd</span>
            </div>
        </div>

        <div class="card">
            <h2>🔗 API Endpoints</h2>
            <div class="endpoint-list">
                <a href="/">[GET] / - Home page (this page)</a>
                <a href="/health">[GET] /health - Health check endpoint</a>
                <a href="/api/info">[GET] /api/info - Server information JSON</a>
                <a href="/api/metrics">[GET] /api/metrics - System metrics JSON</a>
            </div>
        </div>
    </div>
</body>
</html>
'''

@app.route('/')
def home():
    """Home page with server information"""
    import sys
    boot_time = datetime.fromtimestamp(psutil.boot_time())
    uptime = datetime.now() - boot_time
    uptime_str = f"{uptime.days}d {uptime.seconds//3600}h {(uptime.seconds//60)%60}m"
    
    return render_template_string(
        HTML_TEMPLATE,
        hostname=socket.gethostname(),
        private_ip=socket.gethostbyname(socket.gethostname()),
        current_time=datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        python_version=f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}",
        cpu_usage=round(psutil.cpu_percent(interval=1), 2),
        memory_usage=round(psutil.virtual_memory().percent, 2),
        disk_usage=round(psutil.disk_usage('/').percent, 2),
        uptime=uptime_str
    )

@app.route('/health')
def health():
    """Health check endpoint for load balancers"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'hostname': socket.gethostname()
    }), 200

@app.route('/api/info')
def info():
    """Server information API endpoint"""
    import sys
    import platform
    
    return jsonify({
        'hostname': socket.gethostname(),
        'private_ip': socket.gethostbyname(socket.gethostname()),
        'python_version': sys.version,
        'platform': platform.platform(),
        'processor': platform.processor(),
        'architecture': platform.machine(),
        'timestamp': datetime.now().isoformat(),
        'environment': os.environ.get('ENVIRONMENT', 'production')
    })

@app.route('/api/metrics')
def metrics():
    """System metrics API endpoint"""
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    
    boot_time = datetime.fromtimestamp(psutil.boot_time())
    uptime_seconds = (datetime.now() - boot_time).total_seconds()
    
    return jsonify({
        'cpu': {
            'percent': cpu_percent,
            'count': psutil.cpu_count()
        },
        'memory': {
            'total_gb': round(memory.total / (1024**3), 2),
            'used_gb': round(memory.used / (1024**3), 2),
            'percent': memory.percent
        },
        'disk': {
            'total_gb': round(disk.total / (1024**3), 2),
            'used_gb': round(disk.used / (1024**3), 2),
            'percent': round((disk.used / disk.total) * 100, 2)
        },
        'uptime_seconds': int(uptime_seconds),
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    # Run on all interfaces, port 5000
    app.run(host='0.0.0.0', port=5000, debug=False)
