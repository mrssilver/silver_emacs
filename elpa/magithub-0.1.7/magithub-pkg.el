;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "magithub" "0.1.7"
  "Magit interfaces for GitHub."
  '((emacs         "25")
    (magit         "2.12")
    (s             "1.12.0")
    (ghub+         "0.3")
    (git-commit    "2.12")
    (markdown-mode "2.3"))
  :url "https://github.com/vermiculus/magithub"
  :commit "81e75cbbbac820a3297e6b6a1e5dc6d9cfe091d0"
  :revdesc "0.1.7-0-g81e75cbbbac8"
  :keywords '("git" "tools" "vc")
  :authors '(("Sean Allred" . "code@seanallred.com"))
  :maintainers '(("Sean Allred" . "code@seanallred.com")))
