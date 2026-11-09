;;; Read-only inventory. Does not insert, edit, or erase drawing entities.
(vl-load-com)
(defun hlha:value (v / r)
  (cond
    ((= (type v) 'VARIANT) (hlha:value (vlax-variant-value v)))
    ((= (type v) 'SAFEARRAY)
      (setq r (vl-catch-all-apply 'vlax-safearray->list (list v)))
      (if (vl-catch-all-error-p r) nil (mapcar 'hlha:value r)))
    (T v)))
(defun hlha:get (o p / r)
  (setq r (vl-catch-all-apply 'vlax-get-property (list o p)))
  (if (vl-catch-all-error-p r) nil (hlha:value r)))
(defun hlha:props (o / r p out)
  (if (= (hlha:get o 'IsDynamicBlock) :vlax-true)
    (progn
      (setq r (vl-catch-all-apply 'vla-GetDynamicBlockProperties (list o)))
      (if (not (vl-catch-all-error-p r))
        (foreach p (hlha:value r)
          (setq out (cons (list
            (cons 'name (hlha:get p 'PropertyName))
            (cons 'value (hlha:get p 'Value))
            (cons 'allowed (hlha:get p 'AllowedValues))
            (cons 'readonly (hlha:get p 'ReadOnly))) out))))))
  (reverse out))
(defun hlha:box (o / lo hi r)
  (setq r (vl-catch-all-apply 'vla-GetBoundingBox (list o 'lo 'hi)))
  (if (vl-catch-all-error-p r) nil (list (hlha:value lo) (hlha:value hi))))
(defun c:HLHIDDEN_AUDIT (/ *error* f path doc blocks b o props n name row)
  (defun *error* (m)
    (if f (close f))
    (if m (princ (strcat "\nAudit stopped: " m))) (princ))
  (setq path (getfiled "Save read-only Hidden Line inventory" (strcat (getvar "DWGPREFIX") "HiddenLine_Audit.txt") "txt" 1))
  (if path
    (progn
      (setq f (open path "w"))
      (if f
        (progn
          (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)) blocks (vla-get-Blocks doc) n 0)
          (prin1 (list 'drawing (getvar "DWGNAME") 'acadver (getvar "ACADVER") 'insunits (getvar "INSUNITS")) f) (write-line "" f)
          (vlax-for b blocks
            (if (= (vla-get-IsXRef b) :vlax-false)
              (vlax-for o b
                (if (= (vla-get-ObjectName o) "AcDbBlockReference")
                  (progn
                    (setq name (hlha:get o 'EffectiveName))
                    (if (null name) (setq name (hlha:get o 'Name)))
                    (setq row (list
                      (cons 'owner (vla-get-Name b))
                      (cons 'name name) (cons 'handle (vla-get-Handle o))
                      (cons 'position (hlha:get o 'InsertionPoint))
                      (cons 'rotation (hlha:get o 'Rotation))
                      (cons 'scale (list (hlha:get o 'XScaleFactor) (hlha:get o 'YScaleFactor) (hlha:get o 'ZScaleFactor)))
                      (cons 'bounds (hlha:box o)) (cons 'dynamic (hlha:props o))))
                    (prin1 row f) (write-line "" f) (setq n (1+ n)))))))
          (close f) (setq f nil)
          (princ (strcat "\nRead-only audit complete: " (itoa n) " references. File: " path)))
        (princ "\nCannot write report file."))))
  (princ))
(princ "\nLoaded HLHIDDEN_AUDIT. Run in Hidden Line Pipe.dwg. Read-only.")
(princ)
