/** Unit 1 Exam: Player class
* @author Calvin Spencer
* Date: 9/24/19
*/
public class Player{

  //Private fields
  private String college;
  private String name;
  private int number;

  /** 3-parameter constructor
  * @param college name of college of player
  * @param name name of player
  * @param number number of player
  */
  public Player(String college, String name, int number){
    this.college = college;
    this.name = name;
    this.number = number;
  }

  /** Returns string representation of player info
  * @return string with number, name, and college
  */
  public String toString(){
    return "#" + number + " " + name + ", " + college;
  }

  /** Determines if two players are the same
  * @param player2 player being compared
  * @return boolean representing whether they are the same player
  */
  public boolean equals(Player player2){
      //True if names, colleges, and numbers are the same
    return (player2.getName().equals(this.name) && player2.getCollege().equals(this.college) && player2.number == this.number);
  }

  //Accessors

  /** Access player's name
  * @return player's name as string
  */
  public String getName(){
    return name;
  }

  /** Access player's college
  * @return player's college as string
  */
  public String getCollege(){
    return college;
  }

  /** Access player's number
  * @return player's number as integer
  */
  public int getNumber(){
    return number;
  }
}
