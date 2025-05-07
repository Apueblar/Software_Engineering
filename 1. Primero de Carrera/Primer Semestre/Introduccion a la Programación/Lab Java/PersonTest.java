
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.runners.MethodSorters;
import org.junit.FixMethodOrder;
@FixMethodOrder(MethodSorters.NAME_ASCENDING)

/**
 * The test class PersonTest.
 *
 * @author  Me Mario
 * @version 6/10
 */
public class PersonTest
{
    /**
     * Default constructor for test class PersonTest
     */
    public PersonTest()
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
    public void name()
    {
        Person dummy = new Person();
        
        // Dar un nombre
        dummy.setName("abcdefghijklmnopqrstuvwxyz");
        assertEquals(dummy.getName(), "abcdefghijklmnopqrstuvwxyz");
        
        dummy.setName("/@#~%$=!|");
        assertEquals(dummy.getName(), "/@#~%$=!|");
    }
    
    @Test
    public void surname()
    {
        Person dummy = new Person();
        
        // Dar un nombre
        dummy.setSurname("abcdefghijklmnopqrstuvwxyz");
        assertEquals(dummy.getSurname(), "abcdefghijklmnopqrstuvwxyz");
        
        dummy.setSurname("/@#~%$=!|");
        assertEquals(dummy.getSurname(), "/@#~%$=!|");
    }
    
    @Test
    public void gender()
    {
        Person dummy = new Person();
        
        // Gender: MALE
        dummy.setGender(Person.MALE_VALUE);
        assertEquals(dummy.getGender(), Person.MALE_VALUE);
        
        // Gender: FEMALE
        dummy.setGender(Person.FEMALE_VALUE);
        assertEquals(dummy.getGender(), Person.FEMALE_VALUE);
    }
    
    @Test
    public void isAGirl()
    {
        Person dummy = new Person();
        
        // Gender: MALE
        dummy.setGender(Person.MALE_VALUE);
        assertEquals(dummy.isAGirl(), false);
        
        // Gender: FEMALE
        dummy.setGender(Person.FEMALE_VALUE);
        assertEquals(dummy.isAGirl(), true);
    }
    
    @Test
    public void isABoy()
    {
        Person dummy = new Person();
        
        // Gender: MALE
        dummy.setGender(Person.MALE_VALUE);
        assertEquals(dummy.isABoy(), true);
        
        // Gender: FEMALE
        dummy.setGender(Person.FEMALE_VALUE);
        assertEquals(dummy.isABoy(), false);
    }
    
    @Test
    public void age()
    {
        Person dummy = new Person();
        
        //Positive Test
        dummy.setAge(0);
        assertEquals(dummy.getAge(), 0);
        
        dummy.setAge(Person.MAX_AGE_VALUE);
        assertEquals(dummy.getAge(), Person.MAX_AGE_VALUE);
        
        dummy.setAge(Person.MAX_AGE_VALUE/2);
        assertEquals(dummy.getAge(), Person.MAX_AGE_VALUE/2);
        
        //Negative Test
        dummy.setAge(0);
        
        try
        {
            dummy.setAge(-1); //Edad negativa
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            //Throws exceptions and check if its the correct one.
            assertEquals(dummy.getAge(), 0); //La edad no puede cambiar
            assertEquals(e.getMessage(), Person.ERR_NEGATIVE_AGE); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy.setAge(-4 * Person.MAX_AGE_VALUE); //Edad muy negativa
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            //Throws exceptions and check if its the correct one.
            assertEquals(dummy.getAge(), 0); //La edad no puede cambiar
            assertEquals(e.getMessage(), Person.ERR_NEGATIVE_AGE); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy.setAge(Person.MAX_AGE_VALUE + 1); //Edad por encima de la máxima
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            //Throws exceptions and check if its the correct one.
            assertEquals(dummy.getAge(), 0); //La edad no puede cambiar
            assertEquals(e.getMessage(), Person.ERR_HIGH_AGE); //Compara el menseje deseado con el del error
        }
        
        try
        {
            dummy.setAge(4 * Person.MAX_AGE_VALUE); //Edad muy por encima de la máxima.
            fail(); //Obliga a dar un error, si no falla()
        }
        catch (Exception e)
        {
            //Throws exceptions and check if its the correct one.
            assertEquals(dummy.getAge(), 0); //La edad no puede cambiar
            assertEquals(e.getMessage(), Person.ERR_HIGH_AGE); //Compara el menseje deseado con el del error
        }
    }
    
