pragma solidity ^0.4.16;

interface token{
    function transfer(address receiver, uint amount);
}

contract CrowdFund {
    address public beneficiary;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;

    event GoalReached(address beneficiaryAddress, uint amountRaisedValue);
    event FundTransfer(address backer, uint amount, bool isContribution);

    function CrowdFund(
        address ifSuccessfulSendTo,
        uint fundingGoalInEtheres,
        uint durationInMinutes,
        uint ethereCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInTehres * 1 ether;
        deadline = now +  durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    function () external payable {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / price);
        emit FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    function checkGoalReached() external afterDeadline {
        if(amountRaised >= fundingGoal) {
            fundingGoalReached = true;
            emit GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }

    function safeWithdrawal () external afterDeadline {
        if(!fundingGoalReached){
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount> 0){
                if(msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }
        if(fundingGoalReached && beneficiary == msg.sender) {
            if(beneficiary.send(amountRaised)) {
                emit FundTransfer(beneficiay, amountRaised, false);
            } else {
                fundingGoalReached = false;
            }
        }
    }
}