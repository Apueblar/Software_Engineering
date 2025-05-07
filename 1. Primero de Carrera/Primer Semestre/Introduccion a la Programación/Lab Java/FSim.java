import java.util.*;
/**
 * Write a description of class FSim here.
 * 
 * @author Me Wario
 * @version 1.0.0
 */
public class FSim
{
    // instance variables - replace the example below with your own
    private ArrayList<Airplane> planes;
    private char [][] map;
    
    public final static char TERRAIN_SYMBOL = '~'; // ALT + 126
    public final static char RADAR_VERTICAL_SYMBOL = '|';
    public final static char RADAR_HORIZONTAL_SYMBOL = '-';
    public final static char RADAR_DIAGONAL_LEFT_SYMBOL = '\\';
    public final static char RADAR_DIAGONAL_RIGTH_SYMBOL = '/';
    
    public final static String ERR_NEG_FRAMES = "The frames must be positive.";
    
    /**
     * Constructor for objects of class FSim
     */
    public FSim()
    {
        map = new char [1 + Airplane.Y_SOUTH_BORDER - Airplane.Y_NORTH_BORDER][1 + Airplane.X_EAST_BORDER - Airplane.X_WEST_BORDER];
        planes = new ArrayList<Airplane>();
    }

    /**
     * Adds the plane to the map
     * 
     * @param plane The plane that needs to be added
     */
    public void add(Airplane plane)
    {
        planes.add(plane);        
    }
    
    /**
     * Paints the background.
     */
    private void paintBackground()
    {
        System.out.println();
        for (int i = 0; i < map.length; i++){
            for (int j = 0; j < map[0].length; j++){
                map[i][j] = TERRAIN_SYMBOL;
                if (i == j){map[i][j] = RADAR_DIAGONAL_LEFT_SYMBOL;}
                if (j == map[0].length / 2){map[i][j] = RADAR_VERTICAL_SYMBOL;}
                if (i == map.length / 2){map[i][j] = RADAR_HORIZONTAL_SYMBOL;}
                if (map[0].length - i == j + 1){map[i][j] = RADAR_DIAGONAL_RIGTH_SYMBOL;}
            }
        }
    }
    
    /**
     * Paints the planes.
     */
    private void paintForeground()
    {
        for (Airplane plane : planes){
            map[plane.getYPos()][plane.getXPos()] = plane.getID();
        }
    }
    
    /**
     * Paints the map.
     */
    public void paint()
    {
        paintBackground();
        
        paintForeground();
        
        for (int i = 0; i < map.length; i++){
            for (int j = 0; j < map[0].length; j++){
                System.out.print(map[i][j]);
            }
            System.out.println();
        }
    }
    
    /**
     * Asks the planes to fly.
     */
    private void flyPlanes()
    {
        for (Airplane plane : planes){
            plane.fly();
        }
    }
    
    /**
     * Animates the map.
     */
    public void animate(int frames)
    {
        if(frames < 0){throw new RuntimeException(ERR_NEG_FRAMES);}
        
        for (int i = 0; i < frames; i--){
            System.out.println("*** FRAME: " + i + " ***");
            paint();
            System.out.println();
            flyPlanes();
        }
    }
}






























