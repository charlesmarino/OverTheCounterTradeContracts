pragma solidity ^0.4.24;
    
import "./ERC20.sol";
import "./Ownable.sol";

contract E20E20Factory is Ownable {
    
    uint public last_offer_id;
    mapping (uint => OfferInfo) public offers;
    bool locked;

    struct OfferInfo {
        ERC20    make_token;
        ERC20    take_token;
        uint     make_amount;
        uint     take_amount;
        address  owner;
        uint64   createdTimestamp;
    }

    modifier synchronized {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }


    function getOwner(uint id) public constant returns (address owner) {
        return offers[id].owner;
    }

    function getOfferInfo(uint id) public constant returns (uint, uint, ERC20, ERC20) {
      OfferInfo memory offer = offers[id];
      return (offer.make_amount, offer.take_amount, offer.make_token, offer.take_token);
    }

    function make(
        ERC20    take_token,
        ERC20    make_token,
        uint128  take_amount,
        uint128  make_amount
    ) public returns (bytes32 id) {
        return sell(take_token, make_token, take_amount, make_amount);
    }

    function take(bytes32 id, uint128 takeAmount) public {
        require(buy(uint256(id), takeAmount));
    }
    
    function kill(bytes32 id) public {
        require(cancel(uint256(id)));
    }

    function sell(ERC20 take_token, ERC20 make_token, uint128 take_amount, uint128 make_amount)
        public
        synchronized
        returns (bytes32 idInBytes)
    {
        require(make_amount > 0);
        require(make_token != ERC20(0x0));
        require(take_amount > 0);
        require(take_token != ERC20(0x0));
        require(make_token != take_token);

        OfferInfo memory info;
        info.make_token = make_token;
        info.take_token = take_token;
        info.make_amount = make_amount;
        info.take_amount = take_amount;
        info.owner = msg.sender;
        info.createdTimestamp = uint64(now);
        uint id = _nextId();
        offers[id] = info;

        require(make_token.transferFrom(msg.sender, this, make_amount));
        return bytes32(id);
    }

    function buy(uint id, uint128 amount)
        public
        synchronized
        returns (bool)
    {
        OfferInfo memory offer = offers[id];
        uint spend = mul(amount, offer.take_amount) / offer.make_amount;

        require(uint128(spend) == spend);

        if (amount == 0 || spend == 0 ||
            amount > offer.make_amount || spend > offer.take_amount)
        {
            return false;
        }

        offers[id].make_amount = sub(offer.make_amount, amount);
        offers[id].take_amount = sub(offer.take_amount, spend);
        require(offer.take_token.transferFrom(msg.sender, offer.owner, spend));
        require(offer.make_token.transfer(msg.sender, amount));

        emit LogTake(
            bytes32(id),
            offer.owner,
            msg.sender,
            offer.make_token,
            offer.take_token,
            amount,
            uint128(spend),
            uint64(now)
        );

        if (offers[id].make_amount == 0) {
          delete offers[id];
        }
        return true;
    }

    function cancel(uint id)
        public
        synchronized
        returns (bool success)
    {
        require(getOwner(id) == msg.sender);
        // read-only offer
        OfferInfo memory offer = offers[id];
        delete offers[id];
        // refund offer maker
        require(offer.make_token.transfer(offer.owner, offer.make_amount));

        emit LogItemUpdate(id);
        success = true;
    }


    function _nextId() internal returns (uint) {
        last_offer_id++; return last_offer_id;
    }

    //Events 
    event LogTake(
        bytes32           id,
        address  indexed  maker,
        address  indexed  taker,
        ERC20             make_token,
        ERC20             take_token,
        uint128           take_amount,
        uint128           make_amount,
        uint64            timestamp
    );

    event LogItemUpdate(uint id);

    //Math functions
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }

}