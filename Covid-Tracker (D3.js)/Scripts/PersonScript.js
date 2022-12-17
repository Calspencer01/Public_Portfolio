//"Person Script"
// grid of icons representing a proportion of population (1000 people: .1% each)
// Modal from Radial Bar Graph

//Array is made of gridWid * gridHgt 'people'
const gridWid = 40, iconWid = (width-margin.right)/gridWid;
const gridHgt = 25, iconHgt = height/gridHgt;
var stateData; // data filtered by selected state

function drawPersonMap(state, caseData, personSVG){
    
    //Data filtered by state
    stateData = caseData.filter(function (d){
        return d.state == state;
    });
    
   // d3.selectAll(".personSVG").remove(); //Remove any previous personmap

    var description = personSVG.append("text")
    .attr("x", (width + margin.left + margin.right) /2)
    .attr("text-anchor", "middle")
    .attr("class", "personSVG personMapDescription")
    .attr("y", height/4 + 20)
    .text("Showing %Tested Negative, %Active Cases, %Recoveries, and %Deaths. Each person = 0.1%")

    var persons = personSVG.selectAll(".personIcon")
        .data(getPersonArray(stateData, state)) //Enter array of icons from stateData for personmap
        .enter()
        .append("svg:image")
        .attr("xlink:href",function (d) {
            return 'Icons/' + d.src + '.svg'; //Finds svg image for that 'type' of person (tested, active case, dead, or recovered)
        })
        .attr("class", function (d){ //Class depends on type of source
            return "personSVG personIcon " + d.src;
        })
        .attr("width", iconWid*1.5)
        .attr("height", iconHgt*1.2)
        .attr("x", function (d) {
            return margin.left+ d.x;
        })
        .attr("y", function (d) { 
            return height/4 + d.y
        })
        .attr("opacity", .60)
        .on('mouseover', function (d){ //Disappointingly slow 
            d3.selectAll("." + d.src)
            .attr("width", iconWid*1.6)
            .attr("height", iconHgt*1.2)
            .attr("opacity", function(d){
                return 1;
        });

            d3.selectAll(".personMapDescription")
            .text(d.descr);
        })
        .on('mouseout', function (d){ 
            d3.selectAll("." + d.src)
            .attr("width", iconWid*1.5)
            .attr("height", iconHgt*1.2)
            .attr("opacity", function(d){
                return 0.60;
        });
    });

    personSVG.append("text")  //Exit Button text
        .attr("class", "personSVG exitButton")
        .attr("y", height/4 + 10)
        .attr("x", margin.left + 40)
        .attr("dy", "1em")
        .style("text-anchor", "middle")
        .style("font-size", 16)
        .style('fill', "#960000")
        // .on('mouseover', function(d){
        //     d3.selectAll(".exitRect").style('fill-opacity', 0.1);
        // })
        // .on('mouseout', function(d){
        //     d3.selectAll(".exitRect").style('fill-opacity', 0.0);
        // })
        // .on('click', function(d){
        //     d3.selectAll(".exitButton").style('fill', "#fc0303").transition().duration(300).style('fill', "#960000").on("end", function(){
        //         //removeModal();
        //     })
        // })
        .text("Exit");

    personSVG.append("rect") //Exit button rect
        .attr("class", "personSVG exitButton exitRect").style('stroke', "#960000").style('fill', "#960000").style('fill-opacity', 0.0)
        .attr("y", height/4 + 10)
        .attr("x", margin.left + 15)
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
                removeModal();
            })
        })
}

function getPersonArray(data, state){ //Get array of "people" with sources for the svg
    var personIcons = []; //array of srcs
    var personDescription = [];
    var recoveredAbsolute = data[0].recovered; //Absolute # of each
    var confirmedAbsolute = data[0].confirmed;
    var deadAbsolute = data[0].dead;
    var activeAbsolute = data[0].active;
    var tested = data[0].tested; // Absolute # of tested 

    // # icons = (#people) * (# of each type) / # tested (e.g. if 1000 "people", each icon represents 0.1% of the tested population)
    var recoveredIcons = Math.round(gridWid*gridHgt * recoveredAbsolute /tested);
    var activeIcons =    Math.round(gridWid*gridHgt * activeAbsolute    /tested);
    var deadIcons =      Math.round(gridWid*gridHgt * deadAbsolute      /tested);
    var testedIcons = gridWid*gridHgt - recoveredIcons - activeIcons - deadIcons;

    for (var i = 0; i < deadIcons; i++){ //Load icons into src array
        personIcons.push('deadman');
        personDescription.push((deadIcons/10) + '% of those tested in ' + state + " have died from COVID-19.");
    }
    for (var i = 0; i < recoveredIcons; i++){
        personIcons.push('recoveredman');
        personDescription.push((recoveredIcons/10) + '% of those tested in ' + state + " have recovered from COVID-19.");
    }
    for (var i = 0; i < activeIcons; i++){
        personIcons.push('infectedman');
        personDescription.push((activeIcons/10) + '% of those tested in ' + state + " still have COVID-19.");
    }
    for (var i = 0; i < testedIcons; i++){
        personIcons.push('testedman');
        personDescription.push((testedIcons/10) + '% of those tested in ' + state + " tested negative for COVID-19.");
    }
   
    var index = 0; //index in the personIcons array
    for (var y = 0; y < gridHgt; y++){
        for (var x = 0; x < gridWid; x++){
            var xLoc = x * iconWid; //Get x and y coordinates for the person
            if (y % 2 == 0){
                xLoc += (iconWid/2);
            }
            var yLoc = 50 + y * iconHgt;
            var tempSrc = personIcons[index];
            personIcons[index] = null;
            personIcons[index] = { //Load coordinates and src into array
                src: tempSrc,
                x: xLoc,
                y: yLoc,
                descr: personDescription[index]
            };
            index++;
        }
    }
    return personIcons;
}