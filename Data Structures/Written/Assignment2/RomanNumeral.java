/** Written Assignment 2: RomanNumeral
* Date: 10/7/2019
* @author Calvin Spencer


  Summary:
    This class functions to convert Strings of roman numerals to integers,
  and vice-versa. The class contains two maps. 'map' contains integers as keys,
  with the corresponding roman numerals as the associated strings. 'invMap' is
  the same map but with reversed roles. I created invMap in order to simplify the
  toInteger() method by calling containsKey() and get() given the substrings spliced
  from the parameterized roman numeral string. Using a TreeMap for the original map
  was intuitive because it sorts by the integer keys, and allows for the use of
  floorKey() which is essential in finding the next roman numeral to add to the overall
  roman numeral string. The sorting properties of TreeMaps offered the most efficient
  structure for this type of process. The invMap, however, is a HashMap because it
  uses a hashing algorithm to find the strings, meaning it is more efficient when
  methods such as constainsKey(String) are called, since strings are not sorted like
  integers in the TreeMaps.




*/
import java.util.TreeMap;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Iterator;
import java.util.Collections;

public class RomanNumeral{
  private static TreeMap<Integer,String> map = new TreeMap<Integer,String>();
  private static HashMap<String,Integer> invMap = new HashMap<String,Integer>();
  static
  {
    map.put(1000,"M");
    map.put(900,"CM");
    map.put(500,"D");
    map.put(400,"CD");
    map.put(100,"C");
    map.put(90,"XC");
    map.put(50,"L");
    map.put(40,"XL");
    map.put(10,"X");
    map.put(9,"IX");
    map.put(5,"V");
    map.put(4,"IV");
    map.put(1,"I");

    //Creating an inverse map
    LinkedList<Integer> keys = new LinkedList<Integer>(map.keySet());
    LinkedList<String> vals = new LinkedList<String>(map.values());
    Iterator<Integer> iter = keys.iterator();

    for (String val: vals){
      invMap.put(val,iter.next());
    }
  }

  public static void main(String[] args) {
    System.out.println("1988: " + toRomanNumeral(1988));
    System.out.println("1992: " + toRomanNumeral(1992));
    System.out.println("2016: " + toRomanNumeral(2016));
    System.out.println("2019: " + toRomanNumeral(2019));
    System.out.println("");

    System.out.println(toRomanNumeral(1988) + ": " + toInteger(toRomanNumeral(1988)) + " \n");
    System.out.println(toRomanNumeral(1992) + ": " + toInteger(toRomanNumeral(1992)) + " \n");
    System.out.println(toRomanNumeral(2016) + ": " + toInteger(toRomanNumeral(2016)) + " \n");
    System.out.println(toRomanNumeral(2019) + ": " + toInteger(toRomanNumeral(2019)) + " \n");
  }

  /** Converts integer into roman numeral
  * @param x integer being converted
  * @return roman numeral string
  */
  public static String toRomanNumeral(int x){
    String numer = "";
    while (x > 0) {
      numer+= map.get(map.floorKey(x));
      x-= map.floorKey(x);
    }
    return numer;
  }

  /** Converts string roman numeral into integer
  * @param s string being converted
  * @return int representation of roman numeral
  */
  public static int toInteger(String s){
    int x = 0;
    for (int i = 0; i < s.length(); i++){
      //only checks double-character substring if not last index in string
      if (i < s.length()-1 && invMap.containsKey(s.substring(i,i+2))){
        x += invMap.get(s.substring(i,i+2));
        i++;//Move an extra index in the for loop to compensate
      }
      else if (invMap.containsKey(s.substring(i,i+1))){
        x += invMap.get(s.substring(i,i+1));
      }
    }
    return x;
  }
}
