 (defun compile-files ()
   "run make"
   (interactive)
   (let ((buf (get-buffer-create "*result*"))
	 (proc nil)
	 (coding-system-for-read 'euc-jp-unix))
     (setq proc (call-process 
		 "sh"
		 nil
		 buf
		 nil
		 "/home/t_nishi/e-learning/compile/compile.sh"
		 "sample"
		 "/home/t_nishi/e-learning/compile/sample.c"
		 ))
;     (set-process-coding-system proc 'euc-jp-unix 'euc-jp-unix)
;     (display-buffer "*result*"))
   (analysis-client))
)

(defun http-client ()
  "put xml from server"
  (interactive)
  (let ((buf (get-buffer-create "*client*"))
	(proc nil))
    (setq proc (open-network-stream
		"*client*"
		buf
		"localhost"
		7300))
    (set-process-coding-system proc 'iso-2022-jp 'binary)
;    (display-buffer buf)
    (set-buffer "*connection*")
    (process-send-string proc (format (buffer-string)))
    (process-send-string proc (format (concat "\n")))
    (process-send-string proc (format (concat "EOF")))
    (process-send-eof proc)
    (sleep-for 0.3)
    (delete-process proc)
    (set-buffer-modified-p nil)
;    (kill-buffer "*connection*")
    )
  )


(compile-files)

