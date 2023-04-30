# C Family Language using AST approach (DEMO)

This is my attempt to create a C family programming language. The language itself has simple syntax similar to C#.

The approach is taken from the book Crafting Interpriters by Robert Nystrom.

You are very welcomed to contribute.

## Features
- [x] C type support (int, string, double, etc.)
- [x] Arrays support
- [x] Inheritance support
- [x] Reversed polish notation printer
- [x] C++ converter

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
WriteLine("Test 1");
```

**If-else statement**
```cs
bool testBool = true;
bool testBool2 = false;

if (testBool && testBool2 || false) {
    WriteLine("if went to true");
} else {
    WriteLine("if went to false");
}
// prints: if went to false
```

**Function declaration/call**

_Note_: you can declare functions with type int, string etc., but there is no return handling there yet.
```cs
void something() {
    WriteLine("Hello");
}
something(); // prints "Hello"

// ...
int something1() {}
string[] something2() {}
// ...
```

**Class declaration/ Inheritence**

_Note_: there is no proper init handling yet.
```cs
class Some {
    int sum(int a, int b) {
        return a + b;
    }
}

class Something: Some {
    void test() {
        WriteLine("Calling parent class method:");
        int sumResult = base.sum(10, 5);
        WriteLine(sumResult);
    }
}
Something().test();
// Calling parent class method:
// 15
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
- `=`
- `+=`
- `-=`
- `/=`
- `*=`
- `()`
- `!=`
- `!`
- `<`
- `<=`
- `>`
- `>=`
- `==`

## Error Handling

The programm handles a variety of possible errors.

Here are some of them:

- `Syntax errors`
- `Type errors`
- `Index out of range`
- `Unnown variable`


## Preview

You can manage print options in Language file.

```swift
try interpreter.interpret(statements: statements, isPrintable: true)

try ast.printNodes(statements)
try rpn.printNodes(statements)
try cplusPrinter.printCode(statements)
```

- `interpreter` handles runtime errors, performs the calculations and prints the result. If you dont want to see the results put `isPrintable` to false.
- `ast` - representation of nodes of our language tree
- `rpn` - reversed polish notation
- `cplusPrinter` - C++ converter


**Input code**
```cs
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
WriteLine("Printing arr = [1, 2, 3, 2, 3, 4]:");
WriteLine(arr);
WriteLine("Printing arr[1]:");
WriteLine(arr[1]);
WriteLine("Changing arr[1] to 20:");
arr[1] = 20;
WriteLine(arr[1]);

bool testBool = true;
bool testBool2 = false;

if (testBool && testBool2 || false) {
    WriteLine("if went to true");
} else {
    WriteLine("if went to false");
}

int count1 = 2;
while (count < 5) {
    count += 1;
    count1 *= 2;
}
WriteLine(count);
WriteLine(count1);

class Some {
    int sum(int a, int b) {
        return a + b;
    }
}

class Something: Some {
    void test() {
        WriteLine("Calling parent class method:");
        int sumResult = base.sum(10, 5);
        WriteLine(sumResult);
    }
}
Something().test();
```

**Interpreter Result**

```cs
Test calling function that prints Hello
Hello
Test: 10 + 10:
30
Printing arr = [1, 2, 3, 2, 3, 4]:
[1, 2, 3, 2, 3, 4]
Printing arr[1]:
2
Changing arr[1] to 20:
20
if went to false
5
64
Calling parent class method:
15
```

**AST Printer**

```cs
int a = 10
a = 20
string b = "20"
char abs = "c"
int count = 0
void something () (((PRINT "Hello")) )
(PRINT "Test calling function that prints Hello")
something CALL
int c = 10
(PRINT "Test: 10 + 10:")
(PRINT a + c)
int[] arr = ( ARRAY LENGTH(6) 1 2 3 2 3 4 )
(PRINT "Printing arr = [1, 2, 3, 2, 3, 4]:")
(PRINT arr)
(PRINT "Printing arr[1]:")
(PRINT GET arr INDEX(1))
(PRINT "Changing arr[1] to 20:")
arr INDEX(1) = 20
(PRINT GET arr INDEX(1))
bool testBool = true
bool testBool2 = false
IF false || testBool2 && testBool THEN ( (PRINT "if went to true") ) ELSE ( (PRINT "if went to false") ) END
int count1 = 2
WHILE count < 5 DO ( count += 1 count1 *= 2 ) END
(PRINT count)
(PRINT count1)
( CLASS Some (int sum (int a int b) (((RETURN a + b)) )) )
( CLASS Something < PARENTCLASS Some (void test () (((PRINT "Calling parent class method:")) (int sumResult = BASE.sum 10 5 CALL) ((PRINT sumResult)) )) )
Something CALL test CALL
```

**RPN AST**

```cs
a 10 = int
a 20 =
b "20" = string
abs "c" = char
count 0 = int
something () void ((("Hello" PRINT)) )
("Test calling function that prints Hello" PRINT)
something CALL
c 10 = int
("Test: 10 + 10:" PRINT)
(a c + PRINT)
arr ( 1 2 3 2 3 4 LENGTH(6) ARRAY ) = int[]
("Printing arr = [1, 2, 3, 2, 3, 4]:" PRINT)
(arr PRINT)
("Printing arr[1]:" PRINT)
(arr INDEX(1) GET PRINT)
("Changing arr[1] to 20:" PRINT)
arr INDEX(1) 20 =
(arr INDEX(1) GET PRINT)
testBool true = bool
testBool2 false = bool
IF false testBool2 testBool && || THEN ( ("if went to true" PRINT) ) ELSE ( ("if went to false" PRINT) ) END
count1 2 = int
WHILE count 5 < DO ( count 1 += count1 2 *= ) END
(count PRINT)
(count1 PRINT)
( Some CLASS (sum (a int b int) int (((a b + RETURN)) )) )
( Something CLASS < Some PARENTCLASS (test () void ((("Calling parent class method:" PRINT)) (sumResult BASE.sum 10 5 CALL = int) ((sumResult PRINT)) )) )
Something CALL test CALL
```

**C++ Converter**

```cpp
int a = 10;
a = 20;
string b = "20";
char abs = "c";
int count = 0;
void something() {
    std::cout << ("Hello");
}

std::cout << ("Test calling function that prints Hello");
something();
int c = 10;
std::cout << ("Test: 10 + 10:");
std::cout << (a + c);
int arr[6] = {1, 2, 3, 2, 3, 4};
std::cout << ("Printing arr = [1, 2, 3, 2, 3, 4]:");
std::cout << (arr);
std::cout << ("Printing arr[1]:");
std::cout << (arr[1]);
std::cout << ("Changing arr[1] to 20:");
arr[1] = 20;
std::cout << (arr[1]);
bool testBool = true;
bool testBool2 = false;
if (((testBool && testBool2) || false)) {
    std::cout << ("if went to true");
} else {
    std::cout << ("if went to false");
}
int count1 = 2;
while (count < 5) {
    count += 1;
    count1 *= 2;
}
std::cout << (count);
std::cout << (count1);

class Some {
public:
    int sum(a, b) {
        return a + b;
    }

};


class Something : public Some {
public:
    void test() {
        std::cout << ("Calling parent class method:");
        int sumResult = Some::sum(10, 5);
        std::cout << (sumResult);
    }

};

Something().test();
```
