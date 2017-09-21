;;; ac-swift.el --- An auto-complete source for Swift using SourceKitten

;; Copyright (C) 2017 Eitaro Fukamachi

;; Author: Eitaro Fukamachi <e.arrows@gmail.com>
;; URL: https://github.com/fukamachi/ac-swift
;; Version: 0.1.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Usage:

;;     (require 'ac-swift)
;;     (add-hook 'swift-mode-hook 'ac-swift-setup)
;;     (eval-after-load "auto-complete"
;;       '(add-to-list 'ac-modes 'swift-mode))

(require 'auto-complete)
(require 'json)

(defgroup ac-swift nil
  "Swift auto-complete customizations"
  :prefix "ac-swift-"
  :group 'auto-complete)

(defcustom ac-swift-sourcekitten-path "/usr/local/bin/sourcekitten"
  "Binary path to SourceKitten"
  :group 'ac-swift)

(defcustom ac-swift-compile-target nil
  "Compile target given to the Swift compiler"
  :group 'ac-swift)

(defcustom ac-swift-compile-sdk nil
  "Compile SDK given to the Swift compiler"
  :group 'ac-swift)

(defun ac-swift-sourcekitten-complete (text offset)
  (let ((command (append (list ac-swift-sourcekitten-path "complete"
                               "--text" text
                               "--offset" (number-to-string
                                           (if (or (eq ?\. (char-before offset))
                                                   (eq ?  (char-before offset)))
                                               (1- offset)
                                             offset))
)
                         (and (or ac-swift-compile-target
                                  ac-swift-compile-sdk)
                              (list "--"))
                         (and ac-swift-compile-target
                              (list "-target" ac-swift-compile-target))
                         (and ac-swift-compile-sdk
                              (list "-sdk" ac-swift-compile-sdk)))))
    (with-temp-buffer
      (apply 'process-file (first command) nil t nil (rest command))
      (buffer-string))))

(defun ac-swift-parse-results (string)
  (let* ((json-array-type 'list)
         (json-key-type 'string)
         (candidates (json-read-from-string string)))
    (mapcar (lambda (candidate)
              (let* ((name (cdr (assoc "name" candidate)))
                     (typeName (cdr (assoc "typeName" candidate))))
                (popup-make-item name
                                 :symbol typeName
                                 :summary typeName)))
            candidates)))

(defun ac-swift-prefix ()
  (or (ac-prefix-symbol)
      (let ((c (char-before)))
        (if (or (eq ?\. c)
                (eq ?   c))
            (point)
          (save-excursion (skip-syntax-backward "w_") (point))))))

(defun ac-swift-buffer-completions (&optional buffer point)
  (let ((buffer (or buffer (current-buffer))))
    (ac-swift-parse-results
     (ac-swift-sourcekitten-complete (with-current-buffer buffer
                                       (buffer-string))
                                     point))))

(ac-define-source swift
  '((candidates . (ac-swift-buffer-completions nil ac-point))
    (prefix . ac-swift-prefix)
    (requires . 0)
    (cache)))

(defun ac-swift-setup ()
  (interactive)
  (auto-complete-mode +1)
  (add-to-list 'ac-sources 'ac-source-swift))

(provide 'ac-swift)

;;; ac-swift.el ends here
