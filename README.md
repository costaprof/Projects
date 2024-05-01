C++ Environment Variable Reader

This program reads environment variables from a file named "env.txt". The file should contain environment variables in the format KEY=VALUE.
Functionality

The program provides four functionalities based on the command-line arguments:

    Print Variable Value (Default):
        Takes a single argument as the variable name.
        Prints the value of the specified variable if it exists in the file.
        Example: ./program VAR_NAME

    Print Variable Name ( -n flag):
        Takes two arguments:
            The first argument is the -n flag.
            The second argument is the variable name.
        Prints only the name (key) of the variable if it exists in the file.
        Example: ./program -n VAR_NAME

    Case-Insensitive Search with Value ( -i flag):
        Takes two arguments:
            The first argument is the -i flag.
            The second argument is the variable name (case-insensitive search).
        Prints the entire line containing the variable if it exists in the file (case-insensitive match).
        Example: ./program -i var_name

    Case-Insensitive Search with Name ( -n and -i flags):
        Takes three arguments:
            The first argument can be either -n or -i (order does not matter).
            The second argument is the other flag (-n or -i).
            The third argument is the variable name (case-insensitive search).
        Prints only the name (key) of the variable if it exists in the file (case-insensitive match).
        Example: ./program -n -i VAR_NAME or ./program -i -n VAR_NAME

Error Handling

The program handles the following errors and exits with an error code:

    Missing argument after a flag (-n or -i).
    Invalid number of arguments provided.
    Unable to open the "env.txt" file.

How to Use

    Compile the code using a C++ compiler (e.g., g++).
    Run the program with the desired arguments as described above.

Example:

./program VAR_NAME         # Prints the value of VAR_NAME (default behavior)
./program -n VAR_NAME      # Prints the name of VAR_NAME
./program -i var_name      # Prints the line containing var_name (case-insensitive)
./program -n -i VAR_NAME   # Prints the name of VAR_NAME (case-insensitive, flag order doesn't matter)