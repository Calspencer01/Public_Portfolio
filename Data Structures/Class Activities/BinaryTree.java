/** Binary BinaryTree
* Date: 11/12/2019
* @author Calvin Spencer
* @author Mimi Ughetta
*/
import java.util.LinkedList;
import java.util.ArrayList;
import java.util.Arrays;

public class BinaryTree<T>{
  private T parent;
  private BinaryTree<T> leftChild;
  private BinaryTree<T> rightChild;

  public BinaryTree(T parent){
    this(parent,null,null);
  }

  public BinaryTree(T parent, BinaryTree<T> leftChild, BinaryTree<T> rightChild){
    this.parent = parent;
    this.leftChild = leftChild;
    this.rightChild = rightChild;
  }

  public int numLeaves(){
    if (this.parent == null){
      return 0;
    }
    else if (this.leftChild == null && this.rightChild == null){
      return 1;
    }
    else if (this.leftChild == null){
      return this.rightChild.numLeaves();
    }
    else if (this.rightChild == null){
      return this.leftChild.numLeaves();
    }
    else{
      return this.leftChild.numLeaves() + this.rightChild.numLeaves();
    }
  }

  public int height(){
    if (this.parent == null){
      return 0;
    }
    else if (this.leftChild == null && this.rightChild == null){
      return 0;
    }
    else if (this.leftChild == null){
      return 1+this.rightChild.height();
    }
    else if (this.rightChild == null){
      return 1+this.leftChild.height();
    }
    else{
      return Math.max(this.leftChild.height()+1,this.rightChild.height()+1);
    }
  }

  public LinkedList<T> inOrder(){
    LinkedList<T> list = new LinkedList<T>();
    inOrder(list);
    return list;
  }

  private void inOrder(LinkedList<T> list){
    if (this.leftChild == null && this.rightChild == null){
      list.add(this.parent);
    }
    else if (this.leftChild == null){
      list.add(this.parent);
      this.rightChild.inOrder(list);
    }
    else if (this.rightChild == null){
      this.leftChild.inOrder(list);
      list.add(this.parent);
    }
    else{
      this.leftChild.inOrder(list);
      list.add(this.parent);
      this.rightChild.inOrder(list);
    }
  }

  public LinkedList<T> preOrder(){
    LinkedList<T> list = new LinkedList<T>();
    preOrder(list);
    return list;
  }

  private void preOrder(LinkedList<T> list){
    if (this.leftChild == null && this.rightChild == null){
      list.add(this.parent);
    }
    else if (this.leftChild == null){
      list.add(this.parent);
      this.rightChild.preOrder(list);
    }
    else if (this.rightChild == null){
      list.add(this.parent);
      this.leftChild.preOrder(list);
    }
    else{
      list.add(this.parent);
      this.leftChild.preOrder(list);
      this.rightChild.preOrder(list);
    }
  }

  public LinkedList<T> postOrder(){
    LinkedList<T> list = new LinkedList<T>();
    postOrder(list);
    return list;
  }

  private void postOrder(LinkedList<T> list){
    if (this.leftChild == null && this.rightChild == null){
      list.add(this.parent);
    }
    else if (this.leftChild == null){
      this.rightChild.postOrder(list);
      list.add(this.parent);
    }
    else if (this.rightChild == null){
      this.leftChild.postOrder(list);
      list.add(this.parent);
    }
    else{
      this.leftChild.postOrder(list);
      this.rightChild.postOrder(list);
      list.add(this.parent);
    }
  }

  public String toString(){
    return this.toString(0,"");
  }
  private String toString(int level, String str){
    if (this.parent != null){
      if (this.rightChild != null){
        str = this.rightChild.toString(level + 1, str);
      }
      //Shift over, print parent, add new line
      for (int i = 0; i < level; i++){
        str += "  ";
      }
      str += this.parent + "\n";
      if (this.leftChild != null){
        str = this.leftChild.toString(level + 1, str);
      }
    }
    return str;
  }

  public static <T> BinaryTree<T> buildTree(ArrayList<T> inOrder, LinkedList<T> preOrder){
    return buildTree(inOrder,preOrder,0,inOrder.size()-1, 1);
  }
  private static <T> BinaryTree<T> buildTree(ArrayList<T> inOrder, LinkedList<T> preOrder, int inStrt, int inEnd, int level){
    if (inStrt > inEnd){
      return null;
    }
    T root = preOrder.removeFirst();
    //System.out.println("level: " + level + "   root: " + root);
    if (inStrt == inEnd){
      return new BinaryTree<T>(root);
    }

    int index = inStrt;
    while (inOrder.get(index) != root){
      index++;
    }


    BinaryTree<T> leftChild = buildTree(inOrder,preOrder,inStrt,index-1, level+1);
    BinaryTree<T> rightChild = buildTree(inOrder,preOrder,index+1,inEnd, level+1);

    return new BinaryTree<T>(root,leftChild,rightChild);

  }

  public void removeLeft(){
    this.leftChild = null;
  }
  public void removeRight(){
    this.rightChild = null;
  }
  public void removeLeaves(){
    if (this.isLeaf()){
      this.parent = null;
    }
    else{
      removeLeaves(this);
    }
  }
  private <T> void removeLeaves(BinaryTree<T> tree){
    if (tree.parent == null){

    }
    if (tree.leftChild != null){
      if (tree.leftChild.isLeaf()){
        tree.removeLeft();
      }
      else{
        removeLeaves(tree.leftChild);
      }
    }
    if (tree.rightChild != null){
      if (tree.rightChild.isLeaf()){
        tree.removeRight();
      }
      else{
        removeLeaves(tree.rightChild);
      }
    }


  }

  public boolean isLeaf(){
    return (this.leftChild == null && this.rightChild == null);
  }




  public static void main(String[] args) {
    BinaryTree<Integer> topTree = new BinaryTree<Integer>(8, new BinaryTree<Integer>(5, new BinaryTree<Integer>(9), new BinaryTree<Integer>(7)),new BinaryTree<Integer>(4,null,new BinaryTree<Integer>(11)));
    // System.out.println("Pre: " + topTree.preOrder());
    // System.out.println("In: " + topTree.inOrder());
    // System.out.println("Post " + topTree.postOrder());
    // System.out.println("Height: " + topTree.height());
    LinkedList<Integer> preOrder = new LinkedList<Integer>(Arrays.asList(8,5,9,7,1,12,2,4,11,3));
    ArrayList<Integer> inOrder = new ArrayList<Integer>(Arrays.asList(9,5,1,7,2,12,8,4,3,11));
    BinaryTree<Integer> newTree = buildTree(inOrder,preOrder);
    System.out.println(newTree);
    System.out.println(newTree.preOrder());
    //newTree.removeLeaves();
  //  System.out.println("Tree without leaves: \n" + newTree);
  //  System.out.println("NumLeaves: " + newTree.numLeaves());
  //  System.out.println("\n" + topTree);
  }
}
