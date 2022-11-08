/** Overdraft Exception for BankAccount class
  * Date: 9/5/2019
  *
  *@author Calvin Spencer
  *@author Mimi Ughetta
*/
public class OverdraftException extends Exception
{

  public OverdraftException()
  {
    super();
  }
  public OverdraftException(String message)
  {
    super(message);
  }
  public OverdraftException(String message, Throwable cause)
  {
    super(message, cause);
  }
  public OverdraftException(Throwable cause)
  {
      super(cause);
  }

}
