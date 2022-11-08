/** Class: TestArrayList, creating and working with ArrayLists
* Date: 9/26/19
* @author Calvin Spencer
* @author Mimi Ughetta
*/

import java.util.ArrayList;

public class TestArrayList{

  public static void main(String[] args){
    //0-param constructor
    ArrayList<String> list = new ArrayList<String>();
    //1-param constructor
    ArrayList<String> list2 = new ArrayList<String>(100);


    //{”to”,”be”,”or”,”not”,”to”,”be”,”that”,”is”,”the”,”question”};
    list.add("to");
    list.add("be");
    list.add("or");
    list.add("not");
    list.add("to");
    list.add("be");
    list.add("that");
    list.add("is");
    list.add("the");
    list.add("question");

    //Adding ~ between every object in array
    for (int i = 0; i < list.size(); i+= 2){
      list.add(i, " ~");
    }
    System.out.println(list);

    //Removing ~ between the objects
    for (int i = 0; i < list.size(); i++){
      list.remove(i);
    }

    //First and last indeces of "be"
    int first = list.indexOf("be");
    int last = list.lastIndexOf("be");
    System.out.println("First: " + first + " Last: " + last);

    removeEvenLength(list);
    System.out.println(list);
  }

  public static void removeEvenLength(ArrayList<String> list){
    for (int i = 0; i < list.size(); i++){
      if (list.get(i).length() % 2 == 0){
        //remove object
        list.remove(i);

        //compensate for shorter array
        i--;
      }
    }
  }


}
