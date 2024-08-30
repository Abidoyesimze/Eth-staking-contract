// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract staking {

    struct Staker {
        uint amount;
        uint startTime;
        bool hasWithdrawn;
    }

    mapping(address => Staker) stakers;
    uint256 public rewardRate;
    uint256 public stakingDuration;
    address owner;

    
    event Staked(address indexed user, uint amount, uint time);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward); // Changed "withdrawn" to "Withdrawn"

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call thi function");
        _;
    }

    modifier hasStaked(){
        require(stakers[msg.sender].amount > 0, "not enough Eth to stake");
        _;
    }

    constructor(uint _rewardRate, uint _stakingDuration){
        owner == msg.sender;
        rewardRate = _rewardRate;
        stakingDuration = _stakingDuration;
    }

    function stake() external payable {
        require(msg.value > 0, "You need some ether to stake");
        require(stakers[msg.sender].amount == 0, "Already staking");

        stakers[msg.sender] = Staker ({
            amount: msg.value,
            startTime: block.timestamp,
            hasWithdrawn: false
        });

        
        emit Staked(msg.sender, msg.value, block.timestamp);
    }

    function calculateReward(address _staker) public view returns(uint256){
        Staker memory staker =stakers[_staker];
        uint256 stakedTime = block.timestamp - staker.startTime;
        require(stakedTime > stakingDuration, "Voting has not ended yet");
        uint reward = (stakerAmount * rewardRate * stakedTime) /(stakingDuration * 100);
        return reward;
    }
}  function withdraw() external hasStaked{
     Staker memory stakers[msg.sender];
     require(!stakers.hasWithdrawn, "Already withdrawn");

     uint reward = calculateReward[msg.sender];
     uint totalAmount = staker.amount + reward;

     stakers.hasWithdrawn = true;
     
     staker.amount = 0;

     payable(msg.sender).transfer(totalAmount);

     emit Withdrawn(msg.sender, staker.amount, reward);
}

 functionWithdrawContractBalance() external onlyOwner{
    payable(owner).transfer(this).balance;
 }

 receive() external payable{}   

 function updateRewardRate(uint256 _newRate) external onlyOwner{
    rewardRate = _newRate;
 }

 function updateStakingDuration(uint256 _newStakingDuration) external onlyOwner{
    stakingDuration = _newStakingDuration;
 }
