import time
import re
import subprocess
from robot.libraries.BuiltIn import BuiltIn


class Device:
    def __init__(self):
        self.device_handle = None

    def send_command(self,input_data):

        try:
            device_ip = BuiltIn().get_variable_value("${devip}")
            device_port= BuiltIn().get_variable_value("${devport}")

            command = "telnet " + device_ip + " " + device_port
            # Start the subprocess
            process = subprocess.Popen(command, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)

            time.sleep(3)

            # Pass input to the subprocess
            process.stdin.write("\n")
            process.stdin.flush()    # Ensure the input is sent

            inp_cmd = input_data.replace("'","")
            process.stdin.write(inp_cmd)
            process.stdin.flush()    # Ensure the input is sent
            time.sleep(2)
            process.stdin.write("\n")
            process.stdin.flush()  

            process.stdin.write(inp_cmd)
            process.stdin.flush()    # Ensure the input is sent
            time.sleep(2)
            output, error = process.communicate()
            time.sleep(5)

            print("Output_connect_dut: ",output)
            # Close the subprocess
            process.stdin.close()
            process.stdout.close()
            process.stderr.close()

            return output

        except Exception as err:
            print("Check telnet connection of device..!!!", err)
            return -1
   

    def disconnect_device(self):
        if self.device_handle:
            self.device_handle.stdin.close()
            self.device_handle.stdout.close()
            self.device_handle.stderr.close()
            self.device_handle.wait()
            self.device_handle = None
            print('Device disconnected.')
        else:
            print('No device connected.')

