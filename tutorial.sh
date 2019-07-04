#!/bin/sh
# A shebang ^ indicates which shell should be used to run the script

## Basics

# Whitespace-separated arguments passed to echo are each printed successively, each separated with a SINGLE space
echo Hello World 1

# Excessive whitespace is ignored
echo Hello           World        2

# Quotes can be used to preserve whitespace
echo "Hello           World        2"

echo "Other 'hello' examples:"
echo "Hello      World"
echo "Hello World"
echo "Hello * World"
echo Hello * World
echo Hello      World
echo "Hello" World
echo Hello "     " World
echo "Hello "*" World"
echo `hello` world
echo 'hello' world

## Variables

# Note: 'VAR = test' is invalid syntax
# That ^ is interpreted as calling the function 'VAR' with arguments '=' and 'test'
# This makes sense - how could you disambiguate that ^ situation from a variable assignment?
VAR=test
echo "Variable:" $VAR

# echo "Enter value:"
# read READ_VAR
# echo "Read var:" "$READ_VAR"

# Undefined variable references are converted to empty strings
# Note: no error is thrown
echo "Undeclared var:" "$UNDECLARED_VAR"

# Curly braces are necessary when referencing a variable and adding a suffix
# Otherwise $READ_VAR-suffix would try to reference the undefined variable 'READ_VAR-suffix'
# Again, makes sense; how would you disambiguate that ^ situation from the situation where the suffix is wanted?
echo "String interpolation: ${READ_VAR}-suffix"

# Note the necessity for quotes; if the variable value had a space in it, the result of the dereference would be two values separated by a space, not a single value

# Erroneous: if READ_VAR has a space, will pass 2 arguments, not 1
# Example: touch file name.txt --> creates 2 files, not 1
# touch ${READ_VAR}.txt

# Note: variables are 'typeless', though in truth they are all stored as strings internally

## Wildcards

# A '*' character is (sort of) substituted with a list of matching values

# Lists all files with a '.txt' extension
echo "ls *.txt:"
ls *.txt
echo "echo *:"

# Lists all files in the current directory
echo *

## Escape Characters

# Most characters are not interpreted when surrounded by quotes
# Exceptions are: '"', '`', '\' and '$'
# Each has a special purpose, and to be used literally, it must be escaped with a backslash

# Aside
echo "Single "Param""

echo "A string with quotes \"\""

## Loops

# A for-loop iterates through a list of space-separated values, which need not be of a consistent type
echo "For loop:"
for i in 1 2 3 4 5
do
    echo "${i}"
done

echo "Mixed-type for loop:"
for i in 1 2 * something "else"
do
    echo "${i}"
done

# A while-loop iterates as long as a condition is true
echo "While loop:"
# INPUT=""
# while [ "${INPUT}" != "bye" ]
# do
#     echo "Enter something, or \"bye\" to quit"
#     read INPUT
#     echo "Got: ${INPUT}"
# done

# Note: ':' always evaluates to true
echo "Infinite while loop:"
# while :
# do
#     echo "Enter something, or ^C to quit"
#     read INPUT
#     echo "${INPUT}"
# done

# Lines can be read from a file by passing the file path to a while loop using '<', and using 'read' in the condition
# Note: in the file, each line must end with a newline, including the last
echo "While loop file-read:"
while read l
do
    echo "${l}"
done < test.txt

echo "Bash iteration trick (not bourne shell):"
# ls {/usr,/usr/local}/{bin,sbin,lib} # Note the recursion

## Test

# Note: '[' is symbolically linked to the 'test' command
# Like other commands, the arguments must be space-separated

# Note: '=' should be used to compare strings, '-eq', to compare integers
# Some comparison operations only support integers, not strings
echo "If statement:"
if [ "string1" = "string1" ]
then
    echo "Inside if"
fi # Note: 'fi' is 'if' spelled backwards

# Note: in general, a semicolon can be used to join 2 separate lines, while still interpreting them as 2 separate lines
echo "Semicolon if statement:"
if [ "string1" = "string1" ]; then
    echo "Inside semicolon if"
