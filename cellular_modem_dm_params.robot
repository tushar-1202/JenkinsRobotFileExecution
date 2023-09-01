*** Settings ***
Library    CellularManager.py
Library    Device.py

*** Variables ***
### Define below params based on model
${devip}     	10.10.0.100 
${devport}	2007


&{deactive_cmd_dict}      status=Status   role=Role     model=Model    vendor=Vendor     dev_type=DeviceType
&{deactive_exp_dict}      status=DEREGISTERED     role=BACKUP      model=E3372      vendor=huawei

&{down_cmd_dict}      status=Status   role=Role      vendor=Vendor     dev_type=DeviceType
&{down_exp_dict}      status=DOWN     role=BACKUP      model=E3372      vendor=huawei

&{reg_cmd_dict}      status=Status   role=Role      model=Model	   vendor=Vendor     dev_type=DeviceType       dataInt=DataInterface    dataIntlink=DataInterfaceLink
&{reg_exp_dict}      status=REGISTERED     role=BACKUP      model=E3372      vendor=huawei      dev_type=USBMODEM      dataInt=wwan0     dataIntlink=IP_RAW


@{params}        status    role     model     vendor    dev_type     dataInt	dataIntlink

@{int_params}	   service   conn_status   link_status   imei   iden_iccid
@{int_rdk_params}	   service   conn_status   link_status   imei   iden_iccid

&{int_cmd_dict}	    service=RegisteredService    conn_status=PhyConnectedStatus    link_status=LinkAvailableStatus  imei=Identification.Imei     supp_acc_tech=SupportedAccessTechnologies	curr_acc_tech=CurrentAccessTechnology	  iden_iccid=Identification.Iccid

&{int_exp_dict}		service=PS-CS    conn_status=true    link_status=false    imei=866785035273852     supp_acc_tech=GSM,UMTS,LTEGSM,UMTS,LTE     curr_acc_tech=LTE	    iden_iccid=8991000908202678849


&{int_cmd_dict}     service=RegisteredService    conn_status=PhyConnectedStatus    link_status=LinkAvailableStatus  imei=Identification.Imei     supp_acc_tech=SupportedAccessTechnologies      curr_acc_tech=CurrentAccessTechnology     iden_iccid=Identification.Iccid

&{int_exp_dict}         service=PS-CS    conn_status=true    link_status=false    imei=866785035273852     supp_acc_tech=GSM,UMTS,LTEGSM,UMTS,LTE     curr_acc_tech=LTE     iden_iccid=8991000908202678849

@{mmcli_params}	   manufacturer     model     firmware_revision	   imei     mcc     mnc     access_tech    state     operator_name   registration	   plmnid

&{mmcli_cmd_dict}	model=X_RDK_Model    manufacturer=X_RDK_Vendor     access_tech=Interface.1.CurrentAccessTechnology    mcc=Interface.1.X_RDK_PlmnAccess.NetworkInUse.Mcc    mnc=Interface.1.X_RDK_PlmnAccess.NetworkInUse.Mnc    operator_name=Interface.1.X_RDK_PlmnAccess.NetworkInUse.Name      firmware_revision=X_RDK_Firmware.CurrentImageVersion    imei=Interface.1.IMEI    state=X_RDK_Status	plmnid=Interface.1.X_RDK_RadioSignal.PlmnId     registration=Interface.1.X_RDK_PlmnAccess.RoamingStatus


*** Keywords ***
Validate DM params
    [Arguments]     ${params}      ${state}

    FOR    ${param}    IN    @{params}
        ${cmd}=     Set Variable     dmcli eRT getv Device.Cellular.X_RDK_${${state}_cmd_dict.${param}}
        Log    ${cmd}
        ${output}=       send_command        ${cmd}
        ${cm_status}=    get_test_status     ${output}
        Log To Console     val: ${cm_status}
        Should Be Equal As Strings        ${cm_status}        ${${state}_exp_dict.${param}}
    END

Validate Cellular Interface params
    [Arguments]     ${int_params}

    FOR    ${param}    IN    @{int_params}
        ${cmd}=     Set Variable     dmcli eRT getv Device.Cellular.Interface.1.${int_cmd_dict.${param}}
        Log    ${cmd}
        ${output}=       send_command        ${cmd}
        ${cm_status}=    get_test_status     ${output}
        Log To Console     val: ${cm_status}
        Should Be Equal As Strings        ${cm_status}        ${int_exp_dict.${param}}
    END

