(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("fe1c13d75398b1c8fd7fdd1241a55c286b86c3fe4ce513c4292d01383de152cb7" default))
 '(package-selected-packages '(dracula-theme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(add-to-list 'image-types 'svg)
(setq-default line-spacing 0)

;; Performance tweaking for modern machines
(setq gc-cons-threshold 100000000)
;; Increase the amount of data which Emacs reads from the process
(setq read-processd-output-max (* 1024 1024))

;; Hide UI
;; (menu-bar-mode -1)
;; (tool-bar-mode -1)
(scroll-bar-mode -1)

;; Better default modes
(electric-pair-mode t)
(show-paren-mode 1)
(setq-default indent-tabs-mode nil)
(save-place-mode t)
(recentf-mode t)
(global-auto-revert-mode t)
(global-display-line-numbers-mode t)

;; (setq display-line-numbers 'relative)
;; no audio cues
(setq visible-bell t)
(setq ring-bell-function 'ignore)
;; font, themes, oh my
(set-frame-font "JetBrains Mono 13" nil t)
(load-theme 'dracula' t)
(setq warning-minimum-level :error)


;; Not using package.el, use straight
;; (require 'package)
;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; (package-initialize)

;; Add straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; use-package sugar
(straight-use-package 'use-package)

;; Better buffer names
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward
      window-resize-pixelwise t
      frame-resize-pixelwise t
      load-prefer-newer t
      backup-by-copying t
      custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Pickup PATH from system SHELL
(use-package exec-path-from-shell
  :straight t
  :init
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize))
  )

;; Improved minibuffer completion
(use-package vertico
  :straight t
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package orderless
  :straight t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))
                                 ;; '((xref-location (styles basic)))
                                 )
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t)
  )

;; Save minibuffer results
(use-package savehist
  :straight
  :config
  (savehist-mode))

;; magit
(use-package magit
  :straight t)
;; (use-package forge
;;   :after magit)

;; LSP support
;; (use-package eglot
;;   :straight t
;;   :init
;;   (add-hook 'ruby-mode-hook 'eglot-ensure)
;;   (add-hook 'web-mode-hook 'eglot-ensure)
;;   (add-hook 'sql-mode-hook 'eglot-ensure)
;;   (with-eval-after-load 'eglot
;;     (add-to-list 'eglot-server-programs
;;                  '(web-mode . ("typescript-language-server" "--stdio"))
;;                  (add-to-list 'eglot-server-programs
;;                               '(sql-mode . ("sql-language-server" "up" "--method" "stdio"))
;;                               ))
;;     ;; We want rubocop to run via ruby-mode; make eglot stay out
;;     ;; of flymake so ruby-mode can report rubcoop offenses
;;     (add-to-list 'eglot-stay-out-of 'flymake)
;;     (add-hook 'eglot--managed-mode-hook (lambda ()
;;                                           (add-hook 'flymake-diagnostic-functions 'eglot-flymake-backend nil t)
;;                                           ))
;;     ;; ensure to start flymake-mode
;;     ;; (add-hook 'web-mode-hook 'flymake-mode)
;;     (add-hook 'ruby-mode-hook 'flymake-mode)
;;     )
;;   :bind
;;   (("s-." . eglot-code-actions))
;;  )

(use-package lsp-mode
  :straight t
  :init
  (add-hook 'ruby-mode-hook 'lsp)
  (add-hook 'web-mode-hook 'lsp)
  :bind
  (("s-." . lsp-execute-code-action))
  :config
  ;; (setq lsp-solargraph-server-command ("cd" "backend" "&&" "./solargraph" "stdio"))
  (setq lsp-solargraph-use-bundler t)

)
;; (put 'lsp-solargraph-server-command 'safe-local-variable (lambda (_) t))


;; TODO: enable once PR is merged
;; (use-package emacs-format-all-the-code
;; :straight t
;; :init
;; (add-hook 'prog-mode-hook 'format-all-mode)
(add-hook 'ruby-mode-hook 'format-all-mode)
;; )

(use-package eslint-fix
  :straight t
  :init
  (add-hook 'web-mode-hook 'eslint-fix-auto-mode))

(use-package tree-sitter
  :straight t
  :init
  (add-hook 'after-init-hook 'global-tree-sitter-mode)
  (add-hook 'ruby-mode-hook 'tree-sitter-hl-mode)
  )

(use-package tree-sitter-langs
  :straight t)

;; use company everywhere
(use-package company
  :straight t
  :init
  (add-hook 'after-init-hook 'global-company-mode)
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.0)
  :bind (
         ("C-c C-c" . company-complete)
         ("M-<tab>" . company-complete)
         )
  )

