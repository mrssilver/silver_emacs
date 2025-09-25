(defvar window-i nil)
(defvar window-io nil)
(defvar window-main nil)
(defvar split-window-enabled nil)
(defvar rule nil `())
(defvar alist-rule nil `())
(defvar alist-rule2 nil `())



(setq alist-rule2
      `(
	;; Rule 1: 系统消息类缓冲区（复用窗口模式）
	(,(regexp-opt '("*Messages*" "*undo-tree*" "*help*"                "*godoc*" "*Completions*" "*compilation*" "*occur*") t)
	  (display-buffer-reuse-window)
	  (window . window-i))

	;; Rule 2: Go源代码文件（排除系统目录）
	(,(concat (regexp-opt '(".go")) "\\'")
	  (display-buffer-reuse-window)
	  (window . window-i)
	  (unless (string-match-p "/usr/" (or buffer-file-name ""))))

	;; Rule 3: 通讯类缓冲区（固定至IO窗口）
	(,(regexp-opt '("*ERC*" "*mail*" "*gnus*" "*Group*" "*Summary*" "*Article*") t)
	  (display-buffer-reuse-window)
	  (window . window-io)
	  )

	;; Rule 4: 默认规则（主窗口显示）
	(".*"  ; 兜底匹配所有缓冲区
	 (display-buffer-same-window)
	 (window . window-main))
	))


(setq alist-rule  (list
		    ;; Rule 1: *Completions*, *compilation*, *Messages* ,*occur*-> window "I"
		    (cons
		      (lambda (buf alist)
			(let ((name (buffer-name buf)))
			  (string-match-p                "\\`\\*\\(Completions\\|compilation\\|Messages\\|Compile-Log\\|Help\\|Warnings\\)\\*\\|\\*\\*.+"
							 name)))
		      (list 'display-buffer-reuse-window
			    (cons 'in-window-name "I")
			    ;;   (cons 'dedicated t)
			    ))

		    ;; Rule 2: erc 相关 buffer（如 #channel, *erc*）-> window "io"
		    (cons
		      (lambda (buf alist)
			(let ((name (buffer-name buf)))
			  (string-match-p                "\\`\\*\\(*?erc\\|occur\\|undo-tree\\|^#.+:\\)\\*"
							 name)))
		      (list 'display-buffer-reuse-window
			    (cons 'in-window-name "io")
			    ;;    (cons 'dedicated t)
			    ))



		    ;; Rule 3: 其他所有 buffer -> window "main"
		    (cons t
			  (list 'display-buffer-reuse-window
				(cons 'in-window-name "main")))))

(setq rule alist-rule2)

(defun on-state ()
  "切换分屏开关状态，并显示提示。"
  (interactive)
  ;;(setq split-window-enabled (not split-window-enabled))

  (setq split-window-enabled t)
  (if split-window-enabled
    (message "✅ 分屏已启用")
    (message "❌ 分屏已禁用")))

(defun off-state ()
  "切换分屏开关状态，并显示提示。"
  (interactive)
  (setq split-window-enabled nil)

  (if split-window-enabled
    (message "✅ 分屏已启用")
    (message "❌ 分屏已禁用")))




(defun mrsilver/setup-layout ()
  "创建稳定的三窗格布局（左I/右io+main），包含：
  - 修正窗口分割参数传递
  - 添加防御性编程检查
  - 支持交互式调用"
  (interactive)
  (on-state)
  (delete-other-windows)

  ;; 创建左侧I窗口 with is left
  (split-window-horizontally 77)

  (setq window-i (selected-window))
  (set-window-parameter (selected-window) 'window-purpose "I")


  ;; 创建右侧io窗口
 
		    (split-window-vertically)
		    (other-window 1)
		    (message "lllll")
		    (setq window-io (selected-window))
		    (set-window-parameter (selected-window) 'window-purpose "io")
		    (other-window 1)
		    (setq window-main (selected-window))
		    (set-window-parameter (selected-window) 'window-purpose "main")
		   


  (off-state)
 

  )

  (defun get-window-with-purpose (purpose)
    "查找指定用途的窗口"
    (cl-find-if
      (lambda (w) (equal (window-parameter w 'window-purpose) purpose))
      (window-list)))


  (defun ensure-layout ()
    "确保三窗格布局存在，若不存在则创建"
    (unless (and window-i
		 window-io
		 window-main)
      ;; (unless (and (windowp (get-window-with-purpose "I"))
      ;;          (windowp (get-window-with-purpose  "io"))
      ;;        (windowp (get-window-with-purpose "main")))
      (mrsilver/setup-layout)
      (message "imperial layout115 line")
      )

    (with-selected-window  window-i (switch-to-buffer "*Completions*"))
    (with-selected-window  window-io (switch-to-buffer "*erc*"))
    (with-selected-window  window-main (switch-to-buffer "*scratch*"))

    )




  ;; 拦截分屏函数
  (defun split-window-wrapper (orig-fun &rest args)
    "根据 split-window-enabled 决定是否允许分屏。"
    (if split-window-enabled
      (apply orig-fun args)  ; 允许分屏
      ;;(message "⚠️ 分屏操作已禁用，无法创建新窗口。")
      (ding)
      nil))  ; 不执行原函数

  ;; 拦截所有分屏相关函数
  (advice-add 'split-window :around #'split-window-wrapper)
  (advice-add 'split-window-horizontally :around #'split-window-wrapper)
  (advice-add 'split-window-vertically :around #'split-window-wrapper)
  (advice-add 'split-window-sensibly :around #'split-window-wrapper)

;; 拦截 display-buffer 和 pop-to-buffer（可能分屏）

(defun force-display-buffer-wrapper (orig-fun buffer-or-name &rest args)
  "Respect display-buffer-alist but prevent splitting when disabled."
(if split-window-enabled

    (apply orig-fun buffer-or-name args)
      ;;alist-rule must be def
      (let ((display-buffer-alist '(('rule . ((display-buffer-reuse-window . t))))))
(message "good")
	(apply orig-fun buffer-or-name args))
      )
    )


  (defun force-display-buffer-window1 (orig-fun &rest args)
    "force display-buffer obey alist"
    (if split-window-enabled
      (apply orig-fun args)
      ;;alist-rule must be def
      (let ((display-buffer-alist '(('rule . ((display-buffer-reuse-window . t))))))
	(apply orig-fun args))
      )
    )


  (advice-add 'display-buffer :around #'force-display-buffer-wrapper)
  (advice-add 'pop-to-buffer :around #'force-display-buffer-wrapper)
  (setq display-buffer-alist '((rule . alist-rule2)))
  ;; 启动时确保布局存在
  (add-hook 'after-init-hook 'ensure-layout)




  ;; 颜色定制（需放在配置最后）
  ;;(set-face-attribute 'mode-line nil
  ;;  :background "orange" :foreground "gold")

  ;;(force-mode-line-update)

  (provide 'imperial-layout)
