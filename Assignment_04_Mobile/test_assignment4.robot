*** Settings ***
Library           AppiumLibrary

*** Variables ***
${REMOTE_URL}     http://127.0.0.1:4723
${PLATFORM_NAME}  Android
${DEVICE_NAME}    R5GL11Q83TK    # เช็คจาก adb devices อีกทีนะ
${APP_PACKAGE}    com.avjindersinghsekhon.minimaltodo
${APP_ACTIVITY}   com.example.avjindersinghsekhon.toodle.MainActivity
${AUTOMATION}     UiAutomator2

*** Test Cases ***

TC-01: Add New Task
    [Documentation]    ทดสอบการเพิ่ม Task ใหม่
    Open Application    ${REMOTE_URL}    platformName=${PLATFORM_NAME}    deviceName=${DEVICE_NAME}    appPackage=${APP_PACKAGE}    appActivity=${APP_ACTIVITY}    automationName=${AUTOMATION}
    Wait Until Element Is Visible    id=com.avjindersinghsekhon.minimaltodo:id/addToDoItemFAB    timeout=10s
    Click Element    id=com.avjindersinghsekhon.minimaltodo:id/addToDoItemFAB
    Wait Until Element Is Visible    id=com.avjindersinghsekhon.minimaltodo:id/userToDoEditText
    Input Text       id=com.avjindersinghsekhon.minimaltodo:id/userToDoEditText    My to do task
    Click Element    id=com.avjindersinghsekhon.minimaltodo:id/makeToDoFloatingActionButton
    Wait Until Page Contains    My to do task
    Capture Page Screenshot    tc01_added.png


TC-02: Edit To Do Task
    Click Text    My to do task
    Wait Until Element Is Visible    id=com.avjindersinghsekhon.minimaltodo:id/userToDoEditText    timeout=5s
    
    # 1. ล้างข้อความเก่าออกก่อน (กันเหนียว)
    Clear Text    id=com.avjindersinghsekhon.minimaltodo:id/userToDoEditText
    
    # 2. พิมพ์ข้อความใหม่ลงไปแทน
    Input Text    id=com.avjindersinghsekhon.minimaltodo:id/userToDoEditText    My to do task - Edited
    Click Element    id=com.avjindersinghsekhon.minimaltodo:id/makeToDoFloatingActionButton
    
    # 4. เช็คว่ากลับมาหน้าแรก (เห็นปุ่มบวก)
    Wait Until Element Is Visible    id=com.avjindersinghsekhon.minimaltodo:id/addToDoItemFAB    timeout=10s
    Wait Until Page Contains    My to do task - Edited

    Capture Page Screenshot    tc02_completed.png

TC-03: Delete Task (Swipe to Delete)
    [Documentation]    ใช้ Swipe แบบระบุพิกัด Pixels โดยลากให้ต่ำลงมา (Y=800) 
    # เช็คว่าเห็น Task ก่อนลบ
    Wait Until Page Contains    My to do task - Edited    timeout=10s
    
    # พิกัดสำหรับจอ Samsung (โดยประมาณ):
    # จาก ขวาเกือบสุด (1000) ไป ซ้ายเกือบสุด (50) 
    # ที่ความสูง Y=800 (เพื่อให้มั่นใจว่าโดนตัว Task แน่ๆ ไม่โดน Header)
    # ใส่ duration=1s เพื่อแก้ Warning และให้ลากแบบนุ่มนวล
    Swipe    start_x=1000    start_y=800    end_x=50    end_y=800    duration=1s
    
    Sleep    3s
    
    # ถ้ายังไม่หาย ให้ลอง "ปัดซ้ำ" อีกหนึ่งที (Double Swipe)
    Run Keyword And Ignore Error    Swipe    start_x=1000    start_y=850    end_x=50    end_y=850    duration=1s
    
    # ตรวจสอบผล (ถ้ายังไม่หาย... พี่พอเถอะครับ!)
    Page Should Not Contain Text    My to do task - Edited
    Wait Until Page Contains    You don't have any to do    timeout=10s
    
    Capture Page Screenshot    tc03_completed.png
    #[Teardown]    Close Application