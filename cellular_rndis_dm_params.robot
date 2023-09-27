*** Settings ***
Library    CellularManager.py
Library    Device.py
Resource    CellularVariables.robot
Test Setup   Revert Config
Suite Teardown  Revert Config

*** Keywords ***
Revert Config

        ${status}=    Check Cellular Status

	Run Keyword If    '${status}' != 'REGISTERED'     Log To Console    Cellular status in ${status} state, Reverting config...
	Run Keyword If    '${status}' != 'REGISTERED'     Run Keywords   @{revert_config}

Validate X_RDK params
    [Arguments]     ${params}      ${state}     ${usb_mod}=

        ${usb_mod}=    Run Keyword If    '${usb_type}' == 'RNDIS'     Evaluate    "${usb_mod}".replace('-', '_')     ELSE    Set Variable    ${EMPTY}
        ${variable}=    Run Keyword If    '${usb_type}' == 'RNDIS'    Set Variable    ${usb_mod}_${state}    ELSE    Set Variable    ${state}
        Log To Console    USB Type: ${usb_type}
        Log To Console    USB Model: ${usb_mod}

    FOR    ${param}    IN    @{params}
        ${cmd}=     Set Variable     dmcli eRT getv Device.Cellular.X_RDK_${xrdk_cmd_dict.${param}}
        Log To Console    command executed: ${cmd}
        ${output}=       send_command        ${cmd}
        ${cm_status}=    get_test_status     ${output}
        Log To Console    Device val: ${cm_status}
        Log To Console    Expected val: ${${variable}_exp_dict.${param}}
        Should Be Equal As Strings        ${cm_status}        ${${variable}_exp_dict.${param}}
    END


Validate Cellular Interface params
    [Arguments]     ${int_params}      ${state}

    FOR    ${param}    IN    @{int_params}
        ${cmd}=     Set Variable     dmcli eRT getv Device.Cellular.Interface.1.${int_cmd_dict.${param}}
        Log To Console   command executed: ${cmd}
        ${output}=       send_command        ${cmd}
        ${cm_status}=    get_test_status     ${output}
        Log To Console     Device value: ${cm_status}
        Log To Console     Expected value: ${${state}_int_exp_dict.${param}}
        Should Be Equal As Strings        ${cm_status}        ${${state}_int_exp_dict.${param}}
    END


Validate Cellular Interface X_RDK params
    [Arguments]     ${state}

    FOR    ${param}    IN    @{int_xrdk_params}

        ${cmd}=     Set Variable     dmcli eRT getv Device.Cellular.Interface.1.X_RDK_${int_xrdk_cmd_dict.${param}}
        Log To Console   command executed: ${cmd}
        ${output}=       send_command        ${cmd}
        ${cm_status}=    get_test_status     ${output}
        Log To Console     Device value: ${cm_status}
        Log To Console     Expected val: ${${state}_int_xrdk_exp_dict.${param}}
        Should Be Equal As Strings        ${cm_status}        ${${state}_int_xrdk_exp_dict.${param}}
    END

Validate Cellular X_RDK Statistics
    [Arguments]     ${state}

    FOR    ${param}    IN    @{xrdk_Statistics_params}

        ${cmd}=     Set Variable     dmcli eRT getv Device.Cellular.Interface.1.X_RDK_Statistics.${param}
        Log To Console   command executed: ${cmd}
        ${output}=       send_command        ${cmd}
        ${count}=    get_test_status     ${output}
        Log To Console     Device Statistics count: ${count}
        Run Keyword If    '${state}' != 'conn' or 'Drop' in '${param}'    Should Be True     ${count} == 0 
        ...    ELSE       Should Be True    ${count} > 0     
    END


*** Test Cases ***
test1: Validate Data model object params based on Cellular module state
    [documentation]    Validation based on REGISTERED State
    [tags]          t1:retry(2)     RDK_Status

    ${output}=       send_command        dmcli eRT getv Device.Cellular.X_RDK_Status
    ${out}=    get_test_status     ${output}

    Validate X_RDK params      ${reg_params}     reg     ${usb_model}
    Validate Cellular Interface Params    ${reg_int_params}	   reg
    Validate Cellular Interface X_RDK params	  reg
    Validate Cellular X_RDK Statistics     reg

test2: Validate Data model object params based on DOWN State
    [documentation]    Validation based on DOWN State
    [tags]          t2         RDKGWS-2126

    ${output}=    Simulate Usb Removal
    ${cellular_status}=    Check Cellular Status
    Should Be Equal As Strings        '${cellular_status}'           'DOWN'

    Validate X_RDK params      ${down_params}     down
    ### Status checked removed for now due to PR RDKGWS-2126
    Validate Cellular Interface Params    ${down_int_params}    down
    Validate Cellular Interface X_RDK params	  down
    Validate Cellular X_RDK Statistics     down


test3: Validate Data model object params based on CONNECTED State
    [documentation]     Validation based on CONNECTED State
    [tags]          t3        RDKGWS-2126 

    ${primary_status} =    simulate_primary_removal
    Sleep    3 minutes
    ${cm_status}=       Check Cellular Status
    Log To Console     val: ${cm_status}
    Should Be Equal As Strings        '${cm_status}'           'CONNECTED'

    Validate X_RDK params      ${conn_params}     conn      ${usb_model}
    ### Status checked removed for now due to PR RDKGWS-2126
    Validate Cellular Interface Params    ${conn_int_params}    conn
    Validate Cellular Interface X_RDK params      conn
    Validate Cellular X_RDK Statistics      conn


tc4: Validate Device.Cellular.X_RDK TimeStamp
    [documentation]    Validate Device.X_RDK_LastUseTimeStamp datamodel
    [tags]          t4      timestamp

    ${cmd1}=     Set Variable     dmcli eRT getv Device.Cellular.${generic_cmd_dict.first_tstamp}
    Log To Console    Command Executed: ${cmd1}
    ${output}=       send_command        ${cmd1}
    ${timestamp1}=    get_test_status     ${output}

    ${ret_val}=      validate_timestamp     ${timestamp1}
    Should Be Equal As Strings        '${ret_val}'       'True'

    ${cmd2}=     Set Variable     dmcli eRT getv Device.Cellular.${generic_cmd_dict.last_tstamp}
    Log To Console    Command Executed: ${cmd2}
    ${output}=       send_command        ${cmd2}
    ${timestamp2}=    get_test_status     ${output}

    ${ret_val}=      validate_timestamp     ${timestamp2}
    Should Be Equal As Strings        '${ret_val}'       'True'

    ${status}=    validate_and_compare_timestamps       ${timestamp1}        ${timestamp2} 
    Should Be Equal As Strings        '${status}'       'True'


tc5: Simulate Cellular Interface down and check the write status
    [documentation]   Simulate Cellular Interface down and check the status
    [tags]          t5     Smoke

    ${int_down}=     simulate_cellular_interface_down
    ${cmd1}=     Set Variable     dmcli eRT getv Device.Cellular.Interface.1.${int_cmd_dict.enable}
    Log To Console     Command Executed: ${cmd1}
    ${output}=       send_command        ${cmd1}
    ${status}=    get_test_status     ${output}
    Should Not Be Equal As Strings        '${status}'       'true'

    ### Reseting cellular interface status to Enable
    ${cell_status}=     reconnect_cellular_interface
    ${cmd2}=     Set Variable     dmcli eRT getv Device.Cellular.Interface.1.${int_cmd_dict.enable}
    ${output}=       send_command        ${cmd2}
    ${status}=    get_test_status     ${output}
    Should Be Equal As Strings        '${status}'       'true'

