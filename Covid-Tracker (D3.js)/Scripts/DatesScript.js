// "Dates Script"
// Some functions to help organize data/simplify code
// 'columns' array stores all dates of data being visualized

function addDays(date, days) { //Date adder
  var result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
}

function getDates(startDate) { //Get set of all dates from start date to current date
  var formatDays  = d3.timeFormat("%j");
  var formatParse = d3.timeParse("%m/%e/%y");

  var iterations = formatDays(new Date) - formatDays(formatParse(startDate)); //Number of days to visualize (start date to today)
  let dates = new Set();
  var addDate = formatParse(startDate);

  var i = 0;
  while (dates.size < iterations-1){ //Get rid of -1 if there is an updated dataset for current day
    i++;
    dates.add((addDays(addDate, i))); //Increase date by 1 day
  }
  return dates;
}

function getCSVDate(i){ //returns date in the format of the csv link.
  format = d3.timeFormat("%m-%d-%Y");
  return format(addDays(new Date, -1*i));  // Subtracts days because file is always from previous day (or before: see initStateData() & setStateData() in 'initScript')
}
