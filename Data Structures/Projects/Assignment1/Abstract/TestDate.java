/** TestDate - Tests classes inherited from the abstract Date class
  * Date: 9/12/2019
  *
  *@author Calvin Spencer

  Summary:
      This class tests the subclasses GregorianDate and JulianDate. It declares two instances
    of each class, and prints the string representations of d1 and d2 (Gregorian and Julian)
    respectively. It also prints whether d3 and d4 are leap years, which should be different
    because 1900 is a leap year in the Julian calendar, but not the Gregorian calendar. This
    method was made specifically because my Date class did not include accessors to the month,
    day, or year of the internal date represented by a single int. Instead, isLeapYear()
    calculates the year of the object within the method, and then uses that year to determine
    whether the boolean should be true or false (if it is a leap year or not).

*/

public class TestDate{
  public static void main(String[] args){ //Main Method
    //Local Date (Gregorian or Julian) objects
    GregorianDate d1 = new GregorianDate(9,1,2019);
    JulianDate d2 = new JulianDate(9,1,2019);
    GregorianDate d3 = new GregorianDate(36526);
    JulianDate d4 = new JulianDate(36526);

    System.out.println(d1.toString());
    System.out.println(d2.toString());
    System.out.println(d3.isLeapYear());
    System.out.println(d4.isLeapYear());

  }

}
