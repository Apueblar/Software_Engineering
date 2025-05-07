import java.util.Random;
/**
 * Clase Persona, con
 *
 *      
 *  
 *      
 * @author ip-profes 
 * @version 18-9-2023
 */
public class Person
{
    
    public static final int MIN_AGE = 0;        
    public static final int MAX_AGE = 120;
    
    public static final boolean GENDER_MALE = true;
    public static final boolean GENDER_FEMALE = false;
    
    public static final int ADULTHOOD_AGE = 18;    // Se considera adulto con 18 años
    public static final int RETIREMENT_AGE = 65;    // Se considera retirado con 65 años
    
    public static final char MIN_IDENTIFIER = 'A';
    public static final char MAX_IDENTIFIER = 'Z';
    
    public static final String FEMALE_NAMES[] = {"Ana", "Laura", "María", "Bea"};
    public static final String MALE_NAMES[] = {"Juan", "Pedro", "José", "Francisco"};
    public static final String SURNAMES[] = {"Álvarez", "Díaz", "González", "Fernández"};
    
    
    // Atributos variables del objeto
    private String name;
    private int age;
    private String surname;
    private boolean gender;     // true indicará Masculino, false Femenino

    /**
     * Constructor de objetos por defecto 
     * nombre Fernando Alonso de 40 años
     */
    public Person()
    {
        setGender(randomGender());
        setName(randomName());
        setAge (randomAge());
        setSurname(randomSurname());        
    }
    /**
     * Devuelve un número aleatorio entre 0 y MAX_AGE - 1, para la edad
     * @return age
     */
    private int randomAge(){
        Random randomGenerator = new Random();
        return randomGenerator.nextInt(MAX_AGE);    
    }
    
    /**
     * @return apellido aleatorio de entre los que existen en la lista de apeellidos SURNAMES
     */
    private String randomSurname(){
        Random r = new Random();
        return SURNAMES[r.nextInt(SURNAMES.length)];
    }
    /**
     * Constructor que recibe la edad. El resto serán los valores por defecto
     */
    public Person(int age)
    {
        this();
        setAge (age);
    }
    
   /**
     * Método que modifica el valor de name
     * @param newname
     */
    private void setName(String name){
        checkParam(name!=null && !name.trim().isBlank(),"null o vacío en lugar de name");
        this.name = name;
    }
    
    /**
     * Método asigna género y nombre aleatorio
     * 
     */
    
     private String randomName(){
        Random r = new Random();
       
        if (getGender() == GENDER_FEMALE){
             return FEMALE_NAMES[r.nextInt(FEMALE_NAMES.length)];
        } else {
            return MALE_NAMES[r.nextInt(MALE_NAMES.length)];
        }        
    }
    private boolean randomGender()
    {
        Random r = new Random();
        return r.nextBoolean();
               
    }
    
    /**
     * Método que devuelve el valor del atributo name
     * 
     * @return  name, nombre de la persona, de tipo String
     * 
     */
    public String getName()
    {
       return name; 
    }
    
    /**
     * Método que modifica el valor del atributo age si éste es correcto
     * 
     * @param  age, edad de la persona, de tipo int, un método entre [0,120)
     * 
     */
    private void setAge(int age)
    {
       checkParam(age >= MIN_AGE, "La edad debe ser mayor que el mínimo" );
       checkParam(age < MAX_AGE,"La edad debe ser menor que " + MAX_AGE); 
       this.age = age;
    }
    
    
    
    /**
     * Comprueba que la condición se cumple. Si no se cumple lanza una excepción
     * @param condition, condición de control, de tipo booleano
     * @param msg, mensaje que se envía en la excepción 
     */
    private void checkParam(boolean condition, String msg){
        if (! condition) {
            throw new IllegalArgumentException(msg);
        }
    }
    
    /**
     * Método que devuelve el valor del atributo age
     * 
     * @return  age, edad de la persona, de tipo int
     * 
     */
    public int getAge()
    {
       return age;
    }
    
    /**
     * Método que modifica el valor del atributo surname
     * 
     * @param  newSurname, apellidos de la persona, de tipo String
     * 
     */
    private void setSurname(String surname)
    {
       checkParam(surname!=null, "Null en lugar de apellido");
       this.surname = surname;
    }
    
    /**
     * Método que devuelve el valor del atributo surname
     * 
     * @return  surname, apellidos de la persona, de tipo String
     * 
     */
    public String getSurname()
    {
       return surname;
    }
    
    /**
     * Método que modifica el valor del atributo gender, el género de la persona
     * Se indicará como true Masculino y False Femenino
     * 
     * @param  newGender, nombre de la persona, de tipo String
     * 
     */
    private void setGender(boolean gender)
    {
       this.gender = gender;
    }
    
    /**
     * Método que devuelve el valor del atributo gender, el género de la persona
     * 
     * @return  gender, true si es masculino y false si es de género femenino
     * 
     */
    public boolean getGender()
    {
       return gender;
    }
    
         
}
