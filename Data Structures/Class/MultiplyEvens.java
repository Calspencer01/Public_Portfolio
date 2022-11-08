/** Class: MultiplyEvens (Practicing recursion)
*
*/

public class MultiplyEvens{
  public static void main(String[] args) {
    System.out.println("Product of first 1 even: " + multiplyEvens(1));
    System.out.println("Product of first 3 evens: " + multiplyEvens(3));
    System.out.println("Product of first 10 evens: " + multiplyEvens(10));
  }
  public static int multiplyEvens(int n){
    if (n == 1){
      return 2;
    }
    else{
      return 2*n*multiplyEvens(n-1);
    }
  }
}
