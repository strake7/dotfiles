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

;;; Project workspaces

(defun strake/project-worktree-workspace ()
  "Open a project in a new workspace, optionally in a fresh git worktree.

Prompts for a known project. If it's a git repo, prompts for a
worktree name, creates the worktree as a sibling directory named
PROJECT-WORKTREE, and opens it in a workspace of the same name.
Leave the worktree name empty (or pick a non-git project) to open
the project directly in a workspace named after it."
  (interactive)
  (let* ((project (file-name-as-directory
                   (expand-file-name
                    (completing-read "Select project: "
                                     projectile-known-projects nil t))))
         (project-name (projectile-project-name project))
         (git-p (locate-dominating-file project ".git"))
         (wt-name (when git-p
                    (string-trim (read-string "Worktree name (empty to skip): ")))))
    (if (and wt-name (not (string-empty-p wt-name)))
        (let* ((ws-name (format "%s-%s" project-name wt-name))
               (wt-path (expand-file-name
                         ws-name
                         (file-name-directory (directory-file-name project)))))
          (unless (file-directory-p wt-path)
            (let* ((default-directory project)
                   (branch-exists
                    (zerop (call-process "git" nil nil nil "rev-parse" "--verify"
                                         (concat "refs/heads/" wt-name))))
                   (exit (if branch-exists
                             (call-process "git" nil "*git-worktree*" nil
                                           "worktree" "add" wt-path wt-name)
                           (call-process "git" nil "*git-worktree*" nil
                                         "worktree" "add" "-b" wt-name wt-path))))
              (unless (zerop exit)
                (pop-to-buffer "*git-worktree*")
                (user-error "git worktree add failed"))))
          (+workspace-switch ws-name t)
          (projectile-add-known-project wt-path)
          (projectile-switch-project-by-name wt-path))
      (progn
        (+workspace-switch project-name t)
        (projectile-switch-project-by-name project)))))

(map! :leader
      :desc "Project in new workspace" "p W" #'strake/project-worktree-workspace
      :desc "Project in new workspace" "TAB w" #'strake/project-worktree-workspace)

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
        '("~/src/org/todo.org"))
  (setq org-todo-keywords
        '((sequence "TODO" "STRT" "WAIT" "|" "DONE" "KILL")))
  (setq org-log-done 'time))

(use-package! treesit-auto
  :custom
  (treesit-auto-install t)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(setq treesit-font-lock-level 4)

;;; AI tooling

;; (after! gptel
;;   (setq gptel-backend
;;         (gptel-make-anthropic "Claude"
;;           :stream t
;;           :key (getenv "ANTHROPIC_API_KEY")))
;;   (setq gptel-model 'claude-sonnet-4-5-20250514))

(use-package! alert
  :config
  (setq alert-default-style 'osx-notifier))

(use-package! agent-shell
  :config
  (setq agent-shell-display-action
        '((display-buffer-in-direction) (direction . right)))
  (setq agent-shell-anthropic-claude-environment
        (agent-shell-make-environment-variables :inherit-env t))
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t))
  (add-hook 'agent-shell-mode-hook
            (lambda ()
              (agent-shell-subscribe-to
               :shell-buffer (current-buffer)
               :event 'turn-complete
               :on-event
               (lambda (event)
                 (unless (get-buffer-window (map-nested-elt event '(:data :buffer)))
                   (alert "Agent finished working"
                          :title "Agent Shell"
                          :category 'agent-shell)))))))

(map! :leader
      (:prefix-map ("a" . "AI")
       :desc "ECA Menu" "a" #'eca-transient-menu
       :desc "GPTel menu" "g" #'gptel-menu
       :desc "Toggle Agent Shell" "s" #'agent-shell
       :desc "New Agent Shell" "S" #'agent-shell-new-shell
       :desc "Restart Agent Shell" "r" (cmd! (let ((agent-shell-display-action '((display-buffer-same-window))))
                                               (agent-shell-restart)))))
