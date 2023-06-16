import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { expect } from "chai";
import { ethers } from "hardhat";
import { off } from "process";

import { ERC20__factory } from "../../types/factories/ERC20__factory";
import type { Signers } from "../types";
import { deployERC20Fixture } from "./erc20.fixture";

describe("deployERC20", function () {
  describe("erc20deploy", function () {
    it("should properly set name, symbol, decimals", async function () {
      const { erc20, signers } = await loadFixture(deployERC20Fixture);
      expect(await erc20.name()).to.eq("ELENA MIRONOVA"); // Проверяем правильность установки имени
      expect(await erc20.symbol()).to.eq("ELM");  // Проверяем правильность установки символа
      expect(await erc20.decimals()).to.eq(18);   // Проверяем правильность установки количества десятичных знаков
      expect(await erc20.owner()).to.eq(signers[0].address);  // Проверяем, что владельцем является первый аккаунт
      const amount = ethers.utils.parseEther("10");  // Проверяем правильность установки общего количества токенов
      expect(await erc20.totalSupply()).to.eq(amount);
      expect(await erc20.balanceOf(signers[0].address)).to.eq(amount);// Проверяем правильность установки баланса у первого аккаунта
    });
  });
  describe("should check write methods", function () {
    it("should check transfer", async function () {
      const { erc20, signers } = await loadFixture(deployERC20Fixture);
      const amount = ethers.utils.parseEther("1");
      const [sender, receiver] = signers;
      expect(await erc20.transfer(receiver.address, amount))  // Проверяем функцию transfer
        .to.emit(erc20, "Transfer")
        .withArgs(sender.address, receiver.address, amount)
        .changeTokenBalances(erc20, [signers[0].address, signers[1].address], [amount.mul(-1), amount]);
    });
    it("should check transferFrom", async function () {
      const { erc20, signers } = await loadFixture(deployERC20Fixture);
      const amount = ethers.utils.parseEther("1");
      const [sender, receiver] = signers;
      expect(await erc20.approve(receiver.address, amount))  // Проверяем функцию transferFrom
        .to.emit(erc20, "Approval")
        .withArgs(sender.address, receiver.address, amount);
      expect(await erc20.allowance(sender.address, receiver.address)).to.eq(amount);
      expect(await erc20.connect(receiver).transferFrom(sender.address, receiver.address, amount))
        .to.emit(erc20, "Transfer")
        .withArgs(sender.address, receiver.address, amount)
        .changeTokenBalances(erc20, [signers[0].address, signers[1].address], [amount.mul(-1), amount]);
    });
    it("should check mint", async function () {
      const { erc20, signers } = await loadFixture(deployERC20Fixture);
      const amount = ethers.utils.parseEther("10");
      const [sender, receiver] = signers;
      const totalSupply = await erc20.totalSupply();
      expect(await erc20.mint(amount))   // Проверяем функцию mint
        .to.emit(erc20, "Transfer")
        .withArgs(ethers.constants.AddressZero, sender.address, amount)
        .changeTokenBalance(erc20, sender.address, amount);
      expect(await erc20.totalSupply()).to.eq(amount.add(totalSupply));
      //   expect(await erc20.connect(receiver).transferFrom(sender.address, receiver.address, amount))
      //     .to.emit(erc20, "Transfer")
      //     .withArgs(sender.address, receiver.address, amount)
      //     .changeTokenBalances(erc20, [signers[0].address, signers[1].address], [amount.mul(-1), amount]);
    });
    it("should check burn", async function () {
      const { erc20, signers } = await loadFixture(deployERC20Fixture);
      const amount = ethers.utils.parseEther("10");
      const [sender, receiver] = signers;
      const totalSupply = await erc20.totalSupply();
      expect(await erc20.burn(amount))   // Проверяем функцию burn
        .to.emit(erc20, "Transfer")
        .withArgs(sender.address, ethers.constants.AddressZero, amount)
        .changeTokenBalance(erc20, sender.address, amount.mul(-1));
      expect(await erc20.totalSupply()).to.eq(totalSupply.sub(amount));
    });
    it("should check blackList", async function () {
      const { erc20, signers } = await loadFixture(deployERC20Fixture);
      await erc20.blackList(signers[1].address, true);   // Проверяем функцию blackList
      expect(await erc20.blackListed(signers[1].address)).to.eq(true);
      await erc20.blackList(signers[1].address, false);
      expect(await erc20.blackListed(signers[1].address)).to.eq(false);
    });
     // Проверяем, что transfer с нулевым количеством вызывает откат
    it("should revert transfer with zero amount", async function () {
      const { erc20, signers } = await loadFixture(deployERC20Fixture);
      const [sender, receiver] = signers;
      await expect(erc20.transfer(receiver.address, 0)).to.be.revertedWith("amount and address should not be zero");
    });
     // Проверяем, что transfer с нулевым адресом вызывает откат
    it("should revert transfer with zero address", async function () {
      const { erc20, signers } = await loadFixture(deployERC20Fixture);
      const amount = ethers.utils.parseEther("10");
      const [sender] = signers;
    //   await expect(erc20.transfer(ethers.constants.AddressZero, amount)).to.be.revertedWith("Recipient address cannot be zero");
      await expect(erc20.transfer(ethers.constants.AddressZero, amount)).to.be.revertedWith("amount and address should not be zero");
    });

    it("should revert transferFrom with zero amount", async function () {
        const { erc20, signers } = await loadFixture(deployERC20Fixture);
        const amount = ethers.utils.parseEther("10");
        const [sender, receiver] = signers;
        await erc20.approve(receiver.address,amount)
        await expect(erc20.connect(receiver).transferFrom(sender.address,receiver.address, 0))
        .to.be.revertedWith("amount and address should not be zero");
      });
       
      it("should revert transferFrom with zero address", async function () {
        const { erc20, signers } = await loadFixture(deployERC20Fixture);
        const amount = ethers.utils.parseEther("10");
        const [sender, receiver] = signers;
        await erc20.approve(receiver.address,amount)
        await expect(erc20.connect(receiver).transferFrom(sender.address,ethers.constants.AddressZero, amount))
        .to.be.revertedWith("amount and address should not be zero");
      });
      it("should check if the transaction is blacklisted", async function () {
        const { erc20, signers } = await loadFixture(deployERC20Fixture);
        await erc20.blackList(signers[1].address, true);  
        expect(await erc20. connect(signers[1]).blackListed(signers[1].address)).to.revertedWithoutReason();
      });
      it("should check if the transaction is blacklisted", async function () {
        const { erc20, signers } = await loadFixture(deployERC20Fixture);
        const [sender, receiver] = signers;
        const amount = ethers.utils.parseEther("10");
        await erc20.blackList(signers[0].address, true);
        await erc20.approve(receiver.address, amount)  
        await expect (erc20.connect(receiver).transferFrom(signers[0].address, receiver.address, amount))
        .to.revertedWithoutReason();
      });
  });
});




