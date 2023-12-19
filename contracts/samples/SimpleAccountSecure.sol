// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

/* solhint-disable avoid-low-level-calls */
/* solhint-disable no-inline-assembly */
/* solhint-disable reason-string */

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

import "../core/BaseAccount.sol";
import "./callback/TokenCallbackHandler.sol";

/**
  * minimal account.
  *  this is sample minimal account.
  *  has execute, eth handling methods
  *  has a single signer that can send requests through the entryPoint.
  */
contract SimpleAccount is BaseAccount, TokenCallbackHandler, UUPSUpgradeable, Initializable {
    
    address public owner;
    IEntryPoint private immutable _entryPoint;

    constructor(IEntryPoint  _entryPoint){
          _entryPoint = _entryPoint;
    }

    function intializer(address owner) public intializer{
      owner = owner;
    }
    function _requireFromEntryPointOrOwner()internal view{
      if(msg.sender != owner || msg.sender != _entryPoint) revert NotOwnerOrEntryPoint();

    }
    function execute(address dest,uint value, bytes calldata func) external{
      //verify caller is either owner or the entrypoint contract
      _requireFromEntryPointOrOwner();
      _call(dest,value,func);
    }
    function addDeposit(uint amount) external payable{
      _requireFromEntryPointOrOwner();
      _addDeposit(amount);
    }
    function _addDeposit(uint amount) internal{
      entryPoint().addDeposit{value: amount}(address(this));
    }
    function _call(address dest,uint value, bytes calldata func) external{
      (bool success, bytes memory result) = target.call{value: value}(data);
              if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }

    }

    function _validateSignature(UserOperation calldata userOp, bytes32 userOpHash) external {
      bytes hash = userOpHash.toEthSignedMessageHash();
      if(owner != hash.recover(userOperation.signature)){
        return SIG_VALIDATION_FAILED;
        return 0;
      }
    }
}

