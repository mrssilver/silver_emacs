(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(package-initialize)



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(dracula))
 '(custom-safe-themes
   '("603a831e0f2e466480cdc633ba37a0b1ae3c3e9a4e90183833bc4def3421a961" default))
 '(package-selected-packages
   '(slime commenter go-dlv gotest magithub go-eldoc go-guru go-errcheck ffmpeg-player esup use-package org-remark rainbow-mode auto-correct auto-dim-other-buffers python erc rainbow-delimiters popon multiple-cursors minibuffer-header minibuffer-line minibar company-statistics perl-doc preview-auto ztree pdf-tools org emacsql gited dracula-theme diminish diff-hl magit git-modes go-mode markdown-mode memory-usage)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "Black" :foreground "dark red" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight regular :height 120 :width normal :foundry "nil" :family "Menlo"))))
 '(cursor ((t (:background "DarkOrange1"))))
 '(custom-themed ((t (:background "yellow1" :foreground "dark red"))))
 '(highlight ((t (:background "red1" :foreground "light green"))))
 '(isearch ((t (:inherit match :background "gold1" :foreground "dark red" :weight extra-bold))))
 '(isearch-fail ((t (:background "black" :foreground "yellow1"))))
 '(lazy-highlight ((t (:background "yellow1" :foreground "dark red")))))

;;关闭默认界面
(setq inhibit-startup-message t)
(tool-bar-mode 0)
(scroll-bar-mode  0)
(menu-bar-mode  t)
;;设置窗口位置、大小
(set-frame-position (selected-frame) 0 0)
(set-frame-width (selected-frame) 80)
(set-frame-height (selected-frame) 55)
;;显示时间
(display-time-mode t)
;;设置默认模式
(setq initial-major-mode 'text-mode)
;;显示空白字符
(global-whitespace-mode t)
(setq whitespace-style '(face space tabs trailing lines-tail newline empty tab-mark newline-mark))
;;自动刷新
;;(global-auto-revert-mode t)
;;最近的文件
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
(global-set-key (kbd "C-x C-r") 'recentf-open-files)
