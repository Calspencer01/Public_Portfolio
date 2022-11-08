/** Class: Boggle (Recursive Backtracking)
* Date: 11/4/2019
* @author Calvin Spencer




Summary:
    This class contains a 4x4 array of characters, and finds all possible words those characters can build following
  the rules of Boggle. Dict & subDict store strings in HashSets because there is no need to store the same word,
  so a set is the most efficient collection. I use a HashSet specifically so that I can quickly use the contains()
  method to see if the character sequence is contained by either the dictionary HashSet or the HashSets of substrings.
  explore() is a private method because it is a helper method that is called by solve(). The user should not interact
  with explore(). solve() returns a LinkedList<String> because it can contain duplicates, and linked lists more easily
  add elements than ArrayLists. solve(), explore() & print() are all instance methods because they do not serve a
  purpose unless an instance of class Boggle is created and the board is loaded with characters. If these methods
  accepted a parameter for an array of characters or an instance of Boggle, it would make sense for them to be static.
  To run quicker, I created the ArrayList of HashSets (subDict) that store substrings of each word in dict. By doing so, I can
  call contains() in an element of this ArrayList. When the sequence built by the recursive function reaches length n,
  contains(sequence) is called to search the HashSet with substrings of length n. By doing so, the program can give up
  on a sequence if none of the words contain it. This maximizes the use of the contains() method in the HashSet class which
  is an extremely quick and efficient search method.

*/

import java.util.Random;
import java.util.Collections;
import java.util.HashSet;
import java.io.IOException;
import java.io.File;
import java.util.Scanner;
import java.util.Iterator;
import java.util.ArrayList;
import java.util.LinkedList;



public class Boggle{
  //Private Fields
  private char[][] board;
  private static boolean[][] marked;
  private static HashSet<String> dict;

  //Arrays that represent which direction (horizontally & vertically) to move
  //in order to move in all 8 possible directions on the board.
  private static int[] moveCol = { 0, 1,1,1,0,-1,-1,-1};
  private static int[] moveRow = {-1,-1,0,1,1, 1, 0,-1};

  //subDict stores HashSets of Dict but each String is the length of the index of the ArrayList
  private static ArrayList<HashSet<String>> subDict;


  /** Loads the dict HashSet, and the subDict ArrayList of HashSets
  * subDict stores HashSets of the substrings words in dict
  * index in ArrayList + 1 = length of strings in HashSet
  */
  static{

    //Constructing collections
    dict = new HashSet<String>();
    subDict = new ArrayList<HashSet<String>>(16);

    //Adding HashSets into elements of ArrayList subDict
    for (int i = 0; i < 16; i++){
      subDict.add(i,new HashSet<String>());
    }

    try{
      //Scanner scanner = new Scanner(new File("/usr/share/dict/words"));
      Scanner scanner = new Scanner(new File("words"));
      while (scanner.hasNextLine()){
        //Stores scanner's next line
        String nextLine = scanner.nextLine().toUpperCase();
        //Add next line to dict
        dict.add(nextLine);

        for (int i = 1; i <= 16; i++){

          //Add substring (length = i+1) of next line to subDict
          if (i <= nextLine.length())
          subDict.get(i-1).add(nextLine.substring(0,i));
        }
      }
    }
    catch (IOException e){
      System.out.println("Dictionary file not found");
    }
  }

  //Main Method
  public static void main(String[] args) {
    //Random board
    Boggle randGame = new Boggle();
    System.out.println("Random board");
    System.out.println("-------");
    randGame.print();
    System.out.println("Solutions: " + randGame.solve() + "\n\n");

    //Given array of chars
    char[] chars = {'T','I','S','S','D','E','T','I','T','A','T','W','R','S','P','H'};
    try{
      Boggle inputGame = new Boggle(chars);
      System.out.println("Given board");
      System.out.println("-------");
      inputGame.print();
      System.out.println("Solutions " + inputGame.solve());

    }
    catch (IllegalArgumentException e){
      System.err.println(e);
    }

  }

  //Constructors

  //0-param constructor
  public Boggle(){
    //Initializing board
    board = new char[4][4];

    //New Random object
    Random rand = new Random();
    for (int row = 0; row < 4; row++){
      for (int col = 0; col < 4; col++){
        //Filling board randomly
        board[row][col] = (char) (65 + rand.nextInt(26));
      }
    }
  }

  /** 1-param Constructor
  * @param char[] arrayList of characters for boggle board
  */
  public Boggle(char[] c) throws IllegalArgumentException{
    board = new char[4][4];
    if (c.length != 16){
      throw new IllegalArgumentException("Array length is not 16");
    }
    //Index in the parameterized array
    int index = 0;

    //Filling board with given array of chars
    for (int row = 0; row < 4; row++){
      for (int col = 0; col < 4; col++){
        board[row][col] = c[index];

        //Increment index
        index++;
      }
    }
  }

  /** Prints 4x4 boggle grid
  */
  public void print(){
    String str = "";

    //Builds string grid of characters
    for (int row = 0; row < 4; row++){
      for (int col = 0; col < 4; col++){
        str += board[row][col] + " ";
      }
      str += "\n";
    }
    //Print string
    System.out.println(str);
  }

  /** Finds all possible words on boggle board
  * @return LinkedList<String> list of all words on board
  */
  public LinkedList<String> solve(){

    marked = new boolean[4][4];
    //Setting marked map to all false
    for (int i = 0; i < 4; i++){
      for (int l = 0; l < 4; l++){
        marked[i][l] = false;
      }
    }

    //LinkedList storing words on grid -> Repeats are allowed
    LinkedList<String> wordsFound = new LinkedList<String>();

    //Explore starting from all 16 spots on grid
    for (int i = 0; i < 4; i++){
      for (int l = 0; l < 4; l++){
        marked[i][l] = true;
        explore("" + board[i][l],i,l,wordsFound);
        marked[i][l] = false;
      }
    }

    return wordsFound;
  }

  /** Helper method for solve, explore all possibilities starting from given position on board
  * @param str String being built
  * @param row row coordinate
  * @param col column coordinate
  * @param LinkedList<String> collection of words found
  */
  private void explore(String str, int row, int col, LinkedList<String> wordsFound){
    // Add string to words found if contained in dict HashSet
    if (dict.contains(str)){
      wordsFound.add(str);
    }

    //Try to move in all 8 potential directions
    for (int i = 0; i < 8; i++){

      //Increment row/col in given direction
      int newRow = row + moveRow[i];
      int newCol = col + moveCol[i];

      //If row or col is out of bounds, or if space is marked already -> Don't explore
      if (newRow > 3 || newRow < 0 || newCol < 0 || newCol > 3 || marked[newRow][newCol]){
      }   //If subDict of same length as str contains str -> Explore
      //else{
      else if (subDict.get(str.length()).contains(str + board[newRow][newCol])){

        //While exploring, mark this spot as true
        marked[newRow][newCol] = true;

        //Explore given str and the char of current spot, and new row/col
        explore(str + board[newRow][newCol], newRow, newCol, wordsFound);

        //Done exploring off this element, return to false
        marked[newRow][newCol] = false;
      }

    }
  }
}
