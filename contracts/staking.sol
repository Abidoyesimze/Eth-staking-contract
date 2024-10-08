// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract Staking {
    error AccessRestricted();
    error ZeroEthDetected();
    error AddressAlreadyExists();
    error StakeDurationNotEnded();
    error AlreadyWithdrawn();
    error insufficientAllowance();

    struct Staker {
        uint256 amount;
        uint256 startTime;
        bool hasWithdrawn;
    }

    mapping(address => Staker) public stakers;
    IERC20 public stakingToken;
    uint256 public rewardRate;
    uint256 public stakingDuration;
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

    constructor(address _stakingToken,
        uint256 _rewardRate,
        uint256 _stakingDuration) payable {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardRate = _rewardRate;
        stakingDuration = _stakingDuration;
    }

    function stake() external payable {
        if (msg.value <= 0) {
            revert ZeroEthDetected();
        }
        if (stakers[msg.sender].amount > 0) {
            revert AddressAlreadyExists();
        }

        uint256 allowance = stakingToken.allowance(msg.sender, address(this));
        if (allowance < _amount) {
            revert InsufficientAllowance();
        }

        stakingToken.transferFrom(msg.sender, address(this), _amount);

        stakers[msg.sender] = Staker({
            amount: msg.value,
            startTime: block.timestamp,
            hasWithdrawn: false
        });

        // emit Staked(msg.sender, msg.value, block.timestamp);
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

        payable(msg.sender).transfer(totalAmount);

        emit Withdrawn(msg.sender, staker.amount, reward);
    }

    function withdrawContractBalance() external onlyOwner {
        stakingToken.transfer(owner, stakingToken.balanceOf(address(this)));
    }

    function updateRewardRate(uint256 _newRate) external onlyOwner {
        rewardRate = _newRate;
    }

    function updateStakingDuration(uint256 _newStakingDuration) external onlyOwner {
        stakingDuration = _newStakingDuration;
    }

    receive() external payable {
        stakers[msg.sender].amount += msg.value;
    }
}