Validate Cellular Interface X_RDK params
    [Arguments]     ${int_params}     

    FOR    ${param}    IN    @{int_params}

        ${cmd}=     Set Variable     dmcli eRT getv Device.Cellular.Interface.1.X_RDK_${int_cmd_dict.${param}}
        Log    ${cmd}
        ${output}=       send_command        ${cmd}
        ${cm_status}=    get_test_status     ${output}
        Log To Console     val: ${cm_status}
        Should Be Equal As Strings        ${cm_status}        ${int_exp_dict.${param}}
    END

Validate Cellular Interface X_RDK_Plmn params
    [Arguments]     ${int_params}

    FOR    ${param}    IN    @{int_params}

        ${cmd}=     Set Variable     dmcli eRT getv Device.Cellular.Interface.1.X_RDK_Plmn_${int_plmn_cmd_dict.${param}}
        Log    ${cmd}
        ${output}=       send_command        ${cmd}
        ${cm_status}=    get_test_status     ${output}
        Log To Console     val: ${cm_status}
        Should Be Equal As Strings        ${cm_status}        ${int_exp_dict.${param}}
    END

Validate Cellular mmcli params
    [Arguments]     ${exp_mmcli_params}

    FOR    ${param}    IN    @{mmcli_params}
        ${cmd}=     Set Variable     dmcli eRT getv Device.Cellular.${mmcli_cmd_dict.${param}}
        Log    ${cmd}
        ${output}=       send_command        ${cmd}
        ${cm_status}=    get_test_status     ${output}
        Log To Console     val: ${cm_status}
    	Log To Console  val:${exp_mmcli_params['${param}']}
        #Should Be Equal As Strings        ${cm_status}        ${int_exp_dict.${param}}
    END

*** Test Cases ***
test1: Validate Data model params based on state
    [documentation]    Validate data model params
    [tags]          t1      RDK_Status

    ${output}=       send_command        dmcli eRT getv Device.Cellular.X_RDK_Status
    ${out}=    get_test_status     ${output}

    Run Keyword If    '${out}' == 'DEREGISTERED'    Validate DM params    ${params}	deactive 
    ...    ELSE IF    '${out}' == 'REGISTERED'    Validate DM params     ${params}	reg
    ...    ELSE    Validate DM params     ${params}	down


test2: Validate Cellular Interface params 
    [documentation]    Validate cellular interface 1 params
    [tags]          t2      RDK_Status

    ${output}=       send_command        dmcli eRT getv Device.Cellular.Interface.1.Status
    ${out}=    get_test_status     ${output}

    Run Keyword If    '${out}' == 'Up'    Validate Cellular Int params    ${int_params}     
    ...    ELSE    Log To Console   "Down to be added"


test3: Validate Cellular Interface X_RDK params
    [documentation]    Validate cellular interface X_RDK params
    [tags]          t3      RDK_Status

    ${output}=       send_command        dmcli eRT getv Device.Cellular.Interface.1.Status
    ${out}=    get_test_status     ${output}

    Run Keyword If    '${out}' == 'Up'    Validate Cellular Int params    ${int_params}
    ...    ELSE    Log To Console   "Down to be added"


test5: Example program
    [documentation]   example prgm 
    [tags]          t5      RDK_Status

    ${d1}=    get_mmcli_values
    Log To Console  D1:${d1}
    ${data}=	Validate Cellular mmcli params     ${d1}

test4: Validate Cellular Interface Plmn params
    [documentation]    Validate cellular interface 1 Plmn params
    [tags]          t4      RDK_Status

    ${data}=       get_mmcli_values
    Log To Console   val:${data}

    ${val}=       Create Dictionary      ${data}
    Log To Console   val1: ${val}
    #Validate Cellular Int Plmn params    ${int_plmn_params}
    #${d1}=	convert_to_robot_dict    'manufacturer': 'huawei'

    #${data}=    Create Dictionary      'manufacturer'='AA'    plmnid=45
    #Set To Dictionary       ${data}       {'manufacturer': 'huawei', 'model': 'E3372', 'state': 'registered', 'access_tech': 'lte', 'imei': '866785035273852', 'operator_id': '40445', 'operator_name': 'airtel', 'registration': 'home', 'mcc': '404', 'mnc': '45', 'plmnid': '404045'}
    #${data}=    convert_to_robot_dict    ${val}
    Log To Console    ${data}
    Log To Console    ${data}.plmnid
