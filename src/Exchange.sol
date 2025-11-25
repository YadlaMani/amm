// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public tokenaddress;

    constructor(address _token) ERC20("LP Token", "LPT") {
        require(_token != address(0), "Invalid token");
        tokenaddress = _token;
    }

    // current token reserve
    function getReserve() public view returns (uint256) {
        return ERC20(tokenaddress).balanceOf(address(this));
    }

    // add liquidity using msg.value ETH + tokens
    function addLiquidity(uint256 _amount) public payable returns (uint256) {
        uint256 tokenReserve = getReserve();
        uint256 ethBalance = address(this).balance;
        ERC20 token = ERC20(tokenaddress);
        uint256 lpToMint;

        // first provider
        if (tokenReserve == 0) {
            token.transferFrom(msg.sender, address(this), _amount);
            lpToMint = ethBalance; // mint equal to ETH added
            _mint(msg.sender, lpToMint);
            return lpToMint;
        }

        uint256 ethReserve = ethBalance - msg.value;
        uint256 requiredTokens = (msg.value * tokenReserve) / ethReserve;
        require(_amount >= requiredTokens, "Insufficient tokens");

        token.transferFrom(msg.sender, address(this), requiredTokens);
        lpToMint = (totalSupply() * msg.value) / ethReserve;
        _mint(msg.sender, lpToMint);

        return lpToMint;
    }

    // burn LP tokens and return proportional ETH + tokens
    function removeLiquidity(uint256 _lp) public returns (uint256, uint256) {
        require(_lp > 0, "Invalid amount");

        uint256 ethReserve = address(this).balance;
        uint256 totalLP = totalSupply();

        uint256 ethOut = (ethReserve * _lp) / totalLP;
        uint256 tokenOut = (getReserve() * _lp) / totalLP;

        _burn(msg.sender, _lp);
        payable(msg.sender).transfer(ethOut);
        ERC20(tokenaddress).transfer(msg.sender, tokenOut);

        return (ethOut, tokenOut);
    }

    // constant product output amount with 1% fee
    function getOutputAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "Bad reserves");

        uint256 amtWithFee = inputAmount * 99;
        uint256 num = amtWithFee * outputReserve;
        uint256 den = (inputReserve * 100) + amtWithFee;

        return num / den;
    }

    // swap ETH -> Token
    function ethToTokenSwap(uint256 _minToken) public payable {
        uint256 tokenReserve = getReserve();
        uint256 tokensOut = getOutputAmount(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );
        require(tokensOut >= _minToken, "Slippage");

        ERC20(tokenaddress).transfer(msg.sender, tokensOut);
    }

    // swap Token -> ETH
    function tokenToEthSwap(uint256 _tokensSold, uint256 _minEth) public {
        uint256 tokenReserve = getReserve();
        uint256 ethOut = getOutputAmount(
            _tokensSold,
            tokenReserve,
            address(this).balance
        );
        require(ethOut >= _minEth, "Slippage");

        ERC20(tokenaddress).transferFrom(msg.sender, address(this), _tokensSold);
        payable(msg.sender).transfer(ethOut);
    }
}
