const { getNamedAccounts, deployments, network } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    const RPS = await deploy("RPS", {
        from: deployer,
        args: [],
        log: true,
    })

    // if (process.env.ETHERSCAN_API_KEY) {
    //     await verify(RPS.address)
    // }
}
