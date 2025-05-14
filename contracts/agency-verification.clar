;; Agency Verification Contract
;; Validates government entities that can participate in the identity system

(define-data-var admin principal tx-sender)

;; Map of verified agencies
(define-map verified-agencies
  principal
  {
    name: (string-ascii 100),
    agency-type: (string-ascii 50),
    verification-date: uint,
    status: (string-ascii 10)
  }
)

;; Add a new government agency
(define-public (register-agency (agency-principal principal) (name (string-ascii 100)) (agency-type (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (not (is-some (map-get? verified-agencies agency-principal))) (err u401))
    (ok (map-set verified-agencies
                agency-principal
                {
                  name: name,
                  agency-type: agency-type,
                  verification-date: block-height,
                  status: "active"
                }))
  )
)

;; Revoke an agency's verification
(define-public (revoke-agency (agency-principal principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? verified-agencies agency-principal)) (err u404))
    (let ((agency (unwrap-panic (map-get? verified-agencies agency-principal))))
      (ok (map-set verified-agencies
                  agency-principal
                  (merge agency { status: "revoked" })))
    )
  )
)

;; Check if an agency is verified
(define-read-only (is-verified-agency (agency-principal principal))
  (match (map-get? verified-agencies agency-principal)
    agency (is-eq (get status agency) "active")
    false
  )
)

;; Get agency details
(define-read-only (get-agency-details (agency-principal principal))
  (map-get? verified-agencies agency-principal)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
