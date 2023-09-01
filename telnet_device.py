 
import telnetlib
import time

HOST = "10.10.0.100"
PORT = 2007
print("Inside")
tn = telnetlib.Telnet(HOST, PORT)
command = "cat /version.txt"
tn.write(command.encode('utf-8') + b"\n")

response = tn.read_all().decode('utf-8')
print(response)

tn.close()
# Wait for 2 minutes
time.sleep(120)  # 2 minutes = 120 seconds

# Now send your command
command = "ifconfig brlan0"
tn.write(command.encode('utf-8') + b"\n")

# Read and print the response
response = tn.read_all().decode('utf-8')
print(response)

tn.close()



