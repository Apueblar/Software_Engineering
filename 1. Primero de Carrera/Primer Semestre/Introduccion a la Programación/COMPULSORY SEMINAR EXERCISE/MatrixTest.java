import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * The test class MatrixTest.
 *
 * @author  (your name)
 * @version (a version number or a date)
 */
public class MatrixTest
{
    /**
     * Default constructor for test class MatrixTest
     */
    public MatrixTest()
    {
    }

    /**
     * Sets up the test fixture.
     *
     * Called before every test case method.
     */
    @BeforeEach
    public void setUp()
    {
    }

    /**
     * Tears down the test fixture.
     *
     * Called after every test case method.
     */
    @AfterEach
    public void tearDown()
    {
    }
    
    //# Test Method 2
    
    /**
     * Test for the constructor: Matrix(int[][] matrix)
     * 
     * --> Case 1: Correct Matrix
     * Case 2: Null Matrix
     * Case 3: 0 length matrix
     * Case 4: Different length columns and rows
     * Case 5: Length Greater than 20
     */
    @Test
    public void correctMatrixTest()
    {
        int[][] matrix = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
        Matrix dummy = new Matrix(matrix);
        
        int[][] matrix1 = {{1, 2}, {4, 5}};
        dummy = new Matrix(matrix1);
    }
    
    /**
     * Test for the constructor: Matrix(int[][] matrix)
     * 
     * Case 1: Correct Matrix
     * --> Case 2: Null Matrix
     * Case 3: 0 length matrix
     * Case 4: Different length columns and rows
     * Case 5: Length Greater than 20
     */
    @Test
    public void nullMatrixTest()
    {
        try
        {
            Matrix dummy = new Matrix(null);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(Matrix.NULL_MATRIX, e.getMessage());
        }
    }
    
    /**
     * Test for the constructor: Matrix(int[][] matrix)
     * 
     * Case 1: Correct Matrix
     * Case 2: Null Matrix
     * --> Case 3: 0 length matrix
     * Case 4: Different length columns and rows
     * Case 5: Length Greater than 20
     */
    @Test
    public void length0MatrixTest()
    {
        int[][] matrix = new int[0][0];
        try
        {
            Matrix dummy = new Matrix(matrix);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(Matrix.NULL_MATRIX, e.getMessage());
        }
    }
    
    /**
     * Test for the constructor: Matrix(int[][] matrix)
     * 
     * Case 1: Correct Matrix
     * Case 2: Null Matrix
     * Case 3: 0 length matrix
     * --> Case 4: Different length columns and rows
     * Case 5: Length Greater than 20
     */
    @Test
    public void notSquareMatrixTest()
    {
        int[][] matrix = new int[1][2];
        try
        {
            Matrix dummy = new Matrix(matrix);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(Matrix.NOT_SQUARE, e.getMessage());
        }
        
        int[][] matrix1 = new int[10][5];
        try
        {
            Matrix dummy = new Matrix(matrix1);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(Matrix.NOT_SQUARE, e.getMessage());
        }
    }
    
    /**
     * Test for the constructor: Matrix(int[][] matrix)
     * 
     * Case 1: Correct Matrix
     * Case 2: Null Matrix
     * Case 3: 0 length matrix
     * Case 4: Different length columns and rows
     * --> Case 5: Length Greater than 20
     */
    @Test
    public void length21AndMoreMatrixTest()
    {
        int[][] matrix = new int[21][21];
        try
        {
            Matrix dummy = new Matrix(matrix);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(Matrix.ERR_LENGTH, e.getMessage());
        }
        
        int[][] matrix1 = new int[25][25];
        try
        {
            Matrix dummy = new Matrix(matrix1);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(Matrix.ERR_LENGTH, e.getMessage());
        }
        
        int[][] matrix2 = new int[100][100];
        try
        {
            Matrix dummy = new Matrix(matrix2);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(Matrix.ERR_LENGTH, e.getMessage());
        }
        
        int[][] matrix3 = new int[1000][1000];
        try
        {
            Matrix dummy = new Matrix(matrix3);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(Matrix.ERR_LENGTH, e.getMessage());
        }
    }
    
    
    //# Test Method 4
    
    /**
     * Test for the method: flattenMatrix()
     * 
     * --> Case 1: Correct Flattened Matrix
     */
    @Test
    public void flattenedMatrixTest()
    {
        int[][] matrix = {{5, 10},{16, 30}};

        Matrix dummy = new Matrix(matrix);
        ArrayList<Integer> flattenedResult = dummy.flattenMatrix();

        ArrayList<Integer> expected = new ArrayList<>(Arrays.asList(5, 16, 10, 30));

        assertEquals(expected, flattenedResult);
        
        
        int[][] matrix1 = {{20, 15, 10},{50, 40, 30}, {34, 24, 14}};

        dummy = new Matrix(matrix1);
        flattenedResult = dummy.flattenMatrix();

        expected = new ArrayList<>(Arrays.asList(20, 50, 34, 15, 40, 24, 10, 30, 14));

        assertEquals(expected, flattenedResult);
    }
    
    
    //# Test Method 5
    
