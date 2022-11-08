/** Class: BinarySearchTree
* @author Calvin Spencer
* @author Mimi Ughetta
* Date: 11/19/2019
*/

import java.util.LinkedList;
import java.util.Iterator;
import java.util.Collection;
import java.util.Arrays;

public class BinarySearchTree<T extends Comparable<T>>{
  private T parent;
  private BinarySearchTree<T> leftChild;
  private BinarySearchTree<T> rightChild;
  public BinarySearchTree(T parent){
    this.parent = parent;
    this.leftChild = null;
    this.rightChild = null;
  }

  public BinarySearchTree(Collection<T> values){
    this.parent = null;
    this.leftChild = null;
    this.rightChild = null;

    Iterator<T> it = values.iterator();
    while (it.hasNext()){
      this.add(it.next());
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

  public boolean search(T value){
    if (this.parent == null){
      return false;
    }
    else if (value.compareTo(this.parent) == 0){
      return true;
    }
    else if (value.compareTo(this.parent) < 0){
      if (this.leftChild == null){
        return false;
      }
      else{
        return this.leftChild.search(value);
      }
    }
    else{
      if (this.rightChild == null){
        return false;
      }
      else{
        return this.rightChild.search(value);
      }
    }
  }

  public void add(T value){
    if (this.parent == null){
      this.parent = value;
    }
    else if (value.compareTo(this.parent) <= 0){
      if (this.leftChild == null){
        this.leftChild = new BinarySearchTree<T>(value);
      }
      else{
        this.leftChild.add(value);
      }
    }
    else{
      if (this.rightChild == null){
        this.rightChild = new BinarySearchTree<T>(value);
      }
      else{
        this.rightChild.add(value);
      }
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

  public static void main(String[] args) {
    BinarySearchTree<Integer> bst = new BinarySearchTree<Integer>(Arrays.asList(11,6,19,4,8,17,43,5,10,31,49));
    BinarySearchTree<Integer> inOrderBST = new BinarySearchTree<Integer>(bst.inOrder());
    System.out.println("BST: \n" + bst);
    System.out.println("In-Order BST: \n\n" + inOrderBST);

    System.out.println("48 in BST: " + bst.search(48));
    System.out.println("49 in BST: " + bst.search(49));

    System.out.println("48 in in-order BST: " + inOrderBST.search(48));
    System.out.println("49 in in-order BST: " + inOrderBST.search(49));
  }
}
