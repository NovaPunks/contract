// SPDX-License-Identifier: MIT
/*
 __  __   ___   __ __  ___     ____  __ __ __  __ __ __  __ 
 ||\ ||  // \\  || || // \\    || \\ || || ||\ || || // (( \
 ||\\|| ((   )) \\ // ||=||    ||_// || || ||\\|| ||<<   \\ 
 || \||  \\_//   \V/  || ||    ||    \\_// || \|| || \\ \_))
                                                            
*/
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NovaPunks is  Ownable, ERC721Enumerable {

    uint public constant MAX_SPUNKS = 2077;
    bool public hasSaleStarted = false;
    string private _baseTokenURI;

    constructor(string memory baseTokenURI) ERC721("NovaPunks","NVPUNKS")  {
        setBaseURI(baseTokenURI);
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 _tokenId) override public view returns (string memory) {
        return string(abi.encodePacked(_baseTokenURI, Strings.toString(_tokenId)));
    }

    function tokensOfOwner(address _owner) external view returns(uint256[] memory ) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }

    function calculatePrice() public view returns (uint256) {
        require(hasSaleStarted == true, "Sale hasn't started");
        require(totalSupply() < MAX_SPUNKS, "Sale has already ended");

        uint currentSupply = totalSupply();
        if (currentSupply >= 777) {
            return 5000000000000000;
        } else {
            return 0;
        }
    }

   function getNovaPunk(uint256 numNovaPunks) public payable {
        require(totalSupply() < MAX_SPUNKS, "Sale has already ended");
        require(numNovaPunks > 0 && numNovaPunks <= 10, "You can mint minimum 1, maximum 10 NovaPunks");
        require(totalSupply()+numNovaPunks <= MAX_SPUNKS, "Exceeds MAX_SPUNKS");
        require(msg.value >= calculatePrice() * numNovaPunks, "Ether value sent is below the price");
        require(tx.origin == msg.sender, "Contracts not allowed");

        if(calculatePrice() == 0){
            require(balanceOf(_msgSender()) == 0,"You have already Claimed Free");
            numNovaPunks = 1;
        }
        for (uint i = 0; i < numNovaPunks; i++) {
            uint mintIndex = totalSupply();
            _safeMint(msg.sender, mintIndex);
        }
    }

    function gotNovaPunk( address[] memory addresses) public onlyOwner {
                for(uint i=0;i<addresses.length;i++){
                    uint mintIndex = totalSupply();
                    _safeMint(addresses[i], mintIndex);
                }
    }

    function startSale() public onlyOwner {
        hasSaleStarted = true;
    }

    function pauseSale() public onlyOwner {
        hasSaleStarted = false;
    }

    function withdrawAll() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

   function punksTokenBalance(address tokenContractAddress) private view returns(uint) {
       ERC721 token = ERC721(tokenContractAddress);
       return token.balanceOf(msg.sender);
   }

}
