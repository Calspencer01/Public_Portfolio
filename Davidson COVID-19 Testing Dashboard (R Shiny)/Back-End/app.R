library(shinydashboard)
library(shinyWidgets)
library(tidyverse)
library(DT)
library(googlesheets4)

# # designate project-specific cache
# options(gargle_oauth_cache = ".secrets")
# # check the value of the option, if you like
# gargle::gargle_oauth_cache()
# # trigger auth on purpose to store a token in the specified cache
# # a broswer will be opened
# googlesheets4::gs4_auth()
# # see your token file in the cache, if you like
# list.files(".secrets/")
# gs4_deauth()

gs4_auth(
    cache = ".secrets",
    email = "owenbezick@gmail.com"
)

ui <- dashboardPage( skin = "black"
                     , dashboardHeader(title = "Data Input"
                                       , tags$li(
                                           class = "dropdown",
                                           tags$img(
                                               height = "40px",
                                               src = 'Davidson.png',
                                               hspace = "10",
                                               vspace = "5"
                                           )
                                       )
                     )
                     , dashboardSidebar(disable = T)
                     , dashboardBody(
                         includeCSS("www/style.css")
                         , fluidRow(
                             box(width = 12, title = "Inputs", status = "primary"
                                 , box(width = 3, title = "Date:"
                                       , dateInput(inputId = "date", label = "")
                                 )
                                 , box(width = 3, title = "Number Students Tested:"
                                       , numericInput(inputId = "studentsTested", label = "", value = 0)
                                 )
                                 , box(width = 3, title = "New Cases"
                                       , numericInput(inputId = "new", label = "", value = 0)
                                 )
                                 , box(width = 3, title = "Recovered Cases"
                                       , numericInput(inputId = "recovered", label = "", value = 0)
                                 )
                                 , footer = fluidRow(
                                     column(width = 6, actionBttn(inputId = "clear", label = "Clear Inputs", block = T))
                                     , column(width = 6, actionBttn(inputId = "save", label = "Save Inputs", block = T))
                                 )
                             )
                         )
                         , fluidRow(box(width = 12, title = "Current Data", status = "primary"
                                        , DTOutput("df_case_data")
                         )
                         )
                     )
)

