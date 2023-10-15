// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    constructor() ERC20("Wrapped ETH", "WETH") {}

    event LogAddressBalance(uint256 _balance);

    function depositWETH() public payable {
        _mint(msg.sender, msg.value);
        //透過event 顯示餘額
        emit LogAddressBalance(address(this).balance);
    }

    fallback() external payable {
        depositWETH();
    }

    receive() external payable {}

    function withdraw(uint256 _amount) external payable {
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance");
        _burn(msg.sender, _amount);
        //要將錢還給該帳戶
        (bool success,) = msg.sender.call{value: _amount}("");
        require(success, "fail to unwrap");
    }
}
