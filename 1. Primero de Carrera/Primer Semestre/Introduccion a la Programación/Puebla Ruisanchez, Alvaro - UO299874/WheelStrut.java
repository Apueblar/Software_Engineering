/**
 * Write a description of class WheelStrut here.
 * 
 * @author Álvaro
 * @version 27/10/2023
 */
public class WheelStrut
{
    private char ID;
    private Wheel leftWheel;
    private Wheel rightWheel;
    private boolean deployed;

    /**
     * Constructor for objects of class WheelStrut
     */
    public WheelStrut(char ID, double wheelSize)
    {
        setID(ID);
        leftWheel = new Wheel(wheelSize, wheelSize);
        rightWheel = new Wheel(wheelSize, wheelSize);
        setDeployed(true);
    }
    
    /**
     * Updates the value of the field ID.
     * 
     * @param ID New ID for the ID field.
     */
    public void setID(char ID)
    {
        this.ID = ID;
    }
    
    /**
     * Returns the current value of the ID field.
     * 
     * @return Returns a char of the ID.
     */
    public char getID()
    {
        return this.ID;
    }
    
    /**
     * Shows if the wheels are operational
     * 
     * @return If it's operational or not.
     */
    public boolean isOperational()
    {
        return leftWheel.isOperational() && rightWheel.isOperational();
    }
        
    /**
     * Updates the value of the field ID.
     * 
     * @param ID New ID for the ID field.
     */
    public void setDeployed(boolean deployed)
    {
        this.deployed = deployed;
    }
    
    /**
     * Shows if it's deployed.
     * 
     * @return if it's deployed or not.
     */
    public boolean isDeployed()
    {
        return deployed;
    }
    
    /**
     * Creates a string object containing the values of every field in the class.
     * 
     * @return String included the ID, Deployed, Operational and the wheels.
     */
    public String toString(){
        return 
        ("ID: " + getID() + 
        " - Deployed: " + isDeployed() + 
        " - Op: " + isOperational() + 
        " [L: " + leftWheel.isOperational() + "][R: " + rightWheel.isOperational() + "]");
    }
    
    /**
     * Display the values for all the fields in class on the computer's display.
     */
    public void print(){
        System.out.println(toString());
        System.out.println("L: " + leftWheel.toString());
        System.out.println("R: " + rightWheel.toString());
    }
    
    /**
     * Delegates to the Wheels the comand activateHardLandingConfiguration()
     */
    protected void activateHardLandingConfiguration()
    {
        setDeployed(true);
        leftWheel.activateHardLandingConfiguration();
        rightWheel.activateHardLandingConfiguration();
    }
    
    /**
     * Asks every wheel if they are operational and later counts all the operational wheels.
     * 
     * @return The number of wheels that are operational on the plane.
     */
    public int numberOfOperationalWheels()
    {
        int numberOfOperationalWheels = 0;
        if (leftWheel.isOperational()){
            numberOfOperationalWheels += 1;
        }
        if (rightWheel.isOperational()){
            numberOfOperationalWheels += 1;
        }
        return numberOfOperationalWheels;
    }
    
    /**
     * Delegates to the Wheels the comand of adjustPressure(percentage).
     * 
     * @param percentage The percentage between -100 and 100 to increase or decrease the pressure of the wheels.
     */
    protected void adjustPressure(double percentage)
    {
        leftWheel.adjustPressure(percentage);
        rightWheel.adjustPressure(percentage);
    }
    
    // FOR TESTING:
    protected Wheel getLeftWheel()
    {
        return leftWheel;
    }
    
    protected Wheel getRightWheel()
    {
        return rightWheel;
    }
}