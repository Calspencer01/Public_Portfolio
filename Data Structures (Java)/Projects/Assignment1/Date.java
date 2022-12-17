/** Date - An integer representation of the date since Jan 1 1800
  * Date: 9/9/2019
  *
  *@author Calvin Spencer

  Summary:
    The Date class stores an integer representing the number of days since January 1st 1800. I
  created three constructors for the Date class. A default, 0-parameter constructor that sets the
  integer field to 0, representing January 1st 1800. A 1-parameter constructor that directly
  stores the parameterized integer as the date. Lastly, a 3-parameter constructor that converts
  3 integers representing the month/day/year format into the internal single-integer date format.
  The methods and private fields I made are instance methods since this Date class is going to
  be initialized and are inherently dependent to the data given in the constructors. It
  simply doesn't make sense to need access to fields or methods in a class such as this before
  it is created.
    In the toString() method, this integer is converted into a month/day/year format. This is
  done using iterative loops to subtract from a variable, countDown, the days in each year,
  as each year 'passes'. Each iteration, the loop adds a year to the total starting at 1800.
  Once the number of days remaining is less than the length of the year, the year number is
  stored, and the same process is applied to months. Every loop, 1 month is added, and the
  days in the month are subtracted from the total days. This loop ends once the remaining
  days is less than the length of the month. This remaning number of days becomes day of the
  month. For both the month and the year loop, the year length and month lengths vary. The
  methods monthLength() and leapYear() determine these lengths. The final result of toString()
  is a String containing an external representation of the integer value contained within Date.
  In the 3-parameter constructor, the method toDays() is called and does this same process in
  reverse. Where toString() subtracts from a countDown variable, toDays() sums the lengths of
  months and years using a similar looping process, then finally adds the days of the month
  to the final sum. It is intuitive that these two methods, toDays(), and toString() would have
  some kind of commonality considering the roles they are fulfilling are reverses of one another.


*/

public class Date{
  //Private Fields
  private int days;

  /** Default constructor
  */
  public Date(){
    days = 0;
  }

  /** Constructor
  * @param days internal integer date
  */
  public Date(int initDays){
    days = initDays;
  }

  /** Constructor
  * @param month number of months in date
  * @param day day of the month
  * @param year number of years in date
  */
  public Date(int month, int day, int year){
    days = toDays(month, day, year);
  }

  /** Accessor of internal integer date
  * @return days since 1/1/1800
  */
  public int getDate(){
    return days;
  }

  /** Mutator to increment the number of days by given amount
  * @param increment number of days to increase by
  */
  public void incDate(int increment){
    days += increment;
  }

  /** Converts from M/D/Y format to a number of days since 1/1/1800
  * @param month number of months in date
  * @param day day of the month
  * @param year number of years in date
  * @return integer representation of parameterized date
  */
  public int toDays(int month1, int day1, int year1){
    //Local integer for total days that decreases as the years and months are removed from it
    int totDays = 0;

    //Year loop - adds 365 or 366 days for every year
    for (int i = 1800; i < year1; i++){
      if (leapYear(i)){
        totDays += 366;
      }
      else{
        totDays += 365;
      }
    }

    //Month loop - adds number of days in each passed month of the current year
    for (int i = 1; i < month1; i++){
      totDays += monthLength(i, year1);
      //If i = 2, && leapYear(year1)
    }

    //Adds remaining days
    totDays += day1;

    return totDays;
  }

  /** Converts integer date to a String format
  * @return String representation of internal integer date in (M/D/Y) format
  */
  public String toString(){
    //Local integers used to keep track during conversion
    int countDown = days;
    int yearLength = 365;
    int year = 1800;
    int month = 1;
    int day = 1;

    //Loops until days remaining in countDown is less than a year
    while (countDown >= yearLength){

      //Finds length of year
      if (leapYear(year)){
        yearLength = 366;
      }
      else{
        yearLength = 365;
      }

      //Subtracts length of year from countDown
      countDown-= yearLength;

      //Increments the year
      year++;
    }

    //Loops until countDown is less than the length of the upcoming month
    while (countDown > monthLength(month,year)){

      //Subtracts legnth of month from countDown
      countDown -= monthLength(month, year);

      //Increments the number of months
      month++;
    }

    //Day of the month becomes remainder of countDown
    day = countDown;

    //Converts month number to name of the month (not sure if this was necessary...)
    String[] monthStr = {"", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};

    //Returns final string with date in M/D/Y format
    return monthStr[month] + "/" + day + "/" + year;

  }

  /** Finds difference between paramaterized and internal dates
  * @param d1 date object being subtracted from internal date
  * @return int difference between dates
  */
  public int subtract(Date d1){
    return this.days - d1.getDate();
  }

  /** Determines if paramaterized and internal dates are equal
  * @param compDate date object being compared
  * @return boolean for whether dates are equal
  */
  public boolean equals(Date compDate){
    return this.days == compDate.getDate();
  }

  /** Compares difference between paramaterized and internal dates
  * @param compDate date object being compared
  * @return int representing difference (-1, 0, or 1) between compared dates
  */
  public int compareTo(Date compDate){
    int diff = 0;

    //All positive differences result in diff = 1
    if (this.days > compDate.getDate()){
      diff = 1;
    } //All negative differences result in diff = -1
    else if (this.days < compDate.getDate()){
      diff = -1;
    }
    //If dates are equivilent, diff remains 0

    return diff;
  }

  /** Leap year formula for Gregorian calendar
  * @param year year being checked if leap year
  * @return boolean true for leap year, false for non-leap year
  */
  public boolean leapYear(int year){
    boolean leap = false;
    if (year % 100 == 0){
      //If year is divisible by 100 (i.e. 1800, 1900, 2000, 2100)

      if (year % 400 == 0){
        //If leap year is divisible by 400 (i.e. 1600, 2000, 2400)
        leap = true;
      }
    }
    else{
      //If year is not divisible by 100, but is divisible by 4, it is a leap year
      leap = year % 4 == 0;
    }
    return leap;
  }

  /** Returns the length of a month
  * @param monthNum number of the month
  * @param year year number
  * @return int representing length of the month
  */
  public int monthLength(int monthNum, int year){
    //February is 28 days by default
    int febLength = 28;

    //February is set to 29 days if leap year
    if (leapYear(year))
      febLength = 29;

    //Array storying month lengths; index #2 is February's variable
    int[] lengths = {0,31,febLength,31,30,31,30,31,31,30,31,30,31};

    return lengths[monthNum];
  }

}
