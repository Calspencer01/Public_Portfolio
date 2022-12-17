
page_ui <- function(type){
  
  davInfoBox <- function(){
    return( tags$div( class = "info-box",
                                    tags$b("New Cases"), 
                                    " = New positive cases identified between 4 pm on previous date and 4 pm on current date",
                                    tags$br(),#tags$br(),
                                    tags$b("Active Cases"), 
                                    " = Students with ongoing, confirmed cases of COVID-19",
                                    tags$br(),#tags$br(),
                                    tags$b("Recovered Cases"), 
                                    " = Students who no longer have COVID-19"#,
                                    # tags$br(),tags$br(),
                                    #tags$b("On-Site Students"), 
                                    #" = Students who are living on or off campus, excluding remote-only students"
                                    
     )
    )
  }
  
  #adds type to chart id
  getID <- function(id){
    return (paste0(id, tolower(type)))
  }
    tabPanel(type,
      fluidRow(
        column(6,
               # box(width = 6, status = "primary",
               fluidRow(
                 box(
                   width = 6,
                   status = "primary",
                   echarts4rOutput(getID("text_current_cases_"), height = 100)
                 )
                 ,
                 box(
                   width = 6,
                   status = "primary",
                   echarts4rOutput(getID("text_current_population_"), height = 100)
                 )
               ),
               fluidRow(box(status = "info", width = 12, textOutput(getID("text_last_update_"))))
               # textOutput("text_last_update")
               # )
        )
        ,
        box(
          id = "top_2",
          width = 6,
          status = "primary"
          
        )
      )
      , fluidRow(
        box(
          id = "middle_1",
          width = 8,
          status = "primary"
          ,
          tabsetPanel(
            type = "tabs",
            tabPanel("New", echarts4rOutput(getID("chart_cases_new_"), height = 300)
                     , davInfoBox()
                    ),
            tabPanel("Active", echarts4rOutput(getID("chart_cases_current_"), height = 300)
                     , davInfoBox()
                     ),
            tabPanel("Recovered", echarts4rOutput(getID("chart_cases_recovered_"), height = 300)
                     , davInfoBox()
            )
          )
        )
        ,
        box(
          width = 4,
          status = "primary",
          echarts4rOutput(getID("chart_current_pie_"), height = 396)
        )
        
      )
    )
}
