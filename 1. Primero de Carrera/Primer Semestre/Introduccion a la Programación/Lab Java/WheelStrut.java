import java.util.*;

/**
 * Write a description of class WheelStrut here.
 * 
 * @author Álvaro
 * @version 27/10/2023
 */
public class WheelStrut
{
    private char ID;
    private ArrayList<Wheel> wheels;
    private boolean deployed;
    public final static String ERR_NUM_WHEELS_0 = "The number of wheels is lower than 1";

    /**
     * Constructor for objects of class WheelStrut
     */
    public WheelStrut(char ID, double wheelSize, int numberOfWheels)
    {
        if (numberOfWheels < 1){
            throw new RuntimeException(ERR_NUM_WHEELS_0);
        }
        setID(ID);
        
        wheels = new ArrayList<Wheel>(numberOfWheels);
        for(int i = 0; i < numberOfWheels; i++){
            wheels.add(new Wheel(wheelSize, wheelSize));
        }
        
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
        for(Wheel item : wheels){
            if (!item.isOperational()){
                return false;
            }
        }
        return true;
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
        String aux = ("ID: " + getID() + " - Deployed: " + isDeployed() + " - Op: " + isOperational() + " ");
        for(int i = 0; i < wheels.size(); i++){
            aux += "[" + i + ": " + wheels.get(i).isOperational() + "]";
        }
        
        return aux;
    }
    
    /**
     * Display the values for all the fields in class on the computer's display.
     */
    public void print(){
        System.out.println(toString());
        for(int i = 0; i < wheels.size(); i++){
            System.out.println(i + ": " + wheels.get(i).toString());
        }
    }
    
    /**
     * Delegates to the Wheels the comand activateHardLandingConfiguration()
     */
    protected void activateHardLandingConfiguration()
    {
        setDeployed(true);
        for(int i = 0; i < wheels.size(); i++){
            wheels.get(i).activateHardLandingConfiguration();
        }
    }
    
    /**
     * Asks every wheel if they are operational and later counts all the operational wheels.
     * 
     * @return The number of wheels that are operational on the plane.
     */
    public int numberOfOperationalWheels()
    {
        int numberOfOperationalWheels = 0;
        for(int i = 0; i < wheels.size(); i++){
            if (wheels.get(i).isOperational()){
                numberOfOperationalWheels += 1;
            }
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
        for(int i = 0; i < wheels.size(); i++){
            wheels.get(i).adjustPressure(percentage);
        }
    }
    
    // FOR TESTING:
    protected Wheel getWheel(int id)
    {
        return wheels.get(id);
    }
}