/** Written Assignment 1: Primitive Java, Reference Types, Objects and Classes, Inheritance
  * Date: 9/9/2019
  *
  *@author Calvin Spencer

  Summary:

  This class runs static methods from a main method to show the results of unusual division operations in Java.
  I did not include a throws clause because the ArithmeticException was checked in the only instance where
  it was called. The try-catch block ensures that if there is an exception, it will be caught and handled
  appropriately. In this case, by outputting the error. This try-catch block was placed in the main method
  to simplify the code by reducing the number of lines within the block. Even though the method that throws an
  exception (divide()) is called first, the program is guaranteed to run and compete the verify() call without
  the program crashing after the previous method due to an unhandled exception.

*/






public class DivideByZero{
  public static void main(String[] args){ //Main Method

    try{
      // Correctly operating float division
      System.out.println("No Exception:");
      System.out.println("5/10 = " + divide(5,10));

      // Throws arithmetic exception due to 0-divisor
      System.out.println("Exception:");
      System.out.println("5/0 = " + divide(5,0));
    }
    catch (ArithmeticException e){ //Catches exception from divide() method
      System.err.println(e); //Prints error message to console
    }

    // Calls verify() method containing 3 print statements
    verify();
  }

  /** Verifies the three given arithmetic statements
  *
  */
  public static void verify(){
    // (1/0) Prints Java's float representation of infinity
    System.out.println("1.0/0.0 = " + (1.0/0.0));

    // (-1/0) Prints Java's float representation of negative infinity
    System.out.println("-1.0/0.0 = " + (-1.0/0.0));

    // (0/0) Prints Java's float representation of "not-a-number"
    System.out.println("0.0/0.0 = " + (0.0/0.0));
  }

  /** Returns quotient of the given floats
  * @param dividend floating point number for the numerator of the rational number
  * @param divisor floating point number dividing the dividend
  */
  public static float divide(float dividend, float divisor){
    if (divisor == 0){
      throw new ArithmeticException("Divisor is zero");
    }
    return dividend / divisor;

  }

}
