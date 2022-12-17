var commaFormat = d3.format(",");
function subsLineGraph(species){
    
    function dotColorSub(x){
        switch (x){
            case 0: return "#4a5763"; break;
            case 1: return "#d62e00"; break;
        }
    }
    var data = subData.filter(d => {
        return d.type == species
    })

    var yMax = d3.max(data, function(d){
        //console.log(d);
        return d.harvest;
    })

    var filteredData = [];
    locations.forEach(l => {
        filteredData[l] = data.filter(d => {
            return d.region == l;
        })
    })
    
    //console.log(locations);


    
    d3.select("#subs").append("p").attr("class", "subsection")
    .text("  Yukon river " + species.toLowerCase() + " harvest by subsistence fishers from 1992-2019")

    var svg = d3.select("#subs").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


    mouseoutSub = function(d){
        d3.select(this)
        .transition().duration(500)
        .style("fill", d => {
            //console.log(restrictionData[d.type][d.year].restriction);
            return dotColorSub(restrictionData[d.type][d.year].restriction)
        })
        .style("stroke", d => {
            //console.log(restrictionData[d.type][d.year].restriction);
            return '#FFF';
        })
        .style("fill-opacity", d => {
            if (d.region == locations[0]){
                return 1;
            }
            else{
                return 0.35;
            }
        })

        d3.selectAll(".tooltip").remove();
    }
    mouseoverSub = function(d){
        d3.select(this)
        .transition().duration(500)
        .style("fill-opacity", d => {
            if (d.region == locations[0]){
                return 1;
            }
            else{
                return 1;
            }
        })
        .style("stroke", d => {
            //console.log(restrictionData[d.type][d.year].restriction);
            return dotColorSub(restrictionData[d.type][d.year].restriction)
        })
        .style("fill", d => {
            //console.log(restrictionData[d.type][d.year].restriction);
            return "#FFF"
            
        }).on('end', function(){})

        svg.append("text")
        .attr("class", "tooltip")
        .attr("x", 200)
        .attr("y",10)
        .attr("text-anchor", "middle")
       
        .style("fill", "#FFF")
        .text(commaFormat(d.harvest) + " " + d.type + " caught in " + d.year + " in the " + d.region + ".")
        .transition().duration(500)
        .style("fill", "#000")
    }

    yearParse = d3.timeParse("%Y");
    var xScale = d3.scaleTime()
    .domain([yearParse(1992), yearParse(2019)]) // input
    .range([0, width-margin.right]); // output

    // 6. Y scale will use the randomly generate number 
    var yScale = d3.scaleLinear()
        .domain([0, yMax*1.2]) // input 
        .range([height,0]); // output 

    //7. d3's line generator
    var line = d3.line()
        .x(function(d, i) { return xScale(yearParse(d.year)); }) // set the x values for the line generator
        .y(function(d) { return yScale(d.harvest); }) // set the y values for the line generator 
        .curve(d3.curveMonotoneX)

        svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + (height+20) + ")")
        .call(d3.axisBottom(xScale)); // Create an axis component with d3.axisBottom

    // 4. Call the y axis in a group tag
    svg.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(" + (-20) + ",0)")
        .call(d3.axisLeft(yScale))
    

    //9. Append the path, bind the data, and call the line generator 
    var yText = 10;
    locations.forEach(region => {
        svg.append("path")
        .datum(filteredData[region]) // 10. Binds data to the line 
        .attr("class", "line line" + region.replace(" ", "_").replace(" ", "_")) // Assign a class for styling 
        .style("stroke", function (d){
            return colors[d[0].region] 
        })
        .style("stroke-opacity", d => {
            if (region == locations[0]){
                return 1;
            }
            else{
                return 0.35;
            }
        })
        .attr("d", line); // 11. Calls the line generator 

        var latestHarvest;
        


    // 12. Appends a circle for each datapoint 
    svg.selectAll(".dot" + region)
        .data(filteredData[region])
    .enter().append("circle") // Uses the enter().append() method
        .attr("class", "dot") // Assign a class for styling
        .attr("cx", function(d, i) {  if (d.year == years[years.length-1]){
            latestHarvest = d.harvest;
        }
        return xScale(yearParse(d.year)); })
        .attr("cy", function(d) { return yScale(d.harvest) })
        .on('mouseover', mouseoverSub)
        .on('mouseout', mouseoutSub)
        .style("stroke", d => {
            //console.log(restrictionData[d.type][d.year].restriction);
            return "#FFF"
        })
        .style("fill", d => {
            //console.log(restrictionData[d.type][d.year].restriction);
            return dotColorSub(restrictionData[d.type][d.year].restriction)
        })
        .style("fill-opacity", d => {
            if (region == locations[0]){
                return 1;
            }
            else{
                return 0.35;
            }
        })
        .style("stroke-opacity", d => {
            if (region == locations[0]){
                return 1;
            }
            else{
                return 1;
            }
        })
        .attr("r", 6);

        svg.append("circle").attr("class", "dot").attr("r", 6).attr("cx", width/2 + 50).attr("cy", 10).style("fill", dotColorSub(0)).style("stroke", "#FFF");
        svg.append("text").attr("x", width/2 + 60).attr("y", 15).style("fill", dotColorSub(0)).text("Subsistence Season");

        svg.append("circle").attr("class", "dot").attr("r", 6).attr("cx", width/2 + 50).attr("cy", 30).style("fill", dotColorSub(1)).style("stroke", "#FFF");;
        svg.append("text").attr("x", width/2 + 60).attr("y", 35).style("fill", dotColorSub(1)).text("Restricted Subsistence Season");

        svg.append("text").attr("x", width- (100+margin.right)).attr("y", yText).style("fill", colors[region]).attr("text-Anchor","left").text(region);
        yText += 20;

        svg.append("text").attr("x", -height/2).attr("y", -100).attr("transform", "rotate(-90)").text("Fish Caught");
    })




   

}