// "Scatter Script"
// Draws scatterplot of deaths vs recoveries
// Called at end of DataScript; Uses 'scatterData'

var xLabelMargin = 20; //Margins for axis labels
var yLabelMargin = 50;
const radioInputHeight = 17; //Height of radio button inputs

var columnFormat = d3.timeFormat("%-m/%-e/%y"); //Format of 'columns' variable (dates being visualized)
var columns = Array.from(getDates("1/22/20", columnFormat(new Date))); // Get dates from DateScript
const plotMin = 10;


 drawScatterplot = function(data, lineData){  //Draw entire scatterplot, given scatterData (caseData for person map)
  var initR = 12, initBuffer = initR/2
  var hoverR = 35, hoverBuffer = hoverR/2;
  
   var scatterSVG = d3.select("#scatter").append("svg") //Build scatterplot SVG
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom + xLabelMargin)
    .append("g")
    .attr("class", "scatterSVG")
   // .attr("fill", "#2d4575")
    .attr("transform", "translate(" + (margin.left) + "," + margin.top + ")")

   var xMax = d3.extent(data, function (d) { return d.confirmed; })[1]; //Get max confirmed
   var yMax = d3.extent(data, function (d) { return d.dead; })[1]; //Get max deaths
   var ratioMin = d3.extent(data, function (d) { return d.ratio })[0]; //Minimum ratio (confirmed / deaths)
   var ratioMax = d3.extent(data, function (d) { return d.ratio; })[1]; //Maximum ratio (confirmed / deaths)

   var deadColor = "#d73027"; //  Y axis color
   var confirmedColor = "#3288ff"; // X axis color

   scatterColor = d3.scaleLog()//Color scale based off ratio (confirmed / deaths)
    .domain([ratioMin, ratioMax])
    .range([colorVals["dead"][4], colorVals["confirmed"][4]]); 

   var scatterX = d3.scaleLog() //Confirmed scale
    .domain([10,xMax*1.2])
    .range([20,width]);

   var scatterY = d3.scaleLog() //Deaths scale
    .domain([1,yMax*1.2])
    .range([height-20,0]);

  

   var xTickVals = [1]; //Arrays being filled with values to display
   var yTickVals = [1]; // D3's .ticks() function does not work with scaleLog(), hence this workaround

   while (xTickVals[xTickVals.length - 1] < xMax){//Build array of x tick values
     xTickVals.push(xTickVals[xTickVals.length - 1]*5);
     xTickVals.push(xTickVals[xTickVals.length - 1]*2);
   }
   while (yTickVals[yTickVals.length - 1] < yMax){ //Build array of y tick values
     yTickVals.push(yTickVals[yTickVals.length - 1]*5);
     yTickVals.push(yTickVals[yTickVals.length - 1]*2);
   }


  //  var percent = 1;
  //  var xTickLineVals = d3.nest() 
  //  .key(d => d)
  //   .rollup(v => {
  //     var y1 = v[0]*(percent/100);
  //     return {
  //       x: v[0],
  //       y: y1
  //     };
  //   })
  //  .entries([100, xMax]);


  //  var tickLine = d3.line()
  //  .curve(d3.curveCatmullRom)
  //  .x(d => scatterX(d.value.x))
  //  .y(d => scatterY(d.value.y));


   var yAxis = d3.axisLeft(scatterY)
               .tickFormat(function (d){  if (yTickVals.includes(d)){ return d3.format(".0f")(d); }//If tick is in array, include it
                                          else{ return ""; }}); //If tick is not in array, format it as empty string
                          
  var xAxis = d3.axisBottom(scatterX)
              .tickFormat(function (d){ if (xTickVals.includes(d)){ return d3.format(".0f")(d); } //If tick is in array, include it
                                        else{ return ""; }});  //If tick is not in array, format it as empty string
                          
  commaFormat = d3.format(","); // Adds comma every 3 digits

  mouseoutScatter = function (d) { //mouseout function: Remove history line, shrink radius, return all opacities to 1.
    d3.selectAll(".countryScatterLine").remove();
    

    d3.select(this) //Select country's circle
     .transition().duration(1)
     .attr("width", initR) //shrink radius
     .attr("height", initR)
     .attr("x", function (d) { return scatterX(d.confirmed) - initBuffer; }) //X Scale with d.confirmed
     .attr("y", function (d) { return scatterY(d.dead) - initBuffer; }) //Y Scale with d.dead


     d3.selectAll(".flag")
     .attr("opacity", 1)

     d3.selectAll(".scattertooltip").remove();
  }

  mouseoverScatter = function (d) { //mouseover function: Enlarge radius of circle, make other circles' opacity lower, add history line
    var selected = null;
    selected = d3.select(this)
    selected.attr("class", "selectedflag");
    d3.selectAll(".flag").transition().duration(1)
    .attr("opacity", 0.35).on('end', function (d){ //workaround because of a bug: opacity was lingering
      selected.attr("class", "image flag");
    })
    var country = "";
    d3.selectAll(".tip") //Select description element in corner of plot
      .attr("x", 40)
      .attr("y", 20)
      .html(function () {
        country = d.country;
      return "<tspan x='0' dy='1.2em'>&nbsp" + d.country + "</tspan>" // Describes the country's data
         + "<tspan x='0' dy='1.2em'>&nbsp" + "Deaths: " + commaFormat(d.dead) + "</tspan>"
         + "<tspan x='0' dy='1.2em'>&nbsp" + "Confirmed: " + commaFormat(d.confirmed) + "</tspan>";
      })
      .transition().duration(200)
      .style('fill', scatterColor(d.ratio));
    
     var byCountry = d3.nest() //Nest by country
     .key(d => d.country)
     .entries(lineData);
 
    var filteredLineData = []; //New data to work with, filtered by country

    var hasKey = false;
    byCountry.forEach(function (d){
        if (d.key == country){ 
            hasKey = true;
            filteredLineData.push(d); 
        }
    });
    
    var scatterplotline = d3.line()
   .curve(d3.curveBasis)
   .x(function (d){ 
     if (d.confirmed >= plotMin){
       return scatterX(d.confirmed)
     }
     else{
       return 0;
     }
    })
    .y(function (d){ 
      if (d.dead >= 1){
        return scatterY(d.dead)
      }
      else{
        return height-10;
      }
     })
     var scatterColorScale = d3.scaleTime();
     scatterColorScale.domain([columns[0], columns[columns.length-1]])
     scatterColorScale.range(["#A0B","#AB0"]);

     //d3.selectAll(".countryScatterLine").remove();
   var countryScatterLine = scatterSVG.selectAll(".countryScatterLine") // Drawing lines
   .data(filteredLineData) //Add data filtered by selected country
   .enter().append("g")
   .attr("class", "countryScatterLine");

    countryScatterLine
    // .data(filteredLineData)
    .append("path")
    .attr("stroke", "#AAA")
    .attr("class", "scatterLine")
    .attr("stroke-width", "5.0px")
    .attr("fill-opacity","0.0")
    .attr("d", function(d){ return scatterplotline(d.values); });

    d3.select(this).moveToFront();
    
    var tipX = 0, tipY = 0, ratio, below = false;

    d3.select(this) //Select country's circle
     .transition().duration(200)
     .attr("width", hoverR) //Expand radius
     .attr("height", hoverR)
     .attr("x", function (d) { 
       tipX = scatterX(d.confirmed); 
       ratio = 1/d.confirmed; 
       return scatterX(d.confirmed) - hoverBuffer; }) //X Scale with d.confirmed
     .attr("y", function (d) { 
       tipY = scatterY(d.dead); 
       ratio = ratio * d.dead; 
       if (tipY < 70){
         tipY += 70; // In case tooltip goes off page
       }
       return scatterY(d.dead) - hoverBuffer; }) //Y Scale with d.dead
     .attr("opacity", 0.85)


    scatterSVG.append("rect").attr("x", tipX - 75).attr("y", tipY - 50)
    .attr("width", 150).attr("height", 30).attr("rx", 5).attr("fill", scatterColor(1/ratio)).attr("class", "scattertooltip").attr("opacity", 0.7)

    var ratioString = (Math.round(100000 * ratio)/1000) + "%"; 

    scatterSVG.append("text").attr("x", tipX - 70).attr("y", tipY - 31)
    .attr("fill", "white").attr("text-anchor", "center").attr("class", "scattertooltip").text("Mortality rate: " + ratioString)
    
  }

  // clickScatter = function (d){
  //   drawPersonMap(d.country,caseData);
  // }

  d3.selection.prototype.moveToFront = function() { //Move to front
    return this.each(function(){
      this.parentNode.appendChild(this);
    });
  };

  // scatterSVG
  // .datum(xTickLineVals)
  // .append("path")
  // .attr("class", "tickLine")
  // .attr("stroke-width", "1.0px")
  // .attr("d", tickLine);
  

  var dots = scatterSVG.selectAll(".flag") //Plot data points
   .data(data) //Enter scatterData
   .enter()
   .append("svg:image")
   .attr("xlink:href",function (d) {
     var src = 'Flags/' + d.country.toLowerCase() + '.svg';
     src = src.replace(/ /g, '-');
     src = src.replace(/'/g, '');
      return src;
   })
   .attr("class", "image flag")
   .attr("width", initR)
   .attr("height", initR)
   .attr("x", function (d) { return scatterX(d.confirmed) - initBuffer; }) //X Scale with d.confirmed
   .attr("y", function (d) { return scatterY(d.dead) - initBuffer; }) //Y Scale with d.dead
   .on('mouseover', mouseoverScatter)
   .on('mouseout',mouseoutScatter);


 scatterSVG.append("text") //X axis label
  .attr("transform", "translate(" + (width/2) + " ," + ( 10 + height + margin.top + xLabelMargin/2) + ")")
  .style("text-anchor", "middle")
  .style("font-size", "16px")
  .style('fill', colorVals["confirmed"][4])
  .text("Confirmed");

  scatterSVG.append("text") //Y axis label
    .attr("transform", "rotate(-90)")
    .attr("y", 0 - (yLabelMargin + 15))
    .attr("x",0 - (height / 2) )
    .attr("dy", "1em")
    .style("text-anchor", "middle")
    .style("font-size", "16px")
    .style('fill', colorVals["dead"][4])
    .text("Deaths");

  scatterSVG.append("text") //Description
    .attr("class", "tip")
    .attr("y", 20)
    .attr("x", 100)
    .attr("dy", "1em")
    .style("text-anchor", "left")
    .style('fill', "white")
    .style("stroke-width", "1")
    .style("font-size", "18px")
    .text("Country"); //Default (arbitrary)

  scatterSVG.append("g") //Draw x axis
    .attr("transform", "translate(0," + height + ")")
    .attr("class", "axisBottom")
    .call(xAxis);

  scatterSVG.append("g") //Draw y axis
    .attr("class", "axisLeft")
    .call(yAxis);

};
