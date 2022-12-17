// "Map Script"
// Draws chloropleth map, changes by mode (active/recovered/deaths/confirmed)
// Gets date from SliderScript
// Gets mode from radio buttons
// Called at end of DataScript; Uses 'caseData' 

var inModal = false;
var mapAnimating = false;
var restartAnimation = false; //if slider is at the end and already stopped, then it will go to the beginning if play button is clicked
commaFormat = d3.format(",");
var tipInfo = {};

clearTip();

var scaleDomainHigh = [0,1000,10000,100000,500000,1000000,10000000]; //Two different domains, one higher and one lower
var scaleDomainLow = [0,100,1000,10000,100000,1000000,10000000];

var scaleVals = [0,100, 500, 1000, 5000, 10000, 50000, 100000, 500000, 1000000, 5000000];
for (var i = 0; i < scaleVals.length; i++){
  scaleVals[i] = {
    value: scaleVals[i],
    index: i
  }
}

var color = []; //Array of color scales for different modes
color["confirmed"] = d3.scaleLinear()
    .domain(scaleDomainHigh)
    .range(colorVals["confirmed"]);
color["recovered"] = d3.scaleLinear()
    .domain(scaleDomainLow)
    .range(colorVals["recovered"]);
color["dead"] = d3.scaleLinear()
    .domain(scaleDomainLow)
    .range(colorVals["dead"]);
color["active"] = d3.scaleLinear()
    .domain(scaleDomainHigh)
    .range(colorVals["active"]);

var path = d3.geoPath(); //Map path
var projection = d3.geoMercator()
                   .scale(150)
                   .precision(.1)
                  .translate( [(width-margin.left-margin.right) / 2, height / 1.5]);

var path = d3.geoPath().projection(projection); //Projection

var mapSVG = d3.select("#mapviz").append("svg") //Build map SVG
  .attr("id", "mapviz")
  .attr("width", width + margin.left + margin.right + 150)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform",
      "translate(" + margin.left + "," + (margin.top) + ")");

var formatDays  = d3.timeFormat("%-j");
var setDate = columns[0];
var pastDate = columns[1]; //For recognizing the need to update
var mapMode = "confirmed";
var cButtonActive = true, rButtonActive = false, aButtonActive = false, dButtonActive = false;
var pastMode = mapMode;

function animateMap(data, map){
  var iterationCount = 0; //Used to move the slider automatically after a # of iterations
  timer = setInterval(function(){//Called repeatedly, moves slider not on every iteration
    if (mapAnimating){
      iterationCount ++;
      if (iterationCount > 100/10){ //Greater than interval per day / 10ms
        iterationCount = 0;
        if (setDate >= columns[columns.length-1] && restartAnimation == false){
          playClick();
        }
        else if (setDate >= columns[columns.length-1] && restartAnimation == true){
          restartAnimation = false;
          setDate = columns[0];
        }
        else{
          restartAnimation = false;
          setDate = addDays(setDate, 1);
          transitionSlider();
          verticalLineUpdate(setDate);
        }
      }
    }
    var dayDate = formatDays(setDate) - formatDays(columns[0]);
    // d3.selectAll("input[name = 'mode']").on("change", function(){ //Get mode from radio buttons
    //     mode = this.id;
    // });

    if (pastDate != setDate || pastMode != mapMode){ //only update colors if necessary
      updateMap(data, columns[dayDate], map.features, mapMode);
      pastDate = setDate;
      pastMode = mapMode;
    }
  }, 10);
}
var recentCountry; //Most recent country hovered over
function updateMap(data, date, features, mode){ //Fill countries with new colors
  if (recentCountry != undefined){ 
    updateTip(recentCountry, date);
    if (mapAnimating){
      tipText();
    }
  }
  

  //mapSVG.selectAll(".legendRect").remove();

  d3.select(window).on('mousemove', function (d){ moveTip(); })//Update tooltip

  removeMapButtons();
  if (!inModal){ 
    drawLegend(mapSVG);
    // if (!mapAnimating){
      drawMapButtons() 
    // }
  }

  d3.selectAll(".country_path")
    .data(features)
    .on('mouseover',function(d){
      recentCountry = d;
      d3.select(this)
        .style("opacity", 1)
        .style("stroke","white")
        .style("stroke-width",1);
      updateTip(d, date)
      drawTip();
    })
    .transition()  //select all the countries and prepare for a transition to new values
    .duration(100)  //time period for the transition
    .attr('fill', function(d) {
      if(data["confirmed"].hasOwnProperty(d.properties.name)){ //"confirmed" is arbitrary
        if (mapMode == "active"){ //Active = confirmed - recovered - dead
          return color[mapMode](data["confirmed"][d.properties.name][date] - data["recovered"][d.properties.name][date] - data["dead"][d.properties.name][date]);
        }
        else{ 
          return color[mapMode](data[mapMode][d.properties.name][date]); }
      }
    else{ return "#EEE" }
  });
}

