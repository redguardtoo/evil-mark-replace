;;; evil-mark-replace.el --- replace the thing in marked area -*- lexical-binding: t; -*-

;; Copyright (C) 2015-2020 Chen Bin

;; Author: Chen Bin <chenbin DOT sh AT gmail DOT com>
;; URL: http://github.com/redguardtoo/evil-mark-replace
;; Keywords: convenience
;; Version: 0.0.6
;; Package-Requires: ((evil "1.14.0"))

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Install:
;;  (require 'evil-mark-replace)
;;
;; Usage:
;;  1, "M-x evilmr-replace-in-defun"
;;  2, "M-x evilmr-replace-in-buffer"
;;  3, Select a region, "M-x evilmr-tag-selected-region",
;;     then "M-x evilmr-replace-in-tagged-region"
;;  4, "M-x evilmr-replace-lines"
;;

;; This file is free software (GPLv3 License)

;;; Code:

(require 'evil nil t)

(defvar evilmr-only-word-p t
  "If it's t, only matched words will be replaced.")

(defvar evilmr-tagged-region-begin nil)
(defvar evilmr-tagged-region-end nil)

;;;###autoload
(defun evilmr-toggle-only-word-p ()
  "Toggle `evilmr-only-word-p'."
  (interactive)
  (setq evilmr-only-word-p (not evilmr-only-word-p))
  (message "Now evilmr-only-word-p=%s" evilmr-only-word-p))

;;;###autoload
(defun evilmr-replace (mark-fn)
  "Mark region with MARK-FN and replace in marked area."
  (let* ((old (if (region-active-p)
                  (buffer-substring-no-properties (region-beginning) (region-end))
                (thing-at-point 'symbol)))
         escaped-old)
    (unless old (setq old (read-string "String to be replaced:")) )

    (setq escaped-old (replace-regexp-in-string "\\$" "\\\\$" old))

    ;; quit the active region
    (if (region-active-p) (set-mark nil))

    (funcall mark-fn)
    (unless (evil-visual-state-p)
      (kill-new old)
      (evil-visual-state))
    (evil-ex (concat "'<,'>s/"
                     (if evilmr-only-word-p "\\<\\(")
                     escaped-old
                     (if evilmr-only-word-p "\\)\\>")
                     "/"))))

;;;###autoload
(defun evilmr-show-tagged-region ()
  "Mark and show tagged region."
  (interactive)
  (when (and evilmr-tagged-region-begin evilmr-tagged-region-end)
    (goto-char (1+ evilmr-tagged-region-end))
    (push-mark (point) nil t)
    (goto-char evilmr-tagged-region-begin)))

;;;###autoload
(defun evilmr-tag-selected-region ()
  "Tag selected region."
  (interactive)
  (cond
   ((region-active-p)
    (setq evilmr-tagged-region-begin (region-beginning))
    (setq evilmr-tagged-region-end (region-end))
    (set-mark nil)
    (message "Region from %d to %d is tagged"
             evilmr-tagged-region-begin
             evilmr-tagged-region-end))
   (t (message "NO region is tagged"))))

;;;###autoload
(defun evilmr-replace-in-buffer ()
  "Mark buffer and replace the thing."
  (interactive)
  (evilmr-replace #'mark-whole-buffer))

;;;###autoload
(defun evilmr-replace-in-defun ()
  "Mark defun and replace the thing."
  (interactive)
  (evilmr-replace #'mark-defun))

(defun evilmr-get-range (num)
  "Get range of NUM lines."
  (unless num (setq num 1))
  (let* (beg end)
    (save-excursion
      (setq beg (line-beginning-position))
      (forward-line (1- num))
      (setq end (line-end-position)))
    (cons beg end)))

(defun evilmr-replace-lines (&optional num)
  "Mark NUM lines and replace the thing."
  (interactive "P")
  (let* ((range (evilmr-get-range num))
         (evilmr-tagged-region-begin (car range))
         (evilmr-tagged-region-end (cdr range)))
    (evilmr-replace #'evilmr-show-tagged-region)))

;;;###autoload
(defun evilmr-replace-in-tagged-region ()
  "Mark tagged region and replace the thing."
  (interactive)
  (evilmr-replace #'evilmr-show-tagged-region))

;;;###autoload
(defun evilmr-version ()
  "Print current version."
  (interactive)
  (message "0.0.6"))

(provide 'evil-mark-replace)
;;; evil-mark-replace.el ends here