    /**
     * Test for the method: addRows()
     * 
     * --> Case 1: Correct Sum Matrix
     */
    @Test
    public void addMatrixTest()
    {
        int[][] matrix = {{5, 10},{16, 30}};
        Matrix dummy = new Matrix(matrix);
        dummy.addRows();
        int[][] expected = {{5, 15}, {16, 46}};
        assertMatrixEquals(expected,dummy.getMatrix());
        
        
        int[][] matrix1 = {{20, 15, 10},{50, 40, 30}, {34, 24, 14}};
        dummy = new Matrix(matrix1);
        dummy.addRows();
        int[][] expected1 = {{20, 15, 45}, {50, 40, 120}, {34, 24, 72}};
        assertMatrixEquals(expected1,dummy.getMatrix());
    }
    
    /**
     * Checks if 2 matrices have the same numbers.
     */
    private void assertMatrixEquals(int[][] expected, int[][] actual) {
        for (int i = 0; i < expected.length; i++) {
            assertArrayEquals(expected[i], actual[i]);
        }
    }
    
    
    //# Test Method 6
    
    /**
     * Test for the method: swapColumns()
     * 
     * --> Case 1: Correct swap of Columns
     */
    @Test
    public void swapColumnsTest()
    {
        int[][] matrix = {{20, 15, 10},{50, 40, 30}, {34, 24, 14}};
        Matrix dummy = new Matrix(matrix);
        dummy.swapColumns();
        int[][] expected = {{10, 15, 20},{30, 40, 50}, {14, 24, 34}};
        assertMatrixEquals(expected,dummy.getMatrix());
        
        
        int[][] matrix1 = {{83, 32, 79, 52, 71, 43},
                           {47, 89, 16, 79, 47, 67},
                           {64, 44, 56, 29, 72, 40},
                           {25, 81, 92, 23, 14, 36},
                           {86, 43, 16, 48, 77, 25},
                           {33, 32, 45, 14, 94, 85}};
        dummy = new Matrix(matrix1);
        dummy.swapColumns();
        int[][] expected1 = {{79, 32, 71, 52, 83, 43},
                             {16, 89, 47, 79, 47, 67},
                             {56, 44, 72, 29, 64, 40},
                             {92, 81, 14, 23, 25, 36},
                             {16, 43, 77, 48, 86, 25},
                             {45, 32, 94, 14, 33, 85}};
        assertMatrixEquals(expected1,dummy.getMatrix());
    }
    
    
    //# Test Method 9
    
    /**
     * Test for the method: horizontalReverse()
     * 
     * --> Case 1: Correct horizontal row reverse
     */
    @Test
    public void horizontalReverseTest()
    {
        int[][] matrix = {{20, 15, 10},{50, 40, 30}, {34, 24, 14}};
        Matrix dummy = new Matrix(matrix);
        dummy.horizontalReverse();
        int[][] expected = {{20, 15, 10},{30, 40, 50}, {34, 24, 14}};
        assertMatrixEquals(expected,dummy.getMatrix());
        
        
        int[][] matrix1 = {{83, 32, 79, 52, 71, 43},
                           {47, 89, 16, 79, 47, 67},
                           {64, 44, 56, 29, 72, 40},
                           {25, 81, 92, 23, 14, 36},
                           {86, 43, 16, 48, 77, 25},
                           {33, 32, 45, 14, 94, 85}};
        dummy = new Matrix(matrix1);
        dummy.horizontalReverse();
        int[][] expected1 = {{83, 32, 79, 52, 71, 43},
                             {67, 47, 79, 16, 89, 47},
                             {64, 44, 56, 29, 72, 40},
                             {36, 14, 23, 92, 81, 25},
                             {86, 43, 16, 48, 77, 25},
                             {85, 94, 14, 45, 32, 33}};
        assertMatrixEquals(expected1,dummy.getMatrix());
    }
    
    
    //# Test Method 10
    
    /**
     * Test for the method: smoothMatrix()
     * 
     * --> Case 1: Correct smooth Matrix
     */
    @Test
    public void smoothMatrixTest()
    {
        int[][] matrix = {{20, 15, 10},
                          {50, 40, 30}, 
                          {34, 24, 14}};
        Matrix dummy = new Matrix(matrix);
        
        int[][] expected = {{50, 50, 40},
                            {40, 50, 40},
                            {50, 50, 40}};
        assertMatrixEquals(expected,dummy.smoothMatrix());
        
        
        int[][] matrix1 = {{83, 32, 79, 52, 71, 43},
                           {47, 89, 16, 79, 47, 67},
                           {64, 44, 56, 29, 72, 40},
                           {25, 81, 92, 23, 14, 36},
                           {86, 43, 16, 48, 77, 25},
                           {33, 32, 45, 14, 94, 85}};
        dummy = new Matrix(matrix1);
        int[][] expected1 = {{89, 89, 89, 79, 79, 71},
                             {89, 83, 89, 79, 79, 72},
                             {89, 92, 92, 92, 79, 72},
                             {86, 92, 81, 92, 77, 77},
                             {81, 92, 92, 94, 94, 94},
                             {86, 86, 48, 94, 85, 94}};
        assertMatrixEquals(expected1,dummy.smoothMatrix());
    }
}