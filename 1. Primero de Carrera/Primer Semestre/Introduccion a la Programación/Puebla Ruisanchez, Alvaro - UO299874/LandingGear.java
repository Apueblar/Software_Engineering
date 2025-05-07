/**
 * The pilot can access this class.
 * 
 * @author UO299874
 * @version 03/11/2023
 */
public class LandingGear
{
    // instance variables - replace the example below with your own
    private WheelStrut nose;
    private WheelStrut left;
    private WheelStrut right;
    public final static boolean LEVER_UP = false;
    public final static boolean LEVER_DOWN = true;
    private boolean lever;
    
    public final static String NEGATIVE_PERCENTAGE = "The percentage is lower than -100.";
    public final static String OVER_PERCENTAGE = "The percentage is higher than 100.";

    /**
     * Constructor for objects of class LandingGear
     */
    public LandingGear()
    {
        nose = new WheelStrut('N', 100.0);
        left = new WheelStrut('L', 100.0);
        right = new WheelStrut('R', 100.0);
        setLever(LEVER_DOWN);
    }

    /**
     * Returns the value of the lever.
     * 
     * @return The value of the lever.
     */
    public boolean getLever()
    {
        return lever;
    }
    
    /**
     * Updates the state of the lever.
     * 
     * @param lever Current state of the lever.
     */
    public void setLever(boolean lever)
    {
        this.lever = lever;
        if (lever == LEVER_DOWN){
            nose.setDeployed(true);
            left.setDeployed(true);
            right.setDeployed(true);
        }else{
            nose.setDeployed(false);
            left.setDeployed(false);
            right.setDeployed(false);
        }
    }
    
    /**
     * Checks that all the landing struts are in the correct place.
     * 
     * @return If one is not in the correct place, returns false. Otherwise is true.
     */
    private boolean isConsistent()
    {
        if (getLever() == LEVER_UP){
            return !nose.isDeployed() && !left.isDeployed() && !right.isDeployed();
        }
        return nose.isDeployed() && left.isDeployed() && right.isDeployed();      
    }
    
    /**
     * Checks that all the landing struts are operational.
     * 
     * @return If one is not operational, returns false. Otherwise is true.
     */
    private boolean isOperational()
    {
        return nose.isOperational() && left.isOperational() && right.isOperational();
    }
    
    /**
     * Creates a string object containing the values of every field in the class.
     * 
     * @return String included the Lever, Status and the wheel Struts.
     */
    public String toString()
    {
        String text = "Lever: ";
        if (getLever() == LEVER_UP){text += "UP   ";}
        else {text += "DOWN ";}
        
        text += "Status: ";
        if (isConsistent() && isOperational()){text += "ON      ";}
        else{text += "FAILURE ";}
        
        text += "Nose: ";
        if (!nose.isOperational()) {text += "PRESS ";}
        else{
            if (nose.isDeployed()){text += "ON    ";}
            else {text += "OFF   ";}
        }
        
        text += "Left: ";
        if (!left.isOperational()) {text += "PRESS ";}
        else{
            if (left.isDeployed()){text += "ON    ";}
            else {text += "OFF   ";}
        }
        
        text += "Right: ";
        if (!right.isOperational()) {text += "PRESS ";}
        else{
            if (right.isDeployed()){text += "ON    ";}
            else {text += "OFF   ";}
        }
        
        return text;
    }
    
    /**
     * Delegates to the WheelStruts the comand of activateHardLandingConfiguration().
     */
    public void activateHardLandingConfiguration()
    {
        nose.activateHardLandingConfiguration();
        left.activateHardLandingConfiguration();
        right.activateHardLandingConfiguration();
    }
    
    /**
     * Delegates to the WheelStruts the comand of numberOfOperationalWheels().
     * 
     * @return The number(int) of wheels that are operational on the plane.
     */
    public int numberOfOperationalWheels()
    {
        return (nose.numberOfOperationalWheels() + left.numberOfOperationalWheels() + right.numberOfOperationalWheels());
    }
    
    /**
     * Checks that the percentaje is between [-100,100]. 
     * If all correct: Delegates to the WheelStruts the comand of adjustPressure(percentage).
     * Error: It manages the errors.
     * @param percentage The percentage between -100 and 100 to increase or decrease the pressure of the wheels.
     */
    public void adjustPressure(double percentage)
    {
        if (percentage < -100){
            throw new RuntimeException(NEGATIVE_PERCENTAGE);
        }else if (percentage > 100){
            throw new RuntimeException(OVER_PERCENTAGE);
        }else{
            nose.adjustPressure(percentage);
            right.adjustPressure(percentage);
            left.adjustPressure(percentage);
        }
    }
    
    
    // For Testing
    /**
     * Returns the adress of the NoseWheelStrut.
     * 
     * @return Adress of the NoseWheelStrut.
     */
    public WheelStrut getNose()
    {
        return nose;
    }
    
    /**
     * Returns the adress of the LeftWheelStrut.
     * 
     * @return Adress of the LeftWheelStrut.
     */
    public WheelStrut getLeft()
    {
        return left;
    }
    
    /**
     * Returns the adress of the RightWheelStrut.
     * 
     * @return Adress of the RightWheelStrut.
     */
    public WheelStrut getRight()
    {
        return right;
    }
}