(require 'package)

(setq package-enable-at-startup nil)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(setq use-package-verbose nil
      use-package-always-ensure t)

(use-package diminish)

;; Custom Functions
(defun smart-open-line-above ()
  "Insert an empty line above the current line.
Position the cursor at it's beginning, according to the current mode."
  (interactive)
  (move-beginning-of-line nil)
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))
(global-set-key (kbd "C-o") 'smart-open-line-above)

(defun smart-beginning-of-line ()
    "Move point to beginning-of-line or first non-whitespace character"
  (interactive "^")
  (let ((p (point)))
    (beginning-of-visual-line)
    (back-to-indentation)
    (if (= p (point)) (back-to-indentation))
    (if (= p (point)) (beginning-of-line))))
(global-set-key "\C-a" 'smart-beginning-of-line)

(defun comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command.
If no region is selected and current line is not blank and
we are not at the end of the line, then comment current line.
Replaces default behaviour of comment-dwim,
when it inserts comment at the end of the line. "
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))

(global-set-key "\M-;" 'comment-dwim-line)

;; Smart copy, if no region active, it simply copy the current whole line
(defadvice kill-line (before check-position activate)
  (if (member major-mode
          '(emacs-lisp-mode scheme-mode lisp-mode
                c-mode c++-mode objc-mode js-mode
                latex-mode plain-tex-mode))
      (if (and (eolp) (not (bolp)))
      (progn (forward-char 1)
         (just-one-space 0)
         (backward-char 1)))))

(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive (if mark-active (list (region-beginning) (region-end))
         (message "Copied line")
         (list (line-beginning-position)
               (line-beginning-position 2)))))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
	   (line-beginning-position 2)))))


