pragma solidity ^0.4.24;

import "./Ownable.sol";

//currently erc20 standard
contract token {
    function decimals() public constant returns (uint8);
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
}

contract TokenTrade is Ownable {
    address private traderA;
    address private traderB;
    address private traderADepositToken;
    address private traderBDepositToken;
    uint private traderADepositAmount;
    uint private traderBDepositAmount;
    
    constructor (
        address firstTrader,
        address secondTrader,
        address tokenFirstTraderSending,
        address tokenSecondTraderMustSend,
        uint amountFirstTraderSending,
        uint amountSecondTraderMustSend 
        ) public {
        require(tokenFirstTraderSending != tokenSecondTraderMustSend 
        && amountFirstTraderSending > 0 
        && amountSecondTraderMustSend > 0 );
        traderA = firstTrader;
        traderADepositToken = tokenFirstTraderSending;
        traderADepositAmount = amountFirstTraderSending;
        traderB = secondTrader;
        traderBDepositToken = tokenSecondTraderMustSend;
        traderBDepositAmount = amountSecondTraderMustSend;
    }

    function getInfo() public view returns(
        address firstTrader,
        address secondTrader,
        address tokenFirstTraderSending,
        address tokenSecondTraderMustSend,
        uint amountFirstTraderSending,
        uint amountSecondTraderMustSend
        ) {
        firstTrader = traderA;
        tokenFirstTraderSending = traderADepositToken;
        amountFirstTraderSending = traderADepositAmount;
        secondTrader = traderB;
        tokenSecondTraderMustSend = traderBDepositToken;
        amountSecondTraderMustSend = traderBDepositAmount;
        return (firstTrader,
        secondTrader,
        tokenFirstTraderSending,
        tokenSecondTraderMustSend,
        amountFirstTraderSending,
        amountSecondTraderMustSend);
    }
    
    function pow(uint _a, uint _b) internal pure returns (uint) {
        return _a *10**_b;
    } 
    
    function getTokenBalances() public view returns (uint firstTokenBalance, uint secondTokenBalance) {
        token firstDepositToken = token(traderADepositToken);
        token secondDepositToken = token(traderBDepositToken);
        firstTokenBalance = pow(firstDepositToken.balanceOf(this), uint256(firstDepositToken.decimals()));
        secondTokenBalance = pow(secondDepositToken.balanceOf(this), uint256(secondDepositToken.decimals()));
        return (firstTokenBalance,
        secondTokenBalance);
    }
    
    function completeTrade() public {
        token firstDepositToken = token(traderADepositToken);
        token secondDepositToken = token(traderBDepositToken);
        firstDepositToken.transfer(traderB, pow(traderBDepositAmount, uint256(firstDepositToken.decimals())));
        secondDepositToken.transfer(traderA, pow(traderADepositAmount, uint256(secondDepositToken.decimals())));
    }
    
    function withdrawAsSender() external {
        withdraw(msg.sender);
    }
    
    function withdrawAsOwner(address addr) public onlyOwner {
        withdraw(addr);
    }
    
    function withdraw(address addr) private {
        require (addr == traderA || addr == traderB);
        if(addr == traderA) {
            token firstDepositToken = token(traderADepositToken);
            firstDepositToken.transfer(traderA, firstDepositToken.balanceOf(this));
        } 
        if (addr == traderB) {
          token secondDepositToken = token(traderBDepositToken);
          secondDepositToken.transfer(traderB, secondDepositToken.balanceOf(this));
        }
    } 

}