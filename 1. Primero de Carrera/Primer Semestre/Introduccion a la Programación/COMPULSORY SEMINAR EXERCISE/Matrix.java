import java.util.*;
/**
 * The Matrix class.
 * 
 * @author UO299874
 * @version 1.0.0
 */
public class Matrix
{
    private int matrix[][];
    public final static String ERR_LENGTH = "Invalid dimension for the matrix";
    public final static String NOT_SQUARE = "The matrix must be square";
    public final static String NULL_MATRIX = "Matrix must exist";
    /**
     * Constructor for objects of class Matrix
     * 
     * @throws ERR_LENGTH if the length is lower than 1 or greater than 20.
     */
    public Matrix(int length)
    {
        if(length <= 0 || length > 20){
            throw new RuntimeException(ERR_LENGTH);
        }
        
        matrix = new int [length][length];
        
        Random coin = new Random();
        for(int i = 0; i < matrix.length; i++){
            for(int j = 0; j < matrix[0].length; j++){
                matrix[i][j] = coin.nextInt(256);
            }
        }
    }
    
    /**
     * Constructor for objects of class Matrix
     * 
     * Used for Unit Testing.
     * @throws NULL_MATRIX if the matrix is null or length 0.
     * @throws NOT_SQUARE if the matrix is not square.
     * @throws ERR_LENGTH if the length is lower than 1 or greater than 20.
     */
    public Matrix(int[][] matrix)
    {
        if(matrix == null){
            throw new RuntimeException(NULL_MATRIX);
        }
        
        if(matrix.length == 0 || matrix[0].length == 0){
            throw new RuntimeException(NULL_MATRIX);
        }
        
        if(matrix.length != matrix[0].length){
            throw new RuntimeException(NOT_SQUARE);
        }
        
        if(matrix.length < 0 || matrix.length > 20){
            throw new RuntimeException(ERR_LENGTH);
        }
        
        int length = matrix.length;
        this.matrix = new int [length][length];
        for(int i = 0; i < length; i++){
            for(int j = 0; j < length; j++){
                this.matrix[i][j] = matrix[i][j];
            }
        }    
    }
    
    /**
     * Returns a copy of the matrix
     * 
     * @return Copy of the matrix
     */
    public int[][] getMatrix() 
    {
        int[][] copy = new int[matrix.length][matrix[0].length];
        for(int i = 0; i < matrix.length; i++){
            for(int j = 0; j < matrix[0].length; j++){
                copy[i][j] = matrix[i][j];
            }
        }
        return copy;
    }
    
    /**
     * Returns the content of the array 'flattened,' that is, 
     * it traverses the array bycolumns and copies its elements into a collection of integers, ArrayList<Integer>.
     * 
     * @return Flattened matrix
     */
    public ArrayList<Integer> flattenMatrix()
    {
        ArrayList<Integer> flattenedArray = new ArrayList<Integer>();
        for(int j = 0; j < matrix[0].length; j++){
            for(int i = 0; i < matrix.length; i++){
                flattenedArray.add(matrix[i][j]);
            }
        }
        return flattenedArray;
    }
    
    /**
     * It adds all the elements of each row, 
     * storing the result in the last column of the corresponding row.
     */
    public void addRows()
    {
        int sum = 0;
        for(int i = 0; i < matrix.length; i++){
            sum = 0;
            for(int j = 0; j < matrix[0].length; j++){
                sum += matrix[i][j];
            }
            matrix[i][matrix[0].length - 1] = sum;
        }
    }
    
    /**
     * Exchanges the elements of the even columns (0 <- 2, 2 <- 4, …)
     */
    public void swapColumns()
    {
        int[][] matrix2 = new int[matrix.length][1];
        for(int i = 0; i < matrix.length; i++){
                matrix2[i][0] = matrix[i][0];
        }
        
        for(int j = 0; j < matrix[0].length - 2; j += 2){
            for(int i = 0; i < matrix.length; i++){
                matrix[i][j] = matrix[i][j + 2];
            }
        }
        
        if(matrix[0].length % 2 != 0){
            for(int i = 0; i < matrix.length; i++){
                matrix[i][matrix[0].length - 1] = matrix2[i][0];
            }
        }else{
            for(int i = 0; i < matrix.length; i++){
                matrix[i][matrix[0].length - 2] = matrix2[i][0];
            }
        }
    }
    
    /**
     * Displays the content of the matrix on the console.
     */
    public void print(){
        for(int i = 0; i < matrix.length; i++){
                for(int j = 0; j < matrix[0].length; j++){
                    System.out.print(String.format("%03d",matrix[i][j]) + " ");
                }
                System.out.println();
        }
    }
    
    /**
     * Reverse the elements of the odd rows
     */
    public void horizontalReverse()
    {
        int[][] matrixReversed = new int[matrix.length][matrix[0].length];
        
        for(int i = 0; i < matrix.length; i++){
                for(int j = 0; j < matrix[0].length; j++){
                    matrixReversed[i][matrix[0].length - (j + 1)] = matrix[i][j];
                }
                if (i % 2 == 1){
                    for(int j = 0; j < matrix[0].length; j++){
                        matrix[i][j] = matrixReversed[i][j];
                    }
                }
        }
    }
    
    /**
     * Returns an array obtained from the attribute, 
     * replacing each element with maximun of its neighbors of the original array.
     * 
     * @return The smoothMatrix
     */
    public int [][] smoothMatrix()
    {
        int[][] matrixSmooth = new int[matrix.length][matrix[0].length];
        for(int i = 0; i < matrix.length; i++){
                for(int j = 0; j < matrix[0].length; j++){
                    matrixSmooth[i][j] = findMaxNeighbor(i,j);
                }
        }
        return matrixSmooth;
    }
    
    /**
     * Checks for the highest neighbor
     * 
     * @return The max number of a neighbor.
     */
    private int findMaxNeighbor(int i, int j)
    {
        int maxNumber = 0;
        int row;
        int col;
        int rowMax;
        int colMax;
        
        if (i == 0) {
            row = 0;
        }else{
            row = i - 1;
        }
        
        if (i == this.matrix.length - 1){
            rowMax = i;
        }else{
            rowMax = i + 1;
        }
        
        for(;row <= rowMax; row++){
            if (j == 0) {
                col = 0;
            }else{
                col = j - 1;
            }
            
            if (j == this.matrix[0].length - 1){
                colMax = j;
            }else{
                colMax = j + 1;
            }
            for(;col <= colMax; col++){
                if (maxNumber < matrix[row][col] && (row != i || col != j)){maxNumber = matrix[row][col];}
            }
        }
        
        return maxNumber;
    }
}