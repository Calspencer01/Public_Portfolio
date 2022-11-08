/** Class: Exam2
* Date: 10/22/2019
* @author Calvin Spencer
*/

//Imports
import java.util.Set;
import java.util.Map;
import java.util.HashMap;
import java.util.TreeMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Collections;
import java.util.Iterator;

public class Exam2{
  //Main Method
  public static void main(String[] args) {
    System.out.println(count("Hello World!"));
    System.out.println(count("The max of the set {1,2,3,4,5} is equal to 5."));
    System.out.println(count("thcameron@davidson.edu"));
    System.out.println(count("To be or not to be that is the question."));
    System.out.println(count("Tettegouche is pronounced Tet-uhhhh-gOOshe."));
  }

  /** Returns map indicating number of each letter
  * @param s String being counted
  * @return map of Integers as keys, and Sets of Characters as values
  */
  public static Map<Integer,Set<Character>> count(String s){
    //auxMap is a HashMap because the keys are characters, which aren't sorted like integers
    Map<Character,Integer> auxMap = new HashMap<Character,Integer>();

    //map is a TreeMap so that it can be sorted by the integer key, but in reverse order (larger to smaller)
    Map<Integer,Set<Character>> map = new TreeMap<Integer,Set<Character>>(Collections.reverseOrder());

    //Building auxMap
    for (int i = 0; i < s.length(); i++){
      char c = Character.toLowerCase(s.charAt(i));

      //Only in english alphabet
      if ((int) c >= 97 && (int) c <= 122){

        //If letter is a key
        if (auxMap.containsKey(c)){
          auxMap.put(c,auxMap.get(c)+1);
        }//If first instance of letter
        else{
          auxMap.put(c,1);
        }
      }
    }


    //Keys are a hashset because they cannot be repeated, and do not need to be sorted
    Set<Character> keys = new HashSet<Character>(auxMap.keySet());

    //Vals are linked list so it can be iterated through, and duplicates are used
    List<Integer> vals = new LinkedList<Integer>(auxMap.values());
    Iterator<Integer> iter = vals.iterator();


    for (char c : keys){
      Set<Character> newSet;
      //Unboxing
      int val = iter.next();

      //If set already exists
      if (map.containsKey(val)){
        newSet = new HashSet<Character>(map.get(val));
      }//Set doesn't exist, make new set
      else{
        newSet = new HashSet<Character>();
      }

      //Add character to set
      newSet.add(c);

      //Add new set to corresponding key
      map.put(val,newSet);
    }

    /** alternate method (without storing values collection)
      //Keys are a linked list so that it can simply be iterated through
      List<Character> keys = new LinkedList<Character>(auxMap.keySet());

      //Iterating over key set
      for (char c: keys){
        Set<Character> newSet;
        if (map.containsKey(auxMap.get(c))){
          newSet = new HashSet<Character>(map.get(auxMap.get(c)));
        }
        else{
          newSet = new HashSet<Character>();
        }
        newSet.add(c);
        map.put(auxMap.get(c),newSet);
      }
    */

    return map;

  }
}
