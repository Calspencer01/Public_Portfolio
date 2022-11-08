/** Date - Abstract class containing the integer representation of the date since Jan 1 1800
  * Date: 9/12/2019
  *
  *@author Calvin Spencer


  Summary:
    This class functions the exact same as Date in problem 2, however it
  is an abstract class due to the differing formulas used to determine
  leap years in the subclasses GregorianDate and JulianDate. The method
  leapYear() is abstract for this reason. Other than leapYear() and the
  3 constructors, no other code was moved into the subclasses from
  problem 2 to problem 3. This is logical considering the only difference
  between Gregorian and Julian calendars are how they count leap years.
  Other than leapYear(), no other methods should be abstract since they
  all function the same in either date format. 

*/

public abstract class Date{
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

  /** Returns whether parameterized year is a leap year
  * @param year1 year being checked if leap year
  * @return boolean of whether parameterized year is a leap year
  */
  public abstract boolean leapYear(int year1);

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

  /** Determines whether year of internal date is leap year
  * @return boolean of whether internalized date is in a leap year
  */
  public boolean isLeapYear(){
    //Local integers used to keep track during conversion (to years)
    int countDown = days;
    int yearLength = 365;
    int year = 1800;

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
    return leapYear(year);
  }

}
