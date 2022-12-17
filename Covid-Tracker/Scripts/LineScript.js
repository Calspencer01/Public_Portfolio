// "Line Script"
// Draws stacked area line graph of recoveries, deaths, and active cases
// Called at end of DataScript; Uses 'lineData' 

xScale = d3.scaleTime(); //Axis scales
yScale = d3.scaleLinear();

var compFormat = d3.timeFormat("%Y.%m.%d");//Used to format for boolean comparisons
var activeCountry; //Country being viewed
var globalData; //Data stored globally

function updateLineplot(country, modal){ //Called when the graph is redrawn (when a new country is selected)
    
    var lineStr = ""; //String for the description of what area is being hovered over. Updated within mouseover.
    var lineSVG = modal; //Sets svg = to the mapSVG
    activeCountry = country; //Stores country 

    var byCountry = d3.nest() //Nest by country
        .key(d => d.country)
        .entries(lineData);
    
    var filteredLineData = []; //New data to work with, filtered by country

    var hasKey = false;
    byCountry.forEach(function (d){
        if (d.key == country){  //Filter 
            hasKey = true; //Store that the country is valid 
            filteredLineData.push(d); 
        }
    });

    //console.log(filteredLineData);

    globalData = filteredLineData; //Store here (workaround, simplify if you have time)

    
    if (!hasKey){//If country isnt found, just quit modal (add something else?)
        exitModal(lineSVG);
    }
    else{
        var yMax = d3.max(filteredLineData[0].values, function (d){ return d.confirmed; }); //Find max of new data

        xScale = d3.scaleTime().range([0, width/1.1]).domain([columns[0], columns[columns.length-1]]);
        yScale = d3.scaleLinear().range([height, 0]).domain([0,yMax*1.2]); //Scales

        var recoveredArea = d3.area() //Area of recoveries
            .x(function(d) { return xScale(d.date); }) 
            .y0(function(d) { return yScale(d.active + d.dead); }) //Stack on top of active and dead
            .y1(function(d) { return yScale(d.active + d.recovered + d.dead); }); 
        var activeArea = d3.area() //Area of active cases
            .x(function(d) { return xScale(d.date); })
            .y0(height)                                //Stack on top of x axis
            .y1(function(d) { return yScale(d.active); });
        var deadArea = d3.area() //Area of deaths
            .x(function(d) { return xScale(d.date); })
            .y0(function(d) { return yScale(d.active); }) //Stack on top of active cases
            .y1(function(d) { return yScale(d.active + d.dead); });
        var defaultArea = d3.area()
            .x(function(d) { return xScale(d.date); })
            .y0(function(d) { return yScale(0); })
            .y1(function(d) { return yScale(0); });

        var defaultLine = d3.line() //"Default" line, values all 0, so on transition it will move upward
            .x(function(d) { return xScale(d.date); })
            .y(function(d) { return yScale(0);//Start at bottom and transition upward
            });
        
        var recoveredLine = d3.line() //Line for recoveries
            .curve(d3.curveLinear)
            .x(function(d) { return xScale(d.date); })
            .y(function(d) { return yScale(d.active + d.recovered + d.dead);//Stack on active and recovered cases
                //else{ return yScale(1); }
            });

        // var confirmedLine = d3.line() //Line for confirmed cases
        //     .curve(d3.curveLinear)
        //     .x(function(d) { return xScale(d.date); })
        //     .y(function(d) { 
        //         if (d.recovered > 0){ return yScale(d.confirmed); } //Stack on x axis
        //         //else{ return yScale(1); }
        //     });

        var activeLine = d3.line() //Line for active cases
            .curve(d3.curveLinear)
            .x(function(d) { return xScale(d.date); })
            .y(function(d) { return yScale(d.active);});
            
        var deadLine = d3.line() //Line for deaths
            .curve(d3.curveLinear)
            .x(function(d) { return xScale(d.date); })
            .y(function(d) { return yScale(d.dead + d.active);});

        //lineSVG.attr("transform", "translate(" + margin.left + ", + 0 + )");

        lineSVG.append("g") //Create x axis
            .attr("class", "x axis")
            .attr("class", "lineSVG")
            .attr("transform", "translate(" + 0 + "," + height + ")")
            .call(d3.axisBottom(xScale));
        
        lineSVG.append("g") //Create y axis
            .attr("class", "y axis")
            .attr("class", "lineSVG")
            .attr("transform", "translate(" + 0 + "," + 0 + ")")
            .call(d3.axisLeft(yScale));
        
        var countryLine = lineSVG.selectAll(".countryLine") // Drawing lines
        .data(filteredLineData) //Add data filtered by selected country
        .enter().append("g")
        .attr("class", "countryLine")
        .attr("class", "lineSVG");

        countryLine.append("path") // Draw recoveries line
                .attr("stroke",  colorVals["recovered"][5]) //Uses map color scheme
                .attr("class", "countryLine")
                .attr("fill-opacity","0.0")
                .attr("stroke-width", "1.0px")
                .attr("d", function(d){ return defaultLine(d.values); })
                .transition().duration(1000)
                .attr("d", function(d){ return recoveredLine(d.values); })
                .on("end", function(){
                    verticalLineUpdate(setDate);
                });
            
        countryLine.append("path") //Draw active cases line
            .attr("stroke",  colorVals["active"][5]) //Uses map color scheme
            .attr("class", "countryLine")
            .attr("fill-opacity","0.0")
            .attr("stroke-width", "1.0px")
            .attr("d", function(d){ return defaultLine(d.values); })
                .transition().duration(1000)
            .attr("d", function(d){return activeLine(d.values); })

        countryLine.append("path") //Draw deaths line
            .attr("stroke",  colorVals["dead"][5]) //Uses map color scheme
            .attr("class", "countryLine")
            .attr("fill-opacity","0.0")
            .attr("stroke-width", "1.0px")
            .attr("d", function(d){ return defaultLine(d.values); })
                .transition().duration(1000)
            .attr("d", function(d){
                return deadLine(d.values);
            })
            
        countryLine.append("path") //Fill recoveries area
            .data(filteredLineData)
            .attr("class", "area")
            .attr("fill-opacity", "0.7")
            .attr("fill", colorVals["recovered"][1]) //Uses map color scheme
            .attr("d", function (d){ return defaultArea(d.values); })
            .on('mouseover', function (d){ //Highlight area
                lineStr = "active cases in "; //Assign string for description
                d3.select(this).style("opacity", .8)
                updateText();
            })
            .on('mouseout', function (d){ //Remove highlight
                lineStr = ""; //Remove string for description
                d3.select(this).style("opacity", 1)
                updateText();
            })
            .transition().duration(1000)
            .attr("d", function (d){ return recoveredArea(d.values); });

        countryLine.append("path") //Fill active cases area
            .data(filteredLineData)
            .attr("class", "area")
            .attr("fill-opacity", "0.7")
            .attr("fill", colorVals["active"][1]) //Uses map color scheme
            .attr("d", function (d){ return defaultArea(d.values); })
            .on('mouseover', function (d){ //Highlight area
                lineStr = "active cases in "; //Assign string for description
                d3.select(this).style("opacity", .8)
                updateText();
            })
            .on('mouseout', function (d){ //Remove highlight
                lineStr = ""; //Remove string for description
                d3.select(this).style("opacity", 1)
                updateText();
            })
            .transition().duration(1000)
            .attr("d", function (d){ return activeArea(d.values); });

        countryLine.append("path") //Fill deaths area
            .data(filteredLineData)
            .attr("class", "area")
            .attr("fill-opacity", "0.7")
            .attr("fill", colorVals["dead"][1]) //Uses map color scheme
            .attr("d", function (d){ return defaultArea(d.values); })
            .on('mouseover', function (d){ //Highlight area
                lineStr = "active cases in "; //Assign string for description
                d3.select(this).style("opacity", .8)
                updateText();
            })
            .on('mouseout', function (d){ //Remove highlight
                lineStr = ""; //Remove string for description
                d3.select(this).style("opacity", 1)
                updateText();
            })
            .transition().duration(1000)
            .attr("d", function (d){ return deadArea(d.values); });

            columns.forEach(function(column){ //Draw dots for each line
                countryLine.append("circle").attr("class", "linept").attr("r", 2).attr("fill", colorVals["recovered"][1]).attr("stroke", colorVals["recovered"][5])
                    .attr("cx", xScale(column))
                    .attr("cy", yScale(0))
                    .transition().duration(1000)
                    .attr("cy", function (d) { return yScale(getRecoveredY(d.values[getDateIndex(column)])); });
                countryLine.append("circle").attr("class", "linept").attr("r", 2).attr("fill", colorVals["dead"][1]).attr("stroke", colorVals["dead"][5])
                    .attr("cx", xScale(column))
                    .attr("cy", yScale(0))
                    .transition().duration(1000)
                    .attr("cy", function (d) { return yScale(getDeadY(d.values[getDateIndex(column)])); });
                countryLine.append("circle").attr("class", "linept").attr("r", 2).attr("fill", colorVals["active"][1]).attr("stroke", colorVals["active"][5])
                    .attr("cx", xScale(column))
                    .attr("cy", yScale(0))
                    .transition().duration(1000)
                    .attr("cy", function (d) { return yScale(getActiveY(d.values[getDateIndex(column)])); });
            });

        // countryLine.append("path") //Confirmed cases line
        //     .attr("stroke",  "blue")
        //     .attr("class", "countryLine")
        //     .attr("fill-opacity","0.0")
        //     .attr("stroke-width", "2px")
        //     .attr("d", function(d){
        //         return confirmedLine(d.values);
        //     })

        lineSVG.append("text") // Reactive description text
            .attr("class", "linegraphdescription")
            .attr("transform","translate(" + (width/2) + " ," + (margin.top + xLabelMargin/2) + ")")
            .style("text-anchor", "middle")
            .attr("class", "lineSVG")
            .html("Viewing " + country + ". View a date with the slider bar.");

        lineSVG.append("rect") //Y axis label boxes
            .attr("transform", "rotate(-90)").attr("class", "lineSVG").attr("rx", 4).attr("y", -80).attr("x",0 - (height / 2) - 120).attr("height", 20).attr("width", 100).style('fill', colorVals["active"][4]).style("fill-opacity", 0.7);

        lineSVG.append("rect")
            .attr("transform", "rotate(-90)").attr("class", "lineSVG").attr("rx", 4).attr("y", -80).attr("x",0 - (height / 2)).attr("height", 20).attr("width", 60).style('fill', colorVals["dead"][4]).style("fill-opacity", 0.7);

        lineSVG.append("rect")
            .attr("transform", "rotate(-90)").attr("class", "lineSVG").attr("rx", 4).attr("y", -80).attr("x",0 - (height / 2) + 80).attr("height", 20).attr("width", 80).style('fill', colorVals["recovered"][4]).style("fill-opacity", 0.7);

        lineSVG.append("text") //"Active" Y axis label
            .attr("transform", "rotate(-90)")
            .attr("class", "lineSVG")
            .attr("y", -80)
            .attr("x",0 - (height / 2) - 70)
            .attr("dy", "1em")
            .style("text-anchor", "middle")
            .style('fill', "white")
            .text("Active Cases");

        lineSVG.append("text")  //"Deaths" Y axis label
            .attr("transform", "rotate(-90)")
            .attr("class", "lineSVG")
            .attr("y", -80)
            .attr("x",0 - (height / 2) + 30)
            .attr("dy", "1em")
            .style("text-anchor", "middle")
            .style('fill', "white")
            .text("Deaths");

        lineSVG.append("text")  //"Recoveries" Y axis label
            .attr("transform", "rotate(-90)")
            .attr("class", "lineSVG")
            .attr("y", -80)
            .attr("x", 0 - (height / 2) + 120)
            .attr("dy", "1em")
            .style("text-anchor", "middle")
            .style('fill', "white")
            .text("Recoveries");

        
        lineSVG.append("text")  //Exit Button Text
            .attr("class", "lineSVG exitButton")
            .attr("y", 0)
            .attr("x", 35)
            .attr("dy", "1em")
            .style("text-anchor", "middle")
            .style("font-size", 16)
            .style('fill', "#960000")
            .on('mouseover', function(d){
                d3.selectAll(".exitRect").style('fill-opacity', 0.1);
            })
            .on('mouseout', function(d){
                d3.selectAll(".exitRect").style('fill-opacity', 0.0);
            })
            .on('click', function(d){
                d3.selectAll(".exitButton").style('fill', "#fc0303").transition().duration(300).style('fill', "#960000").on("end", function(){
                    exitModal(lineSVG);
                })
            })
            .text("Exit");

        lineSVG.append("rect") //Exit button rect
            .attr("class", "lineSVG exitButton exitRect").style('stroke', "#960000").style('fill', "#960000").style('fill-opacity', 0.0)
            .attr("y", 0).attr("x", 10)
            .attr("rx", 3).attr("ry", 3)
            .attr("height", 20).attr("width", 50)
            .on('mouseover', function(d){
                d3.selectAll(".exitRect").style('fill-opacity', 0.1);
            })
            .on('mouseout', function(d){
                d3.selectAll(".exitRect").style('fill-opacity', 0.0);
            })
            .on('click', function(d){
                d3.selectAll(".exitButton").style('fill', "#fc0303").transition().duration(300).style('fill', "#960000").on("end", function(){
                    exitModal(lineSVG);
                })
            })

        lineSVG.append("line")
            .data(filteredLineData)
            .attr("class", "recovered_timeline lineSVG").style("stroke-width", 1).style("stroke", colorVals["recovered"][4]).style("stroke-opacity", 0.7);
        lineSVG.append("line")
            .data(filteredLineData)
            .attr("class", "dead_timeline lineSVG").style("stroke-width", 1).style("stroke", colorVals["dead"][4]).style("stroke-opacity", 0.7);
        lineSVG.append("line")
            .data(filteredLineData)
            .attr("class", "active_timeline lineSVG").style("stroke-width", 1).style("stroke", colorVals["active"][4]).style("stroke-opacity", 0.7);
        lineSVG.append("line")
            .data(filteredLineData)
            .attr("class", "gray_timeline lineSVG").style("stroke-width", 1).style("stroke", "#BBB").style("fill", "none");

        function updateText(){ // Update chart description
            // d3.selectAll(".linegraphdescription")
            // .html("Viewing " + lineStr + country + ". View a date with the slider bar.");
        }
    }
}
getActiveY = function (values){ // Active line Y coordinate
    return values.active;
}
getDeadY = function (values){ // Dead line Y coordinate
    return values.active + values.dead;
}
getRecoveredY = function (values){ // Recovered line Y coordinate
    return values.active + values.dead + values.recovered;
}

