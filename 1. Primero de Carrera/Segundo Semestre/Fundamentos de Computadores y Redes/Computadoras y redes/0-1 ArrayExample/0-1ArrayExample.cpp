#include <iostream> // Obligatorio para imprimir cositas

using std::cout; // Util para no tener que volver a nombrarlo
using std::endl; // Si no se ponen tendrías que en cada vez que sale endl, poner -> std::endl

// Function: AddDifferent
// Add in destination[i] the elements of source that are different from destination.
// The number of elements in both arrays is supposed to be equal.
// Return in added the number of elements added.

void AddDifferent(int source[], int destination[], int arrayLength, unsigned int &added)
{
  unsigned int i;

  added = 0;
  for (i = 0; i < arrayLength; i++)
  {
    if (source[i] != destination[i]) 
    {
      destination[i] = source[i] + destination[i];
      added++;
    }
  }
}

// Prints in one line the name and the elements of the array
void PrintArray(char name[], int array[], unsigned int length)
{
  cout << name << ": ";

  unsigned int i;
  for (i = 0; i < length; i++)
  {
      cout << array[i] << " ";
  }
  cout << endl;
}

int main()
{
  unsigned int added = 0;
  const unsigned int arrayLength = 5;
  int array1[arrayLength] = {34, 12, 56, 17, 99};
  int array2[arrayLength] = {-8, 9, 56, 38, 99};

  char identArray1[] = "array1";
  char identArray2[] = "array2";

  PrintArray(identArray1, array1, arrayLength);
  PrintArray(identArray2, array2, arrayLength);

  AddDifferent(array1, array2, arrayLength, added);
  cout << "After adding different elements:" << endl;
  PrintArray(identArray2, array2, arrayLength);
  cout << "Elements added " << added << endl;

  return 0;
}