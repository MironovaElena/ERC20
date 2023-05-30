// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/ERC20.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testERC20 is ERC20 {

    // ERC20 erc20;
    address acc0;
    address acc1;

    uint initialTotalSupply = 100e18;


    constructor() ERC20(initialTotalSupply) {} 

    // 'beforeAll' runs before all other tests
    // More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0); 
        acc1 = TestsAccounts.getAccount(1);
    }

    // Test if owner is set correctly
    function testOwner() public {
        // account at zero index (account-0) is default account, so current owner should be acc0
        Assert.equal(owner, acc0, 'owner should be acc0');
    }

    function checkInitialTotalSupply() public  {
        Assert.equal(totalSupply, initialTotalSupply, 'total supply must be 100');
    }
    
    function checkInitialBalance() public {
        Assert.equal(balanceOf[acc0], initialTotalSupply, 'total supply must be 100');
    }
     function checkInitialName() public {
        Assert.equal(name,"ELENA MIRONOVA",'name of owner must be Elena Mironova');
    }
    function checkInitialSymbol() public {
        Assert.equal(symbol,"ELM", 'symbol of owner must be Elena Mironova');
    }
    function checkInitialDecimals() public {
        Assert.equal(decimals, 18,  'number of decimals must be 18');
    }
    
    function chekBurn () public {
        uint senderBalanceBefore =  balanceOf[acc0];
        uint totalSupplyBefore = totalSupply;
        burn(initialTotalSupply);
        Assert.equal(balanceOf[acc0],initialTotalSupply - senderBalanceBefore,'error');
        Assert.equal(totalSupply,initialTotalSupply - totalSupplyBefore,'error');
    }
    function checkMint () public {
     uint ownerBalanceBefore = balanceOf[acc0];
     uint totalSupplyBefore = totalSupply;
     mint(initialTotalSupply);
     Assert.equal(balanceOf[acc0],initialTotalSupply + ownerBalanceBefore,'error');
     Assert.equal(totalSupply,initialTotalSupply + totalSupplyBefore,'error');

    }
    function checkTransfer () public {
      uint senderBalanceBefore = balanceOf[acc0];
      uint recipientBalanceBefore = balanceOf[acc1];
      uint totalSupplyBefore = totalSupply;
      Assert.equal(transfer(acc1, initialTotalSupply),true,'error');
      Assert.equal(balanceOf[acc0],senderBalanceBefore - initialTotalSupply,'error1');
      Assert.equal(balanceOf[acc1],recipientBalanceBefore + initialTotalSupply ,'error2');
      Assert.equal(totalSupply,  totalSupplyBefore,'error3');

    }
    function checkApprove() public {
      Assert.equal(approve(acc1,initialTotalSupply),true,'no');
      Assert.equal(allowance[acc0][acc1],initialTotalSupply,'no');
     
    }
    function checkBlackList () public {
        blackList(acc0,true);
        Assert.equal(blackListed[acc0],true,'are on the blackList');
    }
}
    
 
 


        