function drawLegend(svg){
  svg.append("rect")
    .attr("x", -15)
    .attr("y", 260)
    .attr("width", 100)
    .attr("height", 200)
    .attr("stroke", "black")
    .attr("fill-opacity", 0.0);
  
  d3.selectAll(".legendRect").remove();

  svg.selectAll(".legendRect")
    .data(scaleVals).enter()
    .append("rect")
    .attr("class", "legendRect")
    .attr("x", -10)
    .attr("y", function (d){
      return 268 + d.index * 17;
    })
    .attr("fill", function (d){
      return color[mapMode](d.value);
    })
    .attr("width", 25)
    .attr("height", 12);

  svg.selectAll(".legendText")
    .data(scaleVals).enter()
    .append("text")
    .attr("class", "legendText")
    .style("font-size", "10px")
    .attr("x", 20)
    .attr("y", function (d){
      return 278 + d.index * 17;
    })
    .text(function (d){ return commaFormat(d.value); });
}

var formatParse = d3.timeParse("%m/%e/%y");
var daysParse = d3.timeParse("%j");
var yearlessFormat = d3.timeFormat("%m/%e")
var dayFormat = d3.timeFormat("%-j");
var properFormat = d3.timeFormat("%-m/%-e/%y");

function drawMap(data, date, map){ //Initial map drawing
  
  mapSVG.append("g")
      .attr("class", "countries")
    .selectAll(".country_path")
      .data(map.features)
    .enter().append("path")
      .attr("d", path)
      .attr("class", "country_path")
      .attr('fill-opacity', function(d) {
          if(d != undefined && data["confirmed"].hasOwnProperty(d.properties.name)){ //"confirmed" is initial
            return color[mapMode](data["confirmed"][d.properties.name][date]); }
        else{ return colorVals[mapMode][0]; }
    })
    .style('stroke',"")
    .style('stroke-width', .5)
    .style("opacity",1)
    .on('mouseover',function(d){ //Mouse enters country
      d3.select(this)
        .style("opacity", 1)
        .style("stroke","")
        .style("stroke-width",3);
      updateTip(d, date);
      drawTip();
    })
    .on('mouseout', function(d){ //Mouse exits country
      clearTip();
      d3.select(this)
      .style('stroke',"")
      .style('stroke-width', .5)
      .style("opacity",1)
    })
    .on('click', function (d){ //Update line graph with selected counry
      inModal = true;
      if (data["confirmed"].hasOwnProperty(d.properties.name)){
        animateModal(d.properties.name);
      }
      
    });

  drawLegend(mapSVG);

  mapSVG.append("svg:image") // Add aggregate data logo
  .attr("xlink:href","Data/globe.svg")
  .attr("x", -20)
  .attr("y", -10)
  .attr("height", 20)
  .attr("width", 20);

  mapSVG.append("text") // Add aggregate data text
  .attr("x", 7)
  .attr("y", 5)
  .text("See Aggregate Data");

  mapSVG.append("rect") // Aggregate data button rectangle
  .attr("class", "globalRect")
  .attr("x", -25).attr("y",-15)
  .attr("width", 165).attr("height", 30)
  .attr("rx", 5).attr("fill-opacity", 0.0)
  .attr("stroke", "black")
  .on('mouseover', function(d){
    d3.selectAll(".globalRect").style('fill-opacity', 0.2);
  })
  .on('mouseout', function(d){
      d3.selectAll(".globalRect").style('fill-opacity', 0.0);
  })
  .on('click', function (d){
    modalGlobal()
  });

  mapSVG.append("path") //Draw path
      .datum(topojson.mesh(map.features, function(a, b) { return a.id !== b.id; }))
      .attr("class", "names")
      .attr("class", "country_path")
      .attr("d", path);
}

