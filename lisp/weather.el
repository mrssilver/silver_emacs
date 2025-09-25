
(defvar openweather-api-key "YOUR_OPENWEATHER_API_KEY"
  "OpenWeatherMap API 密钥")

(defvar weather-cities '("Beijing" "Shanghai" "Guangzhou" "Shenzhen")
  "需要显示天气的城市列表")

(defvar weather-refresh-interval 3600
  "天气刷新间隔（秒）")

(defvar rain-threshold 30
  "降雨高亮阈值（降雨概率百分比）")

(defvar weather-buffer-name "*多城市天气*"
  "天气报告缓冲区的名称")

(defvar weather-active-requests 0
  "当前活动的请求数量")

(defvar weather-city-data (make-hash-table :test 'equal)
  "存储各城市天气数据")

(defvar weather-error-messages nil
  "存储错误信息")

;;; ======================
;;; 工具函数
;;; ======================

(defun weather--format-time (timestamp &optional format)
  "格式化时间戳"
  (format-time-string (or format "%Y-%m-%d %H:%M") (seconds-to-time timestamp)))

(defun weather--create-plist (item)
  "从API数据项创建属性列表"
  (let ((dt (alist-get 'dt item))
        (main (alist-get 'main item))
        (weather (car (alist-get 'weather item)))
        (pop (alist-get 'pop item))
        (rain (or (alist-get 'rain item) 0)))
    
    `(:dt ,dt
      :temp ,(alist-get 'temp main)
      :feels_like ,(alist-get 'feels_like main)
      :humidity ,(alist-get 'humidity main)
      :pressure ,(alist-get 'pressure main)
      :description ,(alist-get 'description weather)
      :icon ,(alist-get 'icon weather)
      :pop ,pop
      :rain ,(if (consp rain) (alist-get '3h rain) rain) ; 处理3小时降雨量
      :wind_speed ,(alist-get 'speed (alist-get 'wind item)))))

(defun weather--filter-by-time-range (hourly-data days-back days-forward)
  "按时间范围过滤数据"
  (let ((now (time-to-seconds (current-time)))
        (min-time (- now (* days-back 24 3600)))
        (max-time (+ now (* days-forward 24 3600))))
    
    (cl-remove-if-not (lambda (hour)
                       (let ((dt (plist-get hour :dt)))
                         (and (>= dt min-time) (<= dt max-time))))
                     hourly-data)))

(defun weather--group-by-date (hourly-data)
  "按日期对小时数据进行分组"
  (let ((daily-table (make-hash-table :test 'equal)))
    (dolist (hour hourly-data)
      (let ((date (weather--format-time (plist-get hour :dt) "%Y-%m-%d")))
        (push hour (gethash date daily-table '()))))
    daily-table))

(defun weather--calculate-daily-stats (hours)
  "计算每日统计信息"
  (when hours
    (let ((temps (mapcar (lambda (h) (plist-get h :temp)) hours))
          (pops (mapcar (lambda (h) (plist-get h :pop)) hours))
          (rains (mapcar (lambda (h) (plist-get h :rain)) hours)))
      
      `(:max-temp ,(apply #'max temps)
        :min-temp ,(apply #'min temps)
        :avg-pop ,(/ (apply #'+ pops) (length pops))
        :total-rain ,(apply #'+ rains)
        :hours ,(length hours)))))

;;; ======================
;;; API 请求处理
;;; ======================

(defun weather-start-request (city)
  "启动一个城市的天气请求"
  (condition-case err
      (progn
        (cl-incf weather-active-requests)
        (let ((url (format "http://api.openweathermap.org/data/2.5/forecast?q=%s&appid=%s&units=metric&lang=zh_cn"
                          (url-hexify-string city)
                          openweather-api-key)))
          (url-retrieve url 'weather-api-callback (list city))))
    (error 
     (message "启动 %s 天气请求失败: %s" city (error-message-string err))
     (cl-decf weather-active-requests))))

(defun weather-api-callback (status city)
  "天气API回调函数"
  (let ((data-buffer (current-buffer)))
    (unwind-protect
        (cond
         ((eq (car status) :error)
          (let ((error-msg (format "%s: %s" city (cdr status))))
            (push error-msg weather-error-messages)
            (message "获取 %s 天气失败: %s" city (cdr status))))
         
         (t
          (goto-char (point-min))
          (if (re-search-forward "\r?\n\r?\n" nil t)
              (let* ((json-str (buffer-substring (point) (point-max)))
                     (data (ignore-errors (json-read-from-string json-str))))
                
                (if data
                    (weather-process-data city data)
                  (push (format "%s: JSON解析失败" city) weather-error-messages)))
            (push (format "%s: 无效的API响应" city) weather-error-messages))))
      
      (when (buffer-live-p data-buffer)
        (kill-buffer data-buffer)))
    
    (cl-decf weather-active-requests)
    (when (<= weather-active-requests 0)
      (weather-render-report))))

;;; ======================
;;; 数据处理
;;; ======================

(defun weather-process-data (city data)
  "处理并存储天气数据"
  (condition-case err
      (let* ((city-info (gethash city weather-city-data))
             (existing-hourly (or (plist-get city-info :hourly) '()))
             (new-hourly (mapcar #'weather--create-plist 
                                (alist-get 'list data)))
             (all-hourly (append existing-hourly new-hourly))
             (filtered-hourly (weather--filter-by-time-range all-hourly 1 5))) ; 过去1天，未来5天
        
        ;; 按时间排序并去重
        (setq filtered-hourly (cl-sort filtered-hourly #'< :key (lambda (x) (plist-get x :dt))))
        (setq filtered-hourly (cl-remove-duplicates filtered-hourly 
                                                   :test (lambda (a b) 
                                                          (= (plist-get a :dt) 
                                                             (plist-get b :dt))))))
        
        ;; 分组为每日数据
        (let ((daily-data (weather--group-by-date filtered-hourly)))
          (puthash city `(:city ,city 
                         :hourly ,filtered-hourly 
                         :daily ,daily-data
                         :last-update ,(current-time))
                   weather-city-data))
    
    (error 
     (push (format "%s: 数据处理失败 - %s" city (error-message-string err)) 
           weather-error-messages))))

;;; ======================
;;; 渲染函数
;;; ======================

(defun weather-render-report ()
  "渲染天气报告"
  (let ((buffer (get-buffer-create weather-buffer-name))
        (inhibit-read-only t))
    
    (with-current-buffer buffer
      (erase-buffer)
      
      ;; 头部信息
      (weather--render-header)
      
      ;; 错误信息显示
      (when weather-error-messages
        (weather--render-errors))
      
      ;; 每日摘要表格
      (when (> (hash-table-count weather-city-data) 0)
        (weather--render-summary)
        
        ;; 各城市详细预报
        (maphash (lambda (city _) (weather--render-city-detail city)) 
                 weather-city-data))
      
      ;; 底部操作区域
      (weather--render-footer)
      
      (setq buffer-read-only t)
      (org-mode)
      (goto-char (point-min)))
    
    (display-buffer buffer)))

(defun weather--render-header ()
  "渲染报告头部"
  (insert "#+TITLE: 多城市天气监控\n")
  (insert (format "#+AUTHOR: 天气系统\n"))
  (insert (format "#+DATE: %s\n\n" (format-time-string "%Y年%m月%d日 %H:%M")))
  (insert (format "**监控城市**: %s\n\n" (string-join weather-cities "、"))))

(defun weather--render-errors ()
  "渲染错误信息"
  (insert "**❌ 错误信息**\n")
  (dolist (err weather-error-messages)
    (insert (format "- %s\n" err)))
  (insert "\n")
  (setq weather-error-messages nil))

(defun weather--render-summary ()
  "渲染每日摘要表格"
  (insert "**📊 每日天气摘要**\n\n")
  
  (let ((all-dates (weather--get-all-dates)))
    (dolist (date (cl-subseq all-dates 0 (min 5 (length all-dates)))) ; 最多显示5天
      (insert (format "*** %s (%s)\n" date (weather--get-day-name date)))
      (insert "| 城市 | 最高温 | 最低温 | 平均降雨概率 | 总降雨量 | 天气状况 |\n")
      (insert "|------|--------|--------|--------------|----------|----------|\n")
      
      (dolist (city weather-cities)
        (let* ((city-data (gethash city weather-city-data))
               (hours (when city-data (gethash date (plist-get city-data :daily)))))
          (if hours
              (let ((stats (weather--calculate-daily-stats hours))
                    (icon (plist-get (car hours) :icon)))
                (insert (format "| %s | %.1f°C | %.1f°C | %d%% | %.1fmm | {{weather:%s}} |\n"
                               city
                               (plist-get stats :max-temp)
                               (plist-get stats :min-temp)
                               (round (* (plist-get stats :avg-pop) 100))
                               (plist-get stats :total-rain)
                               icon)))
            (insert (format "| %s | - | - | - | - | 无数据 |\n" city)))))
      (insert "\n"))))

(defun weather--render-city-detail (city)
  "渲染单个城市的详细预报"
  (let ((city-data (gethash city weather-city-data)))
    (when city-data
      (insert (format "**🌤️ %s 详细天气预报**\n", city))
      (insert (format "最后更新: %s\n\n" 
                     (weather--format-time (float-time (plist-get city-data :last-update)))))
      
      (let ((daily-data (plist-get city-data :daily))
            (rain-periods '()))
        (maphash (lambda (date hours)
                   (insert (format "*** %s (%s)\n" date (weather--get-day-name date)))
                   (insert "| 时间 | 温度 | 体感 | 天气 | 降雨概率 | 降雨量 | 风速 |\n")
                   (insert "|------|------|------|------|----------|--------|------|\n")
                   
                   (dolist (hour (cl-sort hours #'< :key (lambda (h) (plist-get h :dt))))
                     (let* ((pop-percent (round (* (plist-get hour :pop) 100)))
                            (rain-highlight (>= pop-percent rain-threshold))
                            (time (weather--format-time (plist-get hour :dt) "%H:%M")))
                       
                       (when rain-highlight
                         (push (list city date time pop-percent) rain-periods))
                       
                       (insert (format "| %s | %s | %.1f°C | %s | %s | %.1fmm | %.1fm/s |\n"
                                     time
                                     (weather--format-temperature (plist-get hour :temp))
                                     (plist-get hour :feels_like)
                                     (plist-get hour :description)
                                     (weather--format-pop pop-percent rain-highlight)
                                     (plist-get hour :rain)
                                     (plist-get hour :wind_speed)))))
                   (insert "\n"))
                 daily-data)
        
        (when rain-periods
          (weather--render-rain-alerts (nreverse rain-periods)))))))

(defun weather--render-rain-alerts (periods)
  "渲染降雨警报"
  (insert "**⚠️ 降雨警报**\n")
  (insert (format "以下时间段降雨概率超过 %d%%：\n\n" rain-threshold))
  
  (let ((current-city nil)
        (current-date nil))
    (dolist (period periods)
      (let ((city (nth 0 period))
            (date (nth 1 period))
            (time (nth 2 period))
            (pop (nth 3 period)))
        
        (unless (equal city current-city)
          (insert (format "*** %s\n" city))
          (setq current-city city
                current-date nil))
        
        (unless (equal date current-date)
          (insert (format "**** %s\n" date))
          (setq current-date date))
        
        (insert (format "- %s: %d%% 降雨概率\n" time pop))))))

(defun weather--render-footer ()
  "渲染底部操作区域"
  (insert "---\n")
  (insert "**操作**\n\n")
  
  (insert (propertize "[[elisp:(weather-update)][🔄 立即更新]]" 
                     'face '(:box (:line-width 1 :color "blue") 
                            :background "light cyan")
                     'mouse-face 'highlight
                     'help-echo "点击手动刷新天气数据"))
  (insert "  ")
  
  (insert (propertize "[[elisp:(weather-set-cities)][✏️ 修改城市]]" 
                     'face '(:box (:line-width 1 :color "green") 
                            :background "honeydew")
                     'mouse-face 'highlight
                     'help-echo "点击修改监控城市列表"))
  (insert "  ")
  
  (insert (propertize "[[elisp:(weather-customize)][⚙️ 设置]]" 
                     'face '(:box (:line-width 1 :color "orange") 
                            :background "seashell")
                     'mouse-face 'highlight
                     'help-echo "点击进行系统设置"))
  (insert "\n\n"))

;;; ======================
;;; 工具函数
;;; ======================

(defun weather--get-all-dates ()
  "获取所有城市的日期列表"
  (let ((dates '()))
    (maphash (lambda (_ city-data)
               (maphash (lambda (date _) (push date dates))
                       (plist-get city-data :daily)))
             weather-city-data)
    (cl-sort (cl-remove-duplicates dates :test 'equal) 'string>)))

(defun weather--get-day-name (date)
  "获取日期对应的星期名称"
  (let ((time (date-to-time (concat date " 00:00:00"))))
    (format-time-string "%A" time)))

(defun weather--format-temperature (temp)
  "格式化温度显示"
  (let ((formatted (format "%.1f°C" temp)))
    (cond ((> temp 30) (propertize formatted 'face '(:foreground "red" :weight bold)))
          ((< temp 10) (propertize formatted 'face '(:foreground "blue" :weight bold)))
          (t (propertize formatted 'face '(:foreground "dark green"))))))

(defun weather--format-pop (pop-percent highlight)
  "格式化降雨概率显示"
  (let ((formatted (format "%d%%" pop-percent)))
    (if highlight
        (propertize formatted 'face '(:background "light coral" :weight bold))
      formatted)))

;;; ======================
;;; 用户交互函数
;;; ======================

(defun weather-update (&optional interactive)
  "手动更新天气数据"
  (interactive "p")
  (setq weather-error-messages nil)
  (clrhash weather-city-data)
  (setq weather-active-requests 0)
  
  (dolist (city weather-cities)
    (weather-start-request city))
  
  (when interactive
    (message "开始更新天气数据...")))

(defun weather-set-cities ()
  "设置监控的城市列表"
  (interactive)
  (let ((new-cities (split-string 
                    (read-string "输入城市列表(逗号分隔): " 
                                (string-join weather-cities ", "))
                    ",\\s-*")))
    (when new-cities
      (setq weather-cities new-cities)
      (weather-update t))))

(defun weather-customize ()
  "天气系统设置"
  (interactive)
  (customize-group 'weather))

(defun weather-auto-update ()
  "设置自动更新天气"
  (interactive)
  (cancel-function-timers 'weather-update) ; 清除现有定时器
  (run-with-timer 0 weather-refresh-interval 'weather-update)
  (message "天气自动更新已启用 (每 %d 秒)" weather-refresh-interval))

(defun weather-init ()
  "初始化天气系统"
  (interactive)
  (when (string= openweather-api-key "YOUR_OPENWEATHER_API_KEY")
    (error "请先设置 openweather-api-key"))
  (weather-auto-update)
  (weather-update t)
  (message "天气系统初始化完成"))

;;; ======================
;;; 提供模式
;;; ======================

(provide 'weather-monitor)

;; 初始化（可选）
;; (eval-after-load 'weather-monitor
;;   '(weather-init))
