#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/select.h>

int main(int argc, char *argv[]) {
    int s, v, maxfd;
    fd_set readfds;
    struct sockaddr_in sa, va;
    char buffer[1024 + 1];

    if ((s = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
        perror("socket input");
        return 1;
    }

    if ((v = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
        perror("socket output");
        return 1;
    }

    bzero(&sa, sizeof sa);
    bzero(&va, sizeof va);

    sa.sin_family = AF_INET;
    sa.sin_port = htons(8200);
    if (argc > 1) {
        sa.sin_addr.s_addr = inet_addr(argv[1]);
    } else {
        sa.sin_addr.s_addr = htonl((((((127 << 8) | 0) << 8) | 0) << 8) | 1);
    }

    va.sin_family = AF_INET;
    va.sin_port = htons(8100);
    if (argc > 1) {
        va.sin_addr.s_addr = inet_addr(argv[1]);
    } else {
        va.sin_addr.s_addr = htonl((((((127 << 8) | 0) << 8) | 0) << 8) | 1);
    }

    if (connect(s, (struct sockaddr *)&sa, sizeof sa) < 0) {
        perror("connect input");
        close(s);
        close(v);
        return 2;
    }
    if (connect(v, (struct sockaddr *)&va, sizeof va) < 0) {
        perror("connect output");
        close(s);
        close(v);
        return 2;
    }

    // Find the maximum file descriptor
    maxfd = (s > v) ? s : v;

    while (1) {
        FD_ZERO(&readfds);
        FD_SET(s, &readfds);
        FD_SET(STDIN_FILENO, &readfds);

        // Check if data is available on any file descriptor
        int ready = select(maxfd + 1, &readfds, NULL, NULL, NULL);
        if (ready < 0) {
            perror("select");
            break;
        }

        // Check if data is available to read from the server socket
        if (FD_ISSET(s, &readfds)) {
            int bytes = read(s, buffer, sizeof(buffer));
            if (bytes <= 0) {
                // Connection closed by server
                break;
            }
            write(STDOUT_FILENO, buffer, bytes);
        }

        // Check if user input is available to send to the server
        if (FD_ISSET(STDIN_FILENO, &readfds)) {
            int bytes = read(STDIN_FILENO, buffer, sizeof(buffer));
            if (bytes <= 0) {
                // Error or end of input
                break;
            }
            write(v, buffer, bytes);
        }
    }

    close(s);
    close(v);
    return 0;
}

