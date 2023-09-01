*** Settings ***
Library    CellularManager.py
Library    Device.py
Library    CellularManager
Resource   CellularVariables.robot
Test Setup    Revert Config
Suite Teardown   Revert Config


*** Keywords ***
Revert Config

        ${status}=    Check Cellular Status
        Log To Console     cellular_status: ${status}

        Run Keyword If    '${status}' != 'REGISTERED'     Run Keywords   @{revert_config}

*** Test Cases ***

test1: Detection of Cellular Manager 
    [documentation]  This test case verifies the connection state on cellular manager when USB is connected
    [tags]          test1      Smoke	tc1.2
    
    ${cm_status}=	Check Cellular Status
    Log To Console     val: ${cm_status}
    Should Be Equal As Strings        '${cm_status}'           '${cellular_def_state}'


test2: Check wan Manager Status without removal of cellular device
    [documentation]  This test case verifies that  wan manager status before device removal
    [tags]          test2      Smoke	tc1.4
    ${wan_cm_status}=	get_wan_manager_device_detection_status     
    Log To Console     wan_status: ${wan_cm_status}
    Should Be Equal As Strings        '${wan_cm_status}'           'Up'


test3: Check erouter configuration and internet connectivity
    [documentation]   Check erouter configuration and internet connectivity 
    [tags]          test3      Smoke    tc1.4

    ${cmd2}=     Set Variable     ifconfig erouter0
    Log    ${cmd2}
    ${output}=       send_command        ${cmd2}
    ${check}=	 check_link_encap_and_ptp      ${output}
    Log    ${check}
    Should Be Equal As Strings        '${check}'       'True'

    ${ping_status}=       ping_connectivity       google.com
    Should Be Equal As Strings        '${ping_status}'           '1'

test4: Check Cellular Manager Status after removal of primary
    [documentation]      This test cases check Cellular Manager Status after removal of primary
    [tags]          test4      test2.1    test2.3
    
    ${primary_status} =    simulate_primary_removal 
    ${wan_cm_status}=   get_wan_manager_device_detection_status
    Log To Console     wan_status: ${wan_cm_status}
    Should Be Equal As Strings        '${wan_cm_status}'           'Down'
    #checking cellular status after primary down
    Sleep    2 minutes
    ${cm_status}=	Check Cellular Status
    Log To Console     val: ${cm_status}
    Should Be Equal As Strings        '${cm_status}'           'CONNECTED'

    ### check p-t-p configuration and internet connectivity in CONNECTED State

    ${cmd2}=     Set Variable     ifconfig erouter0
    Log    ${cmd2}
    ${output}=       send_command        ${cmd2}
    ${check}=    check_link_encap_and_ptp      ${output}
    Log    ${check}

    Should Not Be Equal As Strings        '${check}'       'True'

    Sleep    2 minutes
    ${ping_status}=       ping_connectivity       google.com
    Should Be Equal As Strings        '${ping_status}'           '1'

test5: Check Cellular Manager Status after restoring of primary
    [documentation]      This test cases check Cellular Manager Status after restoring of primary
    [tags]          test5      test2.4

    ${primary_status} =    Run Keyword If    '${status}' != 'REGISTERED'     connect_back_primary 
    Sleep    2 minutes
    ${cmd_status}=	Check Cellular Status
    Log To Console     wan_status: ${cmd_status}
    Should Be Equal As Strings        '${cmd_status}'           'REGISTERED'

    ${ping_status}=       ping_connectivity       google.com
    Should Be Equal As Strings        '${ping_status}'           '1'


# Making cellular down by disconnecting usb through automation 
test6: Simulate cellular interface down and check the Status
   [documentation]  This test case simulates cellular manager down
   [tags]          test6     Smoke    tc1.3
   ${output}=    Simulate Usb Removal
   ${cellular_status}=    Check Cellular Status
   Should Be Equal As Strings        '${cellular_status}'        'DOWN'
   ${cellular_status_on_wan_manager}=    Check Cellular Interface Status On Wan Manager
   Should Be Equal As Strings    '${cellular_status_on_wan_manager}'        'Down'
   ${cellular_interface_status}=    Check Cellular Interface Status
   Should Be Equal As Strings        '${cellular_interface_status}'        'Down'



