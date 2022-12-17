// "Init Script"
// Builds dataframes: lineData, caseData, scatterData for lineplot, mapviz, scatterplot respectively.
// Sets margins & visualization dimensions, color variables
// Calls each visualization at the end 

var columnFormat = d3.timeFormat("%-m/%-e/%y"); //Date format of "columns" array
var columns = Array.from(getDates("1/22/20", columnFormat(new Date)));
var stateData = null; 
var missingDays = 1; //Days since last daily_reports_us CSV

initStateData() //Initialize state data

function initStateData(){ //Queue and return result of previous day's state data
  queue()
    .defer(d3.csv, "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports_us/" + getCSVDate(missingDays) + ".csv")
    .await(setStateData)
}
  
function setStateData(error, data){
  if (error == null){ //If there is no error, file is present
    stateData = data;
  }
  else{ // Else, try the previous day's CSV file
    console.log("Missing " + getCSVDate(missingDays) +" data; Now trying " + getCSVDate(missingDays + 1));
    missingDays ++;;
    initStateData() //Try again
  }
}


queue() //Load data from John Hopkins GitHub
//https://raw.githubusercontent.com/PublicaMundi/MappingAPI/master/data/geojson/us-states.json
  .defer(d3.csv, "Data/statenames.csv") //Names of states and their abbreviations
  .defer(d3.csv, "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv") //Global recoveries
  .defer(d3.csv, "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv") //Global confirmed cases
  .defer(d3.csv, "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv") //Global deaths
  .defer(d3.csv, "Data/world_populations.csv") //Populations of countries
  .defer(d3.json, "Data/editedworld.geo.json") //Edited with country names replaced. Not all countries have data on John Hopkins
  .await(ready)

