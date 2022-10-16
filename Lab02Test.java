import org.junit.*;

import static edu.gvsu.mipsunit.munit.MUnit.Register.*;
import static edu.gvsu.mipsunit.munit.MUnit.*;

public class Lab02Test{
    
    // Test empty - not a great test but checks if the array has been messed about
    @Test(timeout=2000)
    public void verify_empty() {
        Label test_array = wordData(1,3,5,7);
        run("swapArray", test_array, 0);
        int[] expected = {1, 3, 5, 7};
        int[] observed = getWords(test_array, 0, 4);
        Assert.assertArrayEquals(expected, observed);
        Assert.assertTrue(noOtherMemoryModifications());
    }

    // Test array of size 2
    @Test(timeout=2000)
    public void verify_size2() {
        Label test_array = wordData(2, 1, 3);
        run("swapArray", test_array, 2);
        int[] expected = {1, 2, 3};
        int[] observed = getWords(test_array, 0, 3);
        Assert.assertArrayEquals(expected, observed);
        Assert.assertTrue(noOtherMemoryModifications());
    }
	
    // Test array of size 10
    @Test(timeout=2000)
    public void verify_size10() {
        Label test_array = wordData(5, 6, 7, 8, 9,   0, 1, 2, 3, 4);
        run("swapArray", test_array, 10);
        int[] expected = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
        int[] observed = getWords(test_array, 0, 10);
        Assert.assertArrayEquals(expected, observed);
        Assert.assertTrue(noOtherMemoryModifications());
    }
}
