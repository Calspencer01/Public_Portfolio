/** Queens.java: Recursive backtracking
* @author Calvin Spencer
* @author Mimi Ughetta
* Date: 10/31/2019
*/



public class Queens{

  public static void main(String[] args) {
    Board board = new Board(4);
    Board board2 = new Board(6);
    Board board3 = new Board(8);
    solve(board);
    solve(board2);
    solve(board3);
    board.print();
    System.out.println();
    board2.print();
    System.out.println();
    board3.print();
  }

  public static void solve(Board b){
    explore(b, 1);
  }

  public static boolean explore(Board b, int row){
    //Reached a row larger than board
    if (row > b.size()){
      return true;
    }
    for (int col = 1; col <= b.size(); col++){
      //If can be safely placed
      if (b.safe(row,col)){
        //Place it
        b.place(row,col);

        //Explore if any options return true in the next row
        if (explore(b,row+1)){
          return true;
        }
        else{
          //Remove queen and continue iterating
            b.remove(row,col);
        }
      }
    }
    return false;
  }
}
