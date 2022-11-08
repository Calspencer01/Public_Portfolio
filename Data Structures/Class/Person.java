public class Person{
  private String name;
  private int age;
  private String address;
  private String phone;

  public Person(String n, int ag, String ad, String p){
    name = n;
    age = ag;
    address = ad;
    phone = p;
  }
  public String getName(){
    return name;
  }
  public int getAge(){
    return age;
  }
  public void setAddress(String newAddress){
    address = newAddress;
  }
  public String toString(){
     return name + ", " + age + ", " + phone;
  }
}
