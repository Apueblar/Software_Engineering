import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * The test class LandingGearTest.
 *
 * @author  Álvaro P.
 * @version La que tu quieras.
 */
public class LandingGearTest
{
    /**
     * Default constructor for test class LandingGearTest
     */
    public LandingGearTest()
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
    public void setLeverUp()
    {
        LandingGear dummy = new LandingGear();
        
        dummy.setLever(LandingGear.LEVER_UP);
        
        assertEquals(dummy.getNose().isDeployed(), false);
        assertEquals(dummy.getLeft().isDeployed(), false);
        assertEquals(dummy.getRight().isDeployed(), false);
        
        dummy.setLever(LandingGear.LEVER_DOWN);
        
        assertEquals(dummy.getNose().isDeployed(), true);
        assertEquals(dummy.getLeft().isDeployed(), true);
        assertEquals(dummy.getRight().isDeployed(), true);
    }
    
    @Test
    public void toStringTestLeverUp()
    {
        LandingGear dummy = new LandingGear();
        
        dummy.setLever(LandingGear.LEVER_UP);
        assertEquals("Lever: UP   Status: ON      Nose: OFF   Left: OFF   Right: OFF   ",dummy.toString());
        
        dummy.getNose().getLeftWheel().setPressure(0);
        assertEquals("Lever: UP   Status: FAILURE Nose: PRESS Left: OFF   Right: OFF   ",dummy.toString());
        
        dummy.getLeft().getLeftWheel().setPressure(0);
        assertEquals("Lever: UP   Status: FAILURE Nose: PRESS Left: PRESS Right: OFF   ",dummy.toString());
        
        dummy.getRight().getLeftWheel().setPressure(0);
        assertEquals("Lever: UP   Status: FAILURE Nose: PRESS Left: PRESS Right: PRESS ",dummy.toString());
        
        dummy.getNose().getLeftWheel().setPressure(100.0);
        assertEquals("Lever: UP   Status: FAILURE Nose: OFF   Left: PRESS Right: PRESS ",dummy.toString());
        
        dummy.getRight().getLeftWheel().setPressure(100.0);
        assertEquals("Lever: UP   Status: FAILURE Nose: OFF   Left: PRESS Right: OFF   ",dummy.toString());
        
        dummy.getNose().getLeftWheel().setPressure(0);
        dummy.getLeft().getLeftWheel().setPressure(100.0);
        dummy.getRight().getLeftWheel().setPressure(0);
        assertEquals("Lever: UP   Status: FAILURE Nose: PRESS Left: OFF   Right: PRESS ",dummy.toString());
        
        dummy.getNose().getLeftWheel().setPressure(100.0);
        assertEquals("Lever: UP   Status: FAILURE Nose: OFF   Left: OFF   Right: PRESS ",dummy.toString());
    }
    
    @Test
    public void toStringTestLeverDown()
    {
        LandingGear dummy = new LandingGear();
        
        dummy.setLever(LandingGear.LEVER_DOWN);
        assertEquals("Lever: DOWN Status: ON      Nose: ON    Left: ON    Right: ON    ",dummy.toString());
        
        dummy.getNose().getLeftWheel().setPressure(0);
        assertEquals("Lever: DOWN Status: FAILURE Nose: PRESS Left: ON    Right: ON    ",dummy.toString());
        
        dummy.getLeft().getLeftWheel().setPressure(0);
        assertEquals("Lever: DOWN Status: FAILURE Nose: PRESS Left: PRESS Right: ON    ",dummy.toString());
        
        dummy.getRight().getLeftWheel().setPressure(0);
        assertEquals("Lever: DOWN Status: FAILURE Nose: PRESS Left: PRESS Right: PRESS ",dummy.toString());
        
        dummy.getNose().getLeftWheel().setPressure(100.0);
        assertEquals("Lever: DOWN Status: FAILURE Nose: ON    Left: PRESS Right: PRESS ",dummy.toString());
        
        dummy.getRight().getLeftWheel().setPressure(100.0);
        assertEquals("Lever: DOWN Status: FAILURE Nose: ON    Left: PRESS Right: ON    ",dummy.toString());
        
        dummy.getNose().getLeftWheel().setPressure(0);
        dummy.getLeft().getLeftWheel().setPressure(100.0);
        dummy.getRight().getLeftWheel().setPressure(0);
        assertEquals("Lever: DOWN Status: FAILURE Nose: PRESS Left: ON    Right: PRESS ",dummy.toString());
        
        dummy.getNose().getLeftWheel().setPressure(100.0);
        assertEquals("Lever: DOWN Status: FAILURE Nose: ON    Left: ON    Right: PRESS ",dummy.toString());
    }
    
