package es.uniovi.eii.bbdd.jdbc.exam;
import java.util.Scanner;
import java.sql.*;

//alter user M25_JDBC__UO299874 identified by LemonPie1

/** 
 * (ES)
 * Desde el main tienen que poder ejecutarse los mÃƒÂ©todos 
 * implementados para el examen
 *
 * Si al importar el proyecto te da un problema con la
 * versiÃƒÂ³n de Java: BotÃƒÂ³n secundario sobre el
 * proyecto > "Build Path", "Configure Build Path" > "Libraries".
 * En "Modulepath" elimina la versiÃƒÂ³n de JRE que te estÃƒÂ¡
 * dando problemas y aÃƒÂ±ade la que tengas en tu equipo
 * desde el botÃƒÂ³n de "Add Library".
 * 
 * (EN)
 
 *From this main class it must be possible to execute
 * the methods implemented during the test.
 
 * If when importing the project you have a problem with
 * the Java version: Right-click on the
 * project > "Build Path", "Configure Build Path" > "Libraries".
 * In "Modulepath" delete the JRE version that is giving you
 * problems and add the one you have in your computer from
 * the "Add Library" button.
 *  
 * @author Databases 2025 Teaching Staff.
 */
public class ExamJDBCmayo {
	
	private static String USERNAME = "M25_JDBC__UO299874";
	private static String PASSWORD = "LemonPie1";
	private static String CONNECTION_STRING = "jdbc:oracle:thin:@156.35.94.98:1521:desa19"; // "Protocol:Vendor:Driver:Server:Port:DB name"

	private static Connection con;
	
	private static Connection getConnection() throws SQLException{
		if(DriverManager.getDriver(CONNECTION_STRING) == null) {
				DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
		}
		return  DriverManager.getConnection(CONNECTION_STRING,USERNAME,PASSWORD);
	}
	
	public static void main(String[] args) {
		try {
			con = getConnection();

			exercise1();
			exercise2();
		
			con.close(); // To close the connection and all cursors and other things
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * EXAM EXERCISE 1 (Procedure in Java)
	 * @throws SQLException
	 */
	public static void exercise1() throws SQLException {
		System.out.println("############# Exercise 1: #############");
		String cursor1String = "SELECT i.instructor_id, i.instructor_name, COUNT(*) numSections, MAX(num_hours) max_Num_hours\r\n"
				+ "	FROM teaches t INNER JOIN course c ON t.course_id = c.course_id\r\n"
				+ "        INNER JOIN instructor i ON t.instructor_id = i.instructor_id\r\n"
				+ "	WHERE 1=1\r\n"
				+ "        AND TYPE='Compulsory'\r\n"
				+ "        AND i.instructor_id IN (\r\n"
				+ "            SELECT instructor_id\r\n"
				+ "                FROM Participates\r\n"
				+ "        )\r\n"
				+ "	GROUP BY i.instructor_id, instructor_name\r\n"
				+ "	HAVING count(*) >= 3\r\n"
				+ " ORDER BY instructor_name DESC, i.instructor_id DESC";
		
		String cursor2String= " SELECT s.student_name, s.tot_cred, c.course_id, c.title, t.sec_id, t.semester, t.year, t.grade\r\n"
				+ "    FROM takes t INNER JOIN student s ON t.student_id = s.student_id\r\n"
				+ "        INNER JOIN course c ON t.course_id = c.course_id\r\n"
				+ "    WHERE 1=1\r\n"
				+ "        AND s.instructor_id = ? \r\n"
				+ "        AND s.tot_cred < (SELECT AVG(tot_cred) FROM student)\r\n"
				+ "        AND s.student_name LIKE 'S%'\r\n"
				+ "    ORDER BY s.student_name ASC";
		
		PreparedStatement cursor2 = con.prepareStatement(cursor2String); // For the 10 :)
		Statement cursor1 = con.createStatement();
		ResultSet cursor1RS = cursor1.executeQuery(cursor1String);
		while (cursor1RS.next()) {
			System.out.println(" INSTRUCTOR: " +
				cursor1RS.getString("instructor_id") + " / " +
				cursor1RS.getString("instructor_name") + " / " +
				cursor1RS.getInt("numSections") + " / " +
				cursor1RS.getInt("max_Num_hours"));
			
			cursor2.setString(1,cursor1RS.getString("instructor_id"));
			ResultSet cursor2RS = cursor2.executeQuery();
			while (cursor2RS.next()) {
				System.out.println("\t→ STUDENT/SECTION: " +
					cursor2RS.getString("student_name") + " / " +
					cursor2RS.getInt("tot_cred") + " / " +
					cursor2RS.getString("course_id") + " / " +
					cursor2RS.getString("title") + " / " +
					cursor2RS.getString("sec_id") + " / " +
					cursor2RS.getString("semester") + " / " +
					cursor2RS.getInt("year") + " / " +
					cursor2RS.getFloat("grade"));
			}
			cursor2RS.close();
		}
		cursor1RS.close();
	}
	
	/**
	 * EXAM EXERCISE 2 (Updates of budget in Java)
	 * @throws SQLException
	 */
	public static void exercise2() throws SQLException {
		System.out.println("############# Exercise 2: #############");
		float new_dept_budget = 0; 
		
		
		String cursor1String = "SELECT DISTINCT d.dept_name, d.dept_budget\r\n"
				+ "    FROM department d INNER JOIN instructor i ON d.dept_name = i.dept_name\r\n"
				+ "        INNER JOIN participates p ON i.instructor_id = p.instructor_id\r\n"
				+ "    WHERE p.role = 'Researcher'";
			
		String feesString = "SELECT SUM(section_fee) * 0.10 tot_students\r\n"
				+ "    FROM student s INNER JOIN takes t ON s.student_id = t.student_id\r\n"
				+ "        INNER JOIN course c ON c.course_id = t.course_id\r\n"
				+ "    WHERE 1=1\r\n"
				+ "        AND s.dept_name = ?\r\n"
				+ "        AND s.dept_name = c.dept_name";
		
		String updateString = "UPDATE department\r\n"
				+ "    SET dept_budget = ?\r\n"
				+ "    WHERE dept_name = ?";
		
		PreparedStatement fees = con.prepareStatement(feesString);
		PreparedStatement update = con.prepareStatement(updateString);
		
		Statement cursor1 = con.createStatement();
		ResultSet cursor1RS = cursor1.executeQuery(cursor1String);
		while (cursor1RS.next()) {			
			fees.setString(1, cursor1RS.getString("dept_name"));
			ResultSet rsFees = fees.executeQuery();
			
			new_dept_budget = cursor1RS.getFloat("dept_budget");
			if (rsFees.next()) {
				new_dept_budget += rsFees.getFloat("tot_students");
			}
			rsFees.close();
			
			update.setFloat(1, new_dept_budget);
			update.setString(2, cursor1RS.getString("dept_name"));
			int rowsUpdated = update.executeUpdate();

			String deptName = cursor1RS.getString("dept_name");
			float originalBudget = cursor1RS.getFloat("dept_budget");

			System.out.printf("→ Dept: %-20s | Old Budget: %.2f | New Budget: %.2f | Rows Affected: %d%n",
			                  deptName, originalBudget, new_dept_budget, rowsUpdated);			
		}
		cursor1RS.close();
	}

	@SuppressWarnings({ "resource", "unused" })
	private static String ReadString(){
		return new Scanner(System.in).nextLine();		
	}
	
	@SuppressWarnings({ "resource", "unused" })
	private static int ReadInt(){
		return new Scanner(System.in).nextInt();			
	}	
}
