pragma solidity >= 0.8.11;

import '../app/node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract StarNotary is ERC721{



    struct Star {
        string name;
    }

    mapping (uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;

    constructor() ERC721("StarNotary", "SNT") { }

    function createStar(string memory _name, uint256 _tokenId) public {
        Star memory newStar = Star(_name);
        tokenIdToStarInfo[_tokenId] = newStar;
        _mint(msg.sender, _tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "can't sell what you don't own");
        starsForSale[_tokenId] = _price;
    }

    function _make_payable(address x) internal pure returns (address payable){
        return payable(x);
    }

    function buyStar(uint256 _tokenId) public payable{
        require(starsForSale[_tokenId] > 0, "Star not for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "need more Ether!");
        transferFrom(ownerAddress, msg.sender, _tokenId);
        address payable ownerAddressPayable = _make_payable(ownerAddress);
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost){
            address payable payableChangeAddress = payable(msg.sender);
            payableChangeAddress.transfer(msg.value - starCost);
        }
    }
    function lookUpTokenIdToStarInfo(uint _tokenId) public view returns (string memory){
        // returns Star saved by ID in tokenIdToStarInfo
            return tokenIdToStarInfo[_tokenId].name;
    }

    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        address firstParty = ownerOf(_tokenId1);
        address secondParty = ownerOf(_tokenId2);

        require (msg.sender == firstParty || secondParty == msg.sender
        , "you don't own either star");

        transferFrom(firstParty, secondParty, _tokenId1);
        transferFrom(secondParty, firstParty, _tokenId2);
    }

    function transferStar(address _to1, uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId));
        transferFrom(msg.sender, _to1, _tokenId);
    }
}