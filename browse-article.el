;;; browse-article.el --- View articles without webpage cluter, within Emacs
;; Copyright (C) 2015 Pedro Tacla Yamada
;;
;; Author: Pedro Tacla Yamada <tacla.yamada@gmail.com>
;; Maintainer: Pedro Tacla Yamada <tacla.yamada@gmail.com>
;; Created: 18 Mar 2015
;; Keywords: web,browse-url-function,articles
;; Version: 0.0.1
;; Homepage: https://github.com/yamadapc/emacs-browse-article
;; Package-Requires: ((json "1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary: This package exposes a function `browse-article' to fetch and
;;; view articles without the clutter within Emacs. It requires `curl' and
;;; `unfluff' to be installed on the user's machine.
;;
;;; Code:

(require 'json)

(defun browse-article--start-process (url buffer)
  (let* ((command (format "curl -s %s | unfluff" url)))
    (start-process-shell-command "browse-article-process" buffer command)))

(defun browse-article--buffer ()
  (let* ((browse-article-buffer-name "*browse-article*")
         (buffer (get-buffer-create browse-article-buffer-name)))
    (with-current-buffer buffer (erase-buffer))
    buffer))

(defun browse-article--parse-output (buffer)
  (with-current-buffer buffer
   (goto-char (point-min))
   (cdr (assoc 'text (json-read)))))

(defun browse-article--replace-output (buffer article)
  (with-current-buffer buffer
    (erase-buffer)
    (goto-char (point-min))
    (insert article)
    (fill-region (point-min) (point-max))
    (goto-char (point-min))))

(defun browse-article--make-sentinel (buffer)
  `(lambda (p e) (when (= 0 (process-exit-status p))
                   (let ((article (browse-article--parse-output ,buffer)))
                     (browse-article--replace-output ,buffer article)))))

(defun browse-article (url &rest args)
  (let* ((buffer (browse-article--buffer))
         (process (browse-article--start-process url buffer)))
    (set-process-sentinel process (browse-article--make-sentinel buffer))
    (display-buffer buffer)))

;;; browse-article.el ends here
