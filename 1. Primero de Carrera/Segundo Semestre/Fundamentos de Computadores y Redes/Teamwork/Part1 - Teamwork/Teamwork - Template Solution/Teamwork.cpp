#include <iostream>

// To pass every step you can input these values:
// [CheckPassword] -> password
// [CheckBit] -> 260 (or any number greater than 255)
// [CheckAssembly] -> two equal numbers
// [CheckInLineAssembly] -> 10
// You passed!
//
// If not, Invalid License!

using namespace std;

extern "C" bool areEqualAssembly(int a, int b);

// Write here the UO that you have used as ID:
// You'll have to complete this value

void InvalidLicense(void);
void CheckPassword(void);
void CheckBit(void);
void CheckAssembly(void);
void CheckInlineAssembly(void);


int main()
{
	CheckPassword();
	CheckBit();
	CheckAssembly();
	CheckInlineAssembly();
	cout << "You passed!";
	return 0;
}


void InvalidLicense(void)
{
    cout << "Invalid license" << endl;
	exit(EXIT_FAILURE);
}

// Valid input: "password"
// Invalid input: any other string
void CheckPassword(void)
{
	int const MAX_PASSWORD = 255;
	char Input[MAX_PASSWORD];

	cout << "[CheckPassword] Enter password: ";
	cin.getline(Input, MAX_PASSWORD);
	if (strcmp(Input, "password") != 0)
	{
		InvalidLicense();
	}

}

// Valid input: a number greater than 255
void CheckBit(void)
{
	int num1;

	cout << "[CheckBits] Enter a number: ";
	cin >> num1;

	// If num1 < 256, invalid
	if ((num1 & 0xFFFFFF00) == 0)
	{
		InvalidLicense();
	}
}

// Valid input: two equal numbers
void CheckAssembly(void)
{
	int num1 = 0;
	int num2 = 0;
	cout << "[CheckAssembly] Enter number 1: ";
	cin >> num1;
	cout << "[CheckAssembly] Enter number 2: ";
	cin >> num2;

	if (areEqualAssembly(num1, num2) != 1)
	{
		InvalidLicense();
	}
}

// Valid input: 10d
void CheckInlineAssembly(void)
{
	// only checks if num is equal to 10d
	int num;
	cout << "[CheckInlineAssembly] Enter number: ";
	cin >> num;

	__asm {
		mov eax, num;
		xor eax, 0xA
		cmp eax, 0
		je equal10
		call InvalidLicense
	equal10:
	}
}

