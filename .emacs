;; feedback
(setq visible-bell t)
(blink-cursor-mode nil)
(setq ring-bell-function 'ignore)
;;(toggle-debug-on-error)

;; coding
(prefer-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)

;; cedet and ecb bugfix
(setq stack-trace-on-error t)

;; 设置附加的加载目录
(when (not (file-accessible-directory-p "~/.emacs.d/lisps"))
  (make-directory "~/.emacs.d/lisps"))
(add-to-list 'load-path "~/.emacs.d/lisps/")
(add-to-list 'load-path "~/.emacs.d/auto-install/")

;; elpa
(require 'package)
(setq package-archives '(("gnu" . "http://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.ustc.edu.cn/elpa/melpa/")
                         ("melpa-stable" . "http://mirrors.ustc.edu.cn/elpa/melpa-stable/")
                         ("org" . "http://mirrors.ustc.edu.cn/elpa/org/")))
(package-initialize)

;; 管理elpa提供的库
(defun elpa-require (module &optional package)
  (if (require module nil 'noerror) nil
    (unless package-archive-contents
      (package-refresh-contents))
    (if (eq package nil)
        (package-install module)
      (package-install package))
    (message "module installed")
    (require module)
    )
  )

;; 管理通过url访问的库
(defun mi-use-package-url (name url)
  (let ((file (concat "~/.emacs.d/lisps/" name))
        (url-request-method "GET")
        (url-request-extra-headers nil)
        (url-mime-accept-string "*/*")
        )
    (unless (file-exists-p file)
      (let ((file-buffer-name (url-retrieve-synchronously url)))
        (with-current-buffer file-buffer-name
          (set-buffer-multibyte t)
          (goto-char (search-forward "\n\n"))
          (decode-coding-region
           (point) (point-max)
           (coding-system-change-eol-conversion
            (detect-coding-region (point-min) (point-max) t) 'dos))
          (setq data-begin (point))
          (setq data-end (point-max))
          (with-current-buffer (get-buffer-create (concat name "-mi-download"))
            (insert-buffer-substring file-buffer-name data-begin data-end)
            (setq buffer-file-name file)
            (save-buffer)
            (kill-buffer)
            )
          (kill-buffer)
          )
        )
      (byte-compile-file file)
      )
    )
  )
(defun mi-require-url (module name url)
  (mi-use-package-url name url)
  (require module nil 'noerror))

;; 使用git管理包
(defun mi-add-git (name)
  (add-to-list 'load-path (concat "~/.emacs.d/lisps/" name))
  )
(defun mi-require-git (module name url)
  (if (require module nil 'noerror) nil
    (message (concat "Git cloning from " url))
    (shell-command (concat (concat "git clone --depth 1 " url) (concat " ~/.emacs.d/lisps/" name)))
    (message (concat "Please use root account to compile the " (concat "~/.emacs.d/lisps/" name)))
    )
  )
(defun mi-use-git (module name url)
  (if (featurep module) nil
    (message (concat "Git cloning from " url))
    (shell-command (concat (concat "git clone --depth 1 " url) (concat " ~/.emacs.d/lisps/" name)))
    )
  )

;; 让emacs可以找到执行文件
(defun mi-add-exec-path (path)
  (setenv "PATH" (concat (concat path ":") (getenv "PATH")))
  (setq exec-path (split-string (getenv "PATH") path-separator))
  )
(mi-add-exec-path "/opt/local/bin:/opt/local/sbin")

;; 使用emacs的可视化配置保存的参数
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(ecb-layout-window-sizes nil)
 '(ecb-options-version "2.40")
 '(ecb-source-path (quote (("/opt/local/include" "Local Headers") ("/" "/"))))
 '(global-auto-revert-mode t)
 '(global-hl-line-mode 1)
 '(global-linum-mode 1)
 '(global-tool-bar-mode nil)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(initial-scratch-message "")
 '(linum-format "%-5d")
 '(package-selected-packages
   (quote
    (cmake-mode ssh-config-mode php-mode yaml-mode jedi python-environment go-guru go-eldoc go-mode company actionscript-mode realgud helm-go-package ac-helm gorepl-mode pyimport python-docstring virtualenv python-mode flycheck find-file-in-project grep+ icicles logview shell-here shell-command bash-completion dash-at-point w3m imenu+ imenu-anywhere helm-dash flycheck-gometalinter helm-flycheck flymake-go helm-anything helm-projectile magit helm geben ac-html window-number undo-tree tss tide thrift rainbow-delimiters python-info pylint php-scratch php-extras php-eldoc mmm-mode js2-mode jedi-direx hlinum golint go-stacktracer go-projectile go-playground go-impl go-gopath go-errcheck go-dlv go-autocomplete flycheck-pyflakes erlang ecb dired-toggle dired-single dired-open dired-filetype-face dired-efap composer bison-mode auto-compile anything ac-php ac-etags ac-c-headers)))
 '(scroll-bar-mode (quote right))
 '(show-paren-mode t)
 '(tab-width 4)
 '(tool-bar-mode nil))

;; 最大化窗口
(defun my-maximum ()
  (interactive)
  (cond ((eq window-system 'x)
         (x-send-client-message nil 0 nil "_NET_WM_STATE" 32 '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0))
         (x-send-client-message nil 0 nil "_NET_WM_STATE" 32 '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
         (sit-for 0.1)
         )
        ((eq window-system 'w32)
         (w32-send-sys-command #xf030)
         )
        ((eq window-system 'ns)
         )
        )
  )

;; 配置颜色色系
(defun my-colors ()
  (interactive)
  (cond ((eq window-system 'ns)
         (setq x-colors (ns-list-colors))
         )
        )
  )

;; dired
(elpa-require 'dired-single)
(elpa-require 'dired-toggle)
(elpa-require 'dired-efap)
(elpa-require 'dired-open)
(elpa-require 'dired-filetype-face)
(setq-default dired-omit-files-p t)
(setq dired-omit-files "\\.pdf$\\|\\.tex$|\\.DS_Store$")
(setq dired-default-buffer-name "*Dired*")

;; mmm-mode
(elpa-require 'mmm-mode)

;; hl-line
(set-face-background 'hl-line "color-255")
(elpa-require 'hlinum)
(hlinum-activate)

;; yes-or-no.
(defun my-mumble-or-no-p (prompt)
  (if (string= "no"
               (downcase
                (read-from-minibuffer
                 (concat prompt "(yes[enter] or no) "))))
      nil
    t))
(defun my-mumble-or-n-p (prompt)
  (if (string= "n"
               (downcase
                (read-from-minibuffer
                 (concat prompt "(y[enter] or n) "))))
      nil
    t))
(defalias 'yes-or-no-p 'my-mumble-or-no-p)
(defalias 'y-or-n-p 'my-mumble-or-n-p)

;; hl-paren
(defun my-hlparen ()
  (elpa-require 'rainbow-delimiters)
  )
(add-hook 'prog-mode-hook 'my-hlparen)

;; window-number
(elpa-require 'window-number)
(window-number-mode)
(window-number-meta-mode)

;; icicles.
(defun my-icicle ()
  (elpa-require 'icicles)
  (icy-mode 1)
  )
;(add-hook 'after-init-hook 'my-icicle)

;; backups.
(setq make-backup-files nil)
(defvar backup-dir "~/.emacs.d/backups/")
(setq backup-directory-alist (list (cons "." backup-dir)))

;; diff
(setq ediff-split-window-function 'split-window-horizontally)

;; 过滤掉一般不需要访问的文件
(setq my-ignores '("\\.DS_Store" "\\.git" "\\.svn" "\\.cvs" "\\.ede\\'" "\\`~" "\\`#" ".pyc\\'" "\\`tmp" "\\.o\\'" "\\`_{1}" "\\.ropeproject" "\\.scc\\'" "\\.out\\'" "\\.files\\'" "\\.class\\'" "\\.symvers\\'" "\\.order\\'" "\\.dmp\\'" "\\.tmp\\'" "\\.ncb\\'" "\\.suo\\'" "\\.usr\\'" "\\.user\\'" "\\.xcuserdatad\\'" "\\.cmd\\'"))
(ido-mode 1)
(dolist (ignore my-ignores)
  (add-to-list 'ido-ignore-files ignore))
;; 文件管理的辅助工具
(elpa-require 'find-file-in-project)

;; uniquify buffer name
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)

;; org-mode
(autoload 'org-mode "org" nil t)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; tramp
(require 'tramp)
(setq tramp-default-method "ssh")

;; save space.
(setq-default save-place-mode t)
(require 'saveplace)

;; default mode.
(defun save-cleanup()
  (whitespace-cleanup)
  nil
  )
(add-to-list 'auto-mode-alist '("\\.api\\'" . text-mode))
(defun my-text ()
  (auto-complete-mode)
  (prefer-coding-system 'utf-8)
  (add-hook 'write-contents-functions 'save-cleanup)
  )
(add-hook 'text-mode-hook 'my-text)

;; bison.
(add-to-list 'auto-mode-alist '("\\.ypp$" . bison-mode))
(add-to-list 'auto-mode-alist '("\\.y++$" . bison-mode))

;; 在file的父目录搜索目标文件
(defun find-file-ancestor (file tgt)
  (when (> (string-width file) 0)
    (let ((curdir (file-name-directory file)))
      (if (file-exists-p (concat curdir tgt))
          curdir
        (find-file-ancestor (substring curdir 0 -1) tgt)
        ))))

;; Golang.
(defun go-install-tool (tool url)
  (setq gobin-path (concat (getenv "HOME") "/.go.d/bin/"))
  (if (not (file-exists-p (concat gobin-path tool)))
      (progn
        (message (concat "installing " tool))
        (shell-command (concat "go get -u " url))
        ))
  )
(defun my-go ()
  (setq go-path (concat (getenv "HOME") "/.go.d/"))
  (setenv "GOPATH" go-path)
  (setenv "GOROOT" "/opt/local/lib/go")
  (mi-add-exec-path (concat go-path "bin/"))
  (go-install-tool "gocode" "github.com/nsf/gocode")
  (go-install-tool "golint" "github.com/golang/lint/golint")
  (go-install-tool "guru" "golang.org/x/tools/cmd/guru")
  (go-install-tool "godoc" "golang.org/x/tools/cmd/godoc")
  (go-install-tool "goimports" "golang.org/x/tools/cmd/goimports")
  (go-install-tool "gorename" "golang.org/x/tools/cmd/gorename")
  (go-install-tool "godef" "github.com/rogpeppe/godef")
  (go-install-tool "errcheck" "github.com/kisielk/errcheck")
  (if (go-install-tool "gometalinter" "github.com/alecthomas/gometalinter")
      (shell-command "gometalinter --install"))
  (go-install-tool "impl" "github.com/josharian/impl")
  (go-install-tool "gore" "github.com/motemen/gore")
  ;;(go-install-tool "spew" "github.com/davecgh/go-spew/spew")
  (elpa-require 'go-dlv)
  (elpa-require 'go-eldoc)
  (elpa-require 'go-autocomplete)
  (elpa-require 'go-playground)
  (elpa-require 'go-errcheck)
  (elpa-require 'go-gopath)
  (elpa-require 'go-guru)
  (elpa-require 'go-impl)
  (elpa-require 'go-projectile)
  (elpa-require 'go-stacktracer)
  (elpa-require 'golint)
  (elpa-require 'gorepl-mode)
  (elpa-require 'realgud)
  ;; auto set gopath
  (let ((cfgfile (find-file-ancestor buffer-file-name ".go.cfg")))
    (when cfgfile
      (setq gocfg (json-read-file (concat cfgfile ".go.cfg")))
      (setq gopath (concat cfgfile (cdr (assoc 'GOPATH gocfg))))
      (message (concat "GOPATH:" gopath))
      (setenv "GOPATH" gopath)
      ))
  ;; cfg
  (add-to-list 'ac-sources 'ac-source-go)
  (my-autocomplete)
  (go-eldoc-setup)
  (elpa-require 'helm-go-package)
  (substitute-key-definition 'go-import-add 'helm-go-package go-mode-map)
  ;;(elpa-require 'flycheck-gometalinter)
  ;;(flycheck-mode t)
  ;;(flycheck-gometalinter-setup)
  (setq-local helm-dash-docsets '("Go"))
  (go-guru-hl-identifier-mode)
  ;; autofmt
  (setq gofmt-command "goimports")
  (add-hook 'write-contents-functions (lambda () (gofmt-before-save) nil))
  ;; compile in emacs
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
           "go build -v && go test -v && go vet"))
  )

(defun my-setup-go ()
  (elpa-require 'go-mode)
  (add-hook 'go-mode-hook 'my-go)
  (go-mode)
  )
(add-to-list 'auto-mode-alist '("\\.go$" . my-setup-go))

;; php.
(defun my-php ()
  (elpa-require 'composer)
  (elpa-require 'geben)
  (elpa-require 'php-eldoc)
  (elpa-require 'php-scratch)
  (elpa-require 'ac-php)
  (yas-global-mode t)
  (my-autocomplete)
  (ac-php-mode t)
  (add-to-list 'ac-sources 'ac-source-php)
  ;;(define-key php-mode-map  (kbd "C-]") 'ac-php-find-symbol-at-point)   ;goto define
  ;;(define-key php-mode-map  (kbd "C-t") 'ac-php-location-stack-back   ) ;go back
  (add-hook 'write-contents-functions
            (lambda ()
              (whitespace-cleanup)
              (ac-php-remake-tags)
              nil))
  )
(defun my-setup-php ()
  (elpa-require 'php-mode)
  (add-hook 'php-mode-hook 'my-php)
  (php-mode)
  )
(add-to-list 'auto-mode-alist '("\\.php$" . my-setup-php))
(add-to-list 'auto-mode-alist '("\\.volt$" . my-setup-php))

(defun create-php-project ()
  (interactive)
  (let ((prj (read-directory-name "project dir:")))
    (with-current-buffer (get-buffer-create ".ac-php-config.json")
      (insert "{\"use-cscope\":false,\"filter\":{\"php-file-ext-list\":[\"php\"],\"php-path-list\":[\".\"],\"php-path-list-without-subdir\":[]}}")
      (setq buffer-file-name (concat prj ".ac-php-conf.json"))
      (save-buffer)
      (kill-buffer)
      ))
  (ac-php-remake-tags-all)
  )

;; vcm.
(elpa-require 'magit)

;; flycheck
(elpa-require 'flycheck)

;; python.
(defun my-py-settings ()
  (elpa-require 'python)
  (elpa-require 'python-mode)
  (elpa-require 'virtualenv)
  (elpa-require 'python-environment)
  (elpa-require 'python-info)
  (elpa-require 'python-docstring)
  (elpa-require 'pyimport)
  (elpa-require 'pylint)
  (elpa-require 'jedi)
  (elpa-require 'jedi-direx)
  (elpa-require 'flycheck-pyflakes)
  (flycheck-mode)
  (jedi:ac-setup)
  )
(add-hook 'python-mode-hook 'my-py-settings)

;; html.
(defun my-html ()
  (elpa-require 'ac-html)
  (require 'ac-html-default-data-provider)
  (ac-html-enable-data-provider 'ac-html-default-data-provider)
  (auto-complete-mode)
  )
(add-hook 'html-mode-hook 'my-html)

;; javascript.
(defun my-js-settings ()
  (elpa-require 'js2-mode)
  (add-to-list 'interpreter-mode-alist '("node" . js2-mode))
  )
(add-hook 'js-mode-hook 'my-js-settings)

;; typescript
(defun my-typescript-settings ()
  (auto-complete-mode)
  ;(elpa-require 'tss)
  ;(tss-config-default)
  )
(defun my-setup-ts ()
  (elpa-require 'typescript)
  (elpa-require 'tide)
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.tsc\\'" . typescript-mode))
  (add-hook 'typescript-mode-hook 'my-typescript-settings)
  (typescript-mode)
  )
(add-to-list 'auto-mode-alist '("\\.ts$" . my-setup-ts))
(add-to-list 'auto-mode-alist '("\\.tsc$" . my-setup-ts))

;; actionscript.
(defun my-setup-as ()
  (elpa-require 'actionscript-mode)
  (actionscript-mode)
  )
(add-to-list 'auto-mode-alist '("\\.as$" . my-setup-as))

;; cmake.
(defun my-setup-cmake ()
  (elpa-require 'cmake-mode)
  (cmake-mode)
  )
(setq auto-mode-alist
      (append
       '(("CMakeLists\\.txt\\'" . my-setup-cmake))
       '(("\\.cmake\\'" . my-setup-cmake))
       auto-mode-alist))

;; yaml.
(defun my-setup-yaml ()
  (elpa-require 'yaml-mode)
  (yaml-mode)
  )
(add-to-list 'auto-mode-alist '("\\.ya?ml$" . my-setup-yaml))

;; lua.
(defun my-setup-lua ()
  (elpa-require 'lua-mode)
  (lua-mode)
  )
(add-to-list 'auto-mode-alist '("\\.lua$" . my-setup-lua))

;; autocomplete.
(defun my-autocomplete ()
  (elpa-require 'auto-complete)
  (elpa-require 'ac-etags)
  (require 'auto-complete-config)
  (add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
  (ac-config-default)
  ;;(global-auto-complete-mode t)
  )
(add-hook 'text-mode-hook 'my-autocomplete)

;; lisp.
(defun my-lisp ()
  ;; autocompile
  (elpa-require 'auto-compile)
  (auto-compile-on-load-mode 1)
  (auto-compile-on-save-mode 1)
  (auto-complete-mode t)
  )
(add-hook 'emacs-lisp-mode-hook 'my-lisp)

;; helm.
(defun my-helm ()
  (elpa-require 'helm)
  (require 'helm-config)
  (elpa-require 'ac-helm)
  ;(elpa-require 'helm-anything)
  (elpa-require 'helm-projectile)
  (elpa-require 'helm-flycheck)
  (elpa-require 'dash)
  (elpa-require 'helm-dash)
  (elpa-require 'dash-at-point)
  (global-set-key (kbd "M-x") 'helm-M-x)
  (setq helm-dash-browser-func 'eww)
  )
(add-hook 'after-init-hook 'my-helm)

;; ede.
(defun my-ede ()
  (elpa-require 'ede)
  (global-ede-mode t)
  )
(add-hook 'after-init-hook 'my-ede)

;; cedet
(defun my-cedet-setting ()
  (custom-set-variables
   '(semantic-default-submodes '(global-semantic-decoration-mode
                                 global-semantic-idle-completions-mode
                                 global-semantic-idle-scheduler-mode
                                 global-semantic-idle-summary-mode
                                 global-semantic-mru-bookmark-mode
                                 global-semantic-highlight-edits-mode
                                 global-semanticdb-minor-mode
                                 ))
   '(semantic-idle-scheduler-idle-time 2)
   )
  (setq semantic-c-dependency-system-include-path '(
                                                    "/usr/include/"
                                                    "/usr/local/include/"
                                                    "/opt/local/include/"
                                                    ))
  )

(defun my-semantic-c-processed-files ()
  (if (string-match ".h[px]*$" buffer-file-name)
      ;; if file is c-header, add to semantic
      (progn
        (if (boundp 'semantic-lex-c-preprocessor-symbol-file)
            (add-to-list 'semantic-lex-c-preprocessor-symbol-file buffer-file-name)
          )
        )
    )
  )
(add-hook 'find-file-hook 'my-semantic-c-processed-files)

(defun check-expansion ()
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
        (backward-char 1)
        (if (looking-at "->") t
            nil)
          ))))

(defun tab-indent-or-complete ()
  (interactive)
  (if (minibufferp)
      (minibuffer-complete)
    (if (check-expansion)
        (auto-complete)
      (indent-for-tab-command))
    )
  )

(defun my-cedet-keymap ()
  (local-set-key (kbd "RET") 'newline-and-indent)
  (local-set-key (kbd "TAB") 'tab-indent-or-complete)
  )

(defun my-cedet-setup ()
  (my-cedet-setting)
  )

(defun my-cedet-launch ()
  (semantic-mode)
  (my-cedet-keymap)
  )

;; ecb
(defun my-ecb-layouts ()
  (setq ecb-windows-width 30)
  (ecb-layout-define "my-layout" left nil
                     (ecb-split-ver 0.4 t)
                     (if (fboundp (quote ecb-set-directories-buffer)) (ecb-set-directories-buffer) (ecb-set-default-ecb-buffer))
                     (dotimes (i 1) (other-window 1) (if (equal (selected-window) ecb-compile-window) (other-window 1)))
                     (ecb-split-ver 0.5 t)
                     (if (fboundp (quote ecb-set-sources-buffer)) (ecb-set-sources-buffer) (ecb-set-default-ecb-buffer))
                     (dotimes (i 1) (other-window 1) (if (equal (selected-window) ecb-compile-window) (other-window 1)))
                     (if (fboundp (quote ecb-set-methods-buffer)) (ecb-set-methods-buffer) (ecb-set-default-ecb-buffer))
                     (dotimes (i 2) (other-window 1) (if (equal (selected-window) ecb-compile-window) (other-window 1)))
                     (dotimes (i 3) (other-window 1) (if (equal (selected-window) ecb-compile-window) (other-window 1)))
                     )
  (ecb-layout-switch "my-layout")
  )

(unless (boundp 'x-max-tooltip-size)
  (setq x-max-tooltip-size '(80 . 40)))

(defun my-ecb-setting ()
  (setq
   global-ede-mode t
   ecb-auto-activate t
   ecb-tip-of-the-day nil
   inhibit-startup-message t
   ecb-auto-compatibility-check nil
   ecb-version-check nil
   )
  )

(defun my-ecb-keys ()
   ;(local-set-key "." 'semantic-complete-self-insert)
   ;(local-set-key ">" 'semantic-complete-self-insert)
  )

(defun my-ecb-setup ()
  (my-cedet-setup)
  (elpa-require 'ecb-autoloads 'ecb)
  (my-ecb-setting)
  (my-ecb-keys)
  (ecb-activate)
  (my-ecb-layouts)
  (my-cedet-launch)
  )

;; mydev
(defun mydev ()
  (interactive)
  )
(defun mydev-start ()
  (run-with-idle-timer 0.01 nil 'mydev)
  )

;; heander to source.
(defun my-h2s ()
  (elpa-require 'cl-lib)
  (mi-require-url 'eassist "eassist.el" "https://raw.githubusercontent.com/wybosys/wybosys/master/el/eassist.el")
  (setq eassist-header-switches
        '(("h" . ("cpp" "cxx" "c++" "CC" "cc" "C" "c" "mm" "m"))
          ("hh" . ("cc" "CC" "cpp" "cxx" "c++" "C"))
          ("hpp" . ("cpp" "cxx" "c++" "cc" "CC" "C"))
          ("hxx" . ("cxx" "cpp" "c++" "cc" "CC" "C"))
          ("h++" . ("c++" "cpp" "cxx" "cc" "CC" "C"))
          ("H" . ("C" "CC" "cc" "cpp" "cxx" "c++" "mm" "m"))
          ("HH" . ("CC" "cc" "C" "cpp" "cxx" "c++"))
          ("cpp" . ("hpp" "hxx" "h++" "HH" "hh" "H" "h"))
          ("cxx" . ("hxx" "hpp" "h++" "HH" "hh" "H" "h"))
          ("c++" . ("h++" "hpp" "hxx" "HH" "hh" "H" "h"))
          ("CC" . ("HH" "hh" "hpp" "hxx" "h++" "H" "h"))
          ("cc" . ("hh" "HH" "hpp" "hxx" "h++" "H" "h"))
          ("C" . ("hpp" "hxx" "h++" "HH" "hh" "H" "h"))
          ("c" . ("h"))
          ("m" . ("h"))
          ("mm" . ("h"))
          ))
  (local-set-key "\M-o" 'eassist-switch-h-cpp)
  )

;; c mode.
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.c\\'" . c++-mode))
(defun my-c-mode ()
  (interactive)
  (setq c-basic-offset 4)
  (my-h2s)
  )
(add-hook 'c-mode-common-hook
          '(lambda ()
             (my-c-mode)
             (mydev-start)
             ))

;; bash.
(defun my-bash()
  (elpa-require 'bash-completion)
  (bash-completion-setup)
  (elpa-require 'shell-command)
  (elpa-require 'shell-here)
  )
(add-hook 'shell-mode-hook 'my-bash)

;; anything
; (elpa-require 'anything)

;; protobuf
(defun my-setup-pb ()
  (elpa-require 'protobuf-mode)
  (protobuf-mode)
  )
(add-to-list 'auto-mode-alist '("\\.proto\\'" . my-setup-pb))

;; erlang
(defun my-erlang ()
  (elpa-require 'erlang)
  (flycheck-mode)
  (add-to-list 'ac-modes 'erlang-mode)
  (add-to-list 'load-path "~/.emacs.d/lisps/distel/elisp")
  (mi-require-git 'distel "distel" "https://github.com/massemanet/distel.git")
  (distel-setup)
  )
(defun my-setup-erl ()
  (elpa-require 'erlang)
  (setq erlang-root-dir "/opt/local/lib/erlang/")
  (add-hook 'erlang-mode-hook 'my-erlang)
  (erlang-mode)
  )
(add-to-list 'auto-mode-alist '("\\.erl$" . my-setup-erl))

;; log.
(defun my-log ()
  (elpa-require 'logview)
  (end-of-buffer)
  (add-hook 'after-revert-hook 'end-of-buffer)
  )
(add-to-list 'auto-mode-alist '("\\.log$" . my-log))

;; apache httpd.
(defun my-setup-httpd ()
  (elpa-require 'apache-mode)
  (apache-mode)
  )
(add-to-list 'auto-mode-alist '("\\.htaccess\\'"   . my-setup-httpd))
(add-to-list 'auto-mode-alist '("httpd\\.conf\\'"  . my-setup-httpd))
(add-to-list 'auto-mode-alist '("httpd-[[:ascii:]]+\\.conf\\'"  . my-setup-httpd))
(add-to-list 'auto-mode-alist '("srm\\.conf\\'"    . my-setup-httpd))
(add-to-list 'auto-mode-alist '("access\\.conf\\'" . my-setup-httpd))
(add-to-list 'auto-mode-alist '("sites-\\(available\\|enabled\\)/" . my-setup-httpd))

;; nginx mode.
(defun my-setup-nginx ()
  (elpa-require 'nginx-mode)
  (require 'nginx-mode)
  (setq nginx-indent-level 4)
  (nginx-mode)
  )
(add-to-list 'auto-mode-alist '("nginx\\.conf\\'" . my-setup-nginx))
(add-to-list 'auto-mode-alist '("nginx/conf\\.d/[[:ascii:]]+\\.conf\\'" . my-setup-nginx))

;; ssh mode.
(elpa-require 'ssh-config-mode)
(add-to-list 'auto-mode-alist '(".ssh/config\\'"  . ssh-config-mode))
(add-to-list 'auto-mode-alist '("sshd?_config\\'" . ssh-config-mode))

;; script style.
(defconst my-c-style
  '(
    (c-tab-always-indent . t)
    (c-comment-only-line-offset . 0)
    (c-hanging-braces-alist     . ((substatement-open before)
                                   (brace-list-open)
                                   ))
    (c-hanging-colons-alist     . ((member-init-intro before)
                                   (inher-intro)
                                   (case-label after)
                                   (label after)
                                   (access-label after)
                                   ))
    (c-cleanup-list             . (scope-operator
                                   empty-defun-braces
                                   defun-close-semi))
    (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
                                   (substatement-open . 0)
                                   (access-label      . -)
                                   (case-label        . +)
                                   (inline-open       . 0)
                                   (block-open        . 0)
                                   (knr-argdecl-intro . -)
                                   (innamespace . 0)
                                   ))
    ;(c-echo-syntactic-information-p . t) // verbose while indent.
    )
  "My C script style."
  )
(c-add-style "my-cstyle" my-c-style)

(setq c-default-style
      '((c-mode . "my-cstyle") ;; stroustrup
        (c++-mode . "my-cstyle")
        (java-mode . "java")
        (awk-mode . "awk")
        (other . "gnu")
        ))

;; hex mode.
(add-to-list 'auto-mode-alist '("\\.wav\\'" . hexl-mode))

;; buffer
(defun my-switch-to-lastbuffer ()
  (interactive)
  (switch-to-buffer nil)
  )

;; xml
(defun xml-format()
  (interactive)
  (save-excursion
    (shell-command-on-region (mark) (point)
                             "tidy -i -xml -utf8 --quiet y -" (buffer-name) t)
    )
  )
(defun xml-pretty()
  (interactive)
  (save-excursion
    (shell-command-on-region (mark) (point)
                             "tidy -i -xml -utf8 --quiet y --indent-attributes y -" (buffer-name) t)
    )
  )
(add-to-list 'auto-mode-alist '("\\.gpx\\'" . xml-mode))

;; yml
(defun my-setup-yml()
  (elpa-require 'yaml-mode)
  (yaml-mode)
  )
(add-to-list 'auto-mode-alist '("\\.yml$" . my-setup-yml))

;; global bind keys.
(global-set-key (kbd "C-x <left>") 'my-switch-to-lastbuffer)
(global-set-key (kbd "C-x <right>") 'other-window)
(global-set-key (kbd "<M-up>") 'previous-buffer)
(global-set-key (kbd "<M-down>") 'next-buffer)
(global-set-key (kbd "C-x C-<up>") 'scroll-other-window-down)
(global-set-key (kbd "C-x C-<down>") 'scroll-other-window)
(global-set-key (kbd "C-<tab>") 'my-switch-to-lastbuffer)
(global-set-key (kbd "<mouse-1>") 'mouse-set-point)
(global-set-key (kbd "<down-mouse-1>") 'mouse-drag-region)
(global-set-key (kbd "C-<down>") 'forward-paragraph)
(global-set-key (kbd "C-<up>") 'backward-paragraph)
(global-set-key (kbd "<end>") 'bookmark-set)
(global-set-key (kbd "<home>") 'bookmark-jump)
(global-set-key (kbd "C-x C-f") 'ido-find-file)
(global-set-key (kbd "C-c C-d") 'dired-toggle)
(global-set-key (kbd "C-c C-c") 'compile)

;; suspend
(global-unset-key (kbd "C-z"))
(global-set-key (kbd "C-z C-z") 'my-suspend-frame)
(defun my-suspend-frame ()
  "In a GUI environment, do nothing; otherwise `suspend-frame'."
  (interactive)
  (if (display-graphic-p)
      (message "suspend-frame disabled for graphical displays.")
    (suspend-frame)))

;; clipboard
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

(cond ((eq system-type 'darwin)
       (setq interprogram-cut-function 'paste-to-osx)
       (setq interprogram-paste-function 'copy-from-osx)
       )
      )

;; duplicate line
(defun dublicate-line ()
  (interactive)
  (save-excursion
    (let ((begin (line-beginning-position))
          (end (line-end-position)))
      (move-beginning-of-line 2)
      (insert (concat (buffer-substring-no-properties begin end) "\n")))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#FFFFFF" :foreground "#000000" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "outline"))))
 '(linum ((t (:inherit (shadow default) :background "#FFFFFF")))))

;; 当使用gui模式打开
(defun my-gui ()
  (my-colors)
  (custom-set-faces
   '(default ((t (:inherit nil :stipple nil :background "#FFFFFF" :foreground "#000000" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 128 :width normal :foundry nil))))
   '(linum ((t (:inherit (shadow default) :background "#FFFFFF"))))
   )
  (set-fontset-font (frame-parameter nil 'font) 'han (font-spec :family "STSong"))
  ;; other
  (my-maximum)
  ;; 读取之前的桌面记录
  (elpa-require 'desktop)
  (desktop-save-mode 1)
  )

;; 当使用命令行模式打开
(defun my-cli ()
  (custom-set-faces
   '(default ((t (:inherit nil :stipple nil :foreground "#000000" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "outline"))))
   '(linum ((t (:inherit (shadow default)))))
   )
  )

;; gui/cli toggle
(if (not window-system)
    (my-cli)
  (my-gui)
  )
(if (fboundp 'tool-bar-mode)
    (tool-bar-mode -1)
  )
