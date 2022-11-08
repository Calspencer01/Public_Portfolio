/** Written Assignment 2: Balanced
* Date: 10/7/2019
* @author Calvin Spencer


  Summary:
    This class checks whether a given string has balanced parantheses/brackets. The
  balParanthesis() method performs this algorithm by accepting a string parameter
  and returning a boolean saying whether it is balanced. I first made a map that
  linked all parantheses/brackets to their corresponding ones (e.g. { & } or ] & [).
  I could have built a map that only connected open parantheses/brackets to closed
  ones, however by making the complete map I was able to call the containsKey()
  method which essentially checks if the character is a paranthesis/bracket and not
  a letter. Also, if I chose to build off of this program, having the complete
  map might useful. I constructed a LinkedList within balParanthesis called open
  that contains only open parantheses/brackets. This allowed me to call contains() to
  identify if c is open. If it is open, I added it to the chars Stack. If it wasn't,
  it pops the top element off the stack. If this top element is equal to the value
  corresponding to the key (the appropriate closing parantheses/brackets), then
  so far the string is balanced. If this condition is ever false, it indicates
  that the string is unbalanced, and should return false.
    The benefit of using a stack in this case stems from its first-in, last-out
  properties. A balanced string requires the most recently opened paranthesis/bracket
  to be the first closed. This means that the element of the list that must be
  accessed is the one that was most recently added. The push() and pop() methods
  of Stacks do exactly this. With a Queue, the program would immediately access
  the element added first, since behaves first-in, first-out, which is not useful
  in this context.


*/
import java.util.Stack;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.LinkedList;
import java.util.Arrays;

public class Balanced{
  private static HashMap<Character,Character> map = new HashMap<Character,Character>();
  static{
    map.put('{','}');
    map.put('}','{');
    map.put(']','[');
    map.put('[',']');
    map.put('(',')');
    map.put(')','(');
  }

  /** Determines if string has balanced paranthesis
  * @param s string being analyzed
  * @return boolean representation of whether parantheses are balanced
  */
  public static boolean balParanthesis(String s){
    List<Character> open = new LinkedList<Character>(Arrays.asList('{','[','('));
    Stack<Character> chars = new Stack<Character>();
    boolean bal = true;

    for (int i = 0; i < s.length(); i++){
      //Unboxing
      char c = s.charAt(i);
      if (map.containsKey(c)){ //only brackets/parantheses, not letters

        if (open.contains(c)){ //if it is an open bracket
          //add to stack
          chars.push(c);
        }
        else if (chars.pop() != map.get(c)){ //if it is a closed bracket and the top of the stack isnt its open complement
          //unbalanced
          return false;
        }
      }
    }
    //If all open brackets have been popped by their complementary closing ones, return true
    return (chars.isEmpty());
  }
}
