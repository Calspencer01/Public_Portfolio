/** TestMap assignment: Sets & Maps
* Date: 10/13/19
* @author Calvin Spencer
* @author Mimi Ughetta
*/
import java.util.*;
import java.io.*;

public class TestMap{
  public static void main(String[] args) {
    System.out.println(mobyDickTop5());

  }
  public static Map<Integer,String> mobyDickTop5(){
    Map<String,Integer> fileMap = new HashMap<String,Integer>();
    Map<Integer,String> finalMap = new TreeMap<Integer,String>(Collections.reverseOrder());
    try{
      Scanner in = new Scanner(new File("MobyDick.txt"));
      while (in.hasNext()){
        String word = in.next();
        word = word.toLowerCase();
        if (fileMap.containsKey(word)){
          fileMap.put(word,fileMap.get(word)+1);
        }
        else{
          fileMap.put(word,1);
        }
      }

      Set<String> keys = fileMap.keySet();
      Iterator<String> iter = keys.iterator();
      List<Integer> vals = new ArrayList<Integer>(fileMap.values());
      Collections.sort(vals);
      Collections.reverse(vals);

      while (iter.hasNext()){
        String val = iter.next();
        int x = fileMap.get(val);
        for (int i = 0; i < 5; i++){
          if (x == vals.get(i)){
            finalMap.put(x,val);
          }
        }
        if (finalMap.size() > 4){
          break;
        }

      }
      for (int i = 0; i < 5; i++){
        int max = vals.get(i);
      }


    }
    catch (FileNotFoundException e){
      System.err.println(e);
    }
    return finalMap;
  }

}
