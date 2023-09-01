*** Variables ***
${devip}        10.10.0.100
${devport}      2007

${usb_type}	RNDIS
#${usb_type}	MODEM

${usb_model}    MZS_E5577C
#${usb_model}    E5785_320a
&{MZS_E5577C_reg_exp_dict}     enable=true    status=REGISTERED   role=BACKUP   dev_type=USBRNDIS     ctrl_int_stat=OPENED   dataint=eth5   dataintlink=IP_RAW       int_entries=1

&{E5785_320a_reg_exp_dict}     enable=true    status=REGISTERED   role=BACKUP   dev_type=USBRNDIS     ctrl_int_stat=OPENED   dataint=usb0   dataintlink=IP_RAW       int_entries=1

&{E5785_330a_reg_exp_dict}     enable=true    status=REGISTERED   role=BACKUP   dev_type=USBRNDIS     ctrl_int_stat=OPENED   dataint=usb0   dataintlink=IP_RAW       int_entries=1

&{MZS_E5577C_conn_exp_dict}     enable=true    status=CONNECTED   role=BACKUP   dev_type=USBRNDIS     ctrl_int_stat=OPENED   dataint=eth5   dataintlink=IP_RAW       int_entries=1

${cellular_status}      'dmcli eRT getv Device.Cellular.X_RDK_Status'
${wan_status}   'dmcli eRT getv Device.X_RDK_WanManager.CPEInterface.2.LinkStatus'
${cellular_def_state}       REGISTERED
${get_sim_status}   'dmcli eRT getv Device.Cellular.X_RDK_Enable'
${wan_down}     'dmcli eRT setv Device.X_RDK_WanManager.CPEInterface.2.LinkStatus string \"Down\"'
${wan_up}   'dmcli eRT setv Device.X_RDK_WanManager.CPEInterface.2.LinkStatus string \"Up\"'
${wan_int_status}       'dmcli eRT getv Device.X_RDK_WanManager.CPEInterface.2.LinkStatus'

${sim_down}     'dmcli eRT setv Device.Cellular.X_RDK_Enable bool false'
${sim_up}     'dmcli eRT setv Device.Cellular.X_RDK_Enable bool true'
${cell_int_down}     'dmcli eRT setv Device.Cellular.Interface.1.Enable bool false'
${cell_int_up}     'dmcli eRT setv Device.Cellular.Interface.1.Enable bool true'

${get_sim_status}   'dmcli eRT getv Device.Cellular.X_RDK_Enable'
${disconnect_usb}     'echo '1-0:1.0' > /sys/bus/usb/drivers/hub/unbind'
${connect_usb}     'echo '1-0:1.0' > /sys/bus/usb/drivers/hub/bind'

${cellular_int_status}    'dmcli eRT getv Device.Cellular.Interface.1.Status'
${cellular_int_status_wan_manager}    'dmcli eRT getv Device.X_RDK_WanManager.CPEInterface.4.LinkStatus'

@{reg_params}     enable        status     role    dev_type     ctrl_int_stat     dataint       dataintlink
@{conn_params}     enable        status     role    dev_type     ctrl_int_stat     dataint       dataintlink
@{down_params}     enable       status     role    dev_type     ctrl_int_stat     dataintlink

&{generic_cmd_dict}     first_tstamp=X_RDK_FirstUseTimeStamp      last_tstamp=X_RDK_LastUseTimeStamp

&{xrdk_cmd_dict}            enable=Enable       status=Status      role=Role       dev_type=DeviceType     ctrl_int_stat=ControlInterfaceStatus   dataint=DataInterface    dataintlink=DataInterfaceLink          int_entries=InterfaceNumberOfEntries

&{reg_exp_dict}     enable=true    status=REGISTERED   role=BACKUP   dev_type=USBMODEM     ctrl_int_stat=OPENED   dataint=eth5   dataintlink=IP_RAW       int_entries=1

&{down_exp_dict}     enable=true    status=DOWN   role=BACKUP   dev_type=UNKNOWN      ctrl_int_stat=CLOSED     dataintlink=IP_RAW       int_entries=1


