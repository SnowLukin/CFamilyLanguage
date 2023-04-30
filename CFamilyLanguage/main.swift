//
//  main.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 03.04.2023.
//

import Foundation

let sharpCode = """
int a = 10;
a = 20;
string b = "20";
char abs = "c";

int count = 0;
void something() {
    WriteLine("Hello");
}

WriteLine("Test calling function that prints Hello");
something();
int c = 10;
WriteLine("Test: 10 + 10:");
WriteLine(a + c);
int[] arr = { 1, 2, 3, 2, 3, 4 };
WriteLine("Test arr = [1, 2, 3, 2, 3, 4]:");
WriteLine(arr);
WriteLine("Test o[1]:");
WriteLine(arr[1]);
WriteLine("Test changing arr[1] to 20:");
arr[1] = 20;
WriteLine(arr[1]);

class Some {}

class Something: Some {
    int[] test() {
        WriteLine("Testttt");
    }
}

bool testBool = true;
bool testBool2 = false;

if (testBool && testBool2) {
    WriteLine("Here");
} else {
    WriteLine("Here 2");
}

int count1 = 2;
while (count < 5) {
    count += 1;
    count1 *= 2;
}
WriteLine(count);
WriteLine(count1);

Something().test();

class Second: Something {
    void run() {
        base.test();
    }
}
"""


try Language.run(source: sharpCode)
//try Lox.runPrompt()
//try Lox.runFile(path: "testCode.txt")
