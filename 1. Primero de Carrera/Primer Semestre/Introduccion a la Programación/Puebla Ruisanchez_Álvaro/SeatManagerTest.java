import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * The test class SeatManagerTest.
 *
 * @author  (your name)
 * @version (a version number or a date)
 */
public class SeatManagerTest
{
    /**
     * Default constructor for test class SeatManagerTest
     */
    public SeatManagerTest()
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
    public void numberOfAloneChildrenTest(){
        SeatManager dummy = new SeatManager(5,5);
        assertEquals(0, dummy.numberOfAloneChildren());
        
        dummy.bookSeat(new Person(17), 0, 0);
        assertEquals(1, dummy.numberOfAloneChildren());
        
        dummy.bookSeat(new Person(17), 0, 1);
        assertEquals(2, dummy.numberOfAloneChildren());
        
        dummy.bookSeat(new Person(100), 0, 2);
        assertEquals(1, dummy.numberOfAloneChildren());
        
        dummy.bookSeat(new Person(17), 0, 3);
        assertEquals(1, dummy.numberOfAloneChildren());
        
        dummy.bookSeat(new Person(17), 0, 5);
        assertEquals(2, dummy.numberOfAloneChildren());
        
        dummy.bookSeat(new Person(17), 1, 4);
        assertEquals(3, dummy.numberOfAloneChildren());
    }
    
    @Test
    public void bookSeatTest(){
        SeatManager dummy = new SeatManager(5,5);
        ArrayList<Person> list = new ArrayList<Person>();
        
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        assertEquals(5, dummy.bookSeat(list));
        
        list = new ArrayList<Person>();
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        assertEquals(10, dummy.bookSeat(list));
        
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        list.add(new Person());
        // Aprox, 60 people
        // Only 45 can enter
        assertEquals(45, dummy.bookSeat(list));
        
        list = new ArrayList<Person>();
        try{
            dummy.bookSeat(list);
            fail();
        }catch(Exception e){
            assertEquals(SeatManager.INVALID_LIST, e.getMessage());
        }
        
        list.add(null);
        try{
            dummy.bookSeat(list);
            fail();
        }catch(Exception e){
            assertEquals(SeatManager.INVALID_LIST, e.getMessage());
        }
    }
    
    @Test
    public void getPassengersByAgeTest(){
        SeatManager dummy = new SeatManager(5,5);
        
        dummy.bookSeat(new Person(17), 0, 0);
        dummy.bookSeat(new Person(17), 0, 1);
        dummy.bookSeat(new Person(17), 0, 2);
        dummy.bookSeat(new Person(17), 0, 3);
        dummy.bookSeat(new Person(17), 1, 0);
        
        dummy.bookSeat(new Person(20), 2, 0);
        dummy.bookSeat(new Person(20), 3, 0);
        dummy.bookSeat(new Person(20), 4, 0);
        dummy.bookSeat(new Person(21), 5, 0);
        
        assertEquals(5, dummy.getPassengersByAge()[17].size());
        assertEquals(3, dummy.getPassengersByAge()[20].size());
        assertEquals(1, dummy.getPassengersByAge()[21].size());
        
        assertEquals(0, dummy.getPassengersByAge()[80].size());
        assertEquals(0, dummy.getPassengersByAge()[119].size());
        assertEquals(0, dummy.getPassengersByAge()[0].size());
        
    }
}
