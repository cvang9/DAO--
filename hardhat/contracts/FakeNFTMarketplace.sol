// SPDX License-Identifier: MIT
pragma solidity ^0.8.0;

contract FakeNFTMarketPlace {

   mapping( uint256 => address) public token;   

   uint public nftPrice = 0.1 ether;

   function purchase( uint _tokenId ) external payable {
        require( msg.value == nftPrice, "NFT COST IS 0.1 ETH" );
        token[_tokenId] = msg.sender;
   }

   function available( uint _tokenId) external view returns(bool){
    if( token[_tokenId] == address(0))
    {
        return true;
    }
    return false;
   }
   function getPrice()  external  view returns(uint)
   {
    return nftPrice;
   }

}