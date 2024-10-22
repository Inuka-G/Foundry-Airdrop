// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AxionToken is ERC20, Ownable {
    constructor() ERC20("Axion", "AXN") Ownable(msg.sender) {}

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
