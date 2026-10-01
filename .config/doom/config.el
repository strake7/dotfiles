;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; Identity

(setq user-full-name "Nolan Sedley"
      user-mail-address "nsedley@gmail.com")

;;; Appearance

(setq doom-font (font-spec :family "JetBrains Mono" :size 14))
(setq doom-variable-pitch-font (font-spec :family "JetBrains Mono" :size 14))
(setq doom-theme 'doom-dracula)
(setq display-line-numbers-type t)

(after! doom-themes
  (doom-themes-org-config))

(defun strake/clear-fringe (&rest _)
  (set-face-attribute 'fringe nil :background 'unspecified))
(add-hook 'enable-theme-functions #'strake/clear-fringe)
(strake/clear-fringe)   ; also apply now, for the no-theme case

;;; Editor defaults

(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

(after! uniquify
  (setq uniquify-buffer-name-style 'forward))

;;; EEEEVVIIIIL 

(map! "C-SPC" #'er/expand-region)
(map! "C-l" #'evil-window-right)
(map! "C-h" #'evil-window-left)
(map! "C-j" #'evil-window-down)
(map! "C-k" #'evil-window-up)
(map! :n "j" #'evil-next-visual-line
      :n "k" #'evil-previous-visual-line
      :m "j" #'evil-next-visual-line
      :m "k" #'evil-previous-visual-line)

;;; Minibuffer
 
(use-package! consult
  :bind
  (:map minibuffer-local-map
        ("C-r" . consult-history)))

;;; Project workspaces

(defun strake/--ensure-worktree (project wt-name wt-path)
  "Create git worktree WT-NAME at WT-PATH, checked out from the repo at PROJECT.
Checks out the existing branch WT-NAME if there is one.  Otherwise, if
origin/WT-NAME exists, creates WT-NAME tracking it; failing that, creates
a fresh branch WT-NAME.  No-op if the WT-PATH already exists."
  (unless (file-directory-p wt-path)
    (let* ((default-directory project)
           (ref-exists-p (lambda (ref)
                           (zerop (call-process "git" nil nil nil "rev-parse"
                                                "--verify" "--quiet" ref))))
           (remote-ref (concat "origin/" wt-name))
           (args (cond ((funcall ref-exists-p (concat "refs/heads/" wt-name))
                        (list wt-path wt-name))
                       ((funcall ref-exists-p (concat "refs/remotes/" remote-ref))
                        (list "--track" "-b" wt-name wt-path remote-ref))
                       (t (list "-b" wt-name wt-path))))
           (exit (apply #'call-process "git" nil "*git-worktree*" nil
                        "worktree" "add" args)))
      (unless (zerop exit)
        (pop-to-buffer "*git-worktree*")
        (user-error "git worktree add failed")))))

(defun strake/new-workspace-with-worktree ()
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
                    (string-trim (read-string "Worktree name (empty to skip): "))))
         (worktree-p (and wt-name (not (string-empty-p wt-name))))
         (ws-name (if worktree-p
                      (format "%s-%s" project-name wt-name)
                    project-name))
         (path (if worktree-p
                   (expand-file-name
                    ws-name
                    (file-name-directory (directory-file-name project)))
                 project)))
    (when worktree-p
      (strake/--ensure-worktree project wt-name path)
      (projectile-add-known-project path))
    (+workspace-switch ws-name t)
    (projectile-switch-project-by-name path)))

(map! :leader
      :desc "Project in new workspace" "p W" #'strake/new-workspace-with-worktree
      :desc "Project in new workspace" "TAB w" #'strake/new-workspace-with-worktree)

;;; Comint

;; Doom's `doom--if-compile' (behind `doom/reload', `doom/upgrade', ...) calls
;; `local-set-key' in a comint-based compilation buffer, whose local map *is*
;; `comint-mode-map'.  That permanently leaks `q' -> `quit-window' into every
;; comint-derived mode.  Evil's normal state shadows it, but in insert state
;; typing `q' quits the window, which makes composing a prompt in `agent-shell'
;; (its keymap inherits `comint-mode-map' via `shell-maker-mode-map') impossible.
;; Drop the global binding and hand it back to the compile buffer that wanted it.
(defun strake/comint-unleak-q (&optional buffer &rest _)
  "Remove the stray `q' -> `quit-window' binding from `comint-mode-map'.
Rebind it locally in BUFFER so the compile buffer still quits on `q'."
  (when (eq (keymap-lookup comint-mode-map "q") #'quit-window)
    (keymap-unset comint-mode-map "q" t)
    (when (buffer-live-p buffer)
      (with-current-buffer buffer
        (use-local-map (let ((map (make-sparse-keymap)))
                         (set-keymap-parent map (current-local-map))
                         (keymap-set map "q" #'quit-window)
                         map))))))

(after! comint
  (strake/comint-unleak-q)
  (add-hook 'compilation-finish-functions #'strake/comint-unleak-q))

;;; Vterm 

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

;;; Org

(after! org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (sql . t)))
  (setq org-directory "~/src/org/")
  (setq org-agenda-files
        '("~/src/org/todo.org"
          "~/src/org/agent-inbox.org"))
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

;;; AI

(defvar strake/agent-shell-completion-sound "/System/Library/Sounds/Hero.aiff"
  "Sound played when an agent shell finishes a turn while off-screen.")

(defvar-local strake/agent-shell-workspace nil
  "Workspace in which this agent shell was created.")

(defun strake/agent-shell-cd (dir)
  "Restart the current agent shell in DIR.
`agent-shell-restart' inherits the shell buffer's `default-directory',
so setting it here is enough to move the shell."
  (interactive "DNew directory: ")
  (setq default-directory (file-name-as-directory (expand-file-name dir)))
  (agent-shell-restart))

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
        agent-shell-anthropic-default-session-mode-id "auto"
        ;; Offer saved sessions when a project has no live shell.
        agent-shell-session-strategy 'prompt
        agent-shell-session-restore-verbosity 'full)
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
                   (unless (or (get-buffer-window buffer)
                               ;; Scheduled runs are off-screen by design and
                               ;; report through org, not notifications.
                               (and (fboundp 'org-agent-scheduler-shell-buffer-p)
                                    (org-agent-scheduler-shell-buffer-p buffer)))
                     (when (file-readable-p strake/agent-shell-completion-sound)
                       (start-process "agent-shell-completion-sound" nil
                                      "afplay" strake/agent-shell-completion-sound))
                     (alert (format "%s finished" (buffer-name buffer))
                            :title "Agent Shell"
                            :category 'agent-shell))))))))

;; Clipboard images are handled upstream by `agent-shell-yank-dwim', already
;; bound to `<remap> <yank>' in `agent-shell-mode-map'.
(map! :leader
      (:prefix-map ("a" . "AI")
       :desc "Open Project Shell" "s" #'agent-shell
       :desc "New Project Shell" "S" #'agent-shell-new-shell
       :desc "Switch Live Shell" "b" #'strake/agent-shell-switch
       :desc "Change Shell Directory" "d" #'strake/agent-shell-cd
       :desc "Restart Agent Shell" "r" (cmd! (let ((agent-shell-display-action '((display-buffer-same-window))))
                                               (agent-shell-restart)))))

;;; Scheduled agents

;; Runs agent-shell sessions on a schedule and files their output as org
;; agenda items.  Each run is handed a JSON output contract, so a task that
;; produces nothing is a reported failure rather than a silent no-op.
(load! "lisp/org-agent-scheduler")

(after! org-agent-scheduler
  ;; Leave `org-agent-scheduler-default-cwd' nil: the module resolves it to
  ;; `org-directory' when a run starts, by which point (after! org ...) has run.
  (setq org-agent-scheduler-default-org-file "agent-inbox.org"
        ;; Nobody is watching to answer permission prompts mid-run.
        org-agent-scheduler-default-session-mode "auto"
        org-agent-scheduler-keep-shell-buffers 'on-error)

  ;; Hourly Slack/GitHub triage, via the slack-monitor skill in ~/src/org.
  ;; Skills are resolved from the session's working directory, so :cwd is what
  ;; makes .claude/skills/slack-monitor visible to the agent.
  ;;
  ;; The skill's triage window is ~90 minutes against an hourly cadence, so
  ;; consecutive runs deliberately overlap.  Each item carries its Slack
  ;; permalink as :key, and the scheduler skips keys already filed -- that
  ;; overlap is what stops something slipping through, and the key is what
  ;; stops it arriving twice.
  (setq org-agent-scheduler-tasks
        '((:name "slack-triage"
           :schedule (:every 3600)
           :cwd "~/src/org"
           :skill "slack-monitor"
           :org-file "agent-inbox.org"
           :org-headline "Slack triage"
           :tags ("slack" "triage")
           :timeout 900
           :prompt "Run in TRIAGE mode: steps 1 and 2 only.  Do not run the \
briefing steps and do not write a briefing file.

This run is unattended -- there is no one in the chat to read a digest -- so \
instead of printing the ranked list, emit one scheduler item per triage item:

  heading    the item's headline, one line: who and what
  priority   \"A\" for Needs you now, \"B\" for Should respond today, \"C\" for FYI
  key        the item's Slack permalink.  Required: it is how a later run \
recognises this item as already filed.
  body       why it matters in one sentence, the permalink as an org link, \
then the draft reply -- or \"Needs your call:\" and the specific open question \
when you cannot draft one without information you do not have.
  scheduled  today's date for Needs you now, otherwise leave empty
  tags       add \"blocker\", \"morale\" or \"review\" where the skill's filter \
matched for that reason

Apply the skill's filter exactly as written: only things needing him.  If \
nothing meets that bar, write {\"items\": []} -- do not manufacture items.

Never post to Slack: no messages, thread replies, scheduled messages or \
reactions.  Drafts only.")))

  ;; A task is never run on first sighting -- the first tick only records its
  ;; next-run -- so enabling here starts the cycle an hour out, not instantly.
  (org-agent-scheduler-mode 1))

(map! :leader
      (:prefix-map ("a" . "AI")
       (:prefix ("c" . "Scheduler")
        :desc "Toggle scheduler"  "t" #'org-agent-scheduler-mode
        :desc "Status"            "s" #'org-agent-scheduler-status
        :desc "Run task now"      "r" #'org-agent-scheduler-run-now
        :desc "Visit run buffer"  "b" #'org-agent-scheduler-visit-run-buffer
        :desc "Cancel run"        "k" #'org-agent-scheduler-cancel)))

;;; Utility

(use-package! alert
  :config
  (setq alert-default-style 'osx-notifier))
