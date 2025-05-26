package grayCodes;

public class Gray {
    private int n;
    private int total = 0; // Total number of solutions
    private long startTime, endTime;
    private boolean[] used;
    private int[] seq; // Sequence of the current step

    /**
     * Constructor
     * @param n The length of bits making the range [0,1<<n -1] => [0, 2^n - 1]
     */
    public Gray(int n) {
        this.n = n;
        used = new boolean[1 << n]; // 1 << n is a bit displacement = to 2^n
        seq = new int[(1 << n) + 1];  // +1 to check wrap-around (of the first number)
    }
    
    /**
     * Generates and prints all the possible results
     */
    public void generateAll() {
        seq[0] = 0; // First number is always 0
        used[0] = true;
        startTime = System.currentTimeMillis();
        backtrack(1);
        endTime = System.currentTimeMillis();
        System.out.printf("Generated %d sequences in %d ms.%n", total, endTime - startTime);
    }

    /**
     * I used backtracking as you need to find all possible solutions to a given problem, so you need to expand all branches
     * @param idx Current bit index
     */
    private void backtrack(int idx) {
        if (idx == (1 << n)) { // If last index
            // check wrap-around: last to first differ by 1 bit
            if (Integer.bitCount(seq[idx - 1] ^ seq[0]) == 1) { // Valid solution (using bit xor ^ if they are the same is 0 different 1)
                total++;
                printSequence();
            }
            return;
        }
        for (int b = 0; b < n; b++) { // Moving mask of 1 bit, that moves to all possible bits
            int prev = seq[idx - 1];
            int next = prev ^ (1 << b); // Flips bit b
            if (!used[next]) { // Checks if its used
                used[next] = true;
                seq[idx] = next;
                backtrack(idx + 1);
                used[next] = false;
            }
        }
    }

    /**
     * For printing the results
     */
    private void printSequence() {
        System.out.print("[");
        for (int i = 0; i < (1 << n); i++) { // binary:
            String bin = String.format("%" + n + "s", Integer.toBinaryString(seq[i])).replace(' ', '0'); // Used to replace the space of %ns into 0s
            System.out.print(bin + (i+1 < (1<<n) ? ", " : "")); // If is the last index i+1 = 1<<n
        }
        System.out.print("] --> [");
        for (int i = 0; i < (1 << n); i++) { // decimal:
            System.out.print(seq[i] + (i+1 < (1<<n) ? ", " : "")); // Separator if needed
        }
        System.out.println("]");
    }

    /**
     * Start of the program
     * @param args length of the input
     */
    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("You miss the param n for the length of the array.");
            return;
        }
        int n = Integer.parseInt(args[0]);
        if (n < 1 || n > 5) {
            System.err.println("n should be between 1 and 5"); // 5 takes a lot of time, imagine 6 (You can remove the constraint, but for being ecofriendly don't do it)
            return;
        }
        Gray g = new Gray(n);
        g.generateAll();
    }
}