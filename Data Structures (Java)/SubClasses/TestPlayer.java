/** Unit 1 Exam: Testing Player and subclass DEnd
* @author Calvin Spencer
* Date: 9/24/19
*/

public class TestPlayer{
  //Main Method
  public static void main(String[] args){

    //Creating local instances of Player/DEnd classes
    Player p1 = new Player("Washington State", "Hercules Mata'afa", 50);
    DEnd p2 = new DEnd("Washington State", "Hercules Mata'afa", 50, 34, 121, 21.0);

    //Print statements
    System.out.println(p2);
    System.out.println(p1.equals(p2));
    System.out.println(p1==p2);
  }
}
