import java.util.*; // Import all the packages of the util folder.
/**
 * Model of a Person.
 *
 * @author Álvaro Puebla
 * @version 15/9/2023 - 1.0.0
 */
public class Person
{
    private String name;
    public final static String MALE_NAMES[] = {"Adrian", "Alvaro", "Marcos", "Pablo", "Angel", "Alex", "Santiago", "Javier", "Nacho", "Ismael", "Lucas", "Sergio", "Iyan", "Carlos", "Iker", "Hugo", "Jose", "Alberto", "Jorge", "Luis", "Pelayo", "Mario", "Nicolas", "Diego", "Miguel", "Felipe", "Enzo"};
    public final static String FEMALE_NAMES[] = {"Sofia", "Maria", "Clara", "Irene", "Natalia", "Deva", "Paula", "Yaiza", "Aitana", "Lucia", "Angela", "Virginia", "Alba", "Aroa", "Carla", "Mencia", "Ines", "Alejandra", "Olaya", "Elsa", "Raquel", "Daniela"};
    public final static String FAMILY_NAMES[] = {"Puebla", "Rodriguez", "Fernandez", "Martinez", "Leiras", "Mera", "Puertas", "Hoyos", "Garcia", "Gonzalez", "Perez", "Alonso", "Alvarez", "Romero", "Ramirez", "Morales", "Blanco", "Mendez", "Iglesias", "Ruiz", "Santos", "Diez", "Carrasco", "Fuentes", "Ibañez", "Arias", "Brabo", "Gallardo"};   
    
    
    private String surname;
    
    private int age;
    public final static int MAX_AGE_VALUE = 118;
    public final static int ADULTHOOD_AGE = 18;
    public final static int RETIREMENT_AGE = 67;
    public final static String ERR_NEGATIVE_AGE = "The age must be positive.";
    public final static String ERR_HIGH_AGE = "The age must be lower or equal to " + MAX_AGE_VALUE + ".";
    //Final -> Fija el valor como el último / estático.
    //Static -> Mismo valor para todos los objetos.
    // Si el valor es una constante va en mayúsculas (Final).
    
    private boolean gender;
    public final static boolean FEMALE_VALUE = false;
    public final static boolean MALE_VALUE = true;
    public final static String MALE_TEXT = "male";
    public final static String FEMALE_TEXT = "female";
    
    //public -> Todo el mundo lo puede cambiar y usar
    //protected -> Solo objetos y clases del proyecto lo modifican y usan
    //private -> Solo la clase lo usa y modifica
    
    /**
     * Constructor for objects of class Person
     */
    public Person()
    {     
        Random coin = new Random();
        setAge(coin.nextInt(MAX_AGE_VALUE + 1));
        setGender(coin.nextBoolean());
        
        setSurname(FAMILY_NAMES[coin.nextInt(FAMILY_NAMES.length)]);
        
        if(isABoy()){
            setName(MALE_NAMES[coin.nextInt(MALE_NAMES.length)]);
        }else{
            setName(FEMALE_NAMES[coin.nextInt(FEMALE_NAMES.length)]);
        }
    }
    
    /**
     * Constructor for objects of class Person
     * 
     * @param age (initial value of age)
     * 
     */
    public Person(int age)
    {
        this();
        setAge(age);
    }
    
    /**
     * Constructor for objects of class Person
     * 
     * @param name (initial value of name)
     * @param surname (initial value of surname)
     * @param age (initial value of age)
     * @param gender (initial value of gender)
     * 
     */
    public Person(String name, String surname)
    {
        this();
        setName(name);
        setSurname(surname);
    }
    
    /**
     * Constructor for objects of class Person
     * 
     * @param name (initial value of name)
     * @param surname (initial value of surname)
     * @param age (initial value of age)
     * @param gender (initial value of gender)
     * 
     */
    public Person(String name, String surname, int age, boolean gender)
    {
        setName(name);
        setSurname(surname);
        setAge(age);
        setGender(gender);
    }
    
    /**
     * Updates the value of the field name.
     * 
     * @param name New name for the name field.
     */
    public void setName(String name){
        /*This method changes the name of the object*/
        this.name = name;
    }
    
    /**
     * Updates the value of the field surname.
     * 
     * @param surname New surname for the surname field.
     */
    public void setSurname(String surname){
        this.surname = surname; //Coment
    }
    
    /**
     * Updates the value of the field age between 0 and 118.
     * 
     * @param age New age for the age field.
     */
    public void setAge(int age){
        if(age >= 0){
            if(age <= MAX_AGE_VALUE){
                this.age = age; //Si el valor está en el rango, actualiza la edad
            }else{
                throw new RuntimeException(ERR_HIGH_AGE); //Muestra el error de edad >118 en pantalla
            }
        }else{
            throw new RuntimeException(ERR_NEGATIVE_AGE); //Muestra el error de edad negativa en pantalla
        }
    }
    
    /**
     * Updates the value of the field gender.
     * 
     * @param gender New gender for the gender field.
     */
    public void setGender(boolean gender){
        this.gender = gender;
    }
    