fi

echo "Else if example:"
STR="string3"
if [ "${STR}" = "string1" ]
then
    echo "Inside if"
elif [ "${STR}" = "string2" ]
then
    echo "Inside else if"
else
    echo "Inside else"
fi

# Note: '\' can be used to separate a single line into 2 separate lines, while still interpreting them as a single line (the opposite to the semicolon)
echo "One-line if statement:"
[ 0 -gt 1 ] \
    && echo "true" || echo "false"

echo "Type violation in test:"
[ "something" -gt 1 ] && echo "sure?"

## Case
VAR=test
case $VAR in
    test1)
        echo "Test 1 case"
        ;;
    test2)
        echo "Test 2 case"
        ;;
    *)
        echo "Default case"
        ;;
esac # Note: 'esac' is 'case' spelled backwards

## Variables II
echo "Script called with $# parameters"
echo "Script name:" $(basename "$0")
echo "Parameter 1:" "$1"
echo "Parameter 2:" "$2"
echo "All params (w/ whitespace):" "$@"
echo "All params (w/out whitespace):" "$*"

# You can process more than 9 parameters using the $1..$9 variables by using `shift`
# It will move the second parameter from $2 to $1, the third parameter from $3 to $2, &c
# When $# if 0, all the parameters have been shifted
while [ ! "$#" -eq 0 ]
do
    echo "\$1:" "$1"
    shift
done

# Note: be careful with this one
# Intermediate shell commands can modify it (like 'if', &c)
# If you want to check the exit status of a particular command, you need to store it in a variable immediately after the command has finished
cat "/some/file.ext"
if [ "$?" -ne "0" ]; then
    echo "Command failed"
fi

echo "PID of this shell:" "$$"
echo "PID of last-run background process:" "$!"

# Note: when modifying a pre-defined variable like IFS, you should back up the original value, and restore it
OLD_IFS="$IFS" # Note: the quotes are recommended to preserve potential whitespace
IFS=,
#echo "Input comma-separated data:"
#read a b c
IFS="$OLD_IFS"
#echo "a: $a, b: $b, c: $c"

## Variables III
VAR=""

# Default values can be specified, and will be used if the given variable is undefined/empty
echo "Default value: ${VAR:-default1}"

# To assign the given variable to the given default value:
echo "Persistent default value: ${VAR:=default2}"
echo "(Persists: $VAR)"

## External Programs

# Backticks capture the stdout from executing the given command
VAR=`echo test`
echo "Backtick-ed output: $VAR"

## Functions

# Functions can be defined locally in the current script, or externally in a different script and sourced in the current script (using '.')

# Note: a shell function cannot change it's parameters, but it can change externally-defined variables
# Also note: the body of the function is not executed until the function is called
test_function()
{
    # Within the function body, certain environment variables ($1..$9, &c) are overwritten (for the scope of the function)
    echo "\$1 is $1"
    echo "\$2 is $2"
    EXTERNAL_VAR=1
}

EXTERNAL_VAR=0
test_function "a" "b"
echo "External var updated: $EXTERNAL_VAR"

# A function is called in a subshell if it's output is piped to another command, in which case, changes to external variables will not be persistent
EXTERNAL_VAR=0
test_function | grep something
echo "External var not updated: $EXTERNAL_VAR"

recursive_function()
{
ITERATIONS="$1"
if [ $ITERATIONS -gt 0 ]; then
    echo "Remaining iterations: $ITERATIONS"
    recursive_function $((ITERATIONS - 1))
else
    return # Used to exit the function and return the given value (in this case, nothing)
fi
}

recursive_function 5

cat /some/random/nonexistent/file.ext
echo "Exit status: $?"
echo "Another command.."
if [ ! $? -eq 0 ]; then
    echo "Expected exit status"
else
    echo "Unexpected exit status"
fi

cat /some/random/nonexistent/file.ext
STORED_EXIT_STATUS=$?
echo "Another command.."
if [ ! $STORED_EXIT_STATUS -eq 0 ]; then
    echo "Expected exit status"
else
    echo "Unexpected exit status"
fi
