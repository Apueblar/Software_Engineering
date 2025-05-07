#include <iostream>
using namespace std;

int main()
{
	int a = 2000000000;
	int b = 2000000000;

	cout << a+b << endl;

	if (a < b)
	{
		cout << "a is less than b" << endl;
	}

	int a2 = 0;
	cout << endl;
	cout << a << endl;
	cout << b << endl;
	scanf("%d", &a2);
	printf("%d", a2);
	cout << a << endl;
	cout << endl;

	const int one_million = 1000000;
	int counter = 0;
	for (int i = 0; i < 3000 * one_million; i++)
		counter++;
	cout << "counter " << counter << endl;

	return 0;
}
