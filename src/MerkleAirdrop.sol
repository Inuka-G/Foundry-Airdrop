// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    error MerkleAirdrop__invalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    event Claim(address account, uint256 amount);
    address[] private claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airDropToken;
    mapping(address => bool) private s_isClaimed;

    constructor(bytes32 merkleRoot, IERC20 airDropToken) {
        i_airDropToken = airDropToken;
        i_merkleRoot = merkleRoot;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        if (s_isClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__invalidProof();
        }
        s_isClaimed[account] = true;
        emit Claim(account, amount);
        i_airDropToken.safeTransfer(account, amount);
    }
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }
    function getAirdropToken() external view returns (IERC20) {
        return i_airDropToken;
    }
}
