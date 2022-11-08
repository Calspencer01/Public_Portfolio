/** RecursiveGraphics: Drawing triangles using recursive methods
* Date: 10/29/2019
* @author Calvin Spencer
* @author Mimi Ughetta
*/
import java.awt.*;
import java.util.*;

public class RecursiveGraphics{
  public static void main(String[] args){
    sierpTri(800,8);
  }

  public static void sierpTri(int size, int level){
    DrawingPanel p = new DrawingPanel(size,size);
    p.setBackground(new Color(220,220,220));
    Graphics g = p.getGraphics();

    int h = (int) Math.round(size*Math.sqrt(3.0)/2);
    Point p1 = new Point(0,h);
    Point p2 = new Point(size/2,0);
    Point p3 = new Point(size,h);


    sierpTri(g,p1,p2,p3,level);
  }

  private static void sierpTri(Graphics g, Point p1, Point p2, Point p3, int level){
    Polygon mid = new Polygon();
    mid.addPoint(midpoint(p1,p2).x,midpoint(p1,p2).y);
    mid.addPoint(midpoint(p1,p3).x,midpoint(p1,p3).y);
    mid.addPoint(midpoint(p2,p3).x,midpoint(p2,p3).y);
    g.setColor(new Color(255 - (20*level-1),0,0));
    g.fillPolygon(mid);

    if (level <= 1){
      Polygon poly = new Polygon();
      poly.addPoint(p1.x,p1.y);
      poly.addPoint(p2.x,p2.y);
      poly.addPoint(p3.x,p3.y);

      g.setColor(new Color(0,0,0));
      g.fillPolygon(poly);
    }
    else{
      g.setColor(new Color(0,200,150));
      sierpTri(g,midpoint(p1,p2),p1,midpoint(p1,p3),level-1);
      sierpTri(g,midpoint(p1,p2),p2,midpoint(p2,p3),level-1);
      sierpTri(g,midpoint(p1,p3),p3,midpoint(p2,p3),level-1);
    }

  }

  public static Point midpoint(Point p1, Point p2){
    return new Point((p1.x + p2.x)/2,(p1.y + p2.y)/2);
  }
}
