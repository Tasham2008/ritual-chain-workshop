## Starter for Ritual workshop on 23th June 2026

/hardhat -> Where we'll write the smart contract

/web -> Where the frontend lives.
## Reflection Question

**What should be public, what should stay hidden, and what should be decided by AI versus by a human in a bounty system?**

In a fair bounty system, the technical requirements, judging criteria, deadline rules, and the final verification hashes must remain completely public to ensure transparency and trust. Conversely, the participants' actual submissions and identical metadata must stay strictly hidden during the active phases to prevent front-running, plagiarism, and copy-paste improvements. The initial filtering, compliance checks, and comparative grading of large volumes of text submissions should be decided by AI, as it scales efficiently and eliminates subjective human bias at the sorting stage. However, the final critical decisions—such as confirming the top winner in ambiguous edge cases, resolving protocol disputes, and authorizing treasury payouts—must always be decided by a human manager. This hybrid approach guarantees a secure, merit-based environment where Web3 automation meets human accountability.
---

## Test Plan (Reveal Cases)

### 1. Valid Reveal (Success)
* **Pre-conditions:** Participant successfully submitted a commitment hash before the submission deadline. The block timestamp is now between the submission deadline and the reveal deadline.
* **Action:** Participant calls `revealAnswer(bountyId, "correct_answer", salt)`.
* **Expected Result:** The contract successfully verifies that the hash matches, updates `isRevealed` to `true`, stores the plaintext answer, and emits no errors.

### 2. Invalid Reveal: Incorrect Salt or Answer (Failure)
* **Action:** Participant calls `revealAnswer` with a wrong salt or a modified answer string.
* **Expected Result:** The contract reverts with the error `"Invalid salt or answer"`.

### 3. Invalid Reveal: Wrong Phase (Failure)
* **Action:** Participant attempts to call `revealAnswer` before the submission deadline or after the reveal deadline.
* **Expected Result:** The contract reverts with the error `"Invalid stage"` or phase-specific timing restrictions.

---

## Architecture Note: Commit-Reveal vs. Ritual-Native TEE

* **Commit-Reveal Approach (EVM Native):** This approach is chain-agnostic and secures the submission phase by keeping answers off-chain until the deadline. However, it requires a two-step human action (commit then reveal) and forces answers to become fully public on-chain during the reveal phase *before* the AI can judge them.
* **Ritual-Native Encrypted Approach (Advanced):** By leveraging Ritual's TEE-backed execution, participants can encrypt their submissions using a TEE public key. Plaintext answers are never exposed on-chain. During the judging phase, the TEE decrypts the submissions privately off-chain, batch-processes them through the LLM, and submits only the encrypted/hashed final results bundle. This completely eliminates the two-step reveal phase and ensures total privacy until the winner is finalized.
