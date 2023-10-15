// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import { WETH } from "../src/WrappedEther.sol";

contract WETHTest is Test {
    WETH public weth;
    address public Eva = makeAddr('Eva');
    address public Amber = makeAddr('Amber');

    function setUp() public {
        weth = new WETH();
    }
    //測試 deposit 
    function testDeposit() public {
        //1.創建一個 msg.sender 給予 2 ether
        //2.將 2 ether 轉到 weth 合約中
        //3.檢查 weth 合約中的 totalSupply() 會等於 weth 合約中的 balanceOf(Eva)
        vm.prank(Eva);
        vm.deal(Eva, 2e18);
        (bool success,) = address(weth).call{value:2e18}(abi.encodeWithSignature("depositWETH()")); 
        require(success, "fail to deposit");    
        assertEq(weth.totalSupply(), weth.balanceOf(Eva));
    }

    function testWithdraw() public {
        //1.創建一個 msg.sender(Eva) 給予 6 ether
        //2.進行 deposit 將 6 ether 轉到 weth 合約中
        //3.執行 withdraw 將 2 ether 從 weth 合約中轉到 msg.sender(Eva)
        //4.檢查 weth 合約中的 totalSupply() 會等於 4 ether
        //5.檢查 weth 合約中的 balanceOf(Eva) 會等於 4 ether
        vm.startPrank(Eva);
        vm.deal(Eva, 6e18);
        (bool success,)= address(weth).call{value:6e18}(abi.encodeWithSignature("depositWETH()"));
        require(success, "fail to deposit");
        weth.withdraw(2e18);
        
        assertEq(weth.totalSupply(), 4e18);
        assertEq(weth.balanceOf(Eva), 4e18);
        vm.stopPrank();
    }

    function testApprove() public{
        assertTrue(weth.approve(Eva, 2 ether));
        assertEq(weth.allowance(address(this), Eva), 2 ether);
    }

    function testTransfer() public{
        //1.執行 deposit
        testDeposit();
        //2.prank Eva
        vm.startPrank(Eva);
        //3.執行transfer 將 1 ether 從 Eva 轉到 Amber
        weth.transfer(Amber, 0.5 ether);
        //4.檢查 Eva 的餘額會等於 2 ether
        assertEq(weth.balanceOf(Eva), 1.5 ether);
        //5.檢查 Amber 的餘額會等於 1 ether
        assertEq(weth.balanceOf(Amber), 0.5 ether);
        vm.stopPrank();
    }
    function testTransferFrom() public{
        testDeposit();
        vm.prank(Eva);
        //執行transferFrom前，先執行approve
        weth.approve(address(this), 1 ether);
        vm.prank(address(this));
        assertEq(weth.allowance(Eva, address(this)), 1 ether);
        //執行transferFrom
        assertTrue(weth.transferFrom(Eva, Amber, 0.3 ether));
        assertEq(weth.allowance(Eva, address(this)), 0.7 ether);
        assertEq(weth.balanceOf(Eva), 2 ether-0.3 ether);
        assertEq(weth.balanceOf(Amber), 0.3 ether);

    }
}
