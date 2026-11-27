(setq inhibit-x-resources t)
(setq inhibit-splash-screen t)
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(setq bidi-inhibit-bpa t)
(setq confirm-kill-emacs 'y-or-n-p)
(setq confirm-kill-processes nil)
(setq select-active-regions nil)
(setq blink-cursor-mode nil)
(setq scroll-conservatively 101)
(setq scroll-preserve-screen-position t)

(set-language-environment "utf-8")
(set-default-coding-systems 'utf-8-unix)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(set-face-attribute 'default nil
		    :family "DejaVu Sans Mono"
		    :height 140)

(use-package winner
  :hook
  (after-init-hook . winner-mode)
  :bind
  (("M-[" . winner-undo)
   ("M-]" . winner-redo)
   :repeat-map winner-repeat-map
   ("[" . winner-undo)
   ("]" . winnder-redo)))

(use-package repeat
  :hook
  (after-init-hook . repeat-mode))

(use-package window
  :bind
  (("C-c ]" . next-buffer)
   ("C-c [" . previous-buffer)
   :repeat-map buffer-repeat-map
   ("]" . next-buffer)
   ("[" . previous-buffer)
   :repeat-map other-window-repeat-map
   ("o" . other-window)))

(use-package ispell
  :config
  (setq ispell-program-name "hunspell")
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "en_US,ru_RU")
  (ispell-change-dictionary "en_US,ru_RU" t))

