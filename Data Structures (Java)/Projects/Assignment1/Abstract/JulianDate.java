/** JulianDate - Inherited from the date class, implements leap years based off the Gregorian Calendar
  * Date: 9/12/2019
  *
  *@author Calvin Spencer

  Summary:
    This subclass of Date is specialized for the Julian calendar. Both classes contain
    the same three constructors, which simply refer to the constructors in Date. The
    only difference between this class and GregorianDate is the functionality of
    leapYear() since in the Julian calendar, every single year divisible by 4 is a
    leap year with no exceptions (unlike the Gregorian calendar).

*/
public class JulianDate extends Date{
  /** Default constructor
  */
  public JulianDate(){
    super();
  }

  /** Constructor
  * @param days internal integer date
  */
  public JulianDate(int days){
    super(days);
  }

  /** Constructor
  * @param month number of months in date
  * @param day day of the month
  * @param year number of years in date
  */
  public JulianDate(int month, int day, int year){
    super(month,day,year);
  }

  /** Leap year formula for Julian calendar
  * @param year year being checked if leap year
  * @return boolean true for leap year, false for non-leap year
  */
  @Override
  public boolean leapYear(int year){
    return (year % 4) == 0;
  }
}
