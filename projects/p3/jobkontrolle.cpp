#include <iostream>
#include <unistd.h>
#include <stdio.h>
#include <cstring>
#include <sys/wait.h>
#include <vector>
#include <errno.h>
#include <csignal>
#include <sstream>
#include <algorithm>
using namespace std;

#define maxInputSize 200

vector<pid_t> backgroundPIDs;
vector<pid_t> stopped_bg_Pids;
vector<pid_t> stopped_fg_Pids;
vector<pid_t> notYetFinished;




void handle_sigtstp(int sig) {

    std::cout << "SIGTSTP Caught but Not Stopped\n";
    std::signal(SIGTSTP, handle_sigtstp);
}

bool stopProcess(pid_t pid) {

    if(kill(pid, SIGTSTP) == -1){
        return false;
    }

    return true;
}

int get_pid_index(vector<pid_t> *ids, int id){

    for(pid_t i=0; i<ids->size(); i++){
        if((*ids)[i] == id)
            return i;
    }

    return -1;
}

void continueProcess(vector<pid_t> &ids, pid_t pid, int index){

    kill(pid, SIGCONT);
    ids.erase(ids.begin()+index);
}


void handle_sigchld(int sig) {

    pid_t pid;
    int status;

    while ((pid = waitpid(-1, &status, WNOHANG)) > 0) {

        if (WIFEXITED(status)) {
            cout << "Child process " << pid << " terminated normally with status: " << WEXITSTATUS(status) << endl;

        } else if (WIFSIGNALED(status)) {
            cout << "Child process " << pid << " terminated by signal: " << WTERMSIG(status) << endl;
        }

        auto it = find(backgroundPIDs.begin(), backgroundPIDs.end(), pid);

        if (it != backgroundPIDs.end()) {
            backgroundPIDs.erase(it);
        }

        auto it2 = find(stopped_bg_Pids.begin(), stopped_bg_Pids.end(), pid);

        if (it2 != stopped_bg_Pids.end()) {
            stopped_bg_Pids.erase(it2);
        }

        auto it3 = find(stopped_fg_Pids.begin(), stopped_fg_Pids.end(), pid);

        if (it3 != stopped_fg_Pids.end()) {
            stopped_fg_Pids.erase(it3);
        }
    }
}


void isStillRunning(vector<pid_t> bgIDs) {

    int status;

    for (auto pid : bgIDs) {

        pid_t result = waitpid(pid, &status, 0);

        if(result == 0) {
            notYetFinished.push_back(pid);
        }
    }

    for(auto pid : notYetFinished) {

        int status;
        pid_t result_1 = waitpid(pid, &status, 0);

        if(result_1 == -1) {

            if(errno == ECHILD) {
                cerr << "No child processes" << endl;

            } else if(errno == EINTR) {
                cerr << "Waitpid was interrupted by a signal" << endl;

            } else {
                perror("waitpid failed");
            }

        } else {

            if(WIFEXITED(status)) {
                int exitStatus = WEXITSTATUS(status);
                cout << "Process exited with status: " << exitStatus << endl;

            } else if(WIFSIGNALED(status)) {
                int signalNumber = WTERMSIG(status);
                cout << "Process was terminated by signal: " << signalNumber << endl;
            }

        }
    }
}







int main() {


    pid_t vordergrundProzess = 0;
    pid_t hintergrundProzess = 0;

    while(true) {

        cout<<"%";

        string input;

        getline(cin, input);

        if (input == "exit") {

            isStillRunning(backgroundPIDs);
            int exit;
            cout<<"Sure you want to exit? (1/0)"<<endl;
            cin>>exit;
            if(exit) break;
            else continue;

        } else if(input.find("stop ") == 0){

            string stopCmd = input.substr(5);
            pid_t pid = stoi(stopCmd);
            int index;

            if((index = get_pid_index(&backgroundPIDs, pid)) != -1){

                kill(pid, SIGTSTP);
                backgroundPIDs.erase(backgroundPIDs.begin()+index);
                stopped_bg_Pids.push_back(pid);
                hintergrundProzess = pid;
                cout << "Process number: " << hintergrundProzess << " Stopped!" << endl;

            } else {
                cout << "Prozess nicht gefunden!" << endl;
            }

            continue;
        }

        else if (input.find("cont ") == 0) {

            string contCommand = input.substr(5);
            pid_t pid = stoi(contCommand);
            int index;

            if((index = get_pid_index(&stopped_bg_Pids, pid)) != -1){

                continueProcess(stopped_bg_Pids, pid, index);
                cout << "\nProcess number: " << pid << " Continues!" << endl;

            } else if((index = get_pid_index(&stopped_fg_Pids, pid)) != -1){

                continueProcess(stopped_fg_Pids, pid, index);
                vordergrundProzess = pid;
                cout << "\nProcess number: " << pid << " Continues!" << endl;
                waitpid(pid, nullptr , WUNTRACED);

                continue;
            } else {
                cout << "PID nicht gefunden!" << endl;
                continue;
            }
        }

        bool runInBackground = false;

        if (!input.empty() && input.back() == '&') {
            input.pop_back();
            runInBackground = true;
        }


        vector<string> tokens;
        istringstream iss(input);
        string token;

        while(getline(iss, token, ' ')) {
            tokens.push_back(token);
        }



        if (tokens.empty()) {
            cerr << "Error: Empty command entered." << endl;
            continue;
        }



        vector<char*> argv(tokens.size() + 1);

        for (size_t i = 0; i < tokens.size(); ++i) {
            argv[i] = const_cast<char*>(tokens[i].c_str());
        }

        argv[tokens.size()] = nullptr; // Null terminator



        pid_t pid = fork();

        if(pid == -1) {
            perror("fork failed");
            exit(EXIT_FAILURE);

        } else if(pid == 0) {
            if (setpgid(0, 0) == -1) {
                perror("setpgid failed");
                exit(1);

            } else {
                std::cout << "Process ID: " << getpid() << ", Group ID: " << getpgid(0) << std::endl;
                wait(NULL);
            }

            execvp(argv[0], &argv[0]);
            perror("execvp failed");
            exit(EXIT_FAILURE);

        } else {
            if(runInBackground) {

                signal(SIGCHLD, handle_sigchld);
                backgroundPIDs.push_back(pid);

                cout<<"Background processes IDs are: "<<endl;
                for(pid_t bPid: backgroundPIDs) {
                    cout<<"PID: "<<bPid<<endl;
                }

                if (tokens.size() >= 2 && tokens[0] == "stop") {
                    pid_t stopPid;
                    try {
                        stopPid = stoi(tokens[1]);

                        if (stopPid <= 0) {
                            throw invalid_argument("PID must be positive.");
                        }

                    } catch (const invalid_argument& e) {
                        cerr << "Error: Invalid PID. " << e.what() << endl;
                        continue;
                    } catch (const out_of_range& e) {
                        cerr << "Error: PID out of range. " << e.what() << endl;
                        continue;
                    }

                    if (stopProcess(stopPid)) {
                        cout<<"Process stopped successfully"<<endl;
                    }
                } else {
                    cout << "Invalid input. Use 'stop <PID>' to stop a process." << endl;
                }
            } else {
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

        cout<<"Current Process ID: "<<pid<<endl;
        cout<<endl;
    }
    return 0;
}
