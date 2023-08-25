#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <signal.h>

#define BACKLOG 1

volatile sig_atomic_t stop_flag = 0;

void handle_signal(int signum) {
    if (signum == SIGINT || signum == SIGTERM) {
        stop_flag = 1;
    }
}

int main() {
    int inputSocket, outputSocket, c1, c2;
    int b1, b2;
    ssize_t len = 0;
    struct sockaddr_in inputAddr, outputAddr;
    FILE *inputClient, *outputClient;
    char inputBuffer[1024];
    char outputBuffer[1024];
    ssize_t output_size = 0;
    char *line = NULL;

    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    if ((inputSocket = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
        perror("input socket");
        return 1;
    }

    if ((outputSocket = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
        perror("output socket");
        return 2;
    }

    bzero(&inputAddr, sizeof(inputAddr));
    bzero(&outputAddr, sizeof(outputAddr));

    inputAddr.sin_family = AF_INET;
    inputAddr.sin_port = htons(8100);
    inputAddr.sin_addr.s_addr = htonl(INADDR_ANY);

    outputAddr.sin_family = AF_INET;
    outputAddr.sin_port = htons(8200);
    outputAddr.sin_addr.s_addr = htonl(INADDR_ANY);
int reuse = 1;
if (setsockopt(inputSocket, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0) {
    perror("setsockopt input");
    return 10;
}

if (setsockopt(outputSocket, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0) {
    perror("setsockopt output");
    return 10;
}


    if (bind(inputSocket, (struct sockaddr *)&inputAddr, sizeof(inputAddr)) < 0) {
        perror("input bind");
        return 3;
    }

    if (bind(outputSocket, (struct sockaddr *)&outputAddr, sizeof(outputAddr)) < 0) {
        perror("output bind");
        return 4;
    }

    listen(inputSocket, BACKLOG);
    listen(outputSocket, BACKLOG);

    pid_t child = fork();
    if (child < 0) {
        exit(1);
    } else if (child == 0) {
        b1 = sizeof inputSocket;

        if ((c1 = accept(inputSocket, (struct sockaddr *)&inputAddr, &b1)) < 0) {
            perror("input accept");
            return 5;
        }
        if ((inputClient = fdopen(c1, "r")) == NULL) {
            perror("input fdopen");
            return 7;
        }
        while (fgets(inputBuffer, sizeof(inputBuffer), inputClient) != NULL) {
            // Process the received input from the client
            fprintf(stdout, "%s", inputBuffer);

            // Check if the stop flag is set
            if (stop_flag) {
                break;
            }
        }

        fclose(inputClient);
        close(inputSocket);
        exit(0);
    }

    b2 = sizeof outputSocket;
    if ((c2 = accept(outputSocket, (struct sockaddr *)&outputAddr, &b2)) < 0) {
        perror("output accept");
        return 6;
    }

    if ((outputClient = fdopen(c2, "w")) == NULL) {
        perror("output fdopen");
        return 8;
    }

    // Write to the output socket

    while ((output_size = getline(&line, &len, stdin)) != -1) {
        fprintf(outputClient, "%s", line);
        fflush(outputClient);

        // Check if the stop flag is set
        if (stop_flag) {
            break;
        }
    }

    fclose(outputClient);
    close(outputSocket);

    return 0;
}

