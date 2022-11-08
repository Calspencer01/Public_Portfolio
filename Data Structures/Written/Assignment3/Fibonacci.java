/*Written Assignment 3: Fibonacci
* Date: 11/8/2019
* @author Calvin Spencer


Summary:
  This class demonstrates how to recursively generate fibonacci numbers. fib() is not a tail recursive method because it involves
  multiple operations that build up as the call stack is generated. By having two recursive calls and needing to add them, the
  complexity is higher than necessary and the exaggerated runtime demonstrates this inefficiency. This is why fib(25) takes 16 milliseconds,
  and fib(50) takes over 30 seconds! tailFib() is tail recursive because it only returns a recursive call, and does not require any other
  operations. This means that once the base case is reached, all that needs to be returned is the value of the final tailFib() call. This
  way, instead of doing many computations, this tail recursive method is hugely simplified because of this property (as shown by < 0ms runtime).
  The main difference between how fib() and tailFib() run is that fib() counts down from the parameterized integer and adds up the Fibonacci
  values as it goes along, which involves calling fib() twice and adding them together. Whereas tailFib() only calls itself once per return once
  by giving the previous two fibonacci numbers as parameters in the helper method tailFib(int,long,long).
*/



public class Fibonacci{

  public static void main(String[] args) {
    long start;
    long end;

    //Timing fib(25)
    start = System.currentTimeMillis();
    System.out.print("fib(25): " + fib(25) + " Time: ");
    end = System.currentTimeMillis();
    System.out.println((end-start) + "ms");

    //Timing fib(50)
    start = System.currentTimeMillis();
    System.out.print("fib(50): " + fib(50) + " Time: ");
    end = System.currentTimeMillis();
    System.out.println((end-start) + "ms");

    //Timing tailFib(25)
    start = System.currentTimeMillis();
    System.out.print("tailFib(25): " + tailFib(25) + " Time: ");
    end = System.currentTimeMillis();
    System.out.println((end-start) + "ms");

    //Timing tailFib(50)
    start = System.currentTimeMillis();
    System.out.print("tailFib(50): " + tailFib(50) + " Time: ");
    end = System.currentTimeMillis();
    System.out.println((end-start) + "ms");
   }
 /** Finds nth fibonacci number (without tail recursion)
 * @param n index in fibonacci sequence
 * @return long value of fibonacci number n
 */
  public static long fib(int n){
    // First two numbers in sequence are 1
    if (n < 3){
      return 1;
    }
    else{
      return fib(n-1) + fib(n-2);
    }
  }

  /** Finds nth fibonacci number (with tail recursion)
  * @param n index in fibonacci sequence
  * @return long value of fibonacci number n
  */
  public static long tailFib(int n){
    // 1st & 2nd fibonacci # is 1
    if (n < 2){
      return 1;
    }
    return tailFib(n,0,1);
  }

  /** Helper method for tailFib(int)
  * @param n index in fibonacci sequence
  * @param a previous fibonacci number
  * @param b second previous fibonacci number (a+b = next in sequence)
  */
  public static long tailFib(int n, long a, long b){
    if(n < 1){
      return a;
    }
    //Decreases n by 1, shifts fibonacci numbers in parameter down the sequence (2 3 -> 3 5 -> 5 8, etc.)
    return tailFib(n-1, b, a+b);
  }
}
