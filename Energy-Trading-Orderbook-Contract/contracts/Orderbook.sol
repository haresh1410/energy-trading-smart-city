// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

contract OrderBook {
    uint public sessionId;
    mapping(address => uint) public userBidPrice;
    mapping(address => uint) public userAskPrice;
    struct Order {
        uint powerUnits;
        address user;
        uint price;
        bool completed;
        bool isSessionClosed;
        uint closedPrice;
        uint sessionId;
    }

    Order[] public buyOrders;
    Order[] public sellOrders;

    function setBidPrice(uint _bid) public {
        userBidPrice[msg.sender] = _bid;
    }

    function setSessionId(uint _sessionId) public {
        sessionId = _sessionId;
    }

    function retrieveBidPrice() public view returns (uint) {
        return userBidPrice[msg.sender];
    }

    function setAskPrice(uint _ask) public {
        userAskPrice[msg.sender] = _ask;
    }

    function retrieveAskPrice() public view returns (uint) {
        return userAskPrice[msg.sender];
    }

    function retrieveBuyOrders() public view returns (Order[] memory) {
        return buyOrders;
    }

    function retrieveSellOrders() public view returns (Order[] memory) {
        return sellOrders;
    }

    function placeBid(uint _powerUnits) public returns (Order[] memory) {
        uint remaining_units;
        if (sellOrders.length == 0) remaining_units = _powerUnits;
        if (sellOrders.length > 0) {
            for (uint s = 0; s < sellOrders.length; s++) {
                if (sellOrders[s].completed == true) continue;
                if (userBidPrice[msg.sender] >= sellOrders[s].price) {
                    if (_powerUnits >= sellOrders[s].powerUnits) {
                        remaining_units =
                            _powerUnits -
                            sellOrders[s].powerUnits;
                        if (remaining_units == 0) {
                            buyOrders.push(
                                Order({
                                    powerUnits: _powerUnits,
                                    user: msg.sender,
                                    price: userBidPrice[msg.sender],
                                    completed: true,
                                    isSessionClosed: false,
                                    closedPrice: 0,
                                    sessionId: sessionId
                                })
                            );
                        } else {
                            _powerUnits = remaining_units;
                            buyOrders.push(
                                Order({
                                    powerUnits: sellOrders[s].powerUnits,
                                    user: msg.sender,
                                    price: userBidPrice[msg.sender],
                                    completed: true,
                                    isSessionClosed: false,
                                    closedPrice: 0,
                                    sessionId: sessionId
                                })
                            );
                        }
                        sellOrders[s].completed = true;
                    } else {
                        remaining_units =
                            sellOrders[s].powerUnits -
                            _powerUnits;
                        sellOrders[s].powerUnits = remaining_units;
                    }
                } else {
                    break;
                }
            }
        }
        if (buyOrders.length == 0) {
            buyOrders.push(
                Order({
                    powerUnits: _powerUnits,
                    user: msg.sender,
                    price: userBidPrice[msg.sender],
                    completed: false,
                    isSessionClosed: false,
                    closedPrice: 0,
                    sessionId: sessionId
                })
            );
            return buyOrders;
        } else if (remaining_units > 0) {
            uint updatedLength = buyOrders.length + 1;
            Order[] memory updatedBuyOrders = new Order[](updatedLength);
            for (uint k = 0; k < buyOrders.length; k++) {
                updatedBuyOrders[k] = buyOrders[k];
            }
            // debug = updatedBuyOrders[0].price;
            for (uint i = 0; i < updatedLength; i++) {
                if (userBidPrice[msg.sender] > updatedBuyOrders[i].price) {
                    for (uint j = updatedBuyOrders.length - 1; j > i; j--) {
                        updatedBuyOrders[j] = updatedBuyOrders[j - 1];
                    }

                    updatedBuyOrders[i] = Order({
                        powerUnits: _powerUnits,
                        user: msg.sender,
                        price: userBidPrice[msg.sender],
                        completed: false,
                        isSessionClosed: false,
                        closedPrice: 0,
                        sessionId: sessionId
                    });
                    break;
                } else {
                    if (i == updatedBuyOrders.length - 1) {
                        updatedBuyOrders[i] = Order({
                            powerUnits: _powerUnits,
                            user: msg.sender,
                            price: userBidPrice[msg.sender],
                            completed: false,
                            isSessionClosed: false,
                            closedPrice: 0,
                            sessionId: sessionId
                        });
                    }
                }
            }
            for (uint i = 0; i < updatedBuyOrders.length; i++) {
                if (i == updatedBuyOrders.length - 1) {
                    buyOrders.push(updatedBuyOrders[i]);
                } else {
                    buyOrders[i] = updatedBuyOrders[i];
                }
            }
            return updatedBuyOrders;
        } else {
            return buyOrders;
        }
    }

    function placeAsk(uint _powerUnits) public returns (Order[] memory) {
        uint remaining_units;
        if (buyOrders.length == 0) remaining_units = _powerUnits;
        if (buyOrders.length > 0) {
            for (uint s = 0; s < buyOrders.length; s++) {
                if (buyOrders[s].completed == true) continue;
                if (userAskPrice[msg.sender] <= buyOrders[s].price) {
                    if (_powerUnits >= buyOrders[s].powerUnits) {
                        remaining_units = _powerUnits - buyOrders[s].powerUnits;
                        if (remaining_units == 0) {
                            sellOrders.push(
                                Order({
                                    powerUnits: _powerUnits,
                                    user: msg.sender,
                                    price: userAskPrice[msg.sender],
                                    completed: true,
                                    isSessionClosed: false,
                                    closedPrice: 0,
                                    sessionId: sessionId
                                })
                            );
                        } else {
                            _powerUnits = remaining_units;
                            sellOrders.push(
                                Order({
                                    powerUnits: buyOrders[s].powerUnits,
                                    user: msg.sender,
                                    price: userAskPrice[msg.sender],
                                    completed: true,
                                    isSessionClosed: false,
                                    closedPrice: 0,
                                    sessionId: sessionId
                                })
                            );
                        }
                        buyOrders[s].price = userAskPrice[msg.sender];
                        buyOrders[s].completed = true;
                    } else {
                        remaining_units = buyOrders[s].powerUnits - _powerUnits;
                        buyOrders[s].powerUnits = remaining_units;
                    }
                } else {
                    break;
                }
            }
        }

        if (sellOrders.length == 0) {
            sellOrders.push(
                Order({
                    powerUnits: _powerUnits,
                    user: msg.sender,
                    price: userAskPrice[msg.sender],
                    completed: false,
                    isSessionClosed: false,
                    closedPrice: 0,
                    sessionId: sessionId
                })
            );
            return sellOrders;
        } else if (remaining_units > 0) {
            uint updatedLength = sellOrders.length + 1;
            Order[] memory updatedSellOrders = new Order[](updatedLength);
            for (uint k = 0; k < sellOrders.length; k++) {
                updatedSellOrders[k] = sellOrders[k];
            }
            for (uint i = 0; i < updatedSellOrders.length; i++) {
                if (userAskPrice[msg.sender] < updatedSellOrders[i].price) {
                    for (uint j = updatedSellOrders.length - 1; j > i; j--) {
                        updatedSellOrders[j] = updatedSellOrders[j - 1];
                    }
                    updatedSellOrders[i] = Order({
                        powerUnits: _powerUnits,
                        user: msg.sender,
                        price: userAskPrice[msg.sender],
                        completed: false,
                        isSessionClosed: false,
                        closedPrice: 0,
                        sessionId: sessionId
                    });
                    break;
                } else {
                    if (i == updatedSellOrders.length - 1) {
                        updatedSellOrders[i] = Order({
                            powerUnits: _powerUnits,
                            user: msg.sender,
                            price: userAskPrice[msg.sender],
                            completed: false,
                            isSessionClosed: false,
                            closedPrice: 0,
                            sessionId: sessionId
                        });
                    }
                }
            }
            for (uint i = 0; i < updatedSellOrders.length; i++) {
                if (i == updatedSellOrders.length - 1) {
                    sellOrders.push(updatedSellOrders[i]);
                } else {
                    sellOrders[i] = updatedSellOrders[i];
                }
            }
            return updatedSellOrders;
        } else {
            return sellOrders;
        }
    }

    function closeCurrentAuction() public {
        // group all orders closed in this auction (group by sessionId)
        // find market price of all orders closed.
        // first close - take the price of the highest quantity seller in grid
        // all open orders closed by market price.
        uint totalBuyOrderPowerUnits;
        uint totalBuyOrderPrice;
        uint totalSellOrderPowerUnits;
        uint totalSellOrderPrice;
        for (uint i = 0; i < buyOrders.length; i++) {
            if (
                buyOrders[i].completed == true &&
                buyOrders[i].sessionId == sessionId
            ) {
                totalBuyOrderPowerUnits += buyOrders[i].powerUnits;
                totalBuyOrderPrice +=
                    buyOrders[i].powerUnits *
                    buyOrders[i].price;
            }
        }
        for (uint j = 0; j < sellOrders.length; j++) {
            if (
                sellOrders[j].completed == true &&
                sellOrders[j].sessionId == sessionId
            ) {
                totalSellOrderPowerUnits += sellOrders[j].powerUnits;
                totalSellOrderPrice +=
                    sellOrders[j].powerUnits *
                    sellOrders[j].price;
            }
        }
        uint marketBuyPrice = totalBuyOrderPrice / totalBuyOrderPowerUnits;
        uint marketSellPrice = totalSellOrderPrice / totalSellOrderPowerUnits;
        for (uint i = 0; i < buyOrders.length; i++) {
            if (
                buyOrders[i].completed == false &&
                buyOrders[i].sessionId == sessionId
            ) {
                buyOrders[i].price = marketBuyPrice;
            }
            buyOrders[i].isSessionClosed = true;
            buyOrders[i].closedPrice = marketBuyPrice;
        }
        for (uint j = 0; j < sellOrders.length; j++) {
            if (
                sellOrders[j].completed == false &&
                sellOrders[j].sessionId == sessionId
            ) {
                sellOrders[j].price = marketSellPrice;
            }
            sellOrders[j].isSessionClosed = true;
            sellOrders[j].closedPrice = marketSellPrice;
        }
    }
}
