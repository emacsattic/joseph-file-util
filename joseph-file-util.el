;;; joseph-file-util.el --- Function library about file and directory.

;; Filename: joseph-file-util.el
;; Description: Function library about file and directory.
;; Author: Joseph <jixiuf@gmail.com>
;; Maintainer: Joseph <jixiuf@gmail.com>
;; Copyright (C) 2011~, Joseph, all rights reserved.
;; Created: 2011-03-31
;; Version: 0.1.0
;; URL:  http://www.emacswiki.org/emacs/download/joseph-file-util.el
;; Main Page: https://github.com/jixiuf/joseph-file-util
;; Keywords:  file directory
;; Compatibility: (Test on GNU Emacs 24.0.50.1)
;;
;;
;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;;  some functions handle file and directory.
;;  look examples above each function for detail.
;;

;;; Commands:
;;
;; Below are complete command list:
;;
;;
;;; Customizable Options:
;;
;; Below are customizable option list:
;;

;; (joseph-all-files-under-dir-recursively "~/.emacs.d/" "\\.el$")
;; get all `*.el' under directory `~/.emacs.d/' recursively.
;;
;; (joseph-all-files-under-dir-recursively "~")
;;  get all files under home recursively
;;
;; (print (joseph-all-files-under-dir-recursively "d:/.emacs.d/site-lisp/" "sqlparse"  t ))
;; (print (joseph-all-files-under-dir-recursively "d:/.emacs.d/site-lisp/" "sqlparse"   ))
;; (print (joseph-all-files-under-dir-recursively "d:/.emacs.d/site-lisp/" "sqlparse"  t ".git" t))
;; (print (joseph-all-files-under-dir-recursively "d:/.emacs.d/site-lisp/sqlparse/" nil  t ".git" t))

;;;###autoload
(defun joseph-all-files-under-dir-recursively
  (dir &optional include-regexp include-regexp-absolute-path-p exclude-regex exclude-regex-absolute-path-p)
  "return all files matched `include-regexp' under directory `dir' recursively.
if `include-regexp' is nil ,return all.
when `include-regexp-absolute-path-p' is nil or omited ,filename is used to match `include-regexp'
when `include-regexp-absolute-path-p' is t then full file path is used to match `include-regexp'
"
  (let((files (list dir))  matched-dirs head)
    (while (> (length files) 0)
      (setq head (pop files))
      (when (file-readable-p head)
        (if (file-directory-p head)
            (dolist (sub (directory-files head))
              (when (not (string-match "^\\.$\\|^\\.\\.$" sub))
                (setq files (append (list (expand-file-name sub head)) files))))
          (if include-regexp
              (if (string-match include-regexp  (if include-regexp-absolute-path-p head (file-name-nondirectory head)))
                  (if exclude-regex
                      (if (not (string-match exclude-regex (if exclude-regex-absolute-path-p head (file-name-nondirectory head))))
                          (add-to-list 'matched-dirs head))
                    (add-to-list 'matched-dirs head)
                    )
                )
            (if exclude-regex
                (if (not (string-match exclude-regex (if exclude-regex-absolute-path-p head (file-name-nondirectory head))))
                    (add-to-list 'matched-dirs head))
              (add-to-list 'matched-dirs head)
              )
            )
          )))
    matched-dirs))



;; (joseph-all-subdirs-under-dir-recursively "~") will list all sub directories
;; under home recursively (include home directory),
;; (joseph-all-subdirs-under-dir-recursively "~" "\\.git\\|\\.svn")
;; will list all sub directories under home recursively ,exclude `.git' and `.svn'
;; directories.

;;;###autoload
(defun joseph-all-subdirs-under-dir-recursively(dir &optional exclude-regex)
  "return all sub directorys under `dir', exclude those name match `exclude-regex'"
  (let((files (list dir))  matched-dirs head)
    (while (> (length files) 0)
      (setq head (pop files))
      (when (and (file-readable-p head)
                 (file-directory-p head))
        (add-to-list 'matched-dirs head)
        (dolist (dir (directory-files head ))
          (if (and (file-readable-p (expand-file-name dir head))
                   (file-directory-p (expand-file-name dir head))
                   (not (string-match "^\\.$\\|^\\.\\.$" dir))
                   (if exclude-regex (not (string-match exclude-regex dir)) t))
              (setq files (append (list (expand-file-name dir head)) files))
            ))))
    matched-dirs))



;;;###autoload
(defun joseph-all-subdirs-under-dir-without-borring-dirs(dir)
  "return all sub directories under `dir' exclude those borring directory."
  (joseph-all-subdirs-under-dir-recursively dir "\\.git\\|\\.svn\\|RCS\\|rcs\\|CVS\\|cvs"))


;; for example :
;;
;; (joseph-delete-matched-files '("/etc/hosts"  "/etc/host.conf" "/etc/bash/bashrc") "host")
;; return :("/etc/bash/bashrc")
;; (joseph-delete-matched-files '("/etc/hosts"  "/etc/host.conf" "/etc/bash/bashrc") "etc" t)
;; return nil
;; (joseph-delete-matched-files '("/etc/hosts"  "/etc/host.conf" "/etc/bash/bashrc") "etc" )
;; return all

;;;###autoload
(defun joseph-delete-matched-files
  (files pattern &optional absolute-path-p)
  "delete matched files from `files' the new list of files
will be returned ,`files' is a list of file or directory.
when `absolute-path-p' is nil,
the name of file is used to match the `pattern',
 if not , only the absolute path of file is used."
  (let ((tmp-files))
    (dolist (file files)
      (if absolute-path-p
          (unless (string-match pattern file)
            (add-to-list 'tmp-files file))
        (unless (string-match pattern (file-name-nondirectory file))
          (add-to-list 'tmp-files file))
        ))
    tmp-files))

;; (get-system-file-path "d:/.emacs.d")
;;;###autoload
(defun get-system-file-path(file-path)
  "when on windows `expand-file-name' will translate from \\ to /
some times it is not needed . then this function is used to translate /
to \\ when on windows"
  (if (equal system-type 'windows-nt)
      (replace-regexp-in-string "/" "\\\\" (expand-file-name file-path))
    (expand-file-name file-path)))


(provide 'joseph-file-util)
