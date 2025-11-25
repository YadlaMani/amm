//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Token} from "../src/Token.sol";
import {Exchange} from "../src/Exchange.sol";
import {Test, console} from "forge-std/Test.sol";
contract ExchangeTest is Test{
    Exchange exchange;
    Token token;
    address user=address(0xA1);
    function setUp() public{
        token=new Token();
        exchange=new Exchange(address(token));
        
        vm.deal(user,1000 ether);
        token.transfer(user,500_000 ether);
    }
    function testInitialLiquidity()public{
        vm.startPrank(user);
        token.approve(address(exchange),1000 ether);
        uint256 lptokens=exchange.addLiquidity{value:100 ether}(1000 ether);
        console.log("LPTokens minted:",lptokens/1e18);
        assertEq(lptokens,100 ether,"LPTokens should be equal to ETH added");
        assertEq(exchange.getReserve(),1000 ether,"Token reserve should be 1000 tokens");
        assertEq(exchange.balanceOf(user),lptokens,"User should have all the LPTokens");
        vm.stopPrank();
    }
    function testAddLiquidity()public{
        vm.startPrank(user);
        token.approve(address(exchange),2000 ether);
        exchange.addLiquidity{value:100 ether}(1000 ether);
        //add more liquidity
        uint256 lptokens2=exchange.addLiquidity{value:50 ether}(600 ether);
        //Lp minted=totalSupply*(msg.value/ethReserve)
        //totalSupply=100 ether
        //ethReserve (before second deposit)=100 ether
        //second deposit=50 ether
        //msg.value=50 ether
        //lpminted=100*(50/100)=50 ether
        // requiredTokens = (msg.value * tokenReserve) / ethReserve
        //               = (50 * 1000) / 100
        //               = 500 tokens
        assertEq(lptokens2,50 ether,"LPTokens minted should be 50 ether");
        assertEq(exchange.getReserve(),1500 ether,"Token reserve should be 1500 tokens");
        assertEq(exchange.balanceOf(user),150 ether,"User should have 150 LPTokens");
        vm.stopPrank();
    }
    function testRemoveLiquidity()public{
        vm.startPrank(user);
        token.approve(address(exchange),2000 ether);
        exchange.addLiquidity{value:100 ether}(1000 ether);
        //remove liquidity
        (uint256 ethOut,uint256 tokenOut)=exchange.removeLiquidity(50 ether);
        //ethOut=(ethReserve*lp)/totalLP
        //ethOut=(100*50)/100=50 ether
        //tokenOut=(tokenReserve*lp)/totalLP
        //tokenOut=(1000*50)/100=500 ether
        assertEq(ethOut,50 ether,"ETH out should be 50 ether");
        assertEq(tokenOut,500 ether,"Token out should be 500 ether");
        assertEq(exchange.getReserve(),500 ether,"Token reserve should be 500 tokens");
        assertEq(exchange.balanceOf(user),50 ether,"User should have 50 LPTokens");
        vm.stopPrank();
    }
    function testEthToTokenSwap()public{
        vm.startPrank(user);
        token.approve(address(exchange),2000 ether);
        exchange.addLiquidity{value:100}(1000 ether);
        //Swap 10 eth for tokens
        //recievedTokens=(outputReserve*input)/(input+inputReserve)
        // (1000*(0.99*10))/(100+(0.99*10))=90.09 ether
        uint256 userInitialTokenBalance=token.balanceOf(user);
        exchange.ethToTokenSwap{value:10 ether}(1);
        uint256 userFinalTokenBalance=token.balanceOf(user);
        assertGt(userFinalTokenBalance-userInitialTokenBalance,81 ether,"User should receive at least 81 tokens");
        vm.stopPrank();
        
        

    }
    function testTokenToEthSwap()public{
        vm.startPrank(user);
        token.approve(address(exchange),2000 ether);
        exchange.addLiquidity{value:100}(1000 ether);
        //Swap 100 tokens for eth
        //recievedEth=(outputReserve*input)/(input+inputReserve)
        //(100*(0.99*100))/(1000+(0.99*100))=8.99 ether
        uint256 userInitialEthBalance=user.balance;
        exchange.tokenToEthSwap(100 ether,1);
        uint256 userFinalEthBalance=user.balance;
        assertGt(userFinalEthBalance - userInitialEthBalance,8,"User should receive at least 7 eth");
        vm.stopPrank();

    }


}