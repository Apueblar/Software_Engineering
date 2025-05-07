import java.util.*;
/**
 * This is the math class were you can find some math exercises.
 * 
 * @author Álvaro Puebla
 * @version 22-09-2023
 */
public class Math
{
    public final static String ERR_MAX_VALUE = "The value must be greater than 1.";
    public final static String DIF_DIM = "Both matrices must have the same dimension.";
    
    /**
     * Constructor for objects of class Math
     */
    public Math()
    {
        
    }

    /**
     * Computes the area of a triangle from its base and height. Both must be in the 
     * 
     * @param  baseTriangle   Base of the triangle. Positive numbers are the ones acepted.
     * @param  heightTriangle   Height of the triangle. Positive numbers are the ones acepted.
     * @return Returns the area of the triangle in squared units.
     */
    public double compueteArea(double baseTriangle, double heightTriangle)
    {
        // put your code here
        return (baseTriangle * heightTriangle)/2;
    }
    
    /**
     * Given a text, removes the spaces and checks if it is a palindrome.
     * 
     * @param text The text to check.
     * 
     * @return True if the text is palindrome. Otherwise, false.
     */
    public boolean isPalindrome(String text)
    {
        String result = text.replace(" ", "").toLowerCase();
        for(int i = 0; i < result.length() / 2; i++){
            if (result.charAt(i) != result.charAt(result.length() - i - 1)){return false;}
        }
        return true;
    }
    
    /**
     * Given a number returns all the prime numbers under that number.
     * 
     * @param number The number is checked.
     * 
     * @return Returns true if the number is prime.
     */
    private boolean isPrime(int number)
    {
        for (int i = 2; i < number - 1; i++){
            if (number % i == 0){return false;}
        }
        return true;
    }
    
    /**
     * Given a number returns all the prime numbers under that number.
     * 
     * @param limit The limit.
     * 
     * @return Returns an array list with all the primes lower than a given value.
     */
    public ArrayList<Integer> getPrimeUnder(int limit)
    {
        if(limit < 2){throw new RuntimeException(ERR_MAX_VALUE);}
        ArrayList<Integer> primes = new ArrayList<Integer>();
        
        for (int i = 2; i <limit; i++){
            if (isPrime(i)){primes.add(i);}
        }
        
        return primes;
    }
    
    /**
     * Given an array of ints, it sorts it, and returns it.
     * 
     * @param array The array that is going to be sort
     * 
     * @return The sorted array.
     */
    public int[] sortIntArray(int[] array)
    {
        int aux;
        for (int i = 0; i < array.length; i++){
            for (int j = 1; j < array.length; j++){
                if (array[j - 1] > array[j]){
                    aux = array[j - 1];
                    array[j - 1] = array[j];
                    array[j] = aux;
                }
            }
        }
        return array;
    }
    
    /**
     * Given 2 matrices, it will add pixel by pixel and return a new sum matrix.
     * 
     * @param a The first Matrix
     * @param b The second Matrix
     * 
     * @return The added Matrix
     */
    public int[][] sumMatrix(int a[][], int b[][])
    {
        if (a.length != b.length || a[0].length != b[0].length){throw new RuntimeException(DIF_DIM);}
        
        int[][] sumMatrix = new int[a.length][a[0].length];
        for (int i = 0; i < a.length; i++){
            for (int j = 0; j < a[0].length; j++){
                sumMatrix[i][j] = a[i][j] + b[i][j];
            }
        }
        return sumMatrix;
    }
}




















