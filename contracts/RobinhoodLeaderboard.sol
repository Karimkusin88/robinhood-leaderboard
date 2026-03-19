// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract RobinhoodLeaderboard {

    struct Builder {
        address wallet;
        string name;
        uint256 txCount;
        uint256 contractsDeployed;
        uint256 points;
        uint256 lastActivity;
        bool registered;
    }

    address public owner;
    address[] public builderList;
    mapping(address => Builder) public builders;
    mapping(address => bool) public operators;

    uint256 public constant POINTS_PER_TX = 10;
    uint256 public constant POINTS_PER_CONTRACT = 50;
    uint256 public constant POINTS_PER_DAY_STREAK = 25;

    event BuilderRegistered(address indexed wallet, string name);
    event ActivityUpdated(address indexed wallet, uint256 txCount, uint256 contracts, uint256 points);
    event PointsAwarded(address indexed wallet, uint256 amount, string reason);

    modifier onlyOwner() { require(msg.sender == owner, "Not owner"); _; }
    modifier onlyOperator() { require(operators[msg.sender] || msg.sender == owner, "Not operator"); _; }

    constructor() {
        owner = msg.sender;
        operators[msg.sender] = true;
    }

    function register(string calldata _name) external {
        require(!builders[msg.sender].registered, "Already registered");
        require(bytes(_name).length > 0 && bytes(_name).length <= 32, "Invalid name");
        builders[msg.sender] = Builder(msg.sender, _name, 0, 0, 0, block.timestamp, true);
        builderList.push(msg.sender);
        emit BuilderRegistered(msg.sender, _name);
    }

    function checkIn() external {
        require(builders[msg.sender].registered, "Not registered");
        Builder storage b = builders[msg.sender];
        require(block.timestamp >= b.lastActivity + 20 hours, "Already checked in today");
        b.points += POINTS_PER_DAY_STREAK;
        b.lastActivity = block.timestamp;
        b.txCount += 1;
        emit PointsAwarded(msg.sender, POINTS_PER_DAY_STREAK, "Daily check-in");
    }

    function updateActivity(address _builder, uint256 _txCount, uint256 _contractsDeployed) external onlyOperator {
        require(builders[_builder].registered, "Not registered");
        Builder storage b = builders[_builder];
        if (_txCount > b.txCount) b.points += (_txCount - b.txCount) * POINTS_PER_TX;
        if (_contractsDeployed > b.contractsDeployed) b.points += (_contractsDeployed - b.contractsDeployed) * POINTS_PER_CONTRACT;
        b.txCount = _txCount;
        b.contractsDeployed = _contractsDeployed;
        b.lastActivity = block.timestamp;
        emit ActivityUpdated(_builder, _txCount, _contractsDeployed, b.points);
    }

    function awardPoints(address _builder, uint256 _points, string calldata _reason) external onlyOperator {
        require(builders[_builder].registered, "Not registered");
        builders[_builder].points += _points;
        emit PointsAwarded(_builder, _points, _reason);
    }

    function getBuilder(address _wallet) external view returns (Builder memory) { return builders[_wallet]; }
    function getTotalBuilders() external view returns (uint256) { return builderList.length; }
    function getLeaderboard(uint256 offset, uint256 limit) external view returns (Builder[] memory) {
        uint256 total = builderList.length;
        if (offset >= total) return new Builder[](0);
        uint256 end = offset + limit > total ? total : offset + limit;
        Builder[] memory result = new Builder[](end - offset);
        for (uint256 i = offset; i < end; i++) result[i - offset] = builders[builderList[i]];
        return result;
    }
    function setOperator(address _op, bool _status) external onlyOwner { operators[_op] = _status; }
}
