/** Methods and fields to implement Movie class
	*	Date: 11/7/2019.
	*
	*	@author Calvin Spencer
	*	@author Mimi Ughetta
*/
import java.util.*;

public class Movie
{
    // private fields
    private double score;
    private String title, genre;
    private int year;
    // constructor
    public Movie(String title,String genre,int year,double score)
    {
        this.title = title; this.genre = genre;
        this.year = year; this.score = score;
    }
    // accessors
    public double getScore()
        {return this.score;}
    public String getTitle()
        {return this.title;}
    public String getGenre()
        {return this.genre;}
    public int getYear()
        {return this.year;}
    // toString
    public String toString()
    {
        return this.title + " ("+this.year+")\n\tRating: "+this.score+"\n\tGenre: "+this.genre+"\n";
    }
    // Comparators
    public static class GenreCompare implements Comparator<Movie>
    {
        public int compare(Movie m1,Movie m2)
        {
            return m1.getGenre().compareToIgnoreCase(m2.getGenre());
        }
    }
    public static class ScoreCompare implements Comparator<Movie>
    {
        public int compare(Movie m1,Movie m2)
        {
            if(m1.getScore() < m2.getScore())
                {return -1;}
            else if(m1.getScore() > m2.getScore())
                {return 1;}
            else
                {return 0;}
        }
    }
    public static class TitleCompare implements Comparator<Movie>
    {
        public int compare(Movie m1,Movie m2)
        {
            return m1.getTitle().compareToIgnoreCase(m2.getTitle());
        }
    }
    public static class YearCompare implements Comparator<Movie>
    {
        public int compare(Movie m1,Movie m2)
        {
            if(m1.getYear() < m2.getYear())
                {return -1;}
            else if(m1.getYear() > m2.getYear())
                {return 1;}
            else
                {return 0;}
        }
    }
    // selection sort with array lists
    public static <T> void sort(ArrayList<T> list,Comparator<T> cmp)
    {
        int n = list.size();
        for(int i=0; i<n; i++)
        {
            int ind = i;
            for(int j=i+1; j<n; j++)
            {
                if(cmp.compare(list.get(j),list.get(ind))<0)
                    {ind = j;}
            }
            T temp = list.get(i);
            list.set(i,list.get(ind));
            list.set(ind,temp);
        }
    }
    // selectio sort with linked lists
    public static <T> void sort(LinkedList<T> list,Comparator<T> cmp)
    {
        int n = list.size();
        for(int i=0; i<n; i++)
        {
            Iterator<T> it = list.iterator();
            for(int j=0; j<i; j++)
                {it.next();}
            T curVal = it.next();
            int ind = i;
            for(int j=i+1; it.hasNext(); j++)
            {
                T nexVal = it.next();
                if(cmp.compare(nexVal,curVal)<0)
                {
                    curVal = nexVal;
                    ind = j;
                }
            }
            list.add(i,list.remove(ind));
        }
    }
    // main
    public static void main(String[] args)
    {
        // Action movies
        Movie m1 = new Movie("Black Panther","Action",2018,0.97);
        Movie m2 = new Movie("Star Wars: The Last Jedi","Action",2017,0.91);
        Movie m3 = new Movie("Logan","Action",2017,0.93);
        // Animation movies
        Movie m4 = new Movie("Coco","Animation",2017,0.97);
        Movie m5 = new Movie("Up","Animation",2009,0.98);
        Movie m6 = new Movie("Toy Story 2","Animation",1999,1.0);
        // Comedy movies
        Movie m7 = new Movie("Lady Bird","Comedy",2017,0.99);
        Movie m8 = new Movie("La La Land","Comedy",2016,0.91);
        Movie m9 = new Movie("The Big Sick","Comedy",2017,0.98);
        // movie list (Array List)
        LinkedList<Movie> list = new LinkedList<Movie>(Arrays.asList(m1,m2,m3,m4,m5,m6,m7,m8,m9));
        System.out.println(list);

        // Comparators
        ScoreCompare scoreComp = new ScoreCompare();
        GenreCompare genreComp = new GenreCompare();
        // sorting (score then genre) using sort
        System.out.println(list);
        sort(list,scoreComp);
        sort(list,genreComp);
        System.out.println(list);
    }
}
