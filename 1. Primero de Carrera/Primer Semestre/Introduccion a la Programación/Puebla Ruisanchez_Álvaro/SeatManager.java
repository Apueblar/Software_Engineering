import java.util.ArrayList;
import java.util.Iterator;
import java.util.Random;

/**
 * Gestiona los asientos del avión
 * 
 * @author ip-profes
 * @version 14-11-23
 */
public class SeatManager
{
    public static final int SEATS_PER_ROW = 6;     
    
    public static final int MIN_FIRST_ROWS = 3;
    public static final int MIN_STANDARD_ROWS = 4;
    
    public static final int MAX_FIRST_ROWS = 10;
    public static final int MAX_STANDARD_ROWS = 40;
    
    public static final String INVALID_LIST = "Invalid list";
    
    
   
    private Person[][] seats;
    private int firstRows;
    private int standardRows;
    
    /**
     * Constructor del SeatManager
     * Asigna atributos a firstRows y standardRows que recibe como parámetro
     * Crea una matriz con first+standard filas y SEATS_FOR_ROW columnas
     * @param first filas en primera
     * @param standard, filas en clase turista
     */

    public SeatManager(int first, int standard) {       
        setFirstRows(first);
        setStandardRows(standard);
        setSeats(new Person[getFirstRows()+ getStandardRows()][SEATS_PER_ROW]);
    }     
   
    /**
     * Asigna valor al atributo rows
     * @param rows, nuevo valor para rows entre MIN_FIRST_ROWS y MAX_FIRST_ROWS
     */
    private void setFirstRows(int rows) {
        checkParam(rows >= MIN_FIRST_ROWS && rows <= MAX_FIRST_ROWS, "Filas en primera fuera de límites");
        this.firstRows = rows;
    }
    
    /**
     * Asigna valor al atributo standardRows
     * @param rows, nuevo valor para standarRows, entre MIN_STANDARD_ROWS y MAX_STANDARD_ROWS
     */
    private void setStandardRows(int rows) {
        checkParam(rows >= MIN_STANDARD_ROWS && rows <= MAX_STANDARD_ROWS,"Filas en turista fuera de límites");
        this.standardRows = rows;
    }
    
    /**
     * Asigna valor a la matriz de asientos
     * @param seats, matriz de dos dimensiones de objetos tipo Person
     */
    private void setSeats(Person[][] seats) {
        checkParam(seats!=null, "Esperaba matriz de asientos pero fue null");
        this.seats = seats;
    }
    
    /**
     * @return número de filas en primera
     */
    public int getFirstRows(){
        return firstRows;
    }
    
    /**
     * @return número de filas en turista
     */
    public int getStandardRows(){
        return standardRows;
    }
       
    
    /**
     * asigna un asiento para la persona recibida, en fila y columna recibida, 
     * siempre que el asiento esté libre
     * @param person que quiere reservar
     * @param row, fila
     * @param column columna
     * @return true si ha podido sentar a la persona
     */
    public boolean bookSeat(Person person, int row, int column) {
        checkParam(person!=null, "Esperaba persona pero fue null");
        checkParam(row >= 0 && row < seats.length,"Fila fuera de límites");
        checkParam(column >= 0 && column < seats[row].length, "Columna fuera de límites");
       
        if ( seats[row][column] == null) {
            seats[row][column] = person;
            return true;
        } else {
            return false;
        }
    }
    
    /**
     * Libera un asiento cuya fila y columna se reciben
     * @param row
     * @param column
     * @return la persona liberada o null si no había ninguna
     */
    public Person release(int row, int column) {
        checkParam(row >= 0 && row < seats.length,"Fila fuera de límites");
        checkParam(column >= 0 && column < seats[row].length, "Columna fuera de límites");
        
        Person person = seats[row][column];
        seats[row][column] = null;
        return person;
    }
   
