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
  (setq uniquify-buffer-name-style 'forward))

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

;;; Eshell

(set-eshell-alias!
  "config" "git --git-dir=$HOME/.cfg/.git --work-tree=$HOME $*"
  "y"      "yarn $*"
  "b"      "bundle $*")

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
  (setq org-log-done 'time)

  ;; --- inline image support ---
  (setq org-startup-with-inline-images t)   ; show images when opening a file
  (setq org-image-actual-width '(600))      ; cap width at 600px, respect #+ATTR
  (setq org-display-remote-inline-images 'download)) ; render http(s) images too

;; --- paste / drag-drop images into org (org-download) ---
(use-package! org-download
  :after org
  :config
  (setq org-download-method 'directory
        org-download-image-dir "./images"      ; store next to the .org file
        org-download-heading-lvl nil           ; don't nest by heading
        org-download-screenshot-method "pngpaste %s")
  (map! :map org-mode-map
        :localleader
        :desc "Paste image from clipboard" "P" #'org-download-clipboard))

;; --- paste clipboard image into agent-shell as an @mention ---
(after! agent-shell
  (defun strake/agent-shell-paste-image ()
    "Save clipboard image to a temp file and insert an @mention for it."
    (interactive)
    (let ((file (expand-file-name
                 (format "agent-shell-%s.png" (format-time-string "%Y%m%d-%H%M%S"))
                 (temporary-file-directory))))
      (if (zerop (call-process "pngpaste" nil nil nil file))
          (insert (format "@\"%s\" " file))
        (user-error "No image in clipboard (pngpaste failed)"))))
  (map! :map agent-shell-mode-map
        :localleader
        :desc "Paste image from clipboard" "p" #'strake/agent-shell-paste-image))

;;; AI tooling

(use-package! alert
  :config
  (setq alert-default-style 'osx-notifier))

(defvar-local strake/agent-shell-workspace nil
  "Workspace in which this agent shell was created.")

(defun strake/agent-shell-switch ()
  "Switch to a live agent shell in its native workspace."
  (interactive)
  (let* ((buffer (agent-shell--read-shell-buffer :prompt "Switch to shell: "))
         (native-workspace
          (buffer-local-value 'strake/agent-shell-workspace buffer))
         (project-name
          (with-current-buffer buffer
            (when (fboundp 'projectile-project-name)
              (projectile-project-name (agent-shell-cwd)))))
         (workspace
          (or (and native-workspace
                   (+workspace-get native-workspace t))
              (and project-name (+workspace-get project-name t))
              (seq-find (lambda (candidate)
                          (+workspace-contains-buffer-p buffer candidate))
                        (+workspace-list)))))
    (when workspace
      (+workspace-switch (safe-persp-name workspace)))
    (agent-shell--display-buffer buffer)))

(use-package! agent-shell
  :config
  ;; Keep the new-shell picker, with Claude Code first and preselected.
  (setq agent-shell-preferred-agent-config '(preselect . claude-code)
        ;; Offer saved sessions when a project has no live shell.
        agent-shell-session-strategy 'prompt
        agent-shell-session-restore-verbosity 'full)
  ;; Built-in macOS sound; replace this path with a song when ready.
  (setq strake/agent-shell-completion-sound "/System/Library/Sounds/Hero.aiff")
  (setq agent-shell-display-action
        '((display-buffer-in-direction) (direction . right)))
  (setq agent-shell-anthropic-claude-environment
        (agent-shell-make-environment-variables :inherit-env t))
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t))
  (add-hook 'agent-shell-mode-hook
            (lambda ()
              (setq-local strake/agent-shell-workspace
                          (when (bound-and-true-p persp-mode)
                            (+workspace-current-name)))
              (agent-shell-subscribe-to
               :shell-buffer (current-buffer)
               :event 'turn-complete
               :on-event
               (lambda (event)
                 (let ((buffer (map-nested-elt event '(:data :buffer))))
                   (unless (get-buffer-window buffer)
                     (when (file-readable-p strake/agent-shell-completion-sound)
                       (start-process "agent-shell-completion-sound" nil
                                      "afplay" strake/agent-shell-completion-sound))
                     (alert (format "%s finished" (buffer-name buffer))
                            :title "Agent Shell"
                            :category 'agent-shell))))))))

(map! :leader
      (:prefix-map ("a" . "AI")
       :desc "ECA Menu" "a" #'eca-transient-menu
       :desc "GPTel menu" "g" #'gptel-menu
       :desc "Open Project Shell" "s" #'agent-shell
       :desc "New Project Shell" "S" #'agent-shell-new-shell
       :desc "Switch Live Shell" "b" #'strake/agent-shell-switch
       :desc "Restart Agent Shell" "r" (cmd! (let ((agent-shell-display-action '((display-buffer-same-window))))
                                               (agent-shell-restart)))))
