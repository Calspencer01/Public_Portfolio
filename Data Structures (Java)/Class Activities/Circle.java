/** Circle: Inherited from Shape class
  * Date: 9/10/2019
  *
  *@author Calvin Spencer
  *@author Mimi Ughetta
*/
public class Circle extends Shape{

  //private field
  private double radius;

  //constructor
  public Circle(double rad){
    radius = rad;
  }

  //area
  public double area(){
    return Math.PI*radius*radius;
  }
}
