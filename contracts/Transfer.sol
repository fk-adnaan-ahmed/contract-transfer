// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/extension/Ownable.sol";
import "@thirdweb-dev/contracts/lib/CurrencyTransferLib.sol";

contract Transfer is Ownable {

    struct Entry {
        uint _amount;
        address _address;
    }

    constructor() {
        _setupOwner(msg.sender);
    }

    Entry[] private _entryList;

    function _canSetOwner() internal view virtual override returns (bool) {
        return true;
    }

    function getEntryList() public view returns (address[] memory, uint[] memory) {
        address[] memory addresses = new address[](_entryList.length);
        uint[] memory amounts = new uint[](_entryList.length);

        for (uint i = 0; i < _entryList.length; i++) {
            Entry storage entry = _entryList[i];
            addresses[i] = entry._address;
            amounts[i] = entry._amount;
        }

        return (addresses, amounts);
    }

    function addToQueue(uint _amount) public {
        require(msg.sender != owner(), "cannot be called by the owner");
        addToQueue(msg.sender, _amount);
    }

    function addToQueue(address _address, uint _amount) public {
        _entryList.push(Entry(_amount, _address));
    }

    function removeFromQueue(uint index) public payable {
        require(msg.sender == owner(), "only owner can remove from the queue");
        require(index <= _entryList.length, "index out of the bounds");

        Entry storage entry = _entryList[index];
        require(msg.value >= entry._amount, "transferred value is less than the amount");
//        CurrencyTransferLib.transferCurrency(CurrencyTransferLib.NATIVE_TOKEN, msg.sender, entry._address, entry._amount);

        address addr = entry._address;
        payable(addr).transfer(entry._amount);

        for (uint i = index; i < _entryList.length - 1; i++) {
            _entryList[i] = _entryList[i + 1];
        }
        _entryList.pop();
    }

}