// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NEWERC721 is AccessControl, ERC721 {
    using Counters for Counters.Counter;
    bytes32 public constant SUPPORT_ROLE = keccak256("SUPPORT_ROLE");
    mapping(uint => mapping(address => bool)) private _whiteList;
    mapping(uint => uint) private _saleTokensLimit; //Max tokens in a sale
    mapping(uint => uint) private _tokenPrice; // wrt sale
    mapping(uint => uint) private _saleTokensMinted; // Tokens minted in each sale
    uint private _tokensLimit; // total all eg 1000K
    uint private _tokensAssigned; // For all sales minted
    Counters.Counter private _token;
    
    constructor(string memory _name, string memory _symbol, uint tokensLimit_, address _supportAddres ) ERC721(_name, _symbol) {
        _tokensLimit = tokensLimit_;
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
            address allow = _allowed[i];
        _whiteList[_saleId][allow] = true;
        }
    }

    function setSalesTokenLimit(uint _saleId, uint _NFTQaunity) external onlyRole(SUPPORT_ROLE) {
        require(_saleId < 3, "Not Valid Sale");
        require(_NFTQaunity > 0, "Not Valid Quantity");
        require(_tokensAssigned + _NFTQaunity <= _tokensLimit, "Total Tokens Exceeded");
        _tokensAssigned += _NFTQaunity;
        _saleTokensLimit[_saleId] += _NFTQaunity;
    }

    function saleTokensPrice(uint[] calldata _tokenPrices) external onlyRole(SUPPORT_ROLE) {
        require(_tokenPrices.length != 0 && _tokenPrices.length < 4, "No Prices Provided");
        for(uint i; i < _tokenPrices.length; i++ ) {
        _tokenPrice[i] = _tokenPrices[i] ;
        }
    }
    function availbleTokens(uint _saleId) external view returns(uint) {
        require(_saleId < 3, "Not Valid Sale");
        return _saleTokensLimit[_saleId] - _saleTokensMinted[_saleId];

    }
    
    function buyTokens(uint _saleId, uint _NFTs) external payable {
        require(_whiteList[_saleId][msg.sender] == true, "YOu are not authorized");
        require(_saleTokensMinted[_saleId] + _NFTs <= _saleTokensLimit[_saleId] , "Tokens Minted");
        uint price = _tokenPrice[_saleId];
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