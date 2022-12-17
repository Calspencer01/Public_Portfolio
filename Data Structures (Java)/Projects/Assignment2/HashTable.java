/** Written Assignment 2: HashTable
* Date: 10/7/2019
* @author Calvin Spencer


  Summary:
    This class consists of an ArrayList containing LinkedLists of Strings as elements. By using
  an ArrayList, the program can quickly access the desired element (LinkedList) when needed.
  This allows the hashing function to quickly find the LinkedList containing the String needed,
  as opposed to having a single List that the program would have to search through. The LinkedLists
  as elements of the ArrayList allow the program to iterate through the list quickly, as well as
  remove or add elements without the entire list shifting to compensate (as seen in ArrayLists).
  I included an add() method that accepts a List as a parameter so that more than one name can
  be added at a time. This method functions by calling the add(String) method in a for-each loop.
  Additionally, I made a hash() method that accepts a String and returns the sum of each
  ascii character % field size. I made this method because I use this same algorithm both when
  adding and retrieving strings from the table, so it simplified the code to resuse the same method.
*/


import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Arrays;
import java.util.List;


public class HashTable{
  private int size;
  private ArrayList<LinkedList<String>> table;

  /** 1-param constructor, builds table and fills with empty LinkedLists
  * @param size size of HashTable ArrayList
  *
  */
  public HashTable(int size){
    this.size = size;
    this.table = new ArrayList<LinkedList<String>>(size);

    for (int i = 0; i < size; i++){
      //Adds new LinkedList of type String to each index of ArrayList
      table.add(i,new LinkedList<String>());
    }
  }

  //Main Method
  public static void main(String[] args){
    //Creates new HashTable of size 11
    HashTable table = new HashTable(11);

    table.add(Arrays.asList("Bea","Tim","Leo","Sam","Mia","Zoe","Jan","Lou","Max","Ada","Ted"));
    System.out.println(table);

    table.clear();

    table.add(Arrays.asList("Bea","Tim","Len","Moe","Mia","Zoe","Sue","Lou","Rae","Max","Tod"));
    System.out.println(table);

    table.remove(1);
    table.remove("Moe");
    table.add("Sue");
    table.add("Leo");
    System.out.println(table.toString());
  }

  /** Performs the hashing algorithm
  * @param str string being broken into ascii characters
  * @return sum of ascii values % table size
  */
  public int hash(String str){
    int sum = 0;
    for (int i = 0; i < str.length(); i++){
      //Typecasting char to ascii integer at index i in string 'str'
      sum += (int) str.charAt(i);
    }
    return sum % this.size;
  }

  /** Adds list of strings to HashTable
  * @param names List of strings
  */
  public void add(List<String> names){
    //Individually adds name in names via the individual add(String) method
    for (String name : names){
      this.add(name);
    }
  }

  /** Adds individual String to HashTable
  * @param name String being added
  */
  public void add(String name){
    int index = hash(name);

    if (!table.get(index).contains(name)){
      table.get(index).add(name);
    }
  }

  /** Clears all LinkedLists in HashTable
  */
  public void clear(){
    //Loops through all LinkedLists in HashTable
    for (int i = 0; i < size; i++){
      table.get(i).clear();
    }
  }

  /** Clears LinkedList at given index in HashTable
  * @param index index of LinkedList being cleared
  */
  public void remove(int index){
    table.get(index).clear();
  }

  /** Removes string from HashTable
  * @param name string being removed
  */
  public void remove(String name){
    //Calculates appropriate index of name
    table.get(hash(name)).remove(name);
  }

  /** Converts HashTable to string
  * @return string containing all LinkedLists on separate lines
  */
  public String toString(){
    String str = "";
    //Loops through table and adds string of each LinkedList to returned string
    for (int i = 0; i < size; i++){
      str += table.get(i).toString() + "\n";
    }
    return str;
  }

  /** Accessor for size of HashTable
  * @return size of the HashTable
  */
  public int size(){
    return size;
  }

}
