import java.util.*;
/**
 * Model of a plane in an Air Controlles simulator.
 * 
 * @author Álvaro
 * @version 13/10/2023
 */
public class Airplane
{
    public final static int X_WEST_BORDER = 0;
    public final static int X_EAST_BORDER = 10;
    public final static int Y_NORTH_BORDER = 0;
    public final static int Y_SOUTH_BORDER = 10;
    
    public char ID;
    
    public double fuel;
    public final static String ERR_NEG_FUEL = "The fuel cannot be negative.";
    
    public double altitude;
    public final static String ERR_NEG_ALTITUDE = "The altitude cannot be negative.";
    
    public int xPos;
    public final static String ERR_XPOS = "The x position must be between " + X_WEST_BORDER + " and " + X_EAST_BORDER + ".";
    
    public int yPos;
    public final static String ERR_YPOS = "The y position must be between " + Y_NORTH_BORDER + " and " + Y_SOUTH_BORDER + ".";
    
    public int xSpeed;
    public final static String ERR_XSPEED = "The x speed must be -1, 0 or 1.";
    
    public int ySpeed;
    public final static String ERR_YSPEED = "The y speed must be -1, 0 or 1.";
    
    public final static String ERR_IMP_REACH = "It is imposible to reach that column";

    /**
     * Constructor for objects of class Airplane
     */
    public Airplane()
    {
        setID('X');
        
        Random coin = new Random();
        
        setFuel(coin.nextInt(1000000) * coin.nextDouble()); // Toneladas
        setAltitude(coin.nextInt(10000000) * coin.nextDouble());
        setXPos(coin.nextInt(X_EAST_BORDER + 1));
        setYPos(coin.nextInt(Y_SOUTH_BORDER + 1));
        setXSpeed(coin.nextInt(3) - 1);
        setYSpeed(coin.nextInt(3) - 1);
    }
    
    /**
     * Constructor for objects of class Airplane
     */
    public Airplane(char ID)
    {
        setID(ID);
    }
    
