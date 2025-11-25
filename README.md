Musical Duet NFTs Contract

Overview
The Musical Duet NFT contract enables the creation of two types of NFTs: melody and harmony. Individually, each NFT plays an incomplete sound. When paired with its counterpart, they produce complete music. The contract supports minting, pairing, unpairing, transferring, and querying NFTs.

This design encourages collaboration and interaction between NFT holders, creating a unique experience where complete music emerges only when the correct NFTs are paired.

Table of Contents

Features

Constants & Errors

NFT Data Structure

Public Functions

Read-Only Functions

Example Workflow

Deployment

Features

Mint melody or harmony NFTs.

Pair NFTs to play complete music.

Unpair NFTs safely.

Transfer NFTs while automatically unpairing them if needed.

Read-only functions for querying ownership, type, sound, pairing status, and complete music.

Constants & Errors

contract-owner: Owner of the contract.

err-owner-only (u100): Only the contract owner can perform this action.

err-not-token-owner (u101): Action attempted by non-owner of the token.

err-token-not-found (u102): Token does not exist.

err-already-paired (u103): Token is already paired.

err-invalid-pair (u104): Attempted pairing of incompatible NFT types.

err-not-paired (u105): Token is not currently paired.

NFT Data Structure

last-token-id: Stores the ID of the last minted NFT.

nft-owners: Maps token IDs to owner addresses.

nft-types: Stores NFT type as "melody" or "harmony".

nft-pairs: Stores paired NFT relationships.

nft-sounds: Stores individual NFT sounds (string, up to 50 ASCII characters).

Public Functions
Minting

mint-melody(sound) – Mint a melody NFT with a given sound.

mint-harmony(sound) – Mint a harmony NFT with a given sound.

Pairing

pair-nfts(melody-id, harmony-id) – Pair a melody NFT with a harmony NFT to create complete music. Ownership of both NFTs is required.

Unpairing

unpair-nfts(token-id) – Unpair an NFT from its partner. Ownership of both NFTs is required.

Transfer

transfer(token-id, recipient) – Transfer an NFT to another user. Automatically unpairs if currently paired.

Read-Only Functions

get-owner(token-id) – Returns the owner of a token.

get-type(token-id) – Returns the type (melody or harmony) of a token.

get-sound(token-id) – Returns the individual sound of a token.

get-partner(token-id) – Returns the paired token ID.

is-paired(token-id) – Returns true if the token is paired.

get-complete-music(token-id) – Returns the combined music if the token is paired, else partial sound.

get-last-token-id() – Returns the ID of the last minted NFT.

Example Workflow

Mint Melody and Harmony NFTs

(mint-melody "C E G")
(mint-harmony "G B D")


Pair NFTs

(pair-nfts 1 2)


Get Complete Music

(get-complete-music 1)
;; Returns { melody: "C E G", harmony: "G B D", complete: true }


Transfer NFT

(transfer 1 'SP2XXXX...)
;; NFT 1 is unpaired automatically if it was paired


Unpair NFTs

(unpair-nfts 2)

Deployment

Deploy the contract to Stacks blockchain.

Use a Clarity-compatible wallet (e.g., Hiro Wallet) for interactions.

Interact with public and read-only functions via CLI, wallet, or DApp frontend.