function modalGlobal(){ //Open aggregate data modal
  inModal = true;
  animateModal("Worldwide")
}

function updateTip(d, date){  //Update information tip
  var caseString; //String to be returned to 'description'
  if (d == undefined || d.confirmed == undefined){ caseString = d.properties.name + " data not available." } //Data for that country not supplied
  else{
    if (mapMode == "active"){
      caseString = "Active cases: " + commaFormat( d.confirmed[date] - d.recovered[date] - d.dead[date] );
    }
    else if (mapMode == "recovered"){
      caseString = "Recovered cases: " + commaFormat(d.recovered[date]);
    }
    else if (mapMode == "confirmed"){
      caseString = "Confirmed cases: " + commaFormat(d.confirmed[date]);
    }
    else if (mapMode == "dead"){
      caseString = "Deaths: " + commaFormat(d.dead[date]);
    }
  }

  if (inModal){
  }
  else{ //Only draw tooltip if not in modal (line graph)
    tipInfo = {
      string: caseString,
      name: d.properties.name,
      date: properFormat(date)
    }
  }
 
}
function clearTip(){ // Remove tooltip
  tipInfo = {
    string: "",
    name: "",
    date: ""
  }
  d3.selectAll(".maptooltip")
  .text("")
  .attr("fill-opacity", 0.0)
  .style("visible", false);

  d3.selectAll(".tiprect").remove();

}

function moveTip(){ // Move tooltip
  var x = d3.event.pageX - document.getElementById("mapviz").getBoundingClientRect().x - 40;
  var y = d3.event.pageY - document.getElementById("mapviz").getBoundingClientRect().y; 
  y -= window.scrollY; // Compensate for page scroll offset
  var xOffset = -80, yOffset = -50;

  d3.selectAll(".tiprect").transition().duration(10)
  .attr("x",x+xOffset - 100)
  .attr("y",y+yOffset - 50)
  d3.selectAll(".tipstring").transition().duration(10)
  .attr("x", x+xOffset)
  .attr("y", y+yOffset)
  d3.selectAll(".tipname").transition().duration(10)
  .attr("x", x+xOffset)
  .attr("y", y+yOffset-30)
  d3.selectAll(".tipdate").transition().duration(10)
  .attr("x",x+xOffset)
  .attr("y",y+yOffset-15)
  
}

function drawTip(){  //Draw tooltip
  var x = d3.event.pageX - document.getElementById("mapviz").getBoundingClientRect().x - 40;
  var y = d3.event.pageY - document.getElementById("mapviz").getBoundingClientRect().y;
  y -= window.scrollY;

  d3.selectAll(".maptooltip").remove();
  var xOffset = -80, yOffset = -50;

  mapSVG.append("rect").attr("class", "maptooltip tiprect")
    .attr("x", x + xOffset - 100).attr("y", y + yOffset - 50)
    .attr("height", 60).attr("width", 200)
    .attr("rx", 10).attr("ry", 10)
    .attr("fill", colorVals[mapMode][5])
    .attr("fill-opacity", 0.7)

  mapSVG.append("text").attr("class", "maptooltip tipstring")
    .transition().duration(100)
    .attr("x", x+xOffset)
    .attr("y", y+yOffset)
    .attr("fill", "white")
    .attr("text-anchor", "middle")
    .text(tipInfo.string);
  mapSVG.append("text").attr("class", "maptooltip tipname")
  .transition().duration(100)
    .attr("x", x+xOffset)
    .attr("y", y+yOffset-30)
    .attr("fill", "white")
    .attr("text-anchor", "middle")
    .text(tipInfo.name);
  mapSVG.append("text").attr("class", "maptooltip tipdate")
  .transition().duration(100)
    .attr("x",x+xOffset)
    .attr("y",y+yOffset-15)
    .attr("fill", "white")
    .attr("text-anchor", "middle")
    .text(tipInfo.date);

}
function tipText(){ //Update tooltip text
  d3.selectAll(".tipstring").text(tipInfo.string);

  d3.selectAll(".tipname").text(tipInfo.name);

  d3.selectAll(".tipdate").text(tipInfo.date);
}

