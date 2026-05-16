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
        elif parsed.path == '/api/git-pull':
            try:
                result = subprocess.run(
                    ['git', 'pull'],
                    capture_output=True, text=True, cwd=FOLDER, timeout=30
                )
                output = result.stdout + result.stderr
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"success": result.returncode == 0, "output": output}).encode())
            except Exception as e:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"success": False, "error": str(e)}).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        # Silenciar logs para mejor rendimiento en móvil
        pass

def try_port(port):
    """Intenta usar un puerto específico, retorna True si está libre"""
    import socket
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.bind(("", port))
        sock.close()
        return True
    except OSError:
        return False

# Habilitar reutilización de puerto ANTES de intentar bind
socketserver.TCPServer.allow_reuse_address = True

# Intentar usar puerto 8000 primero, solo buscar otro si está ocupado
if try_port(8000):
    PORT = 8000
else:
    print("⚠️  Puerto 8000 ocupado, buscando alternativa...")
    # Buscar puerto libre solo si 8000 falla
    import socket
    for port in range(8001, 8010):
        if try_port(port):
            PORT = port
            break
    else:
        PORT = 8000  # Intentar 8000 de todos modos con reuse_address

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
