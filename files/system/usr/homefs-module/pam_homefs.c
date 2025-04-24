#include <security/pam_modules.h>
#include <security/pam_misc.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <syslog.h>
#include <sys/wait.h>

#define OPEN_CMD "/usr/libexec/homefs/manage_homedir --mount"
#define CLOSE_CMD "/usr/libexec/homefs/manage_homedir --umount"

static int match_argument(const char *arg, const char *expected) {
    return (strcmp(arg, expected) == 0);
}

int pam_sm_open_session(pam_handle_t *pamh, int flags,
                        int argc, const char **argv) {
    openlog("pam_homefs", LOG_PID, LOG_AUTH);

    int run = 0;
    for (int i = 0; i < argc; i++) {
        if (match_argument(argv[i], "mount")) {
            run = 1;
            break;
        }
    }

    if (run) {
        const char *retrieved_user = NULL;
        int retval;

        retval = pam_get_user(pamh, &retrieved_user, NULL);
        if (retval == PAM_SUCCESS && retrieved_user != NULL && *retrieved_user != '\0') {
            setenv("PAM_USER", retrieved_user, 1);
            syslog(LOG_INFO, "PAM_USER set successfully", retrieved_user);
            syslog(LOG_INFO, "Attempting to mount HomeFS.", OPEN_CMD);
            int status;
            pid_t pid = fork();
            if (pid == -1) {
                syslog(LOG_ERR, "Failed to fork process.");
                closelog();
                return PAM_SESSION_ERR;
            } else if (pid == 0) {
                execl("/bin/sh", "sh", "-c", OPEN_CMD, (char *)NULL);
                syslog(LOG_ERR, "Failed to mount! Error: %s", OPEN_CMD);
                exit(EXIT_FAILURE);
            } else {
                if (waitpid(pid, &status, 0) == -1) {
                    syslog(LOG_ERR, "Error waiting for mount.");
                    closelog();
                    return PAM_SESSION_ERR;
                }
                if (WIFEXITED(status) && WEXITSTATUS(status) != 0) {
                    syslog(LOG_ERR, "Mount failed with exit status %d!", WEXITSTATUS(status));
                    closelog();
                    return PAM_SESSION_ERR;
                }
                syslog(LOG_INFO, "Mount succeeded.");
            }
        } else {
             syslog(LOG_ERR, "Could not set PAM_USER.", pam_strerror(pamh, retval));
             closelog();
             return PAM_SESSION_ERR;
        }
    }

    closelog();
    return PAM_SUCCESS;
}

int pam_sm_close_session(pam_handle_t *pamh, int flags,
                         int argc, const char **argv) {
    openlog("pam_homefs", LOG_PID, LOG_AUTH);

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
        if (retval == PAM_SUCCESS && retrieved_user != NULL && *retrieved_user != '\0') {
            setenv("PAM_USER", retrieved_user, 1);
            syslog(LOG_INFO, "PAM_USER set successfully.", retrieved_user);
            syslog(LOG_INFO, "Attempting to unmount HomeFS.", CLOSE_CMD);
            int status;
            pid_t pid = fork();
            if (pid == -1) {
                syslog(LOG_ERR, "Failed to fork process.");
                closelog();
                return PAM_SESSION_ERR;
            } else if (pid == 0) {
                execl("/bin/sh", "sh", "-c", CLOSE_CMD, (char *)NULL);
                syslog(LOG_ERR, "Failed to unmount!! Error: %s", CLOSE_CMD);
                exit(EXIT_FAILURE);
            } else {
                if (waitpid(pid, &status, 0) == -1) {
                    syslog(LOG_ERR, "Error waiting for unmount.");
                    closelog();
                    return PAM_SESSION_ERR;
                }
                if (WIFEXITED(status) && WEXITSTATUS(status) != 0) {
                    syslog(LOG_ERR, "Unmount failed with exit status %d!!", WEXITSTATUS(status));
                    closelog();
                    return PAM_SESSION_ERR;
                }
                syslog(LOG_INFO, "Unmount succeeded.");
            }
        } else {
             syslog(LOG_ERR, "Could not set PAM_USER.", pam_strerror(pamh, retval));
             closelog();
             return PAM_SESSION_ERR;
        }
    }

    closelog();
    return PAM_SUCCESS;
}