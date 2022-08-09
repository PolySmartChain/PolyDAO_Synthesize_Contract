// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;


interface IPloyDaoPRC20 {
    function mint(uint256 value_, uint256 lockTime_ , uint256 releaseTime_ , uint256 tgePercent_ ,address to_) external;
}