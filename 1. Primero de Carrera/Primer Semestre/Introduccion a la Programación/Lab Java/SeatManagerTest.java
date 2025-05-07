import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * The test class SeatManagerTest.
 *
 * @author  Álvaro
 * @version 06/11/2005
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
    public void negativeSizesTest()
    {
        SeatManager dummy = null;
        
        try
        {
            dummy = new SeatManager(0,1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy, null);
            assertEquals(e.getMessage(), SeatManager.NEGATIVE_FIRSTCLASS_ROWS); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy = new SeatManager(-100,1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy, null);
            assertEquals(e.getMessage(), SeatManager.NEGATIVE_FIRSTCLASS_ROWS); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy = new SeatManager(1,0);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy, null);
            assertEquals(e.getMessage(), SeatManager.NEGATIVE_STANDARTCLASS_ROWS); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy = new SeatManager(1,-100);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(dummy, null);
            assertEquals(e.getMessage(), SeatManager.NEGATIVE_STANDARTCLASS_ROWS); //Compara el menseje deseado con el del error
        }
    }
    
    @Test
    public void getSizeTest()
    {
        SeatManager dummy = new SeatManager(1,1);
        assertEquals(dummy.getSize(), 2*6);
        
        dummy = new SeatManager(5,10);
        assertEquals(dummy.getSize(), 15*6);
        
        dummy = new SeatManager(50,100);
        assertEquals(dummy.getSize(), 150*6);
        
        dummy = new SeatManager(100,100);
        assertEquals(dummy.getSize(), 200*6);
    }
    
    @Test
    public void getSizeFirstClassTest()
    {
        SeatManager dummy = new SeatManager(1,1);
        assertEquals(dummy.getSizeFirstClass(), 6);
        
        dummy = new SeatManager(5,10);
        assertEquals(dummy.getSizeFirstClass(), 5*6);
        
        dummy = new SeatManager(50,100);
        assertEquals(dummy.getSizeFirstClass(), 50*6);
        
        dummy = new SeatManager(100,100);
        assertEquals(dummy.getSizeFirstClass(), 100*6);
    }
    
    @Test
    public void getSizeStandardClassTest()
    {
        SeatManager dummy = new SeatManager(1,1);
        assertEquals(dummy.getSizeStandardClass(), 6);
        
        dummy = new SeatManager(5,10);
        assertEquals(dummy.getSizeStandardClass(), 10*6);
        
        dummy = new SeatManager(50,100);
        assertEquals(dummy.getSizeStandardClass(), 100*6);
        
        dummy = new SeatManager(100,100);
        assertEquals(dummy.getSizeStandardClass(), 100*6);
    }
    
    @Test
    public void positivevalidateCoordsTest()
    {
        SeatManager dummy = new SeatManager(5,10);
        dummy.validateCoords(0,0);
        dummy.validateCoords(14,SeatManager.WIDTH-1);
        
        dummy.validateCoords(14,0);
        dummy.validateCoords(0,SeatManager.WIDTH-1);
        
        dummy.validateCoords(6,SeatManager.WIDTH / 2);
    }
    
    @Test
    public void negativevalidateCoordsTest()
    {
        SeatManager dummy = new SeatManager(5,10);
        
        try
        {
            dummy.validateCoords(-1,0);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), SeatManager.NEGATIVE_ROW); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy.validateCoords(-100,0);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), SeatManager.NEGATIVE_ROW); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy.validateCoords(0,-1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), SeatManager.NEGATIVE_COLUMN); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy.validateCoords(0,-100);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), SeatManager.NEGATIVE_COLUMN); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy.validateCoords(15,0);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), SeatManager.ERR_HIGH_ROW); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy.validateCoords(150,0);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), SeatManager.ERR_HIGH_ROW); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy.validateCoords(0,SeatManager.WIDTH);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), SeatManager.ERR_HIGH_COLUMN); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy.validateCoords(0,SeatManager.WIDTH * 10);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            assertEquals(e.getMessage(), SeatManager.ERR_HIGH_COLUMN); //Compara el menseje deseado con el del error
        }
    }
    
    @Test
    public void bookSeatTest()
    {
        SeatManager dummy = new SeatManager(2,8);
        try
        {
            dummy.bookSeat(null, 0,0);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.ERR_PERSON);
        }
        
        dummy.bookSeat (new Person ("Neal", "Armstrong", 30, Person.MALE_VALUE), 3, 4);
        dummy.bookSeat (new Person (), 6, 2);
        dummy.bookSeat (new Person (), 0, 1);
        
        assertEquals (false, dummy.isReserved (0, 0));
        assertEquals (true, dummy.isReserved (0, 1));
        assertEquals (true, dummy.isReserved (3, 4));
        assertEquals (true, dummy.isReserved (6, 2));
        
        assertEquals ("[Name: Neal - Surname: Armstrong - Age: 30 - Gender: male]", dummy.getReservation (3, 4).toString());
        
        dummy.releaseSeat (3, 4);
        assertEquals (false, dummy.isReserved (3, 4));
        
        dummy.bookSeat (new Person ("Alvaro", "Puebla", 18, Person.MALE_VALUE), 3, 4);
        dummy.bookSeat (new Person (), 6, 2);
        dummy.bookSeat (new Person (), 0, 1);
        
        assertEquals (false, dummy.isReserved (0, 0));
        assertEquals (true, dummy.isReserved (0, 1));
        assertEquals (true, dummy.isReserved (3, 4));
        assertEquals (true, dummy.isReserved (6, 2));
        
        dummy.bookSeat (new Person (), 3, 4); //Another person tries to change my seat.
        assertEquals ("[Name: Alvaro - Surname: Puebla - Age: 18 - Gender: male]", dummy.getReservation (3, 4).toString());
        
        dummy.releaseSeat (3, 4);
        dummy.releaseSeat (6, 2);
        
        assertEquals (false, dummy.isReserved (3, 4));
        assertEquals (false, dummy.isReserved (6, 2));
    }
    
    @Test
    public void getNumPaxTest()
    {
        SeatManager dummy = new SeatManager(5,10);
        assertEquals (0, dummy.getNumPax());
        
        dummy.bookSeat (new Person (), 0, 0);
        assertEquals (1, dummy.getNumPax());
        
        dummy.bookSeat (new Person (), 1, 0);
        assertEquals (2, dummy.getNumPax());
        
        dummy.bookSeat (new Person (), 2, 0);
        assertEquals (3, dummy.getNumPax());
        
        dummy.bookSeat (new Person (), 3, 0);
        assertEquals (4, dummy.getNumPax());
        
        dummy.bookSeat (new Person (), 4, 5);
        assertEquals (5, dummy.getNumPax());
        
        dummy.bookSeat (new Person (), 0, 5);
        assertEquals (6, dummy.getNumPax());
        
        dummy.bookSeat (new Person (), 14, 5);
        assertEquals (7, dummy.getNumPax());
        
        dummy.releaseSeat (0, 0);
        assertEquals (6, dummy.getNumPax());
        
        dummy.releaseSeat(1, 0);
        assertEquals (5, dummy.getNumPax());
        
        dummy.releaseSeat (0, 0);
        assertEquals (5, dummy.getNumPax());
    }
    
    @Test
    public void basicSeatManagerTest()
    {
        SeatManager a = new SeatManager (2, 8);
        a.bookSeat(new Person ("Neal", "Armstrong", 25, Person.MALE_VALUE), 3, 4);
        a.bookSeat(new Person (), 6, 2);

        assertEquals (false, a.isReserved (0, 0));
        assertEquals (true, a.isReserved (3, 4));
        assertEquals (true, a.isReserved (6, 2));

        assertEquals ("[Name: Neal - Surname: Armstrong - Age: 25 - Gender: male]", a.getReservation (3, 4).toString());

        a.releaseSeat(3, 4);
        assertEquals (false, a.isReserved (3, 4));
        assertEquals (1, a.getNumPax());
        
        for (int k=0; k<SeatManager.WIDTH; k++)
            a.bookSeat(new Person(), 7, k);
            
        assertEquals (7, a.getNumPax()); 
    }
    
    @Test
    public void loadPaxPositiveTest()
    {
        SeatManager dummy = new SeatManager (2, 8);
        
        assertEquals (0, dummy.getNumPax());
        dummy.loadPax(10);
        
        assertEquals (10, dummy.getNumPax());
        dummy.loadPax(dummy.getSize() - dummy.getNumPax());
        
        assertEquals (dummy.getSize(), dummy.getNumPax());
    }
    
    @Test
    public void loadPaxNegativeTest()
    {
        SeatManager dummy = new SeatManager (2, 8);
        
        try
        {
            dummy.loadPax(-1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.NEG_PEOPLE);
        }
        
        try
        {
            dummy.loadPax(-1000);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.NEG_PEOPLE);
        }
        
        dummy.loadPax(10);
        
        try
        {
            dummy.loadPax(1 + dummy.getSize() - dummy.getNumPax());
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.ERR_CAPACITY);
        }
        
        try
        {
            dummy.loadPax(10000 + dummy.getSize() - dummy.getNumPax());
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.ERR_CAPACITY);
        }
    }
    
    @Test
    public void hackPrintManifest()
    {
        SeatManager dummy = new SeatManager (2, 8);
        
        dummy.loadPax(dummy.getSize());
        dummy.printManifest();
    }
    
    @Test
    public void hackPrint()
    {
        SeatManager dummy = new SeatManager (2, 8);
        
        dummy.loadPax(dummy.getSize());
        dummy.print();
    }
    
    @Test
    public void getYoungestAgeOnBoardTest()
    {
        SeatManager dummy = new SeatManager (2, 8);
        
        assertEquals(-1, dummy.getYoungestAgeOnBoard());
        
        dummy.bookSeat(new Person(40), 3, 4);
        assertEquals(40, dummy.getYoungestAgeOnBoard());
        
        dummy.bookSeat(new Person(50), 2, 3);
        assertEquals(40, dummy.getYoungestAgeOnBoard());
        
        dummy.bookSeat(new Person(1), 4, 4);
        assertEquals(1, dummy.getYoungestAgeOnBoard());
    }
    
    @Test
    public void getYoungestPeopleOnBoardTest()
    {
        SeatManager dummy= new SeatManager(2, 8);
        assertEquals(0, dummy.getYoungestPeopleOnBoard().size());
        
        Person yuri = new Person("Yuri", "Martinez", 16, Person.FEMALE_VALUE);
        dummy.bookSeat(yuri, 1, 1);
        assertEquals(1, dummy.getYoungestPeopleOnBoard().size());
        
        Person paco = new Person("Paco", "Rodriguez", 40, Person.MALE_VALUE);
        dummy.bookSeat(paco, 4, 2);
        assertEquals(1, dummy.getYoungestPeopleOnBoard().size());
        
        Person adrian = new Person("Adrian", "Fernandez", 16, Person.MALE_VALUE);
        dummy.bookSeat(adrian, 3, 3);
        assertEquals(2, dummy.getYoungestPeopleOnBoard().size());
        
        assertEquals(true, dummy.getYoungestPeopleOnBoard().contains(yuri));
        assertEquals(false, dummy.getYoungestPeopleOnBoard().contains(paco));
        assertEquals(true, dummy.getYoungestPeopleOnBoard().contains(adrian));
    }
    
    @Test
    public void getNumPaxAreaTest()
    {
        SeatManager dummy= new SeatManager(2, 8);
        
        dummy.bookSeat(new Person(), 0, 0);
        dummy.bookSeat(new Person(), 0, 1);
        dummy.bookSeat(new Person(), 0, 2);
        dummy.bookSeat(new Person(), 0, 3);
        dummy.bookSeat(new Person(), 1, 0);
        
        dummy.bookSeat(new Person(), 2, 0);
        dummy.bookSeat(new Person(), 6, 2);
        dummy.bookSeat(new Person(), 9, 5);
        
        assertEquals(5, dummy.getNumPax(SeatManager.FIRST_CLASS));
        assertEquals(3, dummy.getNumPax(SeatManager.STANDARD_CLASS));
        assertEquals(8, dummy.getNumPax(SeatManager.ALL_CLASSES));
        
        assertEquals(3, dummy.getNumPax(SeatManager.ALL_CLASSES, SeatManager.BOARD_WINDOW));
        assertEquals(2, dummy.getNumPax(SeatManager.FIRST_CLASS, SeatManager.BOARD_WINDOW));
        assertEquals(1, dummy.getNumPax(SeatManager.STANDARD_CLASS, SeatManager.BOARD_WINDOW));
        
        assertEquals(2, dummy.getNumPax(SeatManager.ALL_CLASSES, SeatManager.LEFT_AISLE));
        assertEquals(1, dummy.getNumPax(SeatManager.FIRST_CLASS, SeatManager.LEFT_AISLE));
        assertEquals(1, dummy.getNumPax(SeatManager.STANDARD_CLASS, SeatManager.LEFT_AISLE));
    
        assertEquals(1, dummy.getNumPax(SeatManager.ALL_CLASSES, SeatManager.RIGHT_AISLE));
        assertEquals(1, dummy.getNumPax(SeatManager.FIRST_CLASS, SeatManager.RIGHT_AISLE));
        assertEquals(0, dummy.getNumPax(SeatManager.STANDARD_CLASS, SeatManager.RIGHT_AISLE));
        
        assertEquals(1, dummy.getNumPax(SeatManager.ALL_CLASSES, SeatManager.STARBOARD_WINDOW));
        assertEquals(0, dummy.getNumPax(SeatManager.FIRST_CLASS, SeatManager.STARBOARD_WINDOW));
        assertEquals(1, dummy.getNumPax(SeatManager.STANDARD_CLASS, SeatManager.STARBOARD_WINDOW));
        
        assertEquals(4, dummy.getNumPax(SeatManager.ALL_CLASSES, SeatManager.BOTH_WINDOWS));
        assertEquals(2, dummy.getNumPax(SeatManager.FIRST_CLASS, SeatManager.BOTH_WINDOWS));
        assertEquals(2, dummy.getNumPax(SeatManager.STANDARD_CLASS, SeatManager.BOTH_WINDOWS));
        
        assertEquals(3, dummy.getNumPax(SeatManager.ALL_CLASSES, SeatManager.BOTH_AISLES));
        assertEquals(2, dummy.getNumPax(SeatManager.FIRST_CLASS, SeatManager.BOTH_AISLES));
        assertEquals(1, dummy.getNumPax(SeatManager.STANDARD_CLASS, SeatManager.BOTH_AISLES));
        
        assertEquals(8, dummy.getNumPax(SeatManager.ALL_CLASSES, SeatManager.EVERYWHERE));
        assertEquals(5, dummy.getNumPax(SeatManager.FIRST_CLASS, SeatManager.EVERYWHERE));
        assertEquals(3, dummy.getNumPax(SeatManager.STANDARD_CLASS, SeatManager.EVERYWHERE));
    }
    
    @Test
    public void countFirstClassElderyPaxTest()
    {
        SeatManager dummy= new SeatManager(2, 8);
        
        Person yuri = new Person("Yuri", "Martinez", 66, Person.FEMALE_VALUE);
        dummy.bookSeat(yuri, 1, 1);
        
        Person maria = new Person("Maria", "Casas", 65, Person.FEMALE_VALUE);
        dummy.bookSeat(maria, 1, 2);
        
        Person paco = new Person("Paco", "Rodriguez",100, Person.MALE_VALUE);
        dummy.bookSeat(paco, 0, 2);
        
        Person rodrigo = new Person("Rodrigo", "Sanchez",96, Person.MALE_VALUE);
        dummy.bookSeat(rodrigo, 0, 0);
        
        Person adrian = new Person("Adrian", "Fernandez", 16, Person.MALE_VALUE);
        dummy.bookSeat(adrian, 0, 1);
        
        assertEquals(1, dummy.countFirstClassElderyPax(Person.FEMALE_VALUE));
        assertEquals(2, dummy.countFirstClassElderyPax(Person.MALE_VALUE));
    }
    
    @Test
    public void interchangeSeatsTest()
    {
        SeatManager dummy= new SeatManager(2, 8);
        
        Person yuri = new Person("Yuri", "Martinez", 66, Person.FEMALE_VALUE);
        dummy.bookSeat(yuri, 1, 1);
        
        Person maria = new Person("Maria", "Casas", 65, Person.FEMALE_VALUE);
        dummy.bookSeat(maria, 1, 2);
        
        Person paco = new Person("Paco", "Rodriguez",100, Person.MALE_VALUE);
        dummy.bookSeat(paco, 0, 2);
        
        Person rodrigo = new Person("Rodrigo", "Sanchez",96, Person.MALE_VALUE);
        dummy.bookSeat(rodrigo, 0, 0);
        
        Person adrian = new Person("Adrian", "Fernandez", 16, Person.MALE_VALUE);
        dummy.bookSeat(adrian, 0, 1);
        
        dummy.interchangeSeats(0,1);
        assertEquals(yuri, dummy.getReservation(1, 0));
        assertEquals(adrian, dummy.getReservation(0, 0));
        assertEquals(rodrigo, dummy.getReservation(0, 1));
        
        try
        {
            dummy.interchangeSeats(-1,0);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.ERR_COL);
        }
        
        try
        {
            dummy.interchangeSeats(SeatManager.WIDTH + 1,0);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.ERR_COL);
        }
        
        try
        {
            dummy.interchangeSeats(-100,0);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.ERR_COL);
        }
        
        try
        {
            dummy.interchangeSeats(SeatManager.WIDTH * 100,0);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.ERR_COL);
        }
        
        try
        {
            dummy.interchangeSeats(0,SeatManager.WIDTH * 100);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.ERR_COL);
        }
        
        try
        {
            dummy.interchangeSeats(0,SeatManager.WIDTH + 1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.ERR_COL);
        }
        
        try
        {
            dummy.interchangeSeats(0,-1);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.ERR_COL);
        }
        
        try
        {
            dummy.interchangeSeats(0,-100);
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e){
            assertEquals(e.getMessage(), SeatManager.ERR_COL);
        }
    }
}

































