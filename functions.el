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

(compile-files)

