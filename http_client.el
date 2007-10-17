 (defun web-client ()
   "get file from http server"
   (interactive)
   (let ((buf (get-buffer-create "web conection"))
         (proc nil))
      (setq proc (open-network-stream
              "web-connection"
              buf
              "localhost"
             80))
     (set-process-coding-system proc 'iso-2022-jp 'binary)
     (display-buffer buf)
     (process-send-string
          proc
          (format (concat
               "GET / HTTP/1.0\r\n"
               "\r\n")))))

(web-client)

