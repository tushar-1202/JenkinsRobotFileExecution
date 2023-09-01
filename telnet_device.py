 
import telnetlib
import time

HOST = "10.10.0.100"
PORT = "2007"
print("Inside")
tn = telnetlib.Telnet(HOST, PORT)
command = "cat /version.txt"
tn.write(command.encode('utf-8') + b"\n")

response = tn.read_until(b'root@telekom:~#').decode('utf-8')
print(response)

tn.close()



