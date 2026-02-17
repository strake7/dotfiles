;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; Identity

(setq user-full-name "Nolan Sedley"
      user-mail-address "nsedley@gmail.com")

;;; Appearance

(setq doom-font (font-spec :family "JetBrains Mono" :size 13))
(setq doom-variable-pitch-font (font-spec :family "JetBrains Mono" :size 13))
(setq doom-theme 'doom-dracula)
(setq display-line-numbers-type t)

(after! doom-themes
  (doom-themes-org-config))

;;; Editor defaults

(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

(after! uniquify
  (setq uniquify-buffer-name-style 'post-forward-angle-brackets))

;;; Keybindings

(map! "C-SPC" #'er/expand-region)
(map! "C-l" #'evil-window-right)
(map! "C-h" #'evil-window-left)
(map! "C-j" #'evil-window-down)
(map! "C-k" #'evil-window-up)
(map! :n "j" #'evil-next-visual-line
      :n "k" #'evil-previous-visual-line
      :m "j" #'evil-next-visual-line
      :m "k" #'evil-previous-visual-line)

(use-package! consult
  :bind
  (:map minibuffer-local-map
        ("C-s" . consult-history)
        ("C-r" . consult-history)))

;;; Terminal

(after! vterm
  (map! :map vterm-mode-map
        "C-c ESC" #'vterm-send-escape))

;;; Languages

(defvar-local use-project-ruby-lsp nil
  "If non-nil, eglot will use bundle exec ruby-lsp for this project.")
(defvar-local use-project-solargraph nil
  "If non-nil, eglot will use bundle exec solargraph for this project.")

(after! org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (sql . t)))
  (setq org-directory "~/src/org/")
  (setq org-agenda-files
        (directory-files-recursively "~/src/org" "\\.org$")))

(use-package! treesit-auto
  :custom
  (treesit-auto-install t)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(setq treesit-font-lock-level 4)

;;; AI tooling

(after! gptel
  (setq gptel-backend
        (gptel-make-anthropic "Claude"
          :stream t
          :key (getenv "ANTHROPIC_API_KEY")))
  (setq gptel-model 'claude-sonnet-4-5-20250514))

(use-package! claude-code-ide
  :config
  (claude-code-ide-emacs-tools-setup))

(map! :leader
      (:prefix-map ("a" . "AI")
       :desc "Claude Code menu" "a" #'claude-code-ide-menu
       :desc "GPTel menu" "g" #'gptel-menu))