    /**
     * Shows if the gender of the person is a girl.
     * 
     * @return If its a girl returns true. Otherwise is false.
     */
    public boolean isAGirl(){
        if(getGender() == FEMALE_VALUE){
            return true; //Its a girl
        }else{
            return false; //Its a boy
        }
    }
    
    /**
     * Shows if the gender of the person is a girl.
     * 
     * @return If its a girl returns true. Otherwise is false.
     */
    public boolean isABoy(){
        if(getGender() == MALE_VALUE){
            return true; //Its a boy
        }else{
            return false; //Its a girl
        }
    }
    
    /**
     * Returns the current value of the name field.
     * 
     * @return Returns a string of the name.
     */
    public String getName(){
        return this.name;
    }
    
    /**
     * Returns the current value of the surname field.
     * 
     * @return Returns a string of the surname.
     */
    public String getSurname(){
        return this.surname;
    }
    
    /**
     * Returns the current value of the age field.
     * 
     * @return Returns a integer of the age.
     */
    public int getAge(){
        return this.age;
    }
    
    /**
     * Returns the current value of the gender field.
     * 
     * @return Returns a boolean of the gender.
     */
    public boolean getGender(){
        return this.gender;
    }
    
    /**
     * Returns the male or female string depending on the gender of the object.
     * 
     * @return String "Male" if it is a boy. Otherwise it will return String "Female".
     */
    private String genderToString(){
        if(isABoy()){
            return MALE_TEXT;
        }else{
            return FEMALE_TEXT;
        }
    }
    
    /**
     * Display the values for all the fields in class in the computer's display.
     */
    public void print(){
        System.out.println("Name: " + getName());
        System.out.println("Surname: " + getSurname());
        System.out.println("Age: " + getAge());
        System.out.println("Gender: " + genderToString());
    }
    
    /**
     * Display the values for all the fields in class on the computer's display.
     */
    public void print1(){
        System.out.println("Name: " + getName());
        System.out.println("Surname: " + getSurname());
        System.out.println("Age: " + getAge());
        System.out.print("Gender: ");
        if(isABoy()){
            System.out.println(MALE_TEXT);
        }else{
            System.out.println(FEMALE_TEXT);
        }
    }
    
    /**
     * Creates a string object containing the values of every field in the class.
     * 
     * @return String included the Name, Surname, Age and Gender.
     */
    public String toString(){
        return ("[Name: " + getName() + " - Surname: " + getSurname() + " - Age: " + getAge() + " - Gender: " + genderToString() + "]");
    }
    
    /**
     * Creates a method to return a String containing the value of every field in Person.
     * 
     * @return String of the fields in the Person class separated by dashes.
     */
    public String getHashCode(){
        return (getName().substring(0,3).toUpperCase() + "-" + getSurname().substring(0,3).toUpperCase()+ "-" + getAge() + "-" + getGender());
        /* .toUpperCase() -> Mayúsculas / .toLowerCase() -> Minúsculas / .substring(valor_inicial,valor_final) -> Corta el String en ese intervalo */
    }
    
    /**
     * Checks for the age of the person and calculates the age until adulthood or retirement.
     * 
     * @return Integer, if the person is young -> The years until adulthood, if the person is between adulthood and retirent age -> The years until retirement age, else The years retired. 
     */
    public int getCriticalAge(){
        if (getAge() < ADULTHOOD_AGE){
            return ADULTHOOD_AGE - getAge();
        }else{
            if(getAge() < RETIREMENT_AGE){
                return RETIREMENT_AGE - getAge();
            }else{
                return getAge() - RETIREMENT_AGE;
            }
        }
    }
    
    /**
     * This method returns true if the age of the user is the same as the one provided.
     * 
     * @param age The age to compare with.
     * 
     * @return True if it's the same age. Otherwise returns false.
     */
    public boolean areYou(int age){
        return getAge() == age;
    }
    
    /**
     * This method returns true if the name of the user is the same as the one provided.
     * 
     * @param name The name to compare with.
     * 
     * @return True if it's the same name. Otherwise returns false.
     */
    public boolean areYou(String name){
        return getName().equalsIgnoreCase(name);
    }
    
    // b.equals(a) -> Boolean - Compares both, if they are the same true.
    // b.compareto(a) -> Int - Compares, if they are too similar lower number. If they are too different higher number, if they are the same 0.
    // IgnoreCase is added to ignore the upper and lower characters.
    
    /**
     * This method returns true if the person of the user is the same as the one provided.
     * 
     * @param person The person to compare with.
     * 
     * @return True if it's the same person. Otherwise returns false.
     */
    public boolean areYou(Person person){
        return getName().equalsIgnoreCase(person.getName()) && 
        getSurname().equalsIgnoreCase(person.getSurname()) && 
        getAge() == person.getAge() && 
        getGender() == person.getGender();
    }
    
    /**
     * Compares the age of a given person to the person itself.
     * 
     * @param person The person to compare the age with.
     * 
     * @return 0 if the ages are the same, -1 if the host person is younger, 1 if the host person is older.
     */
    public int compareTo(Person person){
        if (getAge() == person.getAge()){
            return 0;
        }else{
            if (getAge() < person.getAge()){
                return -1;
            }else{
                return 1;
            }
        }
    }
}