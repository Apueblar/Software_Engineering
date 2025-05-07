import java.util.*;
/**
 * Write a description of class SeatManager here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class SeatManager
{
    public final static String NEGATIVE_FIRSTCLASS_ROWS = "You must have a positive number of rows on the first class.";
    public final static String NEGATIVE_STANDARTCLASS_ROWS = "You must have a positive number of rows on the standart class.";
    
    public final static String NEGATIVE_ROW = "The row must be greater or equal than 0.";
    public final static String ERR_HIGH_ROW = "The row must be lower than the number of rows on the plane.";
    
    public final static String NEGATIVE_COLUMN = "The column must be greater or equal than 0.";
    public final static String ERR_HIGH_COLUMN = "The column must be lower than the number of columns on the plane.";
    public final static String ERR_COL = "The given parameters exceed the limits.";
    
    public final static String ERR_PERSON = "The person is not initialized.";
    
    public final static int WIDTH = 6;
    
    private Person seats[][];
    private int firstClassRows;
    
    public final static String NEG_PEOPLE = "You cannot add a negative amount of people.";
    public final static String ERR_CAPACITY = "The airplane max capacity cannot handle so much people.";
    
    public final static char NUM_TO_LETTER[] = {'A', 'B', 'C', 'D', 'E', 'F', 'G','H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
    
    public final static char ADULT_CHAR = 'X';
    public final static char CHILD_CHAR = 'C';
    public final static char FREE_SEAT_CHAR = '?';
    
    public final static byte FIRST_CLASS = (byte) 0;
    public final static byte STANDARD_CLASS = (byte) 1;
    public final static byte ALL_CLASSES = (byte) 2;
    
    public final static byte BOARD_WINDOW = (byte) 0;
    public final static byte LEFT_AISLE = (byte) 2;
    public final static byte RIGHT_AISLE = (byte) 3;
    public final static byte STARBOARD_WINDOW = (byte) 5;
    public final static byte BOTH_WINDOWS = (byte) 7;
    public final static byte BOTH_AISLES = (byte) 8;
    public final static byte EVERYWHERE = (byte) 9;
    
    /**
     * Constructor for objects of class SeatManager
     */
    public SeatManager(int firstClassRows, int standardClassRows)
    {
        if(firstClassRows <= 0){
            throw new RuntimeException(NEGATIVE_FIRSTCLASS_ROWS);
        }
        if(standardClassRows <= 0){
            throw new RuntimeException(NEGATIVE_STANDARTCLASS_ROWS);
        }
        
        this.firstClassRows = firstClassRows;
        seats = new Person [firstClassRows + standardClassRows][WIDTH];
    }

    /**
     * Calculates the max capacity of people that can enter on the plane.
     * 
     * @return Number of seats on the plane.
     */
    public int getSize()
    {
        return (seats.length * seats[0].length); //seats.length -> Rows / seats[0].length -> Columns
    }
    
    /**
     * Calculates the max capacity of people that can enter on the first class.
     * 
     * @return Number of seats on the firstClass.
     */
    public int getSizeFirstClass()
    {
        return (firstClassRows * seats[0].length);
    }
    
    /**
     * Calculates the max capacity of people that can enter on the standard class.
     * 
     * @return Number of seats on the Standard Class.
     */
    public int getSizeStandardClass()
    {
        return ((seats.length - firstClassRows) * WIDTH);
    }
    
    /**
     * Checks if the coords are right. Otherwise gives the corresponding error.
     * 
     * @param row The row of the seat.
     * @param column The column of the seat.
     */
    public void validateCoords(int row, int col)
    {
        if(row < 0){
            throw new RuntimeException(NEGATIVE_ROW);
        }
        if(row >= seats.length){
            throw new RuntimeException(ERR_HIGH_ROW);
        }
        
        if(col < 0){
            throw new RuntimeException(NEGATIVE_COLUMN);
        }
        if(col >= seats[0].length){
            throw new RuntimeException(ERR_HIGH_COLUMN);
        }
    }
    
    /**
     * Checks if a seat is empty and replaces, if so, it add the person to that seat.
     * 
     * @param person The person that will be on that seat.
     * @param row The row of the seat.
     * @param column The column of the seat.
     */
    public void bookSeat(Person person, int row, int col)
    {
        validateCoords(row, col);
        
        if(person == null){
            throw new RuntimeException(ERR_PERSON);
        }
        
        if (seats[row][col] == null){
            seats[row][col] = person;
        }
    }
    
    /**
     * Checks if a seat is reserved.
     * 
     * @param row The row of the seat.
     * @param column The column of the seat.
     * 
     * @return The anwer to is reserved.
     */
    public boolean isReserved(int row, int col)
    {
        validateCoords(row, col);
        
        return (seats[row][col] != null);
    }
    
    /**
     * Gives the person of a seat.
     * 
     * @param row The row of the seat.
     * @param column The column of the seat.
     * 
     * @return The adress of the person.
     */
    public Person getReservation(int row, int col)
    {
        validateCoords(row, col);
        
        return seats[row][col];
    }
    
    /**
     * Clears a seat.
     * 
     * @param row The row of the seat.
     * @param column The column of the seat.
     */
    public void releaseSeat(int row, int col)
    {
        validateCoords(row, col);
        
        seats[row][col] = null;
    }
    
    /**
     * Counts all the people on each row of the plane and adds all them.
     * 
     * @return The number of people in the plane.
     */
    public int getNumPax()
    {
        int numberOfPax = 0;
        for(int i = 0; i < seats.length; i++){
            for(int j = 0; j < seats[0].length; j++){
                if (seats[i][j] != null){numberOfPax += 1;}
            }
        }
        
        return numberOfPax;
    }
    
    /**
     * Adds people to the plane by a given param.
     * 
     * @param paxNumber The number of people that you want to add to the plane.
     */
    public void loadPax(int paxNumber)
    {
        if (paxNumber < 0){throw new RuntimeException(NEG_PEOPLE);}
        
        int remainingFreeSeats = getSize() - getNumPax();
        
        if (remainingFreeSeats < paxNumber){throw new RuntimeException(ERR_CAPACITY);}
        
        Random random = new Random();
        
        for(int i = 0; i < seats.length && paxNumber > 0; i++){
            for(int j = 0; j < seats[0].length && paxNumber > 0; j++){
                if (seats[i][j] == null){
                    if (random.nextInt(remainingFreeSeats) < paxNumber){
                        seats[i][j] = new Person();
                        paxNumber--;
                    }
                    remainingFreeSeats--;
                }
            }
        }
    }
    
    /**
     * Prints the data of all the people on the plane.
     */
    public void printManifest()
    {
        System.out.println("MANIFEST");
        System.out.println();
        System.out.println("FIRST CLASS");
        for(int i = 0; i < seats.length; i++){
            if (i == firstClassRows){
                System.out.println();
                System.out.println("STANDARD CLASS");
            }
            for(int j = 0; j < seats[0].length; j++){
                if (seats[i][j] != null){
                    System.out.print("ROW: " + i + " ");
                    System.out.print("SEAT: " + NUM_TO_LETTER[j] + " ");
                    System.out.print("- " + seats[i][j].getName().toUpperCase());
                    System.out.print(" " + seats[i][j].getSurname().toUpperCase());
                    System.out.println(" - AGE: " + seats[i][j].getAge());
                }
            }
        }
    }
    
    /**
     * Represents in a visual way the seats of the plane.
     */
    public void print()
    {
        System.out.print("   ");
        for(int letter = 0; letter < WIDTH; letter++){
            if (letter == WIDTH / 2){System.out.print("  ");}
            System.out.print(" " + NUM_TO_LETTER[letter]);
        }
        System.out.println();
        for(int i = 0; i < seats.length; i++){
            if (i == firstClassRows){
                for(int p = -2; p < WIDTH; p++){System.out.print("--");}
                System.out.println("-");
            }
            System.out.print(String.format("%-" + 3 + "s", i));
            for(int j = 0; j < seats[0].length; j++){
                if (j == WIDTH / 2){System.out.print("  ");}
                if (seats[i][j] == null){
                    System.out.print(" " + FREE_SEAT_CHAR);
                }else if (seats[i][j].getAge() < Person.ADULTHOOD_AGE){
                    System.out.print(" " + CHILD_CHAR);
                }else{
                    System.out.print(" " + ADULT_CHAR);
                }
            }
            System.out.println();
        }
    }
    
    /**
     * Searches for the lowest age of the people in the plane.
     * 
     * @return The age of the youngest person in the plane.
     */
    public int getYoungestAgeOnBoard()
    {
        int minAge = Person.MAX_AGE_VALUE + 1;
        for(int i = 0; i < seats.length; i++){
            for(int j = 0; j < seats[0].length; j++){
                if (seats[i][j] != null){
                    if (minAge > seats[i][j].getAge()){
                        minAge = seats[i][j].getAge();
                    }
                }
            }
        }
        if (minAge == Person.MAX_AGE_VALUE + 1) {return -1;}
        return minAge;
    }
    
    /**
     * Searches for the people with the lowest age in the plane.
     * 
     * @return An ArrayList<Person> with the people that have the lowest age.
     */
    public ArrayList<Person> getYoungestPeopleOnBoard()
    {
        ArrayList<Person> youngestPeople = new ArrayList<Person>();
        int minAge = Person.MAX_AGE_VALUE + 1;
        for(int i = 0; i < seats.length; i++){
            for(int j = 0; j < seats[0].length; j++){
                if (seats[i][j] != null){
                    if (minAge > seats[i][j].getAge()){
                        minAge = seats[i][j].getAge();
                        youngestPeople = new ArrayList<Person>();
                    }
                    if (seats[i][j].getAge() == minAge){
                        youngestPeople.add(seats[i][j]);
                    }
                }
            }
        }
        return youngestPeople;
    }
    
    /**
     * OPTIONAL:
     * Counts all the people on a part of the plane and adds all them.
     * 
     * @param area It can be: FIRST_CLASS / STANDARD_CLASS / ALL_CLASSES depending on which one is chosen it selects different rows.
     * 
     * @return The number of people in the specified class.
     */
    public int getNumPax(byte area)
    {
        int numberOfPax = 0;
        if (area == FIRST_CLASS || area == ALL_CLASSES){
            for(int i = 0; i < firstClassRows; i++){
                for(int j = 0; j < seats[0].length; j++){
                    if (seats[i][j] != null){numberOfPax += 1;}
                }
            }
        }
        if (area == STANDARD_CLASS || area == ALL_CLASSES){
            for(int i = firstClassRows; i < seats.length; i++){
                for(int j = 0; j < seats[0].length; j++){
                    if (seats[i][j] != null){numberOfPax += 1;}
                }
            }
        }
        return numberOfPax;
    }
    
    /**
     * OPTIONAL:
     * Counts all the people on a part of the plane and adds all them.
     * 
     * @param area It can be: FIRST_CLASS / STANDARD_CLASS / ALL_CLASSES depending on which one is chosen it selects different rows.
     * @param section It can be: BOARD_WINDOW / LEFT_AISLE / RIGHT_AISLE / STARBOARD_WINDOW / BOTH_WINDOWS / BOTH_AISLES / EVERYWHERE depending on which is chosen it selects different columns.
     * 
     * @return The number of people in the specified class.
     */
    public int getNumPax(byte area, byte section)
    {
        int numberOfPax = 0;
        if (section == EVERYWHERE) {
            numberOfPax = getNumPax(area);
        }
        if (area == FIRST_CLASS || area == ALL_CLASSES){
            if (section == BOARD_WINDOW || section == BOTH_WINDOWS){
                for(int i = 0; i < firstClassRows; i++){
                        if (seats[i][0] != null){numberOfPax += 1;}
                }
            }
            if (section == LEFT_AISLE || section == BOTH_AISLES){
                for(int i = 0; i < firstClassRows; i++){
                        if (seats[i][2] != null){numberOfPax += 1;}
                }
            }
            if (section == RIGHT_AISLE || section == BOTH_AISLES){
                for(int i = 0; i < firstClassRows; i++){
                        if (seats[i][3] != null){numberOfPax += 1;}
                }
            }
            if (section == STARBOARD_WINDOW || section == BOTH_WINDOWS){
                for(int i = 0; i < firstClassRows; i++){
                        if (seats[i][5] != null){numberOfPax += 1;}
                }
            }
        }
        if (area == STANDARD_CLASS || area == ALL_CLASSES){
            if (section == BOARD_WINDOW || section == BOTH_WINDOWS){
                for(int i = firstClassRows; i < seats.length; i++){
                        if (seats[i][0] != null){numberOfPax += 1;}
                }
            }
            if (section == LEFT_AISLE || section == BOTH_AISLES){
                for(int i = firstClassRows; i < seats.length; i++){
                        if (seats[i][2] != null){numberOfPax += 1;}
                }
            }
            if (section == RIGHT_AISLE || section == BOTH_AISLES){
                for(int i = firstClassRows; i < seats.length; i++){
                        if (seats[i][3] != null){numberOfPax += 1;}
                }
            }
            if (section == STARBOARD_WINDOW || section == BOTH_WINDOWS){
                for(int i = firstClassRows; i < seats.length; i++){
                        if (seats[i][5] != null){numberOfPax += 1;}
                }
            }
        }
        return numberOfPax;
    }
    
    /**
     * OPTIONAL:
     * Counts the number of passengers in the first class (by gender) whose age is over 65.
     * 
     * @param gender The gender you want to count.
     * 
     * @return The number of people in the specified class with the specified conditions.
     */
    public int countFirstClassElderyPax(boolean gender)
    {
        int numberOfPax = 0;
        for(int i = 0; i < firstClassRows; i++){
            for(int j = 0; j < seats[0].length; j++){
                if (seats[i][j] != null){
                    if (seats[i][j].getAge() > 65 && seats[i][j].getGender() == gender){numberOfPax += 1;}
                }
            }
        }  
        return numberOfPax;
    }
    
    /**
     * OPTIONAL:
     * Interchanges seats by columns.
     * 
     * @param colA Column A.
     * @param colB Column B.
     */
    public void interchangeSeats(int colA, int colB)
    {
        if (colA < 0 || colB < 0 || colA > seats[0].length || colB > seats[0].length){
            throw new RuntimeException(ERR_COL);
        }
        Person aux;
        for(int i = 0; i < seats[0].length; i++){
            aux = seats[i][colA];
            seats[i][colA] = seats[i][colB];
            seats[i][colB] = aux;
        }  
    }
}













































