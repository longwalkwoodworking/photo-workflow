;;; Copyright © 2022 Eric Diven

;;; This program is free software. It comes without any warranty, to
;;; the extent permitted by applicable law. You can redistribute it
;;; and/or modify it under the terms of the Do What The Fuck You Want
;;; To Public License, Version 2, as published by Sam Hocevar. See
;;; http://www.wtfpl.net/ for more details.

;;; Adapted from https://gist.github.com/danstuken/3625841

(define xcfFiles '(
XCF_FILES
))

(define (jpeg-path xcfPath)
  (let* ((xcfPathLen (string-length xcfPath))
         (extension (substring xcfPath (- xcfPathLen 4)) xcfPathLen)
         (barePath (substring xcfPath 0 (- xcfPathLen 4))))
    (cond
      ((string-ci=? ".xcf" extension) (string-append barePath ".jpg"))
      (else 
        (display "Bad file name: ")
        (display xcfPath)
        (display "\n")
        (gimp-quit FALSE)))))

(define (export-jpeg xcfPath)
  (let* ((jpgPath (jpeg-path xcfPath))
         (xcfImage (car (gimp-file-load RUN-NONINTERACTIVE jpgPath jpgPath)))
         (xcfDrawable (car (gimp-image-flatten xcfImage))))
         (display "Exporting ")
         (display xcfPath)
         (display " to ")
         (display jpgPath)
         (display "\n")
         (file-jpeg-save RUN-NONINTERACTIVE xcfImage xcfDrawable jpgPath jpgPath 1.0 0.0 0 0 "" 2 1 0 2)))

(define (export-all l)
  (cond
    ((null? l) (gimp-quit TRUE))
    (else (export-jpeg (car l))
        (export-all (cdr l)))))

(export-all xcfFiles)
(gimp-quit FALSE)
