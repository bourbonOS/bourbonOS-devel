#include <security/pam_modules.h>
#include <security/pam_misc.h>
#include <security/pam_ext.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <syslog.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/stat.h>

#define SETUP_CMD "/usr/libexec/transit/setup-transit"
#define OPEN_CMD "/usr/libexec/transit/start-transit"
#define CLOSE_CMD "/usr/libexec/transit/stop-transit"

static int match_argument(const char *arg, const char *expected) {
    return (strcmp(arg, expected) == 0);
}

static int check_homedir_exists(const char *user) {
    char path[1024];
    struct stat st;
    
    snprintf(path, sizeof(path), "/var/usrlocal/transit/repo/%s.homedir", user);
    
    return (stat(path, &st) == 0);
}

static int run_command_with_password(pam_handle_t *pamh, const char *user, const char *password, const char *command_base) {
    int pipe_fd[2];
    pid_t pid;
    int status;
    char command[1024];

    snprintf(command, sizeof(command), "%s \"%s\"", command_base, user);

    if (pipe(pipe_fd) == -1) {
        syslog(LOG_ERR, "Failed to create pipe");
        return PAM_SESSION_ERR;
    }

    pid = fork();
    if (pid == -1) {
        syslog(LOG_ERR, "Failed to fork process");
        close(pipe_fd[0]);
        close(pipe_fd[1]);
        return PAM_SESSION_ERR;
    } else if (pid == 0) {
        close(pipe_fd[1]);
        
        if (dup2(pipe_fd[0], STDIN_FILENO) == -1) {
            syslog(LOG_ERR, "Failed to redirect stdin");
            exit(EXIT_FAILURE);
        }
        close(pipe_fd[0]);
        
        execl("/bin/sh", "sh", "-c", command, (char *)NULL);
        
        syslog(LOG_ERR, "Failed to execute command: %s", command);
        exit(EXIT_FAILURE);
    } else {
        close(pipe_fd[0]);
        
        if (password != NULL) {
            if (write(pipe_fd[1], password, strlen(password)) == -1) {
                syslog(LOG_ERR, "Failed to write password to pipe");
                close(pipe_fd[1]);
                return PAM_SESSION_ERR;
            }
            
            if (write(pipe_fd[1], "\n", 1) == -1) {
                syslog(LOG_ERR, "Failed to write newline to pipe");
                close(pipe_fd[1]);
                return PAM_SESSION_ERR;
            }
        }
        
        close(pipe_fd[1]);
        
        if (waitpid(pid, &status, 0) == -1) {
            syslog(LOG_ERR, "Error waiting for child process");
            return PAM_SESSION_ERR;
        }
        
        if (WIFEXITED(status) && WEXITSTATUS(status) != 0) {
            syslog(LOG_ERR, "Command failed with exit status %d", WEXITSTATUS(status));
            return PAM_SESSION_ERR;
        }
        
        return PAM_SUCCESS;
    }
}

static int run_command(pam_handle_t *pamh, const char *user, const char *command_base) {
    pid_t pid;
    int status;
    char command[1024];

    snprintf(command, sizeof(command), "%s \"%s\"", command_base, user);

    pid = fork();
    if (pid == -1) {
        syslog(LOG_ERR, "Failed to fork process");
        return PAM_SESSION_ERR;
    } else if (pid == 0) {
        execl("/bin/sh", "sh", "-c", command, (char *)NULL);
        
        syslog(LOG_ERR, "Failed to execute command: %s", command);
        exit(EXIT_FAILURE);
    } else {
        if (waitpid(pid, &status, 0) == -1) {
            syslog(LOG_ERR, "Error waiting for child process");
            return PAM_SESSION_ERR;
        }
        
        if (WIFEXITED(status) && WEXITSTATUS(status) != 0) {
            syslog(LOG_ERR, "Command failed with exit status %d", WEXITSTATUS(status));
            return PAM_SESSION_ERR;
        }
        
        return PAM_SUCCESS;
    }
}

int pam_sm_open_session(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    openlog("pam_transit", LOG_PID, LOG_AUTH);

    int run = 0;
    for (int i = 0; i < argc; i++) {
        if (match_argument(argv[i], "mount")) {
            run = 1;
            break;
        }
    }

    if (run) {
        const char *retrieved_user = NULL;
        const char *password = NULL;
        int retval;

        retval = pam_get_user(pamh, &retrieved_user, NULL);
        if (retval != PAM_SUCCESS || retrieved_user == NULL || *retrieved_user == '\0') {
            syslog(LOG_ERR, "Could not get PAM_USER: %s", pam_strerror(pamh, retval));
            closelog();
            return PAM_SESSION_ERR;
        }
        
        retval = pam_get_item(pamh, PAM_AUTHTOK, (const void **)&password);
        if (retval != PAM_SUCCESS || password == NULL) {
            syslog(LOG_NOTICE, "No password available for user %s", retrieved_user);
        }
        
        if (!check_homedir_exists(retrieved_user)) {
            syslog(LOG_INFO, "Homedir for %s not found, running setup", retrieved_user);
            
            retval = run_command_with_password(pamh, retrieved_user, password, SETUP_CMD);
            if (retval != PAM_SUCCESS) {
                syslog(LOG_ERR, "Setup failed for %s", retrieved_user);
                closelog();
                return retval;
            }
            
            syslog(LOG_INFO, "Setup succeeded for %s", retrieved_user);
        }
                
        syslog(LOG_INFO, "Attempting to mount transit for %s", retrieved_user);
        
        retval = run_command_with_password(pamh, retrieved_user, password, OPEN_CMD);
        if (retval != PAM_SUCCESS) {
            syslog(LOG_ERR, "Mount failed for %s", retrieved_user);
            closelog();
            return retval;
        }
        
        syslog(LOG_INFO, "Mount succeeded for %s", retrieved_user);
    }

    closelog();
    return PAM_SUCCESS;
}

int pam_sm_close_session(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    openlog("pam_transit", LOG_PID, LOG_AUTH);

    int run = 0;
    for (int i = 0; i < argc; i++) {
        if (match_argument(argv[i], "unmount")) {
            run = 1;
            break;
        }
    }

    if (run) {
        const char *retrieved_user = NULL;
        int retval;

        retval = pam_get_user(pamh, &retrieved_user, NULL);
        if (retval != PAM_SUCCESS || retrieved_user == NULL || *retrieved_user == '\0') {
            syslog(LOG_ERR, "Could not get PAM_USER: %s", pam_strerror(pamh, retval));
            closelog();
            return PAM_SESSION_ERR;
        }
        
        syslog(LOG_INFO, "Attempting to unmount transit for %s", retrieved_user);
        
        // Use the function without password for CLOSE_CMD
        retval = run_command(pamh, retrieved_user, CLOSE_CMD);
        if (retval != PAM_SUCCESS) {
            syslog(LOG_ERR, "Unmount failed for %s", retrieved_user);
            closelog();
            return retval;
        }
        
        syslog(LOG_INFO, "Unmount succeeded for %s", retrieved_user);
    }

    closelog();
    return PAM_SUCCESS;
}

int pam_sm_authenticate(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    return PAM_IGNORE;
}

int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    return PAM_IGNORE;
}

int pam_sm_acct_mgmt(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    return PAM_IGNORE;
}

int pam_sm_chauthtok(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    return PAM_IGNORE;
}