const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("SplittableProperty", () => {
  let SplittableProperty, nft, deployer
  beforeEach(async ()=>{
    [deployer] = await ethers.getSigners()
    SplittableProperty = await ethers.getContractFactory("SplittableProperty")
    nft = await SplittableProperty.deploy("root NFT")
    await nft.deployed()
  })
  it("Should give the first NFT to the deployer", async function () {
    expect(await nft.balanceOf(deployer.address)).eq(1)
    expect(await nft.ownerOf(0)).to.equal(deployer.address)
  });
  it("Should create several NFTs out of one", async function () {
    await nft.separate(0, ['m1', 'm2', 'm3'])
    expect(await nft.balanceOf(deployer.address)).eq(3)
    expect(await nft.ownerOf(0)).to.equal(nft.address)
    expect(await nft.ownerOf(1)).to.equal(deployer.address)
    expect(await nft.ownerOf(2)).to.equal(deployer.address)
    expect(await nft.ownerOf(3)).to.equal(deployer.address)
  });
  it("Should create several NFTs out of onea d revert the process", async function () {
    await nft.separate(0, ['m1', 'm2', 'm3'])
    await nft.rebuild(0)
    expect(await nft.balanceOf(deployer.address)).eq(1)
    expect(await nft.ownerOf(0)).to.equal(deployer.address)
  });
  it("Should create a new NFTs out of several unrelated ones", async function () {
    await nft.separate(0, ['m1', 'm2', 'm3'])
    await nft.combine([1, 2], "m4")
    expect(await nft.balanceOf(deployer.address)).eq(2)
    expect(await nft.ownerOf(0)).to.equal(nft.address)
    expect(await nft.ownerOf(1)).to.equal(nft.address)
    expect(await nft.ownerOf(2)).to.equal(nft.address)
    expect(await nft.ownerOf(3)).to.equal(deployer.address)
    expect(await nft.ownerOf(4)).to.equal(deployer.address)
  });
  it("Should create a new NFTs out of several unrelated ones and then undo the operation", async function () {
    await nft.separate(0, ['m1', 'm2', 'm3'])
    await nft.combine([1, 2], "m4")
    await nft.decombine(4)
    expect(await nft.balanceOf(deployer.address)).eq(3)
    expect(await nft.ownerOf(0)).to.equal(nft.address)
    expect(await nft.ownerOf(1)).to.equal(deployer.address)
    expect(await nft.ownerOf(2)).to.equal(deployer.address)
    expect(await nft.ownerOf(3)).to.equal(deployer.address)
    expect(await nft.ownerOf(4)).to.equal(nft.address)
  });
});