    @Test
    public void toStringTestLeverUpFail()
    {
        LandingGear dummy = new LandingGear();
        
        dummy.setLever(LandingGear.LEVER_UP);
        
        dummy.getNose().setDeployed(true);
        assertEquals("Lever: UP   Status: FAILURE Nose: ON    Left: OFF   Right: OFF   ",dummy.toString());
        
        dummy.getLeft().setDeployed(true);
        assertEquals("Lever: UP   Status: FAILURE Nose: ON    Left: ON    Right: OFF   ",dummy.toString());
        
        dummy.getRight().setDeployed(true);
        assertEquals("Lever: UP   Status: FAILURE Nose: ON    Left: ON    Right: ON    ",dummy.toString());
        
        dummy.getNose().setDeployed(false);
        assertEquals("Lever: UP   Status: FAILURE Nose: OFF   Left: ON    Right: ON    ",dummy.toString());
        
        dummy.getRight().setDeployed(false);
        assertEquals("Lever: UP   Status: FAILURE Nose: OFF   Left: ON    Right: OFF   ",dummy.toString());
        
        dummy.getNose().setDeployed(true);
        dummy.getLeft().setDeployed(false);
        dummy.getRight().setDeployed(true);
        assertEquals("Lever: UP   Status: FAILURE Nose: ON    Left: OFF   Right: ON    ",dummy.toString());
        
        dummy.getNose().setDeployed(false);
        assertEquals("Lever: UP   Status: FAILURE Nose: OFF   Left: OFF   Right: ON    ",dummy.toString());
    }
    
    @Test
    public void toStringTestLeverDownFail()
    {
        LandingGear dummy = new LandingGear();
        
        dummy.setLever(LandingGear.LEVER_DOWN);
        
        dummy.getNose().setDeployed(false);
        assertEquals("Lever: DOWN Status: FAILURE Nose: OFF   Left: ON    Right: ON    ",dummy.toString());
        
        dummy.getLeft().setDeployed(false);
        assertEquals("Lever: DOWN Status: FAILURE Nose: OFF   Left: OFF   Right: ON    ",dummy.toString());
        
        dummy.getRight().setDeployed(false);
        assertEquals("Lever: DOWN Status: FAILURE Nose: OFF   Left: OFF   Right: OFF   ",dummy.toString());
        
        dummy.getNose().setDeployed(true);
        assertEquals("Lever: DOWN Status: FAILURE Nose: ON    Left: OFF   Right: OFF   ",dummy.toString());
        
        dummy.getRight().setDeployed(true);
        assertEquals("Lever: DOWN Status: FAILURE Nose: ON    Left: OFF   Right: ON    ",dummy.toString());
        
        
        dummy.getNose().setDeployed(false);
        dummy.getLeft().setDeployed(true);
        dummy.getRight().setDeployed(false);
        assertEquals("Lever: DOWN Status: FAILURE Nose: OFF   Left: ON    Right: OFF   ",dummy.toString());
        
        dummy.getNose().setDeployed(true);
        assertEquals("Lever: DOWN Status: FAILURE Nose: ON    Left: ON    Right: OFF   ",dummy.toString());
    }
    
