//"Radial Bar Script"
//Creates a radial bar graph of all the states
//Data is of # tested containing a stacked bar chart of #recovered, #dead, & #active cases

//Uses Thanaporn’s Block d5a1178901137b48312ebbc245fdfd48 for d3-scale-radial.js

var testedColor = "#678d9e";
var showingPeopleMap = false;
var selectedState;
function drawRadialBar(byState, stateNames, showActive, showRecovered, showDead, showTested){
    var numSelected = 4; //Number of data items show (1-4)
    d3.select(".radialSVG").remove();
   filteredData = []; //Data for active, dead, and recovered
   filteredDataTested = []; //Separate data for tested because it is another width and not stacked
   
   byState = byState.filter(function(d){ //Some states are called "recovered" at the bottom of the CSV. 
       return d.state != "Recovered"
   } )

   var activeM = 1, recoveredM = 1, deadM = 1, testedM = 1; //Multipliers to remove data if not selected
    if (!showActive){ activeM = 0; numSelected--; }
    if (!showRecovered){ recoveredM = 0; numSelected--; }
    if (!showDead){ deadM = 0; numSelected--; }
    if (!showTested){ testedM = 0; numSelected--; }

   byState.forEach(function (d){ //Filter out selected data
        var active = d.active*activeM;
        var recovered = d.recovered*recoveredM;
        var dead = d.dead*deadM;
        var tested = d.tested*testedM;

        filteredData.push({
            active: active,
            confirmed: +d.confirmed,
            recovered: recovered,
            dead: dead,
            tested: tested,
            state: d.state,
        })

        filteredDataTested.push({
            tested: tested,
            state: d.state
        })
    })

    function getAbbrev(state){ //Get abbreviation for the given state
        var shorthand = "";
        stateNames.forEach(function (d){
            if (d.Name.toLowerCase() == state.toLowerCase()){
                shorthand = d.Shorthand;
            }
        })
        return shorthand;
    }

    var innerRadius = 150; // Inner & Outer Radius
    var outerRadius = (height);

    if (showTested){ //If testing is shown, that will determine the order, otherwise, the sum of the other three parts of data determine order
        filteredData = filteredData.sort((a,b) => d3.descending(a.tested, b.tested));
    }
    else{
        filteredData = filteredData.sort((a,b) => d3.descending((a.active + a.dead + a.recovered), (b.active + b.dead + b.recovered)));
    }

    var zDomain = [];
    if (showActive){  zDomain.push("active"); } //Build Z domain depending on what's selected
    if (showRecovered){ zDomain.push("recovered"); }
    if (showDead){ zDomain.push("dead"); }
    if (showTested){ zDomain.push("tested"); }

    var radialSVG = d3.select("#radialviz").append("svg") //SVG for this graph
    .attr("class", "radialSVG")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height*2 + margin.top + margin.bottom + 100)
    .append("g")
    .attr("transform", "translate(" + (0) + "," + (0) + ")")

    //Person map
    var graph = radialSVG.append("g").attr("transform", "translate(" + (margin.left - 30 + (width/2))  + "," + (outerRadius + 50) + ")");
    
    var colorDomain = [];
    zDomain.forEach(function (d){
        if (d == "tested"){
            colorDomain.push("null");
        }
        else{
            colorDomain.push(colorVals[d][4]); //Same color scheme as choropleth
        }
        
    });

    // if (showingPeopleMap){//Draw person map only if selected
    //     drawPersonMap(selectedState, byState, radialSVG)
    // }

    var xScale = d3.scaleBand()  //Scales
    .range([0, 2 * Math.PI])
    .align(0);

    var yScale = d3.scaleRadial()
    .range([innerRadius, outerRadius]);

    var zScale = d3.scaleOrdinal()
    .range(colorDomain);


    xScale.domain(filteredData.map(function(d) { return d.state; }));

    if (showTested){ //If showing tested, max is tested
        yScale.domain([0, d3.max(filteredDataTested, function(d) { return d.tested; })]);
    }
    else{ //else, max is recovered + active + dead (some will be 0 if not selected)
        yScale.domain([0, d3.max(filteredData, function(d) { return d.recovered + d.active + d.dead; })]);
    }
    
    zScale.domain(zDomain);

    var yAxis = graph.append("g") //y axis
      .attr("text-anchor", "middle")
      .attr("dx", "-50");

    var yTick = yAxis //ticks for y axis
        .selectAll("g")
        .data(yScale.ticks(5).slice(1))
        .enter().append("g");

    yTick.append("circle") //Draw circles for y scale ticks
        .attr("fill", "none")
        .attr("stroke", "#bbb")
        .attr("r", innerRadius)
        .transition().duration(1000)
        .attr("r", yScale);

    yTick.append("text")
        .attr("y", function(d) { return -yScale(0); })
        .transition().duration(1000)
        .attr("y", function(d) { return -yScale(d); })
        .attr("dy", "0.35em")
        .attr("x", -20)
        .attr("fill", "none")
        .attr("stroke", "#fff")
        .attr("stroke-width", 5)
        .text(yScale.tickFormat(5, "s"));

    yTick.append("text")
        .attr("y", function(d) { return -yScale(0); })
        .transition().duration(1000)
        .attr("y", function(d) { return -yScale(d); })
        .attr("dy", "0.35em")
        .attr("x", -20)
        .attr("fill", "#aaa")
        .style("font-size", "10px")
        .text(yScale.tickFormat(5, "s"));

    yAxis.append("text")
        .attr("y", function(d) { return -yScale(0); })
        .transition().duration(1000)
        .attr("y", function(d) { return -yScale(yScale.ticks(5).pop()); })
        .attr("dy", "-1em")
        .text("");

    mouseoverArc = function(d){ //Mouseover for bar
            d = getData(d.data.state);

            commaFormat = d3.format(",");
            d3.selectAll("." + d.state.replace(" ", "_") + "_arc")
            .attr("fill-opacity", 0.5).attr("stroke-opacity", 1);

            d3.selectAll(".active_label").text(commaFormat(d.active))
            d3.selectAll(".recovered_label").text(commaFormat(d.recovered))
            d3.selectAll(".dead_label").text(commaFormat(d.dead))
            d3.selectAll(".tested_label").text(commaFormat(d.tested))

            d3.selectAll(".state_label").text(d.state);
        }
    mouseoutArc = function(d){ //Mouseout for bar
        d3.selectAll("." + d.data.state.replace(" ", "_") + "_arc") //Highlight
            .attr("fill-opacity", 0.6)
            .attr("stroke-opacity", 0.5)
            
        if (!showingPeopleMap){
            d3.selectAll(".tested_label").text("") //Remove text labels
            d3.selectAll(".active_label").text("")
            d3.selectAll(".recovered_label").text("")
            d3.selectAll(".dead_label").text("")

            d3.selectAll(".state_label").text("");
        } 
        else{
            d = getData(selectedState);

            commaFormat = d3.format(",");
            d3.selectAll("." + d.state.replace(" ", "_") + "_arc") //Highlight
            .attr("fill-opacity", 0.5).attr("stroke-opacity", 1);

            d3.selectAll(".active_label").text(commaFormat(d.active)) //Change text labels
            d3.selectAll(".recovered_label").text(commaFormat(d.recovered))
            d3.selectAll(".dead_label").text(commaFormat(d.dead))
            d3.selectAll(".tested_label").text(commaFormat(d.tested))

            d3.selectAll(".state_label").text(d.state);
        }
    }

    mouseoverArcLabel = function(d){ //Mouseover for bar label
        commaFormat = d3.format(",");
        d3.selectAll("." + d.state.replace(" ", "_") + "_arc") //Highlight
        .attr("fill-opacity", 0.5).attr("stroke-opacity", 1);
        
        d3.selectAll(".active_label").text(commaFormat(d.active))
        d3.selectAll(".recovered_label").text(commaFormat(d.recovered))
        d3.selectAll(".dead_label").text(commaFormat(d.dead))
        d3.selectAll(".tested_label").text(commaFormat(d.tested))

        d3.selectAll(".state_label").text(d.state);
    }
    
    mouseoutArcLabel = function(d){ //Mouseout for bar label
        d3.selectAll("." + d.state.replace(" ", "_") + "_arc")
            .attr("fill-opacity", 0.6)
            .attr("stroke-opacity", 0.5)
        if (!showingPeopleMap){
            
            d3.selectAll(".tested_label").text("") //Remove text labels
            d3.selectAll(".active_label").text("")
            d3.selectAll(".recovered_label").text("")
            d3.selectAll(".dead_label").text("")

            d3.selectAll(".state_label").text("");
        } 
        else{
            d = getData(selectedState);

            commaFormat = d3.format(",");
            d3.selectAll("." + d.state.replace(" ", "_") + "_arc")
            .attr("fill-opacity", 0.5).attr("stroke-opacity", 1);

            d3.selectAll(".active_label").text(commaFormat(d.active)) //Change text labels
            d3.selectAll(".recovered_label").text(commaFormat(d.recovered))
            d3.selectAll(".dead_label").text(commaFormat(d.dead))
            d3.selectAll(".tested_label").text(commaFormat(d.tested))

            d3.selectAll(".state_label").text(d.state);
        }
    }

    graph.append("g") //Add bar graph (for tested)
    .selectAll("g")
    .data(d3.stack().keys(zDomain)(filteredDataTested)) //"Stack" just the # tested 
    .enter().append("g")
      .attr("fill", function(d) { return testedColor; })
      .attr("fill-opacity", 0.6)
    .selectAll("path")
    .data(function(d) { return d; })
    .enter().append("path")
        // .attr("d", d3.arc()
        //   .outerRadius(function(d) { return yScale(d[0]); }))
        // .transition().duration(1000)
        .attr("d", d3.arc()
          .innerRadius(function(d) { return yScale(d[0]); })
          .outerRadius(function(d) { return yScale(d[1]); })
          .startAngle(function(d) { return xScale(d.data.state); })
          .endAngle(function(d) { return xScale(d.data.state) + xScale.bandwidth(); })
          .padAngle(0.02) //Distance between bars
          .padRadius(innerRadius))
    .attr("class", function (d){
        return d.data.state.replace(" ", "_") + "_arc arc_graph";
    })
    .attr("stroke", "#111")
    .attr("stroke-width", 0.5)
    .attr("stroke-opacity", 0.5)
    .on('mouseover', mouseoverArc)
    .on('mouseout', mouseoutArc)
    .on('click', function (d) { //On click, draw person map, or remove it if already present
        mouseoutArc(d);
        showingPeopleMap = !showingPeopleMap;
        if (showingPeopleMap){
            selectedState = d.data.state; 
            animatePersonModal(d.data.state, byState, radialSVG)
        }
    });


    graph.append("g") //Add bar graphs (for active, deaths, and recovered)
    .selectAll("g")
    .data(d3.stack().keys(zDomain)(filteredData))//Stack deaths, active, & recovered
    .enter().append("g")
      .attr("fill", function(d) { return zScale(d.key); })
      .attr("fill-opacity", 0.6)
    .selectAll("path")
    .data(function(d) {
        if (d.key == "tested"){
            return 0;
        }
        else {
            return d;
        }
    })
    .enter().append("path")
      .attr("d", d3.arc()
          .innerRadius(function(d) { return yScale(d[0]); })
          .outerRadius(function(d) { return yScale(d[1]); })
          .startAngle(function(d) { return xScale(d.data.state); })
          .endAngle(function(d) { return xScale(d.data.state) + xScale.bandwidth(); })
          .padAngle(0.05)
          .padRadius(innerRadius))
    .attr("class", function (d){
        return d.data.state.replace(" ", "_") + "_arc arc_graph";
    })
    .attr("stroke", "#111")
    .attr("stroke-width", 0.5)
    .attr("stroke-opacity", 0.5)
    .on('mouseover', mouseoverArc)
    .on('mouseout', mouseoutArc)
    .on('click', function (d) {//On click, draw person map, or remove it if already present
        mouseoutArc(d);
        showingPeopleMap = !showingPeopleMap;
        if (showingPeopleMap){
            selectedState = d.data.state; 
            animatePersonModal(d.data.state, byState, radialSVG)
        }
    });

    var label = graph.append("g") //Add labels
    .selectAll("g")
    .data(filteredData)
    .enter().append("g")
      .attr("text-anchor", "middle")
      .attr("transform", function(d) { return "rotate(" + ((xScale(d.state) + xScale.bandwidth() / 2) * 180 / Math.PI - 90) + ")translate(" + innerRadius + ",0)"; });

    label.append("line") //Add little vertical line
      .attr("x2", -5)
      .attr("stroke", "#000");

    label.append("text") //Add text for labels
      .attr("transform", function(d) { 
          if (!showTested){
            return (xScale(d.state) + xScale.bandwidth() / 2 + Math.PI / 2) % (2 * Math.PI) < Math.PI ? "rotate(90)translate(0," + (-yScale(d.recovered + d.active + d.dead + d.tested) + innerRadius - 10) + ")" : "rotate(-90)translate(0," + (yScale(d.recovered + d.active + d.dead + d.tested) - innerRadius + 15) + ")";
          }
          else {
            return (xScale(d.state) + xScale.bandwidth() / 2 + Math.PI / 2) % (2 * Math.PI) < Math.PI ? "rotate(90)translate(0," + (-yScale(d.tested) + innerRadius - 10) + ")" : "rotate(-90)translate(0," + (yScale(d.tested) - innerRadius + 15) + ")";
          }})
        .on("mouseover", mouseoverArcLabel) //Need special functions because different data format :/
        .on("mouseout", mouseoutArcLabel)
        .style("font-size", "10px")
        .text(function(d) { return getAbbrev(d.state); });

    var dColor = colorVals["dead"][4]; //Text colors
    var rColor = colorVals["recovered"][4];
    var aColor = colorVals["active"][4];
    var tColor = testedColor;

    if (!showActive){ aColor = "white" } //Change to white if not shown
    if (!showRecovered){ rColor = "white" }
    if (!showDead){ dColor = "white" }
    if (!showTested){ tColor = "white" }



    var stateLabel = graph.append("text") //Labels for data types
        .attr("class", "state_label")
        .attr("x", 0).attr("y", -30)
        .attr("text-anchor", "middle")
        .attr("font-size", "24px");

    var deadLabel = graph.append("text")
        .attr("class", "dead_label")
        .attr("x", 90).attr("y", 20)
        .attr("text-anchor", "middle")
        .attr("fill", dColor);
        //.text("deaths");

    var recoveredLabel = graph.append("text")
        .attr("class", "recovered_label")
        .attr("x", -90).attr("y", 20)
        .attr("text-anchor", "middle")
        .attr("fill", rColor);
        //.text("recoveries");

    var activeLabel = graph.append("text")
        .attr("class", "active_label")
        .attr("x", 0).attr("y", 20)
        .attr("text-anchor", "middle")
        .attr("fill", aColor);
        //.text("active");

    var testedLabel = graph.append("text")
        .attr("class", "tested_label")
        .attr("x", 0).attr("y", 70)
        .attr("text-anchor", "middle")
        .attr("fill", tColor);
        //.text("active");

    var testedButton =  buttonRadial(graph, "Tested", 0, 50, testedColor, showTested, function(d){ //Buttons for turning on/off data types
            if (numSelected > 1 || !showTested){
                showTested = !showTested;
                if (showTested){
                    d3.selectAll(".TestedRectRadial").style('fill-opacity', 0.5);
                }
                else{
                    d3.selectAll(".TestedRectRadial .tested_label_radial").style('fill-opacity', 0.0);
                    
                }
                redraw();
            }
         })

    var activeButton =  buttonRadial(graph, "Active", 0, 0, colorVals["active"][4], showActive, function(d){
        if (numSelected > 1 || !showActive){
            showActive = !showActive;
            if (showActive){
                d3.selectAll(".ActiveRectRadial").style('fill-opacity', 0.5);
            }
            else{
                d3.selectAll(".ActiveRectRadial .active_label_radial").style('fill-opacity', 0.0);
                
            }
            redraw();
        }
     })
    var recoveredButton =  buttonRadial(graph, "Recovered", -90, 0, colorVals["recovered"][4], showRecovered, function(d){
        if (numSelected > 1 || !showRecovered){
            showRecovered = !showRecovered;
            if (showRecovered){
                d3.selectAll(".RecoveredRectRadial").style('fill-opacity', 0.5);
            }
            else{
                d3.selectAll(".RecoveredRectRadial").style('fill-opacity', 0.0);
            }
            redraw();
        }
     })
    var deathsButton =  buttonRadial(graph, "Deaths", 90, 0, colorVals["dead"][4], showDead, function(d){
        if (numSelected > 1 || !showDead){
            showDead = !showDead;
            if (showDead){
                d3.selectAll(".DeathsRectRadial").style('fill-opacity', 0.5);
            }
            else{
                d3.selectAll(".DeathsRectRadial").style('fill-opacity', 0.0);
            }
            redraw();
        }
     })
    
     function redraw(){
        drawRadialBar(byState, stateNames, showActive, showRecovered, showDead, showTested);
     }

     function getData(state){ //Get data for a given state
         var data = ";"
         filteredData.forEach(function (d){
            if (d.state == state){
                data = d;
            }
         })
         return data;
     }
   
    function buttonRadial(graph, text, x, y, color, active, click){ //Buttons for radial bar graph
        fill = 0.0;
        fontColor = "black";
        if (active){
            fill = 0.7;
        }
        if (active){
            fontColor = "white"
        }
        
        var buttonRect = graph.append("rect") //outline/rectangle
            .attr("fill-opacity", fill)
            .attr("fill", color)
            .attr("class", text + "RectRadial radialButton")
            .attr("stroke", "black")
            .style('stroke-width', 0.5)
            .attr("x", x-40).attr("y", y-15)
            .attr("rx", 3).attr("ry", 3)
            .attr("height", 20).attr("width", 80);

        var buttonText = graph.append("text") //text
            .attr("text-anchor", "middle")
            .attr("fill", fontColor)
            .attr("class", text + "TextRadial radialButton")
            .attr("x", x).attr("y", y)
            .text(text);

        var overlay = graph.append("rect") // fill
        .attr("fill-opacity", 0.0)
        .attr("x", x-40).attr("y", y-15)
        .attr("rx", 3).attr("ry", 3)
        .attr("height", 20).attr("width", 80)
        .on('mouseover', function(d){
                d3.selectAll("." + text + "RectRadial").style('stroke-width', 1.5);
            })
            .on('mouseout', function(d){
                d3.selectAll("." + text + "RectRadial").style('stroke-width', 0.5);
            })
        .on('click', click)
    }
    
    function animatePersonModal(state, data, svg){///Animation into the person map
        modal = svg.append("rect") //Append rectangle that will be drawn over the bar graph as a transition
          .attr("class","personSVG").attr("stroke", "black").attr("fill", "#FFFFFF").attr("x", margin.left).style("fill-opacity", "0").style("stroke-opacity", "0").attr("y", height/4 ).attr("height", height + margin.top + margin.bottom + 30).attr("width", width - 40)
          .transition().duration(500).style("fill-opacity", "1").style("stroke-opacity", "1")
          .on("end", function(){
            drawPersonMap(state, data, svg); //Draw lineplot when transition ends
            d3.selectAll(".arc_graph").attr("fill-opacity", 0.6).attr("stroke-opacity", 0.5)
        });
      }
}

function removeModal(){ // Remove person map
    showingPeopleMap = false;
    d3.selectAll(".personSVG").remove();
}