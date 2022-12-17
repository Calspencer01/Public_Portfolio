public final class Student extends Person{
  private String studentID;
  private float gpa;

  public Student(String n, int ag, String ad, String p, String id, float gp){
    super(n,ag,ad,p);
    this.studentID = id;
    this.gpa = gp;
  }

  public String toString(){
    return this.getName() + ", " + studentID + ", " + gpa;
  }
}
