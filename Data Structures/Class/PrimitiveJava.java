
/** Prints integer pairs that satisfy the equation, as well as roman numerals of the values 2019, 2016, 1992, 1988
* Date: 8/29/2019
*
* @Author Calvin Spencer
**/

import java.util.*;
class PrimitiveJava{

  public static void main(String[] args){ //Main method
    integer_pair(); //Calls integer_pair method, printing integer pairs


    System.out.println(roman_numeral(2019));
    System.out.println(roman_numeral(2016));
    System.out.println(roman_numeral(1992));
    System.out.println(roman_numeral(1988));

  }

  //Outputs integer pairs such (a,b) such that 0 < a < b < 1000 and (a^2 + b^2 + 1)/(ab) is an integer
  public static void integer_pair(){
    for (int a = 1; a < 999; a++){ //Loops a for (0 < a < 999)
      for (int b = a+1; b < 1000; b++){ //Loops b for (a < b < 1000)

        int a2 = a*a; //Assigns a^2 to a2
        int b2 = b*b; //Assigns b^2 to b2
        int ab = a*b; //Assigns a*b to ab

        if ( ((double) (a2+b2+1)/ab) % 1 == 0) //Outputs if (a^2 + b^2 + 1)/(ab) is an integer
        System.out.println("(" + a + "," + b + ")"); //Prints in the format '(a,b)'

      }

    }

  }
  public static String roman_numeral(int x){
    String numer = "";
    int digit = x;
    for (int i = 0; i < 4; i++) {//10^i & (i < 4) means numers less than 10000
      digit = x % 10;
      switch (i){
        //Ones
        case 0:
          switch (digit){
            case 1: numer = "I";
            break;
            case 2: numer = "II";
            break;
            case 3: numer = "III";
            break;
            case 4: numer = "IV";
            break;
            case 5: numer = "V";
            break;
            case 6: numer = "VI";
            break;
            case 7: numer = "VII";
            break;
            case 8: numer = "VIII";
            break;
            case 9: numer = "IX";
            break;
          }
        break;
        //Tens
        case 1:
        switch (digit){
          case 1: numer = "X" + numer;
          break;
          case 2: numer = "XX" + numer;
          break;
          case 3: numer = "XXX" + numer;
          break;
          case 4: numer = "XL" + numer;
          break;
          case 5: numer = "L" + numer;
          break;
          case 6: numer = "LX" + numer;
          break;
          case 7: numer = "LXX" + numer;
          break;
          case 8: numer = "LXXX" + numer;
          break;
          case 9: numer = "XC" + numer;
          break;
        }
        break;
        //Hundreds
        case 2:
        switch (digit){
          case 1: numer = "C" + numer;
          break;
          case 2: numer = "CC" + numer;
          break;
          case 3: numer = "CCC" + numer;
          break;
          case 4: numer = "CD" + numer;
          break;
          case 5: numer = "D" + numer;
          break;
          case 6: numer = "DC" + numer;
          break;
          case 7: numer = "DCC" + numer;
          break;
          case 8: numer = "DCCC" + numer;
          break;
          case 9: numer = "CM" + numer;
          break;
        }
        break;
        //Thousands
        case 3:
        switch (digit){
          case 1: numer = "M" + numer;
          break;
          case 2: numer = "MM" + numer;
          break;
          case 3: numer = "MMM" + numer;
          break;
        }
        break;
      }
      x = x/10;
    }

    //System.out.println(ths + " " + fHund + " " + hund + " " + fift + " " + tens + " " + five + " " + ones); //Adding to strings adds to the right side

    return numer;

  }
}
