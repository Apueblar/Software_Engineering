

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * The test class MathTest.
 *
 * @author  (your name)
 * @version (a version number or a date)
 */
public class MathTest
{
    /**
     * Default constructor for test class MathTest
     */
    public MathTest()
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
    
    @Test
    public void isPalindromeTest()
    {
        Math dummy = new Math();
        assertEquals(true, dummy.isPalindrome("Never odd or even"));
        assertEquals(false, dummy.isPalindrome("Once upon a time"));
    }
    
    @Test
    public void PrimeTest()
    {
        Math dummy = new Math();
        assertEquals("[2, 3, 5, 7, 11, 13]", dummy.getPrimeUnder(15).toString());
        assertEquals("[2, 3, 5, 7]", dummy.getPrimeUnder(9).toString());
        
        try
        {
            dummy.getPrimeUnder(1);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(Math.ERR_MAX_VALUE ,e.getMessage());
        }
        
        try
        {
            dummy.getPrimeUnder(-1000000);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(Math.ERR_MAX_VALUE ,e.getMessage());
        }
    }
    
    @Test
    public void sortIntArrayTest()
    {
        Math dummy = new Math();
        int [] input  = {4,5,2,3,1};
        int [] output = {1,2,3,4,5};
        assertArrayEquals(output, dummy.sortIntArray(input));
        
        
    }
}
