//#include <iostream> // the include is the import of python
//
//// int main()
//// {
////     std::cout << "hello, world!";
////     // los símbolos << sirven para mandar lo que hay en la derecha a la izquierda
////     // std::cout sirve para imprimir por pantalla
////     // std::cout << "hello, world!" << std::endl; will do the same and change the line
//// 
////     return 0;
//// }
//
//using std::cout; // cout will be the same as std::cout
//using std::endl; // endl will be the same as std::endl
//using std::cin; // lo mismo con cin que es para recibir un input
//
//int main()
//{
//    unsigned int a = 23; // lo guarda normal
//    int b = -5; // lo guarda como 2's complement
//
//    cout << "a: " << a << " b: " << b << endl;
//
//    if (a < b)
//    {
//        cout << "a less than b" << endl;
//    }
//
//    return 0;
//}

#include <iostream>

using std::cout;
using std::endl;
using std::cin;

void set23(int number) // Se pasa solo el número a menos que ponga &number
{
    number = 23;
}

int main()
{
    int i = 10;

    set23(i);
    cout << "i now contains: " << i << endl;

    return 0;

    char str[] = "abc"; // Character array with these four values:
    // str[0]='a' str[1]='b' str[2]='c' str[3]=\0

    const unsigned int maxChars = 100; // const is used to define constants
    char str[maxChars];
    cin.getline(str, maxChars); // Reads at most 99 characters from console,
    // or until return is pressed. The characters are
    // stored in str, and \0 is added as the last
    // element of the array
}

