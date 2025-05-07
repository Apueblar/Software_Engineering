/**
 * Write a description of class Test here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class Test
{
    /**
     * Constructor for objects of class Test
     */
    public Test()
    {
        
    }

    /**
     * Tests the getGender() method
     * 
     * @return If it passed the tests true. Otherwise false. 
     */
    private boolean testGender()
    {
        Person dummy = new Person();
        
        dummy.setGender(Person.MALE_VALUE);
        // Gender: MALE
        if (dummy.getGender() != Person.MALE_VALUE){
            System.out.println("T1 Gender: MALE FAILED");
            return false;
        }
        
        dummy.setGender(Person.FEMALE_VALUE);
        if (dummy.getGender() != Person.FEMALE_VALUE){
            System.out.println("T2 Gender: FEMALE FAILED");
            return false;
        }
        return true; // All test passed
        // && -> and - || -> or - ! -> not
    }
    
    /**
     * Tests the isABoy() method
     * 
     * @return If it passed the tests true. Otherwise false. 
     */
    private boolean testIsABoy()
    {
        Person dummy = new Person();
        
        dummy.setGender(Person.MALE_VALUE);
        // Gender: MALE
        if (!dummy.isABoy()){
            System.out.println("T1 IsABoy: MALE FAILED");
            return false;
        }
        
        // Gender: FEMALE
        dummy.setGender(Person.FEMALE_VALUE);
        if (dummy.isABoy()){
            System.out.println("T2 IsABoy: FEMALE FAILED");
            return false;
        }
        return true;
    }
    
    /**
     * Tests the isAGirl() method
     * 
     * @return If it passed the tests true. Otherwise false. 
     */
    private boolean testIsAGirl()
    {
        Person dummy = new Person();
        
        dummy.setGender(Person.MALE_VALUE);
        // Gender: MALE
        if (dummy.isAGirl()){
            System.out.println("T1 IsAGirl: MALE FAILED");
            return false;
        }
        
        // Gender: FEMALE
        dummy.setGender(Person.FEMALE_VALUE);
        if (!dummy.isAGirl()){
            System.out.println("T2 IsAGirl: FEMALE FAILED");
            return false;
        }
        return true;
    }
    
    
    public boolean testAll()
    {
      return testGender() && testIsABoy() && testIsAGirl();
    }
}