;; completion with corfu M-TAB
;; (use-package corfu
;;   :straight t
;;   ;; Optional customizations
;;   :custom
;;   ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
;;   (corfu-auto t)                 ;; Enable auto completion
;;   (corfu-separator ?\s)          ;; Orderless field separator
;;   ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
;;   (corfu-auto-delay 0)
;;   (corfu-auto-prefix 0)
;;   ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
;;   ;; (corfu-preview-current nil)    ;; Disable current candidate preview
;;   ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
;;   ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
;;   ;; (corfu-scroll-margin 5)        ;; Use scroll margin

;;   ;; Enable Corfu globally.
;;   ;; This is recommended since Dabbrev can be used globally (M-/).
;;   ;; See also `corfu-exclude-modes'.
;;   :init
;;   (global-corfu-mode))

;; svg icons for corfu
;; (use-package svg-lib
;;   :straight t)
(use-package kind-icon
  :straight (:host github :repo "jdtsmith/kind-icon" :files ("*.el"))
  :after corfu svg-lib
  :custom
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package store-git-link
  :straight (:host github :repo "mgmarlow/store-git-link" :files ("*.el"))
)

(use-package copilot
  :straight (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el"))
  :straight t
  :init
  (add-hook 'prog-mode-hook 'copilot-mode)
  :bind
  (:map copilot-completion-map
        ("C-c RET" . copilot-accept-completion)
        ("C-c /" . copilot-accept-completion-by-word)
        )
  )


;; Show moar stuff in the minibuffer
(use-package marginalia
  ;; :after vertico
  :straight t
  :init
  (marginalia-mode))

;; Use Vi layer
(use-package evil
  :straight t
  :init
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))
(put 'narrow-to-page 'disabled nil)

;; Add more Vi keybindings
(use-package evil-collection
  :straight t
  :config
  (evil-collection-init))

(use-package web-mode
  :straight t
  :mode (("\\.ts\\'" . web-mode)
         ("\\.js\\'" . web-mode)
         ("\\.mjs\\'" . web-mode)
         ("\\.tsx\\'" . web-mode)
         ("\\.jsx\\'" . web-mode))
  :config
  (setq web-mode-content-types-alist
        '(("jsx" . "\\.js[x]?\\'"))))

(use-package yaml-mode
  :straight t
  :config
  (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
  :init
  (add-hook 'yaml-mode-hook 'flycheck-mode)
  )

(use-package diff-hl
  :straight t
  :init
  (global-diff-hl-mode)
  (add-hook 'dired-mode-hook 'diff-hl-dired-mode)
  :config
  (diff-hl-margin-mode)
  (diff-hl-show-hunk-mouse-mode))

;; Sticky fn header
;; lsp-mode is better
;; (use-package topsy
;;   :straight t
;;   :hook (prog-mode . topsy-mode))

(use-package consult
  :straight t
  :init
  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :bind (
         ("s-i" . consult-imenu)
         ("s-I" . consult-imenu-multi)
         ;; ("s-f" . consult-line)
         ;; ("s-F" . consult-ripgrep)
         ("s-R" . consult-recent-file)
         ;; C-c bindings in `mode-specific-map'
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
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
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
         ("C-s" . consult-history)                 ;; orig. next-matching-history-element
         ("C-r" . consult-history)
         ))

(use-package consult-lsp
  :straight t
  :after (consult lsp-mode)
)

(use-package flycheck
  :straight t
)


;; rspec help
(use-package rspec-mode
  :straight t
)

(use-package rainbow-delimiters
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package highlight-indent-guides
  :straight t
  :config
  (setq highlight-indent-guides-method 'character)
  (setq highlight-indent-guides-responsive 'top)
  (setq highlight-indent-guides-auto-enabled nil)
  (set-face-foreground 'highlight-indent-guides-character-face "grey20")
  (set-face-foreground 'highlight-indent-guides-top-character-face "purple")
  :hook 
  (prog-mode . highlight-indent-guides-mode)
  )

;; Custom fns
(defun highlight-selected-window ()
  "Highlight selected window with a different background color."
  (walk-windows (lambda (w)
                  (unless (eq w (selected-window))
                    (with-current-buffer (window-buffer w)
                      ;; (buffer-face-set '(:background "#555"))
                      (set-face-background 'mode-line "purple")
                      ;; (set-face-foreground 'mode-line "#f8f8f2")
                      (set-cursor-color "green")))))
  (buffer-face-set 'default))
(add-hook 'buffer-list-update-hook 'highlight-selected-window)

(defun show-file-name ()
  "Show the full path file name in the minibuffer."
  (interactive)
  (message (buffer-file-name)))

(defun yank-file-name ()
  "Yank the full path file name to kill ring."
  (interactive)
  (kill-new (buffer-file-name)))

(defun prompt-xref-find-definitions ()
  "Prompt to find the definition of an identifier."
  (interactive)
  (let ((current-prefix-arg '(4)))
    (call-interactively #'xref-find-definitions))
  )

;; keybindings
(global-set-key (kbd "s-/") 'comment-line)
(global-set-key (kbd "s-p") 'project-find-file)
(global-set-key (kbd "s-t") 'prompt-xref-find-definitions)
(global-set-key (kbd "s-<left>") 'evil-prev-buffer)
(global-set-key (kbd "s-}") 'evil-window-next)
(global-set-key (kbd "s-{") 'evil-window-prev)
(global-set-key (kbd "s-<right>") 'evil-next-buffer)

;; Line numbers as relative
(put 'narrow-to-region 'disabled nil)
