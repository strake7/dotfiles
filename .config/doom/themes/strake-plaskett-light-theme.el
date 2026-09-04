;;; strake-plaskett-light-theme.el --- light variant of strake-plaskett -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; Date: September 4, 2026
;; Author: strake7 <https://github.com/strake7>
;; Maintainer:
;; Source: doom-miramare 


(require 'doom-themes)

;; Compiler pacifier
(defvar modeline-bg)

;;
;;; Variables

(defgroup strake-plaskett-light-theme nil
  "Options for strake-plaskett-light."
  :group 'doom-themes)

(defcustom strake-plaskett-light-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'strake-plaskett-light-theme
  :type 'boolean)

(defcustom strake-plaskett-light-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'strake-plaskett-light-theme
  :type '(choice integer boolean))

;;
;;; Theme definition

(def-doom-theme strake-plaskett-light
                "A warm light variant of strake-plaskett."
                :family 'strake-plaskett
                :background-mode 'light

                ;; name        gui       256       16
                ((bg         '("#fbf4e9" "#fbf4e9" nil          )) ; L* 96.5 -- the anchor
                 (bg-alt     '("#f4ebdf" "#f4ebdf" nil          )) ; -3.0 L* (solaire / dimmed panes)
                 (bg-alt2    '("#d1bea8" "#d1bea8" "white"      )) ; region/selection, 1.65:1 vs bg
                 (hl-line-bg '("#f5e6d3" "#f5e6d3" nil          )) ; warm wash, 1.12:1; fg on it 8.79:1

                 ;; INVERTED vs the dark variant: base0 lightest -> base8 darkest.
                 ;; bg (96.5) sits between base0 and base1. base1-base3 are inset
                 ;; surfaces; base4 is the midtone; base5+ are foreground weights.
                 ;; 256 column mirrors gui throughout.
                 (base0      '("#fefcf8" "#fefcf8" "white"      )) ; L* 99.0  fg-on-accent
                 (base1      '("#e8ded1" "#e8ded1" "white"      )) ; L* 89.0  1.22:1
                 (base2      '("#e1d6c6" "#e1d6c6" "white"      )) ; L* 86.0  1.31:1  code-block bg
                 (base3      '("#d7caba" "#d7caba" "white"      )) ; L* 82.0  1.47:1  raised surface
                 (base4      '("#a39384" "#a39384" "brightblack")) ; L* 62.0  2.72:1
                 (base5      '("#7f6f63" "#7f6f63" "brightblack")) ; L* 48.0  4.41:1  line numbers
                 (base6      '("#6b5b52" "#6b5b52" "brightblack")) ; L* 40.0  5.93:1  comments
                 (base7      '("#4d3f3b" "#4d3f3b" "black"      )) ; L* 28.0  9.20:1
                 (base8      '("#342a29" "#342a29" "black"      )) ; L* 18.0 12.73:1
                 (fg         '("#473b38" "#473b38" "black"      )) ; L* 26.0  9.85:1
                 (fg-alt     '("#73665c" "#73665c" "brightblack")) ; L* 44.0  5.08:1  warm, hue 64

                 ;; Semantic colors: L* 37-47, all >= 4.5:1 on bg, no gamut clipping.
                 ;; Hues are carried over from the dark variant so the two read as
                 ;; siblings; chroma is boosted to stay legible at low lightness.
                 (grey       '("#baafa3" "#baafa3" "brightblack")) ; 1.97:1  window dividers
                 (red        '("#b54642" "#b54642" "red"        )) ; 4.90:1  h 30
                 (magenta    '("#9a5475" "#9a5475" "magenta"    )) ; 4.93:1  h 350
                 (violet     '("#5b5d9f" "#5b5d9f" "brightmagenta")) ; 5.47:1  h 295
                 (orange     '("#a35a2e" "#a35a2e" "brightred"  )) ; 4.73:1  h 55
                 (yellow     '("#906919" "#906919" "yellow"     )) ; 4.55:1  h 80
                 (teal       '("#32795f" "#32795f" "green"      )) ; 4.76:1  h 165
                 (green      '("#54733e" "#54733e" "green"      )) ; 4.93:1  h 130
                 (dark-green '("#425f32" "#425f32" "green"      )) ; 6.59:1  h 132
                 (blue       '("#1e708b" "#1e708b" "blue"       )) ; 5.04:1  h 236
                 (dark-blue  '("#3a6281" "#3a6281" "blue"       )) ; 5.92:1  h 258
                 (cyan       '("#09797c" "#09797c" "cyan"       )) ; 4.76:1  h 200
                 (dark-cyan  '("#117b6a" "#117b6a" "cyan"       )) ; 4.73:1  h 178

                 ;; face categories
                 (highlight      magenta)
                 (vertical-bar   grey)
                 (selection      bg-alt2)
                 (builtin        violet)
                 (comments       (if strake-plaskett-light-brighter-comments magenta base6))
                 (doc-comments   (if strake-plaskett-light-brighter-comments (doom-darken magenta 0.2) (doom-darken fg-alt 0.25))) ; [dir]
                 (constants      blue)
                 (functions      magenta)
                 (keywords       violet)
                 (methods        magenta)
                 (operators      blue)
                 (type           orange)
                 (strings        green)
                 (variables      cyan)
                 (numbers        red)
                 (region         bg-alt2)
                 (error          red)
                 (warning        yellow)
                 (success        green)

                 (vc-modified    (doom-darken blue 0.15))
                 (vc-added       (doom-darken green 0.15))
                 (vc-deleted     (doom-darken red 0.15))

                 ;; custom categories
                 (-modeline-pad
                  (when strake-plaskett-light-padded-modeline
                    (if (integerp strake-plaskett-light-padded-modeline)
                        strake-plaskett-light-padded-modeline
                      4)))

                 (org-quote `(,(doom-darken (car bg) 0.04) "#f0e8da"))) ; [dir]


  ;;;; Base theme face overrides
                ((button :foreground blue :underline t :bold t)
                 (cursor :background fg)                ; [dir] was "white"
                 (font-lock-variable-name-face :foreground cyan :italic nil :weight 'normal)
                 (hl-line :background hl-line-bg)
                 (isearch :foreground base0 :background orange)   ; base0 on orange 5.05:1
                 (lazy-highlight
                  :background yellow :foreground base0 :distant-foreground base0
                  :weight 'bold)                                  ; base0 on yellow 4.86:1
                 ((line-number &override) :foreground base5)
                 ((line-number-current-line &override) :background bg-alt2 :foreground fg :bold t)
                 (minibuffer-prompt :foreground cyan)
                 (mode-line
                  :background bg-alt2 :foreground (doom-darken fg-alt 0.25) ; [dir]
                  :box (if -modeline-pad `(:line-width ,-modeline-pad :color base3)))
                 (mode-line-inactive
                  :background bg :foreground base4
                  :box (if -modeline-pad `(:line-width ,-modeline-pad :color base2)))

                 ;; vimish-fold
                 ((vimish-fold-overlay &override) :inherit 'font-lock-comment-face :background bg-alt2 :weight 'light)
                 ((vimish-fold-mouse-face &override) :foreground base0 :background yellow :weight 'light) ; [dir]
                 ((vimish-fold-fringe &override) :foreground magenta :background magenta)
   ;;;; company
                 (company-preview-common :foreground cyan)
                 (company-tooltip-common :foreground cyan)
                 (company-tooltip-common-selection :foreground cyan)
                 (company-tooltip-annotation :foreground cyan)
                 (company-tooltip-annotation-selection :foreground cyan)
                 (company-scrollbar-bg :background bg-alt)
                 (company-scrollbar-fg :background cyan)
                 (company-tooltip-selection :background bg-alt2)
                 (company-tooltip-mouse :background bg-alt2 :foreground nil)
   ;;;; css-mode <built-in> / scss-mode
                 (css-proprietary-property :foreground keywords)
   ;;;; dired
                 (dired-directory :foreground cyan)
                 (dired-marked :foreground yellow)
                 (dired-symlink :foreground cyan)
                 (dired-header :foreground cyan)
   ;;;; doom-emacs
                 (+workspace-tab-selected-face :background dark-green :foreground base0) ; [dir]
   ;;;; doom-modeline
                 (doom-modeline-bar :background dark-green)
                 (doom-modeline-buffer-file :inherit 'bold :foreground fg)
                 (doom-modeline-buffer-major-mode :foreground green :bold t)
                 (doom-modeline-buffer-modified :inherit 'bold :foreground yellow)
                 (doom-modeline-buffer-path :inherit 'bold :foreground green)
                 (doom-modeline-error :background bg)
                 (doom-modeline-info :bold t :foreground cyan)
                 (doom-modeline-panel :background dark-green :foreground base0) ; [dir] fg was invisible
                 (doom-modeline-project-dir :bold t :foreground cyan)
                 (doom-modeline-warning :foreground red :bold t)
   ;;;; doom-themes
                 (doom-themes-neotree-file-face :foreground fg)
                 (doom-themes-neotree-hidden-file-face :foreground (doom-darken fg-alt 0.25)) ; [dir]
                 (doom-themes-neotree-media-file-face :foreground (doom-darken fg-alt 0.25))  ; [dir]
   ;;;; ediff <built-in>
                 (ediff-fine-diff-A    :background (doom-blend red bg 0.4) :weight 'bold)
                 (ediff-current-diff-A :background (doom-blend red bg 0.2))
   ;;;; evil
                 ;; yellow is a dark accent here, so it cannot be a raw background
                 ;; under dark text -- blend it into bg instead. fg on it: 7.16:1
                 (evil-search-highlight-persist-highlight-face :background (doom-blend yellow bg 0.25)) ; [dir]
                 (evil-ex-substitute-replacement :foreground cyan :inherit 'evil-ex-substitute-matches)
   ;;;; evil-snipe
                 (evil-snipe-first-match-face :foreground base0 :background yellow) ; [dir]
                 (evil-snipe-matches-face     :foreground yellow :bold t :underline t)
   ;;;; flycheck
                 (flycheck-error   :underline `(:style wave :color ,red)    :background base3)
                 (flycheck-warning :underline `(:style wave :color ,yellow) :background base3)
                 (flycheck-info    :underline `(:style wave :color ,cyan)  :background base3)
   ;;;; helm
                 (helm-swoop-target-line-face :foreground magenta :inverse-video t)
   ;;;; highlight-quoted
                 (highlight-quoted-symbol :foreground dark-cyan)
   ;;;; highlight-symbol
                 (highlight-symbol-face :background (doom-darken base3 0.03) :distant-foreground fg-alt) ; [dir]
   ;;;; highlight-thing
                 (highlight-thing :background (doom-darken base3 0.03) :distant-foreground fg-alt)       ; [dir]
   ;;;; ivy
                 (ivy-current-match :background bg-alt2)
                 (ivy-subdir :background nil :foreground cyan)
                 (ivy-action :background nil :foreground cyan)
                 (ivy-grep-line-number :background nil :foreground cyan)
                 (ivy-minibuffer-match-face-1 :background nil :foreground yellow :bold t)
                 (ivy-minibuffer-match-face-2 :background nil :foreground red :bold t)
                 (ivy-minibuffer-match-highlight :foreground cyan)
                 (counsel-key-binding :foreground cyan)
   ;;;; ivy-posframe
                 (ivy-posframe :background bg-alt)
                 ;; base1 is only 1.22:1 on cream -- not a border. base4 is 2.72:1.
                 (ivy-posframe-border :background base4) ; [dir] was base1
   ;;;; LaTeX-mode
                 (font-latex-math-face :foreground dark-cyan)
   ;;;; magit
                 (magit-section-heading             :foreground yellow :weight 'bold)
                 (magit-branch-current              :underline cyan :inherit 'magit-branch-local)
                 (magit-diff-hunk-heading           :background base3 :foreground fg-alt)
                 (magit-diff-hunk-heading-highlight :background bg-alt2 :foreground fg)
                 ;; upstream had :foreground twice (bg-alt then fg-alt), so the first
                 ;; was dead and the hunk never got its background. Fixed here.
                 (magit-diff-context                :background bg-alt :foreground fg-alt)
   ;;;; markdown-mode
                 (markdown-blockquote-face :inherit 'italic :foreground cyan)
                 (markdown-list-face :foreground red)
                 (markdown-url-face :foreground red)
                 (markdown-pre-face  :foreground cyan)
                 (markdown-link-face :inherit 'bold :foreground cyan)
                 ((markdown-code-face &override) :background (doom-darken base2 0.045)) ; [dir]
   ;;;; mu4e-view
                 (mu4e-header-key-face :foreground red)
   ;;;; neotree
                 (neo-root-dir-face   :foreground cyan)
                 (doom-neotree-dir-face :foreground cyan)
                 (neo-dir-link-face   :foreground cyan)
                 (neo-expand-btn-face :foreground magenta)
   ;;;; outline <built-in>
                 ((outline-1 &override) :foreground yellow)
                 ((outline-2 &override) :foreground cyan)
                 ((outline-3 &override) :foreground cyan)
   ;;;; org <built-in>
                 (org-ellipsis :underline nil :foreground orange)
                 (org-tag :foreground yellow :bold nil)
                 ((org-quote &override) :inherit 'italic :foreground base7 :background org-quote)
                 (org-todo :foreground yellow :bold 'inherit)
                 (org-list-dt :foreground yellow)
   ;;;; show-paren
                 ;; base5 is a *foreground* weight here; using it as a background
                 ;; under :foreground nil would hide the paren entirely.
                 ((show-paren-match &override) :foreground nil :background bg-alt2 :bold t) ; [dir] was base5
                 ((show-paren-mismatch &override) :foreground base0 :background red)        ; [dir]
   ;;;; which-func
                 (which-func :foreground cyan)
   ;;;; which-key
                 (which-key-command-description-face :foreground fg)
                 (which-key-group-description-face :foreground (doom-darken fg-alt 0.25)) ; [dir]
                 (which-key-local-map-description-face :foreground cyan)
   ;;;; undo-tree
                 (undo-tree-visualizer-active-branch-face :foreground cyan)
                 (undo-tree-visualizer-current-face :foreground yellow)
   ;;;; rainbow-delimiters
                 (rainbow-delimiters-depth-1-face :foreground red)
                 (rainbow-delimiters-depth-2-face :foreground yellow)
                 (rainbow-delimiters-depth-3-face :foreground cyan)
                 (rainbow-delimiters-depth-4-face :foreground red)
                 (rainbow-delimiters-depth-5-face :foreground yellow)
                 (rainbow-delimiters-depth-6-face :foreground cyan)
                 (rainbow-delimiters-depth-7-face :foreground red)
   ;;;; rjsx-mode
                 (rjsx-tag :foreground cyan :weight 'semi-bold)
                 (rjsx-text :foreground fg)
                 (rjsx-attr :foreground violet)
   ;;;; solaire-mode
                 (solaire-hl-line-face :background bg-alt2)
   ;;;; swiper
                 (swiper-line-face :background bg-alt2)
   ;;;; web-mode
                 (web-mode-html-tag-bracket-face :foreground blue)
                 (web-mode-html-tag-face         :foreground cyan :weight 'semi-bold)
                 (web-mode-html-attr-name-face   :foreground violet)
                 (web-mode-json-key-face         :foreground green)
                 (web-mode-json-context-face     :foreground cyan))

                ;; --- extra variables --------------------
                ;; ()
                )

;;; strake-plaskett-light-theme.el ends here
