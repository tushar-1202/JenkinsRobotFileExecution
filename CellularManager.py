import time
import re
import subprocess
from robot.libraries.BuiltIn import BuiltIn
#from robot.libraries import BuiltIn
from Device import Device
#import pandas as pd
from datetime import datetime
from robot.utils import DotDict


class CellularManager:
    def __init__(self):
        self.device=Device()

    def get_test_status(self,output):
        print("Inside get test_status")
        try:
            data = [val for val in output.split('\n') if "value:" in val]
            if data:
                value_line = data[-1].split("value:", 1)[-1].strip()
                return value_line
            raise ValueError("Unable to extract value")

        except Exception as err:
            err="Command execution Failed, please check Manually"
            return err

    def get_wan_manager_device_detection_status(self):
        wan_status = BuiltIn().get_variable_value("${wan_status}")
        output = self.device.send_command(wan_status)
        print("output: ",output)
        status = self.get_test_status(output)
        print("Status: ",status)
        return status

    def simulate_primary_removal(self):
        wan_removal = BuiltIn().get_variable_value("${wan_down}")
        output = self.device.send_command(wan_removal)
        time.sleep(5)
        status = self.get_test_status(output)
        time.sleep(5)
        return status

    def get_primary_status(self):
        #check wan is up
        wan_int_status = BuiltIn().get_variable_value("${wan_int_status}")
        output = self.device.send_command(wan_int_status)
        status = self.get_test_status(output)
        print("Status: ",status)
        return status
    
    def ping_connectivity(self,dest):
        cmd= 'ping -c 1 ' + dest
        output = self.device.send_command(cmd)
        time.sleep(5)
        data = str([val for val in output.split('\n') if "received" in val][-1])
        pattern='(\d+) packets received'
        val_string = re.search(pattern, data).group(1)
        if val_string== '1':
            return 1
        return -1

    def connect_back_primary(self):
        wan_removal = BuiltIn().get_variable_value("${wan_up}")
        output = self.device.send_command(wan_removal)
        time.sleep(5)
        status = self.get_test_status(output)
        time.sleep(120)
        return status

    def get_commands_from_file(self):
        # Read the Excel file
        xlsx_file = pd.read_excel('CellularManager_DM_DT.xlsx')
    
        xlsx_file['NAME'] = xlsx_file['NAME'].str.replace('{i}', '1')
    
        # Extract first three columns
        subset_data = xlsx_file.iloc[:, :3]
    
        # Convert to CSV and save
        subset_data.to_csv('output.csv', index=False)
    
        # Read the CSV file
        df = pd.read_csv('output.csv',skiprows=range(1,9), nrows=4)
        #df = pd.read_csv('output.csv', nrows=5)
    
        # Initialize variables
        var1 = ""
        cmd_list = []
    
        # Iterate over the rows
        for index, row in df.iterrows():
            if row['TYPE'] == 'object':
                var1 = row['NAME']
            elif row['TYPE'] != 'boolean':
                cmd = "dmcli eRT getv " + var1 + row['NAME']
                cmd_list.append([cmd])
                out = self.device.send_command(cmd)
                cmd_list[-1].append(out)
    
                val = self.get_test_status(out)
                cmd_list[-1].append(val)
    
        # Create a DataFrame from the command list
        cmd_df = pd.DataFrame(cmd_list, columns=['Command', 'Output', 'Value'])
    
        # Save the DataFrame to a new Excel file
        #cmd_df.to_excel('commands_output.xlsx', index=False)
        cmd_df.to_csv('automation_ouput.csv', index=False)
    
        return cmd_df

    def validate_timestamp(self,timestamp):
        try:
          datetime.strptime(timestamp, "%m/%d/%y - %I:%M%p")
          return True
        except ValueError:
          return False


    def validate_and_compare_timestamps(self,first_timestamp,last_timestamp):
  		# Validate the time stamps
        if self.validate_timestamp(first_timestamp) and self.validate_timestamp(last_timestamp):
        # Convert the time stamps to datetime objects for comparison
            first_datetime = datetime.strptime(first_timestamp, "%m/%d/%y - %I:%M%p")
            last_datetime = datetime.strptime(last_timestamp, "%m/%d/%y - %I:%M%p")
  
  			# Check if first_time_stamp is greater than last_time_stamp
            if first_datetime <= last_datetime:
                print("Time stamps are valid and first_time_stamp < last_time_stamp.")
                return True
            else:
                print("Time stamps are valid but first_time_stamp >= last_time_stamp.")
        else:
            print("Invalid time stamp format.")
        return False

    def get_mmcli_values(self):
        output = self.device.send_command("mmcli -m 0")
        time.sleep(5)

        data_dict = {}
        pattern = r"\|\s*(\w+(?:\s+\w+)*)\s*:\s*(.+)"

        matches = re.findall(pattern, output)

        for match in matches:
            key = match[0].lower().replace(' ', '_')
            value = match[1].strip()
            if key in ['firmware_revision','manufacturer', 'model', 'imei', 'operator_name', 'registration', 'state', 'access_tech', 'operator_id']:
                data_dict[key] = value

            operator_id = data_dict.get('operator_id')
            if operator_id is not None and len(operator_id) >= 5:
                mcc = operator_id[:3]
                mnc = operator_id[3:]
                data_dict['mcc'] = mcc
                data_dict['mnc'] = mnc
                plmnid = mcc + ('0' + mnc if len(mnc) == 2 else mnc)
                data_dict['plmnid'] = plmnid
        return data_dict


    def simulate_cellular_interface_down(self):
         sim_removal = BuiltIn().get_variable_value("${cell_int_down}")
         output = self.device.send_command(sim_removal)
         time.sleep(5)
         return output

    def reconnect_cellular_interface(self):
         sim_cmd = BuiltIn().get_variable_value("${cell_int_up}")
         output = self.device.send_command(sim_cmd)
         time.sleep(5)
         return output


    def check_link_encap_and_ptp(self,input_string):
        # Define the regular expression patterns
        link_encap_pattern = r'Link encap:(\S+)'

        ptp_pattern = r'P-t-P:(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'

        # Find the values using regular expressions
        link_encap_match = re.search(link_encap_pattern, input_string)
        ptp_match = re.search(ptp_pattern, input_string)
        # Check if both values are found
        if link_encap_match and ptp_match:
            link_encap_value = link_encap_match.group(1)
            ptp_value = ptp_match.group(1)
            # Check if the values meet the specified conditions
            if link_encap_value == 'Point-to-Point' and self.is_valid_ip(ptp_value):
                return True
        return False

    def is_valid_ip(self,ip):

        ip_pattern = r'(1?[0-9][0-9]?)|(2[0-5][0-5])\.(1?[0-9][0-9]?)|(2[0-5][0-5])\.(1?[0-9][0-9]?)|(2[0-5][0-5])\.(1?[0-9][0-9]?)|(2[0-5][0-5])'

        # Simple check for a valid IP address format
        return re.match(ip_pattern, ip) is not None

    def simulate_usb_removal(self):
        disconnect_usb = BuiltIn().get_variable_value("${disconnect_usb}")
        output = self.device.send_command(disconnect_usb)
        time.sleep(60)
        #status = self.get_test_status(output)
        return output

    def simulate_usb_connect(self):
        connect_usb = BuiltIn().get_variable_value("${connect_usb}")
        output = self.device.send_command(connect_usb)
        time.sleep(60)
        #status = self.get_test_status(output)
        return output

    def check_cellular_status(self):
        cellular_status = BuiltIn().get_variable_value("${cellular_status}")
        output = self.device.send_command(cellular_status)
        time.sleep(2)
        status = self.get_test_status(output)
        return status
    
    def check_cellular_interface_status(self):
        cellular_interface_status = BuiltIn().get_variable_value("${cellular_int_status}")
        output = self.device.send_command(cellular_interface_status)
        time.sleep(2)
        status = self.get_test_status(output)
        return status   

    def check_cellular_interface_status_on_wan_manager(self):
        cellular_int_status_wan_manager = BuiltIn().get_variable_value("${cellular_int_status_wan_manager}")
        output = self.device.send_command(cellular_int_status_wan_manager)
        time.sleep(2)
        status = self.get_test_status(output)
        return status 
