#!/usr/bin/env python3
import http.server
import socketserver
import os
import subprocess
import time
import threading
import json
from urllib.parse import urlparse

PORT = 8000
FOLDER = os.path.dirname(os.path.abspath(__file__))
DATA_FILE = os.path.join(FOLDER, 'gym_data.json')

os.chdir(FOLDER)

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        super().end_headers()

    def do_OPTIONS(self):
        """Handle preflight CORS requests"""
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        """Handle GET requests - API or static files"""
        parsed = urlparse(self.path)

        if parsed.path == '/api/data':
            try:
                with open(DATA_FILE, 'r', encoding='utf-8') as f:
                    data = json.load(f)

                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps(data).encode())
            except FileNotFoundError:
                # Si no existe, crear archivo inicial
                initial_data = {"sessions": [], "weights": []}
                with open(DATA_FILE, 'w', encoding='utf-8') as f:
                    json.dump(initial_data, f, indent=2)

                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps(initial_data).encode())
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode())
        else:
            # Servir archivos estáticos normalmente
            super().do_GET()

    def do_POST(self):
        """Handle POST requests - Save data"""
        parsed = urlparse(self.path)

        if parsed.path == '/api/data':
            try:
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode())

                # Guardar datos
                with open(DATA_FILE, 'w', encoding='utf-8') as f:
                    json.dump(data, f, indent=2, ensure_ascii=False)

                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"success": True}).encode())
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        # Silenciar logs para mejor rendimiento en móvil
        pass

def find_free_port(start_port=8000, max_attempts=10):
    import socket
    for port in range(start_port, start_port + max_attempts):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.bind(("", port))
            sock.close()
            return port
        except OSError:
            continue
    return 8000

PORT = find_free_port()

socketserver.TCPServer.allow_reuse_address = True

print("=" * 50)
print(" GYM TRACKER — CALISTENIA")
print("=" * 50)
print(f"\nServidor iniciado en puerto {PORT}")
print(f"Presiona Ctrl+C para detener")
print("=" * 50)

def open_browser():
    """Espera 2 segundos y abre el navegador"""
    time.sleep(2)
    url = f"http://localhost:{PORT}/gymtracker.html"
    try:
        # Intentar abrir con Chrome en Android (Termux)
        subprocess.run([
            'am', 'start',
            '-a', 'android.intent.action.VIEW',
            '-d', url,
            '-n', 'com.android.chrome/com.google.android.apps.chrome.Main'
        ], check=False)
        print(f"\nChrome abierto automaticamente")
    except FileNotFoundError:
        # Si no está en Termux, intentar webbrowser normal (PC)
        try:
            import webbrowser
            webbrowser.open(url)
            print(f"\nNavegador abierto automaticamente")
        except:
            print(f"\nAbre manualmente: {url}")

# Abrir navegador en segundo plano
threading.Thread(target=open_browser, daemon=True).start()

with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServidor detenido")