function ready(error,stateNames,recoveredData,confirmedData,deathsData,populations,map) {
var caseData = []; //Arrays by mode, country, then date of # cases
var countries = []; //Array of all country names
var countryPopulation = []; //Array of country populations
var byState = []; //Array of data by state
caseData["confirmed"] = [];
caseData["recovered"] = [];
caseData["dead"] = [];
 
function loadData(data, label){ //Load data from CSV to caseData
 data.forEach(d => {
   var timeSeries = [];

   columns.forEach(function(column){ //For each date, load the # of cases
     if (caseData[label].hasOwnProperty(d["Country/Region"])){ //Add them to the sum for that country
       timeSeries[column] = +caseData[label][d["Country/Region"]][column] + (+d[columnFormat(column)]);
     } //Aus, China, Canada, Denmark, UK, Netherlands, France
     else{ //First value for that country
       timeSeries[column] = +d[columnFormat(column)];
     }
     if (!countries.includes(d["Country/Region"])){ //Build array of all countries
       countries.push(d["Country/Region"]);
     }
   });
   d.dateData = timeSeries; //Set caseData cases from CSV
   caseData[label][d["Country/Region"]] = d.dateData;
 });
}
  //call loadData function for each of the three data 'modes'

loadData(confirmedData,"confirmed")
loadData(deathsData,"dead")
loadData(recoveredData,"recovered")

populations.forEach(d => {
  if (!countryPopulation.hasOwnProperty(d.Location)){
    countryPopulation[d.Location] = 1000*(+d.PopTotal);
  }
});

stateData.forEach(function (d){
  // if (d.Province_State == "Vermont"){
  //   console.log(d);
  // }
  var active = d.Active;
  if (d.Country_Region == "US"){
    byState.push({
      active: +active,
      confirmed: +d.Confirmed,
      recovered: +d.Recovered,
      dead: +d.Deaths,
      state: d.Province_State,
      tested: +d.People_Tested
    })
  }
});

var formatParse = d3.timeParse("%m/%e/%y");
map.features.forEach(function(d) {
  if(caseData["confirmed"].hasOwnProperty(d.properties.name)){ //enter caseData into map.features
    if (caseData["confirmed"][d.properties.name] != undefined){
      d.confirmed = caseData["confirmed"][d.properties.name];
      d.dead = caseData["dead"][d.properties.name];
      d.recovered = caseData["recovered"][d.properties.name];
    }
    else{ //Set defaults if undefined
      d.confirmed = 0;
      d.dead = 0;
      d.recovered = 0;
    }
  }
});

scatterData = []; //Data for scatterplot
lineData = []; //Data for lineplot

for (var i = 0; i < countries.length; i++){ //Iterate by each country
  var dead = caseData["dead"][countries[i]][columns[columns.length-1]];
  var confirmed = caseData["confirmed"][countries[i]][columns[columns.length-1]];
  var ratio = (+confirmed)/(+dead); //Calculate scatterplot ratio

  if (dead > 0 && confirmed > 10){ //Only if values are valid, & country has >100 confirmed
    scatterData.push({
      confirmed: confirmed,
      dead: dead,
      country: countries[i],
      ratio: ratio
    })
    for (var l = 0; l < columns.length; l++){ //Iterate through each date
    lineDead = caseData["dead"][countries[i]][columns[l]];
    lineRecovered = caseData["recovered"][countries[i]][columns[l]];
    lineConfirmed = caseData["confirmed"][countries[i]][columns[l]];
    lineActive = lineConfirmed - lineRecovered - lineDead;

    //Add to lineData
    lineData.push({ dead: lineDead,
                    confirmed: lineConfirmed,
                    recovered: lineRecovered,
                    active: lineActive,
                    country: countries[i],
                    date: columns[l] });
    }
   }
 }

//Sum worldwide cases
for (var l = 0; l < columns.length; l++){ //Iterate through each date
  var totDead = 0, totRecovered = 0, totConfirmed = 0, totActive = 0; //Totals
  
  for (var i = 0; i < countries.length; i++){ //Iterate through countries & sum up totals
    totDead += caseData["dead"][countries[i]][columns[l]];
    totRecovered += caseData["recovered"][countries[i]][columns[l]];
    totConfirmed += caseData["confirmed"][countries[i]][columns[l]];
  }

  totActive = (totConfirmed - totRecovered - totDead); //Calculate active

  lineData.push({ //Add totals to lineData
    dead: totDead,
    confirmed: totConfirmed,
    recovered: totRecovered,
    active: totActive,
    date: columns[l],
    country: "Worldwide"
  });
}

  function getPopulation(country){ //Returns population of given country
    if (countryPopulation.hasOwnProperty(country)){
      return countryPopulation[country];
    }
    else{
      console.log("no population for: " + country);
      return -1;
    }
  }

 drawMap(caseData, columns[0], map); //Draw initial map at first available date
 animateMap(caseData,map); //Updating fill colors
 drawScatterplot(scatterData, lineData); //Draw scatterplot 
 drawRadialBar(byState, stateNames, false, false, false, true); //Draw radial bar graph
}

var windowWid = window.innerWidth; //Get window width 
var windowHgt = window.innerHeight; //Get window height

var margin = {top: 20, right: 80, bottom: 30, left: 120}, //Margins & dimensions
  width = windowWid - margin.left - margin.right,
  height = windowHgt/1.5 - margin.top - margin.bottom;

var colorVals = []; //Colors for color scales
colorVals["confirmed"] = ["#deebf7","#c6dbef","#6baed6","#2171b5","#08519c","#08306b", "#000"];
colorVals["active"] =    ["#efedf5","#dadaeb","#9e9ac8","#756bb1","#54278f","#3f007d", "#000"];
colorVals["recovered"] = ["#ccece6","#99d8c9","#66c2a4","#2ca25f","#006d2c","#00441b", "#000"];
colorVals["dead"] =      ["#fee0d2","#fcbba1","#fb6a4a","#de2d26","#a10f15","#750f15", "#000"];