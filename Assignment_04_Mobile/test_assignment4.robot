*** Settings ***
Library           AppiumLibrary
Library           DateTime
Library           Collections
Library           String

*** Variables ***
${REMOTE_URL}     http://127.0.0.1:4723
${PLATFORM_NAME}  Android
${UDID}           R5GL11Q83TK
${DEVICE_NAME}    R5GL11Q83TK
${APP_PACKAGE}    com.avjindersinghsekhon.minimaltodo
${APP_ACTIVITY}   com.example.avjindersinghsekhon.toodle.MainActivity

*** Keywords ***
Open Minimal App Normal Mode
    Open Application    ${REMOTE_URL}    
    ...    platformName=${PLATFORM_NAME}    
    ...    deviceName=${DEVICE_NAME}    
    ...    appPackage=${APP_PACKAGE}    
    ...    appActivity=${APP_ACTIVITY}
    ...    noReset=true        # <--- เพิ่มตัวนี้: ไม่ล้างข้อมูล
    ...    fullReset=false     # <--- เพิ่มตัวนี้: ไม่ลบแอปลงใหม่
    ...    automationName=UiAutomator2

Get Calculated Date And Time Separately
    ${now}=              Get Current Date
    ${target_dt}=        Add Time To Date    ${now}    1 hour    result_format=datetime
    ${month}=            Convert Date    ${target_dt}    result_format=%b
    ${day_raw}=          Convert Date    ${target_dt}    result_format=%d
    ${day_clean}=        Convert To Integer    ${day_raw}
    ${year}=             Convert Date    ${target_dt}    result_format=%Y
    ${final_date}=       Set Variable    ${month} ${day_clean}, ${year}
    ${hour_raw}=         Convert Date    ${target_dt}    result_format=%H
    ${hour_clean}=       Convert To Integer    ${hour_raw}
    ${final_time}=       Set Variable    ${hour_clean}:00
    RETURN               ${final_date}    ${final_time}

*** Test Cases ***
TC-01: Create Task Without Reminder
    [Documentation]    Verify that a user can successfully create a new task without setting a reminder.
    ${task_name1}=       Set Variable    Create Task Without Reminder
    Open Application    ${REMOTE_URL}    platformName=Android    automationName=UiAutomator2
    ...    udid=${UDID}    deviceName=Samsung_Phone
    ...    appPackage=${APP_PACKAGE}    appActivity=${APP_ACTIVITY}
    ...    noReset=false    fullReset=false
    Wait Until Element Is Visible    xpath=//*[contains(@resource-id,'addToDoItemFAB')]    timeout=20s
    Click Element    xpath=//*[contains(@resource-id,'addToDoItemFAB')]
    Wait Until Element Is Visible    xpath=//*[contains(@resource-id,'userToDoEditText')]    timeout=10s
    Input Text    xpath=//*[contains(@resource-id,'userToDoEditText')]    ${task_name1}
    Hide Keyboard
    Click Element    xpath=//*[contains(@resource-id,'makeToDoFloatingActionButton')]
    Wait Until Page Contains    ${task_name1}    timeout=15s
    Capture Page Screenshot    tc02_create_task.png

TC-02: Quick Set Reminder with Calculated Format
    [Documentation]     Verify that a user can create a new task with a specific date and time reminder.
    ${task_name2}=       Set Variable    Create Task With Set Reminder
    ${exp_date}    ${exp_time}=    Get Calculated Date And Time Separately
    Wait Until Element Is Visible    xpath=//*[contains(@resource-id,'addToDoItemFAB')]    timeout=10s
    Click Element    xpath=//*[contains(@resource-id,'addToDoItemFAB')]
    Input Text    xpath=//*[contains(@resource-id,'userToDoEditText')]    ${task_name2}
    Hide Keyboard
    Click Element    xpath=//*[contains(@resource-id,'toDoHasDateSwitchCompat')]
    #Sleep    2s
    Click Element    xpath=//*[contains(@resource-id,'makeToDoFloatingActionButton')]
    Wait Until Page Contains    ${task_name2}    timeout=15s
    Wait Until Page Contains    ${exp_date}      timeout=10s
    Wait Until Page Contains    ${exp_time}      timeout=10s
    Capture Page Screenshot    tc02_create_reminder_task.png

