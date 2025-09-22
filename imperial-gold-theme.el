(deftheme imperial-gold "imperial theme")

;; 配色方案
;;	•	💛 金色注释
;;	•	❤️ 血色函数
;;	•	🟣 紫色高亮
;;	•	🏛 mode-line
(defvar imperial-gold/colors
  '((midnight-bg   . "#0a0814")    ; 玄夜背景
    (royal-blood   . "#c23b3b")    ; 函数/变量定义血色
    (imperial-gold . "#e6b422")    ; 注释金色
    (ivory-milk    . "#fffaf0")    ; 普通字符乳白
    (cream-highlight . "#fffff1")  ; 高亮乳白green
    (gold-light    . "#ffed8a")    ; 辅助金色
    (crimson-shadow . "#fc7f22")   ; 血色阴影
    (regal-purple  . "#5d3a9b")    ; 装饰紫色
    (inactive-bg   . "#1f1b24")    ; 非激活模式行背景
    (inactive-fg   . "#a81159")))  ; 非激活模式行前景

(custom-theme-set-faces
 'imperial-gold
 ;; == 核心规则 ==
 `(default ((t :background ,(cdr (assoc 'midnight-bg imperial-gold/colors))
            :foreground ,(cdr (assoc 'imperial-gold imperial-gold/colors)))))
  
 ;; == 语法高亮 ==
 ;; 所有普通字符（包括关键字、符号、字符串等）
 (dolist (face '(font-lock-keyword-face
                font-lock-builtin-face
                font-lock-constant-face
                font-lock-type-face
                font-lock-doc-face
                font-lock-string-face
                font-lock-warning-face))
   (set-face-attribute face nil :foreground (cdr (assoc 'imperial-gold imperial-gold/colors))))

 ;; 函数/变量定义处 - 血色
 `(font-lock-function-name-face ((t :foreground ,(cdr (assoc 'royal-blood imperial-gold/colors)) :bold t)))
 `(font-lock-variable-name-face ((t :foreground ,(cdr (assoc 'royal-blood imperial-gold/colors)))))

 ;; 注释
 `(font-lock-comment-face ((t :foreground ,(cdr (assoc 'ivory-milk imperial-gold/colors)) :italic t)))
 ;; == 其他 UI 元素 ==
 `(line-number ((t :foreground ,(cdr (assoc 'inactive-fg imperial-gold/colors))
                   :background ,(cdr (assoc 'midnight-bg imperial-gold/colors)))))
 `(line-number-current-line ((t :foreground ,(cdr (assoc 'regal-purple imperial-gold/colors))
                                :background ,(cdr (assoc 'cream-highlight imperial-gold/colors)))))
 `(minibuffer-prompt ((t :foreground ,(cdr (assoc 'imperial-gold imperial-gold/colors))
                         :weight bold)))
 `(highlight ((t :background ,(cdr (assoc 'cream-highlight imperial-gold/colors)))))

	
	
	

;; 自定义 mode-line 各部分颜色
 `(mode-line ((t :background ,(cdr (assoc 'regal-purple imperial-gold/colors))
                 :foreground ,(cdr (assoc 'imperial-gold imperial-gold/colors))
                 :box nil
                 :height 1.05)))
 `(mode-line-inactive ((t :background ,(cdr (assoc 'inactive-bg imperial-gold/colors)) 
                        :foreground ,(cdr (assoc 'inactive-fg imperial-gold/colors)))))

 ;; 文件名
 `(mode-line-buffer-face ((t :foreground ,(cdr (assoc 'imperial-gold imperial-gold/colors))
                             :weight bold)))
 ;; 位置信息
 `(mode-line-position-face ((t :foreground ,(cdr (assoc 'imperial-gold imperial-gold/colors)))))
 ;; Git 状态
 `(mode-line-git-face ((t :foreground ,(cdr (assoc 'crimson-shadow imperial-gold/colors)))))



 `(cursor ((t :background ,(cdr (assoc 'gold-light imperial-gold/colors)))))
 `(region ((t :background ,(cdr (assoc 'crimson-shadow imperial-gold/colors)))))


)



(defvar imperial-gold/heartbeat-active t)
(defvar mode-line-modified-heart "💛")
(defun imperial-gold/heartbeat ()
  (when (and (buffer-modified-p) imperial-gold/heartbeat-active)
    (let ((faces '("❤️" "💛" "💓" "💗")))
      (setq mode-line-modified-heart
            (nth (random 4) faces))
      (force-mode-line-update))))

(defun imperial/git-branch ()
  "Return current Git branch."
  (when (and (buffer-file-name)
             (file-exists-p (buffer-file-name))
             (executable-find "git"))
    (let ((default-directory (file-name-directory (buffer-file-name))))
      (with-temp-buffer
        (call-process "git" nil t nil "rev-parse" "--abbrev-ref" "HEAD")
        (string-trim (buffer-string))))))


(setq-default mode-line-format
'(
(:propertize (:eval (if (buffer-modified-p) "🔴" "🟢")) 'face 'mode-line-buffer-face)
(:propertize "%b %e %p %l %i  %S" 'face 'mode-line-buffer-face)
" | "
(:eval (format-time-string "%d/%H:%M"))
(:propertize (:eval (format " git:%s" (imperial/git-branch))))


))
;;test
;;(force-mode-line-update)


;; 创建定时器
;;(defvar heartbeat-timer nil)
;;(setq heartbeat-timer (run-with-timer 0 3.7 #'imperial-gold/heartbeat))

;; 取消定时器
(defun cancel-mode-timer ()
  (when heartbeat-timer
    (cancel-timer heartbeat-timer)
    (setq heartbeat-timer nil)))

;;(cancel-mode-timer)







;; ======================================================================
;; == 递归括号可视化系统（自动应用于所有编程模式）==
;; ======================================================================

;; 递归括号颜色序列
(defvar imperial-gold/bracket-colors
  (list (cdr (assoc 'imperial-gold imperial-gold/colors)) ; 1. 帝王金
        (cdr (assoc 'royal-blood imperial-gold/colors))   ; 2. 血色
        (cdr (assoc 'ivory-milk imperial-gold/colors))    ; 3. 乳白
        (cdr (assoc 'gold-light imperial-gold/colors))    ; 4. 亮金
        (cdr (assoc 'regal-purple imperial-gold/colors)))) ; 5. 紫金

(defun imperial-gold/setup-bracket-colors ()
  "应用帝王金主题的递归括号配色"
  (let ((depth-colors (make-vector 10 nil)))
    (dotimes (i 10)
      (setf (aref depth-colors i)
            `((t :foreground ,(nth (mod i 5) imperial-gold/bracket-colors) 
                 :weight ultra-bold))))
    
    (custom-theme-set-faces
     'imperial-gold
     ;; 小括号 - 从帝王金开始
     `(rainbow-delimiters-depth-1-face ,(aref depth-colors 0))
     `(rainbow-delimiters-depth-2-face ,(aref depth-colors 1))
     `(rainbow-delimiters-depth-3-face ,(aref depth-colors 2))
     `(rainbow-delimiters-depth-4-face ,(aref depth-colors 3))
     `(rainbow-delimiters-depth-5-face ,(aref depth-colors 4))
     `(rainbow-delimiters-depth-6-face ,(aref depth-colors 0))
     `(rainbow-delimiters-depth-7-face ,(aref depth-colors 1))
     `(rainbow-delimiters-depth-8-face ,(aref depth-colors 2))
     `(rainbow-delimiters-depth-9-face ,(aref depth-colors 3))
     
     ;; 大括号 - 从血色开始
     `(rainbow-delimiters-depth-1-curly-face ,(aref depth-colors 1))
     `(rainbow-delimiters-depth-2-curly-face ,(aref depth-colors 2))
     `(rainbow-delimiters-depth-3-curly-face ,(aref depth-colors 3))
     `(rainbow-delimiters-depth-4-curly-face ,(aref depth-colors 4))
     `(rainbow-delimiters-depth-5-curly-face ,(aref depth-colors 0))
     `(rainbow-delimiters-depth-6-curly-face ,(aref depth-colors 1))
     `(rainbow-delimiters-depth-7-curly-face ,(aref depth-colors 2))
     `(rainbow-delimiters-depth-8-curly-face ,(aref depth-colors 3))
     `(rainbow-delimiters-depth-9-curly-face ,(aref depth-colors 4)))))

;; 配置括号颜色
(imperial-gold/setup-bracket-colors)

;; == 智能括号匹配 ==
(custom-theme-set-faces
 'imperial-gold
 `(show-paren-match ((t :background ,(cdr (assoc 'crimson-shadow imperial-gold/colors))
                       :foreground ,(cdr (assoc 'gold-light imperial-gold/colors))
                       :weight ultra-bold
                       :box (:line-width -1 :color ,(cdr (assoc 'royal-blood imperial-gold/colors))))))
 
 `(show-paren-mismatch ((t :background ,(cdr (assoc 'royal-blood imperial-gold/colors))
                         :foreground ,(cdr (assoc 'cream-highlight imperial-gold/colors))
                         :weight ultra-bold))))

;; ======================================================================
;; == 自动启用递归括号可视化（所有编程模式hook）==
;; ======================================================================
(defun imperial-gold/enable-bracket-visualization ()
  "为所有编程模式启用递归括号可视化"
  (require 'rainbow-delimiters)
  (rainbow-delimiters-mode t)
  (show-paren-mode t))

;; 添加到所有编程模式的hook
(add-hook 'prog-mode-hook #'imperial-gold/enable-bracket-visualization)



;; 可选：禁用其他主题
(mapc #'disable-theme custom-enabled-themes)
;; 启用主题
(enable-theme 'imperial-gold)
;;(force-mode-line-update)
(provide-theme 'imperial-gold)
