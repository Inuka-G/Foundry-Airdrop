// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.26;
import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {AxionToken} from "src/AxionToken.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    AxionToken token;
    MerkleAirdrop airdrop;
    bytes32 public ROOT =
        0xbb0a36f36bc2fe4b0d5d8bb6c59609e15d886fa55aceb1f1e67a0ba594b29a6f;
    bytes32 public proofOne =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proofTwo =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];
    uint256 public AMOUNT_TO_SEND = 25 * 1e18;
    uint256 public AMOUNT_TO_MINT = AMOUNT_TO_SEND * 4;
    address user;
    address gasPayer;
    uint256 userPrivKey;

    function setUp() public {
        // using scripts to deploy the contract
        DeployMerkleAirdrop deploy = new DeployMerkleAirdrop();
        (airdrop, token) = deploy.run();

        // manual way of deploying the contract
        // token = new AxionToken();
        // airdrop = new MerkleAirdrop(ROOT, token);
        // token.mint(token.owner(), AMOUNT_TO_MINT);
        // token.transfer(address(airdrop), AMOUNT_TO_SEND);
        (user, userPrivKey) = makeAddrAndKey("inukaG");
        gasPayer = makeAddr("gasPayer");
        console.log(user);
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_SEND);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_SEND, PROOF, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        console.log(
            "startingBalance------,endingBalance---",
            startingBalance,
            endingBalance
        );
    }
}
