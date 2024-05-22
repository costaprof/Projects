**Shell-like Mini-Interpreter**

This C++ program implements a simple shell-like interpreter that allows users to execute commands and manage background processes.

**Features:**

- Basic command execution
- Background process handling with tracking of process IDs (PIDs)
- User interaction with a prompt (`%`) for input

**Requirements:**

- A C++ compiler that supports C++11 features (specifically, `std::vector` and `std::string`)
- A Unix-like operating system (Linux, macOS, etc.) for system calls like `fork`, `execvp`, and `waitpid`

**Usage:**

1. Compile the program:
   ```bash
   g++ shell.cpp -o shell
   ```
2. Run the executable:
   ```bash
   ./shell
   ```

**Functionality:**

- The program displays a prompt `%` where you can enter commands.
- Enter a command followed by any arguments, separated by spaces.
- To run a command in the background, append an ampersand (`&`) at the end of the command line.
- Type `exit` to terminate the shell.

**Background Processes:**

The program keeps track of background processes using a `std::vector` named `backgroundPIDs`. When a command is run in the background, its PID is added to this vector. You can view the list of currently running background processes by entering any command at the prompt.

**Code Breakdown:**

**Header inclusions:**

- `<iostream>`: Provides input/output functionality (e.g., `cout`, `cin`)
- `<unistd.h>`: Provides access to POSIX operating system functions (e.g., `fork`, `execvp`)
- `<stdio.h>`: Provides basic input/output functions (e.g., `perror`)
- `<cstring>`: Provides string manipulation functions (e.g., `strtok`, `strlen`)
- `<sys/wait.h>`: Provides functions for waiting for child processes (e.g., `waitpid`)
- `<vector>`: Provides the `std::vector` class for dynamic arrays (C++11 feature)

**Macros:**

- `maxInputSize`: Defines the maximum size of user input (200 characters)

**`main` function:**

- Declares a `std::vector` named `backgroundPIDs` to store PIDs of background processes.
- Enters an infinite loop (`while(true)`) to continuously prompt the user for commands:
    - Prints the prompt `%`.
    - Reads user input into a character array `input` using `fgets` with a maximum size of `maxInputSize`.
    - Removes the trailing newline character from the input (if present) using `strcspn`.
    - Checks if the input is `exit`. If so, breaks the loop and terminates the program.
    - Determines if the command should run in the background:
        - If the last character of the input is `&`, sets `runInBackground` to `true` and removes the ampersand from the input string.
    - Tokenizes the input string into an array of arguments using `strtok`.
    - Creates a child process using `fork`:
        - If `fork` fails, exits the program with an error message.
        - **Child process (pid == 0):**
            - Attempts to execute the command using `execvp`.
            - If `execvp` fails, exits the program with an error message.
        - **Parent process (pid > 0):**
            - If the command should run in the background:
                - Adds the child process's PID to the `backgroundPIDs` vector.
                - Prints the list of background process PIDs.
            - Otherwise, waits for the child process to finish using `waitpid`.
    - Prints the current process ID (PID) for informational purposes.

**Additional Notes:**

- Error handling is included with `perror` for `fork` and `execvp` failures.
- The code provides error handling for typos.