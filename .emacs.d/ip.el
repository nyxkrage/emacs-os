(defun ip-to-string (ip)
  (mapconcat 'int-to-string ip "."))

(defun modify-ip (ip idx newval)
  (let ((i (copy-tree ip)))
    (setcar (nthcdr idx i) newval)
    i))

(defun assign-ip (ip interface)
  (call-process "/sbin/ip" nil "*log*" nil
		"addr"
		"add"
		(concat (ip-to-string ip) "/24")
		"broadcast"
		(ip-to-string (modify-ip ip 3 255))
		"dev"
		interface)
  (call-process "/sbin/ip" nil "*log*" nil
		"link"
		"set"
		"dev"
		interface
		"up")
  (call-process "/sbin/ip" nil "*log*" nil
		"route"
		"add"
		"default"
		"via"
		(ip-to-string (modify-ip ip 3 2))
		"dev"
		interface))

(provide 'ip)
		
