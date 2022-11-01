// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IFakeNFTMarketPlace {
    function getPrice() external view returns(uint);

    function purchase( uint _tokenId) external payable;

    function available( uint _tokenId) external view returns(bool);
}

interface ICryptoDevs {

    function balanceOf( address owner) external view returns(uint);

     function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);
        
}
contract CryptoDevDAO is Ownable{

    struct proposal{

        uint deadline;

        uint yeoVotes;

        uint neoVotes;

        uint tokenId;

        bool executed;

        mapping(uint => bool ) voters;

    }

    mapping( uint => proposal) public proposals;
    uint public numProposals;

    IFakeNFTMarketPlace nftMarketplace;
    ICryptoDevs cryptoDevsNFT;

    constructor( address mp, address cdNFT) payable {

      nftMarketplace = IFakeNFTMarketPlace(mp);
      cryptoDevsNFT = ICryptoDevs(cdNFT);
    }

    modifier nftHolderOnly(){
        require( cryptoDevsNFT.balanceOf(msg.sender) > 0, "YOU ARE NOT A DAO MEMBER");
        _;
    }

    modifier activeProposals( uint pIndex) {
        require( proposals[pIndex].deadline > block.timestamp);
        _;
    }

    modifier inactiveProposalOnly(uint256 proposalIndex) {
    require(
        proposals[proposalIndex].deadline <= block.timestamp,
        "DEADLINE_NOT_EXCEEDED"
    );
    require(
        proposals[proposalIndex].executed == false,
        "PROPOSAL_ALREADY_EXECUTED"
    );
    _;
}

    function createPropsal( uint _tokenId) external nftHolderOnly() returns(uint){

        require( nftMarketplace.available(_tokenId) ,"NFT IS NOT AVAILABLE");
        proposal storage n_proposal = proposals[numProposals];
        n_proposal.tokenId = _tokenId;
        n_proposal.deadline = block.timestamp + 5 minutes;

        numProposals++;
        return numProposals-1;

    }
    enum Vote{
        Yeo,
        Neo
    }

    function voteOnProposal( uint proposalInd , Vote v) external activeProposals( proposalInd){
        proposal storage p = proposals[proposalInd];
        uint numVotes = 0;
        uint noOfNft = cryptoDevsNFT.balanceOf(msg.sender);
        for( uint i=0; i<noOfNft; i++)
        {
            uint tokId = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender,i);
            if( p.voters[tokId] == false){
                numVotes++;
                p.voters[tokId] == true;
            }
            require(numVotes > 0, "ALREADY_VOTED");
            if( v == Vote.Yeo){
                p.yeoVotes += numVotes;
            }
            else{
                p.neoVotes += numVotes;
            }

        }
    }

    function executeProposal( uint pInd) external nftHolderOnly inactiveProposalOnly(pInd) {
        proposal storage p = proposals[pInd];
      
        if( p.yeoVotes > p.neoVotes ){
            uint nftprice = nftMarketplace.getPrice();
            require( address(this).balance >= nftprice ,"Insuffficient FUNDS");
            nftMarketplace.purchase{value:nftprice}(p.tokenId);
        }
        p.executed = true;
    }
    function withdrawEther() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
    }

   receive() external payable {}

   fallback() external payable {}

}