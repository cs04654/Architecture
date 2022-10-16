import org.junit.*;

import static edu.gvsu.mipsunit.munit.MUnit.Register.*;
import static edu.gvsu.mipsunit.munit.MUnit.*;

public class Lab03TestPalindrome {

int initStackPtr;  // Keep sp before the call

// This always runs before a test method below
// randomize registers to ensure the code does not depend on simulator initialised values or 
@Before
    public void randomizeAndSetRegs() {
        // randomize registers to ensure the code does not depend on simulator initialised values or 
        //  illegal parameter passing
        randomizeRegisters(v0, v1, t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, k0, k1, a0, a1, a2, a3, ra);
        // Set the saved registers to veryify they are preserved after the function call
        set(s0, 0x123);
        set(s1, 0x124);
        set(s2, 0x125);
        set(s3, 0x126);
        set(s4, 0x127);
        set(s5, 0x128);
        set(s6, 0x129);
        set(s7, 0x12a);
        initStackPtr = get(sp);
    }

// This always runs after a test method below
@After
    public void checkSavedRegs() {
        // check saved registers
        Assert.assertEquals("$s0 should be preserved across subroutine calls", 0x123, get(s0));
        Assert.assertEquals("$s1 should be preserved across subroutine calls", 0x124, get(s1));
        Assert.assertEquals("$s2 should be preserved across subroutine calls", 0x125, get(s2));
        Assert.assertEquals("$s3 should be preserved across subroutine calls", 0x126, get(s3));
        Assert.assertEquals("$s4 should be preserved across subroutine calls", 0x127, get(s4));
        Assert.assertEquals("$s5 should be preserved across subroutine calls", 0x128, get(s5));
        Assert.assertEquals("$s6 should be preserved across subroutine calls", 0x129, get(s6));
        Assert.assertEquals("$s7 should be preserved across subroutine calls", 0x12a, get(s7));
        Assert.assertEquals("$sp should be equal to its value before the call", initStackPtr, get(sp));
    }
    

    @Test(timeout=2000)
    public void verify_empty() {
        Label str1 = asciiData("");
        run("pdrome", str1, 0);
        Assert.assertEquals("Empty strings \'\\0\' are palindromes", 1, get(v0));
    }

    @Test(timeout=2000)
    public void verify_null() {
        run("pdrome", 0, 0);
        Assert.assertEquals("Null string is a palindrome", 1, get(v0));
    }

    // Test string of size 1
    @Test(timeout=2000)
    public void verify_size1() {
        Label str1 = asciiData("a");
        run("pdrome", str1, 1);
        Assert.assertEquals("Any single letter string is a palindrome", 1, get(v0));
    }

    // Test string of size 2
    @Test(timeout=2000)
    public void verify_size2() {
        Label str1 = asciiData("aa");
        run("pdrome", str1, 2);
        Assert.assertEquals("aa is a palindrome", 1, get(v0));
    }

    // Test string of odd size
    @Test(timeout=2000)
    public void verify_odd_size() {
        Label str1 = asciiData("123-321");
        run("pdrome", str1, 7);
        Assert.assertEquals("123-321 is a palindrome", 1, get(v0));
    }

    // Make sure I get 0 for non-palindromes!
    @Test(timeout=2000)
    public void verify_not_palindrome() {
        Label str1 = asciiData("antelona");
        run("pdrome", str1, 8);
        Assert.assertEquals("antelona is not a palindrome", 0, get(v0));
    }

}
