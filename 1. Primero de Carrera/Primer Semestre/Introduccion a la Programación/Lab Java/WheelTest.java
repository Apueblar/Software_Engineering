import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * The test class WheelTest.
 *
 * @author  Me Peach
 * @version A long time ago
 */
public class WheelTest
{
    /**
     * Default constructor for test class WheelTest
     */
    public WheelTest()
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
    public void positiveConstructor()
    {
        Wheel dummy = new Wheel(0);
        assertEquals(0.0, dummy.getSize(), 0.01);
        
        dummy = new Wheel(Wheel.B737_WHEEL_SIZE);
        assertEquals(Wheel.B737_WHEEL_SIZE, dummy.getSize(), 0.01);
        
        dummy = new Wheel(Wheel.B737_WHEEL_SIZE / 2);
        assertEquals(Wheel.B737_WHEEL_SIZE / 2, dummy.getSize(), 0.01);
    }
    
    @Test
    public void negativeConstructor()
    {
        Wheel dummy = null;
        try{
            dummy = new Wheel(-0.01);
            fail();
        }
        catch (Exception e)
        {
            dummy = null;
            assertEquals(e.getMessage(), Wheel.ERR_NEGATIVE_SIZE);
        }
        
        try{
            dummy = new Wheel(-Wheel.B737_WHEEL_SIZE);
            fail();
        }
        catch (Exception e)
        {
            dummy = null;
            assertEquals(e.getMessage(), Wheel.ERR_NEGATIVE_SIZE);
        }
    }
    
    @Test
    public void setPressurePositive()
    {
        Wheel dummy = new Wheel(Wheel.B737_WHEEL_SIZE);
        
        assertEquals(0, dummy.getPressure(), 0.01);
        
        dummy.setPressure(Wheel.B737_WHEEL_SIZE / 2);
        assertEquals(Wheel.B737_WHEEL_SIZE / 2, dummy.getPressure(), 0.01);
        
        dummy.setPressure(Wheel.B737_WHEEL_SIZE);
        assertEquals(Wheel.B737_WHEEL_SIZE, dummy.getPressure(), 0.01);
    }    
    
    @Test
    public void setPressureNegative()
    {
        Wheel dummy = new Wheel(Wheel.B737_WHEEL_SIZE);
        dummy.setPressure(0);
        try{
            dummy.setPressure(-0.01);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(0,dummy.getPressure());
            assertEquals(e.getMessage(), Wheel.ERR_NEGATIVE_PRESSURE);
        }
        
        try{
            dummy.setPressure(Wheel.B737_WHEEL_SIZE + 1);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(0,dummy.getPressure());
            assertEquals(e.getMessage(), Wheel.ERR_OVER_PRESSURE);
        }
        
        try{
            dummy.setPressure(Wheel.B737_WHEEL_SIZE * 2);
            fail();
        }
        catch (Exception e)
        {
            assertEquals(0,dummy.getPressure());
            assertEquals(e.getMessage(), Wheel.ERR_OVER_PRESSURE);
        }
    }
    
    @Test
    public void isOperational()
    {
        Wheel dummy = new Wheel(Wheel.METRIC_WHEEL_SIZE);
        
        dummy.setPressure(0);
        assertEquals(false, dummy.isOperational());
        
        dummy.setPressure((Wheel.METRIC_WHEEL_SIZE * Wheel.SAFETY_THRESHOLD) / 2);
        assertEquals(false, dummy.isOperational());
        
        dummy.setPressure((Wheel.METRIC_WHEEL_SIZE * Wheel.SAFETY_THRESHOLD) - 0.01);
        assertEquals(false, dummy.isOperational());
        
        
        dummy.setPressure(Wheel.METRIC_WHEEL_SIZE * Wheel.SAFETY_THRESHOLD);
        assertEquals(true, dummy.isOperational());
        
        dummy.setPressure(90);
        assertEquals(true, dummy.isOperational());
        
        dummy.setPressure(100);
        assertEquals(true, dummy.isOperational());
    }
    
    @Test
    public void toStringTest()
    {
        Wheel dummy = new Wheel (20.7, 19.3);
        
        assertEquals ("Size: 20,70 bars - Pressure: 19,30 bars - Ratio: 0,93 - Op: true", dummy.toString());
        
        dummy.setPressure (2.3);
        assertEquals ("Size: 20,70 bars - Pressure: 2,30 bars - Ratio: 0,11 - Op: false", dummy.toString());
    }
}





































