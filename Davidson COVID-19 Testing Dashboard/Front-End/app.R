#'
#' Dashboard to display campus infection data
#'
#' Authors: Calvin Spencer & Owen Bezick
#'
#'

library(shiny)
library(shinydashboard)
library(echarts4r)
library(tidyverse)
library(googlesheets4)
library(dplyr)
library(lubridate)
library(DescTools)
library(modules)
# # # # designate project-specific cache
# options(gargle_oauth_cache = ".secrets")
# # # # check the value of the option, if you like
# gargle::gargle_oauth_cache()
# # # # trigger auth on purpose to store a token in the specified cache
# # # # a broswer will be opened
# googlesheets4::gs4_auth()
# # # # see your token file in the cache, if you like
# list.files(".secrets/")
# gs4_deauth()

source("utils/tagsHead.R", local = TRUE)
source("TabPage.R", local = TRUE)
source("Graphics.R", local = TRUE)
source("Modal.R", local = TRUE)
source("data_refresh.R", local = TRUE)

gs4_auth(cache = ".secrets",
         email = "owenbezick@gmail.com")
ui <- dashboardPage(
   skin = "black"
   , dashboardHeader(
     title = "Campus COVID-19 Dashboard"
    ,titleWidth = "25%"
    ,tags$li(
      class = "dropdown",
      tags$img(
        height = "40px",
        src = 'Davidson.png',
        hspace = "10",
        vspace = "5"
      )
    )
  )
  , dashboardSidebar(disable = T),
 #

 dashboardBody(tagsHead()
   , includeCSS("Style.css")
   , tabsetPanel(
     type = "tabs",
     page_ui("Total"),
     page_ui("Student"),
     page_ui("Employee")
  )
 )
)

# Data Frames:
#   df_campus_data
#       All campus current, recovered, & new cases
#   df_current_campus
#       df_campus_data filterd by today
#   df_week_campus
#       df_campus_data filtered by current week (starting Sunday)
#
# Outputs x 3 (total, student, employee):
#   text_last_update
#     Text output of date last updated
#   text_current_cases
#     Text (echarts e_title()) output of # current cases (eventually- positive tests for now)
#   text_current_students
#     Text (echarts e_title()) output of # students living on campus
##   text_campus_rate
##    Text output of # current cases / number of students on campus (not in use)
#   chart_cases_new
#     ECharts bar graph over time of new cases
#   chart_cases_current
#     ECharts bar graph over time of active cases
#   chart_cases_recovered
#     ECharts bar graph over time of recovered cases
#   chart_current_pie
#     ECharts pie graph of current cases
#
# Other:
#   red, black: Davidson Colors
#   main, sub: Main & sub text on dashboard
#   testingPopulation: (temporary) number of students being tested
#   wholeNumFormatter: JS function to only return the string with whole numbers (used on axis labels)
#   barMax: Max height of y axis