    /**
     * Constructor for objects of class Airplane
     */
    public Airplane(char ID, double fuel, double altitude, int xPos, int yPos, int xSpeed, int ySpeed)
    {
        setID(ID);
        setFuel(fuel);
        setAltitude(altitude);
        setXPos(xPos);
        setYPos(yPos);
        setXSpeed(xSpeed);
        setYSpeed(ySpeed);
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
     * Updates the value of the field fuel [0,+inf).
     * 
     * @param fuel New fuel for the fuel field (in tons).
     */
    public void setFuel(double fuel)
    {
        if(fuel >= 0){
            this.fuel = fuel;
        }else{
            throw new RuntimeException(ERR_NEG_FUEL);
        }
    }
    
    /**
     * Returns the current value of the fuel field.
     * 
     * @return Returns a double of the fuel in tons.
     */
    public double getFuel(){
        return this.fuel;
    }
    
    /**
     * Updates the value of the field altitude [0,+inf).
     * 
     * @param altitude New altitude for the altitude field in Km.
     */
    public void setAltitude(double altitude)
    {
        if(altitude >= 0){
            this.altitude = altitude;
        }else{
            throw new RuntimeException(ERR_NEG_ALTITUDE);
        }
    }
    
    /**
     * Returns the current value of the altitude field.
     * 
     * @return Returns a double of the altitude in Km.
     */
    public double getAltitude(){
        return this.altitude;
    }
    
    /**
     * Updates the value of the field xPos [X_WEST_BORDER,X_EAST_BORDER].
     * 
     * @param xPos New xPos for the xPos field.
     */
    public void setXPos(int xPos)
    {
        if(X_WEST_BORDER <= xPos  && xPos <= X_EAST_BORDER){
            this.xPos = xPos;
        }else{
            throw new RuntimeException(ERR_XPOS);
        }
    }
    
    /**
     * Returns the current value of the xPos field.
     * 
     * @return Returns a int of the xPos.
     */
    public int getXPos(){
        return this.xPos;
    }
    
    /**
     * Updates the value of the field yPos [Y_NORTH_BORDER,Y_SOUTH_BORDER].
     * 
     * @param yPos New yPos for the yPos field.
     */
    public void setYPos(int yPos)
    {
        if(Y_NORTH_BORDER <= yPos  && yPos <= Y_SOUTH_BORDER){
            this.yPos = yPos;
        }else{
            throw new RuntimeException(ERR_YPOS);
        }
    }
    
    /**
     * Returns the current value of the yPos field.
     * 
     * @return Returns a int of the yPos.
     */
    public int getYPos(){
        return this.yPos;
    }
    
    /**
     * Updates the value of the field xSpeed [-1,1].
     * 
     * @param xSpeed New xSpeed for the xSpeed field.
     */
    public void setXSpeed(int xSpeed)
    {
        if(-1 <= xSpeed && xSpeed <= 1){
            this.xSpeed = xSpeed;
        }else{
            throw new RuntimeException(ERR_XSPEED);
        }
    }
    
    /**
     * Returns the current value of the xSpeed field.
     * 
     * @return Returns a int of the xSpeed.
     */
    public int getXSpeed(){
        return this.xSpeed;
    }
    
    /**
     * Updates the value of the field ySpeed [-1,1].
     * 
     * @param ySpeed New ySpeed for the ySpeed field.
     */
    public void setYSpeed(int ySpeed)
    {
        if(-1 <= ySpeed && ySpeed <= 1){
            this.ySpeed = ySpeed;
        }else{
            throw new RuntimeException(ERR_YSPEED);
        }
    }
    
    /**
     * Returns the current value of the ySpeed field.
     * 
     * @return Returns a int of the ySpeed.
     */
    public int getYSpeed(){
        return this.ySpeed;
    }
    
    /**
     * Creates a string object containing the values of every field in the class.
     * 
     * @return String included the ID, fuel, altitude, position and speed.
     */
    public String toString(){
        return 
        ("ID: " + getID() + 
        " - Fuel: " + getFuel() + 
        " - Altitude: " + getAltitude() + 
        " - Pos[" + getXPos() + "," + getYPos() + 
        "] - Speed[" + getXSpeed() + "," + getYSpeed() + "]");
    }
    
    /**
     * Display the values for all the fields in class on the computer's display.
     */
    public void print(){
        System.out.print("ID: " + getID());
        System.out.print(" - Fuel: " + String.format("%.2f",getFuel()));
        System.out.print(" - Altitude: " + String.format("%.2f",getAltitude()));
        System.out.print(" - Pos[" + getXPos() + "," + getYPos());
        System.out.println("] - Speed[" + getXSpeed() + "," + getXSpeed() + "]");
    }
    
    /**
     * Calculates the number of turns required to move the Airplane to a desired column.
     * 
     * @return An int number of the turns it takes to reach a column.
     */
    public int turnsRequiredToReachColumn (int desiredColumn){
        if(X_WEST_BORDER > desiredColumn || desiredColumn > X_EAST_BORDER ){
            throw new RuntimeException(ERR_IMP_REACH);
        }
        if (getXPos() == desiredColumn){
            return 0;
        }
        if (desiredColumn > getXPos() && getXSpeed() > 0){
            return desiredColumn - getXPos();
        }
        if (desiredColumn < getXPos() && getXSpeed() < 0){
            return getXPos() - desiredColumn;
        }
        throw new RuntimeException(ERR_IMP_REACH);
    }
    
    /**
     * The plane flies if it has fuel and if it is not touching the borders.
     * 
     * @return True if it is flying. False if it has no fuel.
     */
    public boolean fly()
    {
        if (getFuel() < 1.0){return false;}
        setFuel(getFuel() - 1);
        
        try{
            setXPos(getXPos() + getXSpeed());
        }catch (Exception e){}
        
        try{
            setYPos(getYPos() + getYSpeed());
        }catch (Exception e){}
        return true;
    }
}



























