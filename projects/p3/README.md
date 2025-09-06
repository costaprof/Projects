Simple Shell/Job Control with Background Process Management

This is a lightweight shell program written in C++. It allows users to execute commands and manage background processes.

**Features:**

* Executes commands in the foreground or background.
* Stops and continues background processes using `stop` and `cont` commands.
* Lists currently running background processes.
* Handles child process termination with informative messages.
* Catches `SIGTSTP` and `SIGCHLD` signals for better process management.

**How to Use:**

1. Compile the program. You will need a C++ compiler that supports C++11 features (like `std::vector` and `std::string`).
2. Run the program.
3. Enter commands at the prompt (`%`).
4. Valid commands include:
    * Any executable program (e.g., `ls`, `cat`, `gcc`).
    * `exit`: Terminate the shell.
    * `stop <pid>`: Stop a background process with the specified process ID (PID).
    * `cont <pid>`: Continue a stopped background process with the specified PID.
    * Commands can be run in the background by adding `&` at the end.

**Example Usage:**

```
% ls
jobkontrolle.cpp  README.md
% g++ jobkontrolle.cpp -o jobkontrolle
Background processes IDs are:
PID: 1357
% ls
jobkontrolle.cpp  README.md  jobkontrolle
% stop 1357
Process stopped successfully
% cont 1357
Process number: 1357 Continues!
% exit
Sure you want to exit? (1/0)
1
```

**Notes:**

* This is a basic shell program and lacks many features of a full-fledged shell.
* It does not handle redirection (e.g., `<`, `>`) or pipes (`|`).
* Be cautious when stopping and continuing background processes, as it can affect program behavior.

**Disclaimer:**

This code is provided for educational purposes only. It may contain bugs or limitations. Use it at your own risk.
