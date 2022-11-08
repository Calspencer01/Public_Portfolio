/** Class: Exam 3 (Recursion, Searching, Sorting)
* @author Calvin Spencer
* Date: 11/26/2019
*/

import java.util.LinkedList;
import java.util.Arrays;
import java.util.Iterator;

public class Exam3{
  public static void main(String[] args) {

     LinkedList<Integer> list1 = new LinkedList<Integer>(Arrays.asList(11,6,19,4,8,17,43,5,10,31,49));
    LinkedList<Integer> list2 = new LinkedList<Integer>(Arrays.asList(11,6,11,4,6,17,4,5,17,31,5));
    LinkedList<Integer> list3 = new LinkedList<Integer>(Arrays.asList(-11,-22,-3,-4,5));
    LinkedList<Integer> list4 = new LinkedList<Integer>(Arrays.asList(1,2,3,4,5));
    LinkedList<Integer> list5 = new LinkedList<Integer>(Arrays.asList());

    System.out.println("Original \n--------\n" + list1 + "\n" + list2 +  "\n" + list3 +  "\n" + list4 +  "\n" + list5);

    quickSort(list1);
    quickSort(list2);
    quickSort(list3);
    quickSort(list4);
    quickSort(list5);

    System.out.println("\nSorted \n-------\n" + list1 + "\n" + list2 +  "\n" + list3 +  "\n" + list4 +  "\n" + list5);
  }

  public static  int partition(LinkedList<Integer> list, int low, int high){
    LinkedList<Integer> greater = new LinkedList<Integer>(); //List of ints greater than pivot

    int index = 0; //pivot index
    int pivot = 0; //pivot

    int i = 0;
    for (int l : list){ //Finding pivot value & index
      i++;
      if (i == high){
        index = i;
        pivot = l;
        break;
      }
    }

    Iterator<Integer> iter = list.iterator(); //Iterator to go through list

    i = 0;
    while (i < low){ //Move iterator to low index
      iter.next();
      i++;
    }
    while (i < high){ //Search from low to high for ints greater than pivot
      int next = iter.next();
      if (next > pivot){
        iter.remove(); //remove ints > pivot
        greater.add(next); //add ints to greater
        index--; //compensate index for removing int
      }
      i++;
    }
    list.addAll(index, greater);
    return index;
  }
  public static void quickSort(LinkedList<Integer> list){ //Added for convenience
    quickSort(list,0,list.size());
  }
  public static void quickSort(LinkedList<Integer> list, int low, int high){ // normally would be a private helper method
    if (low >= high){ //Base case

    }
    else{ //Recursive step
      int ind = partition(list, low, high);
      quickSort(list, low, ind-1);
      quickSort(list, ind, high);
    }
  }
}
