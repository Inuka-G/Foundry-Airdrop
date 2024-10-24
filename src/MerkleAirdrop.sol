// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;
    error MerkleAirdrop__invalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__invalidSignature();
    event Claim(address account, uint256 amount);
    address[] private claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airDropToken;
    mapping(address => bool) private s_isClaimed;
    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirDropClaim(address account,uint256 amount)");
    struct AirDropClaim {
        address account;
        uint256 amount;
    }

    constructor(
        bytes32 merkleRoot,
        IERC20 airDropToken
    ) EIP712("MerkleAirdrop", "1") {
        i_airDropToken = airDropToken;
        i_merkleRoot = merkleRoot;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (s_isClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        if (
            !_isValidSignature(
                account,
                getMessageHash(account, amount),
                v,
                r,
                s
            )
        ) {
            revert MerkleAirdrop__invalidSignature();
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

    function getMessageHash(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirDropClaim({account: account, amount: amount})
                    )
                )
            );
    }

    function _isValidSignature(
        address account,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        (address actualSigner, , ) = ECDSA.tryRecover(digest, v, r, s);
        return account == actualSigner;
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airDropToken;
    }
}
