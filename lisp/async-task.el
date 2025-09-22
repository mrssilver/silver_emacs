
;;; async-task.el --- Asynchronous task system for Emacs with enhanced debugging

(defvar async-jobs (make-hash-table :test 'equal)
  "Hash table storing all async jobs (job-id -> process)")

(defvar async-job-counter 0
  "Counter for generating unique job IDs")

(defvar async-output-buffer "*Async Output*"
  "Default output buffer name")

(defvar async-debug-buffer "*Async Debug*"
  "Debug logging buffer name")

(defvar async-debug-level 'info
  "Logging level (trace/debug/info/warn/error)")

(defun async-log (level message &rest args)
  "Enhanced logging function with timestamp and level filtering"
  (when (memq level '(trace debug info warn error))
    (let ((log-buffer (get-buffer-create async-debug-buffer))
          (timestamp (format-time-string "[%Y-%m-%d %H:%M:%S]"))
          (formatted-msg (apply #'format message args)))
      (with-current-buffer log-buffer
        (goto-char (point-max))
        (insert (format "%s [%5s] %s\n" timestamp (upcase (symbol-name level)) formatted-msg))))))

(defun async-generate-job-id ()
  "Generate unique job ID with timestamp and counter"
  (format "%s-%d"
          (format-time-string "%H%M%S")
          (cl-incf async-job-counter)))

(defun async-eval-command (&optional code)
  "Generate execution command based on major mode"
  (async-log 'debug "Generating command for mode: %s" major-mode)
  (let ((cmd (append (cond ((eq major-mode 'sh-mode) '("bash" "-c"))
                          ((eq major-mode 'emacs-lisp-mode) '("emacs" "--batch" "--eval"))
                          ((eq major-mode 'python-mode) '("python" "-c"))
                          (t '("sh" "-c")))
                    (when code (list code)))))
    (async-log 'trace "Generated command: %S" cmd)
    cmd))

(defun async-filter (process output)
  "Process filter with debug logging"
  (async-log 'trace "Process[%s] output: %S" (process-id process) output)
  (let ((output-buf (process-buffer process)))
    (when (buffer-live-p output-buf)
      (with-current-buffer output-buf
        (let ((inhibit-read-only t))
          (save-excursion
            (goto-char (point-max))
            (insert output)))))))

(defun async-sentinel (process event)
  "Enhanced process sentinel with detailed logging"
  (let* ((job-id (process-get process 'job-id))
         (exit-status (process-exit-status process))
         (output-buf (process-buffer process)))
    (async-log 'info "Job[%s] status changed: %s (exit: %d)" job-id event exit-status)
    
    (when (buffer-live-p output-buf)
      (with-current-buffer output-buf
        (let ((inhibit-read-only t))
          (save-excursion
            (goto-char (point-max))
            (insert (propertize 
                     (format "\n--- Task finished: %s (status: %d) ---\n" 
                             (replace-regexp-in-string "\n" "" event) exit-status)
                     'face (if (zerop exit-status) 
                               '(:weight bold :foreground "green")
                             '(:weight bold :foreground "red")))))
          (async-log 'debug "Job[%s] output size: %d chars" job-id (buffer-size)))))))

(defun async-run-command (command &optional callback)
  "Main function to execute async command"
  (let* ((job-id (async-generate-job-id))
         (output-buf (get-buffer-create async-output-buffer))
         (process (apply #'start-process 
                         (format "async-%s" job-id)
                         output-buf
                         command)))
    (async-log 'info "Starting job[%s] with command: %S" job-id command)
    (puthash job-id process async-jobs)
    (process-put process 'job-id job-id)
    (set-process-filter process #'async-filter)
    (set-process-sentinel process #'async-sentinel)
    (when callback
      (process-put process 'callback callback))
    job-id))

(defun async-eval-buffer (&optional buffer)
  "Evaluate buffer content asynchronously"
  (interactive)
  (let* ((content (with-current-buffer (or buffer (current-buffer)) 
                   (buffer-string)))
         (cmd (async-eval-command content)))
    (async-run-command cmd)))

(provide 'async-task)
;;; async-task.el ends here
