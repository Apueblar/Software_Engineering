import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.runners.MethodSorters;
import org.junit.FixMethodOrder;
@FixMethodOrder(MethodSorters.NAME_ASCENDING)

/**
 * The test class AirplaneTest.
 *
 * @author  Me Luigi
 * @version 13/10/2023
 */
public class AirplaneTest
{
    /**
     * Default constructor for test class AirplaneTest
     */
    public AirplaneTest()
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
    public void iD()
    {
        Airplane dummy = new Airplane();
        
        // Dar un ID
        dummy.setID('a');
        assertEquals(dummy.getID(), 'a');
        
        dummy.setID('$');
        assertEquals(dummy.getID(), '$');
    }
    
    @Test
    public void fuel()
    {
        Airplane dummy = new Airplane();
        
        dummy.setFuel(1000.01);
        assertEquals(dummy.getFuel(), 1000, 0.01);
        
        dummy.setFuel(0);
        assertEquals(dummy.getFuel(), 0, 0.01);
        
        try
        {
            dummy.setFuel(-1.25);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getFuel(), 0, 0.01);
            assertEquals(e.getMessage(), Airplane.ERR_NEG_FUEL);
        }
        
        try
        {
            dummy.setFuel(-1000.65);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getFuel(), 0, 0.01);
            assertEquals(e.getMessage(), Airplane.ERR_NEG_FUEL);
        }
    }
    
    @Test
    public void altitude()
    {
        Airplane dummy = new Airplane();
        
        dummy.setAltitude(1000);
        assertEquals(dummy.getAltitude(), 1000);
        
        dummy.setAltitude(0);
        assertEquals(dummy.getAltitude(), 0);
        
        try
        {
            dummy.setAltitude(-1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getAltitude(), 0);
            assertEquals(e.getMessage(), Airplane.ERR_NEG_ALTITUDE);
        }
        
        try
        {
            dummy.setAltitude(-1000);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getAltitude(), 0);
            assertEquals(e.getMessage(), Airplane.ERR_NEG_ALTITUDE);
        }
    }
    
    @Test
    public void testXPos()
    {
        Airplane dummy = new Airplane();
        
        dummy.setXPos(Airplane.X_WEST_BORDER);
        assertEquals(dummy.getXPos(), Airplane.X_WEST_BORDER);
        
        dummy.setXPos(Airplane.X_EAST_BORDER);
        assertEquals(dummy.getXPos(), Airplane.X_EAST_BORDER);
        
        dummy.setXPos(Airplane.X_EAST_BORDER / 2);
        assertEquals(dummy.getXPos(), Airplane.X_EAST_BORDER / 2);
        
        dummy.setXPos(Airplane.X_WEST_BORDER);
        try
        {
            dummy.setXPos(Airplane.X_WEST_BORDER - 1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getXPos(), Airplane.X_WEST_BORDER);
            assertEquals(e.getMessage(), Airplane.ERR_XPOS);
        }
        
        try
        {
            dummy.setXPos(Airplane.X_WEST_BORDER - 10000);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getXPos(), Airplane.X_WEST_BORDER);
            assertEquals(e.getMessage(), Airplane.ERR_XPOS);
        }
        
        try
        {
            dummy.setXPos(Airplane.X_EAST_BORDER + 1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getXPos(), Airplane.X_WEST_BORDER);
            assertEquals(e.getMessage(), Airplane.ERR_XPOS);
        }
        
        try
        {
            dummy.setXPos(Airplane.X_EAST_BORDER + 10000);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getXPos(), Airplane.X_WEST_BORDER);
            assertEquals(e.getMessage(), Airplane.ERR_XPOS);
        }
    }
    
    @Test
    public void testYPos()
    {
        Airplane dummy = new Airplane();
        
        dummy.setYPos(Airplane.Y_NORTH_BORDER);
        assertEquals(dummy.getYPos(), Airplane.Y_NORTH_BORDER);
        
        dummy.setYPos(Airplane.Y_SOUTH_BORDER);
        assertEquals(dummy.getYPos(), Airplane.Y_SOUTH_BORDER);
        
        dummy.setYPos(Airplane.Y_SOUTH_BORDER / 2);
        assertEquals(dummy.getYPos(), Airplane.Y_SOUTH_BORDER / 2);
        
        dummy.setYPos(Airplane.Y_NORTH_BORDER);
        try
        {
            dummy.setYPos(Airplane.Y_NORTH_BORDER - 1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getYPos(), Airplane.Y_NORTH_BORDER);
            assertEquals(e.getMessage(), Airplane.ERR_YPOS);
        }
        
        try
        {
            dummy.setYPos(Airplane.Y_NORTH_BORDER - 10000);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getYPos(), Airplane.Y_NORTH_BORDER);
            assertEquals(e.getMessage(), Airplane.ERR_YPOS);
        }
        
        try
        {
            dummy.setYPos(Airplane.Y_SOUTH_BORDER + 1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getYPos(), Airplane.Y_NORTH_BORDER);
            assertEquals(e.getMessage(), Airplane.ERR_YPOS);
        }
        
        try
        {
            dummy.setYPos(Airplane.Y_SOUTH_BORDER + 10000);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getYPos(), Airplane.Y_NORTH_BORDER);
            assertEquals(e.getMessage(), Airplane.ERR_YPOS);
        }
    }
    
    @Test
    public void testXSpeed()
    {
        Airplane dummy = new Airplane();
        
        dummy.setXSpeed(-1);
        assertEquals(dummy.getXSpeed(), -1);
        
        dummy.setXSpeed(0);
        assertEquals(dummy.getXSpeed(), 0);
        
        dummy.setXSpeed(1);
        assertEquals(dummy.getXSpeed(), 1);
        
        dummy.setXSpeed(0);
        try
        {
            dummy.setXSpeed(-2);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getXSpeed(), 0);
            assertEquals(e.getMessage(), Airplane.ERR_XSPEED);
        }
        
        try
        {
            dummy.setXSpeed(-100);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getXSpeed(), 0);
            assertEquals(e.getMessage(), Airplane.ERR_XSPEED);
        }
        
        try
        {
            dummy.setXSpeed(2);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getXSpeed(), 0);
            assertEquals(e.getMessage(), Airplane.ERR_XSPEED);
        }
        
        try
        {
            dummy.setXSpeed(100);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getXSpeed(), 0);
            assertEquals(e.getMessage(), Airplane.ERR_XSPEED);
        }
    }
    
    @Test
    public void testYSpeed()
    {
        Airplane dummy = new Airplane();
        
        dummy.setYSpeed(-1);
        assertEquals(dummy.getYSpeed(), -1);
        
        dummy.setYSpeed(0);
        assertEquals(dummy.getYSpeed(), 0);
        
        dummy.setYSpeed(1);
        assertEquals(dummy.getYSpeed(), 1);
        
        dummy.setYSpeed(0);
        try
        {
            dummy.setYSpeed(-2);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getYSpeed(), 0);
            assertEquals(e.getMessage(), Airplane.ERR_YSPEED);
        }
        
        try
        {
            dummy.setYSpeed(-100);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getYSpeed(), 0);
            assertEquals(e.getMessage(), Airplane.ERR_YSPEED);
        }
        
        try
        {
            dummy.setYSpeed(2);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getYSpeed(), 0);
            assertEquals(e.getMessage(), Airplane.ERR_YSPEED);
        }
        
        try
        {
            dummy.setYSpeed(100);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy.getYSpeed(), 0);
            assertEquals(e.getMessage(), Airplane.ERR_YSPEED);
        }
    }
    
    @Test
    public void toStringFields()
    {
        Airplane dummy = new Airplane();
        
        dummy.setID('$');
        dummy.setFuel(123.5);
        dummy.setAltitude(458.9);
        dummy.setXPos(4);
        dummy.setYPos(8);
        dummy.setXSpeed(0);
        dummy.setYSpeed(-1);
        
        assertEquals(dummy.toString(),"ID: $ - Fuel: 123.5 - Altitude: 458.9 - Pos[4,8] - Speed[0,-1]");
    }
    
    @Test
    public void testReachColumn()
    {
        Airplane dummy = new Airplane();
         
        dummy.setXPos(Airplane.X_WEST_BORDER);
        dummy.setXSpeed(0);
        assertEquals(dummy.turnsRequiredToReachColumn(Airplane.X_WEST_BORDER),0);
        
        
        dummy.setXPos(Airplane.X_EAST_BORDER);
        assertEquals(dummy.turnsRequiredToReachColumn(Airplane.X_EAST_BORDER),0);
        
        
        dummy.setXPos(Airplane.X_EAST_BORDER - Airplane.X_WEST_BORDER);
        assertEquals(dummy.turnsRequiredToReachColumn(Airplane.X_EAST_BORDER - Airplane.X_WEST_BORDER),0);
        
        dummy.setXPos(Airplane.X_WEST_BORDER);
        dummy.setXSpeed(1);
        assertEquals(dummy.turnsRequiredToReachColumn(Airplane.X_WEST_BORDER + 1),1);
        
        dummy.setXPos(Airplane.X_EAST_BORDER);
        dummy.setXSpeed(-1);
        assertEquals(dummy.turnsRequiredToReachColumn(Airplane.X_EAST_BORDER - 1),1);
        
        dummy.setXPos(Airplane.X_WEST_BORDER);
        dummy.setXSpeed(1);
        assertEquals(dummy.turnsRequiredToReachColumn(Airplane.X_EAST_BORDER - Airplane.X_WEST_BORDER),Airplane.X_EAST_BORDER - Airplane.X_WEST_BORDER);
        
        dummy.setXPos(Airplane.X_EAST_BORDER);
        dummy.setXSpeed(-1);
        assertEquals(dummy.turnsRequiredToReachColumn(Airplane.X_WEST_BORDER),Airplane.X_EAST_BORDER - Airplane.X_WEST_BORDER);
        
        
        dummy.setXPos(Airplane.X_WEST_BORDER);
        dummy.setXSpeed(0);
        
        try
        {
            dummy.turnsRequiredToReachColumn(Airplane.X_WEST_BORDER + 1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), Airplane.ERR_IMP_REACH);
        }
        
        dummy.setXPos(Airplane.X_EAST_BORDER);
        try
        {
            dummy.turnsRequiredToReachColumn(Airplane.X_EAST_BORDER - 1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), Airplane.ERR_IMP_REACH);
        }
        
        dummy.setXPos(Airplane.X_WEST_BORDER + 1);
        dummy.setXSpeed(1);
        try
        {
            dummy.turnsRequiredToReachColumn(Airplane.X_WEST_BORDER);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), Airplane.ERR_IMP_REACH);
        }
        
        dummy.setXPos(Airplane.X_EAST_BORDER - 1);
        dummy.setXSpeed(-1);
        try
        {
            dummy.turnsRequiredToReachColumn(Airplane.X_EAST_BORDER);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), Airplane.ERR_IMP_REACH);
        }
        
        dummy.setXPos(Airplane.X_EAST_BORDER - Airplane.X_WEST_BORDER - 1);
        dummy.setXSpeed(-1);
        try
        {
            dummy.turnsRequiredToReachColumn(Airplane.X_EAST_BORDER);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), Airplane.ERR_IMP_REACH);
        }
        
        dummy.setXSpeed(1);
        try
        {
            dummy.turnsRequiredToReachColumn(Airplane.X_WEST_BORDER);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), Airplane.ERR_IMP_REACH);
        }
    }
}



