@{reg_int_params}           enable       status    lastchange    upstream
@{conn_int_params}           enable      lastchange    upstream
#@{down_int_params}         enable       status    lastchange   
## To-Do Status checked removed for now due to JIRA RDKGWS-2126  ### will revert once fixed
@{down_int_params}         enable        lastchange	upstream

&{int_cmd_dict}    enable=Enable        status=Status     lastchange=LastChange    upstream=Upstream    phyconnstatus=X_RDK_PhyConnectedStatus     linkstatus=X_RDK_LinkAvailableStatus

&{reg_int_exp_dict}     enable=true      status=Up         lastchange=0    upstream=false
&{down_int_exp_dict}     enable=true    status=Down       lastchange=0    upstream=false
&{conn_int_exp_dict}     enable=true    status=Down       lastchange=0    upstream=true

@{int_xrdk_params}         regstatus       phyconnstatus      linkstatus
&{int_xrdk_cmd_dict}       regstatus=RegisteredService       phyconnstatus=PhyConnectedStatus      linkstatus=LinkAvailableStatus
&{reg_int_xrdk_exp_dict}       regstatus=PS-CS        phyconnstatus=true     linkstatus=false
&{down_int_xrdk_exp_dict}       regstatus=PS-CS       phyconnstatus=false    linkstatus=false
&{conn_int_xrdk_exp_dict}       regstatus=PS-CS       phyconnstatus=true    linkstatus=true

@{xrdk_Statistics_params}      BytesSent    BytesReceived        PacketsSent      PacketsReceived    PacketsSentDrop    PacketsReceivedDrop
&{xrdk_Statistics_exp_dict}       BytesReceived=0        PacketsSent=0      PacketsReceived=0    PacketsSentDrop=0    PacketsReceivedDrop=0
&{reg_int_xrdk_Statistics_exp_dict}       BytesReceived=0        PacketsSent=0      PacketsReceived=0    PacketsSentDrop=0    PacketsReceivedDrop=0
&{conn_int_xrdk_Statistics_exp_dict}       BytesReceived=0        PacketsSent=0      PacketsReceived=0    PacketsSentDrop=0    PacketsReceivedDrop=0
&{down_int_xrdk_Statistics_exp_dict}       BytesReceived=0      PacketsSent=0      PacketsReceived=0    PacketsSentDrop=0    PacketsReceivedDrop=0


${sim_down}     'dmcli eRT setv Device.Cellular.X_RDK_Enable bool false'
${sim_up}     'dmcli eRT setv Device.Cellular.X_RDK_Enable bool true'
${cell_int_down}     'dmcli eRT setv Device.Cellular.Interface.1.Enable bool false'
${cell_int_up}     'dmcli eRT setv Device.Cellular.Interface.1.Enable bool true'

${get_sim_status}   'dmcli eRT getv Device.Cellular.X_RDK_Enable'
${disconnect_usb}     'echo '1-0:1.0' > /sys/bus/usb/drivers/hub/unbind'
${connect_usb}     'echo '1-0:1.0' > /sys/bus/usb/drivers/hub/bind'

${cellular_status}      'dmcli eRT getv Device.Cellular.X_RDK_Status'
${wan_status}   'dmcli eRT getv Device.X_RDK_WanManager.CPEInterface.2.LinkStatus'
${cellular_def_state}       REGISTERED
${wan_down}     'dmcli eRT setv Device.X_RDK_WanManager.CPEInterface.2.LinkStatus string \"Down\"'
${wan_up}   'dmcli eRT setv Device.X_RDK_WanManager.CPEInterface.2.LinkStatus string \"Up\"'
${wan_int_status}       'dmcli eRT getv Device.X_RDK_WanManager.CPEInterface.2.LinkStatus

${cellular_int_status}    'dmcli eRT getv Device.Cellular.Interface.1.Status'
${cellular_int_status_wan_manager}    'dmcli eRT getv Device.X_RDK_WanManager.CPEInterface.4.LinkStatus'
${cellular_def_state}       REGISTERED


@{revert_config}    Simulate Usb Connect    connect_back_primary

