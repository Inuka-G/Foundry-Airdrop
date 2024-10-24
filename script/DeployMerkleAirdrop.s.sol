// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;
import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {AxionToken} from "src/AxionToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public ROOT =
        0xbb0a36f36bc2fe4b0d5d8bb6c59609e15d886fa55aceb1f1e67a0ba594b29a6f;
    uint256 public AMOUNT_TO_SEND = 25 * 1e18;

    function run() public returns (MerkleAirdrop, AxionToken) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns (MerkleAirdrop, AxionToken) {
        vm.startBroadcast();
        AxionToken token = new AxionToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(ROOT, IERC20(address(token)));
        token.mint(token.owner(), AMOUNT_TO_SEND * 4);
        token.transfer(address(airdrop), AMOUNT_TO_SEND);
        vm.stopBroadcast();
        return (airdrop, token);
    }
}
