/** Class Assignment: Inheritance (Person Classes)
  * Date: 9/10/2019
  *
  *@author Calvin Spencer
  *@author Mimi Ughetta
*/
public class PersonDemo{
  public static void main(String[] args){
    Person p = new Person("Paul", 20, "Paul's Address", "207-319-1094");
    Student s = new Student("Steve", 12, "Steve's Address", "603-294-7291", "Steve's ID", (float) 3.5);
    Employee e = new Employee("Emily", 40, "Emily's Address", "800-421-9184", "Emily's SS #", 40000);

    System.out.println(p.toString());
    System.out.println(s.toString());
    System.out.println(e.toString());

    System.out.println();
    System.out.println("p,s " + isOlder(p,s));
    System.out.println("p,e " + isOlder(p,e));
    System.out.println("e,s " + isOlder(e,s));
    System.out.println("e,p " + isOlder(e,p));
    System.out.println("s,e " + isOlder(s,e));
    System.out.println("s,p " + isOlder(s,p));


  }

  public static boolean isOlder(Person p1, Person p2){
    return p1.getAge() > p2.getAge();
  }
}