    /**
     * @param row
     * @param column
     * @return persona localizada en posición row, column
     */
    public Person getSeat(int row, int column){
        checkParam(row >=0 && row < seats.length,"Fila fuera de límites");
        checkParam(column >= 0 && column < seats[0].length, "Columna fuera de límites");
        return seats[row][column];
    }
    
    /**
     * Devuelve una copia de la matriz de asientos
     */
    public Person[][] getSeats(){
        Person[][] copy = new Person[seats.length][seats[0].length];
        for (int i=0; i < seats.length; i++){
            for (int j=0; j < seats[i].length; j++){
                copy[i][j] = seats[i][j];
            }
        }
        return copy;
    }
   
    /**
     * Si no se cumple la condición se lanza IllegalArgumentException con mensaje recibido
     * @param condición
     * @param mensaje
     */
    private void checkParam(boolean condition, String msg) {
        if (condition == false) {
            throw new RuntimeException(msg);
        }
    }
    
    /**
     * Checks for alone children on the plane.
     * 
     * @return The number of alone children.
     */
    public int numberOfAloneChildren(){
        int numberOfAloneChildren = 0;
        
        for (int i = 0; i < seats.length; i++){
            for (int j = 0; j < seats[0].length; j++){
                if (seats[i][j] != null){
                    if (seats[i][j].getAge() < Person.ADULTHOOD_AGE){
                        if (isChildAlone(i, j)){numberOfAloneChildren += 1;}
                    }
                }
            }
        }
        
        return numberOfAloneChildren;
    }
    
    /**
     * Checks if a child has an adult on the left or on the rigth.
     * 
     * @param i The row.
     * @param j The column.
     * 
     * @return If it is Alone returns true. Otherwise, false.
     */
    private boolean isChildAlone(int i, int j){
        if (j == 0) {
            return (seats[i][1] == null) || (seats[i][1].getAge() < Person.ADULTHOOD_AGE);
        }
        
        if (j == seats[0].length - 1) {
            return (seats[i][seats[0].length - 2] == null) || (seats[i][seats[0].length - 2].getAge() < Person.ADULTHOOD_AGE);
        }
        
        return (seats[i][j - 1] == null || seats[i][j - 1].getAge() < Person.ADULTHOOD_AGE) && (seats[i][j + 1] == null || seats[i][j + 1].getAge() < Person.ADULTHOOD_AGE);
    }

    /**
     * Attempts to seat all passengers from the list in available seats.
     * 
     * @param list The list of people that try to book the plane.
     * 
     * @return The number of succesfull people that entered in the plane.
     */
    public int bookSeat(ArrayList<Person> list){
        checkParam(list.size() != 0, INVALID_LIST);
        for (Person person : list){
            checkParam(person != null, INVALID_LIST);
        }
        
        int bookedPassengers = 0;
        boolean isntSeated;
        int currenti = 0;
        for (Person person : list){
            isntSeated = true;
            
            for (int i = currenti; i < seats.length && isntSeated; i++){
                for (int j = 0; j < seats[0].length && isntSeated; j++){
                    if (seats[i][j] == null){
                        bookSeat(person, i, j);
                        bookedPassengers += 1;
                        isntSeated = false;
                        currenti = i;
                    }
                }
            }
        }
        
        return bookedPassengers;
    }
        
    /**
     * Returns an array containing 1 arrayList for every age. The ArrayList will contain every person of the plane with the corresponding age.
     * 
     * @return An array of ArrayLists of people of the same age.
     */
    public ArrayList<Person>[] getPassengersByAge(){
        ArrayList<Person>[] result = new ArrayList[120];
        ArrayList<Person> tmp;
        for (int age = 0; age < result.length; age++){
            tmp = new ArrayList<Person>();
            for (int i=0; i < seats.length; i++){
                for (int j=0; j < seats[i].length; j++){
                    if (seats[i][j] != null){
                        if (seats[i][j].getAge() == age){
                            tmp.add(seats[i][j]);
                        }
                    }
                }
            }
            result[age] = tmp;
        }
        return result;
    }
}


   
