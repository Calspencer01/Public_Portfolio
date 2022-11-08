/** Methods and Fields to implement a single bank BankAccount
  * Date: 9/5/2019
  *
  *@author Calvin Spencer
  *@author Mimi Ughetta
*/
public class BankAccount
{
  // private fields
  private int acctNumber;
  private double balance;
  private String owner;

  // public fields
  public static final int routNumber = 12345678;

  /** zero-parameter constructor
  */
  public BankAccount()
  {
    acctNumber = 0;
    balance = 0.0;
    owner = null;
  }


  /** three-parameter constructor
  *
  * @param a is account acctNumber
  * @param b is balance
  * @param o is owner
  */
  public BankAccount(int a, double b, String o)
  {
    acctNumber = a;
    balance = b;
    owner = o;
  }

  /** deposit to account
  * @param x deposit amount
  */
  public void deposit(double x)
  {
      balance += x;
  }

  /** withdraw from account
  *
  * @param x withdraw amount
  * @throws OverdraftException in case where balance is insufficient for withdraw
  *
  */
  public void withdraw(double x) throws OverdraftException
  {
    if (x <= balance)
    {
      balance -= x;
    }
    else
    {
      throw new OverdraftException("insufficient funds");
    }
  }

  /** access accout number from account
  *
  * @return acctNumber
  */
  public int getAcctNumber()
  {
    return acctNumber;
  }

  /** access balance from account
  *
  * @return balance
  */
  public double getBalance()
  {
    return balance;
  }

  /** creates string with all account information
  *
  * @return account
  */
  public String toString()
  {
    String account = "Owner: " + owner + "\n";
    account += "Routing Number: " + routNumber + "\n";
    account += "Account Number: " + acctNumber + "\n";
    account += "Balance: " + balance + "\n";
    return account;
  }

  /** check if two bank accounts are the same
  *
  * @return boolean
  */
  public boolean equals(Object obj)
  {
    if (!(obj instanceof BankAccount)) //checks to see if it is even an instance of the BankAccount class
    {
      return false;
    }
    BankAccount otherBA = (BankAccount) obj;
    return this.acctNumber == otherBA.acctNumber;

  }

  /** transfers money from this account to the given account
  *
  * @param otherBA Bank account money is being transferred to
  * @param transAmt Amount of money being transferred
  */
  public void transfer(BankAccount otherBA, double transAmt) throws OverdraftException
  {
    this.withdraw(transAmt);
    otherBA.deposit(transAmt);
  }

}
