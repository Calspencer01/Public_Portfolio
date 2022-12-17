/** GregorianDate -  Inherited from the date class, implements leap years based off the Gregorian Calendar
  * Date: 9/12/2019
  *
  *@author Calvin Spencer

  Summary:
    This subclass of Date is specialized for the Gregorian calendar. Considering
  how the only difference between the Gregorian and Julian calendars are the way
  that they count leap years, the only method needing to be overridden is the
  leapYear() method. The formula in this version of it does not include century
  other than those divisible by 400. The three constructors allow for this class
  to be made with the default date, a single parameter constructor for an int-
  representation of the date, and finally a 3 parameter constructor for the
  month/day/year format of the date. 

*/
public class GregorianDate extends Date{

  /** Default constructor
  */
  public GregorianDate(){
    super();
  }

  /** Constructor
  * @param days internal integer date
  */
  public GregorianDate(int days){
    super(days);
  }

  /** Constructor
  * @param month number of months in date
  * @param day day of the month
  * @param year number of years in date
  */
  public GregorianDate(int month, int day, int year){
    super(month,day,year);
  }

  /** Leap year formula for Gregorian calendar
  * @param year year being checked if leap year
  * @return boolean true for leap year, false for non-leap year
  */
  @Override
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
}
