# My Simple Test Plan

Here is how I plan to test my smart contract to make sure everything works without mistakes:

1. **Testing the Hidden Phase (Commit):**
   * I will try to send a hidden hash of my answer using the `submitCommitment` function. 
   * I need to check that the transaction is successful and nobody can see what my real answer is.

2. **Testing the Opening Phase (Reveal):**
   * After the time is over, I will send my real text answer and my secret password (salt).
   * If I send the correct password, the contract must say "OK" and accept my answer.
   * If I make a mistake in the password or text, the contract must reject it with an error.

3. **Testing the Judging:**
   * I will check that all good answers are sent together to the Ritual AI.
   * Finally, I will check that the owner can click the button to finish the contest and choose the winner.
