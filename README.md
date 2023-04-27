# Custom C Family Language using AST approach (DEMO)

The approach is taken from the book Crafting Interpriters by Robert Nystrom.
 
### Project is in progress...

## Features
- [x] Type support (int, string, double, etc.)
- [x] Array support
- [x] Reversed polish notation print

## Syntax

**Variable declaration**
```cs
int a = 10;
string b = "string example";
char c = "c";
double d = 10.3;
float f = 10.3;
bool e = true;
int[] arr1 = {1, 2, 3, 4};
double[] arr2 = {1.0, 2.0, 3.0, 4.0};
float[] arr3 = {1.0, 2.0, 3.0, 4.0};
string[] arr4 = {"1", "2", "3", "4"};
char[] arr5 = {"1", "2", "3", "4"};
bool[] arr6 = {true, false, true, false};
```

**Print**
```cs
print "Test 1";
print("Test 2");
```

**If-else statement**
```cs
bool testBool = true;
bool testBool2 = false;

if (testBool && testBool2) {
    print "Here";
} else {
    print "Here 2";
}
```

**Function declaration/call**

_Note_: you can declare functions with type int, string etc., but there is no return handling there yet.
```cs
void something() {
    print "Hello";
}
something(); // prints "Hello"
```

**Class declaration/ Inheritence**

_Note_: there is no proper init handling yet. Calling parent method is no fully supported yet.
```cs
class Some {}
class Something: Some {
    void test() {
        print("Hello, World");
    }
}
Something().test(); // prints "Hello, World"
```

**While loop**
```cs
int count = 0;
while (count < 5) {
    count = count + 1;
}
```

## Supported operators

- `+`
- `-`
- `*`
- `/`
- `()`
- `!=`
- `!`
- `<`
- `<=`
- `>`
- `>=`
- `==`

## Preview

```swift
let code = """
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
print "\nTest arr = [1, 2, 3, [2, 3, 4]]:";
print arr;
print "\nTest o[1]:";
print arr[1];
print "\nTest changing arr[1] to 20:";
arr[1] = 20;
arr[2] = {1, 2, 3};
print arr[2];

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

try Language.run(source: code)
```

**RPN AST**
```cs
a 10.0 = int
b 20 = string
abs c = char
abs print
count 0.0 = int
something () int (Hello print)

Test calling function that prints Hello print
something _call_ 
c 10.0 = int

Test: 10 + 10: print
a c + print
arr ( 1.0 2.0 3.0 2.0 3.0 4.0 _(6)array_ ) = intArray

Test arr = [1, 2, 3, 2, 3, 4]: print
arr print

Test o[1]: print
arr 1.0 _get_ print

Test changing arr[1] to 20: print
arr 1.0 20.0 _set_ 
arr 1.0 _get_ print
(Some _class_)
(Something _class_ < Some test () intArray (Testttt _group_ print))
testBool true = bool
testBool2 false = bool
testBool testBool2 && (Here print) (Here 2 print) _if-else_
count 5.0 < (count 1.0 + count = ) while

Test calling Class method _group_ print
Something _call_ test _method_ _call_ 
(Second _class_ < Something)
```

**Result**
```cs
c

Test calling function that prints Hello
Hello

Test: 10 + 10:
20

Test arr = [1, 2, 3, 2, 3, 4]:
[1, 2, 3, 2, 3, 4]

Test o[1]:
2

Test changing arr[1] to 20:
20
Here 2

Test calling Class method
Testttt
```

