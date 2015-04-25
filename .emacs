;; feedback
(setq visible-bell t)
(blink-cursor-mode 0)
(setq ring-bell-function 'ignore)

;; coding
(prefer-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
;(setq coding-system-for-read 'utf-8)

;; cedet and ecb bugfix
(setq stack-trace-on-error t)

;; download lisps
(when (not (file-accessible-directory-p "~/.emacs.d/lisps"))
  (make-directory "~/.emacs.d/lisps"))
(add-to-list 'load-path "~/.emacs.d/lisps/")
(add-to-list 'load-path "~/.emacs.d/auto-install/")

;; elpa extension
(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")
                         ("tromey" . "http://tromey.com/elpa/")
                         ))    
(package-initialize)

(defun elpa-require (module &optional package)
  ;(setq mytimemarker (current-time))
  (if (require module nil 'noerror) nil
    (unless package-archive-contents
      (package-refresh-contents))
    (if (eq package nil)
        (package-install module)
      (package-install package))
    (message "module installed")
    (require module)
    )
  ;(message "module %s interval: %f" (symbol-name module) (float-time (time-since mytimemarker)))
  )

;; may cause os-x crash. 
;(defun ai-require-file (module file)
;  (if (require module nil 'noerror) nil
;    (elpa-require 'auto-install)    
;    (auto-install-from-emacswiki file)
;    (require module)
;    )
;  )

(defun ai-require-url (module url)
  (if (require module nil 'noerror) nil
    (elpa-require 'auto-install)
    (setq auto-install-use-wget nil)
    (setq auto-install-save-confirm nil)
    (auto-install-from-url url)
    )
  (require module nil 'noerror)
  )

(defun ai-try-require-url (module url)
  (if (featurep module) nil
    (elpa-require 'auto-install)
    (setq auto-install-use-wget nil)
    (setq auto-install-save-confirm nil)
    (auto-install-from-url url)    
    )
  )

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
    ))

(defun mi-require-url (module name url)
  (mi-use-package-url name url)
  (require module nil 'noerror))

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

(defun mi-add-exec-path (path)
  (setenv "PATH" (concat (getenv "PATH") (concat ":" path)))
  (setq exec-path (split-string (getenv "PATH") path-separator))
  )

;; guide setting.
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
 '(scroll-bar-mode (quote right))
 '(show-paren-mode t)
 '(tab-width 4))

;; in-gui or not-gui.
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

(defun my-colors ()
  (interactive)
  (cond ((eq window-system 'ns)
         (setq x-colors (ns-list-colors))
         )
        )
  )

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

;; benchmark
;; git@github.com:dholm/benchmark-init-el.git
;(require 'benchmark-init)
;(require 'benchmark-init-modes)
;(benchmark-init/activate)

;; dired
(elpa-require 'dash)
(elpa-require 'dired-hacks-utils)
(elpa-require 'dired+)
(elpa-require 'dired-single)
(elpa-require 'dired-toggle)
;(elpa-require 'dired-subtree)
;(elpa-require 'dired-filter)
;(require 'dired-x)
;(elpa-require 'dired-rainbow)
(setq-default dired-omit-files-p t)
(setq dired-omit-files "^\\.[^.]\\|\\.pdf$\\|\\.tex$|\\.DS_Store$")
(setq dired-default-buffer-name "*Dired*")

;; mmm-mode
(elpa-require 'mmm-mode)

;; hl-line.
(set-face-background 'hl-line "#EEEEEE")
(elpa-require 'hlinum)
(hlinum-activate)
(set-face-background 'linum-highlight-face "#EEEEEE")

;; yes-or-no.
(defun my-mumble-or-no-p (prompt)
  "PROMPT user with a yes-or-no question, but only test for no."
  (if (string= "no"
               (downcase
                (read-from-minibuffer
                 (concat prompt "(yes[enter] or no) "))))
      nil
    t))
(defun my-mumble-or-n-p (prompt)
  "PROMPT user with a y-or-n question, but only test for no."
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
  (elpa-require 'mic-paren)
  (paren-activate)
  ; rainbow
  (mi-require-url 'rainbow-delimiters "rainbow-delimiters.el" "http://github.com/jlr/rainbow-delimiters/raw/master/rainbow-delimiters.el")
  (global-rainbow-delimiters-mode t)
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

;; 80 columns.
;(mi-require-url 'fill-column-indicator "fill-column-indicator.el" "https://raw.github.com/wybosys/wybosys/master/emacs/fill-column-indicator.el")
;(define-globalized-minor-mode global-fci-mode fci-mode (lambda () (fci-mode 1)))
;(global-fci-mode 1)
;(global-visual-line-mode 1)

;; backups.
(setq make-backup-files nil)
(defvar backup-dir "~/.emacs.d/backups/")
(setq backup-directory-alist (list (cons "." backup-dir)))

;; diff
(setq ediff-split-window-function 'split-window-horizontally)

;; ignores.
(setq my-ignores '(".DS_Store" ".git" ".svn" ".cvs" ".ede\\'" "\\`~" "\\`#" ".pyc\\'" "\\`tmp" ".o\\'" "\\`_{1}" ".ropeproject" ".scc\\'" ".out\\'" ".files\\'" ".class\\'" ".symvers\\'" ".order\\'" ".properties\\'" ".dmp\\'" ".tmp\\'" ".ncb\\'" ".suo\\'" ".usr\\'" ".user\\'" ".xcuserdatad\\'" "build" "Debug" "Release" "Debug Static" "Release Static" ".cmd\\'"))

;; ido mode for fast open.
(ido-mode 1)
(dolist (ignore my-ignores)
  (add-to-list 'ido-ignore-files ignore))

;; session.
(defun my-session ()
  (elpa-require 'session)
  (session-initialize)
  (elpa-require 'desktop)
  (require 'desktop)
  )
(add-hook 'after-init-hook 'my-session)

;; uniquify buffer name
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)

;; org-mode
(autoload 'org-mode "org" nil t)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; tramp
(require 'tramp)
(setq tramp-default-method "ssh")

;; bookmark
(require 'bookmark)

;; save space.
(setq-default save-place t)
(require 'saveplace)

;; default mode.
(add-to-list 'auto-mode-alist '("\\.api\\'" . text-mode))
(defun my-text ()
  (prefer-coding-system 'gb18030)
  )
(add-hook 'text-mode-hook 'my-text)

;; go-lang.
(mi-require-url 'go-mode "go-mode.el" "https://raw.github.com/wybosys/wybosys/master/emacs/go-mode.el")
(mi-require-url 'go-mode-load "go-mode-load.el" "https://raw.github.com/wybosys/wybosys/master/emacs/go-mode-load.el")
(defun my-go ()
  (if (eq (getenv "GOPATH") nil) (setenv "GOPATH" (concat (getenv "HOME") "/.go.d/")))
  (setq go-path (getenv "GOPATH"))
  (mi-add-exec-path (concat go-path "bin/"))
  (if (not (file-exists-p (concat go-path "bin/gocode")))    
      (progn
        (message "installing gocode")
        (shell-command "go get -u github.com/nsf/gocode")))
  (elpa-require 'go-autocomplete)
  (elpa-require 'golint)
  (add-to-list 'ac-sources 'ac-source-go)
  (my-autocomplete)
  )
(add-hook 'go-mode-hook 'my-go)

;; vcm.
(mi-require-url 'git "git.el" "https://raw.github.com/wybosys/wybosys/master/emacs/git/git.el")
(mi-require-url 'git-blame "git-blame.el" "https://raw.github.com/wybosys/wybosys/master/emacs/git/git-blame.el")
(require 'vc-git)
(mi-require-url 'egit "egit.el" "https://raw.github.com/jimhourihan/egit/master/egit.el")

;; whitespace-mode.
(mi-require-url 'whitespace "whitespace.el" "https://raw.github.com/wybosys/wybosys/master/emacs/whitespace.el")

;; sql.
(mi-require-url 'sql "sql.el" "https://raw.github.com/wybosys/wybosys/master/emacs/sql.el")

;; maxima mode
(add-to-list 'load-path "/opt/local/share/maxima/5.28.0/emacs")

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
  ;(setq jedi:complete-on-dot t)
  (jedi:ac-setup)
  )
(add-hook 'python-mode-hook 'my-py-settings)

;; d
(elpa-require 'd-mode)

;; markdown
(mi-require-url 'markdown-mode "markdown-mode.el" "http://jblevins.org/projects/markdown-mode/markdown-mode.el")
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; java
(defun my-java ()
  (elpa-require 'javadoc-help)
  (elpa-require 'javap)
  )
(add-hook 'java-mode-hook 'my-java)

;; javascript.
(defun my-js-settings ()
  (elpa-require 'js2-mode)
  (js2-mode)
  )
(add-hook 'js-mode-hook 'my-js-settings)

;; typescript
(elpa-require 'typescript)
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
(defun my-typescript-settings ()
  (auto-complete-mode)
  ;(elpa-require 'tss)
  ;(tss-config-default)
  )
(add-hook 'typescript-mode-hook 'my-typescript-settings)

;; cmake.
(mi-use-package-url "cmake-mode.el" "http://www.cmake.org/CMakeDocs/cmake-mode.el")
(setq auto-mode-alist
      (append
       '(("CMakeLists\\.txt\\'" . cmake-mode))
       '(("\\.cmake\\'" . cmake-mode))
       auto-mode-alist))
(autoload 'cmake-mode "cmake-mode" t)

;; yaml.
(mi-use-package-url "yaml-mode.el" "https://raw.github.com/yoshiki/yaml-mode/master/yaml-mode.el")
(autoload 'yaml-mode "yaml-mode")
(add-to-list 'auto-mode-alist '("\\.ya?ml$" . yaml-mode))

;; qt.
;(elpa-require 'qml-mode)
(mi-use-package-url "qml-mode.el" "https://raw.github.com/emacsmirror/qml-mode/master/qml-mode.el")
(mi-use-package-url "qt-pro.el" "http://www.tolchz.net/wp-content/uploads/2008/01/qt-pro.el")
(add-to-list 'auto-mode-alist '("\\.pr[io]$" . qt-pro-mode))
(add-to-list 'auto-mode-alist '("\\.qml$" . qml-mode))
(autoload 'qt-pro-mode "qt-pro")
(autoload 'qml-mode "qml-mode")

;; lua.
(mi-use-package-url "lua-mode.el" "https://raw.github.com/immerrr/lua-mode/master/lua-mode.el")
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))

;; glsl
(mi-use-package-url "glsl-mode.el" "https://raw.github.com/jimhourihan/glsl-mode/master/glsl-mode.el")
(autoload 'glsl-mode "glsl-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.glsl\\'" . glsl-mode))
(add-to-list 'auto-mode-alist '("\\.vert\\'" . glsl-mode))
(add-to-list 'auto-mode-alist '("\\.frag\\'" . glsl-mode))
(add-to-list 'auto-mode-alist '("\\.geom\\'" . glsl-mode))

;; cg toolkit
(mi-use-package-url "cg-mode.el" "https://raw.github.com/wybosys/wybosys/master/emacs/cg-mode.el")
(add-to-list 'auto-mode-alist '("\\.cg\\'" . cg-mode))

;; opencl
(add-to-list 'auto-mode-alist '("\\.cl\\'" . c-mode))

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

;; autopair
;(elpa-require 'autopair)
;(autopair-global-mode)

;; flycheck
(elpa-require 'flycheck)
;(elpa-require 'flycheck-color-mode-line)
;(add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode)

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
  ;(add-to-list 'ac-sources 'ac-source-semantic)  
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
  (my-ecb-setup)
  )
(defun mydev-start ()
  (run-with-idle-timer 0.01 nil 'mydev)
  )

;; heander to source.
(defun my-h2s ()
  (elpa-require 'cl-lib)
  (mi-require-url 'eassist "eassist.el" "https://raw.github.com/emacsmirror/cedet/master/contrib/eassist.el")
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

;; cscope
(defun my-cscope ()
  (elpa-require 'ascope)
  )

;; c mode.
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.c\\'" . c++-mode))
(defun my-c-mode ()
  (interactive)
  (setq c-basic-offset 4)
  (my-h2s)	
  (my-cscope)
  (my-autocomplete-c)
  )

(add-hook 'c-mode-common-hook 
          '(lambda ()
             (my-c-mode)
             (mydev-start)
             ))

;; verilog
(autoload 'verilog-mode "verilog-mode" "Verilog mode" t )
(add-to-list 'auto-mode-alist '("\\.[ds]?vh?\\'" . verilog-mode))
(setq verilog-indent-level             3
      verilog-indent-level-module      3
      verilog-indent-level-declaration 3
      verilog-indent-level-behavioral  3
      verilog-indent-level-directive   1
      verilog-case-indent              2
      verilog-auto-newline             t
      verilog-auto-indent-on-newline   t
      verilog-tab-always-indent        t
      verilog-auto-endcomments         t
      verilog-minimum-comment-distance 40
      verilog-indent-begin-after-if    t
      verilog-auto-lineup              'declarations
      verilog-highlight-p1800-keywords nil
      verilog-linter             "my_lint_shell_command"
      )

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

;; php.
(elpa-require 'php-mode)
(defun my-php ()
  (flycheck-mode)
  (mi-use-package-url "php-completion.el" "https://raw.github.com/wybosys/wybosys/master/emacs/php-completion.el")
  (require 'php-completion)
  (php-completion-mode t)
  (add-to-list 'ac-sources 'ac-source-php-completion)
  )
(add-hook 'php-mode-hook 'my-php)

;; protobuf
(mi-use-package-url "protobuf-mode.el" "https://raw.github.com/wybosys/wybosys/master/emacs/protobuf-mode.el")
(autoload 'protobuf-mode "protobuf-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.proto\\'" . protobuf-mode))

;; thrift.
(elpa-require 'thrift)

;; erlang
(elpa-require 'erlang)
(setq erlang-root-dir "/opt/local/lib/erlang/")
(defun my-erlang ()
  (mi-use-package-url "erlang-start.el" "https://raw.github.com/wybosys/wybosys/master/emacs/erlang/erlang-start.el")
  (require 'erlang-start)
  (flycheck-mode)
  (add-to-list 'ac-modes 'erlang-mode)
  (add-to-list 'load-path "~/.emacs.d/lisps/distel/elisp")  
  (mi-require-git 'distel "distel" "https://github.com/massemanet/distel.git")
  (distel-setup)
  )
(add-hook 'erlang-mode-hook 'my-erlang)

;; apache httpd.
(mi-use-package-url "apache-mode.el" "https://raw.github.com/wybosys/wybosys/master/emacs/apache-mode.el")
(autoload 'apache-mode "apache-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.htaccess\\'"   . apache-mode))
(add-to-list 'auto-mode-alist '("httpd\\.conf\\'"  . apache-mode))
(add-to-list 'auto-mode-alist '("httpd-[[:ascii:]]+\\.conf\\'"  . apache-mode))
(add-to-list 'auto-mode-alist '("srm\\.conf\\'"    . apache-mode))
(add-to-list 'auto-mode-alist '("access\\.conf\\'" . apache-mode))
(add-to-list 'auto-mode-alist '("sites-\\(available\\|enabled\\)/" . apache-mode))

;; nginx mode.
(mi-use-package-url "nginx-mode.el" "https://raw.github.com/ajc/nginx-mode/master/nginx-mode.el")
(autoload 'nginx-mode "nginx-mode" nil t)
(setq nginx-indent-level 8)
(add-to-list 'auto-mode-alist '("nginx\\.conf\\'" . nginx-mode))
(add-to-list 'auto-mode-alist '("nginx/conf\\.d/[[:ascii:]]+\\.conf\\'" . nginx-mode))

;; ssh mode.
(mi-use-package-url "ssh-config-mode.el" "https://raw.github.com/jhgorrell/ssh-config-mode-el/master/ssh-config-mode.el")
(autoload 'ssh-config-mode "ssh-config-mode" nil t)
(add-to-list 'auto-mode-alist '(".ssh/config\\'"  . ssh-config-mode))
(add-to-list 'auto-mode-alist '("sshd?_config\\'" . ssh-config-mode))

;; objc.
(add-to-list 'auto-mode-alist '("\\.mm\\'" . c++-mode))
;(add-to-list 'auto-mode-alist '("\\.m\\'" . objc-mode))

;; octave.
(autoload 'octave-mode "octave-mod" nil t)
(add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode))
(add-hook 'octave-mode-hook
          (lambda ()
            (add-to-list 'ac-modes 'octave-mode)
            (elpa-require 'ac-octave)
            (abbrev-mode 1)
            (auto-fill-mode 1)
            ))

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

;; undo mode.
(defun my-undo ()
  (elpa-require 'undo-tree)
  (undo-tree-mode)
  )

(add-hook 'after-init-hook 'my-undo)

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

;; scala
(elpa-require 'scala-mode2)

;; groovy
(mi-add-git "groovy-mode")
(mi-require-git 'groovy-mode "groovy-mode" "https://github.com/russel/Emacs-Groovy-Mode.git")
(add-hook 'groovy-mode-hook
          '(lambda ()
             (require 'groovy-electric)
             (groovy-electric-mode)))

;; global bind keys.
(global-set-key (kbd "C-x <left>") 'my-switch-to-lastbuffer)
(global-set-key (kbd "C-x <right>") 'other-window)
(global-set-key (kbd "ESC <up>") 'previous-buffer)
(global-set-key (kbd "ESC <down>") 'next-buffer)
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

