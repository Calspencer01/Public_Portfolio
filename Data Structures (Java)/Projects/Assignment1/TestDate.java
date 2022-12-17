/** TestDate - Class with main method designed to test the Date class via outputs
  * Date: 9/9/2019
  *
  *@author Calvin Spencer

  Summary: This class is designed simply to create 2 instances of the Date Class
  and test out the functionality various methods. The outputs within the main
  method print the results of compareTo(), equals(), and toString().


*/


public class TestDate{
  public static void main(String[] args){  //Main Method
    //Local instances of Date class
    Date d1 = new Date(8,31,2019);
    Date d2 = new Date(9,1,2019);

    //Outputs
    System.out.println("d1 compared to d2: " + d1.compareTo(d2));
    System.out.println("d1 equals(?) d2: " + d1.equals(d2));
    System.out.println("d1 toString: " + d1.toString());
    System.out.println("d2 toString: " + d2.toString());

  }

}
