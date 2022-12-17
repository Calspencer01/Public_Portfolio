// "Slider Script"
// Adapted from https://bl.ocks.org/johnwalley/e1d256b81e51da68f7feb632a53c3518
// Slider bar with handle so the user can input date of map visualization

var formatDateIntoYear = d3.timeFormat("%Y");
var formatDate = d3.timeFormat("%b %Y");
var tickFormat = d3.timeFormat("%-m/%-e/%y");
var tickParse = d3.timeParse("%-m/%-e/%y");

var sliderMargin = 50;
var sliderHeight = 120;

var startDate = columns[0] //Get start and end dates from columns set
var endDate = columns[columns.length-1];

var sliderSVG = d3.select("#slider") //Slider SVG
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", sliderHeight)

var x = d3.scaleTime() // Slider time scale
    .domain([startDate, endDate])
    .range([sliderMargin, width - sliderMargin])
    .clamp(true); // "the return value of the scale is always within the scale’s range"

var slider = sliderSVG.append("g") //Slider line
    .attr("class", "slider")
    .attr("transform", "translate(" + margin.left + "," + sliderHeight/2 + ")");

slider.append("line")
    .attr("class", "track")
    .attr("x1", x.range()[0])
    .attr("x2", x.range()[1])
  .select(function() { return this.parentNode.appendChild(this.cloneNode(true)); })
    .attr("class", "track-inset")
  .select(function() { return this.parentNode.appendChild(this.cloneNode(true)); })
    .attr("class", "track-overlay")
    .call(d3.drag() //When handle is dragged
        .on("start.interrupt", function() { if (!mapAnimating) {slider.interrupt(); }})
        .on("start drag", function() { if (!mapAnimating) { newDate(x.invert(d3.event.x), d3.event.x, x.range()[1]); }}));

slider.insert("g", ".track-overlay") //Slider track
    .attr("class", "ticks")
    .attr("transform", "translate(0," + 18 + ")")
  .selectAll("text")
    .data(x.ticks(15))
    .enter()
    .append("text") // Tick labels
    .attr("x", x)
    .attr("y", 10)
    .attr("text-anchor", "middle")
    .text(function(d) { return tickFormat(d); });

var label = slider.append("text") //Handle label of current date
    .attr("class", "label")
    .attr("text-anchor", "middle")
    .attr("x",sliderMargin)
    .text(tickFormat(startDate))
    .attr("transform", "translate(0," + (-20) + ")")

var handle = slider.insert("circle", ".track-overlay") //Slider handle
    .attr("class", "handle")
    .attr("r", 9)
    .attr("cx",sliderMargin);

// var description = slider.append("text") // Slider instructions
//     .attr("class", "label")
//     .attr("transform", "translate(" + (width/2) + "," + (-50) + ")")
//     .attr("text-anchor", "middle")
//     .attr("x", 0)
//     .attr("font-weight", 500)
//     .text("Hover over a country to see info. Click on a country to view its graph.");

var playButtonText = sliderSVG.append("text")
    .attr("text-anchor", "middle")
    .attr("class", "playText playButton")
    .attr("x", 100).attr("y", 80)
    .text("Play");
var playButtonRect = sliderSVG.append("rect")
    .attr("fill-opacity", 0.0)
    .attr("class", "playRect playButton")
    .attr("stroke", "black")
    .attr("x", 75).attr("y", 65)
    .attr("rx", 3).attr("ry", 3)
    .attr("height", 20).attr("width", 50)
    .on('mouseover', function(d){
        d3.selectAll(".playRect").style('fill-opacity', 0.2);
    })
    .on('mouseout', function(d){
        d3.selectAll(".playRect").style('fill-opacity', 0.0);
    })
    .on('click', playClick)

function playClick(){
    mapAnimating = !mapAnimating;
    
    if (mapAnimating){
        if (formatDate(setDate) == formatDate(columns[columns.length-1])){
            restartAnimation = true;
        }
        d3.selectAll(".playText").text("Pause")
    }
    else{
        
        drawMapButtons()
        d3.selectAll(".playText").text("Play")
    }
}

function transitionSlider(){
    // handleX = getSliderX(setDate);
    handleX = x(setDate);
    handle.transition().duration(50).attr("cx", handleX);
    label
        .transition().duration(50)
        .attr("x", handleX)
        .text(tickFormat(setDate));
}

function getSliderX(){
    var xLoc = 0;
    while (x(xLoc) != setDate){
        console.log(x(xLoc));
        xLoc+= 10;
    }
    return xLoc;
}

function newDate(x, handleX, max){  //Slider dragged
  if (handleX > max){handleX = max}
  if (handleX < sliderMargin){handleX = sliderMargin}
  setDate = tickParse(tickFormat(x));
  verticalLineUpdate(setDate);
  handle.attr("cx", handleX);
  label
    .attr("x", handleX)
    .text(tickFormat(addDays(x,0)));

}
