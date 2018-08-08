pragma solidity ^0.4.24;

import "./TokenTrade.sol";
    
contract TradeFactory is Ownable {
    
  // deploy a new contract

    function newTrade(
        address firstTrader,
        address secondTrader,
        address tokenFirstTraderSending,
        address tokenSecondTraderMustSend,
        uint amountFirstTraderSending,
        uint amountSecondTraderMustSend 
        )
    public
    returns(address newContract)
    {
      TokenTrade t = new TokenTrade(
        firstTrader,
        secondTrader,
        tokenFirstTraderSending,
        tokenSecondTraderMustSend,
        amountFirstTraderSending,
        amountSecondTraderMustSend 
        );
      return t;
    }

    function completeTrade(address addr) external {
        TokenTrade t = TokenTrade(addr);
        return t.completeTrade();
    }
    
    function getTokenTradeInfo(address addr) external view returns (
        address firstTrader,
        address secondTrader,
        address firstTraderToken,
        address secondTraderToken,
        uint firstTraderAmount,
        uint secondTraderAmount
        ) {
        TokenTrade t = TokenTrade(addr);
        (firstTrader,
        secondTrader,
        firstTraderToken,
        secondTraderToken,
        firstTraderAmount,
        secondTraderAmount) = t.getInfo();
        
        return (firstTrader,
        secondTrader,
        firstTraderToken,
        secondTraderToken,
        firstTraderAmount,
        secondTraderAmount);
    }
    
    function getTokenTradeBalances(address addr) external view returns (
        uint firstTokenBalance,
        uint secondTokenBalance) {
        TokenTrade t = TokenTrade(addr);
        (firstTokenBalance, secondTokenBalance) = t.getInfo();
        return (firstTokenBalance, secondTokenBalance);
    }

    function withdraw(address addr) external {
        TokenTrade t = TokenTrade(addr);
        return t.withdrawAsOwner(msg.sender);
    } 

}