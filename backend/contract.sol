// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Staking {
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public stakingTime;
    uint256 public rewardRate = 10; // 10% reward rate

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward);

    constructor() {
        owner = msg.sender;
    }

    // Stake MATIC (Native token on Polygon)
    function stake() public payable {
        require(msg.value > 0, "Must stake some MATIC");

        if (balances[msg.sender] > 0) {
            uint256 reward = calculateReward(msg.sender);
            balances[msg.sender] += reward;
        }

        balances[msg.sender] += msg.value;
        stakingTime[msg.sender] = block.timestamp;

        emit Staked(msg.sender, msg.value);
    }

    // Calculate staking reward
    function calculateReward(address user) public view returns (uint256) {
        uint256 timeStaked = block.timestamp - stakingTime[user];
        uint256 reward = (balances[user] * rewardRate * timeStaked) / (100 * 365 days);
        return reward;
    }

    // Withdraw staked MATIC and rewards
    function withdraw() public {
        require(balances[msg.sender] > 0, "No staked balance");

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = balances[msg.sender] + reward;

        balances[msg.sender] = 0;
        stakingTime[msg.sender] = 0;

        payable(msg.sender).transfer(totalAmount);
        emit Withdrawn(msg.sender, totalAmount, reward);
    }

    // Contract can receive MATIC
    receive() external payable {}
}
