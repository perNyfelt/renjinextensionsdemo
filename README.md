# Renjin extensions demo
Sample code for how to create extensions in Renjin (an R implementation for the JVM)

See http://docs.renjin.org/en/latest/writing-renjin-extensions.html for a general overview.

Here are 3 examples of extensions in Renjin ranging from simple to slightly more involved.
None of them are complex in terms of functionality but should be enough to make you easily grasp
how to do it (especially after reading the docs mentioned above).

Please refer to the mailing list at https://groups.google.com/forum/#!topic/renjin-dev if you have questions.

These examples are heavily indebted to Dr. Parham Solaimani who provided detailed
answers to all my questions on the mailing list mentioned above.
 
## Simple example

Lets say we wanted to create a meantrim function that takes a vector as argument and trims off the min and max values first. i.e.
    
    meantrim <- function(x) {
      x <- x[x != max(x)]
      x <- x[x != min(x)]
      return(mean(x))
    }
    # Example:
    vec <- c(2.3, 2.7, 3.1, 4.9, 1.0, 2.4, 2.6, 2.1, 2.0, 1.9)
    print(paste("mean is ", mean(vec)))
    [1] "mean is  2,5"
    print(paste("meantrim is ", meantrim(vec)))
    [1] "meantrim is  2,3875"

1. Create the files src/main/R/meantrim.R and src/test/R/test.meantrim.R
1. In meantrim.R write your function:
    ````
    meantrim <- function(x) {
        x <- x[x != max(x)]
        x <- x[x != min(x)]
        mean(x)
    }
    ````
1. In the test.meantrim.R write your tests using Renjins hamcrest package:
    ````
    library("com.mydomain:meantrim")
    library("hamcrest")
    assertThat(meantrim(1:10), identicalTo(5.5))
    ````
1. Create the NAMESPACE file and export your function
    ````
           export(meantrim)
    ````
1. Copy the example pom.xml and change the groupId and artefactId to match your pom 
(e.g. "com.mydomain" and "meantrim"), respectively.
Your extension/package folder should now look like this:

    ````
    pom.xml
    NAMESPACE
    src
    |-- main
    |    |-- R
    |        |- meantrim.R
    |-- test
         |-- R
             |- test.meantrim.R  
    ````
1. Now you can do ``mvn test`` to test your package and ``mvn package`` to create the binary jar file from your package 
which will be stored in your "target" folder you can now import this package in your Renjin session and use it

## Slightly more complex example
A more involved example would be something where we have a java class that does something useful and we want to take advantage of that in an  R function

e.g. we have the Java class

    public class StringTransformer {
      
      /** strips off any non numeric char from the string. */
      public static String toNumber(String txt) {
        StringBuilder result = new StringBuilder();
        txt.chars().mapToObj( i -> (char)i )
        .filter( c -> Character.isDigit(c) ).forEach( c -> result.append(c) );
        return result.toString();
      }
      
    }  

and we want to make a library which has a function called "makeNumeric" which uses the StringTransformer.toNumber() functionality.

1. Following the documentation about importing java classes: http://docs.renjin.org/en/latest/importing-java-classes-in-r-code.html
1. Create src/main/java/ 
1. Create StringTransformer.java:

    ````
    package transformers;
    public class StringTransformer {
    
      public static String toNumber(String txt) {
        StringBuilder result = new StringBuilder();
        txt.chars().mapToObj(i -> (char) i)
          .filter(c -> Character.isDigit(c))
          .forEach(c -> result.append(c));
        return result.toString();
      }
    }
    ````
1. Add extractDigits function (to a extractDigits.R file):
    ````
    extractDigits <- function(x) {
        import(transformers.StringTransformer)
        sapply(x, function(txt) StringTransformer$toNumber(txt = txt), USE.NAMES = FALSE)
    }
    makeNumber <- function(x) as.numeric(extractDigits(x))
    ````
1. Add test case to test.extractDigits.R file:
    ````
    library("se.alipsa:makenumeric")
    library("hamcrest")
    
    test.extractDigits <- function() {
        assertThat(extractDigits(c("5", "6Y8", "He", "02")), identicalTo(c("5", "68", "", "02")))
        assertThat(extractDigits("56Y8He02"), identicalTo("56802"))
    }
    
    test.makeNumber <- function() {
        expected <- c(5, 68, NA, 2)
        assertThat(makeNumber(c("5", "6Y8", "He", "02")), identicalTo(expected))
        assertThat(makeNumber("234-123-789 12"), identicalTo(23412378912))
    }

    ````
    A small quirk is that when two test functions are defined hamcrest 
    will report 3 tests being run. This is because as you can write assertions directly
    without wrapping them in a function, the "base" itself counts as one test.
1. Export the new functions in your NAMESPACE and use mvn to test and package your extension
    ````
    export(extractDigits)
    export(makeNumber)
    ````
## Overriding functionality
Lets say we want to override (mask) existing functionality .e.g i want to override library() with something that 
guesses the correct package so i can do e.g. library("dplyr") and get the same thing as if I would have written 
library("org.renjin.cran:dplyr"), what do i need to do to make that happen?

- Depending on whether you want to do this inside your package or java application, you need to have a list of CRAN and BioConductor package names and depending in which list the input name resides add to correct prefix to the input and pass that to base::library()

- If you want to do it in your application follow the instructions here: http://docs.renjin.org/en/latest/library/evaluating.html 

