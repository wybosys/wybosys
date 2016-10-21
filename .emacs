;; feedback
(setq visible-bell t)
(blink-cursor-mode 0)
(setq ring-bell-function 'ignore)

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
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")
                         ("tromey" . "http://tromey.com/elpa/")
                         ))    
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
  (setenv "PATH" (concat (getenv "PATH") (concat ":" path)))
  (setq exec-path (split-string (getenv "PATH") path-separator))
  )
(mi-add-exec-path "/opt/local/bin:/opt/local/sbin")

;; 使用emacs的可视化配置保存的参数
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
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
    (go-dlv go-stacktracer go-projectile go-impl go-gopath go-errcheck go-playground window-number undo-tree tss tide thrift sr-speedbar session rainbow-delimiters python-pep8 python-info pylint pyflakes mmm-mode js2-mode jedi-direx icicles hlinum golint go-autocomplete flycheck-pyflakes erlang ecb dired-toggle dired-single dired-open dired-filetype-face dired-efap dired+ d-mode blank-mode bison-mode auto-compile anything ac-etags ac-c-headers)))
 '(scroll-bar-mode (quote right))
 '(show-paren-mode t)
 '(tab-width 4))

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
  )

;; 当使用命令行模式打开
(defun my-cli ()
  (custom-set-faces
   '(default ((t (:inherit nil :stipple nil :background "#FFFFFF" :foreground "#000000" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "outline"))))
   '(linum ((t (:inherit (shadow default) :background "#FFFFFF"))))
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

;; dired
(elpa-require 'dash)
(elpa-require 'dired+)
(elpa-require 'dired-single)
(elpa-require 'dired-toggle)
(elpa-require 'dired-efap)
(elpa-require 'dired-filetype-face)
(elpa-require 'dired-open)
(setq-default dired-omit-files-p t)
(setq dired-omit-files "\\.pdf$\\|\\.tex$|\\.DS_Store$")
(setq dired-default-buffer-name "*Dired*")

;; mmm-mode
(elpa-require 'mmm-mode)

;; hl-line
(set-face-background 'hl-line "#EEEEEE")
(elpa-require 'hlinum)
(hlinum-activate)
(set-face-background 'linum-highlight-face "#EEEEEE")

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

;; autocompile
(elpa-require 'auto-compile)
(auto-compile-on-load-mode 1)
(auto-compile-on-save-mode 1)

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
  (add-hook 'icicle-ido-like-mode-hook
            (lambda () (setq icicle-default-value
                             (if icicle-ido-like-mode t 'insert-end))
              ))
  )
(add-hook 'after-init-hook 'my-icicle)

;; backups.
(setq make-backup-files nil)
(defvar backup-dir "~/.emacs.d/backups/")
(setq backup-directory-alist (list (cons "." backup-dir)))

;; diff
(setq ediff-split-window-function 'split-window-horizontally)

;; 过滤掉一般不需要访问的文件
(setq my-ignores '(".DS_Store" ".git" ".svn" ".cvs" ".ede\\'" "\\`~" "\\`#" ".pyc\\'" "\\`tmp" ".o\\'" "\\`_{1}" ".ropeproject" ".scc\\'" ".out\\'" ".files\\'" ".class\\'" ".symvers\\'" ".order\\'" ".dmp\\'" ".tmp\\'" ".ncb\\'" ".suo\\'" ".usr\\'" ".user\\'" ".xcuserdatad\\'" ".cmd\\'"))
(ido-mode 1)
(dolist (ignore my-ignores)
  (add-to-list 'ido-ignore-files ignore))

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
(setq-default save-place t)
(require 'saveplace)

;; default mode.
(add-to-list 'auto-mode-alist '("\\.api\\'" . text-mode))
(defun my-text ()
  (prefer-coding-system 'gb18030)
  )
(add-hook 'text-mode-hook 'my-text)

;; bison
(add-to-list 'auto-mode-alist '("\\.ypp$" . bison-mode))
(add-to-list 'auto-mode-alist '("\\.y++$" . bison-mode))

;; golang.
(defun my-go ()
  (if (eq (getenv "GOPATH") nil) (setenv "GOPATH" (concat (getenv "HOME") "/.go.d/")))
  (setq go-path (getenv "GOPATH"))
  (mi-add-exec-path (concat go-path "bin/"))
  (if (not (file-exists-p (concat go-path "bin/gocode")))    
      (progn
        (message "installing gocode")
        (shell-command "go get -u github.com/nsf/gocode")
        (shell-command "go get -u github.com/golang/lint/golint")
        (shell-command "go get -u golang.org/x/tools/cmd/guru")
        (shell-command "go get -u golang.org/x/tools/cmd/goimports")
        (shell-command "go get -u golang.org/x/tools/cmd/gorename")
        ))
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
  (add-to-list 'ac-sources 'ac-source-go)
  (my-autocomplete)
  )
(defun my-setup-go ()
  (elpa-require 'go-mode)
  (add-hook 'go-mode-hook 'my-go)
  (go-mode)
  )
(add-to-list 'auto-mode-alist '("\\.go$" . my-setup-go))

;; vcm.
(mi-require-url 'git "git.el" "https://raw.githubusercontent.com/wybosys/el-git/master/git.el")
(mi-require-url 'git-blame "git-blame.el" "https://raw.githubusercontent.com/wybosys/el-git/master/git-blame.el")
(require 'vc-git)
(mi-require-url 'egit "egit.el" "https://raw.github.com/jimhourihan/egit/master/egit.el")

;; python.
(defun my-py-settings ()
  (elpa-require 'python-pep8)
  (elpa-require 'python-environment)
  (elpa-require 'python-info)
  (elpa-require 'pylint)
  (elpa-require 'pyflakes)
  (elpa-require 'jedi)
  (elpa-require 'jedi-direx)
  (elpa-require 'flycheck-pyflakes)
  (flycheck-mode)
  (jedi:ac-setup)
  )
(add-hook 'python-mode-hook 'my-py-settings)

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
  (mi-add-git "typescript")
  (mi-require-git 'typescript "typescript" "https://github.com/wybosys/el-typescript.git")
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.tsc\\'" . typescript-mode))
  (elpa-require 'tide)
  (add-hook 'typescript-mode-hook 'my-typescript-settings)
  (typescript-mode)
  )
(add-to-list 'auto-mode-alist '("\\.ts$" . my-setup-ts))
(add-to-list 'auto-mode-alist '("\\.tsc$" . my-setup-ts))

;; cmake.
(defun my-setup-cmake ()
  (mi-use-package-url "cmake-mode.el" "http://www.cmake.org/CMakeDocs/cmake-mode.el")
  (cmake-mode)
  )
(setq auto-mode-alist
      (append
       '(("CMakeLists\\.txt\\'" . my-setup-cmake))
       '(("\\.cmake\\'" . my-setup-cmake))
       auto-mode-alist))

;; yaml.
(defun my-setup-yaml ()
  (mi-use-package-url "yaml-mode.el" "https://raw.github.com/yoshiki/yaml-mode/master/yaml-mode.el")
  (yaml-mode)
  )
(add-to-list 'auto-mode-alist '("\\.ya?ml$" . my-setup-yaml))

;; lua.
(defun my-setup-lua ()
  (mi-use-package-url "lua-mode.el" "https://raw.github.com/immerrr/lua-mode/master/lua-mode.el")
  (lua-mode)
  )
(add-to-list 'auto-mode-alist '("\\.lua$" . my-setup-lua))

;; autocomplete
(defun my-autocomplete ()
  (elpa-require 'auto-complete)
  (elpa-require 'ac-etags)
  (require 'auto-complete-config)
  (add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")  
  (ac-config-default)
  (global-auto-complete-mode t)
  )
(defun my-autocomplete-c ()
  (elpa-require 'ac-c-headers)
  (add-to-list 'ac-sources 'ac-source-c-headers)
  (add-to-list 'ac-sources 'ac-source-c-header-symbols t))
(add-hook 'after-init-hook 'my-autocomplete)

;; flycheck
(elpa-require 'flycheck)

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
  (my-autocomplete-c)
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
(elpa-require 'anything)

;; protobuf
(defun my-setup-pb ()  
  (mi-use-package-url "protobuf-mode.el" "https://raw.githubusercontent.com/wybosys/wybosys/master/el/protobuf-mode.el")
  (protobuf-mode)
  )
(add-to-list 'auto-mode-alist '("\\.proto\\'" . my-setup-pb))

;; erlang
(defun my-erlang ()
  (mi-use-package-url "erlang-start.el" "https://raw.githubusercontent.com/wybosys/el-erlang/master/erlang-start.el")
  (require 'erlang-start)
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

;; apache httpd.
(defun my-setup-httpd ()
  (mi-use-package-url "apache-mode.el" "https://raw.githubusercontent.com/wybosys/wybosys/master/el/apache-mode.el")
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
  (mi-use-package-url "nginx-mode.el" "https://raw.github.com/ajc/nginx-mode/master/nginx-mode.el")
  (require 'nginx-mode)
  (setq nginx-indent-level 4)
  (nginx-mode)
  )
(add-to-list 'auto-mode-alist '("nginx\\.conf\\'" . my-setup-nginx))
(add-to-list 'auto-mode-alist '("nginx/conf\\.d/[[:ascii:]]+\\.conf\\'" . my-setup-nginx))

;; ssh mode.
(mi-use-package-url "ssh-config-mode.el" "https://raw.github.com/jhgorrell/ssh-config-mode-el/master/ssh-config-mode.el")
(autoload 'ssh-config-mode "ssh-config-mode" nil t)
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

;; save buffer and resave to another file
(defun wybosys-rbta-resave()
  (widen)
  (write-region (point-min) (point-max) wybosys-rbta-filep)
)
(defun resave-buffer-to-another (filep)
  (interactive "FFilepath:")
  (setq wybosys-rbta-filep filep)
  (make-local-variable 'wybosys-rbta-filep)
  (add-hook 'after-save-hook 'wybosys-rbta-resave)
)

;; show blank, newline, tab ...
(elpa-require 'blank-mode)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#FFFFFF" :foreground "#000000" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "outline"))))
 '(linum ((t (:inherit (shadow default) :background "#FFFFFF")))))
