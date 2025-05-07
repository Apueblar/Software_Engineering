import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * The test class WheelStrutTest.
 *
 * @author  Puebla
 * @version 11/11/1111
 */
public class WheelStrutTest
{
    /**
     * Default constructor for test class WheelStrutTest
     */
    public WheelStrutTest()
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
    public void isOperationalTest()
    {
        WheelStrut dummyStrut = new WheelStrut('N', Wheel.METRIC_WHEEL_SIZE);
        
        assertEquals(true,dummyStrut.isOperational());
        
        dummyStrut.getLeftWheel().setPressure((Wheel.METRIC_WHEEL_SIZE * Wheel.SAFETY_THRESHOLD));
        dummyStrut.getRightWheel().setPressure(Wheel.METRIC_WHEEL_SIZE);
        
        assertEquals(true,dummyStrut.isOperational());
        
        dummyStrut.getLeftWheel().setPressure(Wheel.METRIC_WHEEL_SIZE);
        dummyStrut.getRightWheel().setPressure((Wheel.METRIC_WHEEL_SIZE * Wheel.SAFETY_THRESHOLD));
        
        assertEquals(true,dummyStrut.isOperational());
        
        
        dummyStrut.getLeftWheel().setPressure(0);
        dummyStrut.getRightWheel().setPressure(Wheel.METRIC_WHEEL_SIZE);
        
        assertEquals(false,dummyStrut.isOperational());
        
        dummyStrut.getLeftWheel().setPressure(0);
        dummyStrut.getRightWheel().setPressure(0);
        
        assertEquals(false,dummyStrut.isOperational());
        
        dummyStrut.getLeftWheel().setPressure(Wheel.METRIC_WHEEL_SIZE);
        dummyStrut.getRightWheel().setPressure(0);
        
        assertEquals(false,dummyStrut.isOperational());
    }
    
    @Test
    public void isDeployedTest()
    {
        WheelStrut dummyStrut = new WheelStrut('N', 100);
        
        assertEquals(true,dummyStrut.isDeployed());
        
        dummyStrut.setDeployed(false);
        assertEquals(false,dummyStrut.isDeployed());
    }
    
    @Test
    public void toStringTest()
    {
        WheelStrut dummy = new WheelStrut('N', Wheel.METRIC_WHEEL_SIZE);
        
        assertEquals("ID: N - Deployed: true - Op: true [L: true][R: true]",dummy.toString());
        
        dummy.setDeployed(false);
        assertEquals("ID: N - Deployed: false - Op: true [L: true][R: true]",dummy.toString());
        
        dummy.setDeployed(true);
        dummy.getLeftWheel().setPressure(0);
        assertEquals("ID: N - Deployed: true - Op: false [L: false][R: true]",dummy.toString());
    
        dummy.getRightWheel().setPressure(0);
        assertEquals("ID: N - Deployed: true - Op: false [L: false][R: false]",dummy.toString());
    
        dummy.getLeftWheel().setPressure(Wheel.METRIC_WHEEL_SIZE);
        assertEquals("ID: N - Deployed: true - Op: false [L: true][R: false]",dummy.toString());
    
    }
}




























