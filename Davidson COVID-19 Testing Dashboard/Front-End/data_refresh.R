gs4_auth(cache = ".secrets",
         email = "owenbezick@gmail.com")

get_student_data <- function(){
  df_student_data <-
    read_sheet(
      "https://docs.google.com/spreadsheets/d/1Cz-wwT0nyWytRImkzCGDPaY1YrOSILM74mXAgU_eGcE/edit#gid=509821006", sheet = "student"
    )
  return(df_student_data)
}

get_employee_data <- function(){
  df_employee_data <-
    read_sheet(
      "https://docs.google.com/spreadsheets/d/1Cz-wwT0nyWytRImkzCGDPaY1YrOSILM74mXAgU_eGcE/edit#gid=509821006", sheet = "employee"
    )
  return(df_employee_data)
}

get_total_data <- function(){
  df_student_data <- get_student_data()
  df_employee_data <- get_employee_data()
  df_total_data <- rbind(rename(df_student_data, "Number_Tested" = 1), rename(df_employee_data, "Number_Tested" = 1)) %>%
    group_by(date) %>%
    summarise(Number_Tested = sum(Number_Tested), current_cases = sum(current_cases), recovered_cases = sum(recovered_cases))
  return(df_total_data)
}