server <- function(input, output) {
  df_student_data <- get_student_data()

  df_employee_data <- get_employee_data()
  
  df_total_data <- get_total_data()
  
  # Modal ---------------------------------
  observeEvent("shiny:connected", {
    showModal(snapshot())
  })

  observeEvent(input$closeModal,{
    removeModal()
  })


  df_campus_data <-
    df_student_data %>%
    mutate(date = as.Date(date))


  maxDate <- df_campus_data %>%
    summarise(max = max(date))

  maxCases <- df_campus_data %>%
    summarise(max = max(current_cases))

  # Davidson Marketing Toolbox
  # https://marketing-toolbox.davidson.edu/branding-assets/brand-guide/
  # Red: HEX: #ac1a2f RGB: 172,26,47
  # Black: HEX: #000000 RGB: 0,0,0



  barMax <- RoundTo(maxCases$max[[1]]*1.5, 5)

  df_current_campus <- df_campus_data %>%
    filter(date == maxDate) # filter by the most recent data

  # ______________---------------------------------
  # Modal Outputs ---------------------------------

  #   total_value ----------
  output$total_value <- renderValueBox({
    posCases <- df_current_campus$current_cases[[1]]

    valueBox(
      posCases,
      "total active cases"
    )
  })

  #  student_value ----------
  output$student_value <- renderValueBox({
    posCases <- df_current_campus$current_cases[[1]]

    valueBox(
      posCases,
      "active student cases"
    )
  })

  #   employee_value ----------
  output$employee_value <- renderValueBox({
    posCases <- df_current_campus$current_cases[[1]]

    valueBox(
      posCases,
      "active student-facing employee cases"
    )
  })



  # ______________---------------------------------
  # Total Outputs ---------------------------------

  #   text_last_update_total ----------
  output$text_last_update_total <- renderText({
    paste0("Last updated ", format(maxDate$max[[1]], "%A, %B %d"))
  })

  #   text_current_cases_total ----------
  output$text_current_cases_total <- renderEcharts4r({
    type <- "On-site student"
    posCases <- df_current_campus$current_cases[[1]]
    label <- paste0(type, "s currently testing positive")

    if (posCases == 1){
      label <- paste0(type, " currently testing positive")
    }

    text_current_cases(df_current_campus, posCases, label)
  })

  #   text_current_population_total ----------
  output$text_current_population_total <-renderEcharts4r({

    label <- "On-site students being tested weekly"

    population <- df_current_campus$number_students_tested[[1]]

    text_current_population(df_current_campus, population, label)
  })


  #   chart_cases_new_total ----------
  output$chart_cases_new_total <- renderEcharts4r({
    df <- df_campus_data %>%
      mutate(dateFormatted = format(date, "%d %b")) %>%
      mutate(cases = new_cases) %>%
      select(cases, dateFormatted)

    bar_time_series(df, "New", barMax)

  })
  #   chart_cases_current_total ----------
  output$chart_cases_current_total <-renderEcharts4r({
    df <- df_campus_data %>%
      mutate(dateFormatted = format(date, "%d %b")) %>%
      mutate(cases = current_cases) %>%
      mutate(color = red) %>%
      select(cases, dateFormatted, color)

    bar_time_series(df, "Current", barMax)

  })
  #   chart_cases_recovered_total ----------
  output$chart_cases_recovered_total <- renderEcharts4r({
    df <- df_campus_data %>%
      mutate(dateFormatted = format(date, "%d %b")) %>%
      mutate(cases = recovered_cases) %>%
      select(cases, dateFormatted)

    bar_time_series(df, "Recovered", barMax)

  })

  #   chart_current_pie_total ----------
  output$chart_current_pie_total <- renderEcharts4r({
    testingPopulation <- df_current_campus$number_students_tested[[1]]
    posCases <- df_current_campus$current_cases[[1]]

    percCases <- paste0(100 * (.0001 * round( 10000 * posCases / testingPopulation)), "%")

    `People` <- c(posCases, testingPopulation - posCases)
    label <- c("Testing Positive", "Testing Negative")
    color <- c(black, red)

    df_pie <- data.frame(`People`, label, color)

    subhead <- paste0("Active on-site student cases / On-site students being tested weekly")

    pie_chart(df_pie, "student", percCases, subhead, color)
  })



  # ______________---------------------------------
  # Student Outputs ---------------------------------

  #   text_last_update_student ----------
  output$text_last_update_student <- renderText({
    paste0("Last updated ", format(maxDate$max[[1]], "%A, %B %d"))
  })

  #   text_current_cases_student ----------
  output$text_current_cases_student <- renderEcharts4r({
    type <- "On-site student"
    posCases <- df_current_campus$current_cases[[1]]
    label <- paste0(type, "s currently testing positive")

    if (posCases == 1){
      label <- paste0(type, " currently testing positive")
    }

    text_current_cases(df_current_campus, posCases, label)
  })

  #   text_current_population_student ----------
  output$text_current_population_student <-renderEcharts4r({

    label <- "On-site students being tested weekly"

    population <- df_current_campus$number_students_tested[[1]]

    text_current_population(df_current_campus, population, label)
  })


  #   chart_cases_new_student ----------
  output$chart_cases_new_student <- renderEcharts4r({
    df <- df_campus_data %>%
      mutate(dateFormatted = format(date, "%d %b")) %>%
      mutate(cases = new_cases) %>%
      select(cases, dateFormatted)

   bar_time_series(df, "New", barMax)

  })
  #   chart_cases_current_student ----------
  output$chart_cases_current_student <-renderEcharts4r({
    df <- df_campus_data %>%
      mutate(dateFormatted = format(date, "%d %b")) %>%
      mutate(cases = current_cases) %>%
      mutate(color = red) %>%
      select(cases, dateFormatted, color)

    bar_time_series(df, "Current", barMax)

  })
  #   chart_cases_recovered_student ----------
  output$chart_cases_recovered_student <- renderEcharts4r({
    df <- df_campus_data %>%
      mutate(dateFormatted = format(date, "%d %b")) %>%
      mutate(cases = recovered_cases) %>%
      select(cases, dateFormatted)

    bar_time_series(df, "Recovered", barMax)

  })

  #   chart_current_pie_student ----------
  output$chart_current_pie_student <- renderEcharts4r({
    testingPopulation <- df_current_campus$number_students_tested[[1]]
    posCases <- df_current_campus$current_cases[[1]]

    percCases <- paste0(100 * (.0001 * round( 10000 * posCases / testingPopulation)), "%")

    `People` <- c(posCases, testingPopulation - posCases)
    label <- c("Testing Positive", "Testing Negative")
    color <- c(black, red)

    df_pie <- data.frame(`People`, label, color)

    subhead <- paste0("Active on-site student cases / On-site students being tested weekly")

    pie_chart(df_pie, "student", percCases, subhead, color)
  })

  # ______________---------------------------------
  # Employee Outputs ---------------------------------

  #   text_last_update_employee ----------
  output$text_last_update_employee <- renderText({
    paste0("Last updated ", format(maxDate$max[[1]], "%A, %B %d"))
  })

  #   text_current_cases_employee ----------
  output$text_current_cases_employee <- renderEcharts4r({
    type <- "On-site student"
    posCases <- df_current_campus$current_cases[[1]]
    label <- paste0(type, "s currently testing positive")

    if (posCases == 1){
      label <- paste0(type, " currently testing positive")
    }

    text_current_cases(df_current_campus, posCases, label)
  })

  #   text_current_population_employee ----------
  output$text_current_population_employee <-renderEcharts4r({

    label <- "On-site students being tested weekly"

    population <- df_current_campus$number_students_tested[[1]]

    text_current_population(df_current_campus, population, label)
  })


  #   chart_cases_new_employee ----------
  output$chart_cases_new_employee <- renderEcharts4r({
    df <- df_campus_data %>%
      mutate(dateFormatted = format(date, "%d %b")) %>%
      mutate(cases = new_cases) %>%
      select(cases, dateFormatted)

    bar_time_series(df, "New", barMax)

  })
  #   chart_cases_current_employee ----------
  output$chart_cases_current_employee <-renderEcharts4r({
    df <- df_campus_data %>%
      mutate(dateFormatted = format(date, "%d %b")) %>%
      mutate(cases = current_cases) %>%
      mutate(color = red) %>%
      select(cases, dateFormatted, color)

    bar_time_series(df, "Current", barMax)

  })
  #   chart_cases_recovered_employee ----------
  output$chart_cases_recovered_employee <- renderEcharts4r({
    df <- df_campus_data %>%
      mutate(dateFormatted = format(date, "%d %b")) %>%
      mutate(cases = recovered_cases) %>%
      select(cases, dateFormatted)

    bar_time_series(df, "Recovered", barMax)

  })

  #   chart_current_pie_employee ----------
  output$chart_current_pie_employee <- renderEcharts4r({
    testingPopulation <- df_current_campus$number_students_tested[[1]]
    posCases <- df_current_campus$current_cases[[1]]

    percCases <- paste0(100 * (.0001 * round( 10000 * posCases / testingPopulation)), "%")

    `People` <- c(posCases, testingPopulation - posCases)
    label <- c("Testing Positive", "Testing Negative")
    color <- c(black, red)

    df_pie <- data.frame(`People`, label, color)

    subhead <- paste0("Active on-site student cases / On-site students being tested weekly")

    pie_chart(df_pie, "student", percCases, subhead, color)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
