;;; emacs.el --- my emacs init file -*- lexical-binding: t -*-
;; TODO: move to literate config

;;; Commentary:
;;; Code:
;;; from DOOM emacs
;; (setenv "LSP_USE_PLISTS" "true")
(setq gc-cons-threshold most-positive-fixnum) ;v large GC buffer, gcmh-mode cleans it up later
(setq load-prefer-newer noninteractive)		;I believer nix takes care of this as files loaded are always compiled and static
(setq-default bidi-display-reordering 'left-to-right ;I don't use bidirectional text (hebrew, arabic, etc), so diabling it helps performance
              bidi-paragraph-direction 'left-to-right
	      bidi-inhibit-bpa t)
;; Reduce rendering/line scan work for Emacs by not rendering cursors or regions
;; in non-focused windows.
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)
;; More performant rapid scrolling over unfontified regions. May cause brief
;; spells of inaccurate syntax highlighting right after scrolling, which should
;; quickly self-correct.
(setq fast-but-imprecise-scrolling t)
;; Don't ping things that look like domain names.
;; (setq ffap-machine-p-known 'reject) ;;NOTE: unrecognized for some reason

;; Emacs "updates" its ui more often than it needs to, so slow it down slightly
(setq idle-update-delay 1.0)  ; default is 0.5
;; Font compacting can be terribly expensive, especially for rendering icon
;; fonts on Windows. Whether disabling it has a notable affect on Linux and Mac
;; hasn't been determined, but do it anyway, just in case. This increases memory
;; usage, however!
(setq inhibit-compacting-font-caches t)
;; PGTK builds only: this timeout adds latency to frame operations, like
;; `make-frame-invisible', which are frequently called without a guard because
;; it's inexpensive in non-PGTK builds. Lowering the timeout from the default
;; 0.1 should make childframes and packages that manipulate them (like `lsp-ui',
;; `company-box', and `posframe') feel much snappier. See emacs-lsp/lsp-ui#613.
  (setq pgtk-wait-for-event-timeout 0.001)
;; Increase how much is read from processes in a single chunk (default is 4kb).
;; This is further increased elsewhere, where needed (like our LSP module).
(setq read-process-output-max (* 64 1024))  ; 64kb
(setq redisplay-skip-fontification-on-input t)


(eval-when-compile
  (require 'use-package))
(use-package bind-key
  :custom (
	   (use-package-always-ensure t)
	   (use-package-verbose t)
	   ) ;disabled so its explicit if something is a hook. Also my current config appends hook already
  :demand t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room
(set-frame-font "Lilex Nerd Font")

(menu-bar-mode -1)            ; Disable the menu bar
;; Set up the visible bell
(setq visible-bell t)
;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
;;line numbers
(column-number-mode)
(global-display-line-numbers-mode t)
(prettify-symbols-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook 
		term-mode-hook
		eshell-mode-hook
		pdf-view-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; requirements for leaf							    ;;
;; (eval-and-compile								    ;;
;;   (customize-set-variable							    ;;
;;    'package-archives '(("melpa" . "https://melpa.org/packages/")		    ;;
;; 		       ("gnu" . "https://elpa.gnu.org/packages/")))		    ;;
;;   (package-initialize)							    ;;
;;   (unless (package-installed-p 'leaf)					    ;;
;;     (package-refresh-contents)						    ;;
;;     (package-install 'leaf)							    ;;
;; 										    ;;
;;   (leaf leaf-keywords							    ;;
;;     :ensure t								    ;;
;;     :init									    ;;
;;     ;; optional packages if you want to use :hydra, :el-get, :blackout,,,	    ;;
;;     (leaf hydra :ensure nil)							    ;;
;;     (leaf el-get :ensure nil)						    ;;
;;     (leaf blackout :ensure nil)						    ;;
;; 										    ;;
;;     :config									    ;;
;;     ;; initialize leaf-keywords.el						    ;;
;;     (leaf-keywords-init))))							    ;;
;; ;; end requirements for leaf							    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; performance stuff
(use-package gcmh ;for some reason use-package causes the error, this doesnt
  :custom ((gcmh-idle-delay 'auto)
	   (gcmh-auto-idle-delay-factor 10)
	   (gcmh-high-cons-threshold (* 16 1024 1024)))
  :config (gcmh-mode 1)
  )
;; (use-package hyperbole 			;TODO: investiage error for void symbol func def
;;   :config (hyperbole-mode))
(use-package evil
  :init 
	   (setq evil-want-keybinding nil) ; needed for evil-collection
	   (setq evil-want-integration 't)
	 
  :custom (
	   ;; (evil-shift-width 4)
	   (evil-undo-system 'undo-redo)
	   (evil-want-c-u-scroll t)
	   )
  :config
  (evil-mode 1)
  )

(use-package evil-goggles ;; TODO: figure out why this isn't working
  :after evil
  :config
  (evil-goggles-mode)

  ;; optionally use diff-mode's faces; as a result, deleted text
  ;; will be highlighed with `diff-removed` face which is typically
  ;; some red color (as defined by the color theme)
  ;; other faces such as `diff-added` will be used for other actions
  (evil-goggles-use-diff-faces))

(use-package evil-collection ;;TODO: figure out why this breaks lispy
  :after evil
  :custom (electric-pair-mode t)
	  
  :config
  (evil-collection-init))


(use-package org
  :ensure org-contrib
  :custom (
	   (org-confirm-babel-evaluate . nil)
	   )
  )
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (dot . t)
   (gnuplot . t)
   (python . t)
   (plantuml . t)
   (java . t)
   (shell . t)
   ))
(use-package org-modern
  :hook (
	 (org-mode . org-modern-mode)
	 (org-agenda-finalize . org-modern-agenda)))
;; plantuml
(use-package plantuml-mode
  :after org
  :config (add-to-list
	    'org-src-lang-modes '("plantuml" . plantuml))
  (setq plantuml-executable-path (executable-find "plantuml"))
  (setq plantuml-default-exec-mode 'executable)
  (setq org-plantuml-exec-mode 'plantuml)
  (setq org-plantuml-executable-path (executable-find "plantuml"))
  )


(use-package rainbow-mode
  :hook org-mode
  emacs-lisp-mode
  web-mode
  typescript-mode
  js2-mode)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :after evil
  :config (which-key-mode))

(use-package catppuccin-theme
  :init (load-theme 'catppuccin :no-confirm))

;; Enable vertico
(use-package vertico
  :init
  (vertico-mode)
  :hook (minibuffer-setup . cursor-intangible-mode)
  :custom ((minibuffer-prompt-properties
	    '(read-only t cursor-intangible t face minibuffer-prompt))
	   (read-extended-command-predicate
	    #'command-completion-default-include-p)
	   (enable-recursive-minibuffers t)
	   (completion-cycle-threshold 3)
	   (tab-always-indent 'complete-tag))
  :config
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.

  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  ;; (setq vertico-cycle t)
  )

;; Persist history over Emacs restarts. Vertico sorts by history position.

(use-package vertico-posframe
  :after vertico
  :custom ((vertico-posframe-mode 1))
  )

(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)



(use-package doom-modeline
  :init (doom-modeline-mode)
  :custom (
	   (doom-modeline-height 25)
	   (doom-modeline-support-imenu t)
	   (doom-modeline-hud t) ;;TODO: see if I like this setting
	   (doom-modeline-icon t)))
(use-package solaire-mode
  :init (solaire-global-mode))
(use-package doom-themes)

;; Optionally use the `orderless' completion style.
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       Orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless partial-completion basic)
	completion-category-defaults nil
	completion-category-overrides nil))
(use-package projectile
    :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map)))
;; Example configuration for Consult
(use-package consult
  :after projectile
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  ;; 4. projectile.el (projectile-project-root)
  (autoload 'projectile-project-root "projectile")
  (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;; 5. No project support
  ;; (setq consult-project-function nil)
)
(use-package consult-flycheck)
;; cape
;; Enable Corfu completion UI
;; See the Corfu README for more configuration tips.
;; disabled in favor of lsp-bridge. As nice as it would be
;; to have everything standardized, emacs' current model
;; just isn't set up well for LSP.

(use-package corfu
  ;; Optional customizations
  :custom (
  (corfu-cycle t)	;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)	;; Enable auto completion
  (corfu-separator ?\s)	;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  (corfu-preselect 'prompt) ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  (corfu-scroll-margin 5) ;; Use scroll margin
  (corfu-quit-no-match 'separator))

  ;; Enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode))
 											        
 (use-package corfu-prescient ;; use prescient to filter corfu				        
   :after corfu									        
   :init (setq corfu-prescient-mode 1))							        
 (use-package corfu-terminal									        
   :config										        
   (unless (display-graphic-p)							        
     (corfu-terminal-mode 1)))							        
   											        
   (use-package nerd-icons-corfu								        
     :after corfu									        
     :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Use Dabbrev with Corfu!
(use-package dabbrev
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  ;; Since 29.1, use `dabbrev-ignored-buffer-regexps' on older.
  ;; (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  ;; (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
  )
 											        ;;
 											        ;;
 											        ;;
 (use-package cape										        ;;
   ;; Bind dedicated completion commands						        ;;
   ;; Alternative prefix keys: C-c p, M-p, M-+, ...					        ;;
 											        ;;
   :bind (("C-c p p" . completion-at-point) ;; capf					        ;;
 	 ("C-c p t" . complete-tag)	   ;; etags					        ;;
 	 ("C-c p d" . cape-dabbrev)	   ;; or dabbrev-completion			        ;;
 	 ("C-c p h" . cape-history)							        ;;
 	 ("C-c p f" . cape-file)							        ;;
 	 ("C-c p k" . cape-keyword)							        ;;
 	 ("C-c p s" . cape-elisp-symbol)						        ;;
 	 ("C-c p e" . cape-elisp-block)						        ;;
 	 ("C-c p a" . cape-abbrev)							        ;;
 	 ("C-c p l" . cape-line)							        ;;
 	 ("C-c p w" . cape-dict)							        ;;
 	 ("C-c p :" . cape-emoji)							        ;;
 	 ("C-c p \\" . cape-tex)							        ;;
 	 ("C-c p _" . cape-tex)							        ;;
 	 ("C-c p ^" . cape-tex)							        ;;
 	 ("C-c p &" . cape-sgml)							        ;;
 	 ("C-c p r" . cape-rfc1345))							        ;;
   :init										        ;;
   ;; Add to the global default value of `completion-at-point-functions' which is	        ;;
   ;; used by `completion-at-point'.  The order of the functions matters, the		        ;;
   ;; first function returning a result wins.  Note that the list of buffer-local	        ;;
   ;; completion functions takes precedence over the global list.			        ;;
   (add-to-list 'completion-at-point-functions #'cape-keyword)			        ;;
   (add-to-list 'completion-at-point-functions #'cape-dabbrev)			        ;;
   (add-to-list 'completion-at-point-functions #'cape-file)				        ;;
   (add-to-list 'completion-at-point-functions #'cape-elisp-block)			        ;;
   ;;(add-to-list 'completion-at-point-functions #'cape-history)			        ;;
   ;;(add-to-list 'completion-at-point-functions #'cape-sgml)				        ;;
   ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)			        ;;
   ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)			        ;;
   ;;(add-to-list 'completion-at-point-functions #'cape-dict)				        ;;
   (add-to-list 'completion-at-point-functions #'cape-elisp-symbol)			        ;;
   ;;(add-to-list 'completion-at-point-functions #'cape-line)				        ;;
   (add-to-list 'completion-at-point-functions #'cape-tex)				        ;;
   (add-to-list 'completion-at-point-functions #'cape-emoji)				        ;;
   (defun my/setup-elisp ()								        ;;
     (setq-local completion-at-point-functions					        ;;
 		`(,(cape-super-capf							        ;;
 		    #'elisp-completion-at-point						        ;;
 		    #'cape-dabbrev)							        ;;
 		  cape-file)								        ;;
 		cape-dabbrev-min-length 5))						        ;;
   (add-hook 'emacs-lisp-mode-hook #'my/setup-elisp))					        ;;


(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

(use-package embark
  :bind (("C-'" . embark-act)	      ;; pick some comfortable binding
	 ("C-;" . embark-dwim)	      ;; good alternative: M-.
	 ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  (add-to-list 'display-buffer-alist
	       '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
		 nil
		 (window-parameters (mode-line-format . none)))))
(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))
;;projectile
;; (use-package projectile
;; :ensure t
;; :init
;; (projectile-mode +1)
;; :bind (:map projectile-mode-map
;;             ("s-p" . projectile-command-map)
;;             ("C-c p" . projectile-command-map)))

;; lisp editing tools
(use-package lispy
  :init
  (add-hook 'emacs-lisp-mode-hook (lambda () (lispy-mode 1)))
  (defun conditionally-enable-lispy ()
    (when (eq this-command 'eval-expression)
      (lispy-mode 1)))
  (add-hook 'minibuffer-setup-hook 'conditionally-enable-lispy))

(use-package lispyville
  :hook ((emacs-lisp-mode . lispyville-mode))
  :config
  (lispyville-set-key-theme '(operators c-w additional)))

(use-package flycheck
  :init
  (add-hook 'after-init-hook #'global-flycheck-mode)
  (flycheck-define-checker checkstyle
     " a java checker "
     :command ("checktyle" "-c" "./csc_checkstyle.xml" source)
     :error-parser flycheck-parse-checkstyle
     :enable t
     :modes (java-mode java-ts-mode)))

(defun lsp-booster--advice-json-parse (old-fn &rest args)
  "Try to parse bytecode instead of json."
  (or
   (when (equal (following-char) ?#)
     (let ((bytecode (read (current-buffer))))
       (when (byte-code-function-p bytecode)
         (funcall bytecode))))
   (apply old-fn args)))
(advice-add (if (progn (require 'json)
                       (fboundp 'json-parse-buffer))
                'json-parse-buffer
              'json-read)
            :around
            #'lsp-booster--advice-json-parse)

(defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
  "Prepend emacs-lsp-booster command to lsp CMD."
  (let ((orig-result (funcall old-fn cmd test?)))
    (if (and (not test?)                             ;; for check lsp-server-present?
             (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
             lsp-use-plists
             (not (functionp 'json-rpc-connection))  ;; native json-rpc
             (executable-find "emacs-lsp-booster"))
        (progn
          (message "Using emacs-lsp-booster for %s!" orig-result)
          (cons "emacs-lsp-booster" orig-result))
      orig-result)))
(advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

(use-package lsp-mode
  :custom
  (lsp-completion-provider :none) ;; we use Corfu!
  :init
  (setq lsp-keymap-prefix "C-c l")
  (defun my/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(flex))) ;; Configure flex
  :hook (
	 (lsp-completion-mode . my/lsp-mode-setup-completion)
	 (lsp-mode . lsp-enable-which-key-integration)
	 ;;follow this pattern for everything you want an lsp for
	 (nix-ts-mode . lsp)
	 (rust-ts-mode . lsp))
  :commands lsp)
  (use-package lsp-ui
    :config
    (setq lsp-ui-doc-position 'at-point
	  lsp-ui-doc-show-with-cursor t)
    :commands lsp-ui-mode)
(use-package lsp-treemacs
  :custom (lsp-treemacs-sync-mode 1))
(use-package treemacs
  :config
					; plugins
  (use-package treemacs-all-the-icons)
  (use-package treemacs-magit)
  (use-package treemacs-evil)
  (use-package treemacs-projectile)
  (treemacs-git-mode 1)
  )


(defvar +lsp-defer-shutdown 3 ;;
  ;;   "If non-nil, defer shutdown of LSP servers for this many seconds after last		        ;;
  ;; workspace buffer is closed.									        ;;
  ;; 												        ;;
  ;; This delay prevents premature server shutdown when a user still intends on			        ;;
  ;; working on that project after closing the last buffer, or when programmatically		        ;;
  ;; killing and opening many LSP/eglot-powered buffers."
  )					        ;;
												        ;;
												        ;;
;;												        ;;
;;; nix-mode
(use-package nix-mode
  :mode "\\.nix\\'")
(use-package nix-ts-mode
  :mode "\\.nix\\'")
;; yuck (for eww bar)
(use-package yuck-mode
  :mode "\\.yuck\\'")

;;; Common											        ;;
												        ;;
(defvar +lsp--default-read-process-output-max nil)						        ;;
(defvar +lsp--default-gcmh-high-cons-threshold nil)						        ;;
(defvar +lsp--optimization-init-p nil)							        ;;
												        ;;
(define-minor-mode +lsp-optimization-mode							        ;;
  "Deploys universal GC and IPC optimizations for `lsp-mode' and `eglot'."			        ;;
  :global t											        ;;
  :init-value nil										        ;;
  (if (not +lsp-optimization-mode)								        ;;
      (setq-default read-process-output-max +lsp--default-read-process-output-max		        ;;
                    gcmh-high-cons-threshold +lsp--default-gcmh-high-cons-threshold		        ;;
                    +lsp--optimization-init-p nil)						        ;;
    ;; Only apply these settings once!							        ;;
    (unless +lsp--optimization-init-p							        ;;
      (setq +lsp--default-read-process-output-max (default-value 'read-process-output-max)	        ;;
            +lsp--default-gcmh-high-cons-threshold (default-value 'gcmh-high-cons-threshold))        ;;
      (setq-default read-process-output-max (* 1024 1024))					        ;;
      ;; REVIEW LSP causes a lot of allocations, with or without the native JSON		        ;;
      ;;        library, so we up the GC threshold to stave off GC-induced			        ;;
      ;;        slowdowns/freezes. Doom (where this code was obtained from)			        ;;
      ;;        uses `gcmh' to enforce its GC strategy,					        ;;
      ;;        so we modify its variables rather than `gc-cons-threshold'			        ;;
      ;;        directly.									        ;;
      (setq-default gcmh-high-cons-threshold (* 2 +lsp--default-gcmh-high-cons-threshold))	        ;;
      (gcmh-set-high-threshold)								        ;;
      (setq +lsp--optimization-init-p t))))
(use-package lsp-java :config (add-hook 'java-mode-hook 'lsp)) ;; Don't use manually installed java, doesn't have everything needed
(use-package dap-mode :after lsp-mode :config (dap-auto-configure-mode))
(use-package dap-java :ensure nil)

;;
;; (use-package eglot											        ;;
;;   :hook ((eglot-managed-mode . +lsp-optimization-mode)					        ;;
;; 	 (nix-ts-mode . eglot-ensure)							        ;;
;; 	 (rust-ts-mode . eglot-ensure))							        ;;
;;   :config (											        ;;
;; 	   (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nil"))))			        ;;
;;   :init											        ;;
;;   (setq completion-category-overrides '((eglot (styles orderless))))				        ;;
;;   (setq eglot-sync-connect 1									        ;;
;; 	eglot-autoshutdown t									        ;;
;; 	eglot-send-changes-idle-time 0.5							        ;;
;; 	;; NOTE This setting disable the eglot-events-buffer enabling more			        ;;
;; 	;;      consistent performance on long running emacs instance.			        ;;
;; 	;;      Default is 2000000 lines. After each new event the whole buffer		        ;;
;; 	;;      is pretty printed which causes steady performance decrease over time.	        ;;
;; 	;;      CPU is spent on pretty priting and Emacs GC is put under high pressure.	        ;;
;; 	eglot-events-buffer-size 0								        ;;
;; 	;; NOTE We disable eglot-auto-display-help-buffer because :select t in		        ;;
;; 	;;      its popup rule causes eglot to steal focus too often.			        ;;
;; 	eglot-auto-display-help-buffer nil)							        ;;
;;   												        ;;
;;  (defun my/eglot-capf ()									        ;;
;;    (setq-local completion-at-point-functions						        ;;
;;		(list (cape-super-capf								        ;;
;;		       #'eglot-completion-at-point						        ;;
;;		       #'tempel-expand								        ;;
;;		       #'cape-file))))								        ;;
;;												        ;;
					;  (add-hook 'eglot-managed-mode-hook #'my/eglot-capf))					        ;;
;;(use-package consult-eglot)										        ;;
;;(use-package flycheck-eglot										        ;;
;;  :after (flycheck eglot)									        ;;
;;  :custom (flycheck-eglot-exclusive . nil)							        ;;
;; :config											        ;;
;;  (global-flycheck-eglot-mode 1))								        ;;


;; (use-package lsp-bridge
;;   :after yasnippet
;;   :custom ((lsp-bridge-nix-lsp-server "nil") ;nil the lsp - not the value
;; 	   )
;;   :init (global-lsp-bridge-mode))
;; (use-package yasnippet
;;   :init (yas-global-mode 1)) 			;needed for lsp-bridge, can still template in tempel
;; (use-package yasnippet-snippets)
(use-package markdown-mode)

(use-package tempel
  ;; Require trigger prefix before template name when completing.
  ;; :custom
  ;; (tempel-trigger-prefix "<")

  :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
	 ("M-*" . tempel-insert))
  
  ;; Setup completion at point						   ;;
  (defun tempel-setup-capf ()						   ;;
    ;; Add the Tempel Capf to `completion-at-point-functions'.		   ;;
    ;; `tempel-expand' only triggers on exact matches. Alternatively use	   ;;
    ;; `tempel-complete' if you want to see all matches, but then you	   ;;
    ;; should also configure `tempel-trigger-prefix', such that Tempel	   ;;
    ;; does not trigger too often when you don't expect it. NOTE: We add	   ;;
    ;; `tempel-expand' *before* the main programming mode Capf, such		   ;;
    ;; that it will be tried first.						   ;;
    (setq-local completion-at-point-functions				   ;;
		(cons #'tempel-expand						   ;;
		      completion-at-point-functions)))				   ;;
										   ;;
  (add-hook 'conf-mode-hook 'tempel-setup-capf)				   ;;
  (add-hook 'prog-mode-hook 'tempel-setup-capf)				   ;;
  (add-hook 'text-mode-hook 'tempel-setup-capf)				   ;;
  

  ;; Optionally make the Tempel templates available to Abbrev,
  ;;either locally or globally. `expand-abbrev' is bound to C-x '.
  (add-hook 'prog-mode-hook #'tempel-abbrev-mode)
  (global-tempel-abbrev-mode)
  )

(use-package tempel-collection
  :after tempel
)

;; spellcheck
(use-package jinx
  :config (global-jinx-mode)
  :bind (("M-$" . jinx-correct)
	 ("C-M-$" . jinx-languages)))

;; tree-sitter NOTE: might want to check this as the ecosystem uses native emacs

;; ligatures

(use-package ligature
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://"))
  
  ;; Enables ligature checks globally in all buffers. You can also do it
  ;; per mode with `ligature-mode'.
  (global-ligature-mode t))


(use-package unicode-fonts
   :config
    (unicode-fonts-setup))
;; let writing modes use non-monospace fonts

(use-package mixed-pitch ;;TODO: investigate & configure
  :if (display-graphic-p)
  :hook
  ;; If you want it in all text modes:
  (text-mode . mixed-pitch-mode))
(use-package writeroom-mode) 		;activate manually when I want too/

(use-package all-the-icons
  :if (display-graphic-p))

(use-package spacious-padding
  :custom (spacious-padding-widths)
  :init (spacious-padding-mode))

(use-package helpful
  :bind (("C-h f" . helpful-callable)
	 ("C-h v" . helpful-variable)
	 ("C-h k" . helpful-key)
	 ("C-h x" . helpful-command)
	 ("C-c C-d" . helpful-at-point)
	 ("C-c F" . helpful-function)
	 ))

(use-package centaur-tabs
  :custom (
	   (centaur-tabs-style '"rounded"))
  ;; (centaur-tabs-close-button .  "X") ;; disable close button
  :bind (
	 ("C-<prior>" . centaur-tabs-backward)
	 ("C-<next>" . centaur-tabs-forward))
  :init (centaur-tabs-mode t))

(use-package highlight-indent-guides
  :hook
  (prog-mode . highlight-indent-guides-mode))

(use-package magit) 				;"But I will always use magit"
(use-package vterm)
(use-package eradio
  :custom (eradio-player 'mpv))

(use-package hl-todo
  :init (global-hl-todo-mode)
  )
(use-package flycheck-hl-todo
  :defer 5 				;wait for the other checkers
  :config (flycheck-hl-todo-setup)
  )
(use-package consult-todo)
;; languages
;;; rust

(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :config
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-annot-activate-created-annotations t)
  (require 'pdf-tools)
  (require 'pdf-view)
  (require 'pdf-misc)
  (require 'pdf-occur)
  (require 'pdf-util)
  (require 'pdf-annot)
  (require 'pdf-info)
  (require 'pdf-isearch)
  (require 'pdf-history)
  (require 'pdf-links)
  (pdf-tools-install :no-query)
  )
(use-package zen-mode)

(use-package envrc
  :init
  (envrc-global-mode))

(provide 'emacs)
;;; emacs.el ends here
