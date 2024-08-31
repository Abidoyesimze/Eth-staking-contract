// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Staking is ERC20 {
    error AccessRestricted();
    error ZeroEthDetected();
    error AddressAlreadyExists();
    error StakeDurationNotEnded();
    error AlreadyWithdrawn();

    struct Staker {
        uint256 amount;
        uint256 startTime;
        bool hasWithdrawn;
    }

    mapping(address => Staker) public stakers;
    uint256 public rewardRate;
    uint256 public stakingDuration;
    uint256 public stakingToken;
    address public owner;

    event Staked(address indexed user, uint256 amount, uint256 time);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward);

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert AccessRestricted();
        }
        _;
    }

    modifier hasStaked() {
        if (stakers[msg.sender].amount == 0) {
            revert ZeroEthDetected();
        }
        _;
    }

    constructor(uint256 _stakingToken, uint256 _rewardRate, uint256 _stakingDuration) ERC20("StakingToken", "STAKING") {
        

        owner = msg.sender;
        rewardRate = _rewardRate;
        stakingDuration = _stakingDuration;
        stakingToken = _stakingToken;
    }

    function stake(uint256 amount) external {
        if (amount == 0) {
            revert ZeroEthDetected();
        }
        if (stakers[msg.sender].amount > 0) {
            revert AddressAlreadyExists();
        }

        _transfer(msg.sender, address(this), amount);

        stakers[msg.sender] = Staker({
            amount: amount,
            startTime: block.timestamp,
            hasWithdrawn: false
        });

        emit Staked(msg.sender, amount, block.timestamp);
    }

    function calculateReward(address _staker) public view returns (uint256) {
        Staker memory staker = stakers[_staker];
        uint256 stakedTime = block.timestamp - staker.startTime;

        if (stakedTime < stakingDuration) {
            revert StakeDurationNotEnded();
        }

        uint256 reward = (staker.amount * rewardRate * stakedTime) / (stakingDuration * 100);
        return reward;
    }

    function withdraw() external hasStaked {
        Staker storage staker = stakers[msg.sender];
        if (staker.hasWithdrawn) {
            revert AlreadyWithdrawn();
        }

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = staker.amount + reward;

        staker.hasWithdrawn = true;
        staker.amount = 0;

        _transfer(address(this), msg.sender, totalAmount);

        emit Withdrawn(msg.sender, totalAmount, reward);
    }

    function withdrawContractBalance() external onlyOwner {
       
    }

    function updateRewardRate(uint256 _newRate) external onlyOwner {
        rewardRate = _newRate;
    }

    function updateStakingDuration(uint256 _newStakingDuration) external onlyOwner {
        stakingDuration = _newStakingDuration;
    }
}