TC-03: Edit Task Name and Verify Format
    [Documentation]     Verify that editing an existing task name updates correctly and maintains the format.
    ${task_name3}=       Set Variable    Edit Task With Set Reminder
    ${target_to_edit}=   Set Variable    Create Task Without Reminder
    ${exp_date_edit}    ${exp_time_edit}=    Get Calculated Date And Time Separately
    Wait Until Page Contains    ${target_to_edit}    timeout=15s
    Click Text    ${target_to_edit}
    Clear Text    xpath=//*[contains(@resource-id,'userToDoEditText')]
    Input Text    xpath=//*[contains(@resource-id,'userToDoEditText')]    ${task_name3}
    Hide Keyboard
    Sleep    1s
    Click Element    xpath=//*[contains(@resource-id,'toDoHasDateSwitchCompat')]
    Sleep    1s
    Click Element    xpath=//*[contains(@resource-id,'makeToDoFloatingActionButton')]
    Wait Until Page Contains    ${task_name3}         timeout=15s
    Wait Until Page Contains    ${exp_date_edit}      timeout=10s
    Wait Until Page Contains    ${exp_time_edit}      timeout=10s
    Capture Page Screenshot    tc03_edit_reminder_task.png

TC-04: Delete Task (Swipe to Delete)
    [Documentation]    Verify the "Swipe to Delete" functionality and ensure the task is removed from the list.
    ${target_edit}=    Set Variable    Edit Task With Set Reminder

    Wait Until Element Is Visible    xpath=//*[contains(@text,'${target_edit}')]    timeout=15s
    ${location}=    Get Element Location    xpath=//*[contains(@text,'${target_edit}')]
    ${dynamic_y}=    Evaluate    ${location['y']} + 50
    Log To Console    \n[DEBUG] Swiping at Y: ${dynamic_y} for Task: ${target_edit}
    Swipe    start_x=900    start_y=${dynamic_y}    end_x=50    end_y=${dynamic_y}    duration=1s
    #Sleep    2s
    Page Should Not Contain Text    ${target_edit}
    Capture Page Screenshot    tc03_delete_dynamic.png

TC-05: Undo Delete Specific Task
    [Documentation]    Verify that a deleted task can be restored using the "Undo" SnackBar notification.
    ${target_create}=    Set Variable    Create Task With Set Reminder
    
    Wait Until Element Is Visible    xpath=//*[contains(@text,'${target_create}')]    timeout=10s
    ${location}=    Get Element Location    xpath=//*[contains(@text,'${target_create}')]
    ${dynamic_y}=    Evaluate    ${location['y']} + 50

    Swipe    start_x=900    start_y=${dynamic_y}    end_x=50    end_y=${dynamic_y}    duration=1s
    
    Wait Until Element Is Visible    xpath=//*[contains(@text,'UNDO')]    timeout=5s
    Click Element    xpath=//*[contains(@text,'UNDO')]
    
    Wait Until Page Contains    ${target_create}    timeout=10s
    Capture Page Screenshot    tc04_undo_dynamic_success.png
    Log To Console    \n[SUCCESS] Undo for '${target_create}' completed!

TC-06: Create New Task and Discard
    [Documentation]    Verify that discarding a new task creation (Back/Cancel) does not add it to the list.
    ${temp_task_name}=    Set Variable    Discard This New Task
    
    Wait Until Element Is Visible    xpath=//*[contains(@resource-id,'addToDoItemFAB')]    timeout=10s
    Click Element    xpath=//*[contains(@resource-id,'addToDoItemFAB')]
    
    Wait Until Element Is Visible    xpath=//*[contains(@resource-id,'userToDoEditText')]    timeout=10s
    Input Text    xpath=//*[contains(@resource-id,'userToDoEditText')]    ${temp_task_name}
    Hide Keyboard
    
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton[@content-desc="Navigate up"]    timeout=5s
    Click Element    xpath=//android.widget.ImageButton[@content-desc="Navigate up"]
    #Sleep    2s
    Page Should Not Contain Text    ${temp_task_name}
    
    Capture Page Screenshot    tc06_discard_new_task.png

TC-07: Create Task Without Title (Empty Name)
    [Documentation]    Verify that the system prevents creating a task with an empty title (Validation check).
    
    Wait Until Element Is Visible    xpath=//*[contains(@resource-id,'addToDoItemFAB')]    timeout=10s
    Click Element    xpath=//*[contains(@resource-id,'addToDoItemFAB')]
    
    Wait Until Element Is Visible    xpath=//*[contains(@resource-id,'makeToDoFloatingActionButton')]    timeout=10s
    Click Element    xpath=//*[contains(@resource-id,'makeToDoFloatingActionButton')]
    
    Wait Until Element Is Visible    xpath=//*[contains(@resource-id,'addToDoItemFAB')]    timeout=10s
    
    Capture Page Screenshot    tc07_empty_task_clean.png

TC-08: Smart Polling Notification Check
    [Documentation]    Verify that all existing tasks are persistent and correctly displayed after restarting the app.
    
    ${rand}=         Evaluate    random.randint(1000, 9999)    modules=random
    ${task_name}=    Set Variable    Create_Task_WithNoti_${rand}
    
    Wait Until Element Is Visible    xpath=//*[contains(@resource-id, "addToDoItemFAB")]    timeout=15s
    Click Element    xpath=//*[contains(@resource-id, "addToDoItemFAB")]
    Input Text       xpath=//*[contains(@resource-id, "userToDoEditText")]    ${task_name}
    Click Element    xpath=//*[contains(@resource-id, "toDoHasDateSwitchCompat")]
    
    Click Element    xpath=//*[contains(@resource-id, "makeToDoFloatingActionButton")]
    
    Wait Until Page Contains    ${task_name}    timeout=10s
    
    ${scheduled_time}=    Get Text    xpath=//*[@text="${task_name}"]/following-sibling::android.widget.TextView
    Log To Console    \n[CONFIRMED] Task: ${task_name} | Set for: ${scheduled_time}

    ${target_min}=    Convert Date    ${scheduled_time}    date_format=%b %d, %Y %H:%M    result_format=%Y-%m-%d %H:%M
    Log To Console    \n[INFO] Target Comparison String: ${target_min}

    ${found}=         Set Variable    ${False}
    ${attempt}=       Set Variable    1

    WHILE    '${found}' == 'False' and ${attempt} <= 120
        ${current_now}=    Get Current Date    result_format=%Y-%m-%d %H:%M
        ${time_display}=   Get Current Date    result_format=%H:%M:%S

        IF    '${current_now}' < '${target_min}'
            Log To Console    [${time_display}] Attempt ${attempt}: Still early. (Now: ${current_now} | Target: ${target_min})
            Sleep    30s
        ELSE
            Log To Console    [${time_display}] Attempt ${attempt}: MATCH! Checking Notifications...
            Open Notifications
            Sleep    3s
            
            ${found}=    Run Keyword And Return Status    
            ...    Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="${task_name}"]    timeout=3s
            
            IF    '${found}' == 'True'
                Log To Console    \n[SUCCESS] FOUND IT! "${task_name}" at ${time_display}
                Capture Page Screenshot    final_8_8_pass.png
                Press Keycode    4
                BREAK
            END
            
            Log To Console    Not in tray yet, retrying...
            Press Keycode    4
            Sleep    30s
        END
        ${attempt}=    Evaluate    ${attempt} + 1
    END
    
    Run Keyword If    '${found}' == 'False'    Fail    Notification for "${task_name}" missed after 1 hour.
TC-09: Verify All Tasks Persist After Re-opening
    [Documentation]    Verify that multiple tasks can be managed and displayed correctly in the main list view.
    
    Wait Until Element Is Visible    xpath=//*[contains(@resource-id, "toDoListItemTextview")]    timeout=15s
    
    ${task_elements}=    Get Webelements    xpath=//*[contains(@resource-id, "toDoListItemTextview")]
    ${before_list}=    Create List
    
    FOR    ${el}    IN    @{task_elements}
        ${name}=    Get Text    ${el}
        Append To List    ${before_list}    ${name}
    END

    Terminate Application    ${APP_PACKAGE}
    Sleep    3s
    
    Activate Application     ${APP_PACKAGE}
    Wait Until Element Is Visible    xpath=//*[contains(@resource-id, "toDoListItemTextview")]    timeout=15s

    Log To Console    [STEP 4] Verifying consistency...
    FOR    ${task_item}    IN    @{before_list}
        Page Should Contain Text    ${task_item}
        Log To Console    - Verified: "${task_item}" [STILL EXISTS]
    END
    Capture Page Screenshot    persistence_full_verify.png

TC-10: Verify Night Mode (Final Victory)
    [Documentation]    Verify Night Mode toggle functionality and ensure the UI theme switches correctly.
    
    Wait Until Element Is Visible    xpath=//android.widget.ImageView[@content-desc="More options"]    timeout=10s
    Click Element    xpath=//android.widget.ImageView[@content-desc="More options"]
    
    Wait Until Page Contains    Settings    timeout=5s
    Click Text    Settings

    Wait Until Element Is Visible    class=android.widget.CheckBox    timeout=10s
    
    ${is_checked_before}=    Get Element Attribute    class=android.widget.CheckBox    checked

    Click Element    class=android.widget.CheckBox
    Sleep    3s    

    ${is_checked_after}=    Get Element Attribute    class=android.widget.CheckBox    checked

    Capture Page Screenshot    night_mode_visual_confirm.png

    IF    '${is_checked_before}' != '${is_checked_after}'
        Log To Console    \n[RESULT] PASS: Checkbox toggled successfully!
    ELSE
        Fail    FAIL: Checkbox status did not change.
    END

    Press Keycode    4
    Capture Page Screenshot    main_screen_night_mode.png