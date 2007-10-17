(defun analysis-client ()
  "get xml from server"
  (interactive)
  (let ((buf (get-buffer-create "*connection*"))
	(proc nil))
    (setq proc (open-network-stream
		"*connection*"
		buf
		"localhost"
		7120))
    (set-process-coding-system proc 'iso-2022-jp 'binary)
    (display-buffer buf)
    (set-buffer "*result*")
    (process-send-string proc (format (concat "mode_compiler")))
    (process-send-string proc (format (concat "\n")))
;    (process-send-string proc (format (concat "mode_debugger")))
;    (process-send-string proc (format (concat "\n")))
    (process-send-string proc (format (buffer-string)))
    (process-send-string proc (format (concat "\n")))
    (process-send-string proc (format (concat "EOF")))
    (process-send-eof proc)
    (sleep-for 0.3)
;    (accept-process-output proc)
;    (process-status proc)
;    (setq delete-exited-processes 0)
    (delete-process proc)
    (set-buffer-modified-p nil)
; *result*$B%P%C%U%!$r0lEY>C5n(B
    (kill-buffer "*result*")
    )
  )

(analysis-client)



