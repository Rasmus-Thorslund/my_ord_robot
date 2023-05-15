*** Settings ***
Documentation       Template robot main suite.
Library    RPA.Browser.Selenium    auto_close=${TRUE}
Library    RPA.Desktop
Library    RPA.Tables
Library    RPA.Excel.Application
Library    RPA.HTTP
Library    RPA.PDF
Library    Dialogs
Library    RPA.Robocorp.WorkItems
Library    RPA.Archive




*** Tasks ***

Place Robot order
    Open Website
    Download CSV
    Fill and submit the form using data from the CSV file
    Create archive and populate
    


*** Keywords ***

Open Website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
   

       
Download CSV
    Download  https://robotsparebinindustries.com/orders.csv    overwrite=${True}

   
Fill and submit the form using data from the CSV file
   
    ${order_table}=    Read table from CSV    orders.csv
    
   FOR    ${ORDER}    IN    @{order_table}
    
    Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    
    #Fill in form
    Select From List By Value    //*[@id="head"]    ${ORDER}[Head]
    Click Element    //*[@id="root"]/div/div[1]/div/div[1]/form/div[2]/div/div[${ORDER}[Body]]/label
    Wait Until Element Is Enabled    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${ORDER}[Legs]
    Input Text    //*[@id="address"]    ${ORDER}[Address]
        
    #Preview order
    Click Button    //*[@id="preview"]


    #Order Robot
        Click Button    id:order
    FOR    ${i}    IN RANGE    9999999
        ${success} =    Is Element Visible    id:receipt
        Exit For Loop If    ${success}
        Click Button    id:order
    END
  


    #Generate PDF receipt
    Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipt${ORDER}[Order number].pdf
    
    Screenshot    //*[@id="robot-preview-image"]    ${OUTPUT_DIR}${/}robot${ORDER}[Order number].PNG

    ${receiptPDF}    Open PDF    ${OUTPUT_DIR}${/}receipt${ORDER}[Order number].pdf
    ${robotPNG}    Create List    ${OUTPUT_DIR}${/}robot${ORDER}[Order number].PNG

    ...    ${OUTPUT_DIR}${/}receipt${ORDER}[Order number].pdf

    Add Files To Pdf    ${robotPNG}    ${OUTPUT_DIR}${/}receipt${ORDER}[Order number].pdf
    Close Pdf    ${receiptPDF}
    Wait Until Keyword Succeeds    1min    5 sec    Click Element When Visible    //*[@id="order-another"]
    

    
   END


Create archive and populate
   
   Archive Folder With ZIP   ${OUTPUT_DIR}    ${OUTPUT_DIR}${/}receipts.zip   recursive=True  include=*.pdf  #exclude=/.*
   @{files}                  List Archive             ${OUTPUT_DIR}${/}receipts.zip
   FOR  ${file}  IN  ${files}
      Log  ${file}
   END
   