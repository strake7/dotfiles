(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("fe1c13d75398b1c8fd7fdd1241a55c286b86c3fe4ce513c4292d01383de152cb7" default))
 '(package-selected-packages '(counsel ivy-hydra dracula-theme)))
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
;;(menu-bar-mode -1)
;;(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Better default modes
(electric-pair-mode t)
(show-paren-mode 1)
(setq-default indent-tabs-mode nil)
(save-place-mode t)
(savehist-mode t)
(recentf-mode t)
(global-auto-revert-mode t)



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

;; no audio cues
(setq visible-bell t)
(setq ring-bell-function 'ignore)


(set-frame-font "Fira Code 13" nil t)
(load-theme 'dracula' t)

;; Improved minibuffer completion
(use-package vertico
  :ensure t
  :custom
  (vertico-cycle t)
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case 
  (Completion-styles '(basic substring partial-completion flex))
  :init
  (vertico-mode))

;; `orderless' minibuffer completion style
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Save minibuffer results
(use-package savehist
  :init
  (savehist-mode))

;; LSP support
(use-package eglot
  :ensure t
  :hook (ruby-mode . eglot-ensure))

;; Show moar stuff in the minibuffer
(use-package marginalia
  :after vertico
  :ensure t
  :init
  (marginalia-mode))


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
