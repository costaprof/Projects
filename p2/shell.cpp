#include <iostream>
#include <unistd.h>
#include <stdio.h>
#include <cstring>
#include <sys/wait.h>
#include <vector>
#include <errno.h>
using namespace std;

#define maxInputSize 200

int main() {
    vector <pid_t> backgroundPIDs;
    
    while(true) {
        cout<<"%";
        char input[maxInputSize] = {0};
        fgets(input, maxInputSize, stdin);
        
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
	    cerr<<"Invalid Input, please check again"<<endl;
            exit(EXIT_FAILURE);
        }
        
        else {
            if(runInBackground){
                backgroundPIDs.push_back(pid);
                cout<<"Background processes IDs are: "<<endl;
                for(pid_t bPid: backgroundPIDs) {
                    cout<<"PID: "<<bPid<<endl;
                }
            }
            
            else {
                int status;
                pid_t result = waitpid(pid, &status, 0);
                if(result == -1) {
                    if(errno == ECHILD) {
                        cerr << "No child processes" << endl;
                    }
                    else if(errno == EINTR) {
                        cerr << "Waitpid was interrupted by a signal" << endl;
                    }
                    else {
                        perror("waitpid failed");
                    }
                }
                else {
                    if(WIFEXITED(status)) {
                        int exitStatus = WEXITSTATUS(status);
                        cout << "Process exited with status: " << exitStatus << endl;
                    }
                    else if(WIFSIGNALED(status)) {
                        int signalNumber = WTERMSIG(status);
                        cout << "Process was terminated by signal: " << signalNumber << endl;
                    }
                }
            }
        }

        cout<<"Current Proccess ID: "<<pid<<endl;
        cout<<endl;
    }
    return 0;
}

