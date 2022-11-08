/** Methods and fields to implement Movie class
	*	Date: 1/7/2019.
	*
	*	@author Thomas R. Cameron
	*	@author My Partner
*/
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

public class TestMovie
{
    // load data method
    public static void loadData(LinkedList<Movie> movieList) throws IOException
    {
        // file input stream
        BufferedReader reader = new BufferedReader(new FileReader("IMDb.csv"));
        // read file line by line
        String line = null;
        while((line = reader.readLine()) != null)
        {
            // scanner to read line
            Scanner scanner = new Scanner(line);
            // seperate line by comma
            scanner.useDelimiter(",");
            // index for fields
            int ind = 0;
            // fields
            String title = null, genre = null;
            int year = 0;
            double score = 0;
            // read line
            while(scanner.hasNext())
            {
                String text = scanner.next();
                // strip off all non-ASCII characters
                text = text.replaceAll("[^\\x00-\\x7F]", "");
                // erase all ASCII control characters
                text = text.replaceAll("[\\p{Cntrl}&&[^\r\n\t]]", "");
                // remove non-printable unicode characters
                text = text.replaceAll("\\p{C}", "");
                // trim extra white spaces
                text = text.trim();
                if(ind == 0)
                    {title = text;}
                else if(ind == 1)
                    {genre = text;}
                else if(ind == 2)
                    {year = Integer.parseInt(text);}
                else if(ind == 3)
                    {score = Double.parseDouble(text);}
                ind++;
            }
            movieList.add(new Movie(title,genre,year,score));
        }
    }

    public static <T> int binSearch(ArrayList<T> list, T target, Comparator<T> comp){

      return binSearch(list, target, comp, 0, list.size());
    }

    private static <T> int binSearch(ArrayList<T> list, T target, Comparator<T> comp, int min, int max){
      if (min > max){
        return -1;
      }
      else{
        int mid = (min+max)/2;
        if (comp.compare(list.get(mid),target) == 0){
          return mid;
        }
        else if (comp.compare(list.get(mid),target) < 0){
          return binSearch(list, target, comp, min+1, max);
        }
        else{
          return binSearch(list, target, comp, 0, mid-1);
        }
      }
    }


    public static void main(String[] args)
    {
        // load movie data
        LinkedList<Movie> movieList = new LinkedList<Movie>();

        try
            {loadData(movieList);}
        catch(IOException e)
            {System.out.println(e);}

        Movie.sort(movieList, new Movie.ScoreCompare());

        int listSize = movieList.size();
        System.out.println(listSize);
        System.out.println(movieList.peek());
        System.out.println(movieList.getLast());


        ArrayList<Movie> scoreAr = new ArrayList<Movie>(movieList);
        int index = binSearch(scoreAr, new Movie("","",0,5.4), new Movie.ScoreCompare());
        System.out.println(index);
        System.out.println(scoreAr.get(index));

        Movie.sort(movieList, new Movie.TitleCompare());
        ArrayList<Movie> titleAr = new ArrayList<Movie>(movieList);

        int ind1 = binSearch(titleAr, new Movie("Skyfall","",0,0), new Movie.TitleCompare());
        int ind2 = binSearch(titleAr, new Movie("Gladiator","",0,0), new Movie.TitleCompare());
        System.out.println(titleAr.get(ind1));
        System.out.println(titleAr.get(ind2));

        Movie.sort(movieList, new Movie.YearCompare());
        ArrayList<Movie> yearAr = new ArrayList<Movie>(movieList);
        System.out.println("Oldest Movie: " + yearAr.get(0));
        System.out.println("Newest Movie: " + yearAr.get(yearAr.size()-1));

    }
}