    @Test
    public void criticalAge()
    {
        Person dummy = new Person();
        
        dummy.setAge(0);
        assertEquals(dummy.getCriticalAge(), Person.ADULTHOOD_AGE);
        
        dummy.setAge(Person.ADULTHOOD_AGE - 1);
        assertEquals(dummy.getCriticalAge(), 1);
        
        dummy.setAge(Person.ADULTHOOD_AGE);
        assertEquals(dummy.getCriticalAge(), Person.RETIREMENT_AGE - Person.ADULTHOOD_AGE);
        
        dummy.setAge(Person.RETIREMENT_AGE - 1);
        assertEquals(dummy.getCriticalAge(), 1);
        
        dummy.setAge(Person.RETIREMENT_AGE + 1);
        assertEquals(dummy.getCriticalAge(), 1);
        
        dummy.setAge(Person.MAX_AGE_VALUE);
        assertEquals(dummy.getCriticalAge(), Person.MAX_AGE_VALUE - Person.RETIREMENT_AGE);
    }
    
    @Test
    public void toStringFields()
    {
        Person dummy = new Person();
        
        dummy.setName("Pedro");
        dummy.setSurname("Sanchez");
        dummy.setAge(19);
        dummy.setGender(Person.MALE_VALUE);
        
        assertEquals(dummy.toString(),"[Name: Pedro - Surname: Sanchez - Age: 19 - Gender: " + Person.MALE_TEXT + "]");
    }
    
    @Test
    public void tHashCode()
    {
        Person dummy = new Person();
        
        dummy.setName("Pedro");
        dummy.setSurname("Sanchez");
        dummy.setAge(19);
        dummy.setGender(Person.MALE_VALUE);
        
        assertEquals(dummy.getHashCode(),"PED-SAN-19-" + Person.MALE_VALUE);
    }
    
    @Test
    public void areYouAge()
    {
        Person dummy = new Person();
        
        dummy.setAge(Person.MAX_AGE_VALUE);
        assertEquals(dummy.areYou(Person.MAX_AGE_VALUE), true);
        assertEquals(dummy.areYou(Person.MAX_AGE_VALUE - 1), false);
        
        dummy.setAge(0);
        assertEquals(dummy.areYou(0), true);
        assertEquals(dummy.areYou(Person.MAX_AGE_VALUE), false);
    }
    
    @Test
    public void areYouName()
    {
        Person dummy = new Person();
        
        // Dar un nombre
        dummy.setName("abcdefghijklmnopqrstuvwxyz");
        assertEquals(dummy.areYou("abcdefghijklmnopqrstuvwxyz"), true);
        assertEquals(dummy.areYou("abCdeFghijKlmnopqrstUvwxyz"), true);
        assertEquals(dummy.areYou("Álvaro"), false);
        assertEquals(dummy.areYou("Peter"), false);
        
        dummy.setName("/@#~%$=!|");
        assertEquals(dummy.areYou("/@#~%$=!|"), true);
        assertEquals(dummy.areYou("Álvaro"), false);
        assertEquals(dummy.areYou("Peter"), false);
    }
    
    @Test
    public void areYouPerson()
    {
        Person a = new Person("Pablo","Rodriguez",17,Person.MALE_VALUE);
        Person b = new Person("Irene","Alvarez",18,Person.FEMALE_VALUE);
        
        /*
        a.setName("Pablo");
        a.setSurname("Rodriguez");
        a.setGender(Person.MALE_VALUE);
        a.setAge(17);
        
        b.setName("Irene");
        b.setSurname("Alvarez");
        b.setGender(Person.FEMALE_VALUE);
        b.setAge(18);
        */
        
        assertEquals(a.areYou(a), true);
        assertEquals(b.areYou(a), false);
        assertEquals(a.areYou(b), false);
        
        b.setName("Pablo");
        b.setSurname("Rodriguez");
        b.setGender(Person.MALE_VALUE);
        b.setAge(17);
        
        assertEquals(a.areYou(a), true);
        assertEquals(b.areYou(a), true);
        assertEquals(a.areYou(b), true);
    }
    
    @Test
    public void compareToAge()
    {
        Person a = new Person("Pablo","Rodriguez",18,Person.MALE_VALUE);
        Person b = new Person("Irene","Alvarez",18,Person.FEMALE_VALUE);
        
        assertEquals(a.compareTo(b), 0);
        assertEquals(b.compareTo(a), 0);
        
        a.setAge(17);
        assertEquals(a.compareTo(b), -1);
        assertEquals(b.compareTo(a), 1);
        
        a.setAge(19);
        assertEquals(a.compareTo(b), 1);
        assertEquals(b.compareTo(a), -1);
    }
}




























