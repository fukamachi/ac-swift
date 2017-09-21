# ac-swift.el -- An auto-complete source for Swift using SourceKitten

## Usage

```emacs-lisp
(require 'ac-swift)
(add-hook 'swift-mode-hook 'ac-swift-setup)
(eval-after-load "auto-complete"
  '(add-to-list 'ac-modes 'swift-mode))
```

## See Also

* [SourceKitten](https://github.com/jpsim/SourceKitten)
* [auto-complete.el](https://github.com/auto-complete/auto-complete)
