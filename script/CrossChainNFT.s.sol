    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.19;

    import "forge-std/Script.sol";
    import "./Helper.sol";
    import {XNFT} from "../src/XNFT.sol";
    import {DestinationMinter} from "../src/DestinationMinter.sol";
    import {SourceMinter} from "../src/SourceMinter.sol";
    import {EncodeExtraArgs} from "../src/utils/EncodeExtraArgs.sol";

    //forge script ./script/CrossChainNFT.s.sol:XNFT -vvv --broadcast --rpc-url ethereumSepolia

    contract DeployDestination is Script, Helper {
        function run(SupportedNetworks destination) external {
            uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
            vm.startBroadcast(senderPrivateKey);

            (address router, address link,, uint64 destinationChainId) = getConfigFromNetwork(destination);

            XNFT myNFT = new XNFT(router, link, destinationChainId);

            console.log("MyNFT deployed on ", networks[destination], "with address: ", address(myNFT));

            DestinationMinter destinationMinter = new DestinationMinter(router, address(myNFT));

            console.log(
                "DestinationMinter deployed on ", networks[destination], "with address: ", address(destinationMinter)
            );

            myNFT.transferOwnership(address(destinationMinter));
            address minter = myNFT.owner();

            console.log("Minter role granted to: ", minter);

            vm.stopBroadcast();
        }
    }

    contract DeploySource is Script, Helper {
        function run(SupportedNetworks source) external {
            uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
            vm.startBroadcast(senderPrivateKey);

            (address router, address link,,) = getConfigFromNetwork(source);

            SourceMinter sourceMinter = new SourceMinter(router, link);

            console.log("SourceMinter deployed on ", networks[source], "with address: ", address(sourceMinter));

            vm.stopBroadcast();
        }
    }

    contract Mint is Script, Helper {
        function run(
            address payable sourceMinterAddress,
            SupportedNetworks destination,
            address destinationMinterAddress,
            SourceMinter.PayFeesIn payFeesIn
        ) external {
            uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
            vm.startBroadcast(senderPrivateKey);

            (,,, uint64 destinationChainId) = getConfigFromNetwork(destination);

            SourceMinter(sourceMinterAddress).mint(destinationChainId, destinationMinterAddress, payFeesIn);

            vm.stopBroadcast();
        }
    }
