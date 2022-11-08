/** Rectangle: Inherited from Shape class
  * Date: 9/10/2019
  *
  *@author Calvin Spencer
  *@author Mimi Ughetta
*/
public class Rectangle extends Shape{
  //private fields
  private double width;
  private double length;

  //constructor
  public Rectangle(double wid, double len){
    width = wid;
    length = len;
  }

  //area
  public double area(){
    return width*length;
  }
}
