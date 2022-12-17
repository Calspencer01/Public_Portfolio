snapshot <- function (){
  modalDialog(title= "Campus Snapshot", 
              size = "l",
              fluidRow(
                box(width = 12,
                  valueBoxOutput("total_value", width = 6)
                )
              ),
              fluidRow(
                box(width = 12,
                  valueBoxOutput("student_value", width = 6)
                )
              ),
              fluidRow(
                box(width = 12,
                  valueBoxOutput("employee_value", width = 6)
                )
              ),
              
              footer = actionButton(
                      inputId = "closeModal",
                      label = "Go to Dashboard",
                      style = "fill",
                      color = "danger",
                      size = "sm",
                      block = FALSE,
                      no_outline = TRUE
                    )
              )
}