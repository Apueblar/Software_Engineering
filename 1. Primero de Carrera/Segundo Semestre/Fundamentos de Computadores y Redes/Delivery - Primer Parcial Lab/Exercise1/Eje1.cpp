#include <iostream>
#include <iomanip>

using namespace std;

int main()
{
	// Defining variables of various types
	unsigned int var1 = 85;
	int var2 = -78;
	float var3 = -23.64;
	float var4 = 13.98;
	char string1[] = "#@ÓC";
	char string2[] = "%Dïd";
	cout << "Size of 'int': " << sizeof(int) << " bytes" << endl;

	/*
    BEGIN of the code fragment to be corrected.
	 The result of the addition is not what was expected.
	 Modify the program so that the output is as expected.
	 New sentences cannot be added. Existing sentences cannot be deleted.
    */
	int a = -10;
	short int b = -15;
	short int addition = a + b; // We need to remove the "unsigned"
	cout << a << " + "<< b << " = " << addition << endl;

	return 0;
}