function animateModal(country){
  //Get X & Y coordinates of mouse click event
  var x = d3.event.pageX - document.getElementById("mapviz").getBoundingClientRect().x - 40;
  var y = d3.event.pageY - document.getElementById("mapviz").getBoundingClientRect().y - 20;

  y -= window.scrollY; //Compensate for scrolling

  modal = mapSVG.append("rect") //Append rectangle that will be drawn over the map as a transition
    .attr("class","lineSVG").attr("stroke", "black").attr("fill", "#FFFFFF").attr("r", 10).attr("x", x - 50 - margin.left/2).attr("y", y-50).attr("width", 100).attr("height",100)
    .transition().duration(500).attr("x", -90).attr("y", 0 - margin.top).attr("height", height + margin.top + 30).attr("width", width + margin.right)
    .on("end", function(){
      updateLineplot(country, mapSVG); //Draw lineplot when transition ends
  });

}

function removeMapButtons(){ //Remove map mode buttons
  d3.selectAll(".mapButton").remove();
}

function drawMapButtons(){ //Draw map mode buttons
  removeMapButtons();
  var xSet = 330, ySet = 485;
  if (!inModal){
    buttonMap(mapSVG, "Confirmed", xSet-320, ySet, colorVals["confirmed"][4], cButtonActive, function(){
      if (!cButtonActive){
        mapMode = "confirmed"; 
        cButtonActive = true; aButtonActive = false; rButtonActive = false; dButtonActive = false;
        drawLegend(mapSVG);
      }
    });
    buttonMap(mapSVG, "Active", xSet-230, ySet, colorVals["active"][4], aButtonActive, function(){
      if (!aButtonActive){
        mapMode = "active";
        cButtonActive = false; aButtonActive = true; rButtonActive = false; dButtonActive = false;
        drawLegend(mapSVG);
      }
    });
    buttonMap(mapSVG, "Recovered", xSet-140, ySet, colorVals["recovered"][4], rButtonActive, function(){
      if (!rButtonActive){
        mapMode = "recovered";
        cButtonActive = false; aButtonActive = false; rButtonActive = true; dButtonActive = false;
        drawLegend(mapSVG);
      }
    });
    buttonMap(mapSVG, "Dead", xSet-50, ySet, colorVals["dead"][4], dButtonActive, function(){
      if (!dButtonActive){
        mapMode = "dead";
        cButtonActive = false; aButtonActive = false; rButtonActive = false; dButtonActive = true;
        drawLegend(mapSVG);
      }
    });
  }
}

function buttonMap(svg, text, x, y, color, active, click){ //Make map-buttons (svg, x/y coordinates, color, whether currently pressed or not, click function)
  fill = 0.0;
  fontColor = "black";
  if (active){
      fill = 0.7;
  }
  if (active){
      fontColor = "white"
  }
  
  var buttonRect = svg.append("rect") //Button rounded rectangle shape
      .attr("fill-opacity", fill)
      .attr("fill", color)
      .attr("class", text + "Rect mapButton")
      .attr("stroke", "black")
      .style('stroke-width', 0.5)
      .attr("x", x-40).attr("y", y-15)
      .attr("rx", 3).attr("ry", 3)
      .attr("height", 20).attr("width", 80);

  var buttonText = svg.append("text") //Button text
      .attr("text-anchor", "middle")
      .attr("fill", fontColor)
      .attr("class", text + "Text mapButton")
      .attr("x", x).attr("y", y)
      .text(text);

  var overlay = svg.append("rect") //Overlay so that the cursor doesnt change over the text (bugs me a weird amount, I know)
  .attr("fill-opacity", 0.0)
  .attr("x", x-40).attr("y", y-15)
  .attr("rx", 3).attr("ry", 3)
  .attr("height", 20).attr("width", 80)
  .on('mouseover', function(d){
    d3.selectAll("." + text + "Rect").style('stroke-width', 1.5);
  })
  .on('mouseout', function(d){
      d3.selectAll("." + text + "Rect").style('stroke-width', 0.5);
  })
  .on('click', click);
}