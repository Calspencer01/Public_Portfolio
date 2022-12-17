red <- "#ac1a2f"
black <- "#000000"

main <- red
sub <- black

wholeNumFormatter <- "
             function(params){
               var val = params;
               if (val % 1 != 0) { val = '';}
              return(val)
            }"

text_current_cases <- function(df_current_campus, posCases, label){
  df_current_campus %>%
    e_chart(date) %>%
    e_x_axis(show = FALSE) %>%
    e_y_axis(show = FALSE) %>%
    e_title(
      posCases,
      label,
      subtextStyle = c(fontSize = 14, color = sub),
      textStyle = c(fontSize = 60, color = main),
      left = 'center',
      right = 'center',
      top = '2%',
      bottom = '40%'
    )
}

text_current_population <- function(df_current_campus, population, label){
  
  df_current_campus %>%
    e_chart(date) %>%
    e_x_axis(show = FALSE) %>%
    e_y_axis(show = FALSE) %>%
    e_title(
      format(population,big.mark=",",scientific=FALSE),
      label,
      subtextStyle = c(fontSize = 14, color = sub),
      textStyle = c(fontSize = 60, color = main),
      left = 'center',
      right = 'center',
      top = '2%',
      bottom = '40%'
    ) %>%
    e_theme('westeros')
}

bar_time_series <- function(df, type, barMax){
  df %>%
    e_chart(dateFormatted) %>%
    e_bar(
      cases,
      color = red,
      name = paste0(type, " Cases"),
      stack = type,
      barWidth = "40%"
    ) %>%
    e_legend(show = FALSE) %>%
    e_tooltip(position = 'top') %>%
    e_y_axis(formatter = htmlwidgets::JS(wholeNumFormatter), max = barMax) %>%
    e_grid(bottom = "10%", top = "10%", left = "5%", right = "5%")
}

pie_chart <- function(df, type, percCases, subhead, color){
  #browser()
  df %>%
    e_chart(label) %>%
    e_pie(
      `People`,
      color = color,
      class = paste0("pie_", type),
      radius = c('30%', '60%'),
      center = c('50%', '55%'),
    ) %>%
    e_legend(show = F) %>%
    e_title(
      paste0(percCases, " are positive for COVID-19"),
      subhead,
      top = 0,
      subtextStyle = c(color = sub),
      textStyle = c(fontSize = 22, color = main)
    ) %>%
    e_tooltip(position = 'left')
}