/** Class Assignment: Lists & Iterator
* Date: 10/1/19
* @author Calvin Spencer
* @author Mimi Ughetta
*/
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;

public class TestCollection{
  public static void main(String[] args) {
    int n = 1000000;
    int nanoScale = 1000000000;
    long startTime, endTime, elapsedTime;
    ArrayList<String> arList = new ArrayList<String>(n);
    LinkedList<String> liList = new LinkedList<String>();
    for (int i = 1; i <= n/10; i++){
      arList.addAll(Arrays.asList("to","be","or","not","to","be","that","is","the","question"));
      liList.addAll(Arrays.asList("to","be","or","not","to","be","that","is","the","question"));
    }
    System.out.println("From 100000 to 600000:");

    startTime = System.nanoTime();
    removeInRange(arList, "to", 100000, 600000);
    endTime = System.nanoTime();
    elapsedTime = endTime - startTime;
    System.out.println("Array List: " + (double) elapsedTime / (double) nanoScale);

    startTime = System.nanoTime();
    removeInRange(liList, "to", 100000, 600000);
    endTime = System.nanoTime();
    elapsedTime = endTime - startTime;
    System.out.println("Linked List: " + (double) elapsedTime / (double) nanoScale);

  }

  public static <T> void removeInRange(Collection <T> col, T val, int start, int end){
    int counter = 0;
    Iterator<T> i = col.iterator();
    while (i.hasNext() && counter <= end){
      T element = i.next();
      if (element.equals(val) && counter >= start){
        i.remove();
      }
      counter++;
    }
  }
}
