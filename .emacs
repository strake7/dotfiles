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

;; Performance tweaking for modern machines
(setq gc-cons-threshold 100000000)
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
(savehist-mode t)
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


(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

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
  :ensure t
  :init
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize))
  )

;; Improved minibuffer completion
(use-package vertico
  :ensure t
  :custom
  (vertico-cycle t)
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t)
  (Completion-styles '(basic substring partial-completion flex))
  :init
  (vertico-mode))

;; `orderless' minibuffer completion style
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        ;; completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Save minibuffer results
(use-package savehist
  :init
  (savehist-mode))

;; magit
(use-package magit
  :ensure t)
;; (use-package forge
;;   :after magit)

;; LSP support
(use-package eglot
  :ensure t
  :init
  (add-hook 'ruby-mode-hook 'eglot-ensure)
  (add-hook 'web-mode-hook 'eglot-ensure)
  (add-hook 'sql-mode-hook 'eglot-ensure)
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '(web-mode . ("typescript-language-server" "--stdio"))
                 (add-to-list 'eglot-server-programs
                              '(sql-mode . ("sql-language-server" "up" "--method" "stdio"))
                              ))
    ;; We want rubocop to run via ruby-mode; make eglot stay out
    ;; of flymake so ruby-mode can report rubcoop offenses
    (add-to-list 'eglot-stay-out-of 'flymake)
    (add-hook 'eglot--managed-mode-hook (lambda ()
                                          (add-hook 'flymake-diagnostic-functions 'eglot-flymake-backend nil t)
                                          ))
    ;; ensure to start flymake-mode
    (add-hook 'ruby-mode-hook 'flymake-mode)
    (add-hook 'lsp-mode 'flymake-mode)
    ))

;; TODO: enable once PR is merged
;; (use-package emacs-format-all-the-code
;; :ensure t
;; :init
(add-hook 'prog-mode-hook 'format-all-mode)
;; )

(use-package tree-sitter
  :ensure t
  :init
  (add-hook 'after-init-hook 'global-tree-sitter-mode)
  )

(use-package tree-sitter-langs
  :ensure t)

;; use company everywhere
(use-package company
  :ensure
  t
  :init
  (add-hook 'after-init-hook 'global-company-mode))

;; co-pilot TODO: use straigh el
;; (use-package copilot
;;   :straight (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el"))
;;   :ensure t
;;   :init
;;   (add-hook 'prog-mode-hook 'copilot-mode))

;; Show moar stuff in the minibuffer
(use-package marginalia
  :after vertico
  :ensure t
  :init
  (marginalia-mode))

;; Use Vi layer
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

;; Add more Vi keybindings
(use-package evil-collection
  :ensure t
  :config
  (evil-collection-init))

(use-package web-mode
  :ensure t
  :mode (("\\.ts\\'" . web-mode)
         ("\\.js\\'" . web-mode)
         ("\\.mjs\\'" . web-mode)
         ("\\.tsx\\'" . web-mode)
         ("\\.jsx\\'" . web-mode))
  :config
  (setq web-mode-content-types-alist
        '(("jsx" . "\\.js[x]?\\'"))))

(use-package diff-hl
  :ensure f
  :init
  (global-diff-hl-mode)
  (add-hook 'dired-mode-hook 'diff-hl-dired-mode)
  :config
  (diff-hl-margin-mode)
  (diff-hl-show-hunk-mouse-mode))

;; Sticky fn header
(use-package topsy
  :ensure t
  :hook (prog-mode . topsy-mode))

;; Custom fns
(defun highlight-selected-window ()
  "Highlight selected window with a different background color."
  (walk-windows (lambda (w)
                  (unless (eq w (selected-window))
                    (with-current-buffer (window-buffer w)
                      ;; (buffer-face-set '(:background "#555"))
                      (set-face-background 'mode-line "black")
                      ;; (set-face-foreground 'mode-line "#f8f8f2")
                      (set-cursor-color "cyan")))))
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


;; keybindings
(global-set-key (kbd "s-/") 'comment-line)
(global-set-key (kbd "s-p") 'project-find-file)
(global-set-key (kbd "s-O") 'counsel-imenu)
(global-set-key [C-f1] 'show-file-name)


;;(ivy-mode)
;;(setq ivy-use-virtual-buffers t)
;;(setq enable-recursive-minibuffers t)
;; enable this if you want `swiper' to use it
;; (setq search-default-mode #'char-fold-to-regexp)
;; (global-set-key "\C-s" 'swiper)
;; ;; (global-set-key (kbd "C-c C-r") 'ivy-resume)
;; ;; (global-set-key (kbd "<f6>") 'ivy-resume)
;; (global-set-key (kbd "M-x") 'counsel-M-x)
;; (global-set-key (kbd "C-x C-f") 'counsel-find-file)
;; (global-set-key (kbd "<f1> f") 'counsel-describe-function)
;; (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
;; (global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
;; (global-set-key (kbd "<f1> l") 'counsel-find-library)b
;; (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
;; (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
;; (global-set-key (kbd "C-c g") 'counsel-git)
;; (global-set-key (kbd "C-c j") 'counsel-git-grep)
;; (global-set-key (kbd "C-c k") 'counsel-ag)
;; (global-set-key (kbd "C-x l") 'counsel-locate)
;; (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
;; (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history

;; if you want to change prefix for lsp-mode keybindings.
;; (setq lsp-keymap-prefix "s-i")

;;(require 'lsp-mode)
;;(add-hook 'ruby-mode #'lsp)
;;(add-hook 'ruby-mode 'global-company-mode)

;; Line numbers as relative
