/** Class Assignment: Reference Types. Learning about handling exceptions and working with arrays
	*	Date: 9/3/2019.
	*
	*	@author Calvin Spencer
	*	@Partner Mimi Ughetta
*/

//Import statement for BufferedReader
import java.io.*;


public class ReferenceTypes
{

  //Main Method
  public static void main(String[] args)
  {
    int[] startArr = {5,4,3,2,1}; //startArr[0] = 5; startArr[1] = 4; ..
    //Made an initial array with 5 integers.

    for (int i = 0; i < startArr.length; i++){ //Prints out the initial array
      System.out.print(startArr[i] + " ");
    }

    System.out.println("\n");

    int[] newArr = resize(startArr, 3); //Calls resize method and assigns newArray to what is returned

    for (int i = 0; i < newArr.length; i++){ //Prints out the new array
      System.out.print(newArr[i] + " ");
    }

    System.out.println("\n");

    newArr = resize(newArr, 8); //Calls resize method and assigns newArray to what is returned

    for (int i = 0; i < newArr.length; i++){ //Prints out the new array
      System.out.print(newArr[i] + " ");
    }



    //Try block
    try
    {
      intputIntArr(newArr);
    }
    catch (IOException e)
    {
      System.err.println(e);
    }
    catch (NumberFormatException e)
    {
      System.err.println(e);
    }

    System.out.println("\n");

    for (int i = 0; i < newArr.length; i++){ //Prints out the new array
      System.out.print(newArr[i] + " ");
    }

    System.out.println("\n");
  }

  /** changes the size of paramaterized array
  * @param array integer array that length of is changing
  * @param size new desired length of the array
  * @return integer array of new length
  */
  public static int[] resize(int[] array, int size)
  {
    int[] newArr;
    int length = array.length;
    newArr = new int[size];
    if (array.length > size){  //Finds minimum, Math.min() is an alternative
      length = size;
    }

    //Transfers values in array to newArr
    for (int i = 0; i < length; i++)
    {
      newArr[i] = array[i];
    }

    return newArr;
  }

  /** Lets the user input modify
  * @param array given array
  * @return integer array after user modification
  * @throws IOException
  */
  public static int[] intputIntArr(int[] array) throws IOException{

    //Local fields
    int index;
    int inputInt;
    String indexStr = "";
    String intStr = "";
    BufferedReader in  = new BufferedReader(new InputStreamReader(System.in));

    //User inputs
    System.out.println("\n\nEnter the index of the array you'd like to change [0 - " + (array.length-1) +"]:");
    indexStr = in.readLine();
    index = Integer.parseInt(indexStr);


    System.out.println("\n\nEnter the value you'd like to change it to:");
    intStr = in.readLine();
    inputInt = Integer.parseInt(intStr);



    array[index] = inputInt;
    return array;
  }


}