getDateIndex = function(date){ //return index of date (DEFINITELY a better way to do this)
    for (var i = 0; i < columns.length; i++){
        if (compFormat(date) == compFormat(columns[i])){
            return i;
        }
    }
 }

verticalLineUpdate = function(newDate){ //Update vertical line to coordinates of new date
    dateIndex = getDateIndex(newDate);
    
    d3.selectAll(".recovered_timeline") //Move vertical line in "recoveries" section
        .transition().duration(50)
        .style("stroke-width", "3px")
        .attr("x1", xScale(columns[dateIndex]))
        .attr("y1", function (d){ return yScale(getDeadY(d.values[dateIndex])) - 2; })
        .attr("x2", xScale(columns[dateIndex])) 
        .attr("y2", function (d){ return yScale(getRecoveredY(d.values[dateIndex])) + 2;});

    d3.selectAll(".dead_timeline") //Move vertical line in "deaths" section
        .transition().duration(50)
        .style("stroke-width", "3px")
        .attr("x1", xScale(columns[dateIndex]))
        .attr("y1", function (d){ return yScale(getActiveY(d.values[dateIndex])) - 2; })
        .attr("x2", xScale(columns[dateIndex])) 
        .attr("y2", function (d){ return yScale(getDeadY(d.values[dateIndex])) + 2; });

    d3.selectAll(".active_timeline") //Move vertical line in "active" section
        .transition().duration(50)
        .style("stroke-width", "3px")
        .attr("x1", xScale(columns[dateIndex]))
        .attr("y1", function (d){ return height; })
        .attr("x2", xScale(columns[dateIndex])) 
        .attr("y2", function (d){ return yScale(getActiveY(d.values[dateIndex])) + 2; });

    d3.selectAll(".gray_timeline") //Move vertical line in section with no cases/data
        .transition().duration(50)
        .style("stroke-width", "3px")
        .attr("x1", xScale(columns[dateIndex]))
        .attr("y1", 50)
        .attr("x2", xScale(columns[dateIndex])) 
        .attr("y2", function (d){ return yScale(getRecoveredY(d.values[dateIndex])) -3;});

    d3.selectAll(".lineptTemp").remove();
    d3.selectAll(".lineTip").remove();
    lineSVG = d3.selectAll(".lineSVG")

    //Fill in lines being selected
    lineSVG.append("circle").attr("class", "lineptTemp").attr("r", 2).style("fill", colorVals["recovered"][4]).style("stroke", colorVals["recovered"][5])
                .attr("cx", xScale(newDate))
                .attr("cy", function () { return yScale(getRecoveredY(globalData[0].values[dateIndex])); });
    lineSVG.append("circle").attr("class", "lineptTemp").attr("r", 2).attr("fill", colorVals["dead"][4]).attr("stroke", colorVals["dead"][5])
                .attr("cx", xScale(newDate))
                .attr("cy", function () { return yScale(getDeadY(globalData[0].values[dateIndex])); });
    lineSVG.append("circle").attr("class", "lineptTemp").attr("r", 2).attr("fill", colorVals["active"][4]).attr("stroke", colorVals["active"][5])
                .attr("cx", xScale(newDate))
                .attr("cy", function (){ return yScale(getActiveY(globalData[0].values[dateIndex])); 
                });
   
    stringFormat = d3.timeFormat("%b %d, %Y"); //Date format for tooltip

    lineSVG.append("rect") //Tooltip rectangle
        .attr("class", "lineTip")
        .attr("x", xScale(newDate)+5).attr("y", 50)
        .attr("width", 200).attr("height", 90)
        .attr("fill", "black").attr("fill-opacity", 0.4)
        .attr("rx", 5).attr("ry", 5);
    
    var tooltip = lineSVG.append("text") //Tooltip for the country's data at given date
        .attr("class", "lineTip")
        .attr("y", 50)
        .style("text-anchor", "left")
        .style("fill", "white")
        .html(function () {
         return "<tspan x='" + (xScale(newDate) + 10)  + "' dy='1.2em'>" + activeCountry + " on " + stringFormat(newDate) + "&nbsp&nbsp</tspan>" // Describes the country's data
         + "<tspan x='" + (xScale(newDate) + 10) + "' dy='1.2em'>" + commaFormat(globalData[0].values[dateIndex].confirmed) + " total cases&nbsp&nbsp</tspan>"
         + "<tspan x='" + (xScale(newDate) + 10) + "' dy='1.2em'>" + commaFormat(globalData[0].values[dateIndex].recovered) + " recoveries&nbsp&nbsp</tspan>"
         + "<tspan x='" + (xScale(newDate) + 10) + "' dy='1.2em'>" + commaFormat(globalData[0].values[dateIndex].dead) + " deaths&nbsp&nbsp</tspan>"
         + "<tspan x='" + (xScale(newDate) + 10) + "' dy='1.2em'>" + commaFormat(globalData[0].values[dateIndex].active) + " active cases&nbsp&nbsp</tspan>";
        })
      
}

function exitModal(svg){ //Exit modal view of line graph
    svg.append("rect")
    .attr("class","transitionFrame").attr("x",0 - margin.left).attr("y", 0 - margin.top).attr("height", height + margin.top).attr("width", width + margin.left*2)
    .attr("fill", "#FFFFFF").attr("fill-opacity", 0.0) //Draw empty rectangle
    .transition().duration(300).attr("fill-opacity", 1.0).on("end", function(){ //Transition the rectangle to fill white
        d3.selectAll(".lineSVG").remove();
        d3.selectAll(".transitionFrame").transition().duration(300).attr("fill-opacity", 0.0).on("end", function(){ //Transition the rectangle to fill empty again
            d3.selectAll(".transitionFrame").remove(); //Remove transition frame
            removeMapButtons(); //Redraw buttons
            drawMapButtons()
        });
    })
    inModal = false;
}
