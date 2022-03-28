// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NEWERC721 is AccessControl, ERC721 {
    using Counters for Counters.Counter;
    bytes32 private constant SUPPORT_ROLE = keccak256("SUPPORT_ROLE");
    mapping(uint => mapping(address => bool)) public _whiteList;
    mapping(uint => uint) private _saleTokensLimit; //Max tokens in each sale
    mapping(uint => uint) private _tokenPrice; // Every sale has different price
    mapping(uint => uint) private _saleTokensMinted; // Tokens minted in each sale
    uint private immutable _tokensQuantity; // total Tokens (Total Supply)
    Counters.Counter private _token;
    
    constructor(string memory _name, string memory _symbol, uint tokensQuantity_, address _supportAddres ) ERC721(_name, _symbol) {
        _tokensQuantity = tokensQuantity_;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(SUPPORT_ROLE, _supportAddres);

    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, ERC721) returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function updateWhiteList(uint[] calldata _saleIds, address[] calldata _allowed) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_saleIds.length == _allowed.length, "Not Valid Input");
        for(uint i; i < _saleIds.length; i++ ) {
            uint _saleId = _saleIds[i];
            address _allow = _allowed[i];
        _whiteList[_saleId][_allow] = true;
        }
    }

    function setSalesTokenLimit(uint _sale0Limit, uint _sale1Limit, uint _sale2Limit ) external onlyRole(SUPPORT_ROLE) {// 3 para
        uint _totalTokens = _sale0Limit + _sale1Limit + _sale2Limit;
        require(_totalTokens == _tokensQuantity, "Tokens Limit Issue");
        _saleTokensLimit[0] = _sale0Limit; // need +=? No
        _saleTokensLimit[1] = _sale1Limit;
        _saleTokensLimit[2] = _sale2Limit;
    }

    function saleTokensPrice(uint _sale0Price, uint _sale1Price, uint _sale2Price) external onlyRole(SUPPORT_ROLE) { //3 para
        _tokenPrice[0] = _sale0Price;
        _tokenPrice[1] = _sale1Price;
        _tokenPrice[2] = _sale2Price;
        
    }
    function availbleTokens(uint _saleId) external view returns(uint) {
        require(_saleId < 3, "No Tokens against saleId");
        uint limit = _saleTokensLimit[_saleId];
        uint minted = _saleTokensMinted[_saleId];
        return limit - minted;

    }
    
    function buyTokens(uint _saleId, uint _NFTs) external payable {
        require(_whiteList[_saleId][msg.sender] == true, "Not Authorized to purchase");
        require(_NFTs > 0, "Token Quanity needed");
        require(_saleTokensMinted[_saleId] + _NFTs <= _saleTokensLimit[_saleId] , "Tokens Quantity Exceeded");
        uint price = _tokenPrice[_saleId];
        require(price > 0, "Token Price is not assgned"); //Price can be zero ?
        uint tokensPrice = price * _NFTs;
        require(msg.value == tokensPrice, " The price is not enough");
        _saleTokensMinted[_saleId] += _NFTs;
        for(uint i; i < _NFTs; i++) {
            uint tokenMint = _token.current();
            _token.increment();
            _mint(_msgSender(), tokenMint);
        }   
    }
    function ethWithdraw() external payable onlyRole(DEFAULT_ADMIN_ROLE) {
        uint bal = address(this).balance;
        require(bal > 0, "No Balance in Contract");
        payable(_msgSender()).transfer(bal);
    }
}