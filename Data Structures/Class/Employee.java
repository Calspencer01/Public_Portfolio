public final class Employee extends Person{
  private String ssn;
  private float salary;

  public Employee(String n, int ag, String ad, String p, String ss, float sal){
    super(n,ag,ad,p);
    this.ssn = ss;
    this.salary = sal;

  }

  public String toString(){
    return this.getName() + ", " + ssn + ", " + salary;
  }
}
