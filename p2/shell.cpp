#include <iostream>
#include <unistd.h> // Include the header file for fork
#include <stdio.h>
#include <cstring>
#include <sys/wait.h>

using namespace std;

#define maxInputSize 200

int main() {
    int parenPID = getpid();

    while(true) {
        //cout<<endl;
        cout<<"%";
        char input[maxInputSize] = {0 };
        fgets(input, maxInputSize, stdin);
        // remove trailing new line if present
        input[strcspn(input, "\n")] = 0;
        if(strcmp(input, "exit") == 0) break;
        bool runInBackground = false;
        int inputLength = strlen(input);
        if(inputLength > 0 && input[inputLength - 1] == '&'){
            input[inputLength - 1]= '\0';
            runInBackground = true;
        }
        char *p = strtok(input, " ");
        char *inputTokenized[maxInputSize];
        int i = 0;
        while (p) {
            inputTokenized[i++] = p;
            p = strtok(NULL, " ");
        }

        inputTokenized[i] = NULL;

        pid_t pid = fork();
        if(pid == -1) {
            perror("fork failed");
            exit(EXIT_FAILURE);
        }
        else if(pid==0) {
            execvp(inputTokenized[0], inputTokenized);
            perror("execvp failed");
            exit(EXIT_FAILURE);
        }

        else {
            if(!runInBackground) {
                int status;
                waitpid(pid, &status, 0);
            }
        }
        cout<<endl;
    }
    return 0;
}
