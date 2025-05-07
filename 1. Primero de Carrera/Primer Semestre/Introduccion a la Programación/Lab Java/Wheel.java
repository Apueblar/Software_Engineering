/**
 * Write a description of class Wheel here.
 * 
 * @author Álvaro
 * @version 27/10/2023
 */
public class Wheel
{
    // instance variables - replace the example below with your own
    public final static double B737_WHEEL_SIZE = 20.7;
    public final static double METRIC_WHEEL_SIZE = 100.0;
    
    public final static String ERR_NEGATIVE_SIZE = "The size cannot be negative.";
    
    public final static String ERR_NEGATIVE_PRESSURE = "The pressure cannot be negative.";
    public final static String ERR_OVER_PRESSURE = "The pressure cannot be higher than the size of the wheel.";
    
    public final static double SAFETY_THRESHOLD = 0.85; //85%
    
    private double size;
    
    public double pressure;
    
    /**
     * Constructor for objects of class Wheel
     */
    public Wheel(double size)
    {
        if (size < 0){
            throw new RuntimeException(ERR_NEGATIVE_SIZE);
        }
        this.size = size;
    }
    
    /**
     * Constructor for objects of class Wheel
     */
    public Wheel(double size, double pressure)
    {
        this(size);
        setPressure(pressure);
    }
    
    /**
     * Sets the size in the range[0, +inf].
     * 
     * @return double of the size of the wheel.
     */
    public double getSize()
    {
        return size;
    }
    
    /**
     * Sets the pressure in the range[0, size].
     * 
     * @pressure  The actual pressure of the wheel.
     */
    public void setPressure(double pressure)
    {
        if (pressure < 0){
            throw new RuntimeException(ERR_NEGATIVE_PRESSURE);
        }
        if (pressure > size){
            throw new RuntimeException(ERR_OVER_PRESSURE);
        }
        this.pressure = pressure;
    }
    
    /**
     * Gets the pressure.
     * 
     * @return double of the pressure.
     */
    public double getPressure()
    {
        return pressure;
    }
    
    /**
     * Gets the operational ratio.
     * Is used on isOperational().
     * Is used on toString().
     * 
     * @return double of the operational ratio [0,1].
     */
    private double getOperationalRatio()
    {
        return getPressure() / getSize();
    }
    
    /**
     * Checks if the tire is pressured enough.
     * 
     * @return true if its operational. Otherwise, false.
     */
    public boolean isOperational()
    {
        return getOperationalRatio() >= SAFETY_THRESHOLD;
    }
    
    /**
     * Creates a string object containing the values of every field in the class.
     * 
     * @return String included the .
     */
    public String toString(){
        return 
        ("Size: " + String.format("%.2f",getSize()) + 
        " bars - Pressure: " + String.format("%.2f",getPressure()) + 
        " bars - Ratio: " + String.format("%.2f",getOperationalRatio()) + 
        " - Op: " + isOperational());
    }
    
    /**
     * Display the values for all the fields in class on the computer's display.
     */
    public void print(){
        System.out.println(toString());
    }
    
    /**
     * It sets the pressure to the size of the wheel * 0.75
     */
    public void activateHardLandingConfiguration()
    {
        setPressure(0.75 * getSize());
    }
    
    /**
     * It adjust the pressure of the wheel by increasing or decreasing the current pressure by a proportion that is introduced.
     * 
     * @param percentage The percentage between -100 and 100 to increase or decrease the pressure.
     */
    protected void adjustPressure(double percentage)
    {
        double press = getPressure() * (1 + percentage / 100);
        if (press >= getSize()){
            setPressure(getSize());
        }else{
            setPressure(press);
        }
    }
}