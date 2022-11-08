/** Class: Recursion
* Date: 10/24/2019
* @author Calvin Spencer
* @author Mimi Ughetta
*/

import java.math.BigInteger;

public class Recursion{
  public static void main(String[] args) {
    System.out.println(factorial(5));
    System.out.println(perm(7,3));
  }

  public static BigInteger factorial(int x){

    if (x == 0){
      return new BigInteger("1");
    }
    else{
      return BigInteger.valueOf(x).multiply(factorial(x-1));
    }
  }

  public static int perm(int n, int r){
    if (r == 0){
      return 1;
    }
    else {
      return (n-r+1)*perm(n,r-1);
    }
  }
}
