import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";

import type { ERC20 } from "../../types/ERC20";
import type { ERC20__factory } from "../../types/factories/ERC20__factory";

export async function deployERC20Fixture(): Promise<{ erc20: ERC20; signers: SignerWithAddress[] }> {
  const signers: SignerWithAddress[] = await ethers.getSigners();

  const erc20Factory: ERC20__factory = <ERC20__factory>await ethers.getContractFactory("ERC20");
  const erc20: ERC20 = <ERC20>await erc20Factory.deploy(ethers.utils.parseEther("10"));
  await erc20.deployed();

  return { erc20, signers };
}
