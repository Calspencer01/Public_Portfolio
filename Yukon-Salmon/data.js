var margin = {top: 10, right: 150, bottom: 40, left: 150}
, width = window.innerWidth - margin.left - margin.right // Use the window's width 
, height = window.innerHeight/2 - margin.top - margin.bottom; // Use the window's height
queue()
    .defer(d3.csv, "SalmonCommercial.csv")
    .defer(d3.csv, "SalmonData.csv")
    .await(ready);

var species = ["Coho", "Chinook", "Chum"];
var locations = ["Yukon Area Total", "Lower Yukon", "Upper Yukon", "Yukon Costal District"];
var years = [];
for (var i = 1992; i < 2020; i++){
    years.push(i);
}

var colors = [];
colors[locations[2]] = "#448f9e"
colors[locations[0]] = "#1c3a9c"
colors[locations[1]] = "#498707"
colors[locations[3]] = "#e3b330"

var comData = []; comData[species[0]] = []; comData[species[1]] = []; comData[species[2]] = []; //Commercial Data
var subData = []; //subData[species[0]] = []; subData[species[1]] = []; subData[species[2]] = []; //Subsitence Data
var housingData = [];
var restrictionData = [];



function ready(error, commercial, subsistence){
    species.forEach(s => {
        restrictionData[s] = [];
    })
    // console.log(commercial);
    // console.log(subsistence);

    commercial.forEach(d => {
        species.forEach(i => {
            if (i == d["Species Common"]){
                comData[i].push({
                    species: i,
                    year: d.Year,
                    harvest: d["Number Of Fish"]
                });
            }
        })
    })

    //console.log(subsistence);
    subsistence.forEach(d => {
        var region = d.Region;
        var type = d.Type;
        var id = region + " " + type;
        var fishData = d3.set(species).has(type);
        var timeSeries = [];
       // console.log(d);
        years.forEach(y => {
            if (fishData){
                subData.push({
                    harvest:+d[y],
                    year: y,
                    id: id,
                    type: type,
                    region: region
                })
            }
           
            
            // timeSeries.push({
            //     harvest:+d[y],
            //     year: y
            // });
        })
        if (type == "Households"){
            years.forEach(y => {
                housingData.push({
                    region: region,
                    year: y,
                    households: +d[y]
                })
            })
        }

       // console.log (type.indexOf(" Restriction"));
        if (type.indexOf(" Restriction") > 0){
           // console.log(D);
            years.forEach(y => {
                var species = d.Type.replace(" Restriction", "")
                var restriction = 0;
                if (d[y] == "Y")
                {
                    restriction = 1;
                }
                
                // console.log(species);
                restrictionData[species][y] = {
                    year: y,
                    restriction: restriction,
                    type: species
                }
            })
        }
       
        

        // if (fishData){
        //     subData[type][region] = {
        //         region: region,
        //         species: type,
        //         id: id,
        //         history: timeSeries
        //     }
        // }

    })

    //console.log(housingData);
    //console.log(subData);
    //console.log(restrictionData);

    // [Coho: Array(0), Chinook: Array(0), Chum: Array(0)]
    // Chinook: Array(0)
    // Lower Yukon: {region: "Lower Yukon", species: "Chinook", id: "Lower Yukon Chinook", history: Array(28)}
    // Upper Yukon:
    // history: Array(28)
    // 0: {harvest: 28, year: 1992}
    // 1: {harvest: 420, year: 1993}
    // console.log(comData);

  
    console.log(comData);
    console.log(subData);
   
    subsLineGraph("Chinook");
    subsLineGraph("Chum");
    subsLineGraph("Coho");

    comLineGraph("Chinook");
    comLineGraph("Chum");
    comLineGraph("Coho");

    

     //comDataFiltered
}