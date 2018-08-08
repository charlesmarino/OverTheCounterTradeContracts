pragma solidity ^0.4.24;

import "./Ownable.sol";

//currently erc20 standard

contract token {
    /// @return total amount of tokens
    function totalSupply() public constant returns (uint);
    /// @return balance
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @return Whether the transfer was successful or not
    function transfer(address to, uint tokens) public returns (bool success);
    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @return Whether the approval was successful or not
    function approve(address spender, uint tokens) public returns (bool success);
    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @return Whether the transfer was successful or not
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    string public symbol;
    uint public decimals;
    string public name;
}

contract TokenTrade is Ownable {
    address private firstTrader;
    address private secondTrader;
    address private firstTraderDepositToken;
    address private secondTraderDepositToken;
    uint private firstTraderDepositAmount;
    uint private secondTraderDepositAmount;
    
    constructor (
        address isFirstTrader,
        address isSecondTrader,
        address tokenFirstTraderSending,
        address tokenSecondTraderMustSend,
        uint amountFirstTraderSending,
        uint amountSecondTraderMustSend 
        ) public {
        require(tokenFirstTraderSending != tokenSecondTraderMustSend 
        && amountFirstTraderSending > 0 
        && amountSecondTraderMustSend > 0 );
        firstTrader = isFirstTrader;
        firstTraderDepositToken = tokenFirstTraderSending;
        firstTraderDepositAmount = amountFirstTraderSending;
        secondTrader = isSecondTrader;
        secondTraderDepositToken = tokenSecondTraderMustSend;
        secondTraderDepositAmount = amountSecondTraderMustSend;
    }

    function getInfo() public view returns(
        address isFirstTrader,
        address isSecondTrader,
        address tokenFirstTraderSending,
        address tokenSecondTraderMustSend,
        uint amountFirstTraderSending,
        uint amountSecondTraderMustSend
        ) {
        require (isFirstTrader!=0 &&
         isSecondTrader!=0 &&
         tokenFirstTraderSending!=0 &&
         tokenSecondTraderMustSend!=0 && 
         amountFirstTraderSending!=0 &&
         amountSecondTraderMustSend!=0);
        isFirstTrader = firstTrader;
        tokenFirstTraderSending = firstTraderDepositToken;
        amountFirstTraderSending = firstTraderDepositAmount;
        isSecondTrader = secondTrader;
        tokenSecondTraderMustSend = secondTraderDepositToken;
        amountSecondTraderMustSend = secondTraderDepositAmount;
        return (isFirstTrader,
        isSecondTrader,
        tokenFirstTraderSending,
        tokenSecondTraderMustSend,
        amountFirstTraderSending,
        amountSecondTraderMustSend);
    }
    
    function pow(uint _a, uint _b) internal pure returns (uint) {
        return _a *10**_b;
    } 
    
    function getTokenBalances() public view returns (uint firstTokenBalance, uint secondTokenBalance) {
        token firstDepositToken = token(firstTraderDepositToken);
        token secondDepositToken = token(secondTraderDepositToken);
        //confirm correct 
        firstTokenBalance = pow(firstDepositToken.balanceOf(this), uint256(firstDepositToken.decimals()));
        secondTokenBalance = pow(secondDepositToken.balanceOf(this), uint256(secondDepositToken.decimals()));
        return (firstTokenBalance,
        secondTokenBalance);
    }
    
    function completeTrade() public {
        // t2 - require enough deposit amounts  
        token firstDepositToken = token(firstTraderDepositToken);
        token secondDepositToken = token(secondTraderDepositToken);
        uint firstTokenAmount = pow(firstTraderDepositAmount, uint256(firstDepositToken.decimals()));
        uint secondTokenAmount = pow(secondTraderDepositAmount, uint256(secondDepositToken.decimals()));
        if(!firstDepositToken.transfer(secondTrader, firstTokenAmount)) revert();
        if(!secondDepositToken.transfer(firstTrader, secondTokenAmount)) revert();
        // t1 - add complete event front end should listen for
    }

     //should be used via dapps as primary way to deposit
    function depositTokenToContract(address depositToken, uint amount) public {
    //remember to call Token(address).approve(this, amount) or this contract 
    //will not be able to do the transfer on your behalf.
        require ((msg.sender == firstTrader || msg.sender == secondTrader) && 
            depositToken!=0 && amount!=0);
        if (!token(depositToken).transferFrom(msg.sender, this, amount)) revert();
        // t3 - add deposit events front end should listen for
    }
    
    function withdrawAsSender() external {
        withdraw(msg.sender);
        // t4 - add deposit events front end should listen for
    }
    
    //this type of withdraw function should not be supported and we should interact
    // with the contract directly with corresponding ABI with withdrawAsSender
    function withdrawAsOwner(address addr) public onlyOwner {
        withdraw(addr);
    }
    
    function withdraw(address addr) private {
        require (addr == firstTrader || addr == secondTrader);
        if(addr == firstTrader) {
            token firstDepositToken = token(firstTraderDepositToken);
            firstDepositToken.transfer(firstTrader, firstDepositToken.balanceOf(this));
        } 
        if (addr == secondTrader) {
          token secondDepositToken = token(secondTraderDepositToken);
          secondDepositToken.transfer(secondTrader, secondDepositToken.balanceOf(this));
        }
    } 
}