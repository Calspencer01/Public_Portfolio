function comLineGraph(species){
    var commercialColor = "#0f6396"
    var subsitenceColor = "#038067"

    function dotColorCom(x){
        switch (x){
            case 0: return subsitenceColor; break;
            case 1: return "#d62e00"; break;
        }
    }

    var filteredSubData = subData.filter(d => {
        return (d.type == species && d.region == "Yukon Area Total" && d.year < 2019)
    })

    var filteredComData = comData[species];

    // console.log(filteredComData);
    // console.log(filteredSubData);

    d3.select("#coms").append("p").attr("class", "subsection")
    .text("Yukon river " + species.toLowerCase() + " harvest by subsistence fishers vs commercial fishers from 1992-2018")

    var svg = d3.select("#coms").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    mouseoverCom = function(d){
        var txt = "";
        d3.select(this)
        .transition().duration(500)
        .style("fill-opacity", d => {
            return 1;
        })
        .style("stroke", function(){
            //console.log(restrictionData[d.type][d.year].restriction);
            var clr = commercialColor
            if (d.species == null){
                txt = commaFormat(d.harvest) + " " + species.toLowerCase() + " caught in " + d.year + " for subsitence.";
                clr = dotColorCom(restrictionData[species][d.year].restriction);
            }
            else{
                txt = commaFormat(d.harvest) + " " + species.toLowerCase() + " caught in " + d.year + " commercially.";
            }
            return clr;
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
        .text(txt)
        .transition().duration(500)
        .style("fill", "#000");
    }

    mouseoutCom = function(d){
        d3.select(this)
        .transition().duration(500)
        .style("fill", function(){
            //console.log(restrictionData[d.type][d.year].restriction);
            var clr = commercialColor
            if (d.species == null){
                clr = dotColorCom(restrictionData[species][d.year].restriction);
            }
            return clr;
            //return dotColorCom(restrictionData[d.type][d.year].restriction)
        })
        .style("stroke", d => {
            //console.log(restrictionData[d.type][d.year].restriction);
            return '#FFF';
        });

         d3.selectAll(".tooltip").remove();
    }

    var yMax = d3.max(filteredComData, function(d){
        return d.harvest;
    })
    yearParse = d3.timeParse("%Y");
    var xScale = d3.scaleTime()
    .domain([yearParse(1992), yearParse(2018)]) // input
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

     svg.append("path")
     .datum(filteredComData) // 10. Binds data to the line 
     .attr("class", "line lineCommercial") // Assign a class for styling 
     .style("stroke", function (d){
         return commercialColor;
     })
     .style("stroke-opacity", d => {
         // if (region == locations[0]){
             return 1;
         // }
         // else{
         //     return 0.35;
         // }
     })
     .attr("d", line); // 11. Calls the line generator 

     svg.append("path")
     .datum(filteredSubData) // 10. Binds data to the line 
     .attr("class", "line lineSubsitence") // Assign a class for styling 
     .style("stroke", function (d){
         return subsitenceColor;
     })
     .style("stroke-opacity", d => {
         // if (region == locations[0]){
             return 1;
         // }
         // else{
         //     return 0.35;
         // }
     })
     .attr("d", line); // 11. Calls the line generator 
    


 // 12. Appends a circle for each datapoint 
 svg.selectAll(".dotCommercial")
     .data(filteredComData)
 .enter().append("circle") // Uses the enter().append() method
     .attr("class", "dot dotCommercial") // Assign a class for styling
     .attr("cx", function(d, i) { return xScale(yearParse(d.year)) })
     .attr("cy", function(d) { return yScale(d.harvest) })
     .on('mouseover', mouseoverCom)
     .on('mouseout', mouseoutCom)
     .style("stroke", d => {
         //console.log(restrictionData[d.type][d.year].restriction);
         return "#FFF"
     })
     .style("fill", d => {
         //console.log(restrictionData[d.type][d.year].restriction);
         return commercialColor;
     })
     .attr("r", 6);

     svg.selectAll(".dotSubsitence")
     .data(filteredSubData)
 .enter().append("circle") // Uses the enter().append() method
     .attr("class", "dot dotSubsistence") // Assign a class for styling
     .attr("cx", function(d, i) { return xScale(yearParse(d.year)) })
     .attr("cy", function(d) { return yScale(d.harvest) })
     .on('mouseover', mouseoverCom)
     .on('mouseout', mouseoutCom)
     .style("stroke", d => {
         //console.log(restrictionData[d.type][d.year].restriction);
         return "#FFF"
     })
     .style("fill", d => {
         //console.log(restrictionData[d.type][d.year].restriction);
         return dotColorCom(restrictionData[species][d.year].restriction)
     })
     .attr("r", 6);

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + (height+20) + ")")
        .call(d3.axisBottom(xScale)); // Create an axis component with d3.axisBottom

    // 4. Call the y axis in a group tag
    svg.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(" + (-20) + ",0)")
        .call(d3.axisLeft(yScale));

    svg.append("circle").attr("class", "dot").attr("r", 6).attr("cx", width/2 + 50).attr("cy", 30).style("fill", dotColorCom(0)).style("stroke", "#FFF");
    svg.append("text").attr("x", width/2 + 60).attr("y", 35).style("fill", dotColorCom(0)).text("Subsistence Season");

    svg.append("circle").attr("class", "dot").attr("r", 6).attr("cx", width/2 + 50).attr("cy", 50).style("fill", dotColorCom(1)).style("stroke", "#FFF");;
    svg.append("text").attr("x", width/2 + 60).attr("y", 55).style("fill", dotColorCom(1)).text("Restricted Subsistence Season");
    
    svg.append("circle").attr("class", "dot").attr("r", 6).attr("cx", width/2 + 50).attr("cy", 10).style("fill", commercialColor).style("stroke", "#FFF");;
    svg.append("text").attr("x", width/2 + 60).attr("y", 15).style("fill", commercialColor).text("Commercial Season (always regulated)");

    svg.append("text").attr("x", -height/2).attr("y", -100).attr("transform", "rotate(-90)").text("Fish Caught");
}