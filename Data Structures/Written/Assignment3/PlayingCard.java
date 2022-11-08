/* Written Assignment 3: PlayingCard
* @author Calvin Spencer
* Date; 11/9/2019

Summary:
  This class represents a playing card with a rank and suit. Merge sort is a stable algorithm when an
element in the left array is prioritized to be added first when the comparator deems two cards equal.
This is because the element in the left array was first originally, so this order is maintained. My
mergeSort() method demonstrates this because the order of the first sort (rank) is maintained when it
gets sorted by suit after. 
*/


import java.util.TreeMap;
import java.util.Comparator;
import java.util.ArrayList;

public class PlayingCard{
  private String suit;
  private int rank;
  private static TreeMap<Integer,String> rankStr = new TreeMap<Integer,String>();

  //TreeMap of what high ranks correspond to
  static{
    rankStr.put(11, "Jack");
    rankStr.put(12, "Queen");
    rankStr.put(13, "King");
    rankStr.put(14, "Ace");
  }

  /** 2-param constructor
  * @param suit suit of card
  * @param rank integer rank of card
  * @throws IllegalArgumentException if rank or suit is invalid
  */
  public PlayingCard(String suit, int rank) throws IllegalArgumentException{
    //Only valid suits
    if (!suit.equalsIgnoreCase("Clubs") && !suit.equalsIgnoreCase("Diamonds") && !suit.equalsIgnoreCase("Hearts") && !suit.equalsIgnoreCase("Spades")){
      throw new IllegalArgumentException("Invalid Suit");
    }//Only valid ranks
    else if (rank < 2 || rank > 14){
      throw new IllegalArgumentException("Invalid Rank");
    }
    else{
      this.suit = suit;
      this.rank = rank;
    }
  }

  /** Builds string with rank and suit
  * @return string representing card
  */
  public String toString(){
    if (rank > 10){
      return rankStr.get(rank) + " of " + suit;
    }
    else{
      return rank + " of " + suit;
    }
  }

  //Accessors
  /** returns integer rank
  * @return int rank (2-14)
  */
  public int getRank(){
    return rank;
  }
  /** returns String suit
  * @return String suit (Diamonds, Hearts, Clubs or Spades)
  */
  public String getSuit(){
    return suit;
  }

  /** Recursive mergesort to sort given ArrayList
  * @param ArrayList<T> list being sorted
  * @param Comparator<T> comparator indicating which field to sort by
  */
  public static <T> void mergeSort(ArrayList<T> list, Comparator<T> cmp){
    //Splitting array
    if (list.size() > 1){
      ArrayList<T> list1 = new ArrayList<T>(list.subList(0,list.size()/2));
      ArrayList<T> list2 = new ArrayList<T>(list.subList(list.size()/2,list.size()));

      //Merge sorting both halves
      mergeSort(list1,cmp);
      mergeSort(list2,cmp);

      //Merging both halves
      merge(list,list1,list2,cmp);
    }
  }

  /** Merges two arrayLists into one
  * @param finalList list being made by merging
  * @param list1 first list being merged
  * @param list2 second list being merged
  * @param cmp Comparator for sorting while merging the lists
  */
  private static <T> void merge(ArrayList<T> finalList, ArrayList<T> list1, ArrayList<T> list2, Comparator<T> cmp){

    //Indeces for both ArrayLists
    int i1 = 0;
    int i2 = 0;

    for (int i = 0; i < finalList.size(); i++){
      //if list2 index out of bounds, or i1 element <= i2 element (sort is stable because if equal, i1 (left) gets priority)
      if (i2 >= list2.size() || (i1 < list1.size() && cmp.compare(list1.get(i1),list2.get(i2)) <= 0)) {
        //Replace ith element with i1
        finalList.remove(i);
        finalList.add(i,list1.get(i1));

        //increment i1
        i1++;
      }
      else{
        //Replace ith element with i2
        finalList.remove(i);
        finalList.add(i,list2.get(i2));

        //increment i2
        i2++;
      }
    }
  }

  //Comparators
  //Comparator that compares by card rank
  public static class RankCompare implements Comparator<PlayingCard>{
    /** compares card rank
    * @param card1 first playing card
    * @param card2 second playing card
    * @return int representing relative position of card 1 and card 2
    */
    public int compare(PlayingCard card1, PlayingCard card2){
      if (card1.getRank() > card2.getRank()){
        return 1;
      }
      else if (card1.getRank() < card2.getRank()){
        return -1;
      }
      else{
        return 0;
      }
    }
  }
  //Comparator that compares by card suit
  public static class SuitCompare implements Comparator<PlayingCard>{
    /** compares card suit
    * @param card1 first playing card
    * @param card2 second playing card
    * @return String representing relative position of card 1 and card 2
    */
    public int compare(PlayingCard card1, PlayingCard card2){
      return card1.getSuit().compareTo(card2.getSuit());
    }
  }

  public static void main(String[] args) {
    //Making cards
    ArrayList<PlayingCard> cards = new ArrayList<PlayingCard>();
    cards.add(new PlayingCard("Hearts", 6));
    cards.add(new PlayingCard("Diamonds", 3));
    cards.add(new PlayingCard("Clubs", 7));
    cards.add(new PlayingCard("Diamonds", 5));
    cards.add(new PlayingCard("Spades", 7));
    cards.add(new PlayingCard("Clubs", 4));
    cards.add(new PlayingCard("Spades", 9));

    System.out.println("Original     " + cards);
    mergeSort(cards, new RankCompare());
    System.out.println("Rank Sorted  " + cards);
    mergeSort(cards, new SuitCompare());
    System.out.println("Suit Sorted  " + cards);

  }
}
