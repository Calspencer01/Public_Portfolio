/** Unit 1 Exam: DEnd class inherited from Player class
* @author Calvin Spencer
* Date: 9/24/19
*/
public class DEnd extends Player{

  //Private fields
  private int games;
  private int tackles;
  private double sacks;

  /** 6-parameter constructor
  * @param college name of college of player
  * @param name name of player
  * @param number number of player
  * @param games games played by player
  * @param tackles tackles made by player
  * @param sacks sacks made by player
  */
  public DEnd(String college, String name, int number, int games, int tackles, double sacks){
    super(college,name,number);
    this.games = games;
    this.tackles = tackles;
    this.sacks = sacks;
  }

  /** Returns string representation of player info
  * @return string with number, name, college, games, tackles, sacks
  */
  @Override
  public String toString(){
    return "#" + getNumber() + " " + getName() + ", " + getCollege() + ", " + this.games + " games, " + this.tackles + " tackles, " + this.sacks + " sacks.";
  }



}