# Define server
server <- function(input, output, session) {
    
    df_case_data <- read_sheet("https://docs.google.com/spreadsheets/d/1Cz-wwT0nyWytRImkzCGDPaY1YrOSILM74mXAgU_eGcE/edit#gid=509821006")
    
    reactive <- reactiveValues(df_case_data = df_case_data, date_edit_row = NULL)
    
    clear_results <- function() {
        updateNumericInput(session, "studentsTested", value = "0")
        updateNumericInput(session, "recovered", value = "0")
        updateNumericInput(session, "new", value = "0")
        updateDateInput(session, "date", value = Sys.Date())
    }
    
    observeEvent(input$clear, {
        clear_results()
    })
    # Input Data ----
    observeEvent(input$save, {
        entry_date <- as.character(input$date)
        ls_dates <- df_case_data$date
        if (entry_date %in% ls_dates){
            showModal(modalDialog(title = "Date Check", size = "m",
                                  fluidRow(box(width = 12
                                               , paste("It looks like", input$date, "is already in the data base." )
                                  )
                                  )
                                  , footer = fluidRow(
                                      column(width = 6, actionBttn(inputId = "goBack", label = "Go Back", block = T))
                                      , column(width = 6, actionBttn(inputId = "editDateEntry", label = "Edit Values For That Date", block = T))
                                  )
            )
            )
            
        } else{
            showModal(modalDialog(title = "Please Verify Inputs", size = "l"
                                  , fluidRow(
                                      box(width = 3, title = "Date", input$date)
                                      , box(width = 3, title = "Students Tested", input$studentsTested)
                                      , box(width = 3, title = "New Cases", input$new)
                                      , box(width = 3, title = "Recovered Cases", input$recovered)
                                  )
                                  , footer = fluidRow(
                                      column(width = 6, actionBttn(inputId = "goBack", label = "Back", block = T))
                                      , column(width = 6, actionBttn(inputId = "verifiedSave", label = "Verify Inputs", block = T))
                                  )
            )
            )
        }
    })
    # Save Data ----
    observeEvent(input$verifiedSave, {
        df_case_data <- reactive$df_case_data
        current_cases <- tail(df_case_data, 1)$current_cases # get last row for current case number
        inputDF <- tibble("number_students_tested" = input$studentsTested
                          ,"date" = as.character(input$date)
                          , "new_cases" = input$new
                          , "current_cases" = current_cases - input$recovered + input$new # calculate new current case total
                          , "recovered_cases" = input$recovered
        )
        sheet_append("https://docs.google.com/spreadsheets/d/1Cz-wwT0nyWytRImkzCGDPaY1YrOSILM74mXAgU_eGcE/edit#gid=509821006", inputDF)
        reactive$df_case_data = rbind(df_case_data, inputDF)
        clear_results()
        removeModal()
    })
    # Edit data ----
    observeEvent(input$editDateEntry, {
        removeModal()
        
        entry_date <- as.character(input$date)
        
        df_case_data <- reactive$df_case_data
        
        reactive$date_edit_row <- df_case_data %>%
            rowid_to_column("ID") %>%
            filter(date == entry_date)
        
        
        row <- reactive$date_edit_row
        
        showModal(modalDialog(title = paste("Edit Date:", entry_date), size = "l"
                              , fluidRow(
                                  box(width = 3, title = "Students Tested:"
                                      , numericInput(inputId = "editStudentsTestedD", label = "", value = row$number_students_tested)
                                  )
                                  , box(width = 3, title = "New Cases"
                                        , numericInput(inputId = "editNewD", label = "", value = row$new_cases)
                                  )
                                  , box(width = 3, title = "Recovered Cases"
                                        , numericInput(inputId = "editRecoveredD", label = "", value = row$recovered_cases)
                                  )
                                  , box(width = 3, title = "Current Cases"
                                        , numericInput(inputId = "editCurrentD", label = "", value = row$current_cases)
                                  )
                              )
                              , footer = fluidRow(
                                  column(width = 6, actionBttn(inputId = "goBack", label = "Go Back", block = T))
                                  , column(width = 6, actionBttn(inputId = "saveEditD", label = "Save Edits", block = T))
                              )
                              
        )
        )
        
    })
    # Save Edit ----
    observeEvent(input$saveEditD,{ 
        row <- reactive$date_edit_row
        rowNumber <- row$ID
        df_case_data <- reactive$df_case_data
        editRow <- list("number_students_tested" = input$editStudentsTestedD
                        ,"date" = row$date
                        , "new_cases" = input$editNewD
                        , "current_cases" = input$editCurrentD # calculate new current case total
                        , "recovered_cases" = input$editRecoveredD
                       
        )
        df_case_data[rowNumber, ] <- editRow
        reactive$df_case_data <- df_case_data
        sheet_write(df_case_data, ss = "https://docs.google.com/spreadsheets/d/1Cz-wwT0nyWytRImkzCGDPaY1YrOSILM74mXAgU_eGcE/edit#gid=509821006", sheet = "student")
        removeModal()
    })
    

    
    observeEvent(input$goBack, {
        removeModal()
    })
    
    # DT output ----
    output$df_case_data <- renderDT({
        df <- reactive$df_case_data
        df <- df %>%
            rename(`Date` = date
                   , `Number of Students Tested` = number_students_tested
                   , `New Cases` = new_cases
                   , `Recovered Cases` = recovered_cases
                   , `Current Cases`= current_cases
            )
        datatable(df, rownames = F, selection = "single")
    })
    
    # Edit Entry Modal ----
    # TODO: create a module for editing a row ----
    observeEvent(input$df_case_data_rows_selected,{
        df_case_data <- reactive$df_case_data
        row <- df_case_data[input$df_case_data_rows_selected,]
        showModal(
            modalDialog(
                title = "Edit Entry", size = "l"
                , fluidRow(
                    box(width = 6, title = "Date:"
                        , dateInput(inputId = "editDate", label = "", value = row$date)
                    )
                    , box(width = 6, title = "Students Tested:"
                          , numericInput(inputId = "editStudentsTested", label = "", value = row$number_students_tested)
                    )
                )
                , fluidRow(
                    box(width = 4, title = "New Cases"
                        , numericInput(inputId = "editNew", label = "", value = row$new_cases)
                    )
                    , box(width = 4, title = "Recovered Cases"
                          , numericInput(inputId = "editRecovered", label = "", value = row$recovered_cases)
                    )
                    , box(width = 4, title = "Current Cases"
                          , numericInput(inputId = "editCurrent", label = "", value = row$current_cases)
                    )
                )
                , footer = fluidRow(
                    column(width = 6, actionBttn(inputId = "cancelEdit", label = "Cancel Edits", block = T))
                    , column(width = 6, actionBttn(inputId = "saveEdit", label = "Save Edits", block = T))
                )
            )
        )
    })
    
    observeEvent(input$cancelEdit,{
        removeModal()
    })
    
    observeEvent(input$saveEdit,{
        rowNumber <- input$df_case_data_rows_selected
        df_case_data <- reactive$df_case_data
        current_cases <- tail(df_case_data, 1)$current_cases #get last row for current case number
        editRow <- list("number_students_tested" = input$editStudentsTested
                        ,"date" = as.character(input$editDate)
                        , "new_cases" = input$editNew
                        , "current_cases" = input$editCurrent # calculate new current case total
                        , "recovered_cases" = input$editRecovered
                        
        )
        df_case_data[rowNumber, ] <- editRow
        reactive$df_case_data <- df_case_data
        sheet_write(df_case_data, ss = "https://docs.google.com/spreadsheets/d/1Cz-wwT0nyWytRImkzCGDPaY1YrOSILM74mXAgU_eGcE/edit#gid=509821006", sheet = "student")
        removeModal()
    })
    
}

# Run the application
shinyApp(ui = ui, server = server)