;; Copy line from point to the end, exclude the line break
(defun copy-line (arg)
  "Copy lines (as many as prefix argument) in the kill ring"
  (interactive "p")
  (kill-ring-save (point)
          (line-end-position))
  ;; (line-beginning-position (+ 1 arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s")))

(global-set-key (kbd "M-k") 'copy-line)

;; Do not need it
(global-set-key (kbd "C-z") nil)
(global-set-key (kbd "C-x C-z") nil)

;; (use-package auto-compile
;;   :ensure t
;;   :config (auto-compile-on-load-mode))
;; (setq load-prefer-newer t)

;; Personal information
(setq user-full-name "Lin HY"
      user-mail-address "limon7@gmail.com")

;(set-face-attribute 'default nil :font "Operator Mono SSm Lig Light 10")
					;(set-face-attribute 'default nil :font "Jetbrains Mono 10")

(set-face-attribute 'default nil :font "SFMono Nerd Font 10")
;(set-face-attribute 'default nil :font "CaskaydiaCove Nerd Font Mono 10")

(use-package flucui-themes
  :config
  (flucui-themes-load-style 'light))

;(setq solarized-use-more-italic t)
;(setq solarized-distinct-fringe-background t)
;(setq solarized-high-contrast-mode-line t)
;(setq solarized-emphasize-indicators t)
(setq x-underline-at-descent-line t)
					;(load-theme 'solarized-dark t)
(use-package dracula-theme
  :config
  (load-theme 'dracula t))

;; Apperance
(tooltip-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(column-number-mode 1)

(fset 'yes-or-no-p 'y-or-n-p)
(setq confirm-kill-emacs 'y-or-n-p)

;; (defun simple-mode-line-render (left right)
;;   "Return a string of `window-width' length.
;; Containing LEFT, and RIGHT aligned respectively."
;;   (let ((available-width
;;          (- (window-total-width)
;; 	    120
;;             (+ (length (format-mode-line left))
;;                (length (format-mode-line right))))))
;;     (append left
;; 	    (list '(:eval (list (nyan-create))))
;;             (list (format (format "%%%ds" available-width) ""))
;;             right)))

;; (setq-default
;;  mode-line-format
;;  '((:eval
;;     (simple-mode-line-render
;;      ;; Left.
;;      (quote ("%e "
;;              mode-line-buffer-identification
;;              " %l : %c"
;;              evil-mode-line-tag
;;              "[%*]"))
;;      ;; Right.
;;      (quote ("%p "
;;              mode-line-frame-identification
;;              mode-line-modes
;;              mode-line-misc-info))))))

;; (set-face-attribute 'mode-line nil :height 90)
;; (set-face-attribute 'mode-line-inactive nil :height 90)

;; (use-package nyan-mode
;;   :custom
;;   (nyan-animate-nyancat t)
;;   (nyan-bar-length 60)
;;   :config
;;   (nyan-mode t))

(delete-selection-mode t)
(use-package expand-region
  :bind
  (("C-," . 'er/expand-region)))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  (set-face-attribute 'mode-line nil :height 80)
  (set-face-attribute 'mode-line-inactive nil :height 80)
  (setq doom-modeline-height 20))

(set-face-foreground 'mode-line-buffer-id "#ff79c6")

(use-package smartparens
  :init
  (setq sp-highlight-pair-overlay nil
    sp-highlight-wrap-overlay nil
    sp-highlight-wrap-tag-overlay nil)
  :config
  (require 'smartparens-config)
  :hook
  (prog-mode . smartparens-mode))

(use-package window-numbering
  :config
  (window-numbering-mode 1))

(bind-key "C-x p" 'pop-to-mark-command)
(setq set-mark-command-repeat-pop t)

(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

(use-package helm
  :diminish helm-mode
  :init
  (progn
    (require 'helm-config)
    (setq helm-candidate-number-limit 100)
    ;; From https://gist.github.com/antifuchs/9238468
    (setq helm-idle-delay 0.0 ; update fast sources immediately (doesn't).
          helm-input-idle-delay 0.01  ; this actually updates things
                                        ; reeeelatively quickly.
          helm-yas-display-key-on-candidate t
          helm-quick-update t
          helm-M-x-requires-pattern nil
          helm-ff-skip-boring-files t

          helm-M-x-fuzzy-match t)
    (when (executable-find "ack")
      (setq helm-grep-default-command "ack -Hn --no-group --no-color %e %p %f"
            helm-grep-default-recurse-command "ack -H --no-group --no-color %e %p %f"))
    (helm-mode))
  :bind (("C-x b" . helm-buffers-list)
         ("C-x C-b" . helm-mini)
         ("C-x C-f" . helm-find-files)
         ("C-h a" . helm-apropos)
         ("M-y" . helm-show-kill-ring)
         ("M-x" . helm-M-x)
         ("C-x c o" . helm-occur)
         ("C-x c y" . helm-yas-complete)
         ("C-x c SPC" . helm-all-mark-rings)))
(ido-mode -1) ;; Turn off ido mode in case I enabled it accidentally

(use-package helm-swoop
  :bind
  (("M-i" . helm-swoop)
   ("M-I" . helm-swoop-back-to-last-point)
   ("C-x M-i" . helm-multi-swoop))
  :config
  (progn
    (define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)
    (define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop))
  )

(use-package company
  :diminish
  :init (add-hook 'after-init-hook 'global-company-mode)
  :config
  (set-face-background 'company-preview-common "black")
  (setq company-idle-delay              0.1
        company-minimum-prefix-length   2
        company-show-numbers            t
        company-tooltip-limit           20
        company-selection-wrap-around   t
        company-dabbrev-downcase        nil)
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous)
  :bind ("C-;" . company-complete-common))

(use-package yasnippet
  :diminish yas-minor-mode
  :config
  (yas-global-mode 1))

(use-package flycheck
  :config
  (global-flycheck-mode))

(use-package magit
  :defer t
  :bind
  ("C-x g" . magit-status))

(use-package lsp-mode
  :init
  (setq lsp-rust-server 'rust-analyzer)
  :bind (:map lsp-mode-map
              ("C-." . lsp-execute-code-action))
  :commands lsp)

(use-package lsp-ui)

(use-package company-lsp :commands company-lsp)

(use-package rust-mode
  :init
  (setq rust-format-on-save t
        rust-format-show-buffer nil
        rust-format-goto-problem nil)
  :hook
  (rust-mode . lsp))

(with-eval-after-load 'rust-mode
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package lisp-mode
  :ensure nil
  :defer t
  :init
  (add-hook 'lisp-mode-hook 'rainbow-delimiters-mode))

(use-package emacs-lisp-mode
  :defer t
  :ensure nil
  :hook
  (emacs-lisp-mode . rainbow-delimiters-mode))

(use-package paredit
  :diminish paredit-mode
  :hook
  ((lisp-mode emacs-lisp-mode lisp-interaction-mode) . paredit-mode))

(use-package smartparens
  :defer t
  :init
  (setq sp-highlight-pair-overlay nil
        sp-highlight-wrap-overlay nil
        sp-highlight-wrap-tag-overlay nil))
(show-smartparens-global-mode +1)
(put 'narrow-to-region 'disabled nil)

(use-package avy
  :bind (("C-'" . avy-goto-char)
         ("M-g M-g" . avy-goto-line))
  :config
  (setq avy-background t))

(use-package lua-mode
  :defer t
  :config
  (setq lua-indent-level 2))

(use-package go-mode
  :defer t)

(use-package haskell-mode)

(use-package dante
  :after haskell-mode
  :commands 'dante-mode
  :init
  (add-hook 'haskell-mode-hook 'flycheck-mode)
  (add-hook 'haskell-mode-hook 'dante-mode))

(use-package vterm
  :defer t)

(use-package rbenv
  :init
  (global-rbenv-mode))

(use-package enh-ruby-mode
  :mode
  (("Capfile" . enh-ruby-mode)
   ("Gemfile\\'" . enh-ruby-mode)
   ("Rakefile" . enh-ruby-mode)
   ("\\.rb" . enh-ruby-mode)
   ("\\.ru" . enh-ruby-mode)))

(add-hook 'enh-ruby-mode-hook #'lsp)

(use-package rubocopfmt
  :hook
  (enh-ruby-mode . rubocopfmt-mode)
  :init
  (setq rubocopfmt-on-save-use-lsp-format-buffer t))

(use-package projectile
  :init
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(use-package projectile-rails
  :init
  (projectile-rails-global-mode)
  (define-key projectile-rails-mode-map (kbd "C-c r") 'projectile-rails-command-map))

(use-package helm-projectile
  :init
  :bind (("s-;" . helm-projectile)))

(use-package web-mode
  :init
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  :hook
  (web-mode . turn-off-smartparens-mode)
  :custom
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("1d78d6d05d98ad5b95205670fe6022d15dabf8d131fe087752cc55df03d88595" default))
 '(inhibit-startup-screen t)
 '(package-selected-packages
   '(helm-fd projectile-mode rubocopfmt inf-ruby enh-ruby-mode rbenv cargo flycheck-rust avy dante haskell-mode general sudo-edit lua-mode srcery-theme dracula-theme gruvbox-theme solarized-theme github-theme flucui-themes emacs-lisp nyan-mode emacs-lisp-mode yasnippet window-numbering web-mode vterm use-package undo-tree smartparens rust-mode rainbow-delimiters pyvenv py-autopep8 projectile-rails paredit magit lsp-ui lsp-python-ms js2-mode helm-swoop helm-projectile helm-lsp go-mode flycheck expand-region exec-path-from-shell elscreen doom-themes doom-modeline diminish dap-mode company-lsp)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
