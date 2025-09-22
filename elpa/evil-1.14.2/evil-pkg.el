;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "evil" "1.14.2"
  "Extensible Vi layer for Emacs."
  '((emacs    "24.1")
    (goto-chg "1.6")
    (cl-lib   "0.5"))
  :url "https://github.com/emacs-evil/evil"
  :commit "162a94cbce4f2c09fa7dd6bd8ca56080cb0ab63b"
  :revdesc "162a94cbce4f"
  :keywords '("emulation" "vim")
  :maintainers '(("Tom Dalziel" . "tom.dalziel@gmail.com")))
