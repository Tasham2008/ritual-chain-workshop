// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AIJudge {
    enum Stage { Commit, Reveal, Judging, Finalized }

    struct Bounty {
        uint256 id;
        Stage stage;
        uint256 commitDeadline;
        uint256 revealDeadline;
        uint256 winnerIndex;
        bool isFinalized;
    }

    struct Submission {
        bytes32 commitment;
        string answer;
        bool isRevealed;
    }

    address public owner;
    mapping(uint256 => Bounty) public bounties;
    mapping(uint256 => mapping(address => Submission)) public submissions;
    mapping(uint256 => address[]) public participants;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier atStage(uint256 bountyId, Stage expectedStage) {
        require(bounties[bountyId].stage == expectedStage, "Invalid stage");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Создать новое баунти (для теста)
    function createBounty(uint256 bountyId, uint256 commitDuration, uint256 revealDuration) external onlyOwner {
        bounties[bountyId] = Bounty({
            id: bountyId,
            stage: Stage.Commit,
            commitDeadline: block.timestamp + commitDuration,
            revealDeadline: block.timestamp + commitDuration + revealDuration,
            winnerIndex: 0,
            isFinalized: false
        });
    }

    // 1. ФАЗА КОММИТА: Участники отправляют только хэш
    function submitCommitment(uint256 bountyId, bytes32 commitment) 
        external 
        atStage(bountyId, Stage.Commit) 
    {
        require(block.timestamp < bounties[bountyId].commitDeadline, "Commit period ended");
        require(submissions[bountyId][msg.sender].commitment == bytes32(0), "Already committed");

        submissions[bountyId][msg.sender] = Submission({
            commitment: commitment,
            answer: "",
            isRevealed: false
        });
        participants[bountyId].push(msg.sender);
    }

    // Вручную переключить стадию (для удобства тестирования)
    function setStage(uint256 bountyId, Stage _stage) external onlyOwner {
        bounties[bountyId].stage = _stage;
    }

    // 2. ФАЗА РАСКРЫТИЯ: Участники присылают ответ и соль
    function revealAnswer(uint256 bountyId, string calldata answer, bytes32 salt) 
        external 
        atStage(bountyId, Stage.Reveal) 
    {
        require(block.timestamp < bounties[bountyId].revealDeadline, "Reveal period ended");
        Submission storage sub = submissions[bountyId][msg.sender];
        require(sub.commitment != bytes32(0), "No commitment found");
        require(!sub.isRevealed, "Already revealed");

        // Проверяем, совпадает ли ответ и соль с ранее присланным хэшем
        bytes32 expectedCommitment = keccak256(abi.encodePacked(answer, salt, msg.sender, bountyId));
        require(sub.commitment == expectedCommitment, "Invalid salt or answer");

        sub.answer = answer;
        sub.isRevealed = true;
    }

    // 3. ФАЗА ОЦЕНКИ ИИ
    function judgeAll(uint256 bountyId, bytes calldata /* llmInput */) 
        external 
        atStage(bountyId, Stage.Judging) 
    {
        // Логика интеграции с Ritual нодами для батч-процессинга
    }

    // 4. ФИНАЛИЗАЦИЯ ПОБЕДИТЕЛЯ
    function finalizeWinner(uint256 bountyId, uint256 winnerIndex) 
        external 
        atStage(bountyId, Stage.Judging) 
        onlyOwner
    {
        Bounty storage bounty = bounties[bountyId];
        bounty.winnerIndex = winnerIndex;
        bounty.stage = Stage.Finalized;
        bounty.isFinalized = true;
    }
}
