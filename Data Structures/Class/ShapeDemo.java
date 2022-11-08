/** Class Assignment: Inheritance (Abstract Shape Classes)
  * Date: 9/10/2019
  *
  *@author Calvin Spencer
  *@author Mimi Ughetta
*/
public class ShapeDemo{
  public static void main(String[] args){

    //Creates instances of each shape
    Circle c = new Circle(50);
    Square s = new Square(50);
    Rectangle r = new Rectangle(30,60);

    //Prints dimensions & areas of each shape
    System.out.println("Circle of rad 50: 7854u^2");
    System.out.println("Rectangle (30x60):  1800u^2");
    System.out.println("Square of length 50: 2500u^2\n");

    //isBigger results
    System.out.println("c,s " + isBigger(c,s));
    System.out.println("c,r " + isBigger(c,r));
    System.out.println("r,s " + isBigger(r,s));
    System.out.println("r,c " + isBigger(r,c));
    System.out.println("s,c " + isBigger(s,c));
    System.out.println("s,r " + isBigger(s,r));

  }

  /** Returns true if larger area is s1
  * @param s1 first shape
  * @param s2 second shape
  */
  public static boolean isBigger(Shape s1, Shape s2){
    //calls area method within each shape
    return s1.area() > s2.area();
  }
}
