tagsHead <- function(){tags$head(
  tags$script('
               setHeight = function() {
               
                  //$("#top_1").height(200);
                  //$("#top_2").height(200);
                  
                  $("#middle_1").height(400);
                  $("#middle_2").height(400);
                  
                  
                  
               }
              
              // Set input$box_height when the connection is established
                            $(document).on("shiny:connected", function(event) {
                              setHeight();
                            });
    
                            // Refresh the box height on every window resize event
                            $(window).on("resize", function(){
                              //setHeight();
                            });
              ')
)}