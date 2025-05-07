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
        WheelStrut dummyStrut = new WheelStrut('N', Wheel.METRIC_WHEEL_SIZE, 2);
        
        assertEquals(true,dummyStrut.isOperational());
        
        dummyStrut.getWheel(0).setPressure((Wheel.METRIC_WHEEL_SIZE * Wheel.SAFETY_THRESHOLD));
        dummyStrut.getWheel(1).setPressure(Wheel.METRIC_WHEEL_SIZE);
        
        assertEquals(true,dummyStrut.isOperational());
        
        dummyStrut.getWheel(0).setPressure(Wheel.METRIC_WHEEL_SIZE);
        dummyStrut.getWheel(1).setPressure((Wheel.METRIC_WHEEL_SIZE * Wheel.SAFETY_THRESHOLD));
        
        assertEquals(true,dummyStrut.isOperational());
        
        
        dummyStrut.getWheel(0).setPressure(0);
        dummyStrut.getWheel(1).setPressure(Wheel.METRIC_WHEEL_SIZE);
        
        assertEquals(false,dummyStrut.isOperational());
        
        dummyStrut.getWheel(0).setPressure(0);
        dummyStrut.getWheel(1).setPressure(0);
        
        assertEquals(false,dummyStrut.isOperational());
        
        dummyStrut.getWheel(0).setPressure(Wheel.METRIC_WHEEL_SIZE);
        dummyStrut.getWheel(1).setPressure(0);
        
        assertEquals(false,dummyStrut.isOperational());
    }
    
    @Test
    public void isDeployedTest()
    {
        WheelStrut dummyStrut = new WheelStrut('N', 100, 2);
        
        assertEquals(true,dummyStrut.isDeployed());
        
        dummyStrut.setDeployed(false);
        assertEquals(false,dummyStrut.isDeployed());
    }
    
    @Test
    public void toStringTest()
    {
        WheelStrut dummy = new WheelStrut('N', Wheel.METRIC_WHEEL_SIZE, 2);
        
        assertEquals("ID: N - Deployed: true - Op: true [0: true][1: true]",dummy.toString());
        
        dummy.setDeployed(false);
        assertEquals("ID: N - Deployed: false - Op: true [0: true][1: true]",dummy.toString());
        
        dummy.setDeployed(true);
        dummy.getWheel(0).setPressure(0);
        assertEquals("ID: N - Deployed: true - Op: false [0: false][1: true]",dummy.toString());
    
        dummy.getWheel(1).setPressure(0);
        assertEquals("ID: N - Deployed: true - Op: false [0: false][1: false]",dummy.toString());
    
        dummy.getWheel(0).setPressure(Wheel.METRIC_WHEEL_SIZE);
        assertEquals("ID: N - Deployed: true - Op: false [0: true][1: false]",dummy.toString());
    
    }
}




























