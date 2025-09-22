(package-initialize)
(require 'package)
;;(add-to-list 'package-archives
;;           '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives
            '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'load-path "~/.emacs.d/lisp/")



(require 'imperial-layout)

(load-theme 'imperial-gold t)
(set-frame-position (selected-frame) 0 0)
(set-frame-width (selected-frame) 170)
(set-frame-height (selected-frame) 59)

 ;;------------------------------------------------------------------------
;;关闭默认界面
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(menu-bar-mode 1)
(scroll-bar-mode -1)
(global-font-lock-mode  t)
;;显示时间
(display-time-mode t)
;;设置默认模式
(setq initial-major-mode 'text-mode)
;;显示空白字符
(global-whitespace-mode t)
(setq whitespace-style '(face space tabs trailing lines-tail newline empty tab-mark newline-mark))
(delete-selection-mode)
;;最近的文件
(recentf-mode 1)
(setq recentf-max-menu-items 15)
(setq recentf-max-saved-items 15)

(message "aaaaaa")

(message "aaaaaab")
;;圆润字体 高覆盖率
;;(set-face-attribute 'default nil :font "ComicShannsMono Nerd Font")
;;{
;;}lilex nerdfont mono
;;(set-face-attribute 'default nil :font "lilex nerd font mono")
;;折线字体 高覆盖率
;;(set-face-attribute 'default nil :font "BlexMono Nerd Font Mono")
(set-face-attribute 'default nil :font "BlexMono Nerd Font Mono-13")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("2cde705081696d5cb75c79fc14758ff58151fd2fb1c30474b2f41017b293d8d2"
     default))
 '(package-selected-packages
   '(## async auto-correct auto-dim-other-buffers colorful-mode commenter
	company-go company-statistics csv-mode dap-mode diff-hl
	diminish dot-mode emacsql erc ess esup evil ffmpeg-player
	general git-modes gited github-search gnuplot go-autocomplete
	go-complete go-dlv go-eldoc go-errcheck go-gen-test go-gopath
	go-guru go-imports go-playground gotest gotest-ts
	graphviz-dot-mode isearch-mb lsp-ui magit magithub
	markdown-mode memory-usage minibar minibuffer-header
	minibuffer-line minimap multiple-cursors org org-ai org-evil
	org-journal org-mind-map org-pdftools org-remark org-translate
	pdf-tools perl-doc popon preview-auto python rainbow-blocks
	rainbow-delimiters rainbow-mode slime spell-fu toc-org
	undo-tree use-package wgrep which-key zig-mode ztree)))

(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

;;------------------------------------------------------------------------

;; 禁用所有自动刷新机制
(global-auto-revert-mode -1)          ; 关闭全局自动刷新
(setq auto-revert-mode nil)           ; 禁用 buffer 级别自动刷新
(setq auto-revert-check-interval nil) ; 禁用定期检查
(setq auto-revert-verbose nil)        ; 防止提示信息

;; 禁止 dired 自动刷新目录列表
(setq dired-auto-revert-buffer nil)
(add-hook 'dired-mode-hook
          (lambda ()
            (setq-local auto-revert-mode nil)))

;; 禁用自动保存和恢复
(setq auto-save-list-file-prefix nil)

;; 禁用所有备份文件
(setq make-backup-files nil)
(setq version-control nil)
(setq backup-directory-alist '(("." . "/dev/null"))) ; 重定向到 null 设备

;; 禁用桌面恢复功能
(setq desktop-save nil)
(setq desktop-restore-eager 0)

;; 禁用最近文件记录
;;(setq recentf-save-file nil)
;;(setq recentf-auto-cleanup nil)

;; 禁用消息日志和调试输出
;;(setq message-log-max nil)
(setq message-log-max 30)
(setq debug-on-error nil)
(setq debug-on-quit nil)



;;globalautorevertnonfilebuffers是用于控制非文件缓冲区（如dired缓冲区等）的自动刷新；globalautoreverttailedbuffers用于控制有“tail”模式（如某些日志文件查看模式）的缓冲区自动刷新。
(setq globalautorevertnonfilebuffers nil)
(setq globalautoreverttailedbuffers nil)
(setq globalautorevertmode nil)
(setq auto-save-default nil)


(message "aaaaaac")



;;---------------------------------------------------------------------------
;; 视觉换行配置
(global-visual-line-mode t)  ; 全局视觉换行
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))  ; 边缘箭头指示器
(setq word-wrap t)  ; 按单词边界换行
(setq-default truncate-lines nil)  ; 禁用自动截断行

;; 行号显示配置
(global-display-line-numbers-mode t)  ; 全局行号
(setq display-line-numbers-type 'absolute)  ; 绝对行号
;;(setq display-line-numbers-width 3)  ; 固定3字符宽度
(setq display-line-numbers-grow-only t)  ; 行号列宽度只增不减

;; 性能优化
(setq-default bidi-display-reordering nil)  ; 禁用双向文本重排
(setq redisplay-dont-pause t)  ; 流畅滚动

;; 模式排除
(dolist (mode '(term-mode-hook eshell-mode-hook image-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; 设置org目录





;;---------------------------------------------------------------------------
(setq cache-directory "~/.emacs_cache")
(setq default-directory "~/Documents/github")
(setq org-directory "~/Documents/org")
(setq org-export-directory "~/Documents/org/org-exports")



;;----------------------------------------------------------------------
;;EOF时
(setq search-highlight t)
(setq lazy-highlight-cleanup nil)



(global-set-key (kbd "C-s") 'isearch-forward-regexp)

;; 增量搜索默认不区分大小写
(setq case-fold-search t)
;; (可选) 设置替换操作也默认不区分大小写
(setq case-replace t)
(setq-default case-fold-search t)   ; 默认忽略大小写
(setq-default case-replace t)       ; 替换时保持原有大小写风格
(setq search-upper-case 'smart)     ; 或 (setq isearch-case-fold-search 'smart) 用于增量搜索
(show-paren-mode 1) ; 全局启用括号匹配高亮
(setq show-paren-style 'expression) ; 高亮整个表达式而非仅括号
(setq show-paren-delay 0)          ; 无延迟显示
(setq show-paren-when-point-inside-paren t) ; 光标在括号内时也高亮



;;----------------------------------------------------------------
(require 'company)
(require 'company-go)
(require 'go-mode)
(add-hook 'go-mode-hook
          (lambda ()
            (lsp-deferred)  ; 延迟加载LSP
            (company-mode t)  ; 启用补全
            (setq company-backends (list 'company-go))))

;;


;; 调整 lsp-log-level 为 warn 减少日志输出：
;;(global-lsp-mode 1)



(require 'go-eldoc)
(add-hook 'go-mode-hook 'go-eldoc-setup)
;;(setq godef-command "/urs/local/bin/godef")
(require 'lsp-mode)
(require 'lsp-ui)
(add-hook 'go-mode-hook #'lsp)
(add-hook 'lsp-mode-hook #'lsp-ui-mode)
(require 'lsp-mode)
(require 'lsp-ui)

;; 仅对编程模式启用 company-mode

;; 配置 lsp 和 company 集成
;;(require 'company-lsp)
;;(add-hook 'lsp-mode-hook 'company-lsp-mode)

(setq lsp-ui-sideline-show-diagnostics t
      lsp-ui-sideline-show-hover t
      lsp-ui-sideline-show-code-actions t
      lsp-ui-doc-position 'top)








(setq lsp-go-gocode-command "gopls")
(add-hook 'prog-mode-hook 'company-mode)  ; 仅对编程模式生效
(setq company-minimum-prefix-length 1)
(setq company-tooltip-limit 10)
(setq company-idle-delay 1.1)
(setq company-show-numbers t)
;;(global-company-mode 1)

;; lsp-mode配置
(setq lsp-keymap-prefix "C-c l")
;;(setq lsp-go-format-on-save t)
;;(setq lsp-go-imports-on-save t)
(setq lsp-go-analyses '((unusedparams . t)
                       (shadow . t)))

;; company-go配置
(setq company-go-gocode-command "gopls")
(setq company-go-insert-arguments t)
(setq lsp-ui-doc-enable t)
(setq lsp-ui-peek-enable t)
(setq lsp-ui-sideline-enable t)

(define-key go-mode-map (kbd "C-c C-r") 'go-rename)
(define-key go-mode-map (kbd "C-c C-j") 'go-goto-imports)
(add-hook 'go-mode-hook
          (lambda ()
            (company-mode)
            (lsp-deferred)
            (setq tab-width 4)
            (setq indent-tabs-mode 1)))




;;---------------------------------------------------------------------


(require 'stack)
(require 'spell-fu)
;;(spell-fu-global-mode)
;;for org-mode:
(add-hook 'org-mode-hook
    (lambda ()
      (setq spell-fu-faces-exclude '(org-meta-line))
      (spell-fu-mode)))



;;--------------------------------------------------------------------
(require 'undo-tree)
(global-undo-tree-mode t)

;; Disable undo-tree auto-saving and persistence
(setq undo-tree-auto-save-history nil)
(setq undo-tree-history-directory-alist '(("." . nil)))
(setq gc-cons-threshold 100000000)  ; 默认800KB，此处设为100MB
(setq gc-cons-percentage 0.3)       ; 内存使用达60%时触发GC



(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
