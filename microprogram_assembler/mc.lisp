;; veldig rask skisse til del av mikrokoden, med haugevis av mer eller
;; mindre dumme antagelser om hva som er tilgjengelig i språket

;; registers: pc, car/cdr, data/data-ext, state, stack-top, stack-op-start, op

(defconst state-value 0)
(defconst state-arglist 0)
(defconst state-apply 0)

(defconst op-none 0)
(defconst op-+ 1)

(defconst evaluation-start-address 0)

(init)
(main)

(defmcop init
  (mov stack-top stack-op-start)
  (imm-mov evaluation-start-address pc)
  (mov pc car)
  (imm-mov op-none op)
  (imm-mov value state))

(defmcop main
  (imm-eq? state-value state)
  (callt eval-value)
  (imm-eq? state-arglist state)
  (callt eval-arglist)
  (imm-eq? state-apply state)
  (callt apply-primitive)
  (jmp main))

(defmcop eval-value
  (load-double car data)
  (is-pair? data)
  (callf eval-atom)
  (callt eval-pair))

(defmcop eval-atom
  (push data) ;; assume all atoms are self-evaluating
  (imm-mov state-arglist state))

(defmcop eval-pair
  (push pc)
  (push op)
  (mov stack-top stack-op-start)
  (mov-double data car)
  (load car data)
  (mov data op)
  (imm-mov state-arglist state))


(defmcop eval-arglist
  (is-nil? cdr)
  (imm-jmpt at-end-of-list)
  (mov cdr pc)
  (load-double pc car)
  (imm-mov state-value state)
  (return)
  (label at-end-of-list)
  (imm-mov state-apply state))


(defmcop apply-primitive
  (imm-eq? op-+ op)
  (callt primitive-+)
  (jmpt apply-primitive-end)
  ;; more ops

  (label apply-primitive-end)
  (pop op)
  (pop pc)
  (push data)
  (imm-eq? op-none op)
  (callt happy-happy-joy-joy)
  (imm-mov state-arglist state)
  (load-double pc car))


(defmcop primitive-+
  (pop data)
  (label primitive-+-loop)
  (> stack-top stack-op-start)
  ;; todo
  )

(defmcop happy-happy-joy-joy
  (halt))
