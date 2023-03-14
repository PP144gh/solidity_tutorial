pragma solidity >=0.5.0 <0.6.0;

import "./zombieattack.sol";
import "./erc721.sol";



/// @title A contract for erc721 tokens
/// @author PP144
/// @notice For now, this contract just deals with ownership and transfer of erc721 tokens.
contract ZombieOwnership is ZombieAttack, ERC721 {

 /// @notice stuff
  /// @param  describe parameters
  /// @return explain return
  /// @dev E.g. Compliant with OpenZeppelin's implementation of the ERC721 spec draft

/*


Note that the ERC721 spec has 2 different ways to transfer tokens:

function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

and

function approve(address _approved, uint256 _tokenId) external payable;

function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

The first way is the token's owner calls transferFrom with his address as the _from parameter, the address he wants to transfer to as the _to parameter, and the _tokenId of the token he wants to transfer.

The second way is the token's owner first calls approve with the address he wants to transfer to, and the _tokenID . The contract then stores who is approved to take a token, usually in a mapping (uint256 => address). Then, when the owner or the approved address calls transferFrom, the contract checks if that msg.sender is the owner or is approved by the owner to take the token, and if so it transfers the token to him.

*/

  mapping (uint => address) zombieApprovals; 



  function balanceOf(address _owner) external view returns (uint256) {
    // 1. Return the number of zombies `_owner` has here
    return ownerZombieCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    // 2. Return the owner of `_tokenId` here
    return zombieToOwner[_tokenId];

  }

  
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
    // 2. Replace with SafeMath's `sub`
    ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
    zombieToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }
  
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
    // 2. Add the require statement here
      require (zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender); //check that address that is calling the function is the owner of zombie or is approved

    // 3. Call _transfer
      _transfer(_from, _to, _tokenId);
  }



  // 1. Add function modifier here
  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
    // 2. Define function here
    zombieApprovals[_tokenId] = _approved;
    emit Approval(msg.sender, _approved, _tokenId);
  }





/* COMMENTING THE CODE
The standard in the Solidity community is to use a format called natspec, which looks like this:

/// @title A contract for basic math operations
/// @author H4XF13LD MORRIS 💯💯😎💯💯
/// @notice For now, this contract just adds a multiply function
contract Math {
  /// @notice Multiplies 2 numbers together
  /// @param x the first uint.
  /// @param y the second uint.
  /// @return z the product of (x * y)
  /// @dev This function does not currently check for overflows
  function multiply(uint x, uint y) returns (uint z) {
    // This is just a normal comment, and won't get picked up by natspec
    z = x * y;
  }
}
@title and @author are straightforward.

@notice explains to a user what the contract / function does. @dev is for explaining extra details to developers.

@param and @return are for describing what each parameter and return value of a function are for.

Note that you don't always have to use all of these tags for every function — all tags are optional. But at the very least, leave a @dev note explaining what each function does.





*/




}