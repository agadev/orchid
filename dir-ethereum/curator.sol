/* Orchid - WebRTC P2P VPN Market (on Ethereum)
 * Copyright (C) 2017-2019  The Orchid Authors
*/

/* GNU Affero General Public License, Version 3 {{{ */
/*
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.

 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */


pragma solidity 0.5.13;

contract OrchidCurator {
    address private owner_;

    constructor(address owner) public {
        owner_ = owner;
    }

    mapping (address => bool) private curated_;

    function list(address target, bool good) external {
        require(msg.sender == owner_);
        curated_[target] = good;
    }

    function good(address target, bytes calldata) external view returns (bool) {
        return curated_[target];
    }
}

contract OrchidUnified {
    function good(address target, bytes calldata argument) external pure returns (bool) {
        require(argument.length == 20);
        address allowed;
        bytes memory copy = argument;
        assembly { allowed := mload(add(copy,20)) }
        return target == allowed;
    }
}

contract OrchidUntrusted {
    function good(address, bytes calldata) external pure returns (bool) {
        return true;
    }
}
