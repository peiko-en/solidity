// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

contract MultiSig {
    uint256 private _numRequiredConfirmations;

    struct Proposal {
        bool isExist;
        address creator;
        bytes32 signatureId;
        bytes data;
        uint256 deadline;
        bool completed;
        uint256 confirmations;
        mapping(address => bool) confirmed;
    }

    mapping(bytes32 => Proposal) private _proposals;

    event ProposalCreated(
        bytes32 indexed proposalId, address indexed creator, bytes32 indexed signatureId, bytes data, uint256 deadline
    );
    event ProposalConfirmed(bytes32 indexed proposalId, address indexed confirmer);
    event ProposalCompleted(bytes32 indexed proposalId, address indexed executant);

    error ProposalDoesNotExist();
    error DeadlineIsExpired();
    error AlreadyConfirmed();

    modifier requireConfirmation(bytes32 proposalId) {
        Proposal storage proposal = _proposals[proposalId];
        require(proposal.isExist, "MultiSig: error");
        require(msg.sig == bytes4(proposal.signatureId), "MultiSig: error");
        require(proposal.deadline > block.timestamp, "MultiSig: error");
        require(proposal.confirmations >= _numRequiredConfirmations, "MultiSig: error");
        require(!proposal.completed, "MultiSig: error");
        _;
    }

    function getNumRequiredConfirmations() external view returns (uint256) {
        return _numRequiredConfirmations;
    }

    function setNumRequiredConfirmations(uint256 numRequiredConfirmations) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _numRequiredConfirmations = numRequiredConfirmations;
    }

    function getProposal(bytes32 proposalId)
        external
        view
        returns (
            bool isExist,
            address creator,
            bytes32 signatureId,
            bytes memory data,
            uint256 deadline,
            bool completed,
            uint256 confirmations
        )
    {
        Proposal storage proposal = _proposals[proposalId];

        isExist = proposal.isExist;
        creator = proposal.creator;
        signatureId = proposal.signatureId;
        data = proposal.data;
        deadline = proposal.deadline;
        completed = proposal.completed;
        confirmations = proposal.confirmations;
    }

    function createProposal(bytes memory signature, bytes memory data, uint256 deadline)
        external
        onlyRole(VOTER_ROLE)
        returns (bytes32)
    {
        require(signature.length > 0, "MultiSig: error");
        require(deadline > block.timestamp, "MultiSig: error");

        bytes32 signatureId = keccak256(abi.encodePacked(signature));
        bytes32 proposalId = keccak256(abi.encodePacked(signatureId, data, deadline));
        Proposal storage proposal = _proposals[proposalId];
        require(!proposal.isExist, "MultiSig: error");

        proposal.isExist = true;
        proposal.creator = msg.sender;
        proposal.signatureId = signatureId;
        proposal.data = data;
        proposal.deadline = deadline;

        emit ProposalCreated(proposalId, msg.sender, signatureId, data, deadline);

        return proposalId;
    }

    function confirmProposal(bytes32 proposalId) external onlyRole(VOTER_ROLE) {
        Proposal storage proposal = _proposals[proposalId];

        require(proposal.isExist, "MultiSig: error");
        require(proposal.deadline > block.timestamp, "MultiSig: error");
        require(!proposal.confirmed[msg.sender], "MultiSig: error");

        proposal.confirmations += 1;
        proposal.confirmed[msg.sender] = true;

        emit ProposalConfirmed(proposalId, msg.sender);
    }
}