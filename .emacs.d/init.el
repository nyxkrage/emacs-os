;;; init.el --- Emacs-OS Init System -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Carsten Kragelund
;;
;; Author: Carsten Kragelund <carsten@kragelund.dev>
;; Maintainer: Carsten Kragelund <carsten@kragelund.dev>
;; Created: December 16, 2022
;; Modified: December 16, 2022
;; Version: 1.0.0
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/nyxkrage/emacs-os
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  This is the Emacs-OS init.el file which sets up reboot and shutdown commands
;;  and makes sure that the root filesystem gets mounted as rw
;;
;;; Code:

(message "init starting")
(setq auto-save-interval 0)

(defun save-all-buffers ()
  (save-some-buffers nil t))

(defun reboot ()
  (interactive)
  (when (yes-or-no-p "Really reboot the system? ")
    (save-all-buffers)
    (if (file-exists-p "/etc/mtab") (delete-file "/etc/mtab"))
    (call-process "/sbin/mount" nil nil nil "-n" "-o" "ro,remount" "/")
    (call-process "/sbin/reboot" nil nil nil)))

(defun shutdown ()
  (interactive)
  (when (yes-or-no-p "Really shut down the system? ")
    (save-all-buffers)
    (if (file-exists-p "/etc/mtab") (delete-file "/etc/mtab"))
    (call-process "/sbin/mount" nil nil nil "-n" "-o" "ro,remount" "/")
    (call-process "/sbin/shutdown" nil nil nil)))

;; Global keybindings
(global-set-key "\C-x\C-z" 'reboot)
(global-set-key "\C-x\C-c" 'shutdown)
(global-set-key "\C-\M-s" 'eshell)

(global-set-key "^"  'keyboard-quit) ;; strangely, C-g does not work.

;; Add some standard directories to exec-path to use in eshell
(setenv "PATH" "/bin:/sbin")
(add-to-list 'load-path "/.emacs.d/")

;; Mount various needed virtual/tmp filesystem
(call-process "/sbin/mount" nil "*log*" nil "-t" "proc" "proc" "/proc")
(call-process "/sbin/mount" nil "*log*" nil "-o" "rw,remount" "/")
(call-process "/sbin/mount" nil "*log*" nil "-t" "sysfs" "sys" "/sys")
(call-process "/sbin/mount" nil "*log*" nil "-t" "tmpfs" "run" "/run")
(call-process "/sbin/mount" nil "*log*" nil "-t" "devtmpfs" "dev" "/dev")

(call-process "/bin/hostname" nil nil nil "emacs")

(require 'ip)
(assign-ip '(172 16 57 10) "ens33")

(custom-set-variables
 '(inhibit-startup-screen t)
  '(initial-buffer-choice nil))

(message "init done")

(require 'catppuccin)

(catppuccin-colors)

(eshell)

(provide 'init)
;;; init.el ends here
