/** Overdraft Exception for BankAccount class
  * Date: 9/5/2019
  *
  *@author Calvin Spencer
  *@author Mimi Ughetta
*/
public class TestBankAccount
{
  public static void main(String[] args)
  {
    BankAccount ba1 = new BankAccount(1001,500.0,"Account1Name");
    BankAccount ba2 = new BankAccount(1002,250.0,"Account1Name");
    System.out.println(ba1.toString());
    System.out.println(ba2.toString());

    try
    {
      ba1.withdraw(100);
      System.out.println("After $100 withdrawal from bank account 1: \n\n" + ba1.toString());
    }
    catch (OverdraftException e)
    {
      System.err.println(e);
    }


    ba2.deposit(50);
    System.out.println("After $50 deposit into bank account 1: \n\n" + ba2.toString());

    try
    {
      ba1.transfer(ba2, 75);
      System.out.println("After $75 transfer from acc1 to acc2: \n\n" + ba1.toString() + "\n" + ba2.toString());
    }
    catch (OverdraftException e)
    {
      System.err.println(e);
    }

    try
    {
      ba2.transfer(ba1, 500);
      System.out.println("After $500 transfer from acc2 to acc1: \n\n" + ba1.toString() + "\n" + ba2.toString());
    }
    catch (OverdraftException e)
    {
      System.err.println(e);
    }

    try
    {
      ba1.transfer(ba1, 100);
      System.out.println("After $100 transfer from acc1 to acc1: \n\n" + ba1.toString() + "\n" + ba2.toString());
    }
    catch (OverdraftException e)
    {
      System.err.println(e);
    }


  }
}
