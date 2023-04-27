//
//  main.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 03.04.2023.
//

import Foundation

let sharpCode = """
int a = 10;
string b = "20";
char abs = "c";
print abs;
int count = 0;
int something() {
    print "Hello";
}
print "\nTest calling function that prints Hello";
something();
int c = 10;
print "\nTest: 10 + 10:";
print a + c;
int[] arr = { 1, 2, 3, 2, 3, 4 };
print "\nTest arr = [1, 2, 3, 2, 3, 4]:";
print arr;
print "\nTest o[1]:";
print arr[1];
print "\nTest changing arr[1] to 20:";
arr[1] = 20;
print arr[1];

class Some {}

class Something: Some {
    int[] test() {
        print("Testttt");
    }
}

bool testBool = true;
bool testBool2 = false;

if (testBool && testBool2) {
    print "Here";
} else {
    print "Here 2";
}

print("\nTest calling Class method");
Something().test();

class Second: Something {}
"""


try Language.run(source: sharpCode)
//try Lox.runPrompt()
//try Lox.runFile(path: "testCode.txt")
