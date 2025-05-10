#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <syslog.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>
#include <security/pam_modules.h>
#include <security/pam_ext.h>
#include <security/_pam_macros.h>

#define TRANSIT_OPEN_CMD "/usr/libexec/transit/transit-open"
#define TRANSIT_CLOSE_CMD "/usr/libexec/transit/transit-close"

/* Execute command passing username as arg and password via stdin */
static int execute_command(pam_handle_t *pamh, const char *command, 
                          const char *username, const char *password)
{
    pid_t child_pid;
    int status;
    int pipe_fd[2];
    
    /* Create pipe for password transfer */
    if (pipe(pipe_fd) == -1) {
        pam_syslog(pamh, LOG_ERR, "Failed to create pipe: %s", strerror(errno));
        return PAM_SYSTEM_ERR;
    }
    
    /* Fork process */
    child_pid = fork();
    if (child_pid == -1) {
        pam_syslog(pamh, LOG_ERR, "Fork failed: %s", strerror(errno));
        close(pipe_fd[0]);
        close(pipe_fd[1]);
        return PAM_SYSTEM_ERR;
    }
    
    if (child_pid == 0) {
        /* Child process */
        
        /* Close write end of pipe */
        close(pipe_fd[1]);
        
        /* Redirect stdin to read from pipe */
        if (dup2(pipe_fd[0], STDIN_FILENO) == -1) {
            pam_syslog(pamh, LOG_ERR, "Failed to redirect stdin: %s", strerror(errno));
            close(pipe_fd[0]);
            _exit(EXIT_FAILURE);
        }
        close(pipe_fd[0]);
        
        /* Execute the command with username as argument */
        execl(command, command, username, NULL);
        
        /* If we get here, exec failed */
        pam_syslog(pamh, LOG_ERR, "Failed to execute %s: %s", command, strerror(errno));
        _exit(EXIT_FAILURE);
    }
    
    /* Parent process */
    
    /* Close read end of pipe */
    close(pipe_fd[0]);
    
    /* Write password to pipe if available */
    if (password != NULL) {
        size_t password_len = strlen(password);
        size_t total_written = 0;
        
        while (total_written < password_len) {
            ssize_t written = write(pipe_fd[1], 
                                  password + total_written,
                                  password_len - total_written);
            
            if (written == -1) {
                if (errno == EINTR)
                    continue;
                pam_syslog(pamh, LOG_ERR, "Failed to write password: %s", strerror(errno));
                close(pipe_fd[1]);
                return PAM_SYSTEM_ERR;
            }
            total_written += written;
        }
    }
    
    /* Close write end of pipe */
    close(pipe_fd[1]);
    
    /* Wait for child to exit */
    while ((waitpid(child_pid, &status, 0)) == -1) {
        if (errno != EINTR) {
            pam_syslog(pamh, LOG_ERR, "Wait failed: %s", strerror(errno));
            return PAM_SYSTEM_ERR;
        }
    }
    
    /* Check exit status */
    if (WIFSIGNALED(status)) {
        pam_syslog(pamh, LOG_ERR, "Command terminated by signal %d", WTERMSIG(status));
        return PAM_SYSTEM_ERR;
    }
    
    if (!WIFEXITED(status)) {
        pam_syslog(pamh, LOG_ERR, "Command terminated abnormally");
        return PAM_SYSTEM_ERR;
    }
    
    if (WEXITSTATUS(status) != 0) {
        pam_syslog(pamh, LOG_ERR, "Command failed with status %d", WEXITSTATUS(status));
        return PAM_AUTH_ERR;  // Changed from PAM_SYSTEM_ERR
    }
    
    return PAM_SUCCESS;
}

/* Open session handler */
PAM_EXTERN int pam_sm_open_session(pam_handle_t *pamh, int flags,
                                 int argc, const char **argv)
{
    int retval;
    const char *username = NULL;
    const char *password = NULL;
    
    /* Get username */
    retval = pam_get_item(pamh, PAM_USER, (const void **)&username);
    if (retval != PAM_SUCCESS || username == NULL) {
        pam_syslog(pamh, LOG_ERR, "Cannot get username");
        return PAM_SESSION_ERR;
    }
    
    /* Get password */
    retval = pam_get_item(pamh, PAM_AUTHTOK, (const void **)&password);
    if (retval != PAM_SUCCESS) {
        pam_syslog(pamh, LOG_ERR, "Cannot get password");
        return PAM_SESSION_ERR;
    }
    
    /* Execute transit-open command */
    return execute_command(pamh, TRANSIT_OPEN_CMD, username, password);
}

/* Close session handler */
PAM_EXTERN int pam_sm_close_session(pam_handle_t *pamh, int flags,
                                  int argc, const char **argv)
{
    int retval;
    const char *username = NULL;
    const char *password = NULL;
    
    /* Get username */
    retval = pam_get_item(pamh, PAM_USER, (const void **)&username);
    if (retval != PAM_SUCCESS || username == NULL) {
        pam_syslog(pamh, LOG_ERR, "Cannot get username");
        return PAM_SESSION_ERR;
    }
    
    /* Get password */
    retval = pam_get_item(pamh, PAM_AUTHTOK, (const void **)&password);
    if (retval != PAM_SUCCESS) {
        pam_syslog(pamh, LOG_WARNING, "Cannot get password during session close");
        /* Continue anyway - password might not be available at close time */
    }
    
    /* Execute transit-close command */
    return execute_command(pamh, TRANSIT_CLOSE_CMD, username, password);
}

/* These functions are not implemented since we only handle session events */
PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags,
                                 int argc, const char **argv)
{
    return PAM_IGNORE;
}

PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags,
                            int argc, const char **argv)
{
    return PAM_IGNORE;
}

PAM_EXTERN int pam_sm_acct_mgmt(pam_handle_t *pamh, int flags,
                              int argc, const char **argv)
{
    return PAM_IGNORE;
}

PAM_EXTERN int pam_sm_chauthtok(pam_handle_t *pamh, int flags,
                              int argc, const char **argv)
{
    return PAM_IGNORE;
}