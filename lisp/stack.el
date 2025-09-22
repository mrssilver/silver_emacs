;;work for mr silver
;;100 % work

(defvar region-content-stack nil
  "堆栈用于存储区域内容。")
(defvar buf "**stack")
(defun region-push-content (beg end)
  "将选中的区域内容推送到堆栈中，并删除原区域内容。"
  (interactive "r")
  (when (use-region-p)
    (let ((content (buffer-substring beg end)))
      (push content region-content-stack)
      (delete-region beg end)
      (message "已推送区域内容到堆栈 (当前大小: %d)" (length region-content-stack)))))

(defun region-pop-content (&optional num)
  "将堆栈中最新的内容弹出到当前光标位置。
可选参数NUM指定弹出特定索引的内容。"
  (interactive "P")
  (if region-content-stack
      (let* ((index (if num (prefix-numeric-value num) 0))
             (content (nth index region-content-stack)))
        (if content
            (progn
              (setq region-content-stack (remove-content-from-stack index))
              (insert content)
              (message "已弹出索引 %d 的内容 (剩余: %d)" index (length region-content-stack)))
          (message "索引 %d 超出范围 (堆栈大小: %d)" index (length region-content-stack))))
    (message "堆栈为空，无内容可弹出")))

(defun remove-content-from-stack (index)
  "从堆栈中移除指定索引的内容。"
  (if (or (< index 0) (>= index (length region-content-stack)))
      region-content-stack
    (let ((result '())
          (i 0))
      (dolist (item region-content-stack)
        (when (not (= i index))
          (push item result))
        (setq i (1+ i)))
      (nreverse result))))






(defun region-list-content ()
  "显示堆栈中所有内容的列表。"
  (interactive)
  (if region-content-stack
      (progn
(get-buffer-create buf)
        ;;(switch-to-buffer "stck")
	(with-current-buffer (get-buffer-create buf)
	(read-only-mode -1)
        (erase-buffer)
        (insert "区域内容堆栈:\n\n")
        (let ((i 0))
          (dolist (content region-content-stack)
            (insert (format "%d: %s\n" i content))
            (setq i (1+ i))))
     ;; (special-mode)
	(read-only-mode t)
	)
	
	(display-buffer buf)
	)
    (message "堆栈为空")))


(defun region-pop-specific (num)
  "弹出指定索引的内容。"
  (interactive "n弹出内容的索引: ")
  (region-pop-content num))

(global-set-key (kbd "C-c p p") 'region-push-content)
(global-set-key (kbd "C-c p o") 'region-pop-content)
;;q for quit if special-mode work
;;
(global-set-key (kbd "C-c p l") 'region-list-content)
(global-set-key (kbd "C-c p s") 'region-pop-specific)


(provide 'stack)
