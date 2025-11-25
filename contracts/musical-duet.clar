;; Musical Duet NFTs
;; Two NFTs that only play complete music when paired together

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-not-found (err u102))
(define-constant err-already-paired (err u103))
(define-constant err-invalid-pair (err u104))
(define-constant err-not-paired (err u105))

;; Data Variables
(define-data-var last-token-id uint u0)

;; Data Maps
;; Store NFT ownership
(define-map nft-owners uint principal)

;; Store NFT type: "melody" or "harmony"
(define-map nft-types uint (string-ascii 10))

;; Store pairing information: which token is paired with which
(define-map nft-pairs uint uint)

;; Store musical note/sound for each NFT (incomplete on its own)
(define-map nft-sounds uint (string-ascii 50))

;; Private Functions

;; Check if an address owns a specific token
(define-private (is-owner (token-id uint) (user principal))
    (is-eq (some user) (map-get? nft-owners token-id))
)

;; Public Functions

;; Mint a new melody NFT
(define-public (mint-melody (sound (string-ascii 50)))
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
        )
        (map-set nft-owners token-id tx-sender)
        (map-set nft-types token-id "melody")
        (map-set nft-sounds token-id sound)
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

;; Mint a new harmony NFT
(define-public (mint-harmony (sound (string-ascii 50)))
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
        )
        (map-set nft-owners token-id tx-sender)
        (map-set nft-types token-id "harmony")
        (map-set nft-sounds token-id sound)
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

;; Pair two NFTs together (must own both)
(define-public (pair-nfts (melody-id uint) (harmony-id uint))
    (let
        (
            (melody-type (map-get? nft-types melody-id))
            (harmony-type (map-get? nft-types harmony-id))
            (melody-pair (map-get? nft-pairs melody-id))
            (harmony-pair (map-get? nft-pairs harmony-id))
        )
        ;; Check ownership
        (asserts! (is-owner melody-id tx-sender) err-not-token-owner)
        (asserts! (is-owner harmony-id tx-sender) err-not-token-owner)

        ;; Check tokens exist
        (asserts! (is-some melody-type) err-token-not-found)
        (asserts! (is-some harmony-type) err-token-not-found)

        ;; Check correct types
        (asserts! (is-eq melody-type (some "melody")) err-invalid-pair)
        (asserts! (is-eq harmony-type (some "harmony")) err-invalid-pair)

        ;; Check not already paired
        (asserts! (is-none melody-pair) err-already-paired)
        (asserts! (is-none harmony-pair) err-already-paired)

        ;; Create the pairing
        (map-set nft-pairs melody-id harmony-id)
        (map-set nft-pairs harmony-id melody-id)
        (ok true)
    )
)

;; Unpair NFTs (must own both)
(define-public (unpair-nfts (token-id uint))
    (let
        (
            (partner-id (map-get? nft-pairs token-id))
        )
        ;; Check ownership
        (asserts! (is-owner token-id tx-sender) err-not-token-owner)

        ;; Check if paired
        (asserts! (is-some partner-id) err-not-paired)

        ;; Check ownership of partner
        (asserts! (is-owner (unwrap-panic partner-id) tx-sender) err-not-token-owner)

        ;; Remove pairing
        (map-delete nft-pairs token-id)
        (map-delete nft-pairs (unwrap-panic partner-id))
        (ok true)
    )
)

;; Transfer an NFT (unpairs if paired)
(define-public (transfer (token-id uint) (recipient principal))
    (let
        (
            (partner-id (map-get? nft-pairs token-id))
        )
        ;; Check ownership
        (asserts! (is-owner token-id tx-sender) err-not-token-owner)

        ;; If paired, unpair first
        (match partner-id
            paired-with (begin
                (map-delete nft-pairs token-id)
                (map-delete nft-pairs paired-with)
            )
            true
        )

        ;; Transfer ownership
        (map-set nft-owners token-id recipient)
        (ok true)
    )
)

;; Read-Only Functions

;; Get the owner of an NFT
(define-read-only (get-owner (token-id uint))
    (ok (map-get? nft-owners token-id))
)

;; Get the type of an NFT
(define-read-only (get-type (token-id uint))
    (ok (map-get? nft-types token-id))
)

;; Get the sound of an NFT (incomplete without pair)
(define-read-only (get-sound (token-id uint))
    (ok (map-get? nft-sounds token-id))
)

;; Get the partner of an NFT
(define-read-only (get-partner (token-id uint))
    (ok (map-get? nft-pairs token-id))
)

;; Check if an NFT is paired
(define-read-only (is-paired (token-id uint))
    (ok (is-some (map-get? nft-pairs token-id)))
)

;; Get complete music (only works if NFTs are paired)
(define-read-only (get-complete-music (token-id uint))
    (let
        (
            (partner-id (map-get? nft-pairs token-id))
            (my-sound (map-get? nft-sounds token-id))
            (nft-type (map-get? nft-types token-id))
        )
        (match partner-id
            paired-with
                (let
                    (
                        (partner-sound (map-get? nft-sounds paired-with))
                    )
                    ;; Return both sounds combined based on type order
                    (if (is-eq nft-type (some "melody"))
                        (ok {
                            melody: my-sound,
                            harmony: partner-sound,
                            complete: true
                        })
                        (ok {
                            melody: partner-sound,
                            harmony: my-sound,
                            complete: true
                        })
                    )
                )
            ;; Not paired - incomplete music
            (ok {
                melody: (if (is-eq nft-type (some "melody")) my-sound none),
                harmony: (if (is-eq nft-type (some "harmony")) my-sound none),
                complete: false
            })
        )
    )
)

;; Get the last minted token ID
(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)