;; UI
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(setq mode-line-format (delq 'mode-line-modes mode-line-format))
(setq-default mode-line-format (delete '(vc-mode vc-mode) mode-line-format))

;; Parentheses
(electric-pair-mode t)
(show-paren-mode t)
(setq show-paren-context-when-offscreen t)

;; Theme
(load-theme 'modus-vivendi-deuteranopia)

(use-package envrc
  :ensure t
  :hook (after-init . envrc-global-mode))

(use-package eglot
  :hook (c-mode . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
               '(c-mode . ("clangd"))))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package savehist
  :init
  (savehist-mode))

(use-package orderless
  :ensure t
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this))

(use-package magit
  :ensure t)

(use-package git-commit
  :after magit
  :hook (git-commit-setup . flyspell-mode))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :ensure t
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

(use-package corfu
  :ensure t
  ;; Optional customizations
  :custom
  ;; :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match 'insert) ;; Configure handling of exact matches

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  :hook ((prog-mode . corfu-mode))
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  :init
  (corfu-popupinfo-mode)
  ;; Recommended: Enable Corfu globally.  Recommended since many modes provide
  ;; Capfs and Dabbrev can be used globally (M-/).  See also the customization
  ;; variable `global-corfu-modes' to exclude certain modes.
  ;; Enable optional extension modes:
  ;; (corfu-history-mode)
  ;; (corfu-mouse-mode)

  )

(which-key-mode t)

(use-package nix-ts-mode
  :ensure t
  :mode "\\.nix\\'"
  :hook
  (nix-ts-mode . eglot-ensure))

(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'")

(use-package apheleia
  :ensure t
  :hook
  (prog-mode . apheleia-mode))

(defun apostolic/reference ()
  (interactive)
  (find-file "~/Documents/Vault/agenda/reference.org"))

(defvar org-electric-pairs '((?$ . ?$)))

(defun org-add-electric-pairs ()
  (setq-local electric-pair-pairs (append electric-pair-pairs org-electric-pairs))
  (setq-local electric-pair-text-pairs electric-pair-pairs))

;; Org-mode
(use-package org
  :mode ("\\.org\\'" . org-mode)
  :hook ((org-mode . visual-line-mode)
         (org-mode . flyspell-mode)
         (org-mode . turn-on-org-cdlatex)
	 (org-mode . wrap-region-mode)
	 (org-mode . org-add-electric-pairs))
  :bind (([f12] . org-agenda)
	 ([S-f12] . apostolic/reference)
	 ([f10] . org-clock-goto)
	 ([C-f10] . org-clock-in)
	 ("C-c c" . org-capture))
  :custom
  ;; Babel
  (org-confirm-babel-evaluate nil)
  (org-babel-python-command "python3")

  ;; Org
  (org-directory "~/Documents/Vault")
  (org-log-done 'time)
  (org-log-into-drawer t)

  ;; Agenda
  (org-modules '(org-habit))
  (org-habit-graph-column 60)
  (org-agenda-files '("~/Documents/Vault/agenda"))
  (org-default-notes-file "~/Documents/Vault/agenda/refile.org")

  (org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
     (sequence "WAITING(w)" "HOLD(h)" "|" "CANCELED(c)")))

  (org-todo-state-tags-triggers
   '(("CANCELED" ("CANCELED" . t))
     ("WAITING" ("WAITING" . t))
     ("HOLD" ("WAITING") ("HOLD" . t))
     (done ("WAITING") ("HOLD"))
     ("TODO" ("WAITING") ("CANCELED") ("HOLD"))
     ("NEXT" ("WAITING") ("CANCELED") ("HOLD"))
     ("DONE" ("WAITING") ("CANCELED") ("HOLD"))))

  (org-todo-keyword-faces
   '(("TODO" . (:background "DodgerBlue" :weight bold :foreground "black"))
     ("NEXT" . (:background "BlueViolet" :weight bold :foreground "black"))
     ("DONE" . (:background "LimeGreen" :weight bold :foreground "black"))
     ("WAITING" . (:background "DarkOrange" :weight bold :foreground "black"))
     ("HOLD" . (:background "SlateGray" :weight bold :foreground "black"))
     ("CANCELED" . (:background "DarkRed" :weight bold :foreground "black"))))

  (org-agenda-custom-commands
   '(("u" "Super View"
      ((agenda "" ((org-super-agenda-groups
		    '((:name "Today"
			     :time-grid t
			     :date today
			     :scheduled today
			     :order 1)
		      (:discard (:habit t))))))
       (alltodo "" ((org-agenda-overriding-header "")
		    (org-super-agenda-groups
		     '((:discard (:habit t))
		       (:name "Important"
			      :priority "A"
			      :order 0)
		       (:name "Next to do"
			      :todo "NEXT"
			      :order 0)
		       (:name "Refile"
			      :tag "REFILE"
			      :order 2)
		       (:name "Low Priority"
			      :priority "C"
			      :order 100)
		       (:auto-category t)))))))))

  (org-enforce-todo-dependencies t)
  (org-agenda-start-on-weekday nil)
  (org-agenda-span 'day)
  (org-deadline-warning-days 7)
  (org-agenda-skip-deadline-if-done t)
  (org-agenda-skip-scheduled-if-done t)
  (org-agenda-dim-blocked-tasks t)
  (org-agenda-compact-blocks t)
  (org-agenda-include-diary t)
  (org-agenda-log-mode 'clockcheck)
  (org-agenda-log-mode-items '(clock closed))

  ;; Refile
  (org-refile-target-verify-function 'bh/verify-refile-target)
  (org-refile-targets '((nil :maxlevel . 9)
			(org-agenda-files :maxlevel . 9)))
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil)
  (org-refile-allow-creating-parent-nodes 'confirm)

  ;; Archive
  (org-archive-mark-done nil)
  (org-archive-location "~/Documents/Vault/agenda/archive/%s_archive::* Archived Tasks")

  ;; Appearance
  (org-startup-indented t)
  (org-startup-folded 'content)
  (org-startup-with-inline-images t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities nil)
  (org-ellipsis " ┅ ")
  (org-src-fontify-natively t)
  (org-fontify-quote-and-verse-blocks t)
  (org-fontify-whole-heading-line t)
  (org-fontify-todo-headline t)
  (org-fontify-done-headline t)

  ;; LaTeX
  (org-use-sub-superscripts '{})
  (org-startup-with-latex-preview t)
  (org-latex-compiler "pdflatex")
  (org-preview-latex-default-process 'dvisvgm)
  (org-highlight-latex-and-related '(latex script entities))
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((C . t)
     (emacs-lisp . t)
     (shell . t)
     (org . t)
     (python . t)))

  (setq org-capture-templates
	'(("t" "Todo" entry (file "~/Documents/Vault/agenda/refile.org")
	   "* TODO %?\n%u\n")
	  ("n" "Note" entry (file "~/Documents/Vault/agenda/refile.org")
	   "* %? :note:\n%u\n")))

  ;; Vertico
  (advice-add #'org-make-tags-matcher :around #'vertico-enforce-basic-completion)
  (advice-add #'org-agenda-filter :around #'vertico-enforce-basic-completion)

  ;; Custom
  (defun bh/verify-refile-target ()
    "Exclude todo keywords with a done state from refile targets"
    (not (member (nth 2 (org-heading-components)) org-done-keywords))))

(use-package org-roam
  :ensure t
  :after org
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n a" . org-roam-alias-add)
         ("C-c n d" . org-id-get-create))
  :custom
  (org-roam-directory (file-truename "~/Documents/Vault/WIKI/notes"))
  (org-roam-database-connector 'sqlite-builtin)
  (org-roam-node-display-template (concat "${title:*} " (propertize "${tags:25}" 'face 'org-tag)))
  :config
  (org-roam-db-autosync-mode))

(use-package org-super-agenda
  :ensure t
  :init
  (org-super-agenda-mode))

(use-package org-appear
  :ensure t
  :after org
  :hook (org-mode . org-appear-mode))

(use-package auctex
  :defer t
  :ensure t)

(use-package cdlatex
  :ensure t
  :after (auctex)
  :hook (LaTeX-mode . cdlatex-mode))

(use-package wrap-region
  :ensure t
  :config
  (wrap-region-add-wrapper "$" "$" nil 'org-mode)
  (wrap-region-add-wrapper "*" "*" nil 'org-mode) 
  (wrap-region-add-wrapper "/" "/" nil 'org-mode) 
  (wrap-region-add-wrapper "_" "_" nil 'org-mode) 
  (wrap-region-add-wrapper "=" "=" nil 'org-mode) 
  (wrap-region-add-wrapper "~" "~" nil 'org-mode) 
  (wrap-region-add-wrapper "+" "+" nil 'org-mode))