    @Test
    public void activateHardLandingConfigurationTest()
    {
        LandingGear dummy = new LandingGear();
        
        dummy.setLever(LandingGear.LEVER_UP);
        
        dummy.activateHardLandingConfiguration();
        
        assertEquals(dummy.getLever(),LandingGear.LEVER_UP);
        
        assertEquals(dummy.getNose().isDeployed(), true);
        assertEquals(dummy.getLeft().isDeployed(), true);
        assertEquals(dummy.getRight().isDeployed(), true);
        
        assertEquals(dummy.getNose().getLeftWheel().getPressure(), 75.0, 0.01);
        assertEquals(dummy.getNose().getRightWheel().getPressure(), 75.0, 0.01);
        
        assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 75.0, 0.01);
        assertEquals(dummy.getLeft().getRightWheel().getPressure(), 75.0, 0.01);
        
        assertEquals(dummy.getRight().getLeftWheel().getPressure(), 75.0, 0.01);
        assertEquals(dummy.getRight().getRightWheel().getPressure(), 75.0, 0.01);
    }
    
    @Test
    public void numberOfOperationalWheelsTest()
    {
        LandingGear dummy = new LandingGear();
        
        assertEquals(dummy.numberOfOperationalWheels(), 6);
        
        // Wheels start to explote 1 by 1
        dummy.getNose().getLeftWheel().setPressure(0);
        assertEquals(dummy.numberOfOperationalWheels(), 5);
        
        dummy.getNose().getRightWheel().setPressure(0);
        assertEquals(dummy.numberOfOperationalWheels(), 4);
        
        dummy.getLeft().getLeftWheel().setPressure(0);
        assertEquals(dummy.numberOfOperationalWheels(), 3);
        
        dummy.getLeft().getRightWheel().setPressure(0);
        assertEquals(dummy.numberOfOperationalWheels(), 2);
        
        dummy.getRight().getLeftWheel().setPressure(0);
        assertEquals(dummy.numberOfOperationalWheels(), 1);
        
        dummy.getRight().getRightWheel().setPressure(0);
        assertEquals(dummy.numberOfOperationalWheels(), 0);
        
        //We change 1 wheel
        dummy.getNose().getLeftWheel().setPressure(100.0);
        assertEquals(dummy.numberOfOperationalWheels(), 1);
    }
    
    @Test
    public void adjustPressurePosTest()
    {
        LandingGear dummy = new LandingGear();
        dummy.adjustPressure(0);
        assertEquals(dummy.getNose().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getNose().getRightWheel().getPressure(), 100);
        assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getLeft().getRightWheel().getPressure(), 100);
        assertEquals(dummy.getRight().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getRight().getRightWheel().getPressure(), 100);
        
        dummy.adjustPressure(-50);
        assertEquals(dummy.getNose().getLeftWheel().getPressure(), 50);
        assertEquals(dummy.getNose().getRightWheel().getPressure(), 50);
        assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 50);
        assertEquals(dummy.getLeft().getRightWheel().getPressure(), 50);
        assertEquals(dummy.getRight().getLeftWheel().getPressure(), 50);
        assertEquals(dummy.getRight().getRightWheel().getPressure(), 50);
        
        dummy.adjustPressure(100);
        assertEquals(dummy.getNose().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getNose().getRightWheel().getPressure(), 100);
        assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getLeft().getRightWheel().getPressure(), 100);
        assertEquals(dummy.getRight().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getRight().getRightWheel().getPressure(), 100);
        
        // Over the limit
        dummy.adjustPressure(50);
        assertEquals(dummy.getNose().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getNose().getRightWheel().getPressure(), 100);
        assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getLeft().getRightWheel().getPressure(), 100);
        assertEquals(dummy.getRight().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getRight().getRightWheel().getPressure(), 100);
        
        // Over the limit
        dummy.adjustPressure(100);
        assertEquals(dummy.getNose().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getNose().getRightWheel().getPressure(), 100);
        assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getLeft().getRightWheel().getPressure(), 100);
        assertEquals(dummy.getRight().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getRight().getRightWheel().getPressure(), 100);
        
        dummy.adjustPressure(-20);
        assertEquals(dummy.getNose().getLeftWheel().getPressure(), 80);
        assertEquals(dummy.getNose().getRightWheel().getPressure(), 80);
        assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 80);
        assertEquals(dummy.getLeft().getRightWheel().getPressure(), 80);
        assertEquals(dummy.getRight().getLeftWheel().getPressure(), 80);
        assertEquals(dummy.getRight().getRightWheel().getPressure(), 80);
        
        dummy.adjustPressure(-30);
        assertEquals(dummy.getNose().getLeftWheel().getPressure(), 56);
        assertEquals(dummy.getNose().getRightWheel().getPressure(), 56);
        assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 56);
        assertEquals(dummy.getLeft().getRightWheel().getPressure(), 56);
        assertEquals(dummy.getRight().getLeftWheel().getPressure(), 56);
        assertEquals(dummy.getRight().getRightWheel().getPressure(), 56);
        
        dummy.adjustPressure(-100);
        assertEquals(dummy.getNose().getLeftWheel().getPressure(), 0);
        assertEquals(dummy.getNose().getRightWheel().getPressure(), 0);
        assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 0);
        assertEquals(dummy.getLeft().getRightWheel().getPressure(), 0);
        assertEquals(dummy.getRight().getLeftWheel().getPressure(), 0);
        assertEquals(dummy.getRight().getRightWheel().getPressure(), 0);
    }
    
    @Test
    public void adjustPressureNegTest()
    {
        LandingGear dummy = new LandingGear();
        dummy.adjustPressure(0);
        assertEquals(dummy.getNose().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getNose().getRightWheel().getPressure(), 100);
        assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getLeft().getRightWheel().getPressure(), 100);
        assertEquals(dummy.getRight().getLeftWheel().getPressure(), 100);
        assertEquals(dummy.getRight().getRightWheel().getPressure(), 100);
        
        
        try
        {
            dummy.adjustPressure(-101); 
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getNose().getLeftWheel().getPressure(), 100);
            assertEquals(dummy.getNose().getRightWheel().getPressure(), 100);
            assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 100);
            assertEquals(dummy.getLeft().getRightWheel().getPressure(), 100);
            assertEquals(dummy.getRight().getLeftWheel().getPressure(), 100);
            assertEquals(dummy.getRight().getRightWheel().getPressure(), 100);
            assertEquals(e.getMessage(), LandingGear.NEGATIVE_PERCENTAGE);
        }
        
        try
        {
            dummy.adjustPressure(-100000); 
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getNose().getLeftWheel().getPressure(), 100);
            assertEquals(dummy.getNose().getRightWheel().getPressure(), 100);
            assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 100);
            assertEquals(dummy.getLeft().getRightWheel().getPressure(), 100);
            assertEquals(dummy.getRight().getLeftWheel().getPressure(), 100);
            assertEquals(dummy.getRight().getRightWheel().getPressure(), 100);
            assertEquals(e.getMessage(), LandingGear.NEGATIVE_PERCENTAGE);
        }
        
        try
        {
            dummy.adjustPressure(101); 
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getNose().getLeftWheel().getPressure(), 100);
            assertEquals(dummy.getNose().getRightWheel().getPressure(), 100);
            assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 100);
            assertEquals(dummy.getLeft().getRightWheel().getPressure(), 100);
            assertEquals(dummy.getRight().getLeftWheel().getPressure(), 100);
            assertEquals(dummy.getRight().getRightWheel().getPressure(), 100);
            assertEquals(e.getMessage(), LandingGear.OVER_PERCENTAGE);
        }
        
        try
        {
            dummy.adjustPressure(100000); 
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getNose().getLeftWheel().getPressure(), 100);
            assertEquals(dummy.getNose().getRightWheel().getPressure(), 100);
            assertEquals(dummy.getLeft().getLeftWheel().getPressure(), 100);
            assertEquals(dummy.getLeft().getRightWheel().getPressure(), 100);
            assertEquals(dummy.getRight().getLeftWheel().getPressure(), 100);
            assertEquals(dummy.getRight().getRightWheel().getPressure(), 100);
            assertEquals(e.getMessage(), LandingGear.OVER_PERCENTAGE);
        }
    }
}
































