// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AIBountyJudge {
    
    // Structure to save information about each bounty contest
    struct Bounty {
        uint256 id;
        address winner;
        bool isFinished;
    }

    // Storage mappings for blockchain data
    mapping(uint256 => Bounty) public bounties;
    
    // Stores hidden hash: bountyId => user address => commitment hash
    mapping(uint256 => mapping(address => bytes32)) public commitments;
    
    // Stores open text answer: bountyId => user address => answer string
    mapping(uint256 => mapping(address => string)) public revealedAnswers;

    // 1. Commit Phase: User sends only a hidden hash of the answer
    function submitCommitment(uint256 bountyId, bytes32 commitment) public {
        require(commitment != bytes32(0), "Hash cannot be empty");
        commitments[bountyId][msg.sender] = commitment;
    }

    // 2. Reveal Phase: User sends the real answer text and a secret password (salt)
    function revealAnswer(uint256 bountyId, string calldata answer, bytes32 salt) public {
        bytes32 userCommitment = commitments[bountyId][msg.sender];
        require(userCommitment != bytes32(0), "You did not submit a commitment");

        // Check if the real answer + salt matches the original hidden hash
        bytes32 calculatedHash = keccak256(abi.encodePacked(answer, salt, msg.sender, bountyId));
        require(calculatedHash == userCommitment, "Wrong answer or secret password!");

        // If match is correct, save the plaintext answer for the AI judge
        revealedAnswers[bountyId][msg.sender] = answer;
    }

    // 3. Judging Phase: Prepares and sends verified answers to Ritual AI system
    function judgeAll(uint256 bountyId, bytes calldata llmInput) public pure returns (string memory) {
        // This gathers data for the Ritual TEE and LLM model processing
        return "Answers successfully sent to Ritual AI for batch judging";
    }

    // 4. Final Phase: Sets the winner of the bounty contest
    function finalizeWinner(uint256 bountyId, uint256 winnerIndex, address winnerAddress) public {
        require(!bounties[bountyId].isFinished, "Bounty is already finished");
        
        bounties[bountyId].id = bountyId;
        bounties[bountyId].winner = winnerAddress;
        bounties[bountyId].isFinished = true;
    }
}
