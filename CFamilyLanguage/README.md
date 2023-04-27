# Custom C Family Language using AST approach

The approach is taken from the book Crafting Interpriters by Robert Nystrom.
 
### Project is in progress...

## Features
- [x] Type support (int, string, double, etc.)
- [x] Array support
- [x] Reverced polish notation print

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

