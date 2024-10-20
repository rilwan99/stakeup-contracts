  * Protocol & Gas Settings
  * Security & Executor Configuration

Version: Endpoint V2 Docs

On this page

# OApp Security Stack and Executor Configuration

LayerZero defines a pathway as any configuration where any two points (OApp on
Chain A and OApp on Chain B), have each called the
[`setPeer`](/v2/developers/evm/oapp/overview#setting-peers) function and
enabled messaging to and from each contract instance.

Every LayerZero Endpoint can be used to send and receive messages. Because of
that, **each Endpoint has a separate Send and Receive Configuration** , which
an OApp can configure per target Endpoint (i.e., sending to that target,
receiving from that target).

![Protocol V2
Light](/assets/images/dvn_overview_light-c0dc62c4255d9f400a9ead48434b4265.svg#gh-
light-mode-only) ![Protocol V2
Dark](/assets/images/dvn_overview_dark-514e43593b8d7a910d7d851fa9272365.svg#gh-
dark-mode-only)

For a configuration to be considered correct, **the Send Library
configurations on Chain A must match Chain B's Receive Library configurations
for filtering messages.**

info

In the diagram above, the **Source OApp** has added the DVN's source chain
address to the Send Library configuration.

The **Destination OApp** has added the DVN's destination chain address to the
Receive Library configuration.

The DVN can now read from the source chain, and deliver the message to the
destination chain.

## Checking Default Configuration​

For commonly travelled pathways, LayerZero provides a **default pathway
configuration**. If you provide no configuration prior to setting peers, the
protocol will fallback to the default configuration.

The default configuration varies from pathway to pathway, based on the unique
properties of each chain, and which decentralized verifier networks or
executors listen for those networks.

A default pathway configuration, at the time of writing, will always have one
of the following set within `SendULN302.sol` and `ReceiveUlN302.sol` as a
**Preset Configuration** :

| Security Stack| Executor  
---|---|---  
**Default Send and Receive A**|  requiredDVNs: [ Google Cloud, LayerZero Labs
]| LayerZero Labs  
**Default Send and Receive B**|  requiredDVNs: [ Polyhedra, LayerZero Labs ]|
LayerZero Labs  
**Default Send and Receive C**|  requiredDVNs: [ Dead DVN, LayerZero Labs ]|
LayerZero Labs  
  

info

What is a **Dead DVN**?

Since LayerZero allows for anyone to permissionlessly run DVNs, the network
may occassionally add new chain Endpoints before the default providers (Google
Cloud or Polyhedra) support every possible pathway to and from that chain.

A default configuration with a **Dead DVN** will require you to either
configure an available DVN provider for that Send or Receive pathway, or run
your own DVN if no other security providers exist, before messages can safely
be delivered to and from that chain.

  

Other default configuration settings, like source and destination block
confirmations, will vary per chain pathway based on recommendations provided
by each chain.

To read the default configuration, you can call the LayerZero Endpoint's
`getConfig` method to return the default send and receive configuration for
that target Endpoint.

    
    
    /**  
     * @notice This function is used to retrieve configuration data for a specific OApp using a LayerZero Endpoint on the same chain.  
     *  
     * @param _oapp Address of the OApp for which the configuration is being retrieved.  
     * @param _lib Address of the library (send or receive) used by the OApp at the specified endpoint.  
     * @param _eid Endpoint ID (EID) of the target endpoint on the other side of the pathway. The EID filters  
     * the configurations specifically for the target endpoint, which is crucial for ensuring that messages are  
     * sent and received correctly and securely between the configured endpoints (pathways).  
     * @param _configType Type of configuration to retrieve (e.g., executor configuration, ULN configuration).  
     * This parameter specifies the format and data of the returned configuration.  
     *  
     * @return config Returns the configuration data as bytes, which can be decoded into the respective  
     * configuration structure as per the requested _configType.  
     */  
    function getConfig(  
        address _oapp,  
        address _lib,  
        uint32 _eid,  
        uint32 _configType  
    ) external view returns (bytes memory config);  
    

tip

The [**create-lz-oapp**](/v2/developers/evm/create-lz-oapp/start#configuring-
layerzero-contracts) npx package also provides a faster CLI command to return
every default configuration for each pathway in your project!

    
    
    npx hardhat lz:oapp:config:get:default  
    

  

The example below uses
[`defaultAbiCoder`](https://docs.ethers.org/v5/api/utils/abi/coder/) from the
ethers.js (`^5.7.2`) library to decode the bytes arrays returned by an OApp
using the Ethereum Mainnet Endpoint:

    
    
    import * as ethers from 'ethers';  
      
    // Define provider  
    const provider = new ethers.providers.JsonRpcProvider('YOUR_RPC_PROVIDER_HERE');  
      
    // Define the smart contract address and ABI  
    const ethereumLzEndpointAddress = '0x1a44076050125825900e736c501f859c50fE728c';  
    const ethereumLzEndpointABI = [  
      'function getConfig(address _oapp, address _lib, uint32 _eid, uint32 _configType) external view returns (bytes memory config)',  
    ];  
      
    // Create a contract instance  
    const contract = new ethers.Contract(ethereumLzEndpointAddress, ethereumLzEndpointABI, provider);  
      
    // Define the addresses and parameters  
    const oappAddress = '0xEB6671c152C88E76fdAaBC804Bf973e3270f4c78';  
    const sendLibAddress = '0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1';  
    const receiveLibAddress = '0xc02Ab410f0734EFa3F14628780e6e695156024C2';  
    const remoteEid = 30102; // Example target endpoint ID, Binance Smart Chain  
    const executorConfigType = 1; // 1 for executor  
    const ulnConfigType = 2; // 2 for UlnConfig  
      
    async function getConfigAndDecode() {  
      try {  
        // Fetch and decode for sendLib (both Executor and ULN Config)  
        const sendExecutorConfigBytes = await contract.getConfig(  
          oappAddress,  
          sendLibAddress,  
          remoteEid,  
          executorConfigType,  
        );  
        const executorConfigAbi = ['tuple(uint32 maxMessageSize, address executorAddress)'];  
        const executorConfigArray = ethers.utils.defaultAbiCoder.decode(  
          executorConfigAbi,  
          sendExecutorConfigBytes,  
        );  
        console.log('Send Library Executor Config:', executorConfigArray);  
      
        const sendUlnConfigBytes = await contract.getConfig(  
          oappAddress,  
          sendLibAddress,  
          remoteEid,  
          ulnConfigType,  
        );  
        const ulnConfigStructType = [  
          'tuple(uint64 confirmations, uint8 requiredDVNCount, uint8 optionalDVNCount, uint8 optionalDVNThreshold, address[] requiredDVNs, address[] optionalDVNs)',  
        ];  
        const sendUlnConfigArray = ethers.utils.defaultAbiCoder.decode(  
          ulnConfigStructType,  
          sendUlnConfigBytes,  
        );  
        console.log('Send Library ULN Config:', sendUlnConfigArray);  
      
        // Fetch and decode for receiveLib (only ULN Config)  
        const receiveUlnConfigBytes = await contract.getConfig(  
          oappAddress,  
          receiveLibAddress,  
          remoteEid,  
          ulnConfigType,  
        );  
        const receiveUlnConfigArray = ethers.utils.defaultAbiCoder.decode(  
          ulnConfigStructType,  
          receiveUlnConfigBytes,  
        );  
        console.log('Receive Library ULN Config:', receiveUlnConfigArray);  
      } catch (error) {  
        console.error('Error fetching or decoding config:', error);  
      }  
    }  
      
    // Execute the function  
    getConfigAndDecode();  
    

The `getConfig` function will return you an array of values from both the
SendLib and ReceiveLib's configurations.

The logs below show the output from the Ethereum Endpoint for `SendLib302.sol`
when sending messages to Binance Smart Chain:

    
    
    Send Library Executor Config:  
    executorAddress: "0x173272739Bd7Aa6e4e214714048a9fE699453059"  
    maxMessageSize: 10000  
      
    Send Library ULN Config:  
    confirmations: {_hex: '0x0f', _isBigNumber: true} // this is just big number 15  
    optionalDVNCount: 0  
    optionalDVNThreshold: 0  
    optionalDVNs: Array(0)  
    requiredDVNCount: 2  
    requiredDVNs: Array(2)  
      0: "0x589dEDbD617e0CBcB916A9223F4d1300c294236b"  // LZ Ethereum DVN Address  
      1: "0xD56e4eAb23cb81f43168F9F45211Eb027b9aC7cc"  // Google Cloud Ethereum DVN Address  
    

And when the Ethereum Endpoint uses `ReceiveLib302.sol` to receive messages
from Binance Smart Chain:

    
    
    Receive Library ULN Config  
      
    confirmations: {_hex: '0x0f', _isBigNumber: true} // this is just big number 15  
    optionalDVNCount: 0  
    optionalDVNThreshold: 0  
    optionalDVNs: Array(0)  
    requiredDVNCount: 2  
    requiredDVNs: Array(2)  
      0: "0x589dEDbD617e0CBcB916A9223F4d1300c294236b" // LZ Ethereum DVN Address  
      1: "0xD56e4eAb23cb81f43168F9F45211Eb027b9aC7cc" // Google Cloud Ethereum DVN Address  
    

info

The important takeaway is that every LayerZero Endpoint can be used to send
and receive messages. Because of that, **each Endpoint has a separate Send and
Receive Configuration** , which an OApp can configure by the target
destination Endpoint.

In the above example, the default Send Library configurations control how
messages emit from the **Ethereum Endpoint** to the BNB Endpoint.

The default Receive Library configurations control how the **Ethereum
Endpoint** filters received messages from the BNB Endpoint.

For a configuration to be considered correct, **the Send Library
configurations on Chain A must match Chain B's Receive Library configurations
for filtering messages.**

**Challenge:** Confirm that the BNB Endpoint's Send Library ULN configuration
matches the Ethereum Endpoint's Receive Library ULN Configuration using the
methods above.

## Custom Configuration​

To use non-default protocol settings, the
[delegate](/v2/developers/evm/oapp/overview#setting-delegates) (should always
be OApp owner) should call `setSendLibrary`, `setReceiveLibrary`, and
`setConfig` from the OApp's Endpoint.

When setting your OApp's config, ensure that the Send Configuration for the
OApp on the sending chain (Chain A) matches the Receive Configuration for the
OApp on the receiving chain (Chain B).

Both configurations must be appropriately matched and set across the relevant
chains to ensure successful communication and data transfer.

info

The `setDelegate` function in LayerZero's OApp allows the contract owner to
appoint a delegate who can manage configurations for both the Executor and
ULN. This delegate, once set, has the authority to modify configurations on
behalf of the OApp owner. We **strongly** recommend you always make sure owner
and delegate are the same address.

### Setting Send and Receive Libraries​

Before changing any OApp Send or Receive configurations, you should first
`setSendLibrary` and `setReceiveLibrary` to the intended library. At the time
of writing, the latest library for Endpoint V2 is `SendULN302.sol` and
`ReceiveULN302.sol`:

  * ethers
  * Foundry

    
    
    const {ethers} = require('ethers');  
      
    // Replace with your actual values  
    const YOUR_OAPP_ADDRESS = '0xYourOAppAddress';  
    const YOUR_SEND_LIB_ADDRESS = '0xYourSendLibAddress';  
    const YOUR_RECEIVE_LIB_ADDRESS = '0xYourReceiveLibAddress';  
    const YOUR_ENDPOINT_CONTRACT_ADDRESS = '0xYourEndpointContractAddress';  
    const YOUR_RPC_URL = 'YOUR_RPC_URL';  
    const YOUR_PRIVATE_KEY = 'YOUR_PRIVATE_KEY';  
      
    // Define the remote EID  
    const remoteEid = 30101; // Replace with your actual EID  
      
    // Set up the provider and signer  
    const provider = new ethers.providers.JsonRpcProvider(YOUR_RPC_URL);  
    const signer = new ethers.Wallet(YOUR_PRIVATE_KEY, provider);  
      
    // Set up the endpoint contract  
    const endpointAbi = [  
      'function setSendLibrary(address oapp, uint32 eid, address sendLib) external',  
      'function setReceiveLibrary(address oapp, uint32 eid, address receiveLib) external',  
    ];  
    const endpointContract = new ethers.Contract(YOUR_ENDPOINT_CONTRACT_ADDRESS, endpointAbi, signer);  
      
    async function setLibraries() {  
      try {  
        // Set the send library  
        const sendTx = await endpointContract.setSendLibrary(  
          YOUR_OAPP_ADDRESS,  
          remoteEid,  
          YOUR_SEND_LIB_ADDRESS,  
        );  
        console.log('Send library transaction sent:', sendTx.hash);  
        await sendTx.wait();  
        console.log('Send library set successfully.');  
      
        // Set the receive library  
        const receiveTx = await endpointContract.setReceiveLibrary(  
          YOUR_OAPP_ADDRESS,  
          remoteEid,  
          YOUR_RECEIVE_LIB_ADDRESS,  
        );  
        console.log('Receive library transaction sent:', receiveTx.hash);  
        await receiveTx.wait();  
        console.log('Receive library set successfully.');  
      } catch (error) {  
        console.error('Transaction failed:', error);  
      }  
    }  
      
    setLibraries();  
    
    
    
    // SPDX-License-Identifier: UNLICENSED  
    pragma solidity ^0.8.22;  
      
    // Forge imports  
    import "forge-std/console.sol";  
    import "forge-std/Script.sol";  
      
    // LayerZero imports  
    import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";  
      
    contract SetLibraries is Script {  
        function run(address _endpoint, address _oapp, uint32 _eid, address _sendLib, address _receiveLib, address _signer) external {  
            // Initialize the endpoint contract  
            ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(_endpoint);  
      
            // Start broadcasting transactions  
            vm.startBroadcast(_signer);  
      
            // Set the send library  
            endpoint.setSendLibrary(_oapp, _eid, _sendLib);  
            console.log("Send library set successfully.");  
      
            // Set the receive library  
            endpoint.setReceiveLibrary(_oapp, _eid, _receiveLib);  
            console.log("Receive library set successfully.");  
      
            // Stop broadcasting transactions  
            vm.stopBroadcast();  
        }  
    }  
    

info

Why do you need to set a `sendLibrary` and `receiveLibrary`?

LayerZero uses [**Appendable Message Libraries**](/v2/home/protocol/message-
library). This means that while existing versions will always be immutable and
available to configure, updates can still be added by deploying new Message
Libraries as separate contracts and having applications manually select the
new version.

If an OApp had **NOT** called `setSendLibrary` or `setReceiveLibrary`, the
LayerZero Endpoint will fallback to the default configuration, which may be
different than the MessageLib you have configured.

Explicitly setting the `sendLibrary` and `receiveLibrary` ensures that your
configurations will apply to the correct library version, and will not
fallback to any new library versions released.

### Setting Send Config​

You will call the same function in the Endpoint to set your `sendConfig` and
`receiveConfig`:

    
    
    /// @dev authenticated by the _oapp  
    function setConfig(  
      address _oapp,  
      address _lib,  
      SetConfigParam[] calldata _params  
    ) external onlyRegistered(_lib) {  
        _assertAuthorized(_oapp);  
      
        IMessageLib(_lib).setConfig(_oapp, _params);  
    }  
    

The `SetConfigParam` struct defines how to set custom parameters for a given
`configType` and the remote chain's `eid` (endpoint ID):

    
    
    struct SetConfigParam {  
        uint32 dstEid;  
        uint32 configType;  
        bytes config;  
    }  
    

The ULN and Executor have separate `config` types, which change how the bytes
array is structured:

    
    
    CONFIG_TYPE_ULN = 2; // Security Stack and block confirmation config  
      
    CONFIG_TYPE_EXECUTOR = 1; // Executor and max message size config  
    

Based on the `configType`, the MessageLib will expect one of the following
structures for the config bytes array:

    
    
    const configTypeUlnStruct =  
      'tuple(uint64 confirmations, uint8 requiredDVNCount, uint8 optionalDVNCount, uint8 optionalDVNThreshold, address[] requiredDVNs, address[] optionalDVNs)';  
      
    const configTypeExecutorStruct = 'tuple(uint32 maxMessageSize, address executorAddress)';  
    

Each `config` is encoded and passed as an ordered bytes array in your
`SetConfigParam` struct.

#### Send Config Type ULN (Security Stack)​

The `SendConfig` describes how messages should be emitted from the source
chain. See [DVN Addresses](/v2/developers/evm/technical-reference/dvn-
addresses) for the list of available DVNs.

Parameter| Type| Description  
---|---|---  
confirmations| `uint64`| The number of block confirmations to wait before a
DVN should listen for the `payloadHash`. This setting can be used to ensure
message finality on chains with frequent block reorganizations.  
requiredDVNCount| `uint8`| The quantity of required DVNs that will be paid to
send a message from the OApp.  
optionalDVNCount| `uint8`| The quantity of optional DVNs that will be paid to
send a message from the OApp.  
optionalDVNThreshold| `uint8`| The minimum number of verifications needed from
optional DVNs. A message is deemed Verifiable if it receives verifications
from at least the number of optional DVNs specified by the
`optionalDVNsThreshold`, plus the required DVNs.  
requiredDVNs| `address[]`| An array of addresses for all required DVNs.  
optionalDVNs| `address[]`| An array of addresses for all optional DVNs.  
  
caution

If you set your block confirmations too low, and a reorg occurs after your
confirmation, it can materially impact your OApp or OFT.

#### Send Config Type Executor​

See [Deployed LZ Endpoints and Addresses](/v2/developers/evm/technical-
reference/deployed-contracts) for every chain's Executor address.

Parameter| Type| Description  
---|---|---  
maxMessageSize| `uint32`| The maximum size of a message that can be sent
cross-chain (number of bytes).  
executor| `address`| The executor implementation to pay fees to for calling
the `lzReceive` function on the destination chain.  
  

  * ethers
  * Foundry

The example below uses ethers.js (`^5.7.2`) library to encode the arrays and
call the Endpoint contract:

    
    
    const {ethers} = require('ethers');  
      
    // Addresses  
    const oappAddress = 'YOUR_OAPP_ADDRESS'; // Replace with your OApp address  
    const sendLibAddress = 'YOUR_SEND_LIB_ADDRESS'; // Replace with your send message library address  
      
    // Configuration  
    const remoteEid = 30101; // Example EID, replace with the actual value  
    const ulnConfig = {  
      confirmations: 99, // Example value, replace with actual  
      requiredDVNCount: 2, // Example value, replace with actual  
      optionalDVNCount: 0, // Example value, replace with actual  
      optionalDVNThreshold: 0, // Example value, replace with actual  
      requiredDVNs: ['0xDvnAddress1', '0xDvnAddress2'], // Replace with actual addresses  
      optionalDVNs: [], // Replace with actual addresses  
    };  
      
    const executorConfig = {  
      maxMessageSize: 10000, // Example value, replace with actual  
      executorAddress: '0xExecutorAddress', // Replace with the actual executor address  
    };  
      
    // Provider and Signer  
    const provider = new ethers.providers.JsonRpcProvider(YOUR_RPC_URL);  
    const signer = new ethers.Wallet(YOUR_PRIVATE_KEY, provider);  
      
    // ABI and Contract  
    const endpointAbi = [  
      'function setConfig(address oappAddress, address sendLibAddress, tuple(uint32 eid, uint32 configType, bytes config)[] setConfigParams) external',  
    ];  
    const endpointContract = new ethers.Contract(YOUR_ENDPOINT_CONTRACT_ADDRESS, endpointAbi, signer);  
      
    // Encode UlnConfig using defaultAbiCoder  
    const configTypeUlnStruct =  
      'tuple(uint64 confirmations, uint8 requiredDVNCount, uint8 optionalDVNCount, uint8 optionalDVNThreshold, address[] requiredDVNs, address[] optionalDVNs)';  
    const encodedUlnConfig = ethers.utils.defaultAbiCoder.encode([configTypeUlnStruct], [ulnConfig]);  
      
    // Encode ExecutorConfig using defaultAbiCoder  
    const configTypeExecutorStruct = 'tuple(uint32 maxMessageSize, address executorAddress)';  
    const encodedExecutorConfig = ethers.utils.defaultAbiCoder.encode(  
      [configTypeExecutorStruct],  
      [executorConfig],  
    );  
      
    // Define the SetConfigParam structs  
    const setConfigParamUln = {  
      eid: remoteEid,  
      configType: 2, // ULN_CONFIG_TYPE  
      config: encodedUlnConfig,  
    };  
      
    const setConfigParamExecutor = {  
      eid: remoteEid,  
      configType: 1, // EXECUTOR_CONFIG_TYPE  
      config: encodedExecutorConfig,  
    };  
      
    // Send the transaction  
    async function sendTransaction() {  
      try {  
        const tx = await endpointContract.setConfig(  
          oappAddress,  
          sendLibAddress,  
          [setConfigParamUln, setConfigParamExecutor], // Array of SetConfigParam structs  
        );  
      
        console.log('Transaction sent:', tx.hash);  
        const receipt = await tx.wait();  
        console.log('Transaction confirmed:', receipt.transactionHash);  
      } catch (error) {  
        console.error('Transaction failed:', error);  
      }  
    }  
      
    sendTransaction();  
    
    
    
    // SPDX-License-Identifier: UNLICENSED  
    pragma solidity ^0.8.22;  
      
    // Forge imports  
    import "forge-std/console.sol";  
    import "forge-std/Script.sol";  
      
    // LayerZero imports  
    import { ExecutorConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";  
    import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";  
    import { OFT } from "@layerzerolabs/oft-evm/contracts/OFT.sol";  
    import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";  
    import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";  
      
    contract SendConfig is Script {  
        uint32 public constant EXECUTOR_CONFIG_TYPE = 1;  
        uint32 public constant ULN_CONFIG_TYPE = 2;  
      
        function run(address contractAddress, uint32 remoteEid, address sendLibraryAddress, address signer, UlnConfig calldata ulnConfig, ExecutorConfig calldata executorConfig) external {  
            OFT myOFT = OFT(contractAddress);  
      
            ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(address(myOFT.endpoint()));  
      
            SetConfigParam[] memory setConfigParams = new SetConfigParam[](2);  
      
            setConfigParams[0] = SetConfigParam({  
                eid: remoteEid,  
                configType: EXECUTOR_CONFIG_TYPE,  
                config: abi.encode(executorConfig)  
            });  
      
            setConfigParams[1] = SetConfigParam({  
                eid: remoteEid,  
                configType: ULN_CONFIG_TYPE,  
                config: abi.encode(ulnConfig)  
            });  
      
            vm.startBroadcast(signer);  
      
            endpoint.setConfig(address(myOFT), sendLibraryAddress, setConfigParams);  
      
            vm.stopBroadcast();  
        }  
    }  
    

### Setting Receive Config​

You will still call the `setConfig` function described above, but because
`ReceiveLib302.sol` only enforces the DVN and block confirmation
configurations, you do not need to set an Executor configuration.

    
    
    CONFIG_TYPE_ULN = 2; // Security Stack and block confirmation config  
    
    
    
    const configTypeUlnStruct =  
      'tuple(uint64 confirmations, uint8 requiredDVNCount, uint8 optionalDVNCount, uint8 optionalDVNThreshold, address[] requiredDVNs, address[] optionalDVNs)';  
    

#### Receive Config Type ULN (Security Stack)​

The `ReceiveConfig` describes how to enforce and filter messages when
receiving packets from the remote chain. See [DVN
Addresses](/v2/developers/evm/technical-reference/dvn-addresses) for the list
of available DVNs.

Parameter| Type| Description  
---|---|---  
confirmations| `uint64`| The minimum number of block confirmations the DVNs
must have waited for their verification to be considered valid.  
requiredDVNCount| `uint8`| The quantity of required DVNs that must verify
before receiving the OApp's message.  
optionalDVNCount| `uint8`| The quantity of optional DVNs that must verify
before receiving the OApp's message.  
optionalDVNThreshold| `uint8`| The minimum number of verifications needed from
optional DVNs. A message is deemed Verifiable if it receives verifications
from at least the number of optional DVNs specified by the
`optionalDVNsThreshold`, plus the required DVNs.  
requiredDVNs| `address[]`| An array of addresses for all required DVNs to
receive verifications from.  
optionalDVNs| `address[]`| An array of addresses for all optional DVNs to
receive verifications from.  
  
caution

If you set your block confirmations too low, and a reorg occurs after your
confirmation, it can materially impact your OApp or OFT.

  

Use the ULN config type and the struct definition to form your configuration
for the call:

  * ethers
  * Foundry

The example below uses ethers.js (`^5.7.2`) library to encode the arrays and
call the Endpoint contract:

    
    
    const {ethers} = require('ethers');  
      
    // Addresses  
    const oappAddress = 'YOUR_OAPP_ADDRESS'; // Replace with your OApp address  
    const receiveLibAddress = 'YOUR_RECEIVE_LIB_ADDRESS'; // Replace with your receive message library address  
      
    // Configuration  
    const remoteEid = 30101; // Example EID, replace with the actual value  
    const ulnConfig = {  
      confirmations: 99, // Example value, replace with actual  
      requiredDVNCount: 2, // Example value, replace with actual  
      optionalDVNCount: 0, // Example value, replace with actual  
      optionalDVNThreshold: 0, // Example value, replace with actual  
      requiredDVNs: ['0xDvnAddress1', '0xDvnAddress2'], // Replace with actual addresses  
      optionalDVNs: [], // Replace with actual addresses  
    };  
      
    // Provider and Signer  
    const provider = new ethers.providers.JsonRpcProvider(YOUR_RPC_URL);  
    const signer = new ethers.Wallet(YOUR_PRIVATE_KEY, provider);  
      
    // ABI and Contract  
    const endpointAbi = [  
      'function setConfig(address oappAddress, address receiveLibAddress, tuple(uint32 eid, uint32 configType, bytes config)[] setConfigParams) external',  
    ];  
    const endpointContract = new ethers.Contract(YOUR_ENDPOINT_CONTRACT_ADDRESS, endpointAbi, signer);  
      
    // Encode UlnConfig using defaultAbiCoder  
    const configTypeUlnStruct =  
      'tuple(uint64 confirmations, uint8 requiredDVNCount, uint8 optionalDVNCount, uint8 optionalDVNThreshold, address[] requiredDVNs, address[] optionalDVNs)';  
    const encodedUlnConfig = ethers.utils.defaultAbiCoder.encode([configTypeUlnStruct], [ulnConfig]);  
      
    // Define the SetConfigParam struct  
    const setConfigParam = {  
      eid: remoteEid,  
      configType: 2, // RECEIVE_CONFIG_TYPE  
      config: encodedUlnConfig,  
    };  
      
    // Send the transaction  
    async function sendTransaction() {  
      try {  
        const tx = await endpointContract.setConfig(  
          oappAddress,  
          receiveLibAddress,  
          [setConfigParam], // This should be an array of SetConfigParam structs  
        );  
      
        console.log('Transaction sent:', tx.hash);  
        const receipt = await tx.wait();  
        console.log('Transaction confirmed:', receipt.transactionHash);  
      } catch (error) {  
        console.error('Transaction failed:', error);  
      }  
    }  
      
    sendTransaction();  
    
    
    
    // SPDX-License-Identifier: UNLICENSED  
    pragma solidity ^0.8.22;  
      
    // Forge imports  
    import "forge-std/console.sol";  
    import "forge-std/Script.sol";  
      
    // LayerZero imports  
    import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";  
    import { OFT } from "@layerzerolabs/oft-evm/contracts/OFT.sol";  
    import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";  
    import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";  
      
    contract ReceiveConfig is Script {  
        uint32 public constant RECEIVE_CONFIG_TYPE = 2;  
      
        function run(address contractAddress, uint32 remoteEid, address receiveLibraryAddress, address signer, UlnConfig calldata ulnConfig) external {  
            OFT myOFT = OFT(contractAddress);  
      
            ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(address(myOFT.endpoint()));  
      
            SetConfigParam[] memory setConfigParams = new SetConfigParam[](1);  
            setConfigParams[0] = SetConfigParam({  
                eid: remoteEid,  
                configType: RECEIVE_CONFIG_TYPE,  
                config: abi.encode(ulnConfig)  
            });  
      
            vm.startBroadcast(signer);  
      
            endpoint.setConfig(address(myOFT), receiveLibraryAddress, setConfigParams);  
      
            vm.stopBroadcast();  
        }  
    }  
    

## Resetting Configurations​

To erase your configuration and fallback to the default configurations, simply
pass null values as your configuration params and call `setConfig` again:

    
    
    // ULN Configuration Reset Params  
    const confirmations = 0;  
    const optionalDVNCount = 0;  
    const requiredDVNCount = 0;  
    const optionalDVNThreshold = 0;  
    const requiredDVNs = [];  
    const optionalDVNs = [];  
      
    const ulnConfigData = {  
      confirmations,  
      requiredDVNCount,  
      optionalDVNCount,  
      optionalDVNThreshold,  
      requiredDVNs,  
      optionalDVNs,  
    };  
      
    const ulnConfigEncoded = ethersV5.utils.defaultAbiCoder.encode(  
      [configTypeUlnStruct],  
      [ulnConfigData],  
    );  
      
    const resetConfigParamUln = {  
      eid: DEST_CHAIN_ENDPOINT_ID, // Replace with the target chain's endpoint ID  
      configType: configTypeUln,  
      config: ulnConfigEncoded,  
    };  
      
    // Executor Configuration Reset Params  
    const maxMessageSize = 0; // Representing no limit on message size  
    const executorAddress = '0x0000000000000000000000000000000000000000'; // Representing no specific executor address  
      
    const configTypeExecutorStruct = 'tuple(uint32 maxMessageSize, address executorAddress)';  
    const executorConfigData = {  
      maxMessageSize,  
      executorAddress,  
    };  
      
    const executorConfigEncoded = ethers.utils.defaultAbiCoder.encode(  
      [executorConfigStructType],  
      [executorConfigData],  
    );  
      
    const resetConfigParamExecutor = {  
      eid: DEST_CHAIN_ENDPOINT_ID, // Replace with the target chain's endpoint ID  
      configType: configTypeExecutor,  
      config: executorConfigEncoded,  
    };  
    

After defining the null values in your config params, call `setConfig`:

    
    
    const messageLibAddresses = ['sendLibAddress', 'receiveLibAddress'];  
      
    let resetTx;  
      
    // Call setConfig on the send and receive lib  
    for (const messagelibAddress of messageLibAddresses) {  
      resetTx = await endpointContract.setConfig(oappAddress, messagelibAddress, [  
        resetConfigParamUln,  
        resetConfigParamExecutor,  
      ]);  
      
      await resetTx.wait();  
    }  
    

## Debugging Configurations​

A **correct** OApp configuration example:

SendUlnConfig (A to B)| ReceiveUlnConfig (B to A)  
---|---  
confirmations: 15| confirmations: 15  
optionalDVNCount: 0| optionalDVNCount: 0  
optionalDVNThreshold: 0| optionalDVNThreshold: 0  
optionalDVNs: Array(0)| optionalDVNs: Array(0)  
requiredDVNCount: 2| requiredDVNCount: 2  
requiredDVNs: Array(DVN1_Address_A, DVN2_Address_A)| requiredDVNs:
Array(DVN1_Address_B, DVN2_Address_B)  
  
tip

The sending OApp's **SendLibConfig** (OApp on Chain A) and the receiving
OApp's **ReceiveLibConfig** (OApp on Chain B) match!

#### Block Confirmation Mismatch​

An example of an **incorrect** OApp configuration:

SendUlnConfig (A to B)| ReceiveUlnConfig (B to A)  
---|---  
**confirmations: 5**| **confirmations: 15**  
optionalDVNCount: 0| optionalDVNCount: 0  
optionalDVNThreshold: 0| optionalDVNThreshold: 0  
optionalDVNs: Array(0)| optionalDVNs: Array(0)  
requiredDVNCount: 2| requiredDVNCount: 2  
requiredDVNs: Array(DVN1, DVN2)| requiredDVNs: Array(DVN1, DVN2)  
  
danger

The above configuration has a **block confirmation mismatch**. The sending
OApp (Chain A) will only wait 5 block confirmations, but the receiving OApp
(Chain B) will not accept any message with less than 15 block confirmations.

Messages will be blocked until either the sending OApp has increased the
outbound block confirmations, or the receiving OApp decreases the inbound
block confirmation threshold.

#### DVN Mismatch​

Another example of an incorrect OApp configuration:

SendUlnConfig (A to B)| ReceiveUlnConfig (B to A)  
---|---  
confirmations: 15| confirmations: 15  
optionalDVNCount: 0| optionalDVNCount: 0  
optionalDVNThreshold: 0| optionalDVNThreshold: 0  
optionalDVNs: Array(0)| optionalDVNs: Array(0)  
**requiredDVNCount: 1**| **requiredDVNCount: 2**  
**requiredDVNs: Array(DVN1)**| **requiredDVNs: Array(DVN1, DVN2)**  
  
danger

The above configuration has a **DVN mismatch**. The sending OApp (Chain A)
only pays DVN 1 to listen and verify the packet, but the receiving OApp (Chain
B) requires both DVN 1 and DVN 2 to mark the packet as verified.

Messages will be blocked until either the sending OApp has added DVN 2's
address on Chain A to the SendUlnConfig, or the receiving OApp removes DVN 2's
address on Chain B from the ReceiveUlnConfig.

#### Dead DVN​

This configuration includes a **Dead DVN** :

SendUlnConfig (A to B)| ReceiveUlnConfig (B to A)  
---|---  
confirmations: 15| confirmations: 15  
optionalDVNCount: 0| optionalDVNCount: 0  
optionalDVNThreshold: 0| optionalDVNThreshold: 0  
optionalDVNs: Array(0)| optionalDVNs: Array(0)  
**requiredDVNCount: 2**| **requiredDVNCount: 2**  
**requiredDVNs: Array(DVN1, DVN2)**| **requiredDVNs: Array(DVN1, DVN_DEAD)**  
  
danger

The above configuration has a **Dead DVN**. Similar to a DVN Mismatch, the
sending OApp (Chain A) pays DVN 1 and DVN 2 to listen and verify the packet,
but the receiving OApp (Chain B) has currently set DVN 1 and a Dead DVN to
mark the packet as verified.

Since a Dead DVN for all practical purposes should be considered a null
address, no verification will ever match the dead address.

Messages will be blocked until the receiving OApp removes or replaces the Dead
DVN from the ReceiveUlnConfig.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/protocol-gas-settings/default-
config.md)

[PreviousOFT Patterns & Extensions](/v2/developers/evm/oft/oft-patterns-
extensions)[NextExecution Gas Options](/v2/developers/evm/protocol-gas-
settings/options)

  * Checking Default Configuration
  * Custom Configuration
    * Setting Send and Receive Libraries
    * Setting Send Config
      * Send Config Type ULN (Security Stack)
      * Send Config Type Executor
    * Setting Receive Config
      * Receive Config Type ULN (Security Stack)
  * Resetting Configurations
  * Debugging Configurations
    * Block Confirmation Mismatch
    * DVN Mismatch
    * Dead DVN



  * LayerZero V2
  * Welcome

Version: Endpoint V2 Docs

On this page

# Explore LayerZero V2

[LayerZero V2](https://layerzero.network/) is an open-source, immutable
messaging protocol designed to facilitate the creation of omnichain,
interoperable applications.

Developers can easily [send arbitrary data](/v2/home/protocol/contract-
standards#oapp), [external function calls](/v2/developers/evm/oapp/message-
design-patterns), and [tokens](/v2/home/protocol/contract-standards#oft) with
omnichain messaging while preserving full autonomy and control over their
application.

LayerZero V2 is currently live on the following [Mainnet and Testnet
Chains](/v2/developers/evm/technical-reference/deployed-contracts).

[![](/img/icons/build.svg)Getting StartedStart building on LayerZero by
sending your first omnichain message.View More ](/v2/developers/evm/getting-
started)

[![](/img/icons/protocol.svg)Supported ChainsDiscover which chains the
LayerZero V2 Endpoint is live on.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Supported SecuritySee which Decentralized Verifier
Networks (DVNs) can be added to secure your omnichain app.View More
](/v2/developers/evm/technical-reference/dvn-addresses)

[![](/img/icons/Ethereum-logo-test.svg)Solidity DevelopersResources to help
you quickly build, launch, and scale your EVM omnichain applications.View More
](/v2/developers/evm/overview)

[![](/img/icons/solanaLogoMark.svg)Solana DevelopersResources to build your
LayerZero applications on the Solana blockchain.View More
](/v2/developers/solana/overview)

  
  

See the Quickstart Guide below for specific guides on every topic related to
building with the LayerZero protocol.

## Quickstart​

Comprehensive developer guides for every step of your omnichain journey.

[![](/img/icons/build.svg)OApp OverviewBuild your first Omnichain Application
(OApp), using the LayerZero Contract Standards.View More
](/v2/developers/evm/oapp/overview)

[![](/img/icons/build.svg)Build an OFTBuild an Omnichain Fungible Token (OFT)
using familiar fungible token standards.View More
](/v2/developers/evm/oft/quickstart)

[![](/img/icons/build.svg)Estimating Gas FeesGenerate a quote of your
omnichain message gas costs before sending.View More
](/v2/developers/evm/protocol-gas-settings/gas-fees)

[![](/img/icons/config.svg)Generating OptionsBuild message options to control
gas settings, nonce ordering, and more.View More
](/v2/developers/evm/protocol-gas-settings/options)

[![](/img/icons/config.svg)Chain EndpointsThe addresses and endpoint IDs for
every supported chain.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Configure OAppConfigure your Security Stack,
Executors, and other application specific settings.View More
](/v2/developers/evm/protocol-gas-settings/default-config)

[![](/img/icons/testing.svg)Track MessagesFollow your omnichain messages using
LayerZero Scan.View More ](/v2/developers/evm/tooling/layerzeroscan)

[![](/img/icons/testing.svg)TroubleshootingFind answers to common questions
and debugging support.View More
](/v2/developers/evm/troubleshooting/debugging-messages)

[![](/img/icons/testing.svg)Endpoint V1 DocsFind legacy support for LayerZero
Endpoint V1 here.View More ](/v1)

## Security​

LayerZero Labs has an absolute commitment to continuously evaluating and
improving protocol security:

  * [Core contracts are immutable](/v2/home/protocol/layerzero-endpoint) and LayerZero Labs will never deploy upgradeable contracts.

  * While application contracts come pre-configured with an optimal default, application owners can opt out of updates by [modifying and locking protocol configurations](/v2/developers/evm/protocol-gas-settings/default-config#custom-configuration).

  * Protocol updates will always be [optional and backward compatible](/v2/home/protocol/message-library).

LayerZero protocol has been thoroughly audited by leading organizations
building decentralized systems. Browse through [past public
audits](https://github.com/LayerZero-Labs/Audits/tree/main/audits) in our
Github.

## More from LayerZero​

### Questions?​

Join the LayerZero community in our [Discord](https://discord-
layerzero.netlify.app/discord) to ask for help, as well as share your feedback
or showcase what you have built with LayerZero!

### Careers​

LayerZero is growing. If you enjoy using our protocol and have a genuine
interest in omnichain design, please check out [our current job
openings](https://layerzero.network/careers).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/intro.md)

[NextV2 Overview](/v2/home/v2-overview)

  * Quickstart
  * Security
  * More from LayerZero
    * Questions?
    * Careers



  * Community Support

On this page

# Community Support

The LayerZero ecosystem is a fast-growing network of developers collaborating
to build a better future across every blockchain network.

  * Find the community on [Discord](https://discord-layerzero.netlify.app/discord).

  * Engage with the [Telegram](https://t.me/joinchat/VcqxYkStIDsyN2Rh) group.

  * Find code on [GitHub](https://github.com/LayerZero-Labs/LayerZero).

## Questions?​

We love to answer questions! Questions help everyone learn together, so please
don't hesitate to ask :)

Our [Discord](https://discord-layerzero.netlify.app/discord) is for any real-
time conversations, from brainstorming to debugging and troubleshooting.
Participants often share interesting articles and other educational content.
For in-depth considerations about important decisions and projects, we suggest
contributing on GitHub. New issues, comments, and pull requests are welcome!

## Feedback​

Your insights and experiences are vital to the continuous improvement of
LayerZero's documentation and protocol. If you have suggestions, questions, or
feedback, we strongly encourage you to share them with us.

If you come across anything in our documentation or protocol that you believe
can be improved or if you have constructive feedback, please don't hesitate to
let us know. Here's how you can do it:

### Leaving Feedback​

If your feedback is related to our documentation:

  1. Depending on the issue, visit either our Documentation Repo or Protocol Repo.

  2. Click on the **Issues** tab and then create a **New Issue**.

  3. Provide a clear and detailed description of your suggestions, questions, or the issues you've encountered. This could include suggestions for additional content, clarifications, or corrections.

Once you've filled out the necessary details, submit the issue.

[NextContribute to Docs](/community/contribute)

  * Questions?
  * Feedback
    * Leaving Feedback



  * LayerZero V2
  * Welcome

Version: Endpoint V2 Docs

On this page

# Explore LayerZero V2

[LayerZero V2](https://layerzero.network/) is an open-source, immutable
messaging protocol designed to facilitate the creation of omnichain,
interoperable applications.

Developers can easily [send arbitrary data](/v2/home/protocol/contract-
standards#oapp), [external function calls](/v2/developers/evm/oapp/message-
design-patterns), and [tokens](/v2/home/protocol/contract-standards#oft) with
omnichain messaging while preserving full autonomy and control over their
application.

LayerZero V2 is currently live on the following [Mainnet and Testnet
Chains](/v2/developers/evm/technical-reference/deployed-contracts).

[![](/img/icons/build.svg)Getting StartedStart building on LayerZero by
sending your first omnichain message.View More ](/v2/developers/evm/getting-
started)

[![](/img/icons/protocol.svg)Supported ChainsDiscover which chains the
LayerZero V2 Endpoint is live on.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Supported SecuritySee which Decentralized Verifier
Networks (DVNs) can be added to secure your omnichain app.View More
](/v2/developers/evm/technical-reference/dvn-addresses)

[![](/img/icons/Ethereum-logo-test.svg)Solidity DevelopersResources to help
you quickly build, launch, and scale your EVM omnichain applications.View More
](/v2/developers/evm/overview)

[![](/img/icons/solanaLogoMark.svg)Solana DevelopersResources to build your
LayerZero applications on the Solana blockchain.View More
](/v2/developers/solana/overview)

  
  

See the Quickstart Guide below for specific guides on every topic related to
building with the LayerZero protocol.

## Quickstart​

Comprehensive developer guides for every step of your omnichain journey.

[![](/img/icons/build.svg)OApp OverviewBuild your first Omnichain Application
(OApp), using the LayerZero Contract Standards.View More
](/v2/developers/evm/oapp/overview)

[![](/img/icons/build.svg)Build an OFTBuild an Omnichain Fungible Token (OFT)
using familiar fungible token standards.View More
](/v2/developers/evm/oft/quickstart)

[![](/img/icons/build.svg)Estimating Gas FeesGenerate a quote of your
omnichain message gas costs before sending.View More
](/v2/developers/evm/protocol-gas-settings/gas-fees)

[![](/img/icons/config.svg)Generating OptionsBuild message options to control
gas settings, nonce ordering, and more.View More
](/v2/developers/evm/protocol-gas-settings/options)

[![](/img/icons/config.svg)Chain EndpointsThe addresses and endpoint IDs for
every supported chain.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Configure OAppConfigure your Security Stack,
Executors, and other application specific settings.View More
](/v2/developers/evm/protocol-gas-settings/default-config)

[![](/img/icons/testing.svg)Track MessagesFollow your omnichain messages using
LayerZero Scan.View More ](/v2/developers/evm/tooling/layerzeroscan)

[![](/img/icons/testing.svg)TroubleshootingFind answers to common questions
and debugging support.View More
](/v2/developers/evm/troubleshooting/debugging-messages)

[![](/img/icons/testing.svg)Endpoint V1 DocsFind legacy support for LayerZero
Endpoint V1 here.View More ](/v1)

## Security​

LayerZero Labs has an absolute commitment to continuously evaluating and
improving protocol security:

  * [Core contracts are immutable](/v2/home/protocol/layerzero-endpoint) and LayerZero Labs will never deploy upgradeable contracts.

  * While application contracts come pre-configured with an optimal default, application owners can opt out of updates by [modifying and locking protocol configurations](/v2/developers/evm/protocol-gas-settings/default-config#custom-configuration).

  * Protocol updates will always be [optional and backward compatible](/v2/home/protocol/message-library).

LayerZero protocol has been thoroughly audited by leading organizations
building decentralized systems. Browse through [past public
audits](https://github.com/LayerZero-Labs/Audits/tree/main/audits) in our
Github.

## More from LayerZero​

### Questions?​

Join the LayerZero community in our [Discord](https://discord-
layerzero.netlify.app/discord) to ask for help, as well as share your feedback
or showcase what you have built with LayerZero!

### Careers​

LayerZero is growing. If you enjoy using our protocol and have a genuine
interest in omnichain design, please check out [our current job
openings](https://layerzero.network/careers).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/intro.md)

[NextV2 Overview](/v2/home/v2-overview)

  * Quickstart
  * Security
  * More from LayerZero
    * Questions?
    * Careers



  * Protocol
  * Protocol Overview

Version: Endpoint V2 Docs

On this page

# Protocol Overview

To send a cross-chain message, a user must write a transaction on both the
source and destination blockchains.

A successfully deployed [Omnichain Application
(OApp)](/v2/developers/evm/oapp/overview) communicates with the [LayerZero
Endpoint](/v2/home/protocol/layerzero-endpoint) contract to seamlessly send
messages via the protocol from a source to destination chain.

![Protocol V2
Light](/assets/images/protocolv2light-3d1cf3951869746d3cd8d47a9e63c0bc.svg#gh-
light-mode-only) ![Protocol V2
Dark](/assets/images/protocolv2dark-353378180e0e4413f61da05909437507.svg#gh-
dark-mode-only)

The OApp Contract Standard abstracts away the core Endpoint interfaces,
allowing you to focus on building your application's implementation and
features without the need to implement functions at the protocol level.

### How It Works​

  1. A user calls the **`_lzSend`** method inside the OApp passing an arbitrary message, a destination LayerZero Endpoint, the destination OApp address, and other protocol handling options. This call invokes the Endpoint's [`send`](/v2) method on the same chain.
    
        /// @dev MESSAGING STEP 1 - OApp need to transfer the fees to the endpoint before sending the message  
    /// @param _params the messaging parameters  
    /// @param _refundAddress the address to refund both the native and lzToken  
    function send(  
       MessagingParams calldata _params,  
       address _refundAddress  
    ) external payable sendContext(_params.dstEid, msg.sender) returns (MessagingReceipt memory) {  
       if (_params.payInLzToken && lzToken == address(0x0)) revert Errors.LzTokenUnavailable();  
      
       // send message  
       (MessagingReceipt memory receipt, address sendLibrary) = _send(msg.sender, _params);  
      
       // OApp can simulate with 0 native value it will fail with error including the required fee, which can be provided in the actual call  
       // this trick can be used to avoid the need to write the quote() function  
       // however, without the quote view function it will be hard to compose an oapp on chain  
       uint256 suppliedNative = _suppliedNative();  
       uint256 suppliedLzToken = _suppliedLzToken(_params.payInLzToken);  
       _assertMessagingFee(receipt.fee, suppliedNative, suppliedLzToken);  
      
       // handle native fees  
       _payNative(receipt.fee.nativeFee, suppliedNative, sendLibrary, _refundAddress);proto  
      
       // handle lz token fees  
       _payToken(lzToken, receipt.fee.lzTokenFee, suppliedLzToken, sendLibrary, _refundAddress);  
      
       return receipt;  
    }  
    

The Endpoint uses an on-chain [Message Library](/v2/home/protocol/message-
library) (MessageLib) configured by the OApp owner to determine how to
generate the [Message Packet](/v2/home/protocol/packet). The MessageLib
ensures that the correct [OApp Configuration](/v2/developers/evm/protocol-gas-
settings/default-config) specified by the contract owners will be used by the
protocol.

After generating the packet using the correct configuration, the Endpoint
emits the message packet as an event containing information about the target
blockchain, the receiving address, message handling instructions, and the
message itself.

  2. The [Security Stack](/v2/home/modular-security/security-stack-dvns) (as configured by the OApp) listens for the event emitted, awaits a specified number of block confirmations, and then verifies the `payloadHash` of the packet in the destination chain's MessageLib. This `payloadHash` confirms that the contents of the Message Packet on the destination blockchain matches the packet emitted on source.

After the configured threshold of DVNs verify the `payloadHash` on the target
chain, the message's nonce can then be committed to the Endpoint's messaging
channel by any caller (e.g., [Executor](/v2/home/permissionless-
execution/executors)) for execution.

  3. Finally, a caller (e.g., Executor) invokes the [`lzReceive`](/v2) function in the destination Endpoint contract, triggering message execution.
    
        /// @dev MESSAGING STEP 3 - the last step  
    /// @dev execute a verified message to the designated receiver  
    /// @dev the execution provides the execution context (caller, extraData) to the receiver. the receiver can optionally assert the caller and validate the untrusted extraData  
    /// @dev cant reentrant because the payload is cleared before execution  
    /// @param _origin the origin of the message  
    /// @param _receiver the receiver of the message  
    /// @param _guid the guid of the message  
    /// @param _message the message  
    /// @param _extraData the extra data provided by the executor. this data is untrusted and should be validated.  
    function lzReceive(  
       Origin calldata _origin,  
       address _receiver,  
       bytes32 _guid,  
       bytes calldata _message,  
       bytes calldata _extraData  
    ) external payable {  
       // clear the payload first to prevent reentrancy, and then execute the message  
       _clearPayload(_receiver, _origin.srcEid, _origin.sender, _origin.nonce, abi.encodePacked(_guid, _message));  
       ILayerZeroReceiver(_receiver).lzReceive{ value: msg.value }(_origin, _guid, _message, msg.sender, _extraData);  
       emit PacketDelivered(_origin, _receiver);  
    }  
    

     * The destination Endpoint delivers this packet to the destination OApp contract and triggers arbitrary logic via the OApp's defined **`_lzReceive`** function.

  

info

See this flow in action by following the [**Getting
Started**](/v2/developers/evm/getting-started) guide!

## Security Guarantees​

  * **Update Isolation:** Protocol updates are always _optional_ [MessageLibs](/v2/home/protocol/message-library) are immutable and cannot be disabled by the Endpoint. LayerZero can deploy new MessageLibs for security and performance optimization (e.g. more efficient proof technologies) without impacting existing applications.

  * **Configuration Ownership:** Only the OApp owner can change their application's [Security Configuration](/v2/home/modular-security/security-stack-dvns). Contract owners have the final say on how the protocol transmits and verifies their OApp's messages.

  * **Protocol Immutability:** All core contracts are immutable, preventing smart contract upgrades from introducing vulnerabilities.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/protocol/protocol-overview.md)

[PreviousSending Messages](/v2/home/getting-started/send-
message)[NextOmnichain Mesh Network](/v2/home/protocol/mesh-network)

  * How It Works
  * Security Guarantees



  * Protocol
  * LayerZero Endpoint

Version: Endpoint V2 Docs

On this page

# LayerZero Endpoint

The LayerZero Endpoint is an immutable smart contract that implements a
standardized interface for [Omnichain Applications (OApps)](/v2/home/token-
standards/oapp-standard) to manage security configurations and seamlessly send
and receive messages.

Developers can see the latest chains LayerZero supports in [Endpoint
Addresses](/v2/developers/evm/technical-reference/deployed-contracts).

## Sending Endpoint​

The Endpoint exposes an interface for the OApp contract to use to send
messages. When a caller invokes `_lzSend` within an OApp's child contract:

  1. **OApp Config** : the Endpoint enforces each OApp's [unique messaging configuration](/v2/developers/evm/protocol-gas-settings/default-config) specified by the OApp owner. The configured [MessageLib](/v2/home/protocol/message-library) controls how the [Message Packet](/v2/home/protocol/packet) is generated and emitted.

  2. **Message Emission** : Once the Packet has been constructed using the owner's configuration, the message is emitted via the `PacketSent` event.

![Sending Endpoint Light](/assets/images/source_endpoint-
light-8b0bf406bdfb15bda0ed1df761f94e25.svg#gh-light-mode-only) ![Sending
Endpoint Dark](/assets/images/source_endpoint-
dark-0a1af3d9ece6ff417fa5d8963e90affd.svg#gh-dark-mode-only)

  

## Receiving Endpoint​

The configured DVNs within the [Security Stack](/v2/home/modular-
security/security-stack-dvns) listen for the packet and verify the
`PayloadHash` in the destination MessageLib selected by the OApp:

![Receiving Endpoint Light](/assets/images/destination_endpoint-
light-56003ac2ac8fede5deadeb8349fbf192.svg#gh-light-mode-only) ![Receiving
Endpoint Dark](/assets/images/destination_endpoint-
dark-3dd7e47247d381104add06d8432bfd2e.svg#gh-dark-mode-only)

  

Once the message has fulfilled the OApp's configured Security Stack, any
caller (e.g., [Executor](/v2/home/permissionless-execution/executors)) can
commit the verified packet nonce to the destination Endpoint and execute the
corresponding message via `lzReceive` for the receiving application.

The default configuration includes a default Executor to automatically handle
this permissionless call for convenience.

Developers can easily identify a chain's Endpoint via a unique [Endpoint
ID](/v2/developers/evm/technical-reference/deployed-contracts) used for
message routing.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/protocol/layerzero-endpoint.md)

[PreviousContract Standards](/v2/home/protocol/contract-standards)[NextMessage
Library](/v2/home/protocol/message-library)

  * Sending Endpoint
  * Receiving Endpoint



  * Permissionless Execution
  * Executors

Version: Endpoint V2 Docs

On this page

# Executors

Executors ensure the seamless execution of messages on the destination chain
by following instructions set by the OApp owner on how to automatically
deliver omnichain messages to the destination chain.

After the [Security Stack](/v2/home/modular-security/security-stack-dvns) has
verified the message payload, the Executor invokes the `lzReceive` function in
the [Endpoint](/v2/home/protocol/layerzero-endpoint) contract, initiating
message delivery.

## Role of Executors​

When tracking cross-chain messages, you need to confirm a transaction on both
the source and the destination chain, which can be challenging when trying to
build an application that must seamlessly log messages across chains.

The Executor addresses this problem by quoting users in the source chain's
native gas token and automatically calling the destination chain, thereby
eliminating the need to obtain destination chain gas tokens and allowing for
the seamless execution of destination transactions.

This feature extends even further via [Message
Options](/v2/developers/evm/protocol-gas-settings/options), which control how
the Executor delivers different destination transactions:

  * [`lzReceiveOption`](/v2/developers/evm/protocol-gas-settings/options#lzreceive-option) \- handles setting `gas` and `msg.value` amounts when calling the destination contract's `lzReceive` method.

  * [`lzComposeOption`](/v2/developers/evm/protocol-gas-settings/options#lzcompose-option) \- handles setting `gas` and `msg.value` amounts when calling the destination contract's `lzCompose` method.

  * [`lzNativeDropOption`](/v2/developers/evm/protocol-gas-settings/options#lzairdrop-option) \- handles sending an `amount` of native gas to a `receiver` address on the destination chain.

  * [`lzOrderedExecutionOption`](/v2/developers/evm/protocol-gas-settings/options#orderedexecution-option) \- enforces the nonce ordered execution of messages by the Executor.

### Advantages of Executors​

  * **Automated Execution on the Destination Chain** : An Executor automatically triggers the execution of transactions on the destination chain after a packet's `payloadHash` has been verified. This feature ensures a smooth, uninterrupted omnichain experience for users.

  * **Gas Management** : An Executor simplifies gas payments for omnichain transactions by letting users pay for the end-to-end packet emission and delivery with the source chain's gas token. This mechanism ensures that transactions are executed without any gas-related issues on the destination chain.

  * **Customizable Gas Settings** : An Executor also provides flexibility in terms of gas usage. Developers can specify different gas settings for various types of omnichain messages by passing different [Message Options](/v2/developers/evm/protocol-gas-settings/options). This feature is particularly useful for fine-tuning gas consumption based on the specific requirements of different transaction types.

## Default and Custom Executors​

Developers have the ability to [Configure
Executors](/v2/developers/evm/protocol-gas-settings/default-config#send-
config-type-executor) based on their application's needs, ranging from:

  1. **Custom Executor** : OApps can freely choose between multiple existing Executor implementations for automatic message execution.

  2. **Build Executor** : Developers can build and run their own Executor. See [Build Executors](/v2/developers/evm/off-chain/build-executors) to learn more.

  3. **No Executor Option** : Applications can operate without an automated Executor by requiring users to manually invoke `lzReceive` with transaction data on the destination chain, either using [LayerZero Scan](/v2/developers/evm/tooling/layerzeroscan) or the destination blockchain block explorer.

  

note

See [**Executor Configuration**](/v2/developers/evm/protocol-gas-
settings/default-config#custom-configuration) to learn more about configuring
your OApp to use a non-default Executor.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/permissionless-execution/executors.md)

[PreviousSecurity Stack (DVNs)](/v2/home/modular-security/security-stack-dvns)

  * Role of Executors
    * Advantages of Executors
  * Default and Custom Executors



  * LayerZero V2
  * Welcome

Version: Endpoint V2 Docs

On this page

# Explore LayerZero V2

[LayerZero V2](https://layerzero.network/) is an open-source, immutable
messaging protocol designed to facilitate the creation of omnichain,
interoperable applications.

Developers can easily [send arbitrary data](/v2/home/protocol/contract-
standards#oapp), [external function calls](/v2/developers/evm/oapp/message-
design-patterns), and [tokens](/v2/home/protocol/contract-standards#oft) with
omnichain messaging while preserving full autonomy and control over their
application.

LayerZero V2 is currently live on the following [Mainnet and Testnet
Chains](/v2/developers/evm/technical-reference/deployed-contracts).

[![](/img/icons/build.svg)Getting StartedStart building on LayerZero by
sending your first omnichain message.View More ](/v2/developers/evm/getting-
started)

[![](/img/icons/protocol.svg)Supported ChainsDiscover which chains the
LayerZero V2 Endpoint is live on.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Supported SecuritySee which Decentralized Verifier
Networks (DVNs) can be added to secure your omnichain app.View More
](/v2/developers/evm/technical-reference/dvn-addresses)

[![](/img/icons/Ethereum-logo-test.svg)Solidity DevelopersResources to help
you quickly build, launch, and scale your EVM omnichain applications.View More
](/v2/developers/evm/overview)

[![](/img/icons/solanaLogoMark.svg)Solana DevelopersResources to build your
LayerZero applications on the Solana blockchain.View More
](/v2/developers/solana/overview)

  
  

See the Quickstart Guide below for specific guides on every topic related to
building with the LayerZero protocol.

## Quickstart​

Comprehensive developer guides for every step of your omnichain journey.

[![](/img/icons/build.svg)OApp OverviewBuild your first Omnichain Application
(OApp), using the LayerZero Contract Standards.View More
](/v2/developers/evm/oapp/overview)

[![](/img/icons/build.svg)Build an OFTBuild an Omnichain Fungible Token (OFT)
using familiar fungible token standards.View More
](/v2/developers/evm/oft/quickstart)

[![](/img/icons/build.svg)Estimating Gas FeesGenerate a quote of your
omnichain message gas costs before sending.View More
](/v2/developers/evm/protocol-gas-settings/gas-fees)

[![](/img/icons/config.svg)Generating OptionsBuild message options to control
gas settings, nonce ordering, and more.View More
](/v2/developers/evm/protocol-gas-settings/options)

[![](/img/icons/config.svg)Chain EndpointsThe addresses and endpoint IDs for
every supported chain.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Configure OAppConfigure your Security Stack,
Executors, and other application specific settings.View More
](/v2/developers/evm/protocol-gas-settings/default-config)

[![](/img/icons/testing.svg)Track MessagesFollow your omnichain messages using
LayerZero Scan.View More ](/v2/developers/evm/tooling/layerzeroscan)

[![](/img/icons/testing.svg)TroubleshootingFind answers to common questions
and debugging support.View More
](/v2/developers/evm/troubleshooting/debugging-messages)

[![](/img/icons/testing.svg)Endpoint V1 DocsFind legacy support for LayerZero
Endpoint V1 here.View More ](/v1)

## Security​

LayerZero Labs has an absolute commitment to continuously evaluating and
improving protocol security:

  * [Core contracts are immutable](/v2/home/protocol/layerzero-endpoint) and LayerZero Labs will never deploy upgradeable contracts.

  * While application contracts come pre-configured with an optimal default, application owners can opt out of updates by [modifying and locking protocol configurations](/v2/developers/evm/protocol-gas-settings/default-config#custom-configuration).

  * Protocol updates will always be [optional and backward compatible](/v2/home/protocol/message-library).

LayerZero protocol has been thoroughly audited by leading organizations
building decentralized systems. Browse through [past public
audits](https://github.com/LayerZero-Labs/Audits/tree/main/audits) in our
Github.

## More from LayerZero​

### Questions?​

Join the LayerZero community in our [Discord](https://discord-
layerzero.netlify.app/discord) to ask for help, as well as share your feedback
or showcase what you have built with LayerZero!

### Careers​

LayerZero is growing. If you enjoy using our protocol and have a genuine
interest in omnichain design, please check out [our current job
openings](https://layerzero.network/careers).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/intro.md)

[NextV2 Overview](/v2/home/v2-overview)

  * Quickstart
  * Security
  * More from LayerZero
    * Questions?
    * Careers



  * Aptos Contracts V2
  * Overview

Version: Endpoint V2 Docs

# LayerZero V2 Aptos Smart Contracts

info

Currently Aptos is only available for LayerZero V1! Check back in later to see
progress on the LayerZero V2 Aptos Endpoint.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/aptos/overview.md)



  * Troubleshooting
  * Debugging Messages

Version: Endpoint V2 Docs

On this page

# Debugging Messages

The V2 protocol now splits the verification and contract logic execution of
messages into two separate, distinct phases:

**`Verified`** : the destination chain has received verification from all
configured [DVNs](/v2/home/modular-security/security-stack-dvns) and the
message nonce has been committed to the
[Endpoint](/v2/home/protocol/layerzero-endpoint)'s messaging channel.

**`Delivered`** : the message has been successfully executed by the
[Executor](/v2/home/permissionless-execution/executors).

Because verification and execution are separate, LayerZero can provide
specific error handling for each message state.

## Message Execution​

When your message is successfully delivered to the destination chain, the
protocol attempts to execute the message with the execution parameters defined
by the sender. Message execution can result in two possible states:

  * **Success** : If the execution is successful, an event (`PacketReceived`) is emitted.

  * **Failure** : If the execution fails, the contract reverses the clearing of the payload (re-inserts the payload) and emits an event (`LzReceiveAlert`) to signal the failure.

    * **Out of Gas** : The message fails because the transaction that contains the message doesn't provide enough gas for execution.

    * **Logic Error** : There's an error in either the contract code or the message parameters passed that prevents the message from being executed correctly.

### Retry Message​

Because LayerZero separates the verification of a message from its execution,
if a message fails to execute due to either of the reasons above, the message
can be retried without having to resend it from the origin chain.

This is possible because the message has already been confirmed by the DVNs as
a valid message packet, meaning execution can be retried at anytime, by
anyone.

Here's how an OApp contract owner or user can retry a message:

  * **Using LayerZero Scan** : For users that want a simple frontend interface to interact with, LayerZero Scan provides both message failure detection and in-browser message retrying.

  * **Calling`lzReceive` Directly**: If message execution fails, any user can retry the call on the Endpoint's `lzReceive` function via the block explorer or any popular library for interacting with the blockchain like [ethers](https://docs.ethers.org/v5/), [viem](https://viem.sh/docs/getting-started.html), etc.

    
    
        function lzReceive(  
            Origin calldata _origin,  
            address _receiver,  
            bytes32 _guid,  
            bytes calldata _message,  
            bytes calldata _extraData  
        ) external payable {  
            // clear the payload first to prevent reentrancy, and then execute the message  
            _clearPayload(_receiver, _origin.srcEid, _origin.sender, _origin.nonce, abi.encodePacked(_guid, _message));  
            ILayerZeroReceiver(_receiver).lzReceive{ value: msg.value }(_origin, _guid, _message, msg.sender, _extraData);  
            emit PacketDelivered(_origin, _receiver);  
        }  
    

### Skipping Nonce​

Occasionally, an [OApp delegate](/v2/developers/evm/oapp/overview#setting-
delegates) may want to cancel the verification of an in-flight message. This
might be due to a variety of reasons, such as:

  * **Race Conditions** : conditions where multiple transactions are being processed in parallel, and some might become invalid or redundant before they are processed.

  * **Error Handling** : In scenarios where a message cannot be delivered (for example, due to being invalid or because prerequisites are not met), the skip function provides a way to bypass it and continue with subsequent messages.

By allowing the OApp to skip the problematic message, the OApp can maintain
efficiency and avoid getting stuck by a single bottleneck.

caution

The `skip` function should be used only in instances where either message
**verification** fails or must be stopped, not message **execution**.
LayerZero provides separate handling for retrying or removing messages that
have successfully been verified, but fail to execute.

danger

It is crucial to use this function with caution because once a payload is
skipped, it cannot be recovered.

  

An OApp's delegate can call the `skip` method via the Endpoint to stop message
delivery:

    
    
    /// @dev the caller must provide _nonce to prevent skipping the unintended nonce  
    /// @dev it could happen in some race conditions, e.g. intent to skip nonce 3, but nonce 3 was consumed before this transaction was included in the block  
    /// @dev NOTE: only allows skipping the next of the effective inbound nonce (from the inboundNonce() function). if the Oapp wants to skips a delivered message, it should call the clear() function and ignore the payload instead  
    /// @dev after skipping, the lazyInboundNonce is set to the provided nonce, which makes the inboundNonce also the provided nonce  
      
    function skip (  
      address _oapp, //the Oapp address  
      uint32 _srcEid, //source chain endpoint id  
      bytes32 _sender, //the byte32 format of sender address  
      uint64 _nonce // the message nonce you wish to skip to  
    ) external {  
      _assertAuthorized(_oapp);  
      
      if (_nonce != inboundNonce(_oapp, _srcEid, _sender) + 1) revert Errors.InvalidNonce(_nonce);  
      
      //Skipping ahead of this nonce.  
      lazyInboundNonce[_oapp][_srcEid][_sender] = _nonce;  
      emit InboundNonceSkipped(_srcEid, _sender, _oapp, _nonce);  
    }  
      
    

**Example for calling`skip`**

  1. **Set up Dependencies and Define the ABI**

    
    
     // using ethers v5  
    const {ethers} = require('ethers');  
    const skipFunctionABI = [  
      'function skip(address _oapp,uint32 _srcEid, bytes32 _sender, uint64 _nonce)',  
    ];  
    

  2. **Configure the Contract Instance**

    
    
     // Example Endpoint Address  
    const ENDPOINT_CONTRACT_ADDRESS = '0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7';  
      
    const provider = new ethers.providers.JsonRpcProvider(YOUR_RPC_URL);  
    const signer = new ethers.Wallet(YOUR_PRIVATE_KEY, provider);  
    const endpointContract = new ethers.Contract(ENDPOINT_CONTRACT_ADDRESS, skipFunctionABI, signer);  
    

  3. **Prepare Function Parameters**

    
    
     // Example Oapp Address  
    const oAppAddress = '0x123123123678afecb367f032d93F642f64180aa3';  
      
    // Parameters for the skip function  
    const srcEid = 50121; // srcEid example  
      
    // padding an example address to bytes32  
    const sender = ethers.zeroPadValue(`0x5FbDB2315678afecb367f032d93F642f64180aa3`, 32);  
    const nonce = 3; // uint64 nonce example  
      
    const tx = await endpointContract.skip(oAppAddress, srcEid, sender, nonce);  
    

  4. **Send the Transaction**

    
    
     const tx = await endpointContract.skip(oAppAddress, srcEid, sender, nonce);  
    await tx.wait();  
    

### Clearing Message​

As a last resort, an OApp contract owner may want to force eject a message
packet, either due to an unrecoverable error or to prevent a malicious packet
from being executed:

  * When logic errors exist and the message can't be retried successfully.
  * When a malicious message needs to be avoided.

**Using the`clear` Function**: This function exists on the Endpoint and allows
an OApp contract delegate to burn the message payload so it can never be
retried again.

danger

It is crucial to use this function with caution because once a payload is
cleared, it cannot be recovered.

    
    
    /// @dev Oapp uses this interface to clear a message.  
    /// @dev this is a PULL mode versus the PUSH mode of lzReceive  
    /// @dev the cleared message can be ignored by the app (effectively burnt)  
    /// @dev authenticated by oapp  
    /// @param _origin the origin of the message  
    /// @param _guid the guid of the message  
    /// @param _message the message  
      
    function clear(  
      address _oapp, //the Oapp address  
      Origin calldata _origin, // The `Origin` struct of the message.  
      bytes32 _guid, // The unique identifier of the message. This can be fetched from the arguments of `LzReceive`.  
      bytes calldata _message // The bytes message you sent on the source chain. This can be fetched from the arguments of `LzReceive`.  
    ) external {  
        _assertAuthorized(_oapp);  
      
        bytes memory payload = abi.encodePacked(_guid, _message);  
        _clearPayload(_oapp, _origin.srcEid, _origin.sender, _origin.nonce, payload);  
        emit PacketDelivered(_origin, _oapp);  
    }  
    

**Example for calling`clear`**

  1. **Set up Dependencies and Define the ABI**

    
    
     // using ethers v5  
    const {ethers} = require('ethers');  
    const clearFunctionABI = [  
      {  
        inputs: [  
          {  
            components: [  
              {internalType: 'uint32', name: 'srcEid', type: 'uint32'},  
              {internalType: 'bytes32', name: 'sender', type: 'bytes32'},  
              {internalType: 'uint64', name: 'nonce', type: 'uint64'},  
            ],  
            internalType: 'struct Origin',  
            name: '_origin',  
            type: 'tuple',  
          },  
          {internalType: 'bytes32', name: '_guid', type: 'bytes32'},  
          {internalType: 'bytes', name: '_message', type: 'bytes'},  
        ],  
        name: 'clear',  
        outputs: [],  
        stateMutability: 'nonpayable',  
        type: 'function',  
      },  
    ];  
    

  2. **Configure the Contract Instance**

    
    
     // Example Endpoint Address  
    const ENDPOINT_CONTRACT_ADDRESS = '0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7';  
      
    const provider = new ethers.providers.JsonRpcProvider(YOUR_RPC_URL);  
    const signer = new ethers.Wallet(YOUR_PRIVATE_KEY, provider);  
    const endpointContract = new ethers.Contract(ENDPOINT_CONTRACT_ADDRESS, clearFunctionABI, signer);  
    

  3. **Prepare Function Parameters**

    
    
     // Example Oapp Address  
    const oAppAddress = '0x123123123678afecb367f032d93F642f64180aa3';  
      
    // Parameters for the skip function  
    const origin = {  
      srcEid: 10111, // example source chain endpoint Id  
      sender: ethers.zeroPadValue(`0x5FbDB2315678afecb367f032d93F642f64180aa3`, 32), // bytes32 representation of an address  
      nonce: 3, // example nonce  
    };  
      
    const _guid = '0x0af522cbed56c0e67988a3eab0e83fc576d501659ffe7743ffa4a0a76b40419d'; // example _guid  
    const _message =  
      '0x0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000064849484948490000000000000000000000000000000000000000000000000000'; //example _message  
    

  4. **Send the Transaction**

    
    
     const tx = await endpointContract.clear(oAppAddress, origin, _guid, _message);  
    await tx.wait();  
    

### Nilify and Burn​

These two functions exist in the Endpoint contract and are used in very
specific cases to avoid malicious acts by DVNs. These two functions are
infrequently utilized and serve as precautionary design measures.

tip

`nilify` and `burn` are called similarly to `clear` and `skip`, refer to those
examples if needed.

#### **`nilify`**​

    
    
    /// @dev Marks a packet as verified, but disallows execution until it is re-verified.  
    /// @dev Reverts if the provided _payloadHash does not match the currently verified payload hash.  
    /// @dev A non-verified nonce can be nilified by passing EMPTY_PAYLOAD_HASH for _payloadHash.  
    /// @dev Assumes the computational intractability of finding a payload that hashes to bytes32.max.  
    /// @dev Authenticated by the caller  
    function nilify(  
      address _oapp, // The Oapp address  
      uint32 _srcEid, // The source Endpoint Id  
      bytes32 _sender, // The bytes32 representation of the source chain's Oapp address  
      uint64 _nonce, // The nonce you want to nilify  
      bytes32 _payloadHash // The targeted payload hash  
    ) external  
    

The `nilify` function is designed to transform a non-executed payload hash
into NIL value (0xFFFFFF...). This transformation enables the resubmission of
these NIL packets via the MessageLib back into the endpoint, providing a
recovery mechanism from disruptions caused by malicious DVNs.

#### **`burn`**​

    
    
    /// @dev Marks a nonce as unexecutable and un-verifiable. The nonce can never be re-verified or executed.  
    /// @dev Reverts if the provided _payloadHash does not match the currently verified payload hash.  
    /// @dev Only packets with nonces less than or equal to the lazy inbound nonce can be burned.  
    /// @dev Reverts if the nonce has already been executed.  
    /// @dev Authenticated by the caller  
    function burn(  
      address _oapp, // The Oapp address  
      uint32 _srcEid, // The source Endpoint Id  
      bytes32 _sender, // The bytes32 representation of the source chain's Oapp address  
      uint64 _nonce, // The nonce you want to nilify  
      bytes32 _payloadHash // The targeted payload hash  
    ) external  
    

The `burn` function operates similarly to the `clear` function with two key
distinctions:

  1. The OApp is not required to be aware of the original payload
  2. The nonce designated for burning must be less than the `lazyInboundNonce`

This function exists to avoid malicious DVNs from hiding the original payload
to avoid the message from being cleared.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/troubleshooting/debugging-messages.md)

[PreviousLayerZero Scan](/v2/developers/evm/tooling/layerzeroscan)[NextError
Codes](/v2/developers/evm/troubleshooting/error-messages)

  * Message Execution
    * Retry Message
    * Skipping Nonce
    * Clearing Message
    * Nilify and Burn



  * Getting Started
  * What is LayerZero?

Version: Endpoint V2 Docs

On this page

# What is LayerZero?

LayerZero is an immutable, censorship-resistant, and permissionless smart
contract protocol that enables anyone on a blockchain to send, verify, and
execute messages on a supported destination network.

![Protocol V2
Light](/assets/images/protocolv2light-3d1cf3951869746d3cd8d47a9e63c0bc.svg#gh-
light-mode-only) ![Protocol V2
Dark](/assets/images/protocolv2dark-353378180e0e4413f61da05909437507.svg#gh-
dark-mode-only)

### Before LayerZero​

Before LayerZero, to send anything to a new chain, most dApps used some type
of **monolithic bridge** :

  * **Centralized Provider** : a centralized entity, manually delivering messages to the destination chain.

  * **Collection of Signers** : a collection of different signers which verify the message before delivering.

  * **Middlechain Bridge** : a blockchain which routes all messages through the hub chain, inheriting the security of the middlechain.

While each verifier network came with trade-offs, all suffered from one common
problem: **a single verifier network determined which messages would be
delivered on the destination chain.**

![Attack Vector Dark](/assets/images/attack-
vector-4a72a88e142bb25a417c32d47a8877e5.svg#gh-dark-mode-only)

When that security failed, whether due to centralization, a backdoor in the
signer clients, the middlechain lacking client diversity, or upgradeable
contracts, [every application built on top of that verifier network was
exposed](https://rekt.news/leaderboard/).

### Solution: Immutable Contracts​

To send and receive messages on a target blockchain, a non-upgradeable
**LayerZero Endpoint** contract must be deployed to that chain.

This Endpoint contract acts as the entry and exit point for the protocol,
enabling applications and users to:

  * Send messages from the source blockchain ([`Endpoint.send`](/v2/developers/evm/getting-started)).

  * Configure application security ([`Endpoint.setConfig`](/v2/developers/evm/protocol-gas-settings/default-config#custom-configuration)).

  * Configure execution settings ([`Endpoint.setConfig`](/v2/developers/evm/protocol-gas-settings/default-config#custom-configuration)).

  * Quote cross-chain transaction gas costs ([`Endpoint.quote`](/v2/developers/evm/protocol-gas-settings/gas-fees)).

  * Receive messages on the destination chain ([`Endpoint.lzReceive`](/v2/developers/evm/getting-started)).

  * Debug and retry failed messages ([`Endpoint.lzReceive`](/v2/developers/evm/troubleshooting/debugging-messages)).

This Endpoint interface is used in both the [Omnichain Application
(OApp)](/v2/developers/evm/oapp/overview) and [Omnichain Fungible Token (OFT)
Standard](/v2/developers/evm/oft/quickstart), and can be extended by any smart
contract needing to send messages to a destination chain.

The LayerZero Endpoint provides users a predictable, stable interface for
[sending arbitrary data](/v2/home/protocol/contract-standards#oapp), [external
function calls](/v2/developers/evm/oapp/message-design-patterns), and
[tokens](/v2/home/protocol/contract-standards#oft).

See the currently supported chains that LayerZero has deployed to
[here](/v2/developers/evm/technical-reference/deployed-contracts).

### Solution: Modular Security​

LayerZero allows applications to configure any number and type of
decentralized verifier networks (DVNs) to verify their cross-chain messages.

![DVN Light](/assets/images/dvn-light-7122e5676683412a46450c1a7f461cfe.svg#gh-
light-mode-only) ![DVN Dark](/assets/images/dvn-
dark-a57e53bda0186cb56cbe3eb070d2a1bb.svg#gh-dark-mode-only)

Instead of every application depending on the same verifier network, each
application now has a unique verifier configuration called a [Security
Stack](/v2/home/modular-security/security-stack-dvns), allowing developers to
maintain access controls on arguably the most important part of their
application.

New verifier networks can be added at anytime by the application owner or with
specific access-controls, future-proofing cross-chain applications to the
latest and greatest verification techniques.

See the current list of decentralized verifier networks (DVNs)
[here](/v2/developers/evm/technical-reference/dvn-addresses).

### Solution: Permissionless Execution​

Because anyone can interact with the LayerZero Endpoint on the destination
chain, LayerZero offers permissionless message execution.

![DVN Dark](/assets/images/permissionless-
execution-9354b7b75baf4f029a86a450eb792d7d.svg#gh-dark-mode-only)

Once a message has been verified by an application's chosen decentralized
verifier networks (DVNs), that message can be executed by calling the
Endpoint's `lzReceive` method.

In most cases, this execution is done automatically by an [application's
configured Executor](/v2/developers/evm/protocol-gas-settings/default-
config#setting-send-config), a production asset run in the ecosystem which
automatically delivers messages after verification.

This Executor fully abstracts gas on the destination chain, allowing users to
pay for gas only using the source chain's gas token, and [add specific
execution options](/v2/developers/evm/protocol-gas-settings/options) for the
cross-chain message.

Anyone can [develop and run their own Executor](/v2/developers/evm/off-
chain/build-executors), and should a configured Executor ever disappear, these
messages can still be permissionlessly executed at anytime.

### Getting Started with LayerZero​

To start building on LayerZero V2, read the following:

  * [Getting Started with Omnichain Messaging](/v2/developers/evm/getting-started)

  * [Create LZ OApp Quickstart](/v2/developers/evm/create-lz-oapp/start)

  * [OApp Quickstart](/v2/developers/evm/oapp/overview)

  * [OFT Quickstart](/v2/developers/evm/oft/quickstart)

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/getting-started/what-is-layerzero.md)

[PreviousV2 Migration](/v2/home/v2-migration)[NextSending
Messages](/v2/home/getting-started/send-message)

  * Before LayerZero
  * Solution: Immutable Contracts
  * Solution: Modular Security
  * Solution: Permissionless Execution
  * Getting Started with LayerZero



  * Tooling
  * LayerZero Scan

Version: Endpoint V2 Docs

On this page

# LayerZero Scan

[LayerZero Scan](https://layerzeroscan.com/) is a comprehensive search, API,
and analytics platform designed to streamline the experience for developers
and users dealing with omnichain transactions.

![Scan-Light](/assets/images/scan-aed0cd2a2ac564bc89ece8009ec3c923.png#gh-
light-mode-only) ![Scan-Dark](/assets/images/scan-
aed0cd2a2ac564bc89ece8009ec3c923.png#gh-dark-mode-only)

## Overview​

Scan offers an enhanced developer experience for working with omnichain
transactions in the LayerZero protocol by providing:

  * **Unified Message Explorer** : Track LayerZero transactions across multiple chains within a single interface.

  * **Protocol Analytics** : Monitor marketwide trends and the state of the ecosystem through detailed analytics.

  * **Scan Client** : Interface your frontend applications with omnichain transaction logs seamlessly.

Developers can monitor transactions on both the [Mainnet
Explorer](https://layerzeroscan.com/) and [Testnet
Explorer](https://testnet.layerzeroscan.com/).

## Transaction Statuses​

![Scan-Light](/assets/images/tx-
statuses-868dd8c509c532136cc61a7b325a0de4.png#gh-light-mode-only) ![Scan-
Dark](/assets/images/tx-statuses-868dd8c509c532136cc61a7b325a0de4.png#gh-dark-
mode-only)

  * **Delivered** : The message has been successfully sent and received by the destination chain.

  * **Inflight** : The message is currently being transmitted between chains and has not yet reached its destination.

  * **Payload Stored** : The message arrived at the destination, but reverted or ran out of gas during execution and needs to be retried.

  * **Failed** : The transaction encountered an error and did not complete.

  * **Blocked** : A previous message nonce has a stored payload, halting the current transaction.

  * **Confirming** : The system is validating the finality of a transaction amidst potential high gas replacements or block reorgs.

## Protocol Analytics​

Users can also monitor protocol and chain analytics, making it easy to observe
market wide trends and understand the current state of the ecosystem.

![Scan-Analytics-Light](/assets/images/scan-
analytics-d1a02cdd484abfad2e960dee32f0d1c5.png#gh-light-mode-only) ![Scan-
Analytics-Dark](/assets/images/scan-
analytics-d1a02cdd484abfad2e960dee32f0d1c5.png#gh-dark-mode-only)

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/tooling/layerzeroscan.md)

[PreviousTestHelper](/v2/developers/evm/tooling/test-helper)[NextDebugging
Messages](/v2/developers/evm/troubleshooting/debugging-messages)

  * Overview
  * Transaction Statuses
  * Protocol Analytics



  * Solidity Contracts V2
  * Start Here

Version: Endpoint V2 Docs

On this page

# LayerZero V2 Solidity Contract Standards

LayerZero enable seamless cross-chain messaging, configurations for security,
and other quality of life improvements to simplify cross-chain development.

#### LayerZero Solidity Contract Standards​

[![](/img/icons/build.svg)OApp StandardThe base generic message passing
standard, enabling cross-chain data transfer and external function calls.View
More ](/v2/developers/evm/oapp/overview)

[![](/img/icons/build.svg)OFT StandardExtension of OApp, combining the ERC20
token standard with core bridge logic to make Omnichain Fungible Tokens.View
More ](/v2/developers/evm/oft/quickstart)

[![](/img/icons/build.svg)ONFT StandardCombines the ERC721 token standard with
core bridge logic to make Omnichain Non-Fungible Tokens.View More
](/v2/developers/evm/onft/quickstart)

#### LayerZero Solidity Protocol Configurations​

[![](/img/icons/build.svg)Configure Security StackConfigure which
decentralized verifier networks (DVNs) secure your messages.View More
](/v2/developers/evm/protocol-gas-settings/default-config#custom-
configuration)

[![](/img/icons/protocol.svg)Configure ExecutorConfigure who executes your
messages on the destination chain.View More ](/v2/developers/evm/protocol-gas-
settings/default-config#custom-configuration)

[![](/img/icons/testing.svg)Set Execution OptionsSet the amount of gas to
deliver to the destination chain.View More ](/v2/developers/evm/protocol-gas-
settings/options)

  

info

To find all of LayerZero's contracts visit the [**LayerZero V2 Protocol
Repo**](https://github.com/LayerZero-Labs/LayerZero-v2).

### Installation​

To start sending cross-chain messages with LayerZero, you can find install
instructions for each contract package in [OApp
Quickstart](/v2/developers/evm/oapp/overview), [OFT
Quickstart](/v2/developers/evm/oft/quickstart), or [ONFT
Quickstart](/v2/developers/evm/onft/quickstart).

LayerZero also provides [create-lz-oapp](/v2/developers/evm/create-lz-
oapp/start), an all-in-one npx package that allows developers to create a
project from any of the available omnichain standards in <4 minutes!

tip

Get started by running the following from your command line:

    
    
    npx create-lz-oapp@latest  
    

### Usage​

Once installed, you can use the contracts in the library by importing them:

    
    
    // SPDX-License-Identifier: MIT  
    pragma solidity ^0.8.22;  
      
    import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";  
    import { OApp } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";  
      
      
    contract MyOApp is OApp {  
        constructor(address _endpoint, address _owner) OApp(_endpoint, _owner) Ownable(_owner) {}  
      
        // ... rest of OApp interface functions  
    }  
    

To keep your system secure, you should **always** use the installed code as-
is, and neither copy-paste it from online sources, nor modify it directly.

Most of the LayerZero contracts are expected to be used via inheritance: you
will inherit from them when writing your own contracts.

## Tooling​

LayerZero also provides developer tooling to simplify the contract creation,
testing, and deployment process:

  * [LayerZero Scan](/v2/developers/evm/tooling/layerzeroscan): a comprehensive block explorer, search, API, and analytics platform for tracking and debugging your omnichain transactions.

  * [TestHelper (Foundry)](/v2/developers/evm/foundry): a suite of functions to simulate cross-chain transactions and validate the behavior of OApps locally in your Foundry unit tests.

You can also ask for help or follow development in the
[Discord](https://discord-layerzero.netlify.app/discord).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/overview.md)

[NextGetting Started](/v2/developers/evm/getting-started)

  * Installation
  * Usage
  * Tooling



  * LayerZero V2
  * V2 Migration

Version: Endpoint V2 Docs

On this page

# Migrating from V1 to V2

Migration options exist for deployed LayerZero V1 applications looking to take
advantage of LayerZero V2.

## Deployed Apps on `Endpoint V1`​

If you have already deployed on Endpoint V1, migrating to the new LayerZero V2
protocol is entirely **optional**.

LayerZero V2 comes with enhancements to the core protocol design that increase
message efficiency and customizability.

You can access the new [Security Stack](/v2/home/modular-security/security-
stack-dvns) and [Independent Execution](/v2/home/permissionless-
execution/executors) by configuring your application's Message Library to
**Ultra Light Node 301**.

With UltraLightNode301, your deployed `LZApp` on Endpoint V1 will be able to
configure the new Security Stack for message authentication, as well as an
Executor to ensure your application receives messages on the destination
chain.

### Prerequisites​

You should have an LZApp to start with that's already working with default
settings. Any app that inherits `LZApp.sol` (including the Endpoint V1 OFT and
ONFT standards) can be used.

### Configuring UltraLightNode301​

To set a new MessageLib on Endpoint V1, you will call the `setConfig` function
on Chain A and Chain B.

Below is a simple example for how to set your MessageLib:

    
    
    // @dev function to set your LZApp's send MessageLib  
    function setSendVersion(uint16 _version) external override onlyOwner {  
            lzEndpoint.setSendVersion(_version);  
    }  
      
    // @dev function to set your LZApp's receive MessageLib  
    function setReceiveVersion(uint16 _version) external override onlyOwner {  
            lzEndpoint.setReceiveVersion(_version);  
    }  
    

To find the specific Send/Receive version for a given chain, call the
`latestVersion` variable on the chain's endpoint contract.

    
    
    const latestVersion = await endpointContract.latestVersion();  
    

The `latestVersion` represents the index of the last MessageLib that was
appended to the chain's endpoint, which currently is ReceiveULN301 for all
endpoints, while SendULN301 is the index before ReceiveULN301.

    
    
    const receiveUln301Version = latestVersion;  
    const sendUln301Version = latestVersion - 1;  
    

Finally, you can use the respective Send/Receive versions to set your OApp to
UltraLightNode301:

    
    
    const sendTx = await oappContract.setSendVersion(sendUln301Version);  
    await sendTx.wait();  
      
    const receiveTx = await oappContract.setReceiveVersion(receiveUln301Version);  
    await receiveTx.wait();  
    

After setting your libraries to the new **UltraLightNode301** , you can
configure your `LZApp` using the Endpoint V1 `setConfig` function, passing the
`configType` and `config` values for the specific [Security
Stack](/v2/developers/evm/protocol-gas-settings/default-config#custom-
configuration) and [Executors](/v2/developers/evm/protocol-gas-
settings/default-config#custom-configuration).

  

    
    
    function setConfig(  
        uint16 _version,  
        uint16 _chainId,  
        uint _configType,  
        bytes calldata _config  
    ) external override onlyOwner {  
        lzEndpoint.setConfig(_version, _chainId, _configType, _config);  
    }  
    

With `UltraLightNode301`, your deployed `LZApp` on Endpoint V1 will be able to
configure the new Security Stack for message authentication, as well as an
Executor to ensure your application receives messages on the destination
chain.

This enables a wider range of security configurations while simultaneously
isolating network liveness from message execution.

See the full list of improvements for **Deployed V1 Apps** in the [V2
Overview](/v2).

## New Apps on `Endpoint V2`​

For new applications deciding between Endpoint V1 and Endpoint V2, we
recommend deploying exclusively with V2 Contracts to take advantage of on-
chain specific benefits (_i.e., higher message throughput, smaller contract
sizes, gas optimization, and horizontal message composability_).

You will need to deploy using the new [Contract
Standards](/v2/home/protocol/contract-standards) on Endpoint V2.

info

These benefits specifically come from improvements in on-chain protocol and
application related contracts. For your application to receive these specific
benefits, you will need to deploy new OApps using these contracts. See the
full overview in [**New Protocol Contracts**](/v2).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/v2-migration.md)

[PreviousV2 Overview](/v2/home/v2-overview)[NextWhat is
LayerZero?](/v2/home/getting-started/what-is-layerzero)

  * Deployed Apps on `Endpoint V1`
    * Prerequisites
    * Configuring UltraLightNode301
  * New Apps on `Endpoint V2`



  * LayerZero V2
  * Welcome

Version: Endpoint V2 Docs

On this page

# Explore LayerZero V2

[LayerZero V2](https://layerzero.network/) is an open-source, immutable
messaging protocol designed to facilitate the creation of omnichain,
interoperable applications.

Developers can easily [send arbitrary data](/v2/home/protocol/contract-
standards#oapp), [external function calls](/v2/developers/evm/oapp/message-
design-patterns), and [tokens](/v2/home/protocol/contract-standards#oft) with
omnichain messaging while preserving full autonomy and control over their
application.

LayerZero V2 is currently live on the following [Mainnet and Testnet
Chains](/v2/developers/evm/technical-reference/deployed-contracts).

[![](/img/icons/build.svg)Getting StartedStart building on LayerZero by
sending your first omnichain message.View More ](/v2/developers/evm/getting-
started)

[![](/img/icons/protocol.svg)Supported ChainsDiscover which chains the
LayerZero V2 Endpoint is live on.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Supported SecuritySee which Decentralized Verifier
Networks (DVNs) can be added to secure your omnichain app.View More
](/v2/developers/evm/technical-reference/dvn-addresses)

[![](/img/icons/Ethereum-logo-test.svg)Solidity DevelopersResources to help
you quickly build, launch, and scale your EVM omnichain applications.View More
](/v2/developers/evm/overview)

[![](/img/icons/solanaLogoMark.svg)Solana DevelopersResources to build your
LayerZero applications on the Solana blockchain.View More
](/v2/developers/solana/overview)

  
  

See the Quickstart Guide below for specific guides on every topic related to
building with the LayerZero protocol.

## Quickstart​

Comprehensive developer guides for every step of your omnichain journey.

[![](/img/icons/build.svg)OApp OverviewBuild your first Omnichain Application
(OApp), using the LayerZero Contract Standards.View More
](/v2/developers/evm/oapp/overview)

[![](/img/icons/build.svg)Build an OFTBuild an Omnichain Fungible Token (OFT)
using familiar fungible token standards.View More
](/v2/developers/evm/oft/quickstart)

[![](/img/icons/build.svg)Estimating Gas FeesGenerate a quote of your
omnichain message gas costs before sending.View More
](/v2/developers/evm/protocol-gas-settings/gas-fees)

[![](/img/icons/config.svg)Generating OptionsBuild message options to control
gas settings, nonce ordering, and more.View More
](/v2/developers/evm/protocol-gas-settings/options)

[![](/img/icons/config.svg)Chain EndpointsThe addresses and endpoint IDs for
every supported chain.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Configure OAppConfigure your Security Stack,
Executors, and other application specific settings.View More
](/v2/developers/evm/protocol-gas-settings/default-config)

[![](/img/icons/testing.svg)Track MessagesFollow your omnichain messages using
LayerZero Scan.View More ](/v2/developers/evm/tooling/layerzeroscan)

[![](/img/icons/testing.svg)TroubleshootingFind answers to common questions
and debugging support.View More
](/v2/developers/evm/troubleshooting/debugging-messages)

[![](/img/icons/testing.svg)Endpoint V1 DocsFind legacy support for LayerZero
Endpoint V1 here.View More ](/v1)

## Security​

LayerZero Labs has an absolute commitment to continuously evaluating and
improving protocol security:

  * [Core contracts are immutable](/v2/home/protocol/layerzero-endpoint) and LayerZero Labs will never deploy upgradeable contracts.

  * While application contracts come pre-configured with an optimal default, application owners can opt out of updates by [modifying and locking protocol configurations](/v2/developers/evm/protocol-gas-settings/default-config#custom-configuration).

  * Protocol updates will always be [optional and backward compatible](/v2/home/protocol/message-library).

LayerZero protocol has been thoroughly audited by leading organizations
building decentralized systems. Browse through [past public
audits](https://github.com/LayerZero-Labs/Audits/tree/main/audits) in our
Github.

## More from LayerZero​

### Questions?​

Join the LayerZero community in our [Discord](https://discord-
layerzero.netlify.app/discord) to ask for help, as well as share your feedback
or showcase what you have built with LayerZero!

### Careers​

LayerZero is growing. If you enjoy using our protocol and have a genuine
interest in omnichain design, please check out [our current job
openings](https://layerzero.network/careers).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/intro.md)

[NextV2 Overview](/v2/home/v2-overview)

  * Quickstart
  * Security
  * More from LayerZero
    * Questions?
    * Careers



  * Protocol
  * Message Library

Version: Endpoint V2 Docs

On this page

# Message Library

Each MessageLib is an immutable verification library that OApp owners can
configure their application to use. The protocol enforces the contract owner's
unique [OApp Configuration](/v2/developers/evm/protocol-gas-settings/default-
config) before sending and receiving messages.

![Sending Endpoint Light](/assets/images/source_endpoint-
light-8b0bf406bdfb15bda0ed1df761f94e25.svg#gh-light-mode-only) ![Sending
Endpoint Dark](/assets/images/source_endpoint-
dark-0a1af3d9ece6ff417fa5d8963e90affd.svg#gh-dark-mode-only)

## Key Functions​

MessageLib offers a simple yet effective verification mechanism:

  1. **Configuration Enforcement** : MessageLib readily accepts messages from the sender [Endpoint](/v2/home/protocol/layerzero-endpoint) and enforces [Message Packet](/v2/home/protocol/packet) generation based on the OApp's configuration.

  2. **Message Emission** : MessageLib enforces which [Security Stack](/v2/developers/evm/protocol-gas-settings/default-config) and [Executors](/v2/home/permissionless-execution/executors) the Endpoint emits to.

  3. **Verification** : On the destination chain, MessageLib ensures the OApp's configured Security Stack has verified the packet before allowing a caller (e.g., Executor) to commit the packet hash to the Endpoint's messaging channel.

**Protocol changes can only be via appending MessageLibs to the MessageLib
Registry, MessageLibs cannot be removed**. This design guarantees that the
security of the protocol will remain unaffected by any new additions, and that
developers will **never** be forced to accept new protocol code.

## Available Libraries​

The latest MessageLib Registry can be found in [MessageLib
Addresses](/v2/developers/evm/technical-reference/deployed-contracts).

### Ultra Light Node 302​

This is the default MessageLib for applications built on Endpoint V2.

### Ultra Light Node 301​

This is a new MessageLib for existing Endpoint V1 applications wanting to
utilize the new Security Stack and Executor.

See the [Migration Guide](/v2/home/v2-migration) to learn how to migrate your
V1 application's MessageLib to Ultra Light Node 301.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/protocol/message-library.md)

[PreviousLayerZero Endpoint](/v2/home/protocol/layerzero-endpoint)[NextMessage
Packet](/v2/home/protocol/packet)

  * Key Functions
  * Available Libraries
    * Ultra Light Node 302
    * Ultra Light Node 301



  * LayerZero V2
  * Welcome

Version: Endpoint V2 Docs

On this page

# Explore LayerZero V2

[LayerZero V2](https://layerzero.network/) is an open-source, immutable
messaging protocol designed to facilitate the creation of omnichain,
interoperable applications.

Developers can easily [send arbitrary data](/v2/home/protocol/contract-
standards#oapp), [external function calls](/v2/developers/evm/oapp/message-
design-patterns), and [tokens](/v2/home/protocol/contract-standards#oft) with
omnichain messaging while preserving full autonomy and control over their
application.

LayerZero V2 is currently live on the following [Mainnet and Testnet
Chains](/v2/developers/evm/technical-reference/deployed-contracts).

[![](/img/icons/build.svg)Getting StartedStart building on LayerZero by
sending your first omnichain message.View More ](/v2/developers/evm/getting-
started)

[![](/img/icons/protocol.svg)Supported ChainsDiscover which chains the
LayerZero V2 Endpoint is live on.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Supported SecuritySee which Decentralized Verifier
Networks (DVNs) can be added to secure your omnichain app.View More
](/v2/developers/evm/technical-reference/dvn-addresses)

[![](/img/icons/Ethereum-logo-test.svg)Solidity DevelopersResources to help
you quickly build, launch, and scale your EVM omnichain applications.View More
](/v2/developers/evm/overview)

[![](/img/icons/solanaLogoMark.svg)Solana DevelopersResources to build your
LayerZero applications on the Solana blockchain.View More
](/v2/developers/solana/overview)

  
  

See the Quickstart Guide below for specific guides on every topic related to
building with the LayerZero protocol.

## Quickstart​

Comprehensive developer guides for every step of your omnichain journey.

[![](/img/icons/build.svg)OApp OverviewBuild your first Omnichain Application
(OApp), using the LayerZero Contract Standards.View More
](/v2/developers/evm/oapp/overview)

[![](/img/icons/build.svg)Build an OFTBuild an Omnichain Fungible Token (OFT)
using familiar fungible token standards.View More
](/v2/developers/evm/oft/quickstart)

[![](/img/icons/build.svg)Estimating Gas FeesGenerate a quote of your
omnichain message gas costs before sending.View More
](/v2/developers/evm/protocol-gas-settings/gas-fees)

[![](/img/icons/config.svg)Generating OptionsBuild message options to control
gas settings, nonce ordering, and more.View More
](/v2/developers/evm/protocol-gas-settings/options)

[![](/img/icons/config.svg)Chain EndpointsThe addresses and endpoint IDs for
every supported chain.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Configure OAppConfigure your Security Stack,
Executors, and other application specific settings.View More
](/v2/developers/evm/protocol-gas-settings/default-config)

[![](/img/icons/testing.svg)Track MessagesFollow your omnichain messages using
LayerZero Scan.View More ](/v2/developers/evm/tooling/layerzeroscan)

[![](/img/icons/testing.svg)TroubleshootingFind answers to common questions
and debugging support.View More
](/v2/developers/evm/troubleshooting/debugging-messages)

[![](/img/icons/testing.svg)Endpoint V1 DocsFind legacy support for LayerZero
Endpoint V1 here.View More ](/v1)

## Security​

LayerZero Labs has an absolute commitment to continuously evaluating and
improving protocol security:

  * [Core contracts are immutable](/v2/home/protocol/layerzero-endpoint) and LayerZero Labs will never deploy upgradeable contracts.

  * While application contracts come pre-configured with an optimal default, application owners can opt out of updates by [modifying and locking protocol configurations](/v2/developers/evm/protocol-gas-settings/default-config#custom-configuration).

  * Protocol updates will always be [optional and backward compatible](/v2/home/protocol/message-library).

LayerZero protocol has been thoroughly audited by leading organizations
building decentralized systems. Browse through [past public
audits](https://github.com/LayerZero-Labs/Audits/tree/main/audits) in our
Github.

## More from LayerZero​

### Questions?​

Join the LayerZero community in our [Discord](https://discord-
layerzero.netlify.app/discord) to ask for help, as well as share your feedback
or showcase what you have built with LayerZero!

### Careers​

LayerZero is growing. If you enjoy using our protocol and have a genuine
interest in omnichain design, please check out [our current job
openings](https://layerzero.network/careers).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/intro.md)

[NextV2 Overview](/v2/home/v2-overview)

  * Quickstart
  * Security
  * More from LayerZero
    * Questions?
    * Careers



  * LayerZero V2
  * Welcome

Version: Endpoint V2 Docs

On this page

# Explore LayerZero V2

[LayerZero V2](https://layerzero.network/) is an open-source, immutable
messaging protocol designed to facilitate the creation of omnichain,
interoperable applications.

Developers can easily [send arbitrary data](/v2/home/protocol/contract-
standards#oapp), [external function calls](/v2/developers/evm/oapp/message-
design-patterns), and [tokens](/v2/home/protocol/contract-standards#oft) with
omnichain messaging while preserving full autonomy and control over their
application.

LayerZero V2 is currently live on the following [Mainnet and Testnet
Chains](/v2/developers/evm/technical-reference/deployed-contracts).

[![](/img/icons/build.svg)Getting StartedStart building on LayerZero by
sending your first omnichain message.View More ](/v2/developers/evm/getting-
started)

[![](/img/icons/protocol.svg)Supported ChainsDiscover which chains the
LayerZero V2 Endpoint is live on.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Supported SecuritySee which Decentralized Verifier
Networks (DVNs) can be added to secure your omnichain app.View More
](/v2/developers/evm/technical-reference/dvn-addresses)

[![](/img/icons/Ethereum-logo-test.svg)Solidity DevelopersResources to help
you quickly build, launch, and scale your EVM omnichain applications.View More
](/v2/developers/evm/overview)

[![](/img/icons/solanaLogoMark.svg)Solana DevelopersResources to build your
LayerZero applications on the Solana blockchain.View More
](/v2/developers/solana/overview)

  
  

See the Quickstart Guide below for specific guides on every topic related to
building with the LayerZero protocol.

## Quickstart​

Comprehensive developer guides for every step of your omnichain journey.

[![](/img/icons/build.svg)OApp OverviewBuild your first Omnichain Application
(OApp), using the LayerZero Contract Standards.View More
](/v2/developers/evm/oapp/overview)

[![](/img/icons/build.svg)Build an OFTBuild an Omnichain Fungible Token (OFT)
using familiar fungible token standards.View More
](/v2/developers/evm/oft/quickstart)

[![](/img/icons/build.svg)Estimating Gas FeesGenerate a quote of your
omnichain message gas costs before sending.View More
](/v2/developers/evm/protocol-gas-settings/gas-fees)

[![](/img/icons/config.svg)Generating OptionsBuild message options to control
gas settings, nonce ordering, and more.View More
](/v2/developers/evm/protocol-gas-settings/options)

[![](/img/icons/config.svg)Chain EndpointsThe addresses and endpoint IDs for
every supported chain.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Configure OAppConfigure your Security Stack,
Executors, and other application specific settings.View More
](/v2/developers/evm/protocol-gas-settings/default-config)

[![](/img/icons/testing.svg)Track MessagesFollow your omnichain messages using
LayerZero Scan.View More ](/v2/developers/evm/tooling/layerzeroscan)

[![](/img/icons/testing.svg)TroubleshootingFind answers to common questions
and debugging support.View More
](/v2/developers/evm/troubleshooting/debugging-messages)

[![](/img/icons/testing.svg)Endpoint V1 DocsFind legacy support for LayerZero
Endpoint V1 here.View More ](/v1)

## Security​

LayerZero Labs has an absolute commitment to continuously evaluating and
improving protocol security:

  * [Core contracts are immutable](/v2/home/protocol/layerzero-endpoint) and LayerZero Labs will never deploy upgradeable contracts.

  * While application contracts come pre-configured with an optimal default, application owners can opt out of updates by [modifying and locking protocol configurations](/v2/developers/evm/protocol-gas-settings/default-config#custom-configuration).

  * Protocol updates will always be [optional and backward compatible](/v2/home/protocol/message-library).

LayerZero protocol has been thoroughly audited by leading organizations
building decentralized systems. Browse through [past public
audits](https://github.com/LayerZero-Labs/Audits/tree/main/audits) in our
Github.

## More from LayerZero​

### Questions?​

Join the LayerZero community in our [Discord](https://discord-
layerzero.netlify.app/discord) to ask for help, as well as share your feedback
or showcase what you have built with LayerZero!

### Careers​

LayerZero is growing. If you enjoy using our protocol and have a genuine
interest in omnichain design, please check out [our current job
openings](https://layerzero.network/careers).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/intro.md)

[NextV2 Overview](/v2/home/v2-overview)

  * Quickstart
  * Security
  * More from LayerZero
    * Questions?
    * Careers



  * Solidity Contracts V2
  * Getting Started

Version: Endpoint V2 Docs

On this page

# Getting Started with Contract Standards

Use LayerZero's **Contract Standards** to easily start sending arbtirary data,
tokens, and external calls using the protocol:

  * [Omnichain Application (OApp)](/v2/developers/evm/oapp/overview): the base contract standard for omnichain messaging and configuration.

  * [Omnichain Fungible Token (OFT)](/v2/developers/evm/oft/quickstart): an extension of `OApp` built for handling and supporting omnichain `ERC20` transfers.

  * [Omnichain Non-Fungible Token (ONFT)](/v2/developers/evm/onft/quickstart): an extension built for handling and supporting omnichain `ERC721` transfers.

Each of these contract standards implement common functions for **sending** ,
**receiving** , and **configuring** omnichain messages via the protocol
interface: the [LayerZero Endpoint](/v2/home/protocol/layerzero-endpoint)
contract.

  * `OAppSender._lzSend`: internal function that calls `EndpointV2.send` to send a message as `bytes`.

  * `OAppReceiver._lzReceive`: internal function that delivers the encoded message as `bytes` after the `Executor` calls `EndpointV2.lzReceive`.

This method of **encoding** send parameters and **decoding** them on the
destination chain is the basis for how all OApps work.

## Example Omnichain Application​

The `OApp` Standard contains both a **send** and **receive** interface.

info

This code snippet is already implemented in the Remix example below. Simply
review this code to understand how it works internally.

    
    
    // SPDX-License-Identifier: MIT  
      
    pragma solidity ^0.8.20;  
      
    // @dev Import the 'MessagingFee' and 'MessagingReceipt' so it's exposed to OApp implementers  
    import { OAppSender, MessagingFee, MessagingReceipt } from "./OAppSender.sol";  
    // @dev Import the 'Origin' so it's exposed to OApp implementers  
    import { OAppReceiver, Origin } from "./OAppReceiver.sol";  
    import { OAppCore } from "./OAppCore.sol";  
      
    /**  
     * @title OApp  
     * @dev Abstract contract serving as the base for OApp implementation, combining OAppSender and OAppReceiver functionality.  
     */  
    abstract contract OApp is OAppSender, OAppReceiver {}  
    

You can use the **Remix IDE** to see how `OAppSender` and `OAppReceiver` work
together for sending and receiving any arbitrary data to supported destination
chains.

#### OAppSender.sol​

[Open in
Remix](https://remix.ethereum.org/#url=https://docs.layerzero.network/LayerZero/contracts/Source.sol&)[What
is Remix?](https://remix-ide.readthedocs.io/en/latest/index.html)

#### OAppReceiver.sol​

[Open in
Remix](https://remix.ethereum.org/#url=https://docs.layerzero.network/LayerZero/contracts/Destination.sol)[What
is Remix?](https://remix-ide.readthedocs.io/en/latest/index.html)

### Prerequisites​

  1. You should first be familiar with writing and deploying contracts to your desired blockchains. This involves understanding the specific smart contract language and the deployment process for those chains.

  2. A wallet set up and funded for the chains you'll be working with.

### Deploying Your Contracts​

We'll deploy the **Source Contract** on `Sepolia`, and the **Destination
Contract** on `Optimism Sepolia`:

info

This example can be used with any EVM-compatible blockchain that LayerZero
supports.

  

  1. Open MetaMask and select the `Ethereum Sepolia` network. Make sure you have native gas in the wallet connected.

  2. In Remix under the **Deploy & Run Transactions** tab, select `Injected Provider - MetaMask` in the Environment list.

  3. Under the Deploy section, fill in the [Endpoint Address](/v2/developers/evm/technical-reference/deployed-contracts) for your current chain.

#### Sepolia Endpoint Address​

    
    
    0x6edce65403992e310a62460808c4b910d972f10f  
    

#### Optimism Sepolia Endpoint Address​

    
    
    0x6edce65403992e310a62460808c4b910d972f10f  
    

  4. Click deploy, follow the MetaMask prompt to confirm the transaction, and wait for the contract address to appear under **Deployed Contracts**.

  5. Repeat the above steps for any other chains you plan to deploy to and connect.

### Connecting Your Contracts​

To connect your OApp deployments together, you will need to call `setPeer` on
both the Ethereum Sepolia and Optimism Sepolia OApp.

The function takes 2 arguments: `_eid`, the **destination** endpoint ID for
the chain our other OApp contract lives on, and `_peer`, the destination OApp
contract address in `bytes32` format.

    
    
    // LayerZero/V2/oapp/contracts/oapp/OAppReceiver.sol  
    // @dev must-have configurations for standard OApps  
    function setPeer(uint32 _eid, bytes32 _peer) public virtual onlyOwner {  
        peers[_eid] = _peer; // Array of peer addresses by destination.  
        emit PeerSet(_eid, _peer); // Event emitted each time a peer is set.  
    }  
    

To `setPeer` on `SourceOApp`, take the `DestinationOApp` address and call
`OApp.addressToBytes32`. Use the returned output as the `_peer`.

Your `_peer` should look something like this:
`0x0000000000000000000000000a3ecc421699e2eb7f53584d07165d95721a4ca7`.

By default, the `OApp` standard inherits `OAppReceiver` which uses this peer
inside `lzReceive` to enforce that the sender is the expected origin address.

    
    
    // LayerZero/V2/oapp/contracts/oapp/OAppCore.sol  
      
    /**  
     * @dev Entry point for receiving messages or packets from the endpoint.  
     * @param _origin The origin information containing the source endpoint and sender address.  
     *  - srcEid: The source chain endpoint ID.  
     *  - sender: The sender address on the src chain.  
     *  - nonce: The nonce of the message.  
     * @param _guid The unique identifier for the received LayerZero message.  
     * @param _message The payload of the received message.  
     * @param _executor The address of the executor for the received message.  
     * @param _extraData Additional arbitrary data provided by the corresponding executor.  
     *  
     * @dev Entry point for receiving msg/packet from the LayerZero endpoint.  
     */  
    function lzReceive(  
        Origin calldata _origin,  
        bytes32 _guid,  
        bytes calldata _message,  
        address _executor,  
        bytes calldata _extraData  
    ) public payable virtual {  
        // Ensures that only the endpoint can attempt to lzReceive() messages to this OApp.  
        if (address(endpoint) != msg.sender) revert OnlyEndpoint(msg.sender);  
      
        // Ensure that the sender matches the expected peer for the source endpoint.  
        if (_getPeerOrRevert(_origin.srcEid) != _origin.sender) revert OnlyPeer(_origin.srcEid, _origin.sender);  
      
        // Call the internal OApp implementation of lzReceive.  
        _lzReceive(_origin, _guid, _message, _executor, _extraData);  
    }  
    

tip

Remember, an EVM `address` is a `bytes20` value, so you must convert your
address to `bytes32` when calling `setPeer`. This can also be easily be done
by [**Zero Padding**](https://ethereum.stackexchange.com/questions/103901/can-
you-convert-my-address-bytes20-type-to-a-bytes32-string) the address until it
is 32 bytes in length.

LayerZero uses `bytes32` for broad compatibility with non-EVM chains.

  

Pass the address of your destination contract as a `bytes32` value, as well as
the destination endpoint ID.

  * To send to Ethereum Sepolia, the Endpoint ID is: `40161`.

  * To send to Optimism Sepolia, the Endpoint ID is: `40232`.

caution

You'll need to repeat this wiring on both contracts in order to send and
receive messages. That means calling `setPeer` on both your `Ethereum Sepolia`
and `Optimism Sepolia` contracts. **Remember to switch networks in MetaMask.**

If successful, you now should be setup to start sending cross-chain messages!

### Estimating Fees​

The LayerZero Protocol gas fees can vary based on your source chain, `DVNs`,
`Executor`, and amount of native gas token you request in `_options`, so you
should estimate fees before sending your first transaction.

The `OApp.quote` function invokes an internal `OAppSender._quote` to estimate
the fees associated with a particular LayerZero transaction using four inputs:

  * `_dstEid`: This is the identifier of the destination chain's endpoint where the transaction is intended to go.

  * `_message`: This is the arbitrary message you intend to send to your destination chain and contract.

  * `_options`: A bytes array that contains serialized execution options that tell the protocol the amount of gas to for the [Executor](/v2/home/permissionless-execution/executors) to send when calling `lzReceive`, as well as other function call related settings.

  * `_payInLzToken`: A boolean which determines whether to return the fee estimate in the native gas token or in ZRO token.

info

In this tutorial, you will deliver `50000` wei for the `lzReceive` call by
passing `0x0003010011010000000000000000000000000000c350` as your `_options`.
You will be quoted `50000` wei on the source chain, which the Executor will
convert to the destination gas token and use in the call. See [**Message
Execution Options**](/v2/developers/evm/protocol-gas-settings/options) for all
possible execution settings.

### Sending Your Message​

To use the `send` function, simply input a string into the `message` field
that you wish to send to your destination chain.

#### Contract A​

Remember to pass the `quote` in Remix under `VALUE` to pay the gas fees on the
source and destination, as well as for the [Security Stack](/v2/home/modular-
security/security-stack-dvns) and Executor who verify and execute the
messages. Then call `SourceOApp.send`!

#### Contract B​

Your message may take a few minutes to appear in the destination block
explorer, depending on which chains you deploy to.

### Tracking Your Message​

Finally, let's see what's happening in our transaction. Take your transaction
hash and paste it into: <https://testnet.layerzeroscan.com/>

You should see `Status: Delivered`, confirming your message has been delivered
to its destination using LayerZero.

**Congrats, you just sent your first omnichain message!** 🥳

### Further Reading​

Now that you understand the basics for how OApps work, you should explore
setting up your development environment and diving deeper into the omnichain
contract standards!

  * [Create LZ OApp Quickstart](/v2/developers/evm/create-lz-oapp/start)

  * [OApp Quickstart](/v2/developers/evm/oapp/overview)

  * [OFT Quickstart](/v2/developers/evm/oft/quickstart)

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/getting-started.md)

[PreviousStart Here](/v2/developers/evm/overview)[NextSending
Tokens](/v2/developers/evm/oft/native-transfer)

  * Example Omnichain Application
    * OAppSender.sol
    * OAppReceiver.sol
    * Prerequisites
    * Deploying Your Contracts
      * Sepolia Endpoint Address
      * Optimism Sepolia Endpoint Address
    * Connecting Your Contracts
    * Estimating Fees
    * Sending Your Message
      * Contract A
      * Contract B
    * Tracking Your Message
    * Further Reading



  * Protocol
  * Contract Standards

Version: Endpoint V2 Docs

On this page

# Contract Standards

Developers can easily start building omnichain applications by inheriting and
extending [LayerZero Contract Standards](/v2/developers/evm/overview) that
seamlessly integrate with the protocol's interfaces.

LayerZero offers a suite of template contracts to expedite the development
process. These templates serve as foundational blueprints for developers to
build upon:

## `OApp`​

The [OApp Contract Standard](/v2/developers/evm/oapp/overview) provides
developers with a generic message passing interface to send and receive
arbitrary pieces of data between contracts existing on different blockchain
networks.

![OApp
Example](/assets/images/ABLight-b6e0a32bf1941c8956b7073f1687dd76.svg#gh-light-
mode-only) ![OApp
Example](/assets/images/ABDark-a499c3ef51835bc97613e2f4cba97f22.svg#gh-dark-
mode-only)

This standard abstracts away the core Endpoint interfaces, allowing you to
focus on your application's core implementation and features without needing a
complex understanding of the LayerZero protocol architecture.

This interface can easily be extended to include anything from specific
financial logic in a DeFi application to a voting mechanism in a DAO, or
broadly any smart contract use case.

## `OFT`​

The [Omnichain Fungible Token (OFT)](/v2/developers/evm/oft/quickstart)
Standard allows **fungible tokens** to be transferred across multiple
blockchains without asset wrapping or middlechains.

This standard works by burning tokens on the source chain whenever an
omnichain transfer is initiated, sending a message via the protocol, and
delivering a function call to the destination contract to mint the same number
of tokens burned. This creates a **unified supply** across all networks
LayerZero supports that the OFT is deployed on.

![OFT
Example](/assets/images/oft_mechanism_light-922b88c364b5156e26edc6def94069f1.jpg#gh-
light-mode-only) ![OFT
Example](/assets/images/oft_mechanism-0894f9bd02de35d6d7ce3d648a2df574.jpg#gh-
dark-mode-only)

Using this design pattern, developers can **extend** any fungible token to
interoperate with other chains using LayerZero. The most widely used of these
standards is `OFT.sol`, an extension of the [OApp Contract
Standard](/v2/developers/evm/oapp/overview) and the [ERC20 Token
Standard](https://docs.openzeppelin.com/contracts/5.x/erc20).

## Configuration​

All Contract Standards offer an opt-in default [OApp
Configuration](/v2/developers/evm/protocol-gas-settings/default-config),
allowing for rapid development without needing complex setup or post-
deployment configuration.

The OApp owner or delegated signer can change or lock your configuration at
any time.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/protocol/contract-standards.md)

[PreviousOmnichain Mesh Network](/v2/home/protocol/mesh-network)[NextLayerZero
Endpoint](/v2/home/protocol/layerzero-endpoint)

  * `OApp`
  * `OFT`
  * Configuration



  * LayerZero V1
  * Introduction

Version: Endpoint V1 Docs

On this page

# Introduction to LayerZero V1

[LayerZero](https://layerzero.network/) is an open-source, immutable messaging
protocol designed to facilitate the creation of omnichain, interoperable
applications.

Developers can easily send arbitrary data, external function calls, and tokens
with omnichain messaging while preserving full autonomy and control over their
application.

info

[**LayerZero V2**](/v2) is now live on both [**Mainnet and
Testnet**](/v2/developers/evm/technical-reference/deployed-contracts),
offering direct improvements for both existing, deployed applications on
Endpoint V1, as well as new features that enhance the creation and scalability
of omnichain applications deployed on the new Endpoint V2.

See the [**LayerZero V2 Documentation**](/v2).

## Where can I find more information?​

For the message protocol design, check out the [V1
Whitepaper](https://layerzero.network/pdf/LayerZero_Whitepaper_Release.pdf)
found on the [website](https://layerzero.network/).

If you are looking for a detailed system architecture explanation, check out
the architectures section on the [Endpoint](/v1/home/concepts/layerzero-
endpoint) and the Ultra-Light Node.

## Code Examples​

Learn how to [integrate LayerZero](/v1/developers/evm/evm-guides/send-
messages) into your contracts and take a look at our deployed contracts for
[Mainnet](/v1/developers/evm/technical-reference/mainnet/mainnet-addresses)
and [Testnet](/v1/developers/evm/technical-reference/testnet/testnet-
addresses) usage. If you want to see some examples to play around head over to
[our Github](https://github.com/LayerZero-Labs/solidity-examples).

  * See how to [send a LayerZero message](/v1/developers/evm/evm-guides/send-messages).
  * Learn how to [move fungible tokens](/v1/developers/evm/evm-guides/contract-standards/oft-overview) using the OFT Standard.
  * Create [omnichain NFTs](/v1/developers/evm/evm-guides/contract-standards/onft-overview) by inheriting the ONFT Standard.

## More from LayerZero​

### Questions?​

Join the LayerZero community in our [Discord](https://discord-
layerzero.netlify.app/discord) to ask for help, as well as share your feedback
or showcase what you have built with LayerZero!

### Careers​

LayerZero is growing. If you enjoy using our protocol and have a genuine
interest in omnichain design, please check out [our current job
openings](https://layerzero.network/careers).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/versioned_docs/version-1.0/home/intro.md)

[NextLayerZero Endpoint](/v1/home/concepts/layerzero-endpoint)

  * Where can I find more information?
  * Code Examples
  * More from LayerZero
    * Questions?
    * Careers



  * Solana Programs V2
  * Overview

Version: Endpoint V2 Docs

On this page

# LayerZero V2 Solana Programs (BETA)

caution

The Solana OFT, Endpoint, and ULN Programs are currently in **Mainnet Beta**!

  

The LayerZero Protocol consists of several programs built on the Solana
blockchain designed to facilitate the secure movement of data, tokens, and
digital assets between different blockchain environments.

LayerZero provides **Solana Programs** that can communicate directly with the
equivalent [Solidity Contract Libraries](/v2/developers/evm/overview) deployed
on EVM-based chains.

#### Solana Programs​

[![](/img/icons/solanaLogoMark.svg)Getting Started on SolanaLearn how the
LayerZero V2 Protocol operates on the Solana blockchain.View More
](/v2/developers/solana/getting-started)

[![](/img/icons/build.svg)OApp ReferenceBuild the Endpoint instructions
necessary for sending arbitrary data and external function calls cross-
chain.View More ](/v2/developers/solana/oapp/overview)

[![](/img/icons/protocol.svg)OFT ProgramCreate and send Omnichain Fungible
Tokens (OFTs) on the Solana blockchain.View More
](/v2/developers/solana/oft/program)

#### Solana Protocol Configurations​

[![](/img/icons/build.svg)Configure Security StackConfigure which
decentralized verifier networks (DVNs) secure your messages.View More
](/v2/developers/solana/configuration/oapp-config#custom-configuration)

[![](/img/icons/protocol.svg)Configure ExecutorConfigure who executes your
messages on the destination chain.View More
](/v2/developers/solana/configuration/oapp-config#custom-configuration)

[![](/img/icons/testing.svg)Set Execution OptionsSet the amount of gas to
deliver to the destination chain.View More ](/v2/developers/solana/gas-
settings/options)

  

info

You can find all [**LayerZero Solana Programs**](https://github.com/LayerZero-
Labs/LayerZero-v2/tree/main/packages/layerzero-v2/solana/programs) here.

### Tooling and Resources​

Solana development relies heavily on Rust and the Solana CLI. For more
information, see an [Overview of Developing Solana
Programs](https://solana.com/docs/programs/overview).

LayerZero provides developer tooling to simplify the contract creation,
testing, and deployment process:

[LayerZero
Scan](http://localhost:3000/v2/developers/evm/tooling/layerzeroscan): a
comprehensive block explorer, search, API, and analytics platform for tracking
and debugging your omnichain transactions.

You can also ask for help or follow development in the
[Discord](https://discord-layerzero.netlify.app/discord).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/solana/overview.md)

[NextGetting Started with Solana](/v2/developers/solana/getting-started)

  * Tooling and Resources



Version: Endpoint V2 Docs

# DVN Addresses

Seamlessly set up and configure your application's [Security
Stack](/v2/home/modular-security/security-stack-dvns) to include the following
Decentralized Verifier Networks (DVNs). To successfully add a DVN to verify a
pathway, that DVN must be deployed on both chains!

tip

For example, if you want to add **LayerZero Lab's DVN** to a pathway from
Ethereum to Base, first you should select:

  * **DVNs** : LayerZero Labs

  * **Chains** : Ethereum, Base

Only if LayerZero Labs is on both chains, can I add that DVN to my Security
Stack.

  

Total DVNs: 35

Download JSON

Network Type:

All

![](/img/icons/chevron.svg)

DVNs:

All

![](/img/icons/chevron.svg)

Chains:

All

![](/img/icons/chevron.svg)

Reset

DVN| Chain| DVN Address  
---|---|---  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/abstract-
testnet.svg)Abstract Testnet|
[0x5dfcab27c1eec1eb07ff987846013f19355a04cb](https://layerzeroscan.com/api/explorer/abstract-
testnet/address/0x5dfcab27c1eec1eb07ff987846013f19355a04cb)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/ape.svg)Ape|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/ape/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/ape.svg)Ape|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/ape/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/01node.svg)01node|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x7a205ed4e3d7f9d0777594501705d8cd405c3b05](https://layerzeroscan.com/api/explorer/arbitrum/address/0x7a205ed4e3d7f9d0777594501705d8cd405c3b05)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/animoca-blockdaemon.svg)Animoca-
Blockdaemon| ![](https://icons-ckg.pages.dev/lz-
scan/networks/arbitrum.svg)Arbitrum Mainnet|
[0xddaa92ce2d2fac3f7c5eae19136e438902ab46cc](https://layerzeroscan.com/api/explorer/arbitrum/address/0xddaa92ce2d2fac3f7c5eae19136e438902ab46cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/axelar.svg)Axelar|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x9d3979c7e3dd26653c52256307709c09f47741e0](https://layerzeroscan.com/api/explorer/arbitrum/address/0x9d3979c7e3dd26653c52256307709c09f47741e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x78203678d264063815dac114ea810e9837cd80f7](https://layerzeroscan.com/api/explorer/arbitrum/address/0x78203678d264063815dac114ea810e9837cd80f7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x4a6b9962945d866f53fd114bb76b38b8791b8c1d](https://layerzeroscan.com/api/explorer/arbitrum/address/0x4a6b9962945d866f53fd114bb76b38b8791b8c1d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/blockhunters.svg)Blockhunters|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0xd074b6bbcbec2f2b4c4265de3d95e521f82bf669](https://layerzeroscan.com/api/explorer/arbitrum/address/0xd074b6bbcbec2f2b4c4265de3d95e521f82bf669)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x9bcd17a654bffaa6f8fea38d19661a7210e22196](https://layerzeroscan.com/api/explorer/arbitrum/address/0x9bcd17a654bffaa6f8fea38d19661a7210e22196)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/delegate.svg)Delegate|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0xdf30c9f6a70ce65a152c5bd09826525d7e97ba49](https://layerzeroscan.com/api/explorer/arbitrum/address/0xdf30c9f6a70ce65a152c5bd09826525d7e97ba49)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/gitcoin.svg)Gitcoin|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x313328609a9c38459cae56625fff7f2ad6dcde3b](https://layerzeroscan.com/api/explorer/arbitrum/address/0x313328609a9c38459cae56625fff7f2ad6dcde3b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/arbitrum/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x19670df5e16bea2ba9b9e68b48c054c5baea06b8](https://layerzeroscan.com/api/explorer/arbitrum/address/0x19670df5e16bea2ba9b9e68b48c054c5baea06b8)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/lagrange-labs.svg)Lagrange|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x021e401c2a1a60618c5e6353a40524971eba1e8d](https://layerzeroscan.com/api/explorer/arbitrum/address/0x021e401c2a1a60618c5e6353a40524971eba1e8d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x2f55c492897526677c5b68fb199ea31e2c126416](https://layerzeroscan.com/api/explorer/arbitrum/address/0x2f55c492897526677c5b68fb199ea31e2c126416)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/luganodes.svg)Luganodes|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x54dd79f5ce72b51fcbbcb170dd01e32034323565](https://layerzeroscan.com/api/explorer/arbitrum/address/0x54dd79f5ce72b51fcbbcb170dd01e32034323565)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mim.svg)MIM| ![](https://icons-
ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum Mainnet|
[0x9e930731cb4a6bf7ecc11f695a295c60bdd212eb](https://layerzeroscan.com/api/explorer/arbitrum/address/0x9e930731cb4a6bf7ecc11f695a295c60bdd212eb)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0xa7b5189bca84cd304d8553977c7c614329750d99](https://layerzeroscan.com/api/explorer/arbitrum/address/0xa7b5189bca84cd304d8553977c7c614329750d99)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nodes-guru.svg)Nodes.Guru|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0xd954bf7968ef68875c9100c9ec890f969504d120](https://layerzeroscan.com/api/explorer/arbitrum/address/0xd954bf7968ef68875c9100c9ec890f969504d120)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omni-x.svg)Omni X|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0xabea0b6b9237b589e676dc16f6d74bf7612591f4](https://layerzeroscan.com/api/explorer/arbitrum/address/0xabea0b6b9237b589e676dc16f6d74bf7612591f4)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omnicat.svg)Omnicat|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0xd1c70192cc0eb9a89e3d9032b9facab259a0a1e9](https://layerzeroscan.com/api/explorer/arbitrum/address/0xd1c70192cc0eb9a89e3d9032b9facab259a0a1e9)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p-ops-team.svg)P-OPS|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x8fa9eef18c2a1459024f0b44714e5acc1ce7f5e8](https://layerzeroscan.com/api/explorer/arbitrum/address/0x8fa9eef18c2a1459024f0b44714e5acc1ce7f5e8)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p2p.svg)P2P| ![](https://icons-
ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum Mainnet|
[0xb3ce0a5d132cd9bf965aba435e650c55edce0062](https://layerzeroscan.com/api/explorer/arbitrum/address/0xb3ce0a5d132cd9bf965aba435e650c55edce0062)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/pearlnet.svg)Pearlnet|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0xabc9b1819cc4d9846550f928b985993cf6240439](https://layerzeroscan.com/api/explorer/arbitrum/address/0xabc9b1819cc4d9846550f928b985993cf6240439)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/planetarium-labs.svg)Planetarium
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0xe6cd8c2e46ef396df88048449e5b1c75172b40c3](https://layerzeroscan.com/api/explorer/arbitrum/address/0xe6cd8c2e46ef396df88048449e5b1c75172b40c3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/arbitrum/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/portal.svg)Portal|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x539008c98b17803a273edf98aba2d4414ee3f4d7](https://layerzeroscan.com/api/explorer/arbitrum/address/0x539008c98b17803a273edf98aba2d4414ee3f4d7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/restake.svg)Restake|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x969a0bdd86a230345ad87a6a381de5ed9e6cda85](https://layerzeroscan.com/api/explorer/arbitrum/address/0x969a0bdd86a230345ad87a6a381de5ed9e6cda85)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mercury.svg)Shrapnel|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x7b8a0fd9d6ae5011d5cbd3e85ed6d5510f98c9bf](https://layerzeroscan.com/api/explorer/arbitrum/address/0x7b8a0fd9d6ae5011d5cbd3e85ed6d5510f98c9bf)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stablelab.svg)StableLab|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0xcd37ca043f8479064e10635020c65ffc005d36f6](https://layerzeroscan.com/api/explorer/arbitrum/address/0xcd37ca043f8479064e10635020c65ffc005d36f6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stakingcabin.svg)StakingCabin|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x6268950b2d11aa0516007b6361f6ee3facb3cb14](https://layerzeroscan.com/api/explorer/arbitrum/address/0x6268950b2d11aa0516007b6361f6ee3facb3cb14)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x5756a74e8e18d8392605ba667171962b2b2826b5](https://layerzeroscan.com/api/explorer/arbitrum/address/0x5756a74e8e18d8392605ba667171962b2b2826b5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/switchboard.svg)Switchboard|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0xcced05c3667877b545285b25f19f794436a1c481](https://layerzeroscan.com/api/explorer/arbitrum/address/0xcced05c3667877b545285b25f19f794436a1c481)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet|
[0x3b65e87e2a4690f14cae0483014259ded8215adc](https://layerzeroscan.com/api/explorer/arbitrum/address/0x3b65e87e2a4690f14cae0483014259ded8215adc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/nova.svg)Arbitrum Nova
Mainnet|
[0x34730f2570e6cff8b1c91faabf37d0dd917c4367](https://layerzeroscan.com/api/explorer/nova/address/0x34730f2570e6cff8b1c91faabf37d0dd917c4367)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/nova.svg)Arbitrum Nova
Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/nova/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/nova.svg)Arbitrum Nova
Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/nova/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/nova.svg)Arbitrum Nova
Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/nova/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/nova.svg)Arbitrum Nova
Mainnet|
[0xb7e97ad5661134185fe608b2a31fe8cef2147ba9](https://layerzeroscan.com/api/explorer/nova/address/0xb7e97ad5661134185fe608b2a31fe8cef2147ba9)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/nova.svg)Arbitrum Nova
Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/nova/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum-sepolia.svg)Arbitrum
Sepolia Testnet|
[0x0fbb88ff8d38cd1e917149cd14076852f13e088e](https://layerzeroscan.com/api/explorer/arbitrum-
sepolia/address/0x0fbb88ff8d38cd1e917149cd14076852f13e088e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum-sepolia.svg)Arbitrum
Sepolia Testnet|
[0x9f529527a6810f1b661fb2aeea19378ce5a2c23e](https://layerzeroscan.com/api/explorer/arbitrum-
sepolia/address/0x9f529527a6810f1b661fb2aeea19378ce5a2c23e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/joc.svg)Japan Blockchain
Foundation| ![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum-
sepolia.svg)Arbitrum Sepolia Testnet|
[0x7c84feb58183d3865e4e01d1b6c22ba2d227dc23](https://layerzeroscan.com/api/explorer/arbitrum-
sepolia/address/0x7c84feb58183d3865e4e01d1b6c22ba2d227dc23)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum-
sepolia.svg)Arbitrum Sepolia Testnet|
[0x53f488e93b4f1b60e8e83aa374dbe1780a1ee8a8](https://layerzeroscan.com/api/explorer/arbitrum-
sepolia/address/0x53f488e93b4f1b60e8e83aa374dbe1780a1ee8a8)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/astar.svg)Astar Mainnet|
[0x7a7ddc46882220a075934f40380d3a7e1e87d409](https://layerzeroscan.com/api/explorer/astar/address/0x7a7ddc46882220a075934f40380d3a7e1e87d409)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/astar.svg)Astar Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/astar/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/astar.svg)Astar Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/astar/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/astar.svg)Astar
Mainnet|
[0xe1975c47779edaaaba31f64934a33affd3ce15c2](https://layerzeroscan.com/api/explorer/astar/address/0xe1975c47779edaaaba31f64934a33affd3ce15c2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/astar.svg)Astar Mainnet|
[0xb19a9370d404308040a9760678c8ca28affbbb76](https://layerzeroscan.com/api/explorer/astar/address/0xb19a9370d404308040a9760678c8ca28affbbb76)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/astar-testnet.svg)Astar
Testnet|
[0x44f29fa5237e6ba7bc6dd2fbe758e11ddc5e67a6](https://layerzeroscan.com/api/explorer/astar-
testnet/address/0x44f29fa5237e6ba7bc6dd2fbe758e11ddc5e67a6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/astar-testnet.svg)Astar
Testnet|
[0x190deb4f8555872b454920d6047a04006eee4ca9](https://layerzeroscan.com/api/explorer/astar-
testnet/address/0x190deb4f8555872b454920d6047a04006eee4ca9)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/zkatana.svg)Astar zkEVM
Mainnet|
[0x0131a4ce592e5f5eabb08e62b1ceeb9bafeba036](https://layerzeroscan.com/api/explorer/zkatana/address/0x0131a4ce592e5f5eabb08e62b1ceeb9bafeba036)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/zkatana.svg)Astar zkEVM
Mainnet|
[0xce8358bc28dd8296ce8caf1cd2b44787abd65887](https://layerzeroscan.com/api/explorer/zkatana/address/0xce8358bc28dd8296ce8caf1cd2b44787abd65887)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/zkastar-
testnet.svg)Astar zkEVM Testnet|
[0x12523de19dc41c91f7d2093e0cfbb76b17012c8d](https://layerzeroscan.com/api/explorer/zkastar-
testnet/address/0x12523de19dc41c91f7d2093e0cfbb76b17012c8d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/aurora-
testnet.svg)Aurora Testnet|
[0x988d898a9acf43f61fdbc72aad6eb3f0542e19e1](https://layerzeroscan.com/api/explorer/aurora-
testnet/address/0x988d898a9acf43f61fdbc72aad6eb3f0542e19e1)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuji.svg)Avalanche Fuji
Testnet|
[0x8ca279897cde74350bd880737fd60c047d6d3d64](https://layerzeroscan.com/api/explorer/fuji/address/0x8ca279897cde74350bd880737fd60c047d6d3d64)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuji.svg)Avalanche Fuji
Testnet|
[0x0d88ab4c8e8f89d8d758cbd5a6373f86f7bd737b](https://layerzeroscan.com/api/explorer/fuji/address/0x0d88ab4c8e8f89d8d758cbd5a6373f86f7bd737b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/delegate.svg)Delegate|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuji.svg)Avalanche Fuji
Testnet|
[0xe0f3389bf8a8aa1576b420d888cd462483fdc2a0](https://layerzeroscan.com/api/explorer/fuji/address/0xe0f3389bf8a8aa1576b420d888cd462483fdc2a0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/gitcoin.svg)Gitcoin|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuji.svg)Avalanche Fuji
Testnet|
[0x071fbf35b35d48afc3edf84f0397980c25531560](https://layerzeroscan.com/api/explorer/fuji/address/0x071fbf35b35d48afc3edf84f0397980c25531560)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuji.svg)Avalanche Fuji
Testnet|
[0xa4652582077afc447ea7c9e984d656ee4963fe95](https://layerzeroscan.com/api/explorer/fuji/address/0xa4652582077afc447ea7c9e984d656ee4963fe95)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/fuji.svg)Avalanche Fuji
Testnet|
[0x9f0e79aeb198750f963b6f30b99d87c6ee5a0467](https://layerzeroscan.com/api/explorer/fuji/address/0x9f0e79aeb198750f963b6f30b99d87c6ee5a0467)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuji.svg)Avalanche Fuji
Testnet|
[0x7883f83ea40a56137a63baf93bfee5b9b8c1c447](https://layerzeroscan.com/api/explorer/fuji/address/0x7883f83ea40a56137a63baf93bfee5b9b8c1c447)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p2p.svg)P2P| ![](https://icons-
ckg.pages.dev/lz-scan/networks/fuji.svg)Avalanche Fuji Testnet|
[0xdbec329a5e6d7fb0113eb0a098750d2afd61e9ae](https://layerzeroscan.com/api/explorer/fuji/address/0xdbec329a5e6d7fb0113eb0a098750d2afd61e9ae)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/republic-crypto.svg)Republic|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuji.svg)Avalanche Fuji
Testnet|
[0xefdd92121acb3acd6e2f09dd810752d8da3dfdaf](https://layerzeroscan.com/api/explorer/fuji/address/0xefdd92121acb3acd6e2f09dd810752d8da3dfdaf)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stablelab.svg)StableLab|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuji.svg)Avalanche Fuji
Testnet|
[0xfde647565009b33b1df02689d5873bffff15d907](https://layerzeroscan.com/api/explorer/fuji/address/0xfde647565009b33b1df02689d5873bffff15d907)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/switchboard.svg)Switchboard|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuji.svg)Avalanche Fuji
Testnet|
[0xca5ab7adcd3ea879f1a1c4eee81eaccd250173e4](https://layerzeroscan.com/api/explorer/fuji/address/0xca5ab7adcd3ea879f1a1c4eee81eaccd250173e4)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/01node.svg)01node|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0xa80aa110f05c9c6140018aae0c4e08a70f43350d](https://layerzeroscan.com/api/explorer/avalanche/address/0xa80aa110f05c9c6140018aae0c4e08a70f43350d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/animoca-blockdaemon.svg)Animoca-
Blockdaemon| ![](https://icons-ckg.pages.dev/lz-
scan/networks/avalanche.svg)Avalanche Mainnet|
[0xffe42dc3927a240f3459e5ec27eaabd88727173e](https://layerzeroscan.com/api/explorer/avalanche/address/0xffe42dc3927a240f3459e5ec27eaabd88727173e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/axelar.svg)Axelar|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0xc390fd7ca590a505655eb6c454ed0783c99a2ea9](https://layerzeroscan.com/api/explorer/avalanche/address/0xc390fd7ca590a505655eb6c454ed0783c99a2ea9)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x7b8a0fd9d6ae5011d5cbd3e85ed6d5510f98c9bf](https://layerzeroscan.com/api/explorer/avalanche/address/0x7b8a0fd9d6ae5011d5cbd3e85ed6d5510f98c9bf)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x07ff86c392588254ad10f0811dbbcad45f4c7d87](https://layerzeroscan.com/api/explorer/avalanche/address/0x07ff86c392588254ad10f0811dbbcad45f4c7d87)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/blockhunters.svg)Blockhunters|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0xd074b6bbcbec2f2b4c4265de3d95e521f82bf669](https://layerzeroscan.com/api/explorer/avalanche/address/0xd074b6bbcbec2f2b4c4265de3d95e521f82bf669)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0xcff5b0608fa638333f66e0da9d4f1eb906ac18e3](https://layerzeroscan.com/api/explorer/avalanche/address/0xcff5b0608fa638333f66e0da9d4f1eb906ac18e3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/ccip.svg)Chainlink CCIP|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0xd46270746acbca85dab8de1ce1d71c46c2f2994c](https://layerzeroscan.com/api/explorer/avalanche/address/0xd46270746acbca85dab8de1ce1d71c46c2f2994c)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/delegate.svg)Delegate|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x83d06212b6647b0d0865e730270751e3fdf5036e](https://layerzeroscan.com/api/explorer/avalanche/address/0x83d06212b6647b0d0865e730270751e3fdf5036e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/gitcoin.svg)Gitcoin|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0xcced05c3667877b545285b25f19f794436a1c481](https://layerzeroscan.com/api/explorer/avalanche/address/0xcced05c3667877b545285b25f19f794436a1c481)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/avalanche/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x07c05eab7716acb6f83ebf6268f8eecda8892ba1](https://layerzeroscan.com/api/explorer/avalanche/address/0x07c05eab7716acb6f83ebf6268f8eecda8892ba1)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x962f502a63f5fbeb44dc9ab932122648e8352959](https://layerzeroscan.com/api/explorer/avalanche/address/0x962f502a63f5fbeb44dc9ab932122648e8352959)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/luganodes.svg)Luganodes|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0xe4193136b92ba91402313e95347c8e9fad8d27d0](https://layerzeroscan.com/api/explorer/avalanche/address/0xe4193136b92ba91402313e95347c8e9fad8d27d0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mim.svg)MIM| ![](https://icons-
ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche Mainnet|
[0xf45742bbfabcee739ea2a2d0ba2dd140f1f2c6a3](https://layerzeroscan.com/api/explorer/avalanche/address/0xf45742bbfabcee739ea2a2d0ba2dd140f1f2c6a3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0xa59ba433ac34d2927232918ef5b2eaafcf130ba5](https://layerzeroscan.com/api/explorer/avalanche/address/0xa59ba433ac34d2927232918ef5b2eaafcf130ba5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nocturnal-labs.svg)Nocturnal
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x0ae4e6a9a8b01ee22c6a49af22b674a4e033a23d](https://layerzeroscan.com/api/explorer/avalanche/address/0x0ae4e6a9a8b01ee22c6a49af22b674a4e033a23d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nodes-guru.svg)Nodes.Guru|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0xd251d8a85cdfc84518b9454ee6a8d017e503f56c](https://layerzeroscan.com/api/explorer/avalanche/address/0xd251d8a85cdfc84518b9454ee6a8d017e503f56c)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omni-x.svg)Omni X|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x21caf0bce846aaa78c9f23c5a4ec5988ecbf9988](https://layerzeroscan.com/api/explorer/avalanche/address/0x21caf0bce846aaa78c9f23c5a4ec5988ecbf9988)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p-ops-team.svg)P-OPS|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x2b8cbea81315130a4c422e875063362640ddfeb0](https://layerzeroscan.com/api/explorer/avalanche/address/0x2b8cbea81315130a4c422e875063362640ddfeb0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p2p.svg)P2P| ![](https://icons-
ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche Mainnet|
[0xe94ae34dfcc87a61836938641444080b98402c75](https://layerzeroscan.com/api/explorer/avalanche/address/0xe94ae34dfcc87a61836938641444080b98402c75)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/pearlnet.svg)Pearlnet|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0xd24972c11f91c1bb9eaee97ec96bb9c33cf7af24](https://layerzeroscan.com/api/explorer/avalanche/address/0xd24972c11f91c1bb9eaee97ec96bb9c33cf7af24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/planetarium-labs.svg)Planetarium
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x2ac038606fff3fb00317b8f0ccfb4081694acdd0](https://layerzeroscan.com/api/explorer/avalanche/address/0x2ac038606fff3fb00317b8f0ccfb4081694acdd0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/avalanche/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/portal.svg)Portal|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x0e95cf21ad9376a26997c97f326c5a0a267bb8ff](https://layerzeroscan.com/api/explorer/avalanche/address/0x0e95cf21ad9376a26997c97f326c5a0a267bb8ff)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/republic-crypto.svg)Republic|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x1feb08b1a53a9710afce82d380b8c2833c69a37e](https://layerzeroscan.com/api/explorer/avalanche/address/0x1feb08b1a53a9710afce82d380b8c2833c69a37e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/restake.svg)Restake|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x377b51593a03b82543c1508fe7e75aba6acde008](https://layerzeroscan.com/api/explorer/avalanche/address/0x377b51593a03b82543c1508fe7e75aba6acde008)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mercury.svg)Shrapnel|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x6a110d94e1baa6984a3d904bab37ae49b90e6b4f](https://layerzeroscan.com/api/explorer/avalanche/address/0x6a110d94e1baa6984a3d904bab37ae49b90e6b4f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stablelab.svg)StableLab|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x5fddd320a1e29bb466fa635661b125d51d976f92](https://layerzeroscan.com/api/explorer/avalanche/address/0x5fddd320a1e29bb466fa635661b125d51d976f92)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stakingcabin.svg)StakingCabin|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x54dd79f5ce72b51fcbbcb170dd01e32034323565](https://layerzeroscan.com/api/explorer/avalanche/address/0x54dd79f5ce72b51fcbbcb170dd01e32034323565)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x252b234545e154543ad2784c7111eb90406be836](https://layerzeroscan.com/api/explorer/avalanche/address/0x252b234545e154543ad2784c7111eb90406be836)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/switchboard.svg)Switchboard|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0x92ef4381a03372985985e70fb15e9f081e2e8d14](https://layerzeroscan.com/api/explorer/avalanche/address/0x92ef4381a03372985985e70fb15e9f081e2e8d14)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet|
[0xe552485d02edd3067fe7fcbd4dd56bb1d3a998d2](https://layerzeroscan.com/api/explorer/avalanche/address/0xe552485d02edd3067fe7fcbd4dd56bb1d3a998d2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bahamut-
testnet.svg)Bahamut Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/bahamut-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0xb3ce0a5d132cd9bf965aba435e650c55edce0062](https://layerzeroscan.com/api/explorer/base/address/0xb3ce0a5d132cd9bf965aba435e650c55edce0062)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0x7a3d18e2324536294cd6f054cdde7c994f40391a](https://layerzeroscan.com/api/explorer/base/address/0x7a3d18e2324536294cd6f054cdde7c994f40391a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/base/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/base/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0xa7b5189bca84cd304d8553977c7c614329750d99](https://layerzeroscan.com/api/explorer/base/address/0xa7b5189bca84cd304d8553977c7c614329750d99)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/lagrange-labs.svg)Lagrange|
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0xc50a49186aa80427aa3b0d3c2cec19ba64222a29](https://layerzeroscan.com/api/explorer/base/address/0xc50a49186aa80427aa3b0d3c2cec19ba64222a29)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0x9e059a54699a285714207b43b055483e78faac25](https://layerzeroscan.com/api/explorer/base/address/0x9e059a54699a285714207b43b055483e78faac25)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0xcd37ca043f8479064e10635020c65ffc005d36f6](https://layerzeroscan.com/api/explorer/base/address/0xcd37ca043f8479064e10635020c65ffc005d36f6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omni-x.svg)Omni X|
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0xeede111103535e473451311e26c3e6660b0f77e1](https://layerzeroscan.com/api/explorer/base/address/0xeede111103535e473451311e26c3e6660b0f77e1)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omnicat.svg)Omnicat|
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0xe6cd8c2e46ef396df88048449e5b1c75172b40c3](https://layerzeroscan.com/api/explorer/base/address/0xe6cd8c2e46ef396df88048449e5b1c75172b40c3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/base/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0xcdf31d62140204c08853b547e64707110fbc6680](https://layerzeroscan.com/api/explorer/base/address/0xcdf31d62140204c08853b547e64707110fbc6680)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet|
[0x9e930731cb4a6bf7ecc11f695a295c60bdd212eb](https://layerzeroscan.com/api/explorer/base/address/0x9e930731cb4a6bf7ecc11f695a295c60bdd212eb)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/base-sepolia.svg)Base Sepolia
Testnet|
[0xfa1a1804effec9000f75cd15d16d18b05738d467](https://layerzeroscan.com/api/explorer/base-
sepolia/address/0xfa1a1804effec9000f75cd15d16d18b05738d467)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/base-sepolia.svg)Base
Sepolia Testnet|
[0xe1a12515f9ab2764b887bf60b923ca494ebbb2d6](https://layerzeroscan.com/api/explorer/base-
sepolia/address/0xe1a12515f9ab2764b887bf60b923ca494ebbb2d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bartio.svg)Berachain
Bartio Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/bartio/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/besu1-testnet.svg)Besu1
Testnet|
[0xb0487596a0b62d1a71d0c33294bd6eb635fc6b09](https://layerzeroscan.com/api/explorer/besu1-testnet/address/0xb0487596a0b62d1a71d0c33294bd6eb635fc6b09)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bevm.svg)Bevm|
[0x9c061c9a4782294eef65ef28cb88233a987f4bdd](https://layerzeroscan.com/api/explorer/bevm/address/0x9c061c9a4782294eef65ef28cb88233a987f4bdd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bevm-testnet.svg)Bevm
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/bevm-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/01node.svg)01node|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x8fc629aa400d4d9c0b118f2685a49316552abf27](https://layerzeroscan.com/api/explorer/bsc/address/0x8fc629aa400d4d9c0b118f2685a49316552abf27)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/animoca-blockdaemon.svg)Animoca-
Blockdaemon| ![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance
Smart Chain Mainnet|
[0x313328609a9c38459cae56625fff7f2ad6dcde3b](https://layerzeroscan.com/api/explorer/bsc/address/0x313328609a9c38459cae56625fff7f2ad6dcde3b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/axelar.svg)Axelar|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x878c20d3685cdbc5e2680a8a0e7fb97389344fe1](https://layerzeroscan.com/api/explorer/bsc/address/0x878c20d3685cdbc5e2680a8a0e7fb97389344fe1)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xd36246c322ee102a2203bca9cafb84c179d306f6](https://layerzeroscan.com/api/explorer/bsc/address/0xd36246c322ee102a2203bca9cafb84c179d306f6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xd791948db16ab4373fa394b74c727ddb7fb02520](https://layerzeroscan.com/api/explorer/bsc/address/0xd791948db16ab4373fa394b74c727ddb7fb02520)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/blockhunters.svg)Blockhunters|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x547bf6889b1095b7cc6e525a1f8e8fdb26134a38](https://layerzeroscan.com/api/explorer/bsc/address/0x547bf6889b1095b7cc6e525a1f8e8fdb26134a38)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xfe1cd27827e16b07e61a4ac96b521bdb35e00328](https://layerzeroscan.com/api/explorer/bsc/address/0xfe1cd27827e16b07e61a4ac96b521bdb35e00328)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/ccip.svg)Chainlink CCIP|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x53561bcfe6b3f23bc72e5b9919c12322729942e8](https://layerzeroscan.com/api/explorer/bsc/address/0x53561bcfe6b3f23bc72e5b9919c12322729942e8)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/delegate.svg)Delegate|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x9eeee79f5dbc4d99354b5cb547c138af432f937b](https://layerzeroscan.com/api/explorer/bsc/address/0x9eeee79f5dbc4d99354b5cb547c138af432f937b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/gitcoin.svg)Gitcoin|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x2afa3787cd95fee5d5753cd717ef228eb259f4ea](https://layerzeroscan.com/api/explorer/bsc/address/0x2afa3787cd95fee5d5753cd717ef228eb259f4ea)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/bsc/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x247624e2143504730aec22912ed41f092498bef2](https://layerzeroscan.com/api/explorer/bsc/address/0x247624e2143504730aec22912ed41f092498bef2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart
Chain Mainnet|
[0xfd6865c841c2d64565562fcc7e05e619a30615f0](https://layerzeroscan.com/api/explorer/bsc/address/0xfd6865c841c2d64565562fcc7e05e619a30615f0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/luganodes.svg)Luganodes|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x2c7185f5b0976397d9eb5c19d639d4005e6708f0](https://layerzeroscan.com/api/explorer/bsc/address/0x2c7185f5b0976397d9eb5c19d639d4005e6708f0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mim.svg)MIM| ![](https://icons-
ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain Mainnet|
[0x25e0e650a78e6304a3983fc4b7ffc6544b1beea6](https://layerzeroscan.com/api/explorer/bsc/address/0x25e0e650a78e6304a3983fc4b7ffc6544b1beea6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x31f748a368a893bdb5abb67ec95f232507601a73](https://layerzeroscan.com/api/explorer/bsc/address/0x31f748a368a893bdb5abb67ec95f232507601a73)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nodes-guru.svg)Nodes.Guru|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x1bab20e7fdc79257729cb596bef85db76c44915e](https://layerzeroscan.com/api/explorer/bsc/address/0x1bab20e7fdc79257729cb596bef85db76c44915e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omni-x.svg)Omni X|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x5a4c666e9c7aa86fd4fbfdfbfd04646dcc45c6c5](https://layerzeroscan.com/api/explorer/bsc/address/0x5a4c666e9c7aa86fd4fbfdfbfd04646dcc45c6c5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omnicat.svg)Omnicat|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xdff3f73c260b3361d4f006b02972c6af6c5c5417](https://layerzeroscan.com/api/explorer/bsc/address/0xdff3f73c260b3361d4f006b02972c6af6c5c5417)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p-ops-team.svg)P-OPS|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x33e5fcc13d7439cc62d54c41aa966197145b3cd7](https://layerzeroscan.com/api/explorer/bsc/address/0x33e5fcc13d7439cc62d54c41aa966197145b3cd7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p2p.svg)P2P| ![](https://icons-
ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain Mainnet|
[0x439264fb87581a70bb6d7befd16b636521b0ad2d](https://layerzeroscan.com/api/explorer/bsc/address/0x439264fb87581a70bb6d7befd16b636521b0ad2d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/planetarium-labs.svg)Planetarium
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart
Chain Mainnet|
[0x05aaefdf9db6e0f7d27fa3b6ee099edb33da029e](https://layerzeroscan.com/api/explorer/bsc/address/0x05aaefdf9db6e0f7d27fa3b6ee099edb33da029e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/bsc/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/portal.svg)Portal|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xbd40c9047980500c46b8aed4462e2f889299febe](https://layerzeroscan.com/api/explorer/bsc/address/0xbd40c9047980500c46b8aed4462e2f889299febe)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/republic-crypto.svg)Republic|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xf7ddee427507cdb6885e53caaaa1973b1fe29357](https://layerzeroscan.com/api/explorer/bsc/address/0xf7ddee427507cdb6885e53caaaa1973b1fe29357)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/restake.svg)Restake|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0x4d52f5bc932cf1a854381a85ad9ed79b8497c153](https://layerzeroscan.com/api/explorer/bsc/address/0x4d52f5bc932cf1a854381a85ad9ed79b8497c153)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mercury.svg)Shrapnel|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xb4fa7f1c67e5ec99b556ec92cbddbcdd384106f2](https://layerzeroscan.com/api/explorer/bsc/address/0xb4fa7f1c67e5ec99b556ec92cbddbcdd384106f2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stablelab.svg)StableLab|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xabc9b1819cc4d9846550f928b985993cf6240439](https://layerzeroscan.com/api/explorer/bsc/address/0xabc9b1819cc4d9846550f928b985993cf6240439)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stakingcabin.svg)StakingCabin|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xd841a741addcb6dea735d3b8c9faf96ba3f3d30d](https://layerzeroscan.com/api/explorer/bsc/address/0xd841a741addcb6dea735d3b8c9faf96ba3f3d30d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xac8de74ce0a44a5e73bbc709fe800406f58431e0](https://layerzeroscan.com/api/explorer/bsc/address/0xac8de74ce0a44a5e73bbc709fe800406f58431e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/switchboard.svg)Switchboard|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xf0809f6e760a5452ee567975eda7a28da4a83d38](https://layerzeroscan.com/api/explorer/bsc/address/0xf0809f6e760a5452ee567975eda7a28da4a83d38)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet|
[0xe5491fac6965aa664efd6d1ae5e7d1d56da4fdda](https://layerzeroscan.com/api/explorer/bsc/address/0xe5491fac6965aa664efd6d1ae5e7d1d56da4fdda)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance Smart
Chain Testnet|
[0x16b711e3284e7c1d3b7eed25871584ad8d946cac](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x16b711e3284e7c1d3b7eed25871584ad8d946cac)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance Smart
Chain Testnet|
[0x35fa068ec18631719a7f6253710ba29ab5c5f3b7](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x35fa068ec18631719a7f6253710ba29ab5c5f3b7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/delegate.svg)Delegate|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance Smart
Chain Testnet|
[0xcd02c60d6a23966bd74d435df235a941b35f4f5f](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0xcd02c60d6a23966bd74d435df235a941b35f4f5f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/gitcoin.svg)Gitcoin|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance Smart
Chain Testnet|
[0x6f978ee5bfd7b1a8085a3ea9e54eb76e668e195a](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x6f978ee5bfd7b1a8085a3ea9e54eb76e668e195a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance Smart
Chain Testnet|
[0x6f99ea3fc9206e2779249e15512d7248dab0b52e](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x6f99ea3fc9206e2779249e15512d7248dab0b52e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance
Smart Chain Testnet|
[0x0ee552262f7b562efced6dd4a7e2878ab897d405](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x0ee552262f7b562efced6dd4a7e2878ab897d405)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance Smart
Chain Testnet|
[0x6334290b7b4a365f3c0e79c85b1b42f078db78e4](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x6334290b7b4a365f3c0e79c85b1b42f078db78e4)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p2p.svg)P2P| ![](https://icons-
ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance Smart Chain Testnet|
[0xd0a6fd2e542945d81d4ed82d8f4d25cc09c65f7f](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0xd0a6fd2e542945d81d4ed82d8f4d25cc09c65f7f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance Smart
Chain Testnet|
[0x2ddf08e397541721acd82e5b8a1d0775454a180b](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x2ddf08e397541721acd82e5b8a1d0775454a180b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/republic-crypto.svg)Republic|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance Smart
Chain Testnet|
[0x33ba0e70d74c72d3633870904244b57edfb35df7](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x33ba0e70d74c72d3633870904244b57edfb35df7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stablelab.svg)StableLab|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance Smart
Chain Testnet|
[0xd05c27f2e47fbba82adaac2a5adb71ba57a5b933](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0xd05c27f2e47fbba82adaac2a5adb71ba57a5b933)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/switchboard.svg)Switchboard|
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance Smart
Chain Testnet|
[0x4ecbb26142a1f2233aeee417fd2f4fb0ec6e0d78](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x4ecbb26142a1f2233aeee417fd2f4fb0ec6e0d78)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bitlayer.svg)Bitlayer|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/bitlayer/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bitlayer-
testnet.svg)Bitlayer Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/bitlayer-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/axelar.svg)Axelar|
![](https://icons-ckg.pages.dev/lz-scan/networks/blast.svg)Blast Mainnet|
[0xb830a5afcbebb936c30c607a18bbba9f5b0a592f](https://layerzeroscan.com/api/explorer/blast/address/0xb830a5afcbebb936c30c607a18bbba9f5b0a592f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/blast.svg)Blast Mainnet|
[0xabc9b1819cc4d9846550f928b985993cf6240439](https://layerzeroscan.com/api/explorer/blast/address/0xabc9b1819cc4d9846550f928b985993cf6240439)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/blast.svg)Blast Mainnet|
[0x70bf42c69173d6e33b834f59630dac592c70b369](https://layerzeroscan.com/api/explorer/blast/address/0x70bf42c69173d6e33b834f59630dac592c70b369)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/blast.svg)Blast
Mainnet|
[0xc097ab8cd7b053326dfe9fb3e3a31a0cce3b526f](https://layerzeroscan.com/api/explorer/blast/address/0xc097ab8cd7b053326dfe9fb3e3a31a0cce3b526f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/blast.svg)Blast Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/blast/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omnicat.svg)Omnicat|
![](https://icons-ckg.pages.dev/lz-scan/networks/blast.svg)Blast Mainnet|
[0x25e0e650a78e6304a3983fc4b7ffc6544b1beea6](https://layerzeroscan.com/api/explorer/blast/address/0x25e0e650a78e6304a3983fc4b7ffc6544b1beea6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/blast.svg)Blast Mainnet|
[0x0ff4cc28826356503bb79c00637bec0ee006f237](https://layerzeroscan.com/api/explorer/blast/address/0x0ff4cc28826356503bb79c00637bec0ee006f237)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/blast.svg)Blast Mainnet|
[0x1383981c78393b36f59c4f8f4f12f1b4eb249ebf](https://layerzeroscan.com/api/explorer/blast/address/0x1383981c78393b36f59c4f8f4f12f1b4eb249ebf)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/blast-testnet.svg)Blast
Testnet|
[0x939afd54a8547078dbea02b683a7f1fdc929f853](https://layerzeroscan.com/api/explorer/blast-
testnet/address/0x939afd54a8547078dbea02b683a7f1fdc929f853)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/ble-testnet.svg)Ble
Testnet|
[0x12523de19dc41c91f7d2093e0cfbb76b17012c8d](https://layerzeroscan.com/api/explorer/ble-
testnet/address/0x12523de19dc41c91f7d2093e0cfbb76b17012c8d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/bob.svg)Bob Mainnet|
[0x58dff8622759ea75910a08dba5d060579271dcd7](https://layerzeroscan.com/api/explorer/bob/address/0x58dff8622759ea75910a08dba5d060579271dcd7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/bob.svg)Bob Mainnet|
[0xf2067660520f79eb7a8326dc1266dce0167d64e7](https://layerzeroscan.com/api/explorer/bob/address/0xf2067660520f79eb7a8326dc1266dce0167d64e7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bob.svg)Bob Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/bob/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/bob.svg)Bob Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/bob/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bob-testnet.svg)Bob
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/bob-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/botanix-
testnet.svg)Botanix Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/botanix-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bouncebit-
testnet.svg)Bouncebit Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/bouncebit-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/camp-testnet.svg)Camp
Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/camp-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/canto.svg)Canto Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/canto/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/canto.svg)Canto Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/canto/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/canto.svg)Canto
Mainnet|
[0x1bacc2205312534375c8d1801c27d28370656cff](https://layerzeroscan.com/api/explorer/canto/address/0x1bacc2205312534375c8d1801c27d28370656cff)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/canto.svg)Canto Mainnet|
[0x809cde2afcf8627312e87a6a7bbffab3f8f347c7](https://layerzeroscan.com/api/explorer/canto/address/0x809cde2afcf8627312e87a6a7bbffab3f8f347c7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omnicat.svg)Omnicat|
![](https://icons-ckg.pages.dev/lz-scan/networks/canto.svg)Canto Mainnet|
[0x25e0e650a78e6304a3983fc4b7ffc6544b1beea6](https://layerzeroscan.com/api/explorer/canto/address/0x25e0e650a78e6304a3983fc4b7ffc6544b1beea6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/canto-testnet.svg)Canto
Testnet|
[0x032457e2c87376ad1d0ae8bbada45d178c9968b3](https://layerzeroscan.com/api/explorer/canto-
testnet/address/0x032457e2c87376ad1d0ae8bbada45d178c9968b3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/alfajores.svg)Celo
Alfajores Testnet|
[0xbef132bc69c87f52d173d093a3f8b5b98842275f](https://layerzeroscan.com/api/explorer/alfajores/address/0xbef132bc69c87f52d173d093a3f8b5b98842275f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/alfajores.svg)Celo Alfajores
Testnet|
[0x449391d6812bce0b0b86d32d752035ff5be3f159](https://layerzeroscan.com/api/explorer/alfajores/address/0x449391d6812bce0b0b86d32d752035ff5be3f159)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/celo.svg)Celo Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/celo/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/celo.svg)Celo Mainnet|
[0x31f748a368a893bdb5abb67ec95f232507601a73](https://layerzeroscan.com/api/explorer/celo/address/0x31f748a368a893bdb5abb67ec95f232507601a73)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/celo.svg)Celo Mainnet|
[0x75b073994560a5c03cd970414d9170be0c6e5c36](https://layerzeroscan.com/api/explorer/celo/address/0x75b073994560a5c03cd970414d9170be0c6e5c36)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/celo.svg)Celo Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/celo/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/celo.svg)Celo Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/celo/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/celo.svg)Celo Mainnet|
[0x1383981c78393b36f59c4f8f4f12f1b4eb249ebf](https://layerzeroscan.com/api/explorer/celo/address/0x1383981c78393b36f59c4f8f4f12f1b4eb249ebf)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/codex.svg)Codex|
[0xabc9b1819cc4d9846550f928b985993cf6240439](https://layerzeroscan.com/api/explorer/codex/address/0xabc9b1819cc4d9846550f928b985993cf6240439)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/codex.svg)Codex|
[0x9c061c9a4782294eef65ef28cb88233a987f4bdd](https://layerzeroscan.com/api/explorer/codex/address/0x9c061c9a4782294eef65ef28cb88233a987f4bdd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/codex-testnet.svg)Codex
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/codex-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/conflux.svg)Conflux eSpace|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/conflux/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/conflux.svg)Conflux eSpace|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/conflux/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/conflux.svg)Conflux
eSpace|
[0x8d183a062e99cad6f3723e6d836f9ea13886b173](https://layerzeroscan.com/api/explorer/conflux/address/0x8d183a062e99cad6f3723e6d836f9ea13886b173)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/conflux.svg)Conflux eSpace|
[0x809cde2afcf8627312e87a6a7bbffab3f8f347c7](https://layerzeroscan.com/api/explorer/conflux/address/0x809cde2afcf8627312e87a6a7bbffab3f8f347c7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/conflux-
testnet.svg)Conflux Testnet|
[0x62a731f0840d23970d5ec36fb7a586e1d61db9b6](https://layerzeroscan.com/api/explorer/conflux-
testnet/address/0x62a731f0840d23970d5ec36fb7a586e1d61db9b6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/coredao.svg)Core Blockchain
Mainnet|
[0x7a7ddc46882220a075934f40380d3a7e1e87d409](https://layerzeroscan.com/api/explorer/coredao/address/0x7a7ddc46882220a075934f40380d3a7e1e87d409)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/coredao.svg)Core Blockchain
Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/coredao/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/coredao.svg)Core
Blockchain Mainnet|
[0x3c5575898f59c097681d1fc239c2c6ad36b7b41c](https://layerzeroscan.com/api/explorer/coredao/address/0x3c5575898f59c097681d1fc239c2c6ad36b7b41c)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/coredao.svg)Core Blockchain
Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/coredao/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/coredao.svg)Core Blockchain
Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/coredao/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/coredao.svg)Core Blockchain
Mainnet|
[0xe6cd8c2e46ef396df88048449e5b1c75172b40c3](https://layerzeroscan.com/api/explorer/coredao/address/0xe6cd8c2e46ef396df88048449e5b1c75172b40c3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/coredao-
testnet.svg)CoreDAO Testnet|
[0xae9bbf877bf1bd41edd5dfc3473d263171cf3b9e](https://layerzeroscan.com/api/explorer/coredao-
testnet/address/0xae9bbf877bf1bd41edd5dfc3473d263171cf3b9e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/coredao-testnet.svg)CoreDAO
Testnet|
[0x4bb65bdb2c5d9bbaf25574a882c12fd98f5f994a](https://layerzeroscan.com/api/explorer/coredao-
testnet/address/0x4bb65bdb2c5d9bbaf25574a882c12fd98f5f994a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/curtis-
testnet.svg)Curtis Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/curtis-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/cyber.svg)Cyber
Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/cyber/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/cyber.svg)Cyber Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/cyber/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/cyber.svg)Cyber Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/cyber/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/cyber-testnet.svg)Cyber
Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/cyber-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/dfk.svg)DeFi Kingdoms
Mainnet|
[0x6a110d94e1baa6984a3d904bab37ae49b90e6b4f](https://layerzeroscan.com/api/explorer/dfk/address/0x6a110d94e1baa6984a3d904bab37ae49b90e6b4f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/dfk.svg)DeFi Kingdoms
Mainnet|
[0xa9ff468ad000a4d5729826459197a0db843f433e](https://layerzeroscan.com/api/explorer/dfk/address/0xa9ff468ad000a4d5729826459197a0db843f433e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/dfk.svg)DeFi Kingdoms
Mainnet|
[0x1f7e674143031e74bc48a0c570c174a07aa9c5d0](https://layerzeroscan.com/api/explorer/dfk/address/0x1f7e674143031e74bc48a0c570c174a07aa9c5d0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/dfk.svg)DeFi Kingdoms
Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/dfk/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/dfk-testnet.svg)DeFi
Kingdoms Testnet|
[0x685e66cb79b4864ce0a01173f2c5efbf103715ad](https://layerzeroscan.com/api/explorer/dfk-
testnet/address/0x685e66cb79b4864ce0a01173f2c5efbf103715ad)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/degen.svg)Degen Mainnet|
[0x01a998260da061efb9a85b26d42f8f8662bf3d5f](https://layerzeroscan.com/api/explorer/degen/address/0x01a998260da061efb9a85b26d42f8f8662bf3d5f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/degen.svg)Degen
Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/degen/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/degen.svg)Degen Mainnet|
[0x8d77d35604a9f37f488e41d1d916b2a0088f82dd](https://layerzeroscan.com/api/explorer/degen/address/0x8d77d35604a9f37f488e41d1d916b2a0088f82dd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/degen.svg)Degen Mainnet|
[0x80442151791bbdd89117719e508115ebc1ce2d93](https://layerzeroscan.com/api/explorer/degen/address/0x80442151791bbdd89117719e508115ebc1ce2d93)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/dexalot.svg)Dexalot Subnet|
[0x58dff8622759ea75910a08dba5d060579271dcd7](https://layerzeroscan.com/api/explorer/dexalot/address/0x58dff8622759ea75910a08dba5d060579271dcd7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/dexalot.svg)Dexalot Subnet|
[0xd42306df1a805d8053bc652ce0cd9f62bde80146](https://layerzeroscan.com/api/explorer/dexalot/address/0xd42306df1a805d8053bc652ce0cd9f62bde80146)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/dexalot.svg)Dexalot
Subnet|
[0xb98d764d25d53f803f05d451225612e4a9a3b712](https://layerzeroscan.com/api/explorer/dexalot/address/0xb98d764d25d53f803f05d451225612e4a9a3b712)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/dexalot.svg)Dexalot Subnet|
[0x70bf42c69173d6e33b834f59630dac592c70b369](https://layerzeroscan.com/api/explorer/dexalot/address/0x70bf42c69173d6e33b834f59630dac592c70b369)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/dexalot-
testnet.svg)Dexalot Subnet Testnet|
[0x433daf5e5fba834de2c3d06a82403c9e96df6b42](https://layerzeroscan.com/api/explorer/dexalot-
testnet/address/0x433daf5e5fba834de2c3d06a82403c9e96df6b42)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/dm2verse.svg)Dm2verse|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/dm2verse/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/dm2verse-
testnet.svg)Dm2verse Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/dm2verse-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/dos.svg)DOS Chain|
[0x2ac038606fff3fb00317b8f0ccfb4081694acdd0](https://layerzeroscan.com/api/explorer/dos/address/0x2ac038606fff3fb00317b8f0ccfb4081694acdd0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/dos.svg)DOS Chain|
[0x33e5fcc13d7439cc62d54c41aa966197145b3cd7](https://layerzeroscan.com/api/explorer/dos/address/0x33e5fcc13d7439cc62d54c41aa966197145b3cd7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/dos.svg)DOS Chain|
[0x203dfa8cbcbe234821da01a6e95fcbf92da065ea](https://layerzeroscan.com/api/explorer/dos/address/0x203dfa8cbcbe234821da01a6e95fcbf92da065ea)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/dos.svg)DOS Chain|
[0xacde1f22eeab249d3ca6ba8805c8fee9f52a16e7](https://layerzeroscan.com/api/explorer/dos/address/0xacde1f22eeab249d3ca6ba8805c8fee9f52a16e7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/dos-testnet.svg)DOS
Testnet|
[0x9e35059b08dca75f0f3c3940e4217b8dc73f4fda](https://layerzeroscan.com/api/explorer/dos-
testnet/address/0x9e35059b08dca75f0f3c3940e4217b8dc73f4fda)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/ebi.svg)EBI Mainnet|
[0x3a2d3a2249691809c34fb9733fd0d826d1aee028](https://layerzeroscan.com/api/explorer/ebi/address/0x3a2d3a2249691809c34fb9733fd0d826d1aee028)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/ebi.svg)EBI Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/ebi/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/ebi.svg)EBI Mainnet|
[0x261150ab73528dbd51573a52917eab243be9729a](https://layerzeroscan.com/api/explorer/ebi/address/0x261150ab73528dbd51573a52917eab243be9729a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/ebi.svg)EBI Mainnet|
[0x97841d4ab18e9a923322a002d5b8eb42b31ccdb5](https://layerzeroscan.com/api/explorer/ebi/address/0x97841d4ab18e9a923322a002d5b8eb42b31ccdb5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/ebi-testnet.svg)EBI
Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/ebi-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/holesky-testnet.svg)Ethereum
Holesky Testnet|
[0xa38e1ff4b2516f6ed7ebbf1bf12a46c766969937](https://layerzeroscan.com/api/explorer/holesky-
testnet/address/0xa38e1ff4b2516f6ed7ebbf1bf12a46c766969937)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/holesky-testnet.svg)Ethereum
Holesky Testnet|
[0xd0d47c34937ddbebbe698267a6bbb1dace51198d](https://layerzeroscan.com/api/explorer/holesky-
testnet/address/0xd0d47c34937ddbebbe698267a6bbb1dace51198d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/holesky-
testnet.svg)Ethereum Holesky Testnet|
[0x3e43f8ff0175580f7644da043071c289ddf98118](https://layerzeroscan.com/api/explorer/holesky-
testnet/address/0x3e43f8ff0175580f7644da043071c289ddf98118)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/01node.svg)01node|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x58dff8622759ea75910a08dba5d060579271dcd7](https://layerzeroscan.com/api/explorer/ethereum/address/0x58dff8622759ea75910a08dba5d060579271dcd7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/animoca-blockdaemon.svg)Animoca-
Blockdaemon| ![](https://icons-ckg.pages.dev/lz-
scan/networks/ethereum.svg)Ethereum Mainnet|
[0x7e65bdd15c8db8995f80abf0d6593b57dc8be437](https://layerzeroscan.com/api/explorer/ethereum/address/0x7e65bdd15c8db8995f80abf0d6593b57dc8be437)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/axelar.svg)Axelar|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0xce5b47fa5139fc5f3c8c5f4c278ad5f56a7b2016](https://layerzeroscan.com/api/explorer/ethereum/address/0xce5b47fa5139fc5f3c8c5f4c278ad5f56a7b2016)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0xe552485d02edd3067fe7fcbd4dd56bb1d3a998d2](https://layerzeroscan.com/api/explorer/ethereum/address/0xe552485d02edd3067fe7fcbd4dd56bb1d3a998d2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x05d78174b97cf2ec223ee578cd1f401ff792ca31](https://layerzeroscan.com/api/explorer/ethereum/address/0x05d78174b97cf2ec223ee578cd1f401ff792ca31)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/blockhunters.svg)Blockhunters|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x6e70fcdc42d3d63748b7d8883399dcb16bbb5c8c](https://layerzeroscan.com/api/explorer/ethereum/address/0x6e70fcdc42d3d63748b7d8883399dcb16bbb5c8c)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x7a23612f07d81f16b26cf0b5a4c3eca0e8668df2](https://layerzeroscan.com/api/explorer/ethereum/address/0x7a23612f07d81f16b26cf0b5a4c3eca0e8668df2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/ccip.svg)Chainlink CCIP|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x771d10d0c86e26ea8d3b778ad4d31b30533b9cbf](https://layerzeroscan.com/api/explorer/ethereum/address/0x771d10d0c86e26ea8d3b778ad4d31b30533b9cbf)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/delegate.svg)Delegate|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x87048402c32632b7c4d0a892d82bc1160e8b2393](https://layerzeroscan.com/api/explorer/ethereum/address/0x87048402c32632b7c4d0a892d82bc1160e8b2393)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/gitcoin.svg)Gitcoin|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x38179d3bfa6ef1d69a8a7b0b671ba3d8836b2ae8](https://layerzeroscan.com/api/explorer/ethereum/address/0x38179d3bfa6ef1d69a8a7b0b671ba3d8836b2ae8)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/ethereum/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x380275805876ff19055ea900cdb2b46a94ecf20d](https://layerzeroscan.com/api/explorer/ethereum/address/0x380275805876ff19055ea900cdb2b46a94ecf20d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/lagrange-labs.svg)Lagrange|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x95729ea44326f8add8a9b1d987279dbdc1dd3dff](https://layerzeroscan.com/api/explorer/ethereum/address/0x95729ea44326f8add8a9b1d987279dbdc1dd3dff)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x589dedbd617e0cbcb916a9223f4d1300c294236b](https://layerzeroscan.com/api/explorer/ethereum/address/0x589dedbd617e0cbcb916a9223f4d1300c294236b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/luganodes.svg)Luganodes|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x58249a2ec05c1978bf21df1f5ec1847e42455cf4](https://layerzeroscan.com/api/explorer/ethereum/address/0x58249a2ec05c1978bf21df1f5ec1847e42455cf4)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mim.svg)MIM| ![](https://icons-
ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum Mainnet|
[0x0ae4e6a9a8b01ee22c6a49af22b674a4e033a23d](https://layerzeroscan.com/api/explorer/ethereum/address/0x0ae4e6a9a8b01ee22c6a49af22b674a4e033a23d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0xa59ba433ac34d2927232918ef5b2eaafcf130ba5](https://layerzeroscan.com/api/explorer/ethereum/address/0xa59ba433ac34d2927232918ef5b2eaafcf130ba5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nocturnal-labs.svg)Nocturnal
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x04584d612802a3a26b160e3f90341e6443ddb76a](https://layerzeroscan.com/api/explorer/ethereum/address/0x04584d612802a3a26b160e3f90341e6443ddb76a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nodes-guru.svg)Nodes.Guru|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x9f45834f0c8042e36935781b944443e906886a87](https://layerzeroscan.com/api/explorer/ethereum/address/0x9f45834f0c8042e36935781b944443e906886a87)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omni-x.svg)Omni X|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0xaf75bfd402f3d4ee84978179a6c87d16c4bd1724](https://layerzeroscan.com/api/explorer/ethereum/address/0xaf75bfd402f3d4ee84978179a6c87d16c4bd1724)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omnicat.svg)Omnicat|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0xf10ea2c0d43bc4973cfbcc94ebafc39d1d4af118](https://layerzeroscan.com/api/explorer/ethereum/address/0xf10ea2c0d43bc4973cfbcc94ebafc39d1d4af118)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p-ops-team.svg)P-OPS|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x94aafe0a92a8300f0a2100a7f3de47d6845747a9](https://layerzeroscan.com/api/explorer/ethereum/address/0x94aafe0a92a8300f0a2100a7f3de47d6845747a9)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p2p.svg)P2P| ![](https://icons-
ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum Mainnet|
[0x06559ee34d85a88317bf0bfe307444116c631b67](https://layerzeroscan.com/api/explorer/ethereum/address/0x06559ee34d85a88317bf0bfe307444116c631b67)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/pearlnet.svg)Pearlnet|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0xd24972c11f91c1bb9eaee97ec96bb9c33cf7af24](https://layerzeroscan.com/api/explorer/ethereum/address/0xd24972c11f91c1bb9eaee97ec96bb9c33cf7af24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/planetarium-labs.svg)Planetarium
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x972ed7bd3d42d9c0bea3632992ebf7e97186ea4a](https://layerzeroscan.com/api/explorer/ethereum/address/0x972ed7bd3d42d9c0bea3632992ebf7e97186ea4a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/ethereum/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/portal.svg)Portal|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x92ef4381a03372985985e70fb15e9f081e2e8d14](https://layerzeroscan.com/api/explorer/ethereum/address/0x92ef4381a03372985985e70fb15e9f081e2e8d14)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/republic-crypto.svg)Republic|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0xa1bc1b9af01a0ec78883aa5dc7decdce897e1e76](https://layerzeroscan.com/api/explorer/ethereum/address/0xa1bc1b9af01a0ec78883aa5dc7decdce897e1e76)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/restake.svg)Restake|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0xe4193136b92ba91402313e95347c8e9fad8d27d0](https://layerzeroscan.com/api/explorer/ethereum/address/0xe4193136b92ba91402313e95347c8e9fad8d27d0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mercury.svg)Shrapnel|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0xce97511db880571a7c31821eb026ef12fcac892e](https://layerzeroscan.com/api/explorer/ethereum/address/0xce97511db880571a7c31821eb026ef12fcac892e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stablelab.svg)StableLab|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x5fddd320a1e29bb466fa635661b125d51d976f92](https://layerzeroscan.com/api/explorer/ethereum/address/0x5fddd320a1e29bb466fa635661b125d51d976f92)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stakingcabin.svg)StakingCabin|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0xdeb742e71d57603d8f769ce36f4353468007fc02](https://layerzeroscan.com/api/explorer/ethereum/address/0xdeb742e71d57603d8f769ce36f4353468007fc02)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x8fafae7dd957044088b3d0f67359c327c6200d18](https://layerzeroscan.com/api/explorer/ethereum/address/0x8fafae7dd957044088b3d0f67359c327c6200d18)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/switchboard.svg)Switchboard|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0x276e6b1138d2d49c0cda86658765d12ef84550c1](https://layerzeroscan.com/api/explorer/ethereum/address/0x276e6b1138d2d49c0cda86658765d12ef84550c1)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet|
[0xd42306df1a805d8053bc652ce0cd9f62bde80146](https://layerzeroscan.com/api/explorer/ethereum/address/0xd42306df1a805d8053bc652ce0cd9f62bde80146)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/sepolia.svg)Ethereum Sepolia
Testnet|
[0xca7a736be0fe968a33af62033b8b36d491f7999b](https://layerzeroscan.com/api/explorer/sepolia/address/0xca7a736be0fe968a33af62033b8b36d491f7999b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/sepolia.svg)Ethereum Sepolia
Testnet|
[0xac294c43d44d4131db389256959f33e713851e31](https://layerzeroscan.com/api/explorer/sepolia/address/0xac294c43d44d4131db389256959f33e713851e31)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/delegate.svg)Delegate|
![](https://icons-ckg.pages.dev/lz-scan/networks/sepolia.svg)Ethereum Sepolia
Testnet|
[0x942afc25b43d6ffe6d990af37737841f580638d7](https://layerzeroscan.com/api/explorer/sepolia/address/0x942afc25b43d6ffe6d990af37737841f580638d7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/gitcoin.svg)Gitcoin|
![](https://icons-ckg.pages.dev/lz-scan/networks/sepolia.svg)Ethereum Sepolia
Testnet|
[0x28b92d35407caa791531cd7f7d215044f4c0cbdd](https://layerzeroscan.com/api/explorer/sepolia/address/0x28b92d35407caa791531cd7f7d215044f4c0cbdd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/sepolia.svg)Ethereum Sepolia
Testnet|
[0x4f675c48fad936cb4c3ca07d7cbf421ceeae0c75](https://layerzeroscan.com/api/explorer/sepolia/address/0x4f675c48fad936cb4c3ca07d7cbf421ceeae0c75)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/sepolia.svg)Ethereum Sepolia
Testnet|
[0x96746917b256bdb8424496ff6bbcaf8216708a6a](https://layerzeroscan.com/api/explorer/sepolia/address/0x96746917b256bdb8424496ff6bbcaf8216708a6a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/joc.svg)Japan Blockchain
Foundation| ![](https://icons-ckg.pages.dev/lz-
scan/networks/sepolia.svg)Ethereum Sepolia Testnet|
[0xefd1d76a2db92bad8fd56167f847d204f5f4004e](https://layerzeroscan.com/api/explorer/sepolia/address/0xefd1d76a2db92bad8fd56167f847d204f5f4004e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/sepolia.svg)Ethereum
Sepolia Testnet|
[0x8eebf8b423b73bfca51a1db4b7354aa0bfca9193](https://layerzeroscan.com/api/explorer/sepolia/address/0x8eebf8b423b73bfca51a1db4b7354aa0bfca9193)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/sepolia.svg)Ethereum Sepolia
Testnet|
[0x715a4451be19106bb7cefd81e507813e23c30768](https://layerzeroscan.com/api/explorer/sepolia/address/0x715a4451be19106bb7cefd81e507813e23c30768)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p2p.svg)P2P| ![](https://icons-
ckg.pages.dev/lz-scan/networks/sepolia.svg)Ethereum Sepolia Testnet|
[0xe7b65ec1ae41186ef626a3a3cbf79d0c0426a911](https://layerzeroscan.com/api/explorer/sepolia/address/0xe7b65ec1ae41186ef626a3a3cbf79d0c0426a911)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stablelab.svg)StableLab|
![](https://icons-ckg.pages.dev/lz-scan/networks/sepolia.svg)Ethereum Sepolia
Testnet|
[0xf21f0282b55b4143251d8e39d3d93e78a78389ab](https://layerzeroscan.com/api/explorer/sepolia/address/0xf21f0282b55b4143251d8e39d3d93e78a78389ab)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/switchboard.svg)Switchboard|
![](https://icons-ckg.pages.dev/lz-scan/networks/sepolia.svg)Ethereum Sepolia
Testnet|
[0x51e8907d6f3606587ba9f0aba4ece4c28ac31ec6](https://layerzeroscan.com/api/explorer/sepolia/address/0x51e8907d6f3606587ba9f0aba4ece4c28ac31ec6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/etherlink.svg)Etherlink
Mainnet|
[0xc097ab8cd7b053326dfe9fb3e3a31a0cce3b526f](https://layerzeroscan.com/api/explorer/etherlink/address/0xc097ab8cd7b053326dfe9fb3e3a31a0cce3b526f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/etherlink.svg)Etherlink
Mainnet|
[0x7a23612f07d81f16b26cf0b5a4c3eca0e8668df2](https://layerzeroscan.com/api/explorer/etherlink/address/0x7a23612f07d81f16b26cf0b5a4c3eca0e8668df2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/etherlink.svg)Etherlink
Mainnet|
[0x31f748a368a893bdb5abb67ec95f232507601a73](https://layerzeroscan.com/api/explorer/etherlink/address/0x31f748a368a893bdb5abb67ec95f232507601a73)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/etherlink-
testnet.svg)Etherlink Testnet|
[0x4d97186cd94047e285b7cb78fa63c93e69e7aad0](https://layerzeroscan.com/api/explorer/etherlink-
testnet/address/0x4d97186cd94047e285b7cb78fa63c93e69e7aad0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/01node.svg)01node|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x8fc629aa400d4d9c0b118f2685a49316552abf27](https://layerzeroscan.com/api/explorer/fantom/address/0x8fc629aa400d4d9c0b118f2685a49316552abf27)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/animoca-blockdaemon.svg)Animoca-
Blockdaemon| ![](https://icons-ckg.pages.dev/lz-
scan/networks/fantom.svg)Fantom Mainnet|
[0x313328609a9c38459cae56625fff7f2ad6dcde3b](https://layerzeroscan.com/api/explorer/fantom/address/0x313328609a9c38459cae56625fff7f2ad6dcde3b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0xdf44a1594d3d516f7cdfb4dc275a79a5f6e3db1d](https://layerzeroscan.com/api/explorer/fantom/address/0xdf44a1594d3d516f7cdfb4dc275a79a5f6e3db1d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/blockhunters.svg)Blockhunters|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x547bf6889b1095b7cc6e525a1f8e8fdb26134a38](https://layerzeroscan.com/api/explorer/fantom/address/0x547bf6889b1095b7cc6e525a1f8e8fdb26134a38)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x247624e2143504730aec22912ed41f092498bef2](https://layerzeroscan.com/api/explorer/fantom/address/0x247624e2143504730aec22912ed41f092498bef2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/delegate.svg)Delegate|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x9eeee79f5dbc4d99354b5cb547c138af432f937b](https://layerzeroscan.com/api/explorer/fantom/address/0x9eeee79f5dbc4d99354b5cb547c138af432f937b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/gitcoin.svg)Gitcoin|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x2afa3787cd95fee5d5753cd717ef228eb259f4ea](https://layerzeroscan.com/api/explorer/fantom/address/0x2afa3787cd95fee5d5753cd717ef228eb259f4ea)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/fantom/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x25e0e650a78e6304a3983fc4b7ffc6544b1beea6](https://layerzeroscan.com/api/explorer/fantom/address/0x25e0e650a78e6304a3983fc4b7ffc6544b1beea6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom
Mainnet|
[0xe60a3959ca23a92bf5aaf992ef837ca7f828628a](https://layerzeroscan.com/api/explorer/fantom/address/0xe60a3959ca23a92bf5aaf992ef837ca7f828628a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/luganodes.svg)Luganodes|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0xa6f5ddbf0bd4d03334523465439d301080574742](https://layerzeroscan.com/api/explorer/fantom/address/0xa6f5ddbf0bd4d03334523465439d301080574742)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mim.svg)MIM| ![](https://icons-
ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x1bab20e7fdc79257729cb596bef85db76c44915e](https://layerzeroscan.com/api/explorer/fantom/address/0x1bab20e7fdc79257729cb596bef85db76c44915e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x31f748a368a893bdb5abb67ec95f232507601a73](https://layerzeroscan.com/api/explorer/fantom/address/0x31f748a368a893bdb5abb67ec95f232507601a73)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nodes-guru.svg)Nodes.Guru|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x05aaefdf9db6e0f7d27fa3b6ee099edb33da029e](https://layerzeroscan.com/api/explorer/fantom/address/0x05aaefdf9db6e0f7d27fa3b6ee099edb33da029e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omni-x.svg)Omni X|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0xe0f0fbbdbf9d398eca0dd8c86d1f308d895b9eb7](https://layerzeroscan.com/api/explorer/fantom/address/0xe0f0fbbdbf9d398eca0dd8c86d1f308d895b9eb7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p-ops-team.svg)P-OPS|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x78203678d264063815dac114ea810e9837cd80f7](https://layerzeroscan.com/api/explorer/fantom/address/0x78203678d264063815dac114ea810e9837cd80f7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p2p.svg)P2P| ![](https://icons-
ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x439264fb87581a70bb6d7befd16b636521b0ad2d](https://layerzeroscan.com/api/explorer/fantom/address/0x439264fb87581a70bb6d7befd16b636521b0ad2d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/planetarium-labs.svg)Planetarium
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom
Mainnet|
[0xf7ddee427507cdb6885e53caaaa1973b1fe29357](https://layerzeroscan.com/api/explorer/fantom/address/0xf7ddee427507cdb6885e53caaaa1973b1fe29357)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/fantom/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/portal.svg)Portal|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0xbd40c9047980500c46b8aed4462e2f889299febe](https://layerzeroscan.com/api/explorer/fantom/address/0xbd40c9047980500c46b8aed4462e2f889299febe)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/restake.svg)Restake|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x4d52f5bc932cf1a854381a85ad9ed79b8497c153](https://layerzeroscan.com/api/explorer/fantom/address/0x4d52f5bc932cf1a854381a85ad9ed79b8497c153)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mercury.svg)Shrapnel|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0xb4fa7f1c67e5ec99b556ec92cbddbcdd384106f2](https://layerzeroscan.com/api/explorer/fantom/address/0xb4fa7f1c67e5ec99b556ec92cbddbcdd384106f2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stablelab.svg)StableLab|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0xabc9b1819cc4d9846550f928b985993cf6240439](https://layerzeroscan.com/api/explorer/fantom/address/0xabc9b1819cc4d9846550f928b985993cf6240439)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stakingcabin.svg)StakingCabin|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0x2b8cbea81315130a4c422e875063362640ddfeb0](https://layerzeroscan.com/api/explorer/fantom/address/0x2b8cbea81315130a4c422e875063362640ddfeb0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/switchboard.svg)Switchboard|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0xf0809f6e760a5452ee567975eda7a28da4a83d38](https://layerzeroscan.com/api/explorer/fantom/address/0xf0809f6e760a5452ee567975eda7a28da4a83d38)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
[0xae675d8a97a06dea4e74253d429bd324606ded24](https://layerzeroscan.com/api/explorer/fantom/address/0xae675d8a97a06dea4e74253d429bd324606ded24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom-testnet.svg)Fantom
Testnet|
[0xd83401cd9e9ec8c81e4bf247b0bce1b85c2ec2b6](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0xd83401cd9e9ec8c81e4bf247b0bce1b85c2ec2b6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom-testnet.svg)Fantom
Testnet|
[0x312f5c396cf78a80f6fac979b55a4ddde44031f0](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0x312f5c396cf78a80f6fac979b55a4ddde44031f0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/delegate.svg)Delegate|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom-testnet.svg)Fantom
Testnet|
[0x427859dcf157e29fda324c2cd90b17fa33d0e300](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0x427859dcf157e29fda324c2cd90b17fa33d0e300)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/gitcoin.svg)Gitcoin|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom-testnet.svg)Fantom
Testnet|
[0x97f671e60196ff62279dd06c393948f5b0b90c05](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0x97f671e60196ff62279dd06c393948f5b0b90c05)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom-testnet.svg)Fantom
Testnet|
[0xbdb61339dc1cd02982ab459fa46f858decf3cec6](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0xbdb61339dc1cd02982ab459fa46f858decf3cec6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/fantom-
testnet.svg)Fantom Testnet|
[0xfffc92a6abe6480adc574901ebfde108a7077eb8](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0xfffc92a6abe6480adc574901ebfde108a7077eb8)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom-testnet.svg)Fantom
Testnet|
[0x39ed64e4e063d22f69fb09d5a84ed6582aff120f](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0x39ed64e4e063d22f69fb09d5a84ed6582aff120f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p2p.svg)P2P| ![](https://icons-
ckg.pages.dev/lz-scan/networks/fantom-testnet.svg)Fantom Testnet|
[0xf10955530720932660589259dabc44c964d88869](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0xf10955530720932660589259dabc44c964d88869)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stablelab.svg)StableLab|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom-testnet.svg)Fantom
Testnet|
[0x134dc38ae8c853d1aa2103d5047591acdaa16682](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0x134dc38ae8c853d1aa2103d5047591acdaa16682)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/switchboard.svg)Switchboard|
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom-testnet.svg)Fantom
Testnet|
[0xfd53de8f107538c28148f0bcdf1fb1f1dfd5461b](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0xfd53de8f107538c28148f0bcdf1fb1f1dfd5461b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/fi-testnet.svg)Fi
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/fi-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/flare.svg)Flare Mainnet|
[0xeaa5a170d2588f84773f965281f8611d61312832](https://layerzeroscan.com/api/explorer/flare/address/0xeaa5a170d2588f84773f965281f8611d61312832)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/flare.svg)Flare
Mainnet|
[0x9c061c9a4782294eef65ef28cb88233a987f4bdd](https://layerzeroscan.com/api/explorer/flare/address/0x9c061c9a4782294eef65ef28cb88233a987f4bdd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/flare.svg)Flare Mainnet|
[0x9bcd17a654bffaa6f8fea38d19661a7210e22196](https://layerzeroscan.com/api/explorer/flare/address/0x9bcd17a654bffaa6f8fea38d19661a7210e22196)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/flare.svg)Flare Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/flare/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/flare.svg)Flare Mainnet|
[0x8d77d35604a9f37f488e41d1d916b2a0088f82dd](https://layerzeroscan.com/api/explorer/flare/address/0x8d77d35604a9f37f488e41d1d916b2a0088f82dd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/flare-testnet.svg)Flare
Testnet|
[0x12523de19dc41c91f7d2093e0cfbb76b17012c8d](https://layerzeroscan.com/api/explorer/flare-
testnet/address/0x12523de19dc41c91f7d2093e0cfbb76b17012c8d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/form-testnet.svg)Form
Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/form-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/axelar.svg)Axelar|
![](https://icons-ckg.pages.dev/lz-scan/networks/fraxtal.svg)Fraxtal Mainnet|
[0x025bab5b7271790f9cf188fdce2c4214857f48d3](https://layerzeroscan.com/api/explorer/fraxtal/address/0x025bab5b7271790f9cf188fdce2c4214857f48d3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/fraxtal.svg)Fraxtal Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/fraxtal/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/fraxtal.svg)Fraxtal
Mainnet|
[0xcce466a522984415bc91338c232d98869193d46e](https://layerzeroscan.com/api/explorer/fraxtal/address/0xcce466a522984415bc91338c232d98869193d46e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/fraxtal.svg)Fraxtal Mainnet|
[0xa7b5189bca84cd304d8553977c7c614329750d99](https://layerzeroscan.com/api/explorer/fraxtal/address/0xa7b5189bca84cd304d8553977c7c614329750d99)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/fraxtal-
testnet.svg)Fraxtal Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/fraxtal-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuse.svg)Fuse Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/fuse/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuse.svg)Fuse Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/fuse/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/fuse.svg)Fuse Mainnet|
[0x795f8325af292ff6e58249361d1954893be15aff](https://layerzeroscan.com/api/explorer/fuse/address/0x795f8325af292ff6e58249361d1954893be15aff)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuse.svg)Fuse Mainnet|
[0x809cde2afcf8627312e87a6a7bbffab3f8f347c7](https://layerzeroscan.com/api/explorer/fuse/address/0x809cde2afcf8627312e87a6a7bbffab3f8f347c7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/fuse.svg)Fuse Mainnet|
[0x9f45834f0c8042e36935781b944443e906886a87](https://layerzeroscan.com/api/explorer/fuse/address/0x9f45834f0c8042e36935781b944443e906886a87)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/fusespark.svg)Fusespark
Testnet|
[0x955412c07d9bc1027eb4d481621ee063bfd9f4c6](https://layerzeroscan.com/api/explorer/fusespark/address/0x955412c07d9bc1027eb4d481621ee063bfd9f4c6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/glue-testnet.svg)Glue
Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/glue-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/chiado.svg)Gnosis Chiado
Testnet|
[0x1c4fc6f1e44eaaef53ac701b7cc4c280f536fa75](https://layerzeroscan.com/api/explorer/chiado/address/0x1c4fc6f1e44eaaef53ac701b7cc4c280f536fa75)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/chiado.svg)Gnosis
Chiado Testnet|
[0xabfa1f7c3586eaff6958dc85baebbab7d3908fd2](https://layerzeroscan.com/api/explorer/chiado/address/0xabfa1f7c3586eaff6958dc85baebbab7d3908fd2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/chiado.svg)Gnosis Chiado
Testnet|
[0xb186f85d0604fe58af2ea33fe40244f5eef7351b](https://layerzeroscan.com/api/explorer/chiado/address/0xb186f85d0604fe58af2ea33fe40244f5eef7351b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/gnosis.svg)Gnosis Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/gnosis/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/gnosis.svg)Gnosis Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/gnosis/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/gnosis.svg)Gnosis Mainnet|
[0x6abdb569dc985504cccb541ade8445e5266e7388](https://layerzeroscan.com/api/explorer/gnosis/address/0x6abdb569dc985504cccb541ade8445e5266e7388)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/gnosis.svg)Gnosis
Mainnet|
[0x11bb2991882a86dc3e38858d922559a385d506ba](https://layerzeroscan.com/api/explorer/gnosis/address/0x11bb2991882a86dc3e38858d922559a385d506ba)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/gnosis.svg)Gnosis Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/gnosis/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p-ops-team.svg)P-OPS|
![](https://icons-ckg.pages.dev/lz-scan/networks/gnosis.svg)Gnosis Mainnet|
[0x790d7b1e97a086eb0012393b65a5b32ce58a04dc](https://layerzeroscan.com/api/explorer/gnosis/address/0x790d7b1e97a086eb0012393b65a5b32ce58a04dc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/gnosis.svg)Gnosis Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/gnosis/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/gnosis.svg)Gnosis Mainnet|
[0x07c05eab7716acb6f83ebf6268f8eecda8892ba1](https://layerzeroscan.com/api/explorer/gnosis/address/0x07c05eab7716acb6f83ebf6268f8eecda8892ba1)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/gravity.svg)Gravity Mainnet|
[0xcced05c3667877b545285b25f19f794436a1c481](https://layerzeroscan.com/api/explorer/gravity/address/0xcced05c3667877b545285b25f19f794436a1c481)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/gravity.svg)Gravity Mainnet|
[0xe95b63c4da1d94fa5022e7c23c984f278b416ca7](https://layerzeroscan.com/api/explorer/gravity/address/0xe95b63c4da1d94fa5022e7c23c984f278b416ca7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/gravity.svg)Gravity
Mainnet|
[0x9c061c9a4782294eef65ef28cb88233a987f4bdd](https://layerzeroscan.com/api/explorer/gravity/address/0x9c061c9a4782294eef65ef28cb88233a987f4bdd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/gravity.svg)Gravity Mainnet|
[0x4b92bc2a7d681bf5230472c80d92acfe9a6b9435](https://layerzeroscan.com/api/explorer/gravity/address/0x4b92bc2a7d681bf5230472c80d92acfe9a6b9435)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nodes-guru.svg)Nodes.Guru|
![](https://icons-ckg.pages.dev/lz-scan/networks/gravity.svg)Gravity Mainnet|
[0x4d52f5bc932cf1a854381a85ad9ed79b8497c153](https://layerzeroscan.com/api/explorer/gravity/address/0x4d52f5bc932cf1a854381a85ad9ed79b8497c153)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/gravity.svg)Gravity Mainnet|
[0x70bf42c69173d6e33b834f59630dac592c70b369](https://layerzeroscan.com/api/explorer/gravity/address/0x70bf42c69173d6e33b834f59630dac592c70b369)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/gunzilla-
testnet.svg)Gunzilla Testnet|
[0x8f337d230a5088e2a448515eab263735181a9039](https://layerzeroscan.com/api/explorer/gunzilla-
testnet/address/0x8f337d230a5088e2a448515eab263735181a9039)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/harmony.svg)Harmony Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/harmony/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/harmony.svg)Harmony Mainnet|
[0x462a63dbe8ca43a57d379c88a382c02862b9a2ce](https://layerzeroscan.com/api/explorer/harmony/address/0x462a63dbe8ca43a57d379c88a382c02862b9a2ce)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/harmony.svg)Harmony
Mainnet|
[0x8363302080e711e0cab978c081b9e69308d49808](https://layerzeroscan.com/api/explorer/harmony/address/0x8363302080e711e0cab978c081b9e69308d49808)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/harmony.svg)Harmony Mainnet|
[0xd24972c11f91c1bb9eaee97ec96bb9c33cf7af24](https://layerzeroscan.com/api/explorer/harmony/address/0xd24972c11f91c1bb9eaee97ec96bb9c33cf7af24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/hedera.svg)Hedera|
[0xce8358bc28dd8296ce8caf1cd2b44787abd65887](https://layerzeroscan.com/api/explorer/hedera/address/0xce8358bc28dd8296ce8caf1cd2b44787abd65887)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/hedera-
testnet.svg)Hedera Testnet|
[0xec7ee1f9e9060e08df969dc08ee72674afd5e14d](https://layerzeroscan.com/api/explorer/hedera-
testnet/address/0xec7ee1f9e9060e08df969dc08ee72674afd5e14d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/homeverse.svg)Homeverse
Mainnet|
[0x97841d4ab18e9a923322a002d5b8eb42b31ccdb5](https://layerzeroscan.com/api/explorer/homeverse/address/0x97841d4ab18e9a923322a002d5b8eb42b31ccdb5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/homeverse.svg)Homeverse
Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/homeverse/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/homeverse-
testnet.svg)Homeverse Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/homeverse-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/eon.svg)Horizen EON Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/eon/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/eon.svg)Horizen EON Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/eon/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/eon.svg)Horizen EON
Mainnet|
[0xe9ae261d3aff7d3fccf38fa2d612dd3897e07b2d](https://layerzeroscan.com/api/explorer/eon/address/0xe9ae261d3aff7d3fccf38fa2d612dd3897e07b2d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/hubble.svg)Hubble
Mainnet|
[0xe9ba4c1e76d874a43942718dafc96009ec9d9917](https://layerzeroscan.com/api/explorer/hubble/address/0xe9ba4c1e76d874a43942718dafc96009ec9d9917)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/hyperliquid-
testnet.svg)Hyperliquid Testnet|
[0x12523de19dc41c91f7d2093e0cfbb76b17012c8d](https://layerzeroscan.com/api/explorer/hyperliquid-
testnet/address/0x12523de19dc41c91f7d2093e0cfbb76b17012c8d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-
scan/networks/bl2-testnet.svg)InclusiveLayer Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/bl2-testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/bb1.svg)inEVM Mainnet|
[0xc9c1b26505bf3f4d6562159a119f6ede1e245deb](https://layerzeroscan.com/api/explorer/bb1/address/0xc9c1b26505bf3f4d6562159a119f6ede1e245deb)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/bb1.svg)inEVM Mainnet|
[0xb21f945e8917c6cd69fcfe66ac6703b90f7fe004](https://layerzeroscan.com/api/explorer/bb1/address/0xb21f945e8917c6cd69fcfe66ac6703b90f7fe004)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/bb1.svg)inEVM Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/bb1/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/iota.svg)Iota Mainnet|
[0xd7bb44516b476ca805fb9d6fc5b508ef3ee9448d](https://layerzeroscan.com/api/explorer/iota/address/0xd7bb44516b476ca805fb9d6fc5b508ef3ee9448d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/iota.svg)Iota Mainnet|
[0xdfc9455f8f86b45fa3b1116967f740905de6fe51](https://layerzeroscan.com/api/explorer/iota/address/0xdfc9455f8f86b45fa3b1116967f740905de6fe51)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/iota.svg)Iota Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/iota/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/iota.svg)Iota Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/iota/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/iota.svg)Iota Mainnet|
[0xf18a7d86917653725afb7c215e47a24f9d784718](https://layerzeroscan.com/api/explorer/iota/address/0xf18a7d86917653725afb7c215e47a24f9d784718)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/iota-testnet.svg)Iota
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/iota-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/joc.svg)Japan Open Chain|
[0xfb02364e3f5e97d8327dc6e4326e93828a28657d](https://layerzeroscan.com/api/explorer/joc/address/0xfb02364e3f5e97d8327dc6e4326e93828a28657d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/joc.svg)Japan Open
Chain|
[0x9c061c9a4782294eef65ef28cb88233a987f4bdd](https://layerzeroscan.com/api/explorer/joc/address/0x9c061c9a4782294eef65ef28cb88233a987f4bdd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/joc.svg)Japan Blockchain
Foundation| ![](https://icons-ckg.pages.dev/lz-scan/networks/joc-
testnet.svg)Japan Open Chain Testnet|
[0x3d4d36a92a597faec770678c1de305d50a7c4307](https://layerzeroscan.com/api/explorer/joc-
testnet/address/0x3d4d36a92a597faec770678c1de305d50a7c4307)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/joc-testnet.svg)Japan
Open Chain Testnet|
[0x9db9ca3305b48f196d18082e91cb64663b13d014](https://layerzeroscan.com/api/explorer/joc-
testnet/address/0x9db9ca3305b48f196d18082e91cb64663b13d014)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/axelar.svg)Axelar|
![](https://icons-ckg.pages.dev/lz-scan/networks/kava.svg)Kava Mainnet|
[0x80c4c3768dd5a3dd105cf2bd868fdc50280e398b](https://layerzeroscan.com/api/explorer/kava/address/0x80c4c3768dd5a3dd105cf2bd868fdc50280e398b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/kava.svg)Kava Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/kava/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/kava.svg)Kava Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/kava/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/kava.svg)Kava Mainnet|
[0x2d40a7b66f776345cf763c8ebb83199cd285e7a3](https://layerzeroscan.com/api/explorer/kava/address/0x2d40a7b66f776345cf763c8ebb83199cd285e7a3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/kava.svg)Kava Mainnet|
[0x6a4c9096f162f0ab3c0517b0a40dc1ce44785e16](https://layerzeroscan.com/api/explorer/kava/address/0x6a4c9096f162f0ab3c0517b0a40dc1ce44785e16)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/kava.svg)Kava Mainnet|
[0x9cbaf815ed62ef45c59e9f2cb05106babb4d31d3](https://layerzeroscan.com/api/explorer/kava/address/0x9cbaf815ed62ef45c59e9f2cb05106babb4d31d3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/kava-testnet.svg)Kava
Testnet|
[0x433daf5e5fba834de2c3d06a82403c9e96df6b42](https://layerzeroscan.com/api/explorer/kava-
testnet/address/0x433daf5e5fba834de2c3d06a82403c9e96df6b42)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/klaytn.svg)Klaytn Mainnet
Cypress|
[0x28af4dadbc5066e994986e8bb105240023dc44b6](https://layerzeroscan.com/api/explorer/klaytn/address/0x28af4dadbc5066e994986e8bb105240023dc44b6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/klaytn.svg)Klaytn Mainnet
Cypress|
[0xacde1f22eeab249d3ca6ba8805c8fee9f52a16e7](https://layerzeroscan.com/api/explorer/klaytn/address/0xacde1f22eeab249d3ca6ba8805c8fee9f52a16e7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/klaytn.svg)Klaytn
Mainnet Cypress|
[0xc80233ad8251e668becbc3b0415707fc7075501e](https://layerzeroscan.com/api/explorer/klaytn/address/0xc80233ad8251e668becbc3b0415707fc7075501e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/klaytn.svg)Klaytn Mainnet
Cypress|
[0x6a4c9096f162f0ab3c0517b0a40dc1ce44785e16](https://layerzeroscan.com/api/explorer/klaytn/address/0x6a4c9096f162f0ab3c0517b0a40dc1ce44785e16)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/klaytn.svg)Klaytn Mainnet
Cypress|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/klaytn/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/klaytn.svg)Klaytn Mainnet
Cypress|
[0x17720e3f361dcc2f70871a2ce3ac51b0eaa5c2e4](https://layerzeroscan.com/api/explorer/klaytn/address/0x17720e3f361dcc2f70871a2ce3ac51b0eaa5c2e4)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/klaytn-
baobab.svg)Klaytn Testnet Baobab|
[0xe4fe9782b809b7d66f0dcd10157275d2c4e4898d](https://layerzeroscan.com/api/explorer/klaytn-
baobab/address/0xe4fe9782b809b7d66f0dcd10157275d2c4e4898d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/lif3-testnet.svg)Lif3
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/lif3-testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/lightlink.svg)Lightlink
Mainnet|
[0xacde1f22eeab249d3ca6ba8805c8fee9f52a16e7](https://layerzeroscan.com/api/explorer/lightlink/address/0xacde1f22eeab249d3ca6ba8805c8fee9f52a16e7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/lightlink.svg)Lightlink
Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/lightlink/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/lightlink.svg)Lightlink
Mainnet|
[0x18f76f0d8ccd176bbe59b3870fa486d1fff87026](https://layerzeroscan.com/api/explorer/lightlink/address/0x18f76f0d8ccd176bbe59b3870fa486d1fff87026)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/lightlink.svg)Lightlink
Mainnet|
[0x0e95cf21ad9376a26997c97f326c5a0a267bb8ff](https://layerzeroscan.com/api/explorer/lightlink/address/0x0e95cf21ad9376a26997c97f326c5a0a267bb8ff)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/lightlink-
testnet.svg)Lightlink Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/lightlink-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/linea.svg)Linea Mainnet|
[0xf45742bbfabcee739ea2a2d0ba2dd140f1f2c6a3](https://layerzeroscan.com/api/explorer/linea/address/0xf45742bbfabcee739ea2a2d0ba2dd140f1f2c6a3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/linea.svg)Linea Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/linea/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/linea.svg)Linea Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/linea/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/linea.svg)Linea
Mainnet|
[0x129ee430cb2ff2708ccaddbdb408a88fe4ffd480](https://layerzeroscan.com/api/explorer/linea/address/0x129ee430cb2ff2708ccaddbdb408a88fe4ffd480)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/linea.svg)Linea Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/linea/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/linea.svg)Linea Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/linea/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/linea.svg)Linea Mainnet|
[0xef269bbadb81de86e4b3278fa1dae1723545268b](https://layerzeroscan.com/api/explorer/linea/address/0xef269bbadb81de86e4b3278fa1dae1723545268b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/lineasep-
testnet.svg)Linea Sepolia Testnet|
[0x701f3927871efcea1235db722f9e608ae120d243](https://layerzeroscan.com/api/explorer/lineasep-
testnet/address/0x701f3927871efcea1235db722f9e608ae120d243)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/lisk-testnet.svg)Lisk
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/lisk-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/loot.svg)Loot Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/loot/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/loot.svg)Loot Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/loot/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/loot.svg)Loot Mainnet|
[0x4f8b7a7a346da5c467085377796e91220d904c15](https://layerzeroscan.com/api/explorer/loot/address/0x4f8b7a7a346da5c467085377796e91220d904c15)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/loot-testnet.svg)Loot
Testnet|
[0x09c3ff7df4f480f329cbee2df6f66c9a2e7f5a63](https://layerzeroscan.com/api/explorer/loot-
testnet/address/0x09c3ff7df4f480f329cbee2df6f66c9a2e7f5a63)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/lyra.svg)Lyra Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/lyra/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/lyra.svg)Lyra Mainnet|
[0x9c061c9a4782294eef65ef28cb88233a987f4bdd](https://layerzeroscan.com/api/explorer/lyra/address/0x9c061c9a4782294eef65ef28cb88233a987f4bdd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/lyra-testnet.svg)Lyra
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/lyra-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/manta.svg)Manta Mainnet|
[0x809cde2afcf8627312e87a6a7bbffab3f8f347c7](https://layerzeroscan.com/api/explorer/manta/address/0x809cde2afcf8627312e87a6a7bbffab3f8f347c7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/manta.svg)Manta Mainnet|
[0xabc9b1819cc4d9846550f928b985993cf6240439](https://layerzeroscan.com/api/explorer/manta/address/0xabc9b1819cc4d9846550f928b985993cf6240439)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/manta.svg)Manta Mainnet|
[0x31f748a368a893bdb5abb67ec95f232507601a73](https://layerzeroscan.com/api/explorer/manta/address/0x31f748a368a893bdb5abb67ec95f232507601a73)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/manta.svg)Manta
Mainnet|
[0xa09db5142654e3eb5cf547d66833fae7097b21c3](https://layerzeroscan.com/api/explorer/manta/address/0xa09db5142654e3eb5cf547d66833fae7097b21c3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/manta.svg)Manta Mainnet|
[0x247624e2143504730aec22912ed41f092498bef2](https://layerzeroscan.com/api/explorer/manta/address/0x247624e2143504730aec22912ed41f092498bef2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/manta.svg)Manta Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/manta/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/mantasep-
testnet.svg)Manta Sepolia Mainnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/mantasep-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/axelar.svg)Axelar|
![](https://icons-ckg.pages.dev/lz-scan/networks/mantle.svg)Mantle Mainnet|
[0x6e6359a9abe2e235ef2b82e48f0f93d1ec16afbb](https://layerzeroscan.com/api/explorer/mantle/address/0x6e6359a9abe2e235ef2b82e48f0f93d1ec16afbb)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/mantle.svg)Mantle Mainnet|
[0x7a7ddc46882220a075934f40380d3a7e1e87d409](https://layerzeroscan.com/api/explorer/mantle/address/0x7a7ddc46882220a075934f40380d3a7e1e87d409)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/mantle.svg)Mantle Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/mantle/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/mantle.svg)Mantle Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/mantle/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/mantle.svg)Mantle
Mainnet|
[0x28b6140ead70cb2fb669705b3598ffb4beaa060b](https://layerzeroscan.com/api/explorer/mantle/address/0x28b6140ead70cb2fb669705b3598ffb4beaa060b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/mantle.svg)Mantle Mainnet|
[0xb19a9370d404308040a9760678c8ca28affbbb76](https://layerzeroscan.com/api/explorer/mantle/address/0xb19a9370d404308040a9760678c8ca28affbbb76)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/mantle.svg)Mantle Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/mantle/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/mantle.svg)Mantle Mainnet|
[0xfe809470016196573d64a8d17a745bebea4ecc41](https://layerzeroscan.com/api/explorer/mantle/address/0xfe809470016196573d64a8d17a745bebea4ecc41)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/mantle-
sepolia.svg)Mantle Sepolia Testnet|
[0x9454f0eabc7c4ea9ebf89190b8bf9051a0468e03](https://layerzeroscan.com/api/explorer/mantle-
sepolia/address/0x9454f0eabc7c4ea9ebf89190b8bf9051a0468e03)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/masa.svg)Masa Mainnet|
[0xacde1f22eeab249d3ca6ba8805c8fee9f52a16e7](https://layerzeroscan.com/api/explorer/masa/address/0xacde1f22eeab249d3ca6ba8805c8fee9f52a16e7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/masa.svg)Masa Mainnet|
[0x9c061c9a4782294eef65ef28cb88233a987f4bdd](https://layerzeroscan.com/api/explorer/masa/address/0x9c061c9a4782294eef65ef28cb88233a987f4bdd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/masa.svg)Masa Mainnet|
[0x77d94a239dca4b8a92a45dd68ec3e31515a807c0](https://layerzeroscan.com/api/explorer/masa/address/0x77d94a239dca4b8a92a45dd68ec3e31515a807c0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/masa-testnet.svg)Masa
Testnet|
[0xc1868e054425d378095a003ecba3823a5d0135c9](https://layerzeroscan.com/api/explorer/masa-
testnet/address/0xc1868e054425d378095a003ecba3823a5d0135c9)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/beam-testnet.svg)Merit
Circle Testnet|
[0x51b5ba90288c2253cfa03ca71bd1f04b53c423dd](https://layerzeroscan.com/api/explorer/beam-
testnet/address/0x51b5ba90288c2253cfa03ca71bd1f04b53c423dd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/beam.svg)Meritcircle Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/beam/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/beam.svg)Meritcircle Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/beam/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/beam.svg)Meritcircle
Mainnet|
[0x5e38c31c28d0f485d6dc3ffabf8980bbcd882294](https://layerzeroscan.com/api/explorer/beam/address/0x5e38c31c28d0f485d6dc3ffabf8980bbcd882294)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/merlin.svg)Merlin Mainnet|
[0x439264fb87581a70bb6d7befd16b636521b0ad2d](https://layerzeroscan.com/api/explorer/merlin/address/0x439264fb87581a70bb6d7befd16b636521b0ad2d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/merlin.svg)Merlin
Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/merlin/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/merlin.svg)Merlin Mainnet|
[0xabc9b1819cc4d9846550f928b985993cf6240439](https://layerzeroscan.com/api/explorer/merlin/address/0xabc9b1819cc4d9846550f928b985993cf6240439)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/merlin.svg)Merlin Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/merlin/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/merlin-
testnet.svg)Merlin Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/merlin-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/merlin-testnet.svg)Merlin
Testnet|
[0x3bd9af5aa8c33b1e71c94cae7c009c36413e08fd](https://layerzeroscan.com/api/explorer/merlin-
testnet/address/0x3bd9af5aa8c33b1e71c94cae7c009c36413e08fd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/meter.svg)Meter Mainnet|
[0xc4e1b199c3b24954022fce7ba85419b3f0669142](https://layerzeroscan.com/api/explorer/meter/address/0xc4e1b199c3b24954022fce7ba85419b3f0669142)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/meter.svg)Meter Mainnet|
[0x3f10b9b75b05f103995ee8b8e2803aa6c7a9dcdf](https://layerzeroscan.com/api/explorer/meter/address/0x3f10b9b75b05f103995ee8b8e2803aa6c7a9dcdf)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/meter.svg)Meter
Mainnet|
[0xb792afc44214b5f910216bc904633dbd15b31680](https://layerzeroscan.com/api/explorer/meter/address/0xb792afc44214b5f910216bc904633dbd15b31680)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/meter.svg)Meter Mainnet|
[0x08095eced6c0b46d50ee45a6a59c0fd3de0b0855](https://layerzeroscan.com/api/explorer/meter/address/0x08095eced6c0b46d50ee45a6a59c0fd3de0b0855)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/meter-testnet.svg)Meter
Testnet|
[0xe3a4539200e8906c957cd85b3e7a515c9883fd81](https://layerzeroscan.com/api/explorer/meter-
testnet/address/0xe3a4539200e8906c957cd85b3e7a515c9883fd81)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/metis.svg)Metis Mainnet|
[0x7a7ddc46882220a075934f40380d3a7e1e87d409](https://layerzeroscan.com/api/explorer/metis/address/0x7a7ddc46882220a075934f40380d3a7e1e87d409)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/metis.svg)Metis Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/metis/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/metis.svg)Metis Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/metis/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/metis.svg)Metis
Mainnet|
[0x32d4f92437454829b3fe7bebfece5d0523deb475](https://layerzeroscan.com/api/explorer/metis/address/0x32d4f92437454829b3fe7bebfece5d0523deb475)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/metis.svg)Metis Mainnet|
[0x6abdb569dc985504cccb541ade8445e5266e7388](https://layerzeroscan.com/api/explorer/metis/address/0x6abdb569dc985504cccb541ade8445e5266e7388)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/metis.svg)Metis Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/metis/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/metis.svg)Metis Mainnet|
[0x61a1b61a1087be03abedc04900cfcc1c14187237](https://layerzeroscan.com/api/explorer/metis/address/0x61a1b61a1087be03abedc04900cfcc1c14187237)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/metissep-
testnet.svg)Metis Sepolia Testnet|
[0x12523de19dc41c91f7d2093e0cfbb76b17012c8d](https://layerzeroscan.com/api/explorer/metissep-
testnet/address/0x12523de19dc41c91f7d2093e0cfbb76b17012c8d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/minato-
testnet.svg)Minato Testnet|
[0x12523de19dc41c91f7d2093e0cfbb76b17012c8d](https://layerzeroscan.com/api/explorer/minato-
testnet/address/0x12523de19dc41c91f7d2093e0cfbb76b17012c8d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/mode.svg)Mode Mainnet|
[0x10901f74cae315f674d3f6fc0645217fe4fad77c](https://layerzeroscan.com/api/explorer/mode/address/0x10901f74cae315f674d3f6fc0645217fe4fad77c)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/mode.svg)Mode Mainnet|
[0xacde1f22eeab249d3ca6ba8805c8fee9f52a16e7](https://layerzeroscan.com/api/explorer/mode/address/0xacde1f22eeab249d3ca6ba8805c8fee9f52a16e7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/mode.svg)Mode Mainnet|
[0xce8358bc28dd8296ce8caf1cd2b44787abd65887](https://layerzeroscan.com/api/explorer/mode/address/0xce8358bc28dd8296ce8caf1cd2b44787abd65887)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/mode.svg)Mode Mainnet|
[0xcd37ca043f8479064e10635020c65ffc005d36f6](https://layerzeroscan.com/api/explorer/mode/address/0xcd37ca043f8479064e10635020c65ffc005d36f6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/mode.svg)Mode Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/mode/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/mode-testnet.svg)Mode
Testnet|
[0x12523de19dc41c91f7d2093e0cfbb76b17012c8d](https://layerzeroscan.com/api/explorer/mode-
testnet/address/0x12523de19dc41c91f7d2093e0cfbb76b17012c8d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/moonbase.svg)Moonbase Alpha
Testnet|
[0xcc9a31f253970ad46cb45e6db19513e2248ed1fe](https://layerzeroscan.com/api/explorer/moonbase/address/0xcc9a31f253970ad46cb45e6db19513e2248ed1fe)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/moonbase.svg)Moonbase
Alpha Testnet|
[0x90ccfdcd75a66dac697ab9c49f9ee0e32fd77e9f](https://layerzeroscan.com/api/explorer/moonbase/address/0x90ccfdcd75a66dac697ab9c49f9ee0e32fd77e9f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/moonbeam.svg)Moonbeam
Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/moonbeam/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/moonbeam.svg)Moonbeam
Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/moonbeam/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/moonbeam.svg)Moonbeam
Mainnet|
[0x34730f2570e6cff8b1c91faabf37d0dd917c4367](https://layerzeroscan.com/api/explorer/moonbeam/address/0x34730f2570e6cff8b1c91faabf37d0dd917c4367)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/moonbeam.svg)Moonbeam
Mainnet|
[0x8b9b67b22ab2ed6ee324c2fd43734dbd2dddd045](https://layerzeroscan.com/api/explorer/moonbeam/address/0x8b9b67b22ab2ed6ee324c2fd43734dbd2dddd045)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/moonbeam.svg)Moonbeam
Mainnet|
[0x790d7b1e97a086eb0012393b65a5b32ce58a04dc](https://layerzeroscan.com/api/explorer/moonbeam/address/0x790d7b1e97a086eb0012393b65a5b32ce58a04dc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p-ops-team.svg)P-OPS|
![](https://icons-ckg.pages.dev/lz-scan/networks/moonbeam.svg)Moonbeam
Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/moonbeam/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/moonbeam.svg)Moonbeam
Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/moonbeam/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/moonriver.svg)Moonriver
Mainnet|
[0x7a7ddc46882220a075934f40380d3a7e1e87d409](https://layerzeroscan.com/api/explorer/moonriver/address/0x7a7ddc46882220a075934f40380d3a7e1e87d409)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/moonriver.svg)Moonriver
Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/moonriver/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/moonriver.svg)Moonriver
Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/moonriver/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/moonriver.svg)Moonriver
Mainnet|
[0x2b3ebe6662ad402317ee7ef4e6b25c79a0f91015](https://layerzeroscan.com/api/explorer/moonriver/address/0x2b3ebe6662ad402317ee7ef4e6b25c79a0f91015)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/moonriver.svg)Moonriver
Mainnet|
[0xfe1cd27827e16b07e61a4ac96b521bdb35e00328](https://layerzeroscan.com/api/explorer/moonriver/address/0xfe1cd27827e16b07e61a4ac96b521bdb35e00328)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/morph-testnet.svg)Morph
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/morph-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/aurora.svg)Near Aurora
Mainnet|
[0x70bf42c69173d6e33b834f59630dac592c70b369](https://layerzeroscan.com/api/explorer/aurora/address/0x70bf42c69173d6e33b834f59630dac592c70b369)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/aurora.svg)Near Aurora
Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/aurora/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/aurora.svg)Near Aurora
Mainnet|
[0xd4a903930f2c9085586cda0b11d9681eecb20d2f](https://layerzeroscan.com/api/explorer/aurora/address/0xd4a903930f2c9085586cda0b11d9681eecb20d2f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/aurora.svg)Near Aurora
Mainnet|
[0x34730f2570e6cff8b1c91faabf37d0dd917c4367](https://layerzeroscan.com/api/explorer/aurora/address/0x34730f2570e6cff8b1c91faabf37d0dd917c4367)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/aurora.svg)Near Aurora
Mainnet|
[0xe11c808bc6099abc9be566c9017aa2ab0f131d35](https://layerzeroscan.com/api/explorer/aurora/address/0xe11c808bc6099abc9be566c9017aa2ab0f131d35)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/okx-testnet.svg)OKX
Testnet|
[0xdbdc042321a87dff222c6bf26be68ad7b3d7543f](https://layerzeroscan.com/api/explorer/okx-
testnet/address/0xdbdc042321a87dff222c6bf26be68ad7b3d7543f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/okx.svg)OKXChain Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/okx/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/okx.svg)OKXChain Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/okx/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/okx.svg)OKXChain
Mainnet|
[0x52eea5c490fb89c7a0084b32feab854eeff07c82](https://layerzeroscan.com/api/explorer/okx/address/0x52eea5c490fb89c7a0084b32feab854eeff07c82)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/olive-testnet.svg)Olive
Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/olive-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/opbnb.svg)opBNB Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/opbnb/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/opbnb.svg)opBNB Mainnet|
[0x2ac038606fff3fb00317b8f0ccfb4081694acdd0](https://layerzeroscan.com/api/explorer/opbnb/address/0x2ac038606fff3fb00317b8f0ccfb4081694acdd0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/opbnb.svg)opBNB Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/opbnb/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/opbnb.svg)opBNB
Mainnet|
[0x3ebb618b5c9d09de770979d552b27d6357aff73b](https://layerzeroscan.com/api/explorer/opbnb/address/0x3ebb618b5c9d09de770979d552b27d6357aff73b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/opbnb.svg)opBNB Mainnet|
[0x6a4c9096f162f0ab3c0517b0a40dc1ce44785e16](https://layerzeroscan.com/api/explorer/opbnb/address/0x6a4c9096f162f0ab3c0517b0a40dc1ce44785e16)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/opbnb.svg)opBNB Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/opbnb/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/opbnb-testnet.svg)opBNB
Testnet|
[0x15e62434aadd26acc8a045e89404eceb4f6d2a52](https://layerzeroscan.com/api/explorer/opbnb-
testnet/address/0x15e62434aadd26acc8a045e89404eceb4f6d2a52)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/opencampus-
testnet.svg)Opencampus Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/opencampus-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/01node.svg)01node|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0x969a0bdd86a230345ad87a6a381de5ed9e6cda85](https://layerzeroscan.com/api/explorer/optimism/address/0x969a0bdd86a230345ad87a6a381de5ed9e6cda85)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/animoca-blockdaemon.svg)Animoca-
Blockdaemon| ![](https://icons-ckg.pages.dev/lz-
scan/networks/optimism.svg)Optimism Mainnet|
[0x7b8a0fd9d6ae5011d5cbd3e85ed6d5510f98c9bf](https://layerzeroscan.com/api/explorer/optimism/address/0x7b8a0fd9d6ae5011d5cbd3e85ed6d5510f98c9bf)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/axelar.svg)Axelar|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0x218b462e19d00c8fed4adbce78f33aef88d2ccfc](https://layerzeroscan.com/api/explorer/optimism/address/0x218b462e19d00c8fed4adbce78f33aef88d2ccfc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0x73ddc92e39aeda95feb8d3e0008016d9f1268c76](https://layerzeroscan.com/api/explorer/optimism/address/0x73ddc92e39aeda95feb8d3e0008016d9f1268c76)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0x90ee303d4743f460b9a38415e09f3799b85a4efc](https://layerzeroscan.com/api/explorer/optimism/address/0x90ee303d4743f460b9a38415e09f3799b85a4efc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/blockhunters.svg)Blockhunters|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xb3ce0a5d132cd9bf965aba435e650c55edce0062](https://layerzeroscan.com/api/explorer/optimism/address/0xb3ce0a5d132cd9bf965aba435e650c55edce0062)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0x19670df5e16bea2ba9b9e68b48c054c5baea06b8](https://layerzeroscan.com/api/explorer/optimism/address/0x19670df5e16bea2ba9b9e68b48c054c5baea06b8)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/delegate.svg)Delegate|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0x7a205ed4e3d7f9d0777594501705d8cd405c3b05](https://layerzeroscan.com/api/explorer/optimism/address/0x7a205ed4e3d7f9d0777594501705d8cd405c3b05)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/gitcoin.svg)Gitcoin|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xb4fa7f1c67e5ec99b556ec92cbddbcdd384106f2](https://layerzeroscan.com/api/explorer/optimism/address/0xb4fa7f1c67e5ec99b556ec92cbddbcdd384106f2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/optimism/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0x9e930731cb4a6bf7ecc11f695a295c60bdd212eb](https://layerzeroscan.com/api/explorer/optimism/address/0x9e930731cb4a6bf7ecc11f695a295c60bdd212eb)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/lagrange-labs.svg)Lagrange|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xa4281c1c88f0278ff696edeb517052153190fc9e](https://layerzeroscan.com/api/explorer/optimism/address/0xa4281c1c88f0278ff696edeb517052153190fc9e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0x6a02d83e8d433304bba74ef1c427913958187142](https://layerzeroscan.com/api/explorer/optimism/address/0x6a02d83e8d433304bba74ef1c427913958187142)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/luganodes.svg)Luganodes|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xd841a741addcb6dea735d3b8c9faf96ba3f3d30d](https://layerzeroscan.com/api/explorer/optimism/address/0xd841a741addcb6dea735d3b8c9faf96ba3f3d30d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mim.svg)MIM| ![](https://icons-
ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism Mainnet|
[0xd954bf7968ef68875c9100c9ec890f969504d120](https://layerzeroscan.com/api/explorer/optimism/address/0xd954bf7968ef68875c9100c9ec890f969504d120)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xa7b5189bca84cd304d8553977c7c614329750d99](https://layerzeroscan.com/api/explorer/optimism/address/0xa7b5189bca84cd304d8553977c7c614329750d99)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nodes-guru.svg)Nodes.Guru|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xe6cd8c2e46ef396df88048449e5b1c75172b40c3](https://layerzeroscan.com/api/explorer/optimism/address/0xe6cd8c2e46ef396df88048449e5b1c75172b40c3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omni-x.svg)Omni X|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0x03d2414476a742aba715bcc337583c820525e22a](https://layerzeroscan.com/api/explorer/optimism/address/0x03d2414476a742aba715bcc337583c820525e22a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p-ops-team.svg)P-OPS|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xe552485d02edd3067fe7fcbd4dd56bb1d3a998d2](https://layerzeroscan.com/api/explorer/optimism/address/0xe552485d02edd3067fe7fcbd4dd56bb1d3a998d2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p2p.svg)P2P| ![](https://icons-
ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism Mainnet|
[0x539008c98b17803a273edf98aba2d4414ee3f4d7](https://layerzeroscan.com/api/explorer/optimism/address/0x539008c98b17803a273edf98aba2d4414ee3f4d7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/pearlnet.svg)Pearlnet|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xabc9b1819cc4d9846550f928b985993cf6240439](https://layerzeroscan.com/api/explorer/optimism/address/0xabc9b1819cc4d9846550f928b985993cf6240439)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/planetarium-labs.svg)Planetarium
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0x021e401c2a1a60618c5e6353a40524971eba1e8d](https://layerzeroscan.com/api/explorer/optimism/address/0x021e401c2a1a60618c5e6353a40524971eba1e8d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/optimism/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/portal.svg)Portal|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xdf30c9f6a70ce65a152c5bd09826525d7e97ba49](https://layerzeroscan.com/api/explorer/optimism/address/0xdf30c9f6a70ce65a152c5bd09826525d7e97ba49)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/restake.svg)Restake|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xcced05c3667877b545285b25f19f794436a1c481](https://layerzeroscan.com/api/explorer/optimism/address/0xcced05c3667877b545285b25f19f794436a1c481)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mercury.svg)Shrapnel|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xd36246c322ee102a2203bca9cafb84c179d306f6](https://layerzeroscan.com/api/explorer/optimism/address/0xd36246c322ee102a2203bca9cafb84c179d306f6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stablelab.svg)StableLab|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xcd37ca043f8479064e10635020c65ffc005d36f6](https://layerzeroscan.com/api/explorer/optimism/address/0xcd37ca043f8479064e10635020c65ffc005d36f6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stakingcabin.svg)StakingCabin|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xea0c32623d19d888e926e68667a5e42853fa91b4](https://layerzeroscan.com/api/explorer/optimism/address/0xea0c32623d19d888e926e68667a5e42853fa91b4)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xfe6507f094155cabb4784403cd784c2df04122dd](https://layerzeroscan.com/api/explorer/optimism/address/0xfe6507f094155cabb4784403cd784c2df04122dd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/switchboard.svg)Switchboard|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0x313328609a9c38459cae56625fff7f2ad6dcde3b](https://layerzeroscan.com/api/explorer/optimism/address/0x313328609a9c38459cae56625fff7f2ad6dcde3b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet|
[0xaf75bfd402f3d4ee84978179a6c87d16c4bd1724](https://layerzeroscan.com/api/explorer/optimism/address/0xaf75bfd402f3d4ee84978179a6c87d16c4bd1724)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism-sepolia.svg)Optimism
Sepolia|
[0x938b28dc069a7b0880f4749655cb3c727c07a442](https://layerzeroscan.com/api/explorer/optimism-
sepolia/address/0x938b28dc069a7b0880f4749655cb3c727c07a442)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism-sepolia.svg)Optimism
Sepolia|
[0x3e9d8fa8067938f2a62baa7114eed183040824ab](https://layerzeroscan.com/api/explorer/optimism-
sepolia/address/0x3e9d8fa8067938f2a62baa7114eed183040824ab)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/optimism-
sepolia.svg)Optimism Sepolia|
[0xd680ec569f269aa7015f7979b4f1239b5aa4582c](https://layerzeroscan.com/api/explorer/optimism-
sepolia/address/0xd680ec569f269aa7015f7979b4f1239b5aa4582c)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/orderly.svg)Orderly Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/orderly/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/orderly.svg)Orderly Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/orderly/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/orderly.svg)Orderly
Mainnet|
[0xf53857dbc0d2c59d5666006ec200cba2936b8c35](https://layerzeroscan.com/api/explorer/orderly/address/0xf53857dbc0d2c59d5666006ec200cba2936b8c35)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/orderly.svg)Orderly Mainnet|
[0x6a4c9096f162f0ab3c0517b0a40dc1ce44785e16](https://layerzeroscan.com/api/explorer/orderly/address/0x6a4c9096f162f0ab3c0517b0a40dc1ce44785e16)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/orderly.svg)Orderly Mainnet|
[0xd074b6bbcbec2f2b4c4265de3d95e521f82bf669](https://layerzeroscan.com/api/explorer/orderly/address/0xd074b6bbcbec2f2b4c4265de3d95e521f82bf669)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/orderly-
testnet.svg)Orderly Sepolia Testnet|
[0x175d2b829604b82270d384393d25c666a822ab60](https://layerzeroscan.com/api/explorer/orderly-
testnet/address/0x175d2b829604b82270d384393d25c666a822ab60)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/otherworld-
testnet.svg)Otherworld Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/otherworld-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/ozean-testnet.svg)Ozean
Testnet|
[0x55c175dd5b039331db251424538169d8495c18d1](https://layerzeroscan.com/api/explorer/ozean-
testnet/address/0x55c175dd5b039331db251424538169d8495c18d1)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/peaq.svg)Peaq Mainnet|
[0x790d7b1e97a086eb0012393b65a5b32ce58a04dc](https://layerzeroscan.com/api/explorer/peaq/address/0x790d7b1e97a086eb0012393b65a5b32ce58a04dc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/peaq.svg)Peaq Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/peaq/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/peaq.svg)Peaq Mainnet|
[0x725fafe20b74ff6f88daea0c506190a8f1037635](https://layerzeroscan.com/api/explorer/peaq/address/0x725fafe20b74ff6f88daea0c506190a8f1037635)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nodes-guru.svg)Nodes.Guru|
![](https://icons-ckg.pages.dev/lz-scan/networks/peaq.svg)Peaq Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/peaq/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/peaq.svg)Peaq Mainnet|
[0x18f76f0d8ccd176bbe59b3870fa486d1fff87026](https://layerzeroscan.com/api/explorer/peaq/address/0x18f76f0d8ccd176bbe59b3870fa486d1fff87026)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/peaq-testnet.svg)Peaq
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/peaq-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/amoy-testnet.svg)Polygon Amoy
Testnet|
[0x02feab4e6ca6eebd60d85347762de70ca9ce162a](https://layerzeroscan.com/api/explorer/amoy-
testnet/address/0x02feab4e6ca6eebd60d85347762de70ca9ce162a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/joc.svg)Japan Blockchain
Foundation| ![](https://icons-ckg.pages.dev/lz-scan/networks/amoy-
testnet.svg)Polygon Amoy Testnet|
[0xd44e25bea2bedcceceb7e104d5843a55d208e8a9](https://layerzeroscan.com/api/explorer/amoy-
testnet/address/0xd44e25bea2bedcceceb7e104d5843a55d208e8a9)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/amoy-
testnet.svg)Polygon Amoy Testnet|
[0x55c175dd5b039331db251424538169d8495c18d1](https://layerzeroscan.com/api/explorer/amoy-
testnet/address/0x55c175dd5b039331db251424538169d8495c18d1)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/republic-crypto.svg)Republic|
![](https://icons-ckg.pages.dev/lz-scan/networks/amoy-testnet.svg)Polygon Amoy
Testnet|
[0x35cea726508192472919c51951042dd140794b01](https://layerzeroscan.com/api/explorer/amoy-
testnet/address/0x35cea726508192472919c51951042dd140794b01)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/01node.svg)01node|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xf0809f6e760a5452ee567975eda7a28da4a83d38](https://layerzeroscan.com/api/explorer/polygon/address/0xf0809f6e760a5452ee567975eda7a28da4a83d38)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/animoca-blockdaemon.svg)Animoca-
Blockdaemon| ![](https://icons-ckg.pages.dev/lz-
scan/networks/polygon.svg)Polygon Mainnet|
[0xa6f5ddbf0bd4d03334523465439d301080574742](https://layerzeroscan.com/api/explorer/polygon/address/0xa6f5ddbf0bd4d03334523465439d301080574742)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xd410ddb726991f372b69a05b006d2ae5a8cedbd6](https://layerzeroscan.com/api/explorer/polygon/address/0xd410ddb726991f372b69a05b006d2ae5a8cedbd6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bitgo.svg)BitGo|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xc30291521305bc76115de7bca8034ea7147abe36](https://layerzeroscan.com/api/explorer/polygon/address/0xc30291521305bc76115de7bca8034ea7147abe36)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/blockhunters.svg)Blockhunters|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xbd40c9047980500c46b8aed4462e2f889299febe](https://layerzeroscan.com/api/explorer/polygon/address/0xbd40c9047980500c46b8aed4462e2f889299febe)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x247624e2143504730aec22912ed41f092498bef2](https://layerzeroscan.com/api/explorer/polygon/address/0x247624e2143504730aec22912ed41f092498bef2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/delegate.svg)Delegate|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x4d52f5bc932cf1a854381a85ad9ed79b8497c153](https://layerzeroscan.com/api/explorer/polygon/address/0x4d52f5bc932cf1a854381a85ad9ed79b8497c153)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/gitcoin.svg)Gitcoin|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x047d9dbe4fc6b5c916f37237f547f9f42809935a](https://layerzeroscan.com/api/explorer/polygon/address/0x047d9dbe4fc6b5c916f37237f547f9f42809935a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc](https://layerzeroscan.com/api/explorer/polygon/address/0xd56e4eab23cb81f43168f9f45211eb027b9ac7cc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x25e0e650a78e6304a3983fc4b7ffc6544b1beea6](https://layerzeroscan.com/api/explorer/polygon/address/0x25e0e650a78e6304a3983fc4b7ffc6544b1beea6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon
Mainnet|
[0x23de2fe932d9043291f870324b74f820e11dc81a](https://layerzeroscan.com/api/explorer/polygon/address/0x23de2fe932d9043291f870324b74f820e11dc81a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/luganodes.svg)Luganodes|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xd1b5493e712081a6fbab73116405590046668f6b](https://layerzeroscan.com/api/explorer/polygon/address/0xd1b5493e712081a6fbab73116405590046668f6b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mim.svg)MIM| ![](https://icons-
ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x1bab20e7fdc79257729cb596bef85db76c44915e](https://layerzeroscan.com/api/explorer/polygon/address/0x1bab20e7fdc79257729cb596bef85db76c44915e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x31f748a368a893bdb5abb67ec95f232507601a73](https://layerzeroscan.com/api/explorer/polygon/address/0x31f748a368a893bdb5abb67ec95f232507601a73)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nocturnal-labs.svg)Nocturnal
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon
Mainnet|
[0x05aaefdf9db6e0f7d27fa3b6ee099edb33da029e](https://layerzeroscan.com/api/explorer/polygon/address/0x05aaefdf9db6e0f7d27fa3b6ee099edb33da029e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nodes-guru.svg)Nodes.Guru|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xf7ddee427507cdb6885e53caaaa1973b1fe29357](https://layerzeroscan.com/api/explorer/polygon/address/0xf7ddee427507cdb6885e53caaaa1973b1fe29357)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omni-x.svg)Omni X|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x06b85533967179ed5bc9c754b84ae7d02f7ed830](https://layerzeroscan.com/api/explorer/polygon/address/0x06b85533967179ed5bc9c754b84ae7d02f7ed830)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omnicat.svg)Omnicat|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xa2d10677441230c4aed58030e4ea6ba7bfd80393](https://layerzeroscan.com/api/explorer/polygon/address/0xa2d10677441230c4aed58030e4ea6ba7bfd80393)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p-ops-team.svg)P-OPS|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xa75abcc0fab6ae09c8fd808bec7be7e88fe31d6b](https://layerzeroscan.com/api/explorer/polygon/address/0xa75abcc0fab6ae09c8fd808bec7be7e88fe31d6b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p2p.svg)P2P| ![](https://icons-
ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x9eeee79f5dbc4d99354b5cb547c138af432f937b](https://layerzeroscan.com/api/explorer/polygon/address/0x9eeee79f5dbc4d99354b5cb547c138af432f937b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/planetarium-labs.svg)Planetarium
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon
Mainnet|
[0x2ac038606fff3fb00317b8f0ccfb4081694acdd0](https://layerzeroscan.com/api/explorer/polygon/address/0x2ac038606fff3fb00317b8f0ccfb4081694acdd0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/polygon/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/portal.svg)Portal|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x8fc629aa400d4d9c0b118f2685a49316552abf27](https://layerzeroscan.com/api/explorer/polygon/address/0x8fc629aa400d4d9c0b118f2685a49316552abf27)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/republic-crypto.svg)Republic|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x547bf6889b1095b7cc6e525a1f8e8fdb26134a38](https://layerzeroscan.com/api/explorer/polygon/address/0x547bf6889b1095b7cc6e525a1f8e8fdb26134a38)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/restake.svg)Restake|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x2afa3787cd95fee5d5753cd717ef228eb259f4ea](https://layerzeroscan.com/api/explorer/polygon/address/0x2afa3787cd95fee5d5753cd717ef228eb259f4ea)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/mercury.svg)Shrapnel|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x54dd79f5ce72b51fcbbcb170dd01e32034323565](https://layerzeroscan.com/api/explorer/polygon/address/0x54dd79f5ce72b51fcbbcb170dd01e32034323565)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stablelab.svg)StableLab|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xabc9b1819cc4d9846550f928b985993cf6240439](https://layerzeroscan.com/api/explorer/polygon/address/0xabc9b1819cc4d9846550f928b985993cf6240439)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stakingcabin.svg)StakingCabin|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0x53bdce6dccf7505a55813022f53c43fabfef7b3a](https://layerzeroscan.com/api/explorer/polygon/address/0x53bdce6dccf7505a55813022f53c43fabfef7b3a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xc79f0b1bcb7cdae9f9ba547dcfc57cbfcd2993a5](https://layerzeroscan.com/api/explorer/polygon/address/0xc79f0b1bcb7cdae9f9ba547dcfc57cbfcd2993a5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/switchboard.svg)Switchboard|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xc6d46f63578635e4a7140cdf4d0eea0fd7bb50ec](https://layerzeroscan.com/api/explorer/polygon/address/0xc6d46f63578635e4a7140cdf4d0eea0fd7bb50ec)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
[0xcd8ea69bbca0a2bb221aed59fa2704f01fc76a9f](https://layerzeroscan.com/api/explorer/polygon/address/0xcd8ea69bbca0a2bb221aed59fa2704f01fc76a9f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/zkevm.svg)Polygon zkEVM
Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/zkevm/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/zkevm.svg)Polygon zkEVM
Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/zkevm/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/zkevm.svg)Polygon zkEVM
Mainnet|
[0x488863d609f3a673875a914fbee7508a1de45ec6](https://layerzeroscan.com/api/explorer/zkevm/address/0x488863d609f3a673875a914fbee7508a1de45ec6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/zkevm.svg)Polygon zkEVM
Mainnet|
[0x7a7ddc46882220a075934f40380d3a7e1e87d409](https://layerzeroscan.com/api/explorer/zkevm/address/0x7a7ddc46882220a075934f40380d3a7e1e87d409)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/zkpolygon-
sepolia.svg)Polygon zkEVM Sepolia Testnet|
[0x55c175dd5b039331db251424538169d8495c18d1](https://layerzeroscan.com/api/explorer/zkpolygon-
sepolia/address/0x55c175dd5b039331db251424538169d8495c18d1)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/rarible.svg)Rari Chain|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/rarible/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/rarible.svg)Rari Chain|
[0x0b5e5452d0c9da1bb5fb0664f48313e9667d7820](https://layerzeroscan.com/api/explorer/rarible/address/0x0b5e5452d0c9da1bb5fb0664f48313e9667d7820)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/rarible.svg)Rari Chain|
[0xb53648ca1aa054a80159c1175c03679fdc76bf88](https://layerzeroscan.com/api/explorer/rarible/address/0xb53648ca1aa054a80159c1175c03679fdc76bf88)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/rarible.svg)Rari Chain|
[0x2fa870cee4da57de84d1db36759d4716ad7e5038](https://layerzeroscan.com/api/explorer/rarible/address/0x2fa870cee4da57de84d1db36759d4716ad7e5038)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/rarible-
testnet.svg)Rarible Testnet|
[0xfc7c4b995a9293a1123bdd425531cfcd71082de4](https://layerzeroscan.com/api/explorer/rarible-
testnet/address/0xfc7c4b995a9293a1123bdd425531cfcd71082de4)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/real.svg)re.al Mainnet|
[0x439264fb87581a70bb6d7befd16b636521b0ad2d](https://layerzeroscan.com/api/explorer/real/address/0x439264fb87581a70bb6d7befd16b636521b0ad2d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/real.svg)re.al Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/real/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/real.svg)re.al Mainnet|
[0xabc9b1819cc4d9846550f928b985993cf6240439](https://layerzeroscan.com/api/explorer/real/address/0xabc9b1819cc4d9846550f928b985993cf6240439)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/reya.svg)Reya Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/reya/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/reya-testnet.svg)Reya
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/reya-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/root-testnet.svg)Root
Testnet|
[0xb100823baa9f8d625052fc8f544fc307b0184b18](https://layerzeroscan.com/api/explorer/root-
testnet/address/0xb100823baa9f8d625052fc8f544fc307b0184b18)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/sanko.svg)Sanko Mainnet|
[0x5fddd320a1e29bb466fa635661b125d51d976f92](https://layerzeroscan.com/api/explorer/sanko/address/0x5fddd320a1e29bb466fa635661b125d51d976f92)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/sanko.svg)Sanko
Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/sanko/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/omni-x.svg)Omni X|
![](https://icons-ckg.pages.dev/lz-scan/networks/sanko.svg)Sanko Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/sanko/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/sanko-testnet.svg)Sanko
Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/sanko-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/axelar.svg)Axelar|
![](https://icons-ckg.pages.dev/lz-scan/networks/scroll.svg)Scroll Mainnet|
[0x70cedf51c199fad12c6c0a71cd876af948059540](https://layerzeroscan.com/api/explorer/scroll/address/0x70cedf51c199fad12c6c0a71cd876af948059540)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/scroll.svg)Scroll Mainnet|
[0x7a7ddc46882220a075934f40380d3a7e1e87d409](https://layerzeroscan.com/api/explorer/scroll/address/0x7a7ddc46882220a075934f40380d3a7e1e87d409)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/scroll.svg)Scroll Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/scroll/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/scroll.svg)Scroll Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/scroll/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/scroll.svg)Scroll
Mainnet|
[0xbe0d08a85eebfcc6eda0a843521f7cbb1180d2e2](https://layerzeroscan.com/api/explorer/scroll/address/0xbe0d08a85eebfcc6eda0a843521f7cbb1180d2e2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/scroll.svg)Scroll Mainnet|
[0x446755349101cb20c582c224462c3912d3584dce](https://layerzeroscan.com/api/explorer/scroll/address/0x446755349101cb20c582c224462c3912d3584dce)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/p-ops-team.svg)P-OPS|
![](https://icons-ckg.pages.dev/lz-scan/networks/scroll.svg)Scroll Mainnet|
[0x34730f2570e6cff8b1c91faabf37d0dd917c4367](https://layerzeroscan.com/api/explorer/scroll/address/0x34730f2570e6cff8b1c91faabf37d0dd917c4367)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/scroll.svg)Scroll Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/scroll/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/scroll.svg)Scroll Mainnet|
[0xb87591d8b0b93fae8b631a073577c40e8dd46a62](https://layerzeroscan.com/api/explorer/scroll/address/0xb87591d8b0b93fae8b631a073577c40e8dd46a62)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/scroll.svg)Scroll Mainnet|
[0x05aaefdf9db6e0f7d27fa3b6ee099edb33da029e](https://layerzeroscan.com/api/explorer/scroll/address/0x05aaefdf9db6e0f7d27fa3b6ee099edb33da029e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/scroll-testnet.svg)Scroll
Sepolia Testnet|
[0xca01daa8e559cb6a810ce7906ec2aea39bdecce4](https://layerzeroscan.com/api/explorer/scroll-
testnet/address/0xca01daa8e559cb6a810ce7906ec2aea39bdecce4)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/scroll-
testnet.svg)Scroll Sepolia Testnet|
[0xb186f85d0604fe58af2ea33fe40244f5eef7351b](https://layerzeroscan.com/api/explorer/scroll-
testnet/address/0xb186f85d0604fe58af2ea33fe40244f5eef7351b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/sei.svg)Sei Mainnet|
[0x1feb08b1a53a9710afce82d380b8c2833c69a37e](https://layerzeroscan.com/api/explorer/sei/address/0x1feb08b1a53a9710afce82d380b8c2833c69a37e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/sei.svg)Sei Mainnet|
[0x87048402c32632b7c4d0a892d82bc1160e8b2393](https://layerzeroscan.com/api/explorer/sei/address/0x87048402c32632b7c4d0a892d82bc1160e8b2393)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/sei.svg)Sei Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/sei/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/sei.svg)Sei Mainnet|
[0xd24972c11f91c1bb9eaee97ec96bb9c33cf7af24](https://layerzeroscan.com/api/explorer/sei/address/0xd24972c11f91c1bb9eaee97ec96bb9c33cf7af24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/sei.svg)Sei Mainnet|
[0xbd00c87850416db0995ef8030b104f875e1bdd15](https://layerzeroscan.com/api/explorer/sei/address/0xbd00c87850416db0995ef8030b104f875e1bdd15)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/sei-testnet.svg)Sei
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/sei-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/shimmer.svg)Shimmer Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/shimmer/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/shimmer.svg)Shimmer Mainnet|
[0xa59ba433ac34d2927232918ef5b2eaafcf130ba5](https://layerzeroscan.com/api/explorer/shimmer/address/0xa59ba433ac34d2927232918ef5b2eaafcf130ba5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/shimmer.svg)Shimmer
Mainnet|
[0x9bdf3ae7e2e3d211811e5e782a808ca0a75bf1fc](https://layerzeroscan.com/api/explorer/shimmer/address/0x9bdf3ae7e2e3d211811e5e782a808ca0a75bf1fc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/shimmer.svg)Shimmer Mainnet|
[0x5fddd320a1e29bb466fa635661b125d51d976f92](https://layerzeroscan.com/api/explorer/shimmer/address/0x5fddd320a1e29bb466fa635661b125d51d976f92)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/skale.svg)Skale
Mainnet|
[0xce8358bc28dd8296ce8caf1cd2b44787abd65887](https://layerzeroscan.com/api/explorer/skale/address/0xce8358bc28dd8296ce8caf1cd2b44787abd65887)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/skale-testnet.svg)Skale
Testnet|
[0x955412c07d9bc1027eb4d481621ee063bfd9f4c6](https://layerzeroscan.com/api/explorer/skale-
testnet/address/0x955412c07d9bc1027eb4d481621ee063bfd9f4c6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/google-cloud.svg)Google Cloud|
![](https://icons-ckg.pages.dev/lz-scan/networks/solana.svg)Solana Mainnet|
[F7gu9kLcpn4bSTZn183mhn2RXUuMy7zckdxJZdUjuALw](https://layerzeroscan.com/api/explorer/solana/address/F7gu9kLcpn4bSTZn183mhn2RXUuMy7zckdxJZdUjuALw)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/solana.svg)Solana Mainnet|
[HR9NQKK1ynW9NzgdM37dU5CBtqRHTukmbMKS7qkwSkHX](https://layerzeroscan.com/api/explorer/solana/address/HR9NQKK1ynW9NzgdM37dU5CBtqRHTukmbMKS7qkwSkHX)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/solana.svg)Solana
Mainnet|
[4VDjp6XQaxoZf5RGwiPU9NR1EXSZn2TP4ATMmiSzLfhb](https://layerzeroscan.com/api/explorer/solana/address/4VDjp6XQaxoZf5RGwiPU9NR1EXSZn2TP4ATMmiSzLfhb)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/solana.svg)Solana Mainnet|
[GPjyWr8vCotGuFubDpTxDxy9Vj1ZeEN4F2dwRmFiaGab](https://layerzeroscan.com/api/explorer/solana/address/GPjyWr8vCotGuFubDpTxDxy9Vj1ZeEN4F2dwRmFiaGab)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/solana-
testnet.svg)Solana Testnet|
[4VDjp6XQaxoZf5RGwiPU9NR1EXSZn2TP4ATMmiSzLfhb](https://layerzeroscan.com/api/explorer/solana-
testnet/address/4VDjp6XQaxoZf5RGwiPU9NR1EXSZn2TP4ATMmiSzLfhb)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/story-testnet.svg)Story
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/story-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/taiko.svg)Taiko Mainnet|
[0xbd237ef21319e2200487bdf30c188c6c34b16d3b](https://layerzeroscan.com/api/explorer/taiko/address/0xbd237ef21319e2200487bdf30c188c6c34b16d3b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/taiko.svg)Taiko
Mainnet|
[0xc097ab8cd7b053326dfe9fb3e3a31a0cce3b526f](https://layerzeroscan.com/api/explorer/taiko/address/0xc097ab8cd7b053326dfe9fb3e3a31a0cce3b526f)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/taiko.svg)Taiko Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/taiko/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/taiko.svg)Taiko Mainnet|
[0x37473676ff697f2eba29c8a3105309abf00ba013](https://layerzeroscan.com/api/explorer/taiko/address/0x37473676ff697f2eba29c8a3105309abf00ba013)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/taiko-testnet.svg)Taiko
Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/taiko-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/tangible-
testnet.svg)Tangible Testnet|
[0x25d5882bd4b6d4aa72a877eb62c7096364ae210a](https://layerzeroscan.com/api/explorer/tangible-
testnet/address/0x25d5882bd4b6d4aa72a877eb62c7096364ae210a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/telos-testnet.svg)Telos
EVM Testnet|
[0x5b11f3833393e9be06fa702c68453ad31976866e](https://layerzeroscan.com/api/explorer/telos-
testnet/address/0x5b11f3833393e9be06fa702c68453ad31976866e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/telos.svg)TelosEVM Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/telos/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/telos.svg)TelosEVM Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/telos/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/telos.svg)TelosEVM
Mainnet|
[0x3c5575898f59c097681d1fc239c2c6ad36b7b41c](https://layerzeroscan.com/api/explorer/telos/address/0x3c5575898f59c097681d1fc239c2c6ad36b7b41c)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/telos.svg)TelosEVM Mainnet|
[0x809cde2afcf8627312e87a6a7bbffab3f8f347c7](https://layerzeroscan.com/api/explorer/telos/address/0x809cde2afcf8627312e87a6a7bbffab3f8f347c7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/tenet.svg)Tenet Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/tenet/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/tenet.svg)Tenet Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/tenet/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/tenet.svg)Tenet
Mainnet|
[0x28a5536ca9f36c45a9d2ac8d2b62fc46fde024b6](https://layerzeroscan.com/api/explorer/tenet/address/0x28a5536ca9f36c45a9d2ac8d2b62fc46fde024b6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/tenet-testnet.svg)Tenet
Testnet|
[0x74582424b8b92be2ec17c192f6976b2effefab7c](https://layerzeroscan.com/api/explorer/tenet-
testnet/address/0x74582424b8b92be2ec17c192f6976b2effefab7c)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/tiltyard.svg)Tiltyard|
[0x0165c910ea47964a23dc4fb7c7483f6f3ad462ae](https://layerzeroscan.com/api/explorer/tiltyard/address/0x0165c910ea47964a23dc4fb7c7483f6f3ad462ae)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/tiltyard.svg)Tiltyard|
[0xcfc3f9dd0205b76ff04e20243f106465dd829656](https://layerzeroscan.com/api/explorer/tiltyard/address/0xcfc3f9dd0205b76ff04e20243f106465dd829656)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/treasure-
testnet.svg)Treasure Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/treasure-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/tron.svg)Tron Mainnet|
[0xfee824cc7ced4f2ba7a0e72e5cfe20fd2197cd53](https://layerzeroscan.com/api/explorer/tron/address/0xfee824cc7ced4f2ba7a0e72e5cfe20fd2197cd53)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/tron.svg)Tron Mainnet|
[0x8bc1d368036ee5e726d230beb685294be191a24e](https://layerzeroscan.com/api/explorer/tron/address/0x8bc1d368036ee5e726d230beb685294be191a24e)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/tron.svg)Tron Mainnet|
[0xfd952ea14b87fb18d4a1119be0be45064e448f45](https://layerzeroscan.com/api/explorer/tron/address/0xfd952ea14b87fb18d4a1119be0be45064e448f45)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/tron.svg)Tron Mainnet|
[0x1de9dec8465638b07c198f53f1d4cb2a92be729c](https://layerzeroscan.com/api/explorer/tron/address/0x1de9dec8465638b07c198f53f1d4cb2a92be729c)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/tron-testnet.svg)Tron
Testnet|
[0xc6b1a264d9bb30a8d19575b0bb3ba525a3a6fc93](https://layerzeroscan.com/api/explorer/tron-
testnet/address/0xc6b1a264d9bb30a8d19575b0bb3ba525a3a6fc93)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/unichain-
testnet.svg)Unichain Testnet|
[0x6236072727ae3dfe29bafe9606e41827be8c6341](https://layerzeroscan.com/api/explorer/unichain-
testnet/address/0x6236072727ae3dfe29bafe9606e41827be8c6341)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/unreal-
testnet.svg)Unreal Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/unreal-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/vanguard-
testnet.svg)Vanguard Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/vanguard-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/tomo.svg)Viction Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/tomo/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/tomo.svg)Viction Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/tomo/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/tomo.svg)Viction
Mainnet|
[0x1ace9dd1bc743ad036ef2d92af42ca70a1159df5](https://layerzeroscan.com/api/explorer/tomo/address/0x1ace9dd1bc743ad036ef2d92af42ca70a1159df5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/tomo.svg)Viction Mainnet|
[0x790d7b1e97a086eb0012393b65a5b32ce58a04dc](https://layerzeroscan.com/api/explorer/tomo/address/0x790d7b1e97a086eb0012393b65a5b32ce58a04dc)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/tomo-
testnet.svg)Viction Testnet|
[0x37d03c8d27d7928546b5b773566ec9c2847054d2](https://layerzeroscan.com/api/explorer/tomo-
testnet/address/0x37d03c8d27d7928546b5b773566ec9c2847054d2)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-
scan/networks/worldchain.svg)Worldchain|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/worldchain/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/worldcoin-
testnet.svg)Worldcoin Testnet|
[0x55c175dd5b039331db251424538169d8495c18d1](https://layerzeroscan.com/api/explorer/worldcoin-
testnet/address/0x55c175dd5b039331db251424538169d8495c18d1)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/xlayer.svg)X Layer Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/xlayer/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/xlayer.svg)X Layer
Mainnet|
[0x9c061c9a4782294eef65ef28cb88233a987f4bdd](https://layerzeroscan.com/api/explorer/xlayer/address/0x9c061c9a4782294eef65ef28cb88233a987f4bdd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/xlayer.svg)X Layer Mainnet|
[0x28af4dadbc5066e994986e8bb105240023dc44b6](https://layerzeroscan.com/api/explorer/xlayer/address/0x28af4dadbc5066e994986e8bb105240023dc44b6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/polyhedra-network.svg)Polyhedra|
![](https://icons-ckg.pages.dev/lz-scan/networks/xlayer.svg)X Layer Mainnet|
[0x8ddf05f9a5c488b4973897e278b58895bf87cb24](https://layerzeroscan.com/api/explorer/xlayer/address/0x8ddf05f9a5c488b4973897e278b58895bf87cb24)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/xlayer-testnet.svg)X
Layer Testnet|
[0x55c175dd5b039331db251424538169d8495c18d1](https://layerzeroscan.com/api/explorer/xlayer-
testnet/address/0x55c175dd5b039331db251424538169d8495c18d1)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/xai.svg)Xai Mainnet|
[0x34730f2570e6cff8b1c91faabf37d0dd917c4367](https://layerzeroscan.com/api/explorer/xai/address/0x34730f2570e6cff8b1c91faabf37d0dd917c4367)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/xai.svg)Xai Mainnet|
[0x9c061c9a4782294eef65ef28cb88233a987f4bdd](https://layerzeroscan.com/api/explorer/xai/address/0x9c061c9a4782294eef65ef28cb88233a987f4bdd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/xai.svg)Xai Mainnet|
[0xacde1f22eeab249d3ca6ba8805c8fee9f52a16e7](https://layerzeroscan.com/api/explorer/xai/address/0xacde1f22eeab249d3ca6ba8805c8fee9f52a16e7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/xai-testnet.svg)Xai
Testnet|
[0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6](https://layerzeroscan.com/api/explorer/xai-
testnet/address/0xf49d162484290eaead7bb8c2c7e3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/xchain.svg)XChain Mainnet|
[0x0e5c792ec122cbe89ce0085d7efcdb151eae3376](https://layerzeroscan.com/api/explorer/xchain/address/0x0e5c792ec122cbe89ce0085d7efcdb151eae3376)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/xchain.svg)XChain
Mainnet|
[0x9c061c9a4782294eef65ef28cb88233a987f4bdd](https://layerzeroscan.com/api/explorer/xchain/address/0x9c061c9a4782294eef65ef28cb88233a987f4bdd)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/xchain.svg)XChain Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/xchain/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/xchain.svg)XChain Mainnet|
[0x56053a8f4db677e5774f8ee5bdd9d2dc270075f3](https://layerzeroscan.com/api/explorer/xchain/address/0x56053a8f4db677e5774f8ee5bdd9d2dc270075f3)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/xchain-
testnet.svg)XChain Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/xchain-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/xpla.svg)XPLA Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/xpla/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/xpla.svg)XPLA Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/xpla/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/xpla.svg)XPLA Mainnet|
[0x2d24207f9c1f77b2e08f2c3ad430da18e355cf66](https://layerzeroscan.com/api/explorer/xpla/address/0x2d24207f9c1f77b2e08f2c3ad430da18e355cf66)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/xpla.svg)XPLA Mainnet|
[0x809cde2afcf8627312e87a6a7bbffab3f8f347c7](https://layerzeroscan.com/api/explorer/xpla/address/0x809cde2afcf8627312e87a6a7bbffab3f8f347c7)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/xpla-testnet.svg)XPLA
Testnet|
[0x0747d0dabb284e5fbaeeea427bba7b2fba507120](https://layerzeroscan.com/api/explorer/xpla-
testnet/address/0x0747d0dabb284e5fbaeeea427bba7b2fba507120)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/zircuit.svg)Zircuit Mainnet|
[0xdcdd4628f858b45260c31d6ad076bd2c3d3c2f73](https://layerzeroscan.com/api/explorer/zircuit/address/0xdcdd4628f858b45260c31d6ad076bd2c3d3c2f73)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/zircuit.svg)Zircuit
Mainnet|
[0x6788f52439aca6bff597d3eec2dc9a44b8fee842](https://layerzeroscan.com/api/explorer/zircuit/address/0x6788f52439aca6bff597d3eec2dc9a44b8fee842)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/zircuit.svg)Zircuit Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/zircuit/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/zircuit-
testnet.svg)Zircuit Testnet|
[0x88b27057a9e00c5f05dda29241027aff63f9e6e0](https://layerzeroscan.com/api/explorer/zircuit-
testnet/address/0x88b27057a9e00c5f05dda29241027aff63f9e6e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/zklink.svg)zkLink Mainnet|
[0x1253e268bc04bb43cb96d2f7ee858b8a1433cf6d](https://layerzeroscan.com/api/explorer/zklink/address/0x1253e268bc04bb43cb96d2f7ee858b8a1433cf6d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/zklink.svg)zkLink Mainnet|
[0x27bb790440376db53c840326263801fafd9f0ee6](https://layerzeroscan.com/api/explorer/zklink/address/0x27bb790440376db53c840326263801fafd9f0ee6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/zklink.svg)zkLink
Mainnet|
[0x04830f6decf08dec9ed6c3fcad215245b78a59e1](https://layerzeroscan.com/api/explorer/zklink/address/0x04830f6decf08dec9ed6c3fcad215245b78a59e1)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nodes-guru.svg)Nodes.Guru|
![](https://icons-ckg.pages.dev/lz-scan/networks/zklink.svg)zkLink Mainnet|
[0x3a5a74f863ec48c1769c4ee85f6c3d70f5655e2a](https://layerzeroscan.com/api/explorer/zklink/address/0x3a5a74f863ec48c1769c4ee85f6c3d70f5655e2a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/zklink-
testnet.svg)zkLink Testnet|
[0x6869b4348fae6a911fdb5bae5e0d153b2aa261f6](https://layerzeroscan.com/api/explorer/zklink-
testnet/address/0x6869b4348fae6a911fdb5bae5e0d153b2aa261f6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/zksync.svg)zkSync Era
Mainnet|
[0x0d1bc4efd08940eb109ef3040c1386d09b6334e0](https://layerzeroscan.com/api/explorer/zksync/address/0x0d1bc4efd08940eb109ef3040c1386d09b6334e0)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bware-labs.svg)BWare|
![](https://icons-ckg.pages.dev/lz-scan/networks/zksync.svg)zkSync Era
Mainnet|
[0x3a5a74f863ec48c1769c4ee85f6c3d70f5655e2a](https://layerzeroscan.com/api/explorer/zksync/address/0x3a5a74f863ec48c1769c4ee85f6c3d70f5655e2a)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/zksync.svg)zkSync Era
Mainnet|
[0x1253e268bc04bb43cb96d2f7ee858b8a1433cf6d](https://layerzeroscan.com/api/explorer/zksync/address/0x1253e268bc04bb43cb96d2f7ee858b8a1433cf6d)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/zksync.svg)zkSync Era
Mainnet|
[0x620a9df73d2f1015ea75aea1067227f9013f5c51](https://layerzeroscan.com/api/explorer/zksync/address/0x620a9df73d2f1015ea75aea1067227f9013f5c51)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/zksync.svg)zkSync Era
Mainnet|
[0xb183c2b91cf76cad13602b32ada2fd273f19009c](https://layerzeroscan.com/api/explorer/zksync/address/0xb183c2b91cf76cad13602b32ada2fd273f19009c)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/stargate.svg)Stargate|
![](https://icons-ckg.pages.dev/lz-scan/networks/zksync.svg)zkSync Era
Mainnet|
[0x62aa89bad332788021f6f4f4fb196d5fe59c27a6](https://layerzeroscan.com/api/explorer/zksync/address/0x62aa89bad332788021f6f4f4fb196d5fe59c27a6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/zenrock.svg)Zenrock|
![](https://icons-ckg.pages.dev/lz-scan/networks/zksync.svg)zkSync Era
Mainnet|
[0xc4a1f52fda034a9a5e1b3b27d14451d15776fef6](https://layerzeroscan.com/api/explorer/zksync/address/0xc4a1f52fda034a9a5e1b3b27d14451d15776fef6)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/zksync-
sepolia.svg)zkSync Sepolia Testnet|
[0x605688c4caa80d17448e074faa463ed7b7693d63](https://layerzeroscan.com/api/explorer/zksync-
sepolia/address/0x605688c4caa80d17448e074faa463ed7b7693d63)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/bcw.svg)BCW Group|
![](https://icons-ckg.pages.dev/lz-scan/networks/zora.svg)Zora Mainnet|
[0x7fe673201724925b5c477d4e1a4bd3e954688cf5](https://layerzeroscan.com/api/explorer/zora/address/0x7fe673201724925b5c477d4e1a4bd3e954688cf5)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/horizen-labs.svg)Horizen|
![](https://icons-ckg.pages.dev/lz-scan/networks/zora.svg)Zora Mainnet|
[0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b](https://layerzeroscan.com/api/explorer/zora/address/0xdd7b5e1db4aafd5c8ec3b764efb8ed265aa5445b)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/zora.svg)Zora Mainnet|
[0xc1ec25a9e8a8de5aa346f635b33e5b74c4c081af](https://layerzeroscan.com/api/explorer/zora/address/0xc1ec25a9e8a8de5aa346f635b33e5b74c4c081af)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/nethermind.svg)Nethermind|
![](https://icons-ckg.pages.dev/lz-scan/networks/zora.svg)Zora Mainnet|
[0xa7b5189bca84cd304d8553977c7c614329750d99](https://layerzeroscan.com/api/explorer/zora/address/0xa7b5189bca84cd304d8553977c7c614329750d99)  
![](https://icons-ckg.pages.dev/lz-scan/dvns/layerzero-labs.svg)LayerZero
Labs| ![](https://icons-ckg.pages.dev/lz-scan/networks/zora-sepolia.svg)Zora
Sepolia Testnet|
[0x701f3927871efcea1235db722f9e608ae120d243](https://layerzeroscan.com/api/explorer/zora-
sepolia/address/0x701f3927871efcea1235db722f9e608ae120d243)  
  
[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/technical-reference/dvn-addresses.md)



  * Protocol & Gas Settings
  * Security & Executor Configuration

Version: Endpoint V2 Docs

On this page

# OApp Security Stack and Executor Configuration

LayerZero defines a pathway as any configuration where any two points (OApp on
Chain A and OApp on Chain B), have each called the
[`setPeer`](/v2/developers/evm/oapp/overview#setting-peers) function and
enabled messaging to and from each contract instance.

Every LayerZero Endpoint can be used to send and receive messages. Because of
that, **each Endpoint has a separate Send and Receive Configuration** , which
an OApp can configure per target Endpoint (i.e., sending to that target,
receiving from that target).

![Protocol V2
Light](/assets/images/dvn_overview_light-c0dc62c4255d9f400a9ead48434b4265.svg#gh-
light-mode-only) ![Protocol V2
Dark](/assets/images/dvn_overview_dark-514e43593b8d7a910d7d851fa9272365.svg#gh-
dark-mode-only)

For a configuration to be considered correct, **the Send Library
configurations on Chain A must match Chain B's Receive Library configurations
for filtering messages.**

info

In the diagram above, the **Source OApp** has added the DVN's source chain
address to the Send Library configuration.

The **Destination OApp** has added the DVN's destination chain address to the
Receive Library configuration.

The DVN can now read from the source chain, and deliver the message to the
destination chain.

## Checking Default Configuration​

For commonly travelled pathways, LayerZero provides a **default pathway
configuration**. If you provide no configuration prior to setting peers, the
protocol will fallback to the default configuration.

The default configuration varies from pathway to pathway, based on the unique
properties of each chain, and which decentralized verifier networks or
executors listen for those networks.

A default pathway configuration, at the time of writing, will always have one
of the following set within `SendULN302.sol` and `ReceiveUlN302.sol` as a
**Preset Configuration** :

| Security Stack| Executor  
---|---|---  
**Default Send and Receive A**|  requiredDVNs: [ Google Cloud, LayerZero Labs
]| LayerZero Labs  
**Default Send and Receive B**|  requiredDVNs: [ Polyhedra, LayerZero Labs ]|
LayerZero Labs  
**Default Send and Receive C**|  requiredDVNs: [ Dead DVN, LayerZero Labs ]|
LayerZero Labs  
  

info

What is a **Dead DVN**?

Since LayerZero allows for anyone to permissionlessly run DVNs, the network
may occassionally add new chain Endpoints before the default providers (Google
Cloud or Polyhedra) support every possible pathway to and from that chain.

A default configuration with a **Dead DVN** will require you to either
configure an available DVN provider for that Send or Receive pathway, or run
your own DVN if no other security providers exist, before messages can safely
be delivered to and from that chain.

  

Other default configuration settings, like source and destination block
confirmations, will vary per chain pathway based on recommendations provided
by each chain.

To read the default configuration, you can call the LayerZero Endpoint's
`getConfig` method to return the default send and receive configuration for
that target Endpoint.

    
    
    /**  
     * @notice This function is used to retrieve configuration data for a specific OApp using a LayerZero Endpoint on the same chain.  
     *  
     * @param _oapp Address of the OApp for which the configuration is being retrieved.  
     * @param _lib Address of the library (send or receive) used by the OApp at the specified endpoint.  
     * @param _eid Endpoint ID (EID) of the target endpoint on the other side of the pathway. The EID filters  
     * the configurations specifically for the target endpoint, which is crucial for ensuring that messages are  
     * sent and received correctly and securely between the configured endpoints (pathways).  
     * @param _configType Type of configuration to retrieve (e.g., executor configuration, ULN configuration).  
     * This parameter specifies the format and data of the returned configuration.  
     *  
     * @return config Returns the configuration data as bytes, which can be decoded into the respective  
     * configuration structure as per the requested _configType.  
     */  
    function getConfig(  
        address _oapp,  
        address _lib,  
        uint32 _eid,  
        uint32 _configType  
    ) external view returns (bytes memory config);  
    

tip

The [**create-lz-oapp**](/v2/developers/evm/create-lz-oapp/start#configuring-
layerzero-contracts) npx package also provides a faster CLI command to return
every default configuration for each pathway in your project!

    
    
    npx hardhat lz:oapp:config:get:default  
    

  

The example below uses
[`defaultAbiCoder`](https://docs.ethers.org/v5/api/utils/abi/coder/) from the
ethers.js (`^5.7.2`) library to decode the bytes arrays returned by an OApp
using the Ethereum Mainnet Endpoint:

    
    
    import * as ethers from 'ethers';  
      
    // Define provider  
    const provider = new ethers.providers.JsonRpcProvider('YOUR_RPC_PROVIDER_HERE');  
      
    // Define the smart contract address and ABI  
    const ethereumLzEndpointAddress = '0x1a44076050125825900e736c501f859c50fE728c';  
    const ethereumLzEndpointABI = [  
      'function getConfig(address _oapp, address _lib, uint32 _eid, uint32 _configType) external view returns (bytes memory config)',  
    ];  
      
    // Create a contract instance  
    const contract = new ethers.Contract(ethereumLzEndpointAddress, ethereumLzEndpointABI, provider);  
      
    // Define the addresses and parameters  
    const oappAddress = '0xEB6671c152C88E76fdAaBC804Bf973e3270f4c78';  
    const sendLibAddress = '0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1';  
    const receiveLibAddress = '0xc02Ab410f0734EFa3F14628780e6e695156024C2';  
    const remoteEid = 30102; // Example target endpoint ID, Binance Smart Chain  
    const executorConfigType = 1; // 1 for executor  
    const ulnConfigType = 2; // 2 for UlnConfig  
      
    async function getConfigAndDecode() {  
      try {  
        // Fetch and decode for sendLib (both Executor and ULN Config)  
        const sendExecutorConfigBytes = await contract.getConfig(  
          oappAddress,  
          sendLibAddress,  
          remoteEid,  
          executorConfigType,  
        );  
        const executorConfigAbi = ['tuple(uint32 maxMessageSize, address executorAddress)'];  
        const executorConfigArray = ethers.utils.defaultAbiCoder.decode(  
          executorConfigAbi,  
          sendExecutorConfigBytes,  
        );  
        console.log('Send Library Executor Config:', executorConfigArray);  
      
        const sendUlnConfigBytes = await contract.getConfig(  
          oappAddress,  
          sendLibAddress,  
          remoteEid,  
          ulnConfigType,  
        );  
        const ulnConfigStructType = [  
          'tuple(uint64 confirmations, uint8 requiredDVNCount, uint8 optionalDVNCount, uint8 optionalDVNThreshold, address[] requiredDVNs, address[] optionalDVNs)',  
        ];  
        const sendUlnConfigArray = ethers.utils.defaultAbiCoder.decode(  
          ulnConfigStructType,  
          sendUlnConfigBytes,  
        );  
        console.log('Send Library ULN Config:', sendUlnConfigArray);  
      
        // Fetch and decode for receiveLib (only ULN Config)  
        const receiveUlnConfigBytes = await contract.getConfig(  
          oappAddress,  
          receiveLibAddress,  
          remoteEid,  
          ulnConfigType,  
        );  
        const receiveUlnConfigArray = ethers.utils.defaultAbiCoder.decode(  
          ulnConfigStructType,  
          receiveUlnConfigBytes,  
        );  
        console.log('Receive Library ULN Config:', receiveUlnConfigArray);  
      } catch (error) {  
        console.error('Error fetching or decoding config:', error);  
      }  
    }  
      
    // Execute the function  
    getConfigAndDecode();  
    

The `getConfig` function will return you an array of values from both the
SendLib and ReceiveLib's configurations.

The logs below show the output from the Ethereum Endpoint for `SendLib302.sol`
when sending messages to Binance Smart Chain:

    
    
    Send Library Executor Config:  
    executorAddress: "0x173272739Bd7Aa6e4e214714048a9fE699453059"  
    maxMessageSize: 10000  
      
    Send Library ULN Config:  
    confirmations: {_hex: '0x0f', _isBigNumber: true} // this is just big number 15  
    optionalDVNCount: 0  
    optionalDVNThreshold: 0  
    optionalDVNs: Array(0)  
    requiredDVNCount: 2  
    requiredDVNs: Array(2)  
      0: "0x589dEDbD617e0CBcB916A9223F4d1300c294236b"  // LZ Ethereum DVN Address  
      1: "0xD56e4eAb23cb81f43168F9F45211Eb027b9aC7cc"  // Google Cloud Ethereum DVN Address  
    

And when the Ethereum Endpoint uses `ReceiveLib302.sol` to receive messages
from Binance Smart Chain:

    
    
    Receive Library ULN Config  
      
    confirmations: {_hex: '0x0f', _isBigNumber: true} // this is just big number 15  
    optionalDVNCount: 0  
    optionalDVNThreshold: 0  
    optionalDVNs: Array(0)  
    requiredDVNCount: 2  
    requiredDVNs: Array(2)  
      0: "0x589dEDbD617e0CBcB916A9223F4d1300c294236b" // LZ Ethereum DVN Address  
      1: "0xD56e4eAb23cb81f43168F9F45211Eb027b9aC7cc" // Google Cloud Ethereum DVN Address  
    

info

The important takeaway is that every LayerZero Endpoint can be used to send
and receive messages. Because of that, **each Endpoint has a separate Send and
Receive Configuration** , which an OApp can configure by the target
destination Endpoint.

In the above example, the default Send Library configurations control how
messages emit from the **Ethereum Endpoint** to the BNB Endpoint.

The default Receive Library configurations control how the **Ethereum
Endpoint** filters received messages from the BNB Endpoint.

For a configuration to be considered correct, **the Send Library
configurations on Chain A must match Chain B's Receive Library configurations
for filtering messages.**

**Challenge:** Confirm that the BNB Endpoint's Send Library ULN configuration
matches the Ethereum Endpoint's Receive Library ULN Configuration using the
methods above.

## Custom Configuration​

To use non-default protocol settings, the
[delegate](/v2/developers/evm/oapp/overview#setting-delegates) (should always
be OApp owner) should call `setSendLibrary`, `setReceiveLibrary`, and
`setConfig` from the OApp's Endpoint.

When setting your OApp's config, ensure that the Send Configuration for the
OApp on the sending chain (Chain A) matches the Receive Configuration for the
OApp on the receiving chain (Chain B).

Both configurations must be appropriately matched and set across the relevant
chains to ensure successful communication and data transfer.

info

The `setDelegate` function in LayerZero's OApp allows the contract owner to
appoint a delegate who can manage configurations for both the Executor and
ULN. This delegate, once set, has the authority to modify configurations on
behalf of the OApp owner. We **strongly** recommend you always make sure owner
and delegate are the same address.

### Setting Send and Receive Libraries​

Before changing any OApp Send or Receive configurations, you should first
`setSendLibrary` and `setReceiveLibrary` to the intended library. At the time
of writing, the latest library for Endpoint V2 is `SendULN302.sol` and
`ReceiveULN302.sol`:

  * ethers
  * Foundry

    
    
    const {ethers} = require('ethers');  
      
    // Replace with your actual values  
    const YOUR_OAPP_ADDRESS = '0xYourOAppAddress';  
    const YOUR_SEND_LIB_ADDRESS = '0xYourSendLibAddress';  
    const YOUR_RECEIVE_LIB_ADDRESS = '0xYourReceiveLibAddress';  
    const YOUR_ENDPOINT_CONTRACT_ADDRESS = '0xYourEndpointContractAddress';  
    const YOUR_RPC_URL = 'YOUR_RPC_URL';  
    const YOUR_PRIVATE_KEY = 'YOUR_PRIVATE_KEY';  
      
    // Define the remote EID  
    const remoteEid = 30101; // Replace with your actual EID  
      
    // Set up the provider and signer  
    const provider = new ethers.providers.JsonRpcProvider(YOUR_RPC_URL);  
    const signer = new ethers.Wallet(YOUR_PRIVATE_KEY, provider);  
      
    // Set up the endpoint contract  
    const endpointAbi = [  
      'function setSendLibrary(address oapp, uint32 eid, address sendLib) external',  
      'function setReceiveLibrary(address oapp, uint32 eid, address receiveLib) external',  
    ];  
    const endpointContract = new ethers.Contract(YOUR_ENDPOINT_CONTRACT_ADDRESS, endpointAbi, signer);  
      
    async function setLibraries() {  
      try {  
        // Set the send library  
        const sendTx = await endpointContract.setSendLibrary(  
          YOUR_OAPP_ADDRESS,  
          remoteEid,  
          YOUR_SEND_LIB_ADDRESS,  
        );  
        console.log('Send library transaction sent:', sendTx.hash);  
        await sendTx.wait();  
        console.log('Send library set successfully.');  
      
        // Set the receive library  
        const receiveTx = await endpointContract.setReceiveLibrary(  
          YOUR_OAPP_ADDRESS,  
          remoteEid,  
          YOUR_RECEIVE_LIB_ADDRESS,  
        );  
        console.log('Receive library transaction sent:', receiveTx.hash);  
        await receiveTx.wait();  
        console.log('Receive library set successfully.');  
      } catch (error) {  
        console.error('Transaction failed:', error);  
      }  
    }  
      
    setLibraries();  
    
    
    
    // SPDX-License-Identifier: UNLICENSED  
    pragma solidity ^0.8.22;  
      
    // Forge imports  
    import "forge-std/console.sol";  
    import "forge-std/Script.sol";  
      
    // LayerZero imports  
    import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";  
      
    contract SetLibraries is Script {  
        function run(address _endpoint, address _oapp, uint32 _eid, address _sendLib, address _receiveLib, address _signer) external {  
            // Initialize the endpoint contract  
            ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(_endpoint);  
      
            // Start broadcasting transactions  
            vm.startBroadcast(_signer);  
      
            // Set the send library  
            endpoint.setSendLibrary(_oapp, _eid, _sendLib);  
            console.log("Send library set successfully.");  
      
            // Set the receive library  
            endpoint.setReceiveLibrary(_oapp, _eid, _receiveLib);  
            console.log("Receive library set successfully.");  
      
            // Stop broadcasting transactions  
            vm.stopBroadcast();  
        }  
    }  
    

info

Why do you need to set a `sendLibrary` and `receiveLibrary`?

LayerZero uses [**Appendable Message Libraries**](/v2/home/protocol/message-
library). This means that while existing versions will always be immutable and
available to configure, updates can still be added by deploying new Message
Libraries as separate contracts and having applications manually select the
new version.

If an OApp had **NOT** called `setSendLibrary` or `setReceiveLibrary`, the
LayerZero Endpoint will fallback to the default configuration, which may be
different than the MessageLib you have configured.

Explicitly setting the `sendLibrary` and `receiveLibrary` ensures that your
configurations will apply to the correct library version, and will not
fallback to any new library versions released.

### Setting Send Config​

You will call the same function in the Endpoint to set your `sendConfig` and
`receiveConfig`:

    
    
    /// @dev authenticated by the _oapp  
    function setConfig(  
      address _oapp,  
      address _lib,  
      SetConfigParam[] calldata _params  
    ) external onlyRegistered(_lib) {  
        _assertAuthorized(_oapp);  
      
        IMessageLib(_lib).setConfig(_oapp, _params);  
    }  
    

The `SetConfigParam` struct defines how to set custom parameters for a given
`configType` and the remote chain's `eid` (endpoint ID):

    
    
    struct SetConfigParam {  
        uint32 dstEid;  
        uint32 configType;  
        bytes config;  
    }  
    

The ULN and Executor have separate `config` types, which change how the bytes
array is structured:

    
    
    CONFIG_TYPE_ULN = 2; // Security Stack and block confirmation config  
      
    CONFIG_TYPE_EXECUTOR = 1; // Executor and max message size config  
    

Based on the `configType`, the MessageLib will expect one of the following
structures for the config bytes array:

    
    
    const configTypeUlnStruct =  
      'tuple(uint64 confirmations, uint8 requiredDVNCount, uint8 optionalDVNCount, uint8 optionalDVNThreshold, address[] requiredDVNs, address[] optionalDVNs)';  
      
    const configTypeExecutorStruct = 'tuple(uint32 maxMessageSize, address executorAddress)';  
    

Each `config` is encoded and passed as an ordered bytes array in your
`SetConfigParam` struct.

#### Send Config Type ULN (Security Stack)​

The `SendConfig` describes how messages should be emitted from the source
chain. See [DVN Addresses](/v2/developers/evm/technical-reference/dvn-
addresses) for the list of available DVNs.

Parameter| Type| Description  
---|---|---  
confirmations| `uint64`| The number of block confirmations to wait before a
DVN should listen for the `payloadHash`. This setting can be used to ensure
message finality on chains with frequent block reorganizations.  
requiredDVNCount| `uint8`| The quantity of required DVNs that will be paid to
send a message from the OApp.  
optionalDVNCount| `uint8`| The quantity of optional DVNs that will be paid to
send a message from the OApp.  
optionalDVNThreshold| `uint8`| The minimum number of verifications needed from
optional DVNs. A message is deemed Verifiable if it receives verifications
from at least the number of optional DVNs specified by the
`optionalDVNsThreshold`, plus the required DVNs.  
requiredDVNs| `address[]`| An array of addresses for all required DVNs.  
optionalDVNs| `address[]`| An array of addresses for all optional DVNs.  
  
caution

If you set your block confirmations too low, and a reorg occurs after your
confirmation, it can materially impact your OApp or OFT.

#### Send Config Type Executor​

See [Deployed LZ Endpoints and Addresses](/v2/developers/evm/technical-
reference/deployed-contracts) for every chain's Executor address.

Parameter| Type| Description  
---|---|---  
maxMessageSize| `uint32`| The maximum size of a message that can be sent
cross-chain (number of bytes).  
executor| `address`| The executor implementation to pay fees to for calling
the `lzReceive` function on the destination chain.  
  

  * ethers
  * Foundry

The example below uses ethers.js (`^5.7.2`) library to encode the arrays and
call the Endpoint contract:

    
    
    const {ethers} = require('ethers');  
      
    // Addresses  
    const oappAddress = 'YOUR_OAPP_ADDRESS'; // Replace with your OApp address  
    const sendLibAddress = 'YOUR_SEND_LIB_ADDRESS'; // Replace with your send message library address  
      
    // Configuration  
    const remoteEid = 30101; // Example EID, replace with the actual value  
    const ulnConfig = {  
      confirmations: 99, // Example value, replace with actual  
      requiredDVNCount: 2, // Example value, replace with actual  
      optionalDVNCount: 0, // Example value, replace with actual  
      optionalDVNThreshold: 0, // Example value, replace with actual  
      requiredDVNs: ['0xDvnAddress1', '0xDvnAddress2'], // Replace with actual addresses  
      optionalDVNs: [], // Replace with actual addresses  
    };  
      
    const executorConfig = {  
      maxMessageSize: 10000, // Example value, replace with actual  
      executorAddress: '0xExecutorAddress', // Replace with the actual executor address  
    };  
      
    // Provider and Signer  
    const provider = new ethers.providers.JsonRpcProvider(YOUR_RPC_URL);  
    const signer = new ethers.Wallet(YOUR_PRIVATE_KEY, provider);  
      
    // ABI and Contract  
    const endpointAbi = [  
      'function setConfig(address oappAddress, address sendLibAddress, tuple(uint32 eid, uint32 configType, bytes config)[] setConfigParams) external',  
    ];  
    const endpointContract = new ethers.Contract(YOUR_ENDPOINT_CONTRACT_ADDRESS, endpointAbi, signer);  
      
    // Encode UlnConfig using defaultAbiCoder  
    const configTypeUlnStruct =  
      'tuple(uint64 confirmations, uint8 requiredDVNCount, uint8 optionalDVNCount, uint8 optionalDVNThreshold, address[] requiredDVNs, address[] optionalDVNs)';  
    const encodedUlnConfig = ethers.utils.defaultAbiCoder.encode([configTypeUlnStruct], [ulnConfig]);  
      
    // Encode ExecutorConfig using defaultAbiCoder  
    const configTypeExecutorStruct = 'tuple(uint32 maxMessageSize, address executorAddress)';  
    const encodedExecutorConfig = ethers.utils.defaultAbiCoder.encode(  
      [configTypeExecutorStruct],  
      [executorConfig],  
    );  
      
    // Define the SetConfigParam structs  
    const setConfigParamUln = {  
      eid: remoteEid,  
      configType: 2, // ULN_CONFIG_TYPE  
      config: encodedUlnConfig,  
    };  
      
    const setConfigParamExecutor = {  
      eid: remoteEid,  
      configType: 1, // EXECUTOR_CONFIG_TYPE  
      config: encodedExecutorConfig,  
    };  
      
    // Send the transaction  
    async function sendTransaction() {  
      try {  
        const tx = await endpointContract.setConfig(  
          oappAddress,  
          sendLibAddress,  
          [setConfigParamUln, setConfigParamExecutor], // Array of SetConfigParam structs  
        );  
      
        console.log('Transaction sent:', tx.hash);  
        const receipt = await tx.wait();  
        console.log('Transaction confirmed:', receipt.transactionHash);  
      } catch (error) {  
        console.error('Transaction failed:', error);  
      }  
    }  
      
    sendTransaction();  
    
    
    
    // SPDX-License-Identifier: UNLICENSED  
    pragma solidity ^0.8.22;  
      
    // Forge imports  
    import "forge-std/console.sol";  
    import "forge-std/Script.sol";  
      
    // LayerZero imports  
    import { ExecutorConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";  
    import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";  
    import { OFT } from "@layerzerolabs/oft-evm/contracts/OFT.sol";  
    import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";  
    import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";  
      
    contract SendConfig is Script {  
        uint32 public constant EXECUTOR_CONFIG_TYPE = 1;  
        uint32 public constant ULN_CONFIG_TYPE = 2;  
      
        function run(address contractAddress, uint32 remoteEid, address sendLibraryAddress, address signer, UlnConfig calldata ulnConfig, ExecutorConfig calldata executorConfig) external {  
            OFT myOFT = OFT(contractAddress);  
      
            ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(address(myOFT.endpoint()));  
      
            SetConfigParam[] memory setConfigParams = new SetConfigParam[](2);  
      
            setConfigParams[0] = SetConfigParam({  
                eid: remoteEid,  
                configType: EXECUTOR_CONFIG_TYPE,  
                config: abi.encode(executorConfig)  
            });  
      
            setConfigParams[1] = SetConfigParam({  
                eid: remoteEid,  
                configType: ULN_CONFIG_TYPE,  
                config: abi.encode(ulnConfig)  
            });  
      
            vm.startBroadcast(signer);  
      
            endpoint.setConfig(address(myOFT), sendLibraryAddress, setConfigParams);  
      
            vm.stopBroadcast();  
        }  
    }  
    

### Setting Receive Config​

You will still call the `setConfig` function described above, but because
`ReceiveLib302.sol` only enforces the DVN and block confirmation
configurations, you do not need to set an Executor configuration.

    
    
    CONFIG_TYPE_ULN = 2; // Security Stack and block confirmation config  
    
    
    
    const configTypeUlnStruct =  
      'tuple(uint64 confirmations, uint8 requiredDVNCount, uint8 optionalDVNCount, uint8 optionalDVNThreshold, address[] requiredDVNs, address[] optionalDVNs)';  
    

#### Receive Config Type ULN (Security Stack)​

The `ReceiveConfig` describes how to enforce and filter messages when
receiving packets from the remote chain. See [DVN
Addresses](/v2/developers/evm/technical-reference/dvn-addresses) for the list
of available DVNs.

Parameter| Type| Description  
---|---|---  
confirmations| `uint64`| The minimum number of block confirmations the DVNs
must have waited for their verification to be considered valid.  
requiredDVNCount| `uint8`| The quantity of required DVNs that must verify
before receiving the OApp's message.  
optionalDVNCount| `uint8`| The quantity of optional DVNs that must verify
before receiving the OApp's message.  
optionalDVNThreshold| `uint8`| The minimum number of verifications needed from
optional DVNs. A message is deemed Verifiable if it receives verifications
from at least the number of optional DVNs specified by the
`optionalDVNsThreshold`, plus the required DVNs.  
requiredDVNs| `address[]`| An array of addresses for all required DVNs to
receive verifications from.  
optionalDVNs| `address[]`| An array of addresses for all optional DVNs to
receive verifications from.  
  
caution

If you set your block confirmations too low, and a reorg occurs after your
confirmation, it can materially impact your OApp or OFT.

  

Use the ULN config type and the struct definition to form your configuration
for the call:

  * ethers
  * Foundry

The example below uses ethers.js (`^5.7.2`) library to encode the arrays and
call the Endpoint contract:

    
    
    const {ethers} = require('ethers');  
      
    // Addresses  
    const oappAddress = 'YOUR_OAPP_ADDRESS'; // Replace with your OApp address  
    const receiveLibAddress = 'YOUR_RECEIVE_LIB_ADDRESS'; // Replace with your receive message library address  
      
    // Configuration  
    const remoteEid = 30101; // Example EID, replace with the actual value  
    const ulnConfig = {  
      confirmations: 99, // Example value, replace with actual  
      requiredDVNCount: 2, // Example value, replace with actual  
      optionalDVNCount: 0, // Example value, replace with actual  
      optionalDVNThreshold: 0, // Example value, replace with actual  
      requiredDVNs: ['0xDvnAddress1', '0xDvnAddress2'], // Replace with actual addresses  
      optionalDVNs: [], // Replace with actual addresses  
    };  
      
    // Provider and Signer  
    const provider = new ethers.providers.JsonRpcProvider(YOUR_RPC_URL);  
    const signer = new ethers.Wallet(YOUR_PRIVATE_KEY, provider);  
      
    // ABI and Contract  
    const endpointAbi = [  
      'function setConfig(address oappAddress, address receiveLibAddress, tuple(uint32 eid, uint32 configType, bytes config)[] setConfigParams) external',  
    ];  
    const endpointContract = new ethers.Contract(YOUR_ENDPOINT_CONTRACT_ADDRESS, endpointAbi, signer);  
      
    // Encode UlnConfig using defaultAbiCoder  
    const configTypeUlnStruct =  
      'tuple(uint64 confirmations, uint8 requiredDVNCount, uint8 optionalDVNCount, uint8 optionalDVNThreshold, address[] requiredDVNs, address[] optionalDVNs)';  
    const encodedUlnConfig = ethers.utils.defaultAbiCoder.encode([configTypeUlnStruct], [ulnConfig]);  
      
    // Define the SetConfigParam struct  
    const setConfigParam = {  
      eid: remoteEid,  
      configType: 2, // RECEIVE_CONFIG_TYPE  
      config: encodedUlnConfig,  
    };  
      
    // Send the transaction  
    async function sendTransaction() {  
      try {  
        const tx = await endpointContract.setConfig(  
          oappAddress,  
          receiveLibAddress,  
          [setConfigParam], // This should be an array of SetConfigParam structs  
        );  
      
        console.log('Transaction sent:', tx.hash);  
        const receipt = await tx.wait();  
        console.log('Transaction confirmed:', receipt.transactionHash);  
      } catch (error) {  
        console.error('Transaction failed:', error);  
      }  
    }  
      
    sendTransaction();  
    
    
    
    // SPDX-License-Identifier: UNLICENSED  
    pragma solidity ^0.8.22;  
      
    // Forge imports  
    import "forge-std/console.sol";  
    import "forge-std/Script.sol";  
      
    // LayerZero imports  
    import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";  
    import { OFT } from "@layerzerolabs/oft-evm/contracts/OFT.sol";  
    import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";  
    import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";  
      
    contract ReceiveConfig is Script {  
        uint32 public constant RECEIVE_CONFIG_TYPE = 2;  
      
        function run(address contractAddress, uint32 remoteEid, address receiveLibraryAddress, address signer, UlnConfig calldata ulnConfig) external {  
            OFT myOFT = OFT(contractAddress);  
      
            ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(address(myOFT.endpoint()));  
      
            SetConfigParam[] memory setConfigParams = new SetConfigParam[](1);  
            setConfigParams[0] = SetConfigParam({  
                eid: remoteEid,  
                configType: RECEIVE_CONFIG_TYPE,  
                config: abi.encode(ulnConfig)  
            });  
      
            vm.startBroadcast(signer);  
      
            endpoint.setConfig(address(myOFT), receiveLibraryAddress, setConfigParams);  
      
            vm.stopBroadcast();  
        }  
    }  
    

## Resetting Configurations​

To erase your configuration and fallback to the default configurations, simply
pass null values as your configuration params and call `setConfig` again:

    
    
    // ULN Configuration Reset Params  
    const confirmations = 0;  
    const optionalDVNCount = 0;  
    const requiredDVNCount = 0;  
    const optionalDVNThreshold = 0;  
    const requiredDVNs = [];  
    const optionalDVNs = [];  
      
    const ulnConfigData = {  
      confirmations,  
      requiredDVNCount,  
      optionalDVNCount,  
      optionalDVNThreshold,  
      requiredDVNs,  
      optionalDVNs,  
    };  
      
    const ulnConfigEncoded = ethersV5.utils.defaultAbiCoder.encode(  
      [configTypeUlnStruct],  
      [ulnConfigData],  
    );  
      
    const resetConfigParamUln = {  
      eid: DEST_CHAIN_ENDPOINT_ID, // Replace with the target chain's endpoint ID  
      configType: configTypeUln,  
      config: ulnConfigEncoded,  
    };  
      
    // Executor Configuration Reset Params  
    const maxMessageSize = 0; // Representing no limit on message size  
    const executorAddress = '0x0000000000000000000000000000000000000000'; // Representing no specific executor address  
      
    const configTypeExecutorStruct = 'tuple(uint32 maxMessageSize, address executorAddress)';  
    const executorConfigData = {  
      maxMessageSize,  
      executorAddress,  
    };  
      
    const executorConfigEncoded = ethers.utils.defaultAbiCoder.encode(  
      [executorConfigStructType],  
      [executorConfigData],  
    );  
      
    const resetConfigParamExecutor = {  
      eid: DEST_CHAIN_ENDPOINT_ID, // Replace with the target chain's endpoint ID  
      configType: configTypeExecutor,  
      config: executorConfigEncoded,  
    };  
    

After defining the null values in your config params, call `setConfig`:

    
    
    const messageLibAddresses = ['sendLibAddress', 'receiveLibAddress'];  
      
    let resetTx;  
      
    // Call setConfig on the send and receive lib  
    for (const messagelibAddress of messageLibAddresses) {  
      resetTx = await endpointContract.setConfig(oappAddress, messagelibAddress, [  
        resetConfigParamUln,  
        resetConfigParamExecutor,  
      ]);  
      
      await resetTx.wait();  
    }  
    

## Debugging Configurations​

A **correct** OApp configuration example:

SendUlnConfig (A to B)| ReceiveUlnConfig (B to A)  
---|---  
confirmations: 15| confirmations: 15  
optionalDVNCount: 0| optionalDVNCount: 0  
optionalDVNThreshold: 0| optionalDVNThreshold: 0  
optionalDVNs: Array(0)| optionalDVNs: Array(0)  
requiredDVNCount: 2| requiredDVNCount: 2  
requiredDVNs: Array(DVN1_Address_A, DVN2_Address_A)| requiredDVNs:
Array(DVN1_Address_B, DVN2_Address_B)  
  
tip

The sending OApp's **SendLibConfig** (OApp on Chain A) and the receiving
OApp's **ReceiveLibConfig** (OApp on Chain B) match!

#### Block Confirmation Mismatch​

An example of an **incorrect** OApp configuration:

SendUlnConfig (A to B)| ReceiveUlnConfig (B to A)  
---|---  
**confirmations: 5**| **confirmations: 15**  
optionalDVNCount: 0| optionalDVNCount: 0  
optionalDVNThreshold: 0| optionalDVNThreshold: 0  
optionalDVNs: Array(0)| optionalDVNs: Array(0)  
requiredDVNCount: 2| requiredDVNCount: 2  
requiredDVNs: Array(DVN1, DVN2)| requiredDVNs: Array(DVN1, DVN2)  
  
danger

The above configuration has a **block confirmation mismatch**. The sending
OApp (Chain A) will only wait 5 block confirmations, but the receiving OApp
(Chain B) will not accept any message with less than 15 block confirmations.

Messages will be blocked until either the sending OApp has increased the
outbound block confirmations, or the receiving OApp decreases the inbound
block confirmation threshold.

#### DVN Mismatch​

Another example of an incorrect OApp configuration:

SendUlnConfig (A to B)| ReceiveUlnConfig (B to A)  
---|---  
confirmations: 15| confirmations: 15  
optionalDVNCount: 0| optionalDVNCount: 0  
optionalDVNThreshold: 0| optionalDVNThreshold: 0  
optionalDVNs: Array(0)| optionalDVNs: Array(0)  
**requiredDVNCount: 1**| **requiredDVNCount: 2**  
**requiredDVNs: Array(DVN1)**| **requiredDVNs: Array(DVN1, DVN2)**  
  
danger

The above configuration has a **DVN mismatch**. The sending OApp (Chain A)
only pays DVN 1 to listen and verify the packet, but the receiving OApp (Chain
B) requires both DVN 1 and DVN 2 to mark the packet as verified.

Messages will be blocked until either the sending OApp has added DVN 2's
address on Chain A to the SendUlnConfig, or the receiving OApp removes DVN 2's
address on Chain B from the ReceiveUlnConfig.

#### Dead DVN​

This configuration includes a **Dead DVN** :

SendUlnConfig (A to B)| ReceiveUlnConfig (B to A)  
---|---  
confirmations: 15| confirmations: 15  
optionalDVNCount: 0| optionalDVNCount: 0  
optionalDVNThreshold: 0| optionalDVNThreshold: 0  
optionalDVNs: Array(0)| optionalDVNs: Array(0)  
**requiredDVNCount: 2**| **requiredDVNCount: 2**  
**requiredDVNs: Array(DVN1, DVN2)**| **requiredDVNs: Array(DVN1, DVN_DEAD)**  
  
danger

The above configuration has a **Dead DVN**. Similar to a DVN Mismatch, the
sending OApp (Chain A) pays DVN 1 and DVN 2 to listen and verify the packet,
but the receiving OApp (Chain B) has currently set DVN 1 and a Dead DVN to
mark the packet as verified.

Since a Dead DVN for all practical purposes should be considered a null
address, no verification will ever match the dead address.

Messages will be blocked until the receiving OApp removes or replaces the Dead
DVN from the ReceiveUlnConfig.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/protocol-gas-settings/default-
config.md)

[PreviousOFT Patterns & Extensions](/v2/developers/evm/oft/oft-patterns-
extensions)[NextExecution Gas Options](/v2/developers/evm/protocol-gas-
settings/options)

  * Checking Default Configuration
  * Custom Configuration
    * Setting Send and Receive Libraries
    * Setting Send Config
      * Send Config Type ULN (Security Stack)
      * Send Config Type Executor
    * Setting Receive Config
      * Receive Config Type ULN (Security Stack)
  * Resetting Configurations
  * Debugging Configurations
    * Block Confirmation Mismatch
    * DVN Mismatch
    * Dead DVN



  * Protocol
  * Message Packet

Version: Endpoint V2 Docs

On this page

# Message Packet

Because cross-chain messaging allows for a variety of operations, such as
transferring data and assets or performing external calls, the LayerZero
protocol requires a generic data type for passing raw data from one chain to
another.

The **Message Packet** standardizes the format and size of messages that are
sent between different blockchains:

    
    
    struct Packet {  
        uint64 nonce; // the nonce of the message in the pathway  
        uint32 srcEid; // the source endpoint ID  
        address sender; // the sender address  
        uint32 dstEid; // the destination endpoint ID  
        bytes32 receiver; // the receiving address  
        bytes32 guid; // a global unique identifier  
        bytes message; // the message payload  
    }  
    

This standardized packet structure is compatible with different blockchains
that utilize different underlying execution environments (e.g., `EVM` vs `non-
EVM`).

## Packet Structure​

  * **Ordering and Routing Checks** : The packet includes several fields that help ensure the security of cross-chain communication:

    * **nonce** : Prevents replay attacks and censorship by defining a strong gapless ordering between all nonces in each channel.

    * **guid** : Acts as a globally unique identifier to track the message across chains and systems.

    * **srcEid** and **dstEid** : Identifiers for the source and destination chains that prevent message misrouting.

  * **Traceability** : The inclusion of a nonce, source and destination information, and a unique identifier (guid) makes it possible to track the message through its journey across chains. This is important for debugging, auditing, and for building trust in the system.

  * **Payload Integrity** : The message field carries the actual information or command that needs to be communicated to the destination chain. The configured [Security Stack](/v2/home/modular-security/security-stack-dvns) ensures that the message has not been altered during transit by ensuring multiple DVNs comparing multiple payload hashes against one another.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/protocol/packet.md)

[PreviousMessage Library](/v2/home/protocol/message-library)[NextSecurity
Stack (DVNs)](/v2/home/modular-security/security-stack-dvns)

  * Packet Structure



  * Modular Security
  * Security Stack (DVNs)

Version: Endpoint V2 Docs

On this page

# Security Stack (DVNs)

Every OApp can [Configure a Security Stack](/v2/developers/evm/protocol-gas-
settings/default-config#custom-configuration) comprised of a number of
**required** and **optional** Decentralized Verifier Networks (DVNs) to check
the `payloadHash` emitted for message integrity, specifying an **optional
threshold** for when a message nonce can be committed as Verified.

![DVN Light](/assets/images/dvn-light-7122e5676683412a46450c1a7f461cfe.svg#gh-
light-mode-only) ![DVN Dark](/assets/images/dvn-
dark-a57e53bda0186cb56cbe3eb070d2a1bb.svg#gh-dark-mode-only)

Each individual DVN checks messages using its own verification schema to
determine the integrity of the `payloadHash` before verifying it in the
destination chain's [MessageLib](/v2/home/protocol/message-library).

When both the required DVNs and a threshold of optional DVNs agree on the
`payloadHash`, the message nonce can then be committed to the destination
[Endpoint's](/v2/home/protocol/layerzero-endpoint) messaging channel for
execution by any caller (e.g., [Executor](/v2/home/permissionless-
execution/executors)).

Message Nonce| Description  
---|---  
1| The OApp's Security Stack has verified the `payloadHash`, and the nonce has
been committed to the Endpoint's messaging channel.  
2| All DVNs in the Security Stack have verified the `payloadHash`, but no
caller (e.g., Executor) has committed the nonce to the Endpoint's messaging
channel.  
3| Two required and one optional DVN have verified the `payloadHash`, meeting
the security threshold, but no caller (e.g., Executor) has committed the nonce
to the Endpoint's messaging channel.  
4| Even though the optional DVN security threshold has been met, the Security
Stack enforces all **required DVNs** (i.e., `DVN1`) to verify the
`payloadHash` before the nonce can be committed to the Endpoint's messaging
channel.  
5| Only the required DVNs (i.e., `DVN(A)`, `DVN(B)`) have verified the
`payloadHash`, but neither optional DVN have verified.  
6| Both the required DVNs and the optional threshold have verified the
`payloadHash`, but no caller (e.g., Executor) has committed the nonce to the
Endpoint's messaging channel.  
  
## Verification Model​

Each DVN offers a unique verification model for how to confirm the
`payloadHash` of a message, meaning OApp owners can determine which security
and cost-efficiency models best fit an application's needs.

See [DVN Addresses](/v2/developers/evm/technical-reference/dvn-addresses) for
an extensive list of all DVNs you could include in your OApp's Security Stack.

### DVN Adapters​

[DVN Adapters](/v2/developers/evm/technical-reference/dvn-addresses#axelar-
dvn-adapter) enable applications to integrate the security of third-party
networks such as native asset bridges, middle-chains, and other verification
methods into the OApp's Security Stack, exponentially increasing the number of
security configurations possible for an OApp to choose.

![DVN Hook Light](/assets/images/dvnhook-
light-4a57a08251e2f25f6dd6e062eb0b44ae.svg#gh-light-mode-only) ![DVN Hook
Dark](/assets/images/dvnhook-dark-ad5ba37409bfac0efc3c357178f8e83a.svg#gh-
dark-mode-only)

Since DVNs refer broadly to any verification model, OApp owners can integrate
with any infrastructure that can securely deliver a message's `payloadHash` to
the destination MessageLib.

## Configuring Security Stack​

When developers deploy omnichain applications (OApps) using the provided
[Contract Standards](/v2/home/protocol/contract-standards), these contracts
come pre-packaged with the necessary interfaces for managing the Security
Stack, as well as the ability to opt-in to a configured default. This means
there's no immediate need for complex setups or configurations post-
deployment, nor are you forced at any point to accept defaults.

The OApp owner can freely configure and reconfigure the Security Stack,
tailoring the protocol to required security and efficiency needs.

info

See [**Configure Security Stack**](/v2/developers/evm/protocol-gas-
settings/default-config#custom-configuration) to change your application's
configuration.

  

You can find all available DVNs for applications to use under [Supported
DVNs](/v2/developers/evm/technical-reference/dvn-addresses).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/modular-security/security-stack-dvns.md)

[PreviousMessage
Packet](/v2/home/protocol/packet)[NextExecutors](/v2/home/permissionless-
execution/executors)

  * Verification Model
    * DVN Adapters
  * Configuring Security Stack



  * LayerZero V2
  * V2 Overview

Version: Endpoint V2 Docs

On this page

# What is LayerZero V2?

**LayerZero is a messaging protocol, not a blockchain.** Using smart contracts
deployed on each chain, in combination with [Decentralized Verifier Networks
(DVNs)](/v2/home/modular-security/security-stack-dvns) and
[Executors](/v2/home/permissionless-execution/executors), LayerZero enables
different blockchains to seamlessly interact with one another.

![Protocol V2
Light](/assets/images/protocolv2light-3d1cf3951869746d3cd8d47a9e63c0bc.svg#gh-
light-mode-only) ![Protocol V2
Dark](/assets/images/protocolv2dark-353378180e0e4413f61da05909437507.svg#gh-
dark-mode-only)

In LayerZero V2, message verification and execution have been separated into
two distinct phases, providing developers with more control over their
application's security configuration and independent execution.

Combined with improved handling, message throughput, programmability, and
other contract specific improvements, LayerZero V2 provides a more flexible,
performant, and future-proof messaging protocol.

Start reading more about this design in the [Protocol
Overview](/v2/home/protocol/protocol-overview).

## New Security & Execution​

[LayerZero V2](https://layerzero.network/) offers direct improvements for both
existing, deployed applications on Endpoint V1, as well as new features that
enhance the creation and scalability of omnichain applications deployed on the
new Endpoint V2.

Applications deployed on Endpoint V1 can receive two main overhauls to
application security and execution by migrating their application's Message
Library to **Ultra Light Node 301**. See the [Migration
Guide](/v2/home/v2-migration) to learn more.

### X of Y of N Message Authentication​

The new **Ultra Light Node 301 (V1)** and **Ultra Light Node 302 (V2)** allow
application owners to configure a custom [Security Stack](/v2/home/modular-
security/security-stack-dvns), choosing a set of different Decentralized
Verifier Networks (DVNs) to verify the payload hash on the destination
MessageLib. A subset of these DVNs are **all** required (`X`) to verify the
payload hash, and a threshold (`Y`) of a set of optional DVNs (`N`) must also
verify the same payload hash before the packet can be delivered.

OApp owners can now utilize multiple verification models to achieve a desired
security and cost-efficiency outcome based on their application's needs.

You can select between the following DVNs at launch, or permissionlessly
[Build DVNs](/v2/developers/evm/off-chain/build-dvns)

Security Stack (DVNs) can be found [here](/v2/home/modular-security/security-
stack-dvns).

### Independent Message Execution​

In LayerZero V1, the Relayer handled both the verification and execution of
messages:

  * **Oracle** : Handled the verification of message block headers.

  * **Relayer** : Handled the verification of tx-proofs and the execution of messages.

In LayerZero V2, the verification of messages is now handled by the [Security
Stack](/v2/developers/evm/protocol-gas-settings/default-config#send-config-
type-uln-security-stack), and execution by
[Executors](/v2/home/permissionless-execution/executors):

  * **Security Stack** : your application's selected (`X of Y of N`) DVNs.

  * **Executor (Optional)** : your application's selected automated caller for receiving messages.

**For new applications deployed on Endpoint V2, this caller is completely
permissionless.**

## New Protocol Contracts​

In addition to [New Message Libraries](/v2/home/protocol/message-
library#available-libraries), LayerZero V2 includes improvements to the core
protocol architecture.

Developers can take advantage of higher message throughput on certain
blockchains, improved programmability, smaller contract sizes, and more by
deploying applications using the [Endpoint V2 Contract
Standards](/v2/home/protocol/contract-standards).

### Improved Message Handling​

Because the V2 protocol splits the verification and execution of messages,
message nonces can now be executed out of order while still maintaining
censorship resistance:

  * **`Verified`** : the nonce of the [Message Packet](/v2/home/protocol/packet) has successfully been verified, and awaits execution.

  * **`Delivered`** : the message has successfully been executed and received by the destination application.

In V1, by default, if a sent message failed to execute on destination, the
relevant pathway would be blocked by a `storedPayload` event that would
temporarily stop all subsequent messages from being executed.

Now by default, the subsequent flow of messages will continue to be delivered
and executed even if a previous message failed to execute.

Ordered execution can still be enabled at the application level by configuring
[Ordered Message Delivery](/v2/developers/evm/oapp/message-design-
patterns#ordered-delivery).

### Higher Message Throughput​

This [Unordered Message Delivery](/v2/developers/evm/oapp/message-design-
patterns#message-ordering) offers the highest possible message throughput
(i.e., the chain itself), by using improved on-chain nonce tracking via a
**Lazy Inbound Nonce** and **Inbound Nonce** as pointers for where to try
message execution.

  * **Lazy Inbound Nonce** : the highest executed message nonce in the system.

  * **Inbound Nonce** : the latest verified message nonce, where all preceding nonces have also been verified.

Since nonces must be verified before they can be executed, this system enables
LayerZero V2 to verify and losslessly execute packets out-of-order,
streamlining message execution without compromising censorship resistance.

### Improved Programmability​

LayerZero V2 has also significantly improved programmability in several ways:

  * **Simplified Protocol Contract Interfaces** : The improved contract interfaces in LayerZero V2 simplify message routing and handling, reducing the complexity involved in sending and receiving messages via the protocol. Developers can work more confidently and efficiently.

  * **Path-Specific Libraries** : Path-specific libraries in Endpoint V2 enable developers to configure different MessageLibs for specific pathways (source to destination), providing applications with more [flexibility and customization](/v2/developers/evm/protocol-gas-settings/default-config).

  * **Horizontal Composability** : The new `sendCompose` and `lzCompose` interfaces, where external calls can be containerized into new message packets, allows applications to maintain a clear separation between the logic that handles the receipt of a message (`lzReceive`) and the logic of the external call itself (`lzCompose`). This ensures that each step is executed correctly and independently of others, enabling powerful [cross-chain interactions](/v2/developers/evm/oapp/message-design-patterns).

### Smaller Contract Sizes​

LayerZero V2 introduces several improvements to enhance gas efficiency for
developers and users interacting with LayerZero contracts. Let's break down
these improvements:

  * **Optimized Base Contracts** : All [LayerZero Contract Standards](/v2/developers/evm/overview) have been restructured to reduce the inherited gas cost from base contracts.

  * **Compiler Efficiency** : Improvements in the contracts lead to better compiler optimization, which in turn reduces the deployment and execution gas costs.

### Chain Compatibility​

V2 also significantly improves chain compatibility, further empowering
developers to build versatile and efficient omnichain applications across a
wider range of blockchains.

  * **Chain-Agnostic Design** : The protocol defines isolation between composed contract calls (`composeSend` to store data followed by `lzCompose` to compose the contract). This enables developers to build more uniform application designs across blockchains with different environment assumptions (e.g., lack of runtime dispatch). This is important for achieving broad compatibility with non-EVM chains and unifying the OApp interface across every chain.

  * **Improved Gas Payment Options** : The Endpoint can now specify an alternative gas token on a given chain during deployment. This flexibility accommodates blockchains that may have unique gas mechanisms or fee models.

  * **Specific Library Defaults** : Endpoints now support a different default library per chain pathway. This feature allows for more streamlined and efficient message processing that is tailored to the specific characteristics and unique requirements of each chain pair.

These improvements offer a more chain-agnostic approach to message handling,
helping OApp developers design a single application architecture that can be
unified across EVM and non-EVM chains.

## Consistent Security Standards​

  * **Application Level Control** : While application contracts can opt into pre-defined curated defaults, LayerZero gives you the choice to [configure your application's settings](/v2/developers/evm/protocol-gas-settings/default-config) for every pathway, offering unparalleled flexibility and security.

  * **Immutable Core Contracts** : LayerZero only uses immutable core contracts. This provides developers with a long-term stable and predictable interface to interact with, ensuring that security and reliability are never compromised by external updates.

  * **Backwards Compatibility** : LayerZero's on-chain message libraries are immutable and can never be removed or deprecated. LayerZero will always be backwards-compatible with previous MessageLib versions.

## Get Started​

LayerZero offers a fully integrated suite of [Contract
Standards](/v2/developers/evm/overview) to help you quickly build, launch, and
scale your omnichain applications.

Start learning about LayerZero's architecture by either reading the [Protocol
Overview](/v2/home/protocol/protocol-overview) or the [V2
Whitepaper](https://layerzero.network/publications/LayerZero_Whitepaper_V2.0.pdf).

Have questions? You can also ask for help or follow development in our
[Discord](https://discord-layerzero.netlify.app/discord).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/v2-overview.md)

[PreviousWelcome](/v2)[NextV2 Migration](/v2/home/v2-migration)

  * New Security & Execution
    * X of Y of N Message Authentication
    * Independent Message Execution
  * New Protocol Contracts
    * Improved Message Handling
    * Higher Message Throughput
    * Improved Programmability
    * Smaller Contract Sizes
    * Chain Compatibility
  * Consistent Security Standards
  * Get Started



  * Protocol & Gas Settings
  * Estimating Source Gas Fees

Version: Endpoint V2 Docs

On this page

# Estimating Gas Fees

Both [`OApp`](/v2/developers/evm/oapp/overview) and
[`OFT`](/v2/developers/evm/oft/quickstart) come packaged with methods you can
implement or call directly in order to receive a quote for how much native gas
your message will cost to send to the destination chain.

info

Both the `OApp` and `OFT` implementations for estimating fees require some
knowledge of how `_options` work. We recommend reviewing the
[**OApp**](/v2/developers/evm/oapp/overview) or [**OFT
Quickstart**](/v2/developers/evm/oft/quickstart) and [**Message
Options**](/v2/developers/evm/protocol-gas-settings/options) guides first to
better understand `_options` usage.

[](/v2/developers/evm/oapp/message-design-patterns#unordered-delivery)

## OApp​

To estimate how much gas a message will cost to be sent and received, you will
need to implement a `quote` function to return an estimate from the Endpoint
contract to use as a recommended `msg.value`.

    
    
    function quote(  
        uint32 _dstEid, // destination endpoint id  
        bytes memory payload, // message payload being sent  
        bytes memory _options, // your message execution options  
        bool memory _payInLzToken // boolean for which token to return fee in  
    ) public view returns (uint256 nativeFee, uint256 zroFee) {  
        return _quote(_dstEid, payload, _options, _payInLzToken);  
    }  
    

The `_quote` can be returned in either the native gas token or in `LzToken`,
supporting both payment methods.

In general, this quote will be accurate as the same function is used by the
Endpoint when pricing an `_lzSend` call:

    
    
    // How the _quote function works.  
    // This function is already defined in your OApp contract.  
    /// @dev the generic quote interface to interact with the LayerZero EndpointV2.quote()  
    function _quote(  
        uint32 _dstEid,  
        bytes memory _message,  
        bytes memory _options,  
        bool _payInLzToken  
    ) internal view virtual returns (MessagingFee memory fee) {  
        return  
            endpoint.quote(  
                MessagingParams(_dstEid, _getPeerOrRevert(_dstEid), _message, _options, _payInLzToken),  
                address(this)  
            );  
    }  
    

tip

Make sure that the arguments passed into the `_quote` function identically
match the parameters used in the `lzSend` function. If parameters mismatch,
you may run into errors as your `msg.value` will not match the actual gas
quote.

  

note

Remember that to send a message, a `msg.sender` will be paying the source
chain, the selected DVNs to deliver the message, and the destination chain to
execute the transaction.

## OFT​

To estimate how much gas an OFT transfer will cost, call the `quoteSend`
function to return an estimate from the Endpoint contract.

    
    
    // @dev Requests a nativeFee/lzTokenFee quote for sending the corresponding msg cross-chain through the layerZero Endpoint  
    function quoteSend(  
        SendParam calldata _sendParam, // send parameters struct  
        bytes calldata _extraOptions, // extra message options  
        bool _payInLzToken, // bool for payment in native gas or LzToken  
        bytes calldata _composeMsg, // data for composed message  
        bytes calldata _oftCmd // data for custom OFT behaviours  
    )  
        public  
        view  
        virtual  
        returns (  
            MessagingFee memory msgFee, // fee struct for native or LzToken  
            OFTLimit memory oftLimit,  
            OFTReceipt memory oftReceipt,  
            OFTFeeDetail[] memory oftFeeDetails // @dev unused in the default implementation, future proofs complex fees inside of an oft send  
        )  
    {  
        (oftLimit, oftReceipt) = quoteOFT(_sendParam);  
      
        (bytes memory message, bytes memory options) = _buildMsgAndOptions(  
            _sendParam,  
            _extraOptions,  
            _composeMsg,  
            oftReceipt.amountCreditLD  
        );  
      
        msgFee = _quote(_sendParam.dstEid, message, options, _payInLzToken);  
    }  
    

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/protocol-gas-settings/gas-fees.md)

[PreviousExecution Gas Options](/v2/developers/evm/protocol-gas-
settings/options)[NextDeploy Deterministic
Addresses](/v2/developers/evm/tooling/uniform-address)

  * OApp
  * OFT



Version: Endpoint V2 Docs

# Deployed Endpoints, Message Libraries, and Executors

The [LayerZero Endpoint](/v2/home/protocol/layerzero-endpoint),
[MessageLib](/v2/home/protocol/message-library), and
[Executor](/v2/home/permissionless-execution/executors) for every supported
blockchain.

Total Mainnet Networks: 88

Download JSON

Network Type:

All

![](/img/icons/chevron.svg)

Chains:

All

![](/img/icons/chevron.svg)

Show Recently Added:  

Reset

Chain| EID| Endpoint Address| Libraries & Executor  
---|---|---|---  
![](https://icons-ckg.pages.dev/lz-scan/networks/abstract-testnet.svg)Abstract
Testnet| 40313| [EndpointV2
(0x16c6...)](https://layerzeroscan.com/api/explorer/abstract-
testnet/address/0x16c693A3924B947298F7227792953Cd6BBb21Ac8)| [SendUln302
(0xF636...)](https://layerzeroscan.com/api/explorer/abstract-
testnet/address/0xF636882f80cb5039D80F08cDEee1b166D700091b)[ReceiveUln302
(0x2443...)](https://layerzeroscan.com/api/explorer/abstract-
testnet/address/0x2443297aEd720EACED2feD76d1C6044471382EA2)[SendUln301
(0xD5eE...)](https://layerzeroscan.com/api/explorer/abstract-
testnet/address/0xD5eE0055c37dDfaF7e2e0CA3dECb60f365848Bd5)[ReceiveUln301
(0x0Cc6...)](https://layerzeroscan.com/api/explorer/abstract-
testnet/address/0x0Cc6F5414996678Aa4763c3Bc66058B47813fa85)[LZ Executor
(0x5c12...)](https://layerzeroscan.com/api/explorer/abstract-
testnet/address/0x5c123dB6f87CC0d7e320C5CC9EaAfD336B5f6eF3)  
![](https://icons-ckg.pages.dev/lz-scan/networks/ape.svg)ApeRecently Added!|
30312| [EndpointV2
(0x6F47...)](https://layerzeroscan.com/api/explorer/ape/address/0x6F475642a6e85809B1c36Fa62763669b1b48DD5B)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/ape/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/ape/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/ape/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/ape/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/ape/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum.svg)Arbitrum
Mainnet| 30110| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/arbitrum/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x975b...)](https://layerzeroscan.com/api/explorer/arbitrum/address/0x975bcD720be66659e3EB3C0e4F1866a3020E493A)[ReceiveUln302
(0x7B9E...)](https://layerzeroscan.com/api/explorer/arbitrum/address/0x7B9E184e07a6EE1aC23eAe0fe8D6Be2f663f05e6)[SendUln301
(0x5cDc...)](https://layerzeroscan.com/api/explorer/arbitrum/address/0x5cDc927876031B4Ef910735225c425A7Fc8efed9)[ReceiveUln301
(0xe4DD...)](https://layerzeroscan.com/api/explorer/arbitrum/address/0xe4DD168822767C4342e54e6241f0b91DE0d3c241)[LZ
Executor
(0x31CA...)](https://layerzeroscan.com/api/explorer/arbitrum/address/0x31CAe3B7fB82d847621859fb1585353c5720660D)  
![](https://icons-ckg.pages.dev/lz-scan/networks/nova.svg)Arbitrum Nova
Mainnet| 30175| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/nova/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xef32...)](https://layerzeroscan.com/api/explorer/nova/address/0xef32f931ac53808e695B7eF3D1b6C5016024a68f)[ReceiveUln302
(0xB81F...)](https://layerzeroscan.com/api/explorer/nova/address/0xB81F326b95e79eaC4aba800Ae545efb4C602973D)[SendUln301
(0x2b3e...)](https://layerzeroscan.com/api/explorer/nova/address/0x2b3eBE6662Ad402317EE7Ef4e6B25c79a0f91015)[ReceiveUln301
(0x00e7...)](https://layerzeroscan.com/api/explorer/nova/address/0x00e7306e591c04E72867644dF141e250aCAF175B)[LZ
Executor
(0x8Ee0...)](https://layerzeroscan.com/api/explorer/nova/address/0x8Ee02736F8a0c28164a20c25f3d199a74DF7F24B)  
![](https://icons-ckg.pages.dev/lz-scan/networks/arbitrum-sepolia.svg)Arbitrum
Sepolia Testnet| 40231| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/arbitrum-
sepolia/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4f7c...)](https://layerzeroscan.com/api/explorer/arbitrum-
sepolia/address/0x4f7cd4DA19ABB31b0eC98b9066B9e857B1bf9C0E)[ReceiveUln302
(0x75Db...)](https://layerzeroscan.com/api/explorer/arbitrum-
sepolia/address/0x75Db67CDab2824970131D5aa9CECfC9F69c69636)[SendUln301
(0x9270...)](https://layerzeroscan.com/api/explorer/arbitrum-
sepolia/address/0x92709d5BAc33547482e4BB7dd736f9a82b029c40)[ReceiveUln301
(0xa673...)](https://layerzeroscan.com/api/explorer/arbitrum-
sepolia/address/0xa673a180fB2BF0E315b4f832b7d5b9ACB7162273)[LZ Executor
(0x5Df3...)](https://layerzeroscan.com/api/explorer/arbitrum-
sepolia/address/0x5Df3a1cEbBD9c8BA7F8dF51Fd632A9aef8308897)  
![](https://icons-ckg.pages.dev/lz-scan/networks/astar.svg)Astar Mainnet|
30210| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/astar/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x30C3...)](https://layerzeroscan.com/api/explorer/astar/address/0x30C3074669d866933db74DF1Fbe4b3703e6ec139)[ReceiveUln302
(0xF08f...)](https://layerzeroscan.com/api/explorer/astar/address/0xF08f13c080fcc530B1C21DE827C27B7b66874DDc)[SendUln301
(0xbC78...)](https://layerzeroscan.com/api/explorer/astar/address/0xbC7848582De127E61f3521e5B8b3E119e5D1eA48)[ReceiveUln301
(0x8D18...)](https://layerzeroscan.com/api/explorer/astar/address/0x8D183A062e99cad6f3723E6d836F9EA13886B173)[LZ
Executor
(0x3C55...)](https://layerzeroscan.com/api/explorer/astar/address/0x3C5575898f59c097681d1Fc239c2c6Ad36B7b41c)  
![](https://icons-ckg.pages.dev/lz-scan/networks/astar-testnet.svg)Astar
Testnet| 40210| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/astar-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x3617...)](https://layerzeroscan.com/api/explorer/astar-
testnet/address/0x3617dA335F75164809B540bA31bdf79DE6cB1Ee3)[ReceiveUln302
(0xdBdC...)](https://layerzeroscan.com/api/explorer/astar-
testnet/address/0xdBdC042321A87DFf222C6BF26be68Ad7b3d7543f)[SendUln301
(0x5D15...)](https://layerzeroscan.com/api/explorer/astar-
testnet/address/0x5D1573FBC5a08533CFbDEa991887B96f2CE0C5d0)[ReceiveUln301
(0x1a2f...)](https://layerzeroscan.com/api/explorer/astar-
testnet/address/0x1a2fd0712Ded46794022DdB16a282e798D22a7FB)[LZ Executor
(0x9130...)](https://layerzeroscan.com/api/explorer/astar-
testnet/address/0x9130D98D47984BF9dc796829618C36CBdA43EBb9)  
![](https://icons-ckg.pages.dev/lz-scan/networks/zkatana.svg)Astar zkEVM
Mainnet| 30257| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/zkatana/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/zkatana/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[ReceiveUln302
(0xc1B6...)](https://layerzeroscan.com/api/explorer/zkatana/address/0xc1B621b18187F74c8F6D52a6F709Dd2780C09821)[SendUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/zkatana/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[ReceiveUln301
(0x7cac...)](https://layerzeroscan.com/api/explorer/zkatana/address/0x7cacBe439EaD55fa1c22790330b12835c6884a91)[LZ
Executor
(0x4208...)](https://layerzeroscan.com/api/explorer/zkatana/address/0x4208D6E27538189bB48E603D6123A94b8Abe0A0b)  
![](https://icons-ckg.pages.dev/lz-scan/networks/zkastar-testnet.svg)Astar
zkEVM Testnet| 40266| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/zkastar-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x00C5...)](https://layerzeroscan.com/api/explorer/zkastar-
testnet/address/0x00C5C0B8e0f75aB862CbAaeCfff499dB555FBDD2)[ReceiveUln302
(0x1d18...)](https://layerzeroscan.com/api/explorer/zkastar-
testnet/address/0x1d186C560281B8F1AF831957ED5047fD3AB902F9)[SendUln301
(0xF019...)](https://layerzeroscan.com/api/explorer/zkastar-
testnet/address/0xF0196DEa83b47244222B315AbbbcF6b9fD2F705c)[ReceiveUln301
(0xa78A...)](https://layerzeroscan.com/api/explorer/zkastar-
testnet/address/0xa78A78a13074eD93aD447a26Ec57121f29E8feC2)[LZ Executor
(0x9dB9...)](https://layerzeroscan.com/api/explorer/zkastar-
testnet/address/0x9dB9Ca3305B48F196D18082e91cB64663b13d014)  
![](https://icons-ckg.pages.dev/lz-scan/networks/aurora-testnet.svg)Aurora
Testnet| 40201| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/aurora-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x19D1...)](https://layerzeroscan.com/api/explorer/aurora-
testnet/address/0x19D1198b0f43Ec076a897bF98dEb0FD1D6CE8B9f)[ReceiveUln302
(0x0E91...)](https://layerzeroscan.com/api/explorer/aurora-
testnet/address/0x0E91e0239971B6CF7519e458a742e2eA4Ffb7458)[SendUln301
(0x790d...)](https://layerzeroscan.com/api/explorer/aurora-
testnet/address/0x790deF6091dD5e5e8c3F8550B37a04790e0ba492)[ReceiveUln301
(0x55a7...)](https://layerzeroscan.com/api/explorer/aurora-
testnet/address/0x55a75EB9A470329f1bA6278bDe58CE95E6CEF501)[LZ Executor
(0x9dD6...)](https://layerzeroscan.com/api/explorer/aurora-
testnet/address/0x9dD6727B9636761ff50E375D0A7039BD5447ceDB)  
![](https://icons-ckg.pages.dev/lz-scan/networks/fuji.svg)Avalanche Fuji
Testnet| 40106| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/fuji/address/0x6EDCE65403992e310A62460808c4b910D972f10f)|
[SendUln302
(0x69BF...)](https://layerzeroscan.com/api/explorer/fuji/address/0x69BF5f48d2072DfeBc670A1D19dff91D0F4E8170)[ReceiveUln302
(0x819F...)](https://layerzeroscan.com/api/explorer/fuji/address/0x819F0FAF2cb1Fba15b9cB24c9A2BDaDb0f895daf)[SendUln301
(0x184e...)](https://layerzeroscan.com/api/explorer/fuji/address/0x184e24e31657Cf853602589fe5304b144a826c85)[ReceiveUln301
(0x91df...)](https://layerzeroscan.com/api/explorer/fuji/address/0x91df17bF1Ced54c6169e1E24722C0a88a447cBAf)[LZ
Executor
(0xa7BF...)](https://layerzeroscan.com/api/explorer/fuji/address/0xa7BFA9D51032F82D649A501B6a1f922FC2f7d4e3)  
![](https://icons-ckg.pages.dev/lz-scan/networks/avalanche.svg)Avalanche
Mainnet| 30106| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/avalanche/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x197D...)](https://layerzeroscan.com/api/explorer/avalanche/address/0x197D1333DEA5Fe0D6600E9b396c7f1B1cFCc558a)[ReceiveUln302
(0xbf35...)](https://layerzeroscan.com/api/explorer/avalanche/address/0xbf3521d309642FA9B1c91A08609505BA09752c61)[SendUln301
(0x31CA...)](https://layerzeroscan.com/api/explorer/avalanche/address/0x31CAe3B7fB82d847621859fb1585353c5720660D)[ReceiveUln301
(0xF85e...)](https://layerzeroscan.com/api/explorer/avalanche/address/0xF85eD5489E6aDd01Fec9e8D53cF8FAcFc70590BD)[LZ
Executor
(0x90E5...)](https://layerzeroscan.com/api/explorer/avalanche/address/0x90E595783E43eb89fF07f63d27B8430e6B44bD9c)  
![](https://icons-ckg.pages.dev/lz-scan/networks/bahamut-testnet.svg)Bahamut
Testnet| 40310| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/bahamut-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/bahamut-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/bahamut-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/bahamut-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/bahamut-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/bahamut-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/base.svg)Base Mainnet| 30184|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/base/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xB532...)](https://layerzeroscan.com/api/explorer/base/address/0xB5320B0B3a13cC860893E2Bd79FCd7e13484Dda2)[ReceiveUln302
(0xc70A...)](https://layerzeroscan.com/api/explorer/base/address/0xc70AB6f32772f59fBfc23889Caf4Ba3376C84bAf)[SendUln301
(0x9DB3...)](https://layerzeroscan.com/api/explorer/base/address/0x9DB3714048B5499Ec65F807787897D3b3Aa70072)[ReceiveUln301
(0x58D5...)](https://layerzeroscan.com/api/explorer/base/address/0x58D53a2d6a08B72a15137F3381d21b90638bd753)[LZ
Executor
(0x2CCA...)](https://layerzeroscan.com/api/explorer/base/address/0x2CCA08ae69E0C44b18a57Ab2A87644234dAebaE4)  
![](https://icons-ckg.pages.dev/lz-scan/networks/base-sepolia.svg)Base Sepolia
Testnet| 40245| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/base-
sepolia/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xC186...)](https://layerzeroscan.com/api/explorer/base-
sepolia/address/0xC1868e054425D378095A003EcbA3823a5D0135C9)[ReceiveUln302
(0x1252...)](https://layerzeroscan.com/api/explorer/base-
sepolia/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)[SendUln301
(0x53fd...)](https://layerzeroscan.com/api/explorer/base-
sepolia/address/0x53fd4C4fBBd53F6bC58CaE6704b92dB1f360A648)[ReceiveUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/base-
sepolia/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[LZ Executor
(0x8A3D...)](https://layerzeroscan.com/api/explorer/base-
sepolia/address/0x8A3D588D9f6AC041476b094f97FF94ec30169d3D)  
![](https://icons-ckg.pages.dev/lz-scan/networks/bartio.svg)Berachain Bartio
Testnet| 40291| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/bartio/address/0x6EDCE65403992e310A62460808c4b910D972f10f)|
[SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/bartio/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/bartio/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/bartio/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/bartio/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ
Executor
(0x55c1...)](https://layerzeroscan.com/api/explorer/bartio/address/0x55c175DD5b039331dB251424538169D8495C18d1)  
![](https://icons-ckg.pages.dev/lz-scan/networks/besu1-testnet.svg)Besu1
Testnet| 40288| [EndpointV2
(0x3aCA...)](https://layerzeroscan.com/api/explorer/besu1-testnet/address/0x3aCAAf60502791D199a5a5F0B173D78229eBFe32)|
[SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/besu1-testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/besu1-testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0xC186...)](https://layerzeroscan.com/api/explorer/besu1-testnet/address/0xC1868e054425D378095A003EcbA3823a5D0135C9)[ReceiveUln301
(0x1252...)](https://layerzeroscan.com/api/explorer/besu1-testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)[LZ
Executor
(0xa78A...)](https://layerzeroscan.com/api/explorer/besu1-testnet/address/0xa78A78a13074eD93aD447a26Ec57121f29E8feC2)  
![](https://icons-ckg.pages.dev/lz-scan/networks/bevm.svg)BevmRecently Added!|
30317| [EndpointV2
(0xcb56...)](https://layerzeroscan.com/api/explorer/bevm/address/0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa)|
[SendUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/bevm/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[ReceiveUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/bevm/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[SendUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/bevm/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[ReceiveUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/bevm/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[LZ
Executor
(0x4208...)](https://layerzeroscan.com/api/explorer/bevm/address/0x4208D6E27538189bB48E603D6123A94b8Abe0A0b)  
![](https://icons-ckg.pages.dev/lz-scan/networks/bevm-testnet.svg)Bevm
TestnetRecently Added!| 40324| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/bevm-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/bevm-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/bevm-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/bevm-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/bevm-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/bevm-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc.svg)Binance Smart Chain
Mainnet| 30102| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/bsc/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x9F8C...)](https://layerzeroscan.com/api/explorer/bsc/address/0x9F8C645f2D0b2159767Bd6E0839DE4BE49e823DE)[ReceiveUln302
(0xB217...)](https://layerzeroscan.com/api/explorer/bsc/address/0xB217266c3A98C8B2709Ee26836C98cf12f6cCEC1)[SendUln301
(0xfCCE...)](https://layerzeroscan.com/api/explorer/bsc/address/0xfCCE712C9be5A78FE5f842008e0ed7af59455278)[ReceiveUln301
(0xff3d...)](https://layerzeroscan.com/api/explorer/bsc/address/0xff3da3a1cd39Bbaeb8D7cB2deB83EfC065CBb38F)[LZ
Executor
(0x3ebD...)](https://layerzeroscan.com/api/explorer/bsc/address/0x3ebD570ed38B1b3b4BC886999fcF507e9D584859)  
![](https://icons-ckg.pages.dev/lz-scan/networks/bsc-testnet.svg)Binance Smart
Chain Testnet| 40102| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x55f1...)](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x55f16c442907e86D764AFdc2a07C2de3BdAc8BB7)[ReceiveUln302
(0x188d...)](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x188d4bbCeD671A7aA2b5055937F79510A32e9683)[SendUln301
(0x65e2...)](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x65e2DdD01cf0f1e27090052fF64f061d236206fd)[ReceiveUln301
(0xA4b1...)](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0xA4b12509e4267e3139249223c294bB16b6F1578b)[LZ Executor
(0x3189...)](https://layerzeroscan.com/api/explorer/bsc-
testnet/address/0x31894b190a8bAbd9A067Ce59fde0BfCFD2B18470)  
![](https://icons-ckg.pages.dev/lz-scan/networks/bitlayer.svg)BitlayerRecently
Added!| 30314| [EndpointV2
(0x6F47...)](https://layerzeroscan.com/api/explorer/bitlayer/address/0x6F475642a6e85809B1c36Fa62763669b1b48DD5B)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/bitlayer/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/bitlayer/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/bitlayer/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/bitlayer/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/bitlayer/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/bitlayer-testnet.svg)Bitlayer
Testnet| 40320| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/bitlayer-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/bitlayer-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/bitlayer-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/bitlayer-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/bitlayer-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/bitlayer-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/blast.svg)Blast Mainnet|
30243| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/blast/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xc1B6...)](https://layerzeroscan.com/api/explorer/blast/address/0xc1B621b18187F74c8F6D52a6F709Dd2780C09821)[ReceiveUln302
(0x3775...)](https://layerzeroscan.com/api/explorer/blast/address/0x377530cdA84DFb2673bF4d145DCF0C4D7fdcB5b6)[SendUln301
(0x7cac...)](https://layerzeroscan.com/api/explorer/blast/address/0x7cacBe439EaD55fa1c22790330b12835c6884a91)[ReceiveUln301
(0x282b...)](https://layerzeroscan.com/api/explorer/blast/address/0x282b3386571f7f794450d5789911a9804FA346b4)[LZ
Executor
(0x4208...)](https://layerzeroscan.com/api/explorer/blast/address/0x4208D6E27538189bB48E603D6123A94b8Abe0A0b)  
![](https://icons-ckg.pages.dev/lz-scan/networks/blast-testnet.svg)Blast
Testnet| 40243| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/blast-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x701f...)](https://layerzeroscan.com/api/explorer/blast-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)[ReceiveUln302
(0x9dB9...)](https://layerzeroscan.com/api/explorer/blast-
testnet/address/0x9dB9Ca3305B48F196D18082e91cB64663b13d014)[SendUln301
(0x8A3D...)](https://layerzeroscan.com/api/explorer/blast-
testnet/address/0x8A3D588D9f6AC041476b094f97FF94ec30169d3D)[ReceiveUln301
(0x8dF5...)](https://layerzeroscan.com/api/explorer/blast-
testnet/address/0x8dF53a660a00C3D977d7E778fB7385ECf4482D16)[LZ Executor
(0xE62d...)](https://layerzeroscan.com/api/explorer/blast-
testnet/address/0xE62d066e71fcA410eD48ad2f2A5A860443C04035)  
![](https://icons-ckg.pages.dev/lz-scan/networks/ble-testnet.svg)Ble
TestnetRecently Added!| 40330| [EndpointV2
(0x6Ac7...)](https://layerzeroscan.com/api/explorer/ble-
testnet/address/0x6Ac7bdc07A0583A362F1497252872AE6c0A5F5B8)| [SendUln302
(0x00C5...)](https://layerzeroscan.com/api/explorer/ble-
testnet/address/0x00C5C0B8e0f75aB862CbAaeCfff499dB555FBDD2)[ReceiveUln302
(0x1d18...)](https://layerzeroscan.com/api/explorer/ble-
testnet/address/0x1d186C560281B8F1AF831957ED5047fD3AB902F9)[SendUln301
(0xF019...)](https://layerzeroscan.com/api/explorer/ble-
testnet/address/0xF0196DEa83b47244222B315AbbbcF6b9fD2F705c)[ReceiveUln301
(0xa78A...)](https://layerzeroscan.com/api/explorer/ble-
testnet/address/0xa78A78a13074eD93aD447a26Ec57121f29E8feC2)[LZ Executor
(0x4Cf1...)](https://layerzeroscan.com/api/explorer/ble-
testnet/address/0x4Cf1B3Fa61465c2c907f82fC488B43223BA0CF93)  
![](https://icons-ckg.pages.dev/lz-scan/networks/bob.svg)Bob Mainnet| 30279|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/bob/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/bob/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/bob/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/bob/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/bob/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xc097...)](https://layerzeroscan.com/api/explorer/bob/address/0xc097ab8CD7b053326DFe9fB3E3a31a0CCe3B526f)  
![](https://icons-ckg.pages.dev/lz-scan/networks/bob-testnet.svg)Bob Testnet|
40279| [EndpointV2 (0x6EDC...)](https://layerzeroscan.com/api/explorer/bob-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/bob-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/bob-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/bob-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/bob-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x55c1...)](https://layerzeroscan.com/api/explorer/bob-
testnet/address/0x55c175DD5b039331dB251424538169D8495C18d1)  
![](https://icons-ckg.pages.dev/lz-scan/networks/botanix-testnet.svg)Botanix
Testnet| 40281| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/botanix-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/botanix-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/botanix-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/botanix-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/botanix-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x1252...)](https://layerzeroscan.com/api/explorer/botanix-
testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/bouncebit-
testnet.svg)Bouncebit Testnet| 40289| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/bouncebit-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/bouncebit-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/bouncebit-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/bouncebit-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/bouncebit-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x55c1...)](https://layerzeroscan.com/api/explorer/bouncebit-
testnet/address/0x55c175DD5b039331dB251424538169D8495C18d1)  
![](https://icons-ckg.pages.dev/lz-scan/networks/camp-testnet.svg)Camp
Testnet| 40295| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/camp-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/camp-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/camp-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/camp-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/camp-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x1252...)](https://layerzeroscan.com/api/explorer/camp-
testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/canto.svg)Canto Mainnet|
30159| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/canto/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x61Ab...)](https://layerzeroscan.com/api/explorer/canto/address/0x61Ab01Ce58D1dFf3562bb25870020d555e39D849)[ReceiveUln302
(0x6BD7...)](https://layerzeroscan.com/api/explorer/canto/address/0x6BD792911F4B3714E88FbDf32B351632e7d22c70)[SendUln301
(0x243E...)](https://layerzeroscan.com/api/explorer/canto/address/0x243EC2F09e12B3843548C528303A15c0cA5B1237)[ReceiveUln301
(0x9aD0...)](https://layerzeroscan.com/api/explorer/canto/address/0x9aD0958902A56729f139805C7378Ff13E88eCcA7)[LZ
Executor
(0x8E72...)](https://layerzeroscan.com/api/explorer/canto/address/0x8E721E1930B4559AcAfDf06eE591af2FFCB93b8D)  
![](https://icons-ckg.pages.dev/lz-scan/networks/canto-testnet.svg)Canto
Testnet| 40159| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/canto-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x5Bb7...)](https://layerzeroscan.com/api/explorer/canto-
testnet/address/0x5Bb7F2FFF085f0066430Be92541Db302B9F1e6Af)[ReceiveUln302
(0x5c68...)](https://layerzeroscan.com/api/explorer/canto-
testnet/address/0x5c68f65B7156cdDC79C1C6f32b3073eB8BBe6e58)[SendUln301
(0x6a94...)](https://layerzeroscan.com/api/explorer/canto-
testnet/address/0x6a9428e0f920a9a5E5B3440Fdf3494fd221d78F7)[ReceiveUln301
(0x7458...)](https://layerzeroscan.com/api/explorer/canto-
testnet/address/0x74582424B8b92BE2eC17c192F6976b2effEFAb7c)[LZ Executor
(0xcA01...)](https://layerzeroscan.com/api/explorer/canto-
testnet/address/0xcA01DAa8e559Cb6a810ce7906eC2AeA39BDeccE4)  
![](https://icons-ckg.pages.dev/lz-scan/networks/alfajores.svg)Celo Alfajores
Testnet| 40125| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/alfajores/address/0x6EDCE65403992e310A62460808c4b910D972f10f)|
[SendUln302
(0x0043...)](https://layerzeroscan.com/api/explorer/alfajores/address/0x00432463F40E100F6A99fA2E60B09F0182D828DE)[ReceiveUln302
(0xdb5A...)](https://layerzeroscan.com/api/explorer/alfajores/address/0xdb5A808eF72Aa3224D9fA6c15B717E8029B89a4f)[SendUln301
(0xfb66...)](https://layerzeroscan.com/api/explorer/alfajores/address/0xfb667d3db2c3798ECDBE50098A20A6F7AC67f710)[ReceiveUln301
(0x0aEa...)](https://layerzeroscan.com/api/explorer/alfajores/address/0x0aEae1f789B226E74c6b00347a8a3E679066dE48)[LZ
Executor
(0x5468...)](https://layerzeroscan.com/api/explorer/alfajores/address/0x5468b60ed00F9b389B5Ba660189862Db058D7dC8)  
![](https://icons-ckg.pages.dev/lz-scan/networks/celo.svg)Celo Mainnet| 30125|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/celo/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x42b4...)](https://layerzeroscan.com/api/explorer/celo/address/0x42b4E9C6495B4cFDaE024B1eC32E09F28027620e)[ReceiveUln302
(0xaDDe...)](https://layerzeroscan.com/api/explorer/celo/address/0xaDDed4478B423d991C21E525Cd3638FBce1AaD17)[SendUln301
(0xc802...)](https://layerzeroscan.com/api/explorer/celo/address/0xc80233AD8251E668BecbC3B0415707fC7075501e)[ReceiveUln301
(0x556d...)](https://layerzeroscan.com/api/explorer/celo/address/0x556d7664d5b4Db11f381c714B6b47A8Bf0b494FD)[LZ
Executor
(0x1dDb...)](https://layerzeroscan.com/api/explorer/celo/address/0x1dDbaF8b75F2291A97C22428afEf411b7bB19e28)  
![](https://icons-ckg.pages.dev/lz-scan/networks/codex.svg)CodexRecently
Added!| 30310| [EndpointV2
(0xcb56...)](https://layerzeroscan.com/api/explorer/codex/address/0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa)|
[SendUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/codex/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[ReceiveUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/codex/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[SendUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/codex/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[ReceiveUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/codex/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[LZ
Executor
(0x4208...)](https://layerzeroscan.com/api/explorer/codex/address/0x4208D6E27538189bB48E603D6123A94b8Abe0A0b)  
![](https://icons-ckg.pages.dev/lz-scan/networks/codex-testnet.svg)Codex
Testnet| 40311| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/codex-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/codex-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/codex-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/codex-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/codex-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/codex-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/conflux-testnet.svg)Conflux
Testnet| 40211| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/conflux-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x9325...)](https://layerzeroscan.com/api/explorer/conflux-
testnet/address/0x9325bE62062a8844839C0fF9cbb0bA97b2d9EAF9)[ReceiveUln302
(0x9971...)](https://layerzeroscan.com/api/explorer/conflux-
testnet/address/0x99710d5cd4650A0E6b34438d0bD860F5A426EFd6)[SendUln301
(0x95eF...)](https://layerzeroscan.com/api/explorer/conflux-
testnet/address/0x95eF4b9f53bb078372CA50624968126aF38246Bf)[ReceiveUln301
(0x9FC6...)](https://layerzeroscan.com/api/explorer/conflux-
testnet/address/0x9FC61783e62f699Ea372773f27E486f423480302)[LZ Executor
(0xE699...)](https://layerzeroscan.com/api/explorer/conflux-
testnet/address/0xE699078689c771383C8e262DCFeE520c9171ED53)  
![](https://icons-ckg.pages.dev/lz-scan/networks/conflux.svg)Conflux eSpace|
30212| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/conflux/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xb360...)](https://layerzeroscan.com/api/explorer/conflux/address/0xb360A579Dc6f77d6a3E8710A9d983811129C428d)[ReceiveUln302
(0x16Cc...)](https://layerzeroscan.com/api/explorer/conflux/address/0x16Cc4EF7c128d7FEa96Cf46FFD9dD20f76170347)[SendUln301
(0x08D4...)](https://layerzeroscan.com/api/explorer/conflux/address/0x08D4c56cb7766b947c5b76e83bF23bE0Df6e1Abb)[ReceiveUln301
(0x0BcA...)](https://layerzeroscan.com/api/explorer/conflux/address/0x0BcAC336466ef7F1e0b5c184aAB2867C108331aF)[LZ
Executor
(0x07Dd...)](https://layerzeroscan.com/api/explorer/conflux/address/0x07Dd1bf9F684D81f59B6a6760438d383ad755355)  
![](https://icons-ckg.pages.dev/lz-scan/networks/coredao.svg)Core Blockchain
Mainnet| 30153| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/coredao/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x0BcA...)](https://layerzeroscan.com/api/explorer/coredao/address/0x0BcAC336466ef7F1e0b5c184aAB2867C108331aF)[ReceiveUln302
(0x8F76...)](https://layerzeroscan.com/api/explorer/coredao/address/0x8F76bAcC52b5730c1f1A2413B8936D4df12aF4f6)[SendUln301
(0xdCD9...)](https://layerzeroscan.com/api/explorer/coredao/address/0xdCD9fd7EabCD0fC90300984Fc1Ccb67b5BF3DA36)[ReceiveUln301
(0x07Dd...)](https://layerzeroscan.com/api/explorer/coredao/address/0x07Dd1bf9F684D81f59B6a6760438d383ad755355)[LZ
Executor
(0x1785...)](https://layerzeroscan.com/api/explorer/coredao/address/0x1785c94d31E3E3Ab1079e7ca8a9fbDf33EEf9dd5)  
![](https://icons-ckg.pages.dev/lz-scan/networks/coredao-testnet.svg)CoreDAO
Testnet| 40153| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/coredao-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xc836...)](https://layerzeroscan.com/api/explorer/coredao-
testnet/address/0xc8361Fac616435eB86B9F6e2faaff38F38B0d68C)[ReceiveUln302
(0xD1bb...)](https://layerzeroscan.com/api/explorer/coredao-
testnet/address/0xD1bbdB62826eDdE4934Ff3A4920eB053ac9D5569)[SendUln301
(0x73B2...)](https://layerzeroscan.com/api/explorer/coredao-
testnet/address/0x73B2dCB13A27e893c249d8240e9179f2C5FEcf7E)[ReceiveUln301
(0xaBfa...)](https://layerzeroscan.com/api/explorer/coredao-
testnet/address/0xaBfa1F7c3586eaFF6958DC85BAEbBab7D3908fD2)[LZ Executor
(0x3Bdb...)](https://layerzeroscan.com/api/explorer/coredao-
testnet/address/0x3Bdb89Df44e50748fAed8cf851eB25bf95f37d19)  
![](https://icons-ckg.pages.dev/lz-scan/networks/curtis-testnet.svg)Curtis
Testnet| 40306| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/curtis-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/curtis-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/curtis-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/curtis-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/curtis-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/curtis-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/cyber.svg)Cyber Mainnet|
30283| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/cyber/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/cyber/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/cyber/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/cyber/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/cyber/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xc097...)](https://layerzeroscan.com/api/explorer/cyber/address/0xc097ab8CD7b053326DFe9fB3E3a31a0CCe3B526f)  
![](https://icons-ckg.pages.dev/lz-scan/networks/cyber-testnet.svg)Cyber
Testnet| 40280| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/cyber-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/cyber-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/cyber-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/cyber-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/cyber-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x1252...)](https://layerzeroscan.com/api/explorer/cyber-
testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/dos.svg)DOS Chain| 30149|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/dos/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x72C9...)](https://layerzeroscan.com/api/explorer/dos/address/0x72C91c46d7033dfF1707091Ef32D4951a73bD099)[ReceiveUln302
(0xEF77...)](https://layerzeroscan.com/api/explorer/dos/address/0xEF7781FC1C4F7B2Fd3Cf03f4d65b6835b27C1A0d)[SendUln301
(0x7908...)](https://layerzeroscan.com/api/explorer/dos/address/0x79089C4eD119900839AdD13a1a8F0298ABFC4aa2)[ReceiveUln301
(0x94fE...)](https://layerzeroscan.com/api/explorer/dos/address/0x94fE59AfAff2d0a8Ea6e8158FeB7C65410867a9b)[LZ
Executor
(0x5B23...)](https://layerzeroscan.com/api/explorer/dos/address/0x5B23E2bAe5C5f00e804EA2C4C9abe601604378fa)  
![](https://icons-ckg.pages.dev/lz-scan/networks/dos-testnet.svg)DOS Testnet|
40286| [EndpointV2 (0x0841...)](https://layerzeroscan.com/api/explorer/dos-
testnet/address/0x08416c0eAa8ba93F907eC8D6a9cAb24821C53E64)| [SendUln302
(0xa805...)](https://layerzeroscan.com/api/explorer/dos-
testnet/address/0xa805000DcA12b38690558785878642BA19Bc4981)[ReceiveUln302
(0x00D0...)](https://layerzeroscan.com/api/explorer/dos-
testnet/address/0x00D0cd55beAfb96f0A5c37452f56D06DA3765ce8)[SendUln301
(0x8fC0...)](https://layerzeroscan.com/api/explorer/dos-
testnet/address/0x8fC0E34d14d80148BB24EF48fA05621B181D098e)[ReceiveUln301
(0x9d92...)](https://layerzeroscan.com/api/explorer/dos-
testnet/address/0x9d925b84c726f2Bc4Af308fBB23679BCB344fE72)[LZ Executor
(0x06f0...)](https://layerzeroscan.com/api/explorer/dos-
testnet/address/0x06f021541521Ae6dcfaeED4EC9A8bF800528E805)  
![](https://icons-ckg.pages.dev/lz-scan/networks/dfk.svg)DeFi Kingdoms
Mainnet| 30115| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/dfk/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xc802...)](https://layerzeroscan.com/api/explorer/dfk/address/0xc80233AD8251E668BecbC3B0415707fC7075501e)[ReceiveUln302
(0x556d...)](https://layerzeroscan.com/api/explorer/dfk/address/0x556d7664d5b4Db11f381c714B6b47A8Bf0b494FD)[SendUln301
(0x75b0...)](https://layerzeroscan.com/api/explorer/dfk/address/0x75b073994560A5c03Cd970414d9170be0C6e5c36)[ReceiveUln301
(0xcC2d...)](https://layerzeroscan.com/api/explorer/dfk/address/0xcC2d3d4B88b87775Bec386d92F6951Ee7f8d52D9)[LZ
Executor
(0x1a7C...)](https://layerzeroscan.com/api/explorer/dfk/address/0x1a7CE89220b945e82f80380B14aA6FDC5E5e3B2A)  
![](https://icons-ckg.pages.dev/lz-scan/networks/dfk-testnet.svg)DeFi Kingdoms
Testnet| 40115| [EndpointV2
(0x94FF...)](https://layerzeroscan.com/api/explorer/dfk-
testnet/address/0x94FF3a4d9E9792dc59193ff753B5038A14c59570)| [SendUln302
(0xd453...)](https://layerzeroscan.com/api/explorer/dfk-
testnet/address/0xd45316d099dC4f3B15f2462888D62D919bc07a61)[ReceiveUln302
(0x5709...)](https://layerzeroscan.com/api/explorer/dfk-
testnet/address/0x5709988a03d1CC02197F222D2C72CcC6018bCE0B)[SendUln301
(0x00E1...)](https://layerzeroscan.com/api/explorer/dfk-
testnet/address/0x00E118BE6932185202ecBf9c9ceE66240B29B47F)[ReceiveUln301
(0x3D50...)](https://layerzeroscan.com/api/explorer/dfk-
testnet/address/0x3D50Cb5860377aC29895fb3B034222B3e599689B)[LZ Executor
(0x1b36...)](https://layerzeroscan.com/api/explorer/dfk-
testnet/address/0x1b3649C2C06F1fb0d3e57FB001c8B592f5E3CAc6)  
![](https://icons-ckg.pages.dev/lz-scan/networks/degen.svg)Degen Mainnet|
30267| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/degen/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/degen/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/degen/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/degen/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/degen/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xc097...)](https://layerzeroscan.com/api/explorer/degen/address/0xc097ab8CD7b053326DFe9fB3E3a31a0CCe3B526f)  
![](https://icons-ckg.pages.dev/lz-scan/networks/dexalot.svg)Dexalot Subnet|
30118| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/dexalot/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x439C...)](https://layerzeroscan.com/api/explorer/dexalot/address/0x439C059878fA7A747ead101e2e20A65AcA01C7A8)[ReceiveUln302
(0xe01F...)](https://layerzeroscan.com/api/explorer/dexalot/address/0xe01F3c1CD14F39303D175c31c16f58707B28976b)[SendUln301
(0xb5c7...)](https://layerzeroscan.com/api/explorer/dexalot/address/0xb5c73a0b0788743D2818757c8D0A5AB7D37858E9)[ReceiveUln301
(0xBFbB...)](https://layerzeroscan.com/api/explorer/dexalot/address/0xBFbBcB2Cc399086a3EEd28aC5947339c4Cf23eBA)[LZ
Executor
(0xcbD3...)](https://layerzeroscan.com/api/explorer/dexalot/address/0xcbD35a9b849342AD34a71e072D9947D4AFb4E164)  
![](https://icons-ckg.pages.dev/lz-scan/networks/dexalot-testnet.svg)Dexalot
Subnet Testnet| 40118| [EndpointV2
(0x7288...)](https://layerzeroscan.com/api/explorer/dexalot-
testnet/address/0x72884B17f92a863fD056Ec3695Bd3484D601f39a)| [SendUln302
(0x4B68...)](https://layerzeroscan.com/api/explorer/dexalot-
testnet/address/0x4B68C45f6A276485870D56f1699DCf451FEC076F)[ReceiveUln302
(0x3De7...)](https://layerzeroscan.com/api/explorer/dexalot-
testnet/address/0x3De74963B7223343ffD168e230fC4e374282d37b)[SendUln301
(0x8247...)](https://layerzeroscan.com/api/explorer/dexalot-
testnet/address/0x82470370d95d5cb20700a306DE3f8eF19cbCC725)[ReceiveUln301
(0x21f1...)](https://layerzeroscan.com/api/explorer/dexalot-
testnet/address/0x21f1C2B131557c3AebA918D590815c47Dc4F20aa)[LZ Executor
(0x13EA...)](https://layerzeroscan.com/api/explorer/dexalot-
testnet/address/0x13EA72039D7f02848CDDd67a2F948dd334cDE70e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/dm2verse.svg)Dm2verseRecently
Added!| 30315| [EndpointV2
(0x6F47...)](https://layerzeroscan.com/api/explorer/dm2verse/address/0x6F475642a6e85809B1c36Fa62763669b1b48DD5B)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/dm2verse/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/dm2verse/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/dm2verse/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/dm2verse/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/dm2verse/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/dm2verse-testnet.svg)Dm2verse
Testnet| 40321| [EndpointV2
(0x3aCA...)](https://layerzeroscan.com/api/explorer/dm2verse-
testnet/address/0x3aCAAf60502791D199a5a5F0B173D78229eBFe32)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/dm2verse-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/dm2verse-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/dm2verse-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/dm2verse-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x55c1...)](https://layerzeroscan.com/api/explorer/dm2verse-
testnet/address/0x55c175DD5b039331dB251424538169D8495C18d1)  
![](https://icons-ckg.pages.dev/lz-scan/networks/ebi.svg)EBI Mainnet| 30282|
[EndpointV2
(0x6F47...)](https://layerzeroscan.com/api/explorer/ebi/address/0x6F475642a6e85809B1c36Fa62763669b1b48DD5B)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/ebi/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/ebi/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/ebi/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/ebi/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xc097...)](https://layerzeroscan.com/api/explorer/ebi/address/0xc097ab8CD7b053326DFe9fB3E3a31a0CCe3B526f)  
![](https://icons-ckg.pages.dev/lz-scan/networks/ebi-testnet.svg)EBI Testnet|
40284| [EndpointV2 (0x6EDC...)](https://layerzeroscan.com/api/explorer/ebi-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/ebi-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/ebi-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/ebi-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/ebi-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x1252...)](https://layerzeroscan.com/api/explorer/ebi-
testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/holesky-testnet.svg)Ethereum
Holesky Testnet| 40217| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/holesky-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x21F3...)](https://layerzeroscan.com/api/explorer/holesky-
testnet/address/0x21F33EcF7F65D61f77e554B4B4380829908cD076)[ReceiveUln302
(0xbAe5...)](https://layerzeroscan.com/api/explorer/holesky-
testnet/address/0xbAe52D605770aD2f0D17533ce56D146c7C964A0d)[SendUln301
(0xDD06...)](https://layerzeroscan.com/api/explorer/holesky-
testnet/address/0xDD066F8c7592bf7235F314028E5e01a66F9835F0)[ReceiveUln301
(0x8d00...)](https://layerzeroscan.com/api/explorer/holesky-
testnet/address/0x8d00218390E52B30d755882E09B2418eD08dCa7d)[LZ Executor
(0xBc0C...)](https://layerzeroscan.com/api/explorer/holesky-
testnet/address/0xBc0C24E6f24eC2F1fd7E859B8322A1277F80aaD5)  
![](https://icons-ckg.pages.dev/lz-scan/networks/ethereum.svg)Ethereum
Mainnet| 30101| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/ethereum/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xbB2E...)](https://layerzeroscan.com/api/explorer/ethereum/address/0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1)[ReceiveUln302
(0xc02A...)](https://layerzeroscan.com/api/explorer/ethereum/address/0xc02Ab410f0734EFa3F14628780e6e695156024C2)[SendUln301
(0xD231...)](https://layerzeroscan.com/api/explorer/ethereum/address/0xD231084BfB234C107D3eE2b22F97F3346fDAF705)[ReceiveUln301
(0x245B...)](https://layerzeroscan.com/api/explorer/ethereum/address/0x245B6e8FFE9ea5Fc301e32d16F66bD4C2123eEfC)[LZ
Executor
(0x1732...)](https://layerzeroscan.com/api/explorer/ethereum/address/0x173272739Bd7Aa6e4e214714048a9fE699453059)  
![](https://icons-ckg.pages.dev/lz-scan/networks/sepolia.svg)Ethereum Sepolia
Testnet| 40161| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/sepolia/address/0x6EDCE65403992e310A62460808c4b910D972f10f)|
[SendUln302
(0xcc1a...)](https://layerzeroscan.com/api/explorer/sepolia/address/0xcc1ae8Cf5D3904Cef3360A9532B477529b177cCE)[ReceiveUln302
(0xdAf0...)](https://layerzeroscan.com/api/explorer/sepolia/address/0xdAf00F5eE2158dD58E0d3857851c432E34A3A851)[SendUln301
(0x6862...)](https://layerzeroscan.com/api/explorer/sepolia/address/0x6862b19f6e42a810946B9C782E6ebE26Ad266C84)[ReceiveUln301
(0x5937...)](https://layerzeroscan.com/api/explorer/sepolia/address/0x5937A5fe272fbA38699A1b75B3439389EEFDb399)[LZ
Executor
(0x718B...)](https://layerzeroscan.com/api/explorer/sepolia/address/0x718B92b5CB0a5552039B593faF724D182A881eDA)  
cautionLayerZero Testnet Endpoints use the real Mainnet pricefeed for cross-
chain transfers. That means Ethereum Sepolia uses the real Ethereum gwei
price. For testing EVM <> EVM transfers, it may be cheaper to use another EVM
testnet with a cheaper cost of blockspace.  
![](https://icons-ckg.pages.dev/lz-scan/networks/etherlink.svg)Etherlink
Mainnet| 30292| [EndpointV2
(0xAaB5...)](https://layerzeroscan.com/api/explorer/etherlink/address/0xAaB5A48CFC03Efa9cC34A2C1aAcCCB84b4b770e4)|
[SendUln302
(0xc1B6...)](https://layerzeroscan.com/api/explorer/etherlink/address/0xc1B621b18187F74c8F6D52a6F709Dd2780C09821)[ReceiveUln302
(0x3775...)](https://layerzeroscan.com/api/explorer/etherlink/address/0x377530cdA84DFb2673bF4d145DCF0C4D7fdcB5b6)[SendUln301
(0x7cac...)](https://layerzeroscan.com/api/explorer/etherlink/address/0x7cacBe439EaD55fa1c22790330b12835c6884a91)[ReceiveUln301
(0x282b...)](https://layerzeroscan.com/api/explorer/etherlink/address/0x282b3386571f7f794450d5789911a9804FA346b4)[LZ
Executor
(0xa20D...)](https://layerzeroscan.com/api/explorer/etherlink/address/0xa20DB4Ffe74A31D17fc24BD32a7DD7555441058e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/etherlink-
testnet.svg)Etherlink Testnet| 40239| [EndpointV2
(0xec28...)](https://layerzeroscan.com/api/explorer/etherlink-
testnet/address/0xec28645346D781674B4272706D8a938dB2BAA2C6)| [SendUln302
(0xE62d...)](https://layerzeroscan.com/api/explorer/etherlink-
testnet/address/0xE62d066e71fcA410eD48ad2f2A5A860443C04035)[ReceiveUln302
(0x2072...)](https://layerzeroscan.com/api/explorer/etherlink-
testnet/address/0x2072a32Df77bAE5713853d666f26bA5e47E54717)[SendUln301
(0x638B...)](https://layerzeroscan.com/api/explorer/etherlink-
testnet/address/0x638B6D10D981273e19E32F812C9b916E82c86927)[ReceiveUln301
(0x340b...)](https://layerzeroscan.com/api/explorer/etherlink-
testnet/address/0x340b5E5E90a6D177E7614222081e0f9CDd54f25C)[LZ Executor
(0x417c...)](https://layerzeroscan.com/api/explorer/etherlink-
testnet/address/0x417cb9E12cfe7301c8b6ef8f63ffac55263e147C)  
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom.svg)Fantom Mainnet|
30112| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/fantom/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xC17B...)](https://layerzeroscan.com/api/explorer/fantom/address/0xC17BaBeF02a937093363220b0FB57De04A535D5E)[ReceiveUln302
(0xe1Dd...)](https://layerzeroscan.com/api/explorer/fantom/address/0xe1Dd69A2D08dF4eA6a30a91cC061ac70F98aAbe3)[SendUln301
(0xeDD6...)](https://layerzeroscan.com/api/explorer/fantom/address/0xeDD674b123662D1922d7060c10548ae58D4838af)[ReceiveUln301
(0xA374...)](https://layerzeroscan.com/api/explorer/fantom/address/0xA374A435f3068FDf51dBd03b931D03AA6F878DA0)[LZ
Executor
(0x2957...)](https://layerzeroscan.com/api/explorer/fantom/address/0x2957eBc0D2931270d4a539696514b047756b3056)  
![](https://icons-ckg.pages.dev/lz-scan/networks/fantom-testnet.svg)Fantom
Testnet| 40112| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x3f41...)](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0x3f41017De79aA979b8f33E2e9518203888458273)[ReceiveUln302
(0xe4a4...)](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0xe4a446690Dfaf438EEA2b06394E1fdd0A9435178)[SendUln301
(0x88bC...)](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0x88bC8e61C33F8E3CCaBe7F3aD75e397c9E3732D0)[ReceiveUln301
(0xE8ad...)](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0xE8ad92998674b08eaee83a720D47F442c51F86F3)[LZ Executor
(0x0453...)](https://layerzeroscan.com/api/explorer/fantom-
testnet/address/0x0453b4730BB550363F726aD8eeC9441e763F2835)  
![](https://icons-ckg.pages.dev/lz-scan/networks/fi-testnet.svg)Fi Testnet|
40301| [EndpointV2 (0x6C7A...)](https://layerzeroscan.com/api/explorer/fi-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/fi-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/fi-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/fi-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/fi-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/fi-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/flare.svg)Flare Mainnet|
30295| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/flare/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/flare/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[ReceiveUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/flare/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[SendUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/flare/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[ReceiveUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/flare/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/flare/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/flare-testnet.svg)Flare
Testnet| 40294| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/flare-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x00C5...)](https://layerzeroscan.com/api/explorer/flare-
testnet/address/0x00C5C0B8e0f75aB862CbAaeCfff499dB555FBDD2)[ReceiveUln302
(0x1d18...)](https://layerzeroscan.com/api/explorer/flare-
testnet/address/0x1d186C560281B8F1AF831957ED5047fD3AB902F9)[SendUln301
(0xF019...)](https://layerzeroscan.com/api/explorer/flare-
testnet/address/0xF0196DEa83b47244222B315AbbbcF6b9fD2F705c)[ReceiveUln301
(0xa78A...)](https://layerzeroscan.com/api/explorer/flare-
testnet/address/0xa78A78a13074eD93aD447a26Ec57121f29E8feC2)[LZ Executor
(0x9dB9...)](https://layerzeroscan.com/api/explorer/flare-
testnet/address/0x9dB9Ca3305B48F196D18082e91cB64663b13d014)  
![](https://icons-ckg.pages.dev/lz-scan/networks/form-testnet.svg)Form
Testnet| 40270| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/form-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/form-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/form-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/form-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/form-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x1252...)](https://layerzeroscan.com/api/explorer/form-
testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/fraxtal.svg)Fraxtal Mainnet|
30255| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/fraxtal/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x3775...)](https://layerzeroscan.com/api/explorer/fraxtal/address/0x377530cdA84DFb2673bF4d145DCF0C4D7fdcB5b6)[ReceiveUln302
(0x8bC1...)](https://layerzeroscan.com/api/explorer/fraxtal/address/0x8bC1e36F015b9902B54b1387A4d733cebc2f5A4e)[SendUln301
(0x282b...)](https://layerzeroscan.com/api/explorer/fraxtal/address/0x282b3386571f7f794450d5789911a9804FA346b4)[ReceiveUln301
(0x6788...)](https://layerzeroscan.com/api/explorer/fraxtal/address/0x6788f52439ACA6BFF597d3eeC2DC9a44B8FEE842)[LZ
Executor
(0x41Bd...)](https://layerzeroscan.com/api/explorer/fraxtal/address/0x41Bdb4aa4A63a5b2Efc531858d3118392B1A1C3d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/fraxtal-testnet.svg)Fraxtal
Testnet| 40255| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/fraxtal-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/fraxtal-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/fraxtal-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/fraxtal-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/fraxtal-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x55c1...)](https://layerzeroscan.com/api/explorer/fraxtal-
testnet/address/0x55c175DD5b039331dB251424538169D8495C18d1)  
![](https://icons-ckg.pages.dev/lz-scan/networks/fuse.svg)Fuse Mainnet| 30138|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/fuse/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x2762...)](https://layerzeroscan.com/api/explorer/fuse/address/0x2762409Baa1804D94D8c0bCFF8400B78Bf915D5B)[ReceiveUln302
(0xB125...)](https://layerzeroscan.com/api/explorer/fuse/address/0xB12514e226E50844E4655696c92c0c36B8A53141)[SendUln301
(0xCD2E...)](https://layerzeroscan.com/api/explorer/fuse/address/0xCD2E3622d483C7Dc855F72e5eafAdCD577ac78B4)[ReceiveUln301
(0x6b34...)](https://layerzeroscan.com/api/explorer/fuse/address/0x6b340A6413068C423cfd63D91764B34457C97Aa4)[LZ
Executor
(0xc905...)](https://layerzeroscan.com/api/explorer/fuse/address/0xc905E74BEb8229E258c3C6E5bC0D6Cc54C534688)  
![](https://icons-ckg.pages.dev/lz-scan/networks/fusespark.svg)Fusespark
Testnet| 40138| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/fusespark/address/0x6EDCE65403992e310A62460808c4b910D972f10f)|
[SendUln302
(0x098F...)](https://layerzeroscan.com/api/explorer/fusespark/address/0x098Fed01ABd66C63e706Ed9b368726DE54FefBEb)[ReceiveUln302
(0x253E...)](https://layerzeroscan.com/api/explorer/fusespark/address/0x253E37074D299b70d11F72eF547cc2EF59fD7f9C)[SendUln301
(0x134F...)](https://layerzeroscan.com/api/explorer/fusespark/address/0x134FC1970434b837FF11E1dF29d1Da00338B4FFf)[ReceiveUln301
(0x7651...)](https://layerzeroscan.com/api/explorer/fusespark/address/0x76519C66ecA66185d129E1142417aEf22ee47693)[LZ
Executor
(0x86d0...)](https://layerzeroscan.com/api/explorer/fusespark/address/0x86d08462EaA1559345d7F41f937B2C804209DB8A)  
![](https://icons-ckg.pages.dev/lz-scan/networks/glue-testnet.svg)Glue
Testnet| 40296| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/glue-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/glue-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/glue-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/glue-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/glue-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x1252...)](https://layerzeroscan.com/api/explorer/glue-
testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/chiado.svg)Gnosis Chiado
Testnet| 40145| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/chiado/address/0x6EDCE65403992e310A62460808c4b910D972f10f)|
[SendUln302
(0xddF3...)](https://layerzeroscan.com/api/explorer/chiado/address/0xddF3266fEAa899ACcf805F4379E5137144cb0A7D)[ReceiveUln302
(0xC228...)](https://layerzeroscan.com/api/explorer/chiado/address/0xC22825d9982365d31E63CC3b5589B17067e795b1)[SendUln301
(0x9723...)](https://layerzeroscan.com/api/explorer/chiado/address/0x97237B7Daff151Eb9793Aa749b487B8bA157E465)[ReceiveUln301
(0x9c79...)](https://layerzeroscan.com/api/explorer/chiado/address/0x9c79B1B82Ab36FbDf927afbD653Ebb6b9cd11121)[LZ
Executor
(0xe382...)](https://layerzeroscan.com/api/explorer/chiado/address/0xe3826C822a53a736cC4d8f6FD884a6E3A461d29F)  
![](https://icons-ckg.pages.dev/lz-scan/networks/gnosis.svg)Gnosis Mainnet|
30145| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/gnosis/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x3C15...)](https://layerzeroscan.com/api/explorer/gnosis/address/0x3C156b1f625D2B4E004D43E91aC2c3a719C29c7B)[ReceiveUln302
(0x9714...)](https://layerzeroscan.com/api/explorer/gnosis/address/0x9714Ccf1dedeF14BaB5013625DB92746C1358cb4)[SendUln301
(0x42b4...)](https://layerzeroscan.com/api/explorer/gnosis/address/0x42b4E9C6495B4cFDaE024B1eC32E09F28027620e)[ReceiveUln301
(0xaDDe...)](https://layerzeroscan.com/api/explorer/gnosis/address/0xaDDed4478B423d991C21E525Cd3638FBce1AaD17)[LZ
Executor
(0x3834...)](https://layerzeroscan.com/api/explorer/gnosis/address/0x38340337f9ADF5D76029Ab3A667d34E5a032F7BA)  
![](https://icons-ckg.pages.dev/lz-scan/networks/gravity.svg)Gravity Mainnet|
30294| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/gravity/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/gravity/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[ReceiveUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/gravity/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[SendUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/gravity/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[ReceiveUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/gravity/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/gravity/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/gunzilla-testnet.svg)Gunzilla
Testnet| 40236| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/gunzilla-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x82b7...)](https://layerzeroscan.com/api/explorer/gunzilla-
testnet/address/0x82b7dc04A4ABCF2b4aE570F317dcab49f5a10f24)[ReceiveUln302
(0x3062...)](https://layerzeroscan.com/api/explorer/gunzilla-
testnet/address/0x306202702AF38152D3604cD82af71C3db0eE08CF)[SendUln301
(0x9D0A...)](https://layerzeroscan.com/api/explorer/gunzilla-
testnet/address/0x9D0A659cAC5F122e22bAaDD8769a3abc05C6bdAE)[ReceiveUln301
(0x6227...)](https://layerzeroscan.com/api/explorer/gunzilla-
testnet/address/0x62273145f80EB808EeF539Ed3ea21f4440CEBB18)[LZ Executor
(0x9554...)](https://layerzeroscan.com/api/explorer/gunzilla-
testnet/address/0x955412C07d9bC1027eb4d481621ee063bFd9f4C6)  
![](https://icons-ckg.pages.dev/lz-scan/networks/harmony.svg)Harmony Mainnet|
30116| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/harmony/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x795F...)](https://layerzeroscan.com/api/explorer/harmony/address/0x795F8325aF292Ff6E58249361d1954893BE15Aff)[ReceiveUln302
(0x177d...)](https://layerzeroscan.com/api/explorer/harmony/address/0x177d36dBE2271A4DdB2Ad8304d82628eb921d790)[SendUln301
(0x91AA...)](https://layerzeroscan.com/api/explorer/harmony/address/0x91AA2547728307E0e3B35254D526aceF202d131A)[ReceiveUln301
(0x5000...)](https://layerzeroscan.com/api/explorer/harmony/address/0x50002CdFe7CCb0C41F519c6Eb0653158d11cd907)[LZ
Executor
(0xd27B...)](https://layerzeroscan.com/api/explorer/harmony/address/0xd27B2Fe1d0a60E06A0ec7e64501d2f15e6c65Bd9)  
![](https://icons-ckg.pages.dev/lz-scan/networks/hedera.svg)HederaRecently
Added!| 30316| [EndpointV2
(0x3A73...)](https://layerzeroscan.com/api/explorer/hedera/address/0x3A73033C0b1407574C76BdBAc67f126f6b4a9AA9)|
[SendUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/hedera/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[ReceiveUln302
(0xc1B6...)](https://layerzeroscan.com/api/explorer/hedera/address/0xc1B621b18187F74c8F6D52a6F709Dd2780C09821)[SendUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/hedera/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[ReceiveUln301
(0x7cac...)](https://layerzeroscan.com/api/explorer/hedera/address/0x7cacBe439EaD55fa1c22790330b12835c6884a91)[LZ
Executor
(0xa20D...)](https://layerzeroscan.com/api/explorer/hedera/address/0xa20DB4Ffe74A31D17fc24BD32a7DD7555441058e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/hedera-testnet.svg)Hedera
Testnet| 40285| [EndpointV2
(0xbD67...)](https://layerzeroscan.com/api/explorer/hedera-
testnet/address/0xbD672D1562Dd32C23B563C989d8140122483631d)| [SendUln302
(0x1707...)](https://layerzeroscan.com/api/explorer/hedera-
testnet/address/0x1707575f7cecdc0ad53fde9ba9bda3ed5d4440f4)[ReceiveUln302
(0xc0c3...)](https://layerzeroscan.com/api/explorer/hedera-
testnet/address/0xc0c34919A04d69415EF2637A3Db5D637a7126cd0)[SendUln301
(0xa813...)](https://layerzeroscan.com/api/explorer/hedera-
testnet/address/0xa8133fB932b185f8a4E88E22238C8d3602E2A853)[ReceiveUln301
(0xe729...)](https://layerzeroscan.com/api/explorer/hedera-
testnet/address/0xe7292d7797776bCcDF44C78f296Ff26Ddb70F70a)[LZ Executor
(0xe514...)](https://layerzeroscan.com/api/explorer/hedera-
testnet/address/0xe514D331c54d7339108045bF4794F8d71cad110e)  
cautionThe Hedera EVM has 8 decimals while their JSON RPC uses 18 decimals for
`msg.value`, please take precaution when calling `quoteFee`  
![](https://icons-ckg.pages.dev/lz-scan/networks/homeverse.svg)Homeverse
Mainnet| 30265| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/homeverse/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x9802...)](https://layerzeroscan.com/api/explorer/homeverse/address/0x980205D352F198748B626f6f7C38A8a5663Ec981)[ReceiveUln302
(0xFe7C...)](https://layerzeroscan.com/api/explorer/homeverse/address/0xFe7C30860D01e28371D40434806F4A8fcDD3A098)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/homeverse/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/homeverse/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xc097...)](https://layerzeroscan.com/api/explorer/homeverse/address/0xc097ab8CD7b053326DFe9fB3E3a31a0CCe3B526f)  
cautionThe Homeverse Endpoint uses an alternative ERC20 token instead of the
native gas token for omnichain fees. You will need to modify your _payNative()
function in OApp to handle ERC20 fees (see OFTAlt).  
![](https://icons-ckg.pages.dev/lz-scan/networks/homeverse-
testnet.svg)Homeverse Testnet| 40265| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/homeverse-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/homeverse-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/homeverse-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/homeverse-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/homeverse-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x1252...)](https://layerzeroscan.com/api/explorer/homeverse-
testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)  
cautionThe Homeverse Endpoint uses an alternative ERC20 token instead of the
native gas token for omnichain fees. You will need to modify your _payNative()
function in OApp to handle ERC20 fees (see OFTAlt).  
![](https://icons-ckg.pages.dev/lz-scan/networks/eon.svg)Horizen EON Mainnet|
30215| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/eon/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x5EB6...)](https://layerzeroscan.com/api/explorer/eon/address/0x5EB6b3Db915d29fc624b8a0e42AC029e36a1D86B)[ReceiveUln302
(0xF622...)](https://layerzeroscan.com/api/explorer/eon/address/0xF622DFb40bf7340DBCf1e5147D6CFD95d7c5cF1F)[SendUln301
(0xF538...)](https://layerzeroscan.com/api/explorer/eon/address/0xF53857dbc0D2c59D5666006EC200cbA2936B8c35)[ReceiveUln301
(0x4f8B...)](https://layerzeroscan.com/api/explorer/eon/address/0x4f8B7a7a346Da5c467085377796e91220d904c15)[LZ
Executor
(0xA09d...)](https://layerzeroscan.com/api/explorer/eon/address/0xA09dB5142654e3eB5Cf547D66833FAe7097B21C3)  
![](https://icons-ckg.pages.dev/lz-scan/networks/hubble.svg)Hubble Mainnet|
30182| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/hubble/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xBB96...)](https://layerzeroscan.com/api/explorer/hubble/address/0xBB967E3A329F4c47F654B82a2F7d11E69E5A7143)[ReceiveUln302
(0x6f16...)](https://layerzeroscan.com/api/explorer/hubble/address/0x6f1686189f32e78f1D83e7c6Ed433FCeBc3A5B51)[SendUln301
(0xD165...)](https://layerzeroscan.com/api/explorer/hubble/address/0xD1654C656455E40E2905E96b6B91088AC2B362a2)[ReceiveUln301
(0xC1EC...)](https://layerzeroscan.com/api/explorer/hubble/address/0xC1EC25A9e8a8DE5Aa346f635B33e5B74c4c081aF)[LZ
Executor
(0xe9AE...)](https://layerzeroscan.com/api/explorer/hubble/address/0xe9AE261D3aFf7d3fCCF38Fa2d612DD3897e07B2d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/hyperliquid-
testnet.svg)Hyperliquid TestnetRecently Added!| 40332| [EndpointV2
(0x6Ac7...)](https://layerzeroscan.com/api/explorer/hyperliquid-
testnet/address/0x6Ac7bdc07A0583A362F1497252872AE6c0A5F5B8)| [SendUln302
(0x00C5...)](https://layerzeroscan.com/api/explorer/hyperliquid-
testnet/address/0x00C5C0B8e0f75aB862CbAaeCfff499dB555FBDD2)[ReceiveUln302
(0x1d18...)](https://layerzeroscan.com/api/explorer/hyperliquid-
testnet/address/0x1d186C560281B8F1AF831957ED5047fD3AB902F9)[SendUln301
(0xF019...)](https://layerzeroscan.com/api/explorer/hyperliquid-
testnet/address/0xF0196DEa83b47244222B315AbbbcF6b9fD2F705c)[ReceiveUln301
(0xa78A...)](https://layerzeroscan.com/api/explorer/hyperliquid-
testnet/address/0xa78A78a13074eD93aD447a26Ec57121f29E8feC2)[LZ Executor
(0x4Cf1...)](https://layerzeroscan.com/api/explorer/hyperliquid-
testnet/address/0x4Cf1B3Fa61465c2c907f82fC488B43223BA0CF93)  
![](https://icons-ckg.pages.dev/lz-
scan/networks/bl2-testnet.svg)InclusiveLayer TestnetRecently Added!| 40331|
[EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/bl2-testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)|
[SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/bl2-testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/bl2-testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/bl2-testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/bl2-testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ
Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/bl2-testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/iota.svg)Iota Mainnet| 30284|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/iota/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/iota/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/iota/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/iota/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/iota/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xc097...)](https://layerzeroscan.com/api/explorer/iota/address/0xc097ab8CD7b053326DFe9fB3E3a31a0CCe3B526f)  
![](https://icons-ckg.pages.dev/lz-scan/networks/iota-testnet.svg)Iota
Testnet| 40307| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/iota-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/iota-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/iota-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/iota-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/iota-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/iota-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/joc.svg)Japan Open Chain|
30285| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/joc/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/joc/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[ReceiveUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/joc/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[SendUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/joc/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[ReceiveUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/joc/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/joc/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/joc-testnet.svg)Japan Open
Chain Testnet| 40242| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/joc-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x9eCf...)](https://layerzeroscan.com/api/explorer/joc-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln302
(0xB048...)](https://layerzeroscan.com/api/explorer/joc-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[SendUln301
(0xF49d...)](https://layerzeroscan.com/api/explorer/joc-
testnet/address/0xF49d162484290EAeAd7bb8C2c7E3a6f8f52e32d6)[ReceiveUln301
(0xC186...)](https://layerzeroscan.com/api/explorer/joc-
testnet/address/0xC1868e054425D378095A003EcbA3823a5D0135C9)[LZ Executor
(0x4dFa...)](https://layerzeroscan.com/api/explorer/joc-
testnet/address/0x4dFa426aEAA55E6044d2b47682842460a04aF45c)  
![](https://icons-ckg.pages.dev/lz-scan/networks/kava.svg)Kava Mainnet| 30177|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/kava/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x83Fb...)](https://layerzeroscan.com/api/explorer/kava/address/0x83Fb937054918cB7AccB15bd6cD9234dF9ebb357)[ReceiveUln302
(0xb7e9...)](https://layerzeroscan.com/api/explorer/kava/address/0xb7e97ad5661134185Fe608b2A31fe8cEf2147Ba9)[SendUln301
(0x02E5...)](https://layerzeroscan.com/api/explorer/kava/address/0x02E5fc018fa140eC2eE934f3Bf22a05DF62ba908)[ReceiveUln301
(0x5573...)](https://layerzeroscan.com/api/explorer/kava/address/0x55734F78a14cCb85BB3886a8917e90df44EB8F4F)[LZ
Executor
(0x41ED...)](https://layerzeroscan.com/api/explorer/kava/address/0x41ED8065dd9bC6c0caF21c39766eDCBA0F21851c)  
![](https://icons-ckg.pages.dev/lz-scan/networks/kava-testnet.svg)Kava
Testnet| 40172| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/kava-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4B68...)](https://layerzeroscan.com/api/explorer/kava-
testnet/address/0x4B68C45f6A276485870D56f1699DCf451FEC076F)[ReceiveUln302
(0x3De7...)](https://layerzeroscan.com/api/explorer/kava-
testnet/address/0x3De74963B7223343ffD168e230fC4e374282d37b)[SendUln301
(0x8247...)](https://layerzeroscan.com/api/explorer/kava-
testnet/address/0x82470370d95d5cb20700a306DE3f8eF19cbCC725)[ReceiveUln301
(0x21f1...)](https://layerzeroscan.com/api/explorer/kava-
testnet/address/0x21f1C2B131557c3AebA918D590815c47Dc4F20aa)[LZ Executor
(0x13EA...)](https://layerzeroscan.com/api/explorer/kava-
testnet/address/0x13EA72039D7f02848CDDd67a2F948dd334cDE70e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/klaytn.svg)Klaytn Mainnet
Cypress| 30150| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/klaytn/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x9714...)](https://layerzeroscan.com/api/explorer/klaytn/address/0x9714Ccf1dedeF14BaB5013625DB92746C1358cb4)[ReceiveUln302
(0x937A...)](https://layerzeroscan.com/api/explorer/klaytn/address/0x937AbA873827BF883CeD83CA557697427eAA46Ee)[SendUln301
(0xaDDe...)](https://layerzeroscan.com/api/explorer/klaytn/address/0xaDDed4478B423d991C21E525Cd3638FBce1AaD17)[ReceiveUln301
(0x9d76...)](https://layerzeroscan.com/api/explorer/klaytn/address/0x9d76EFE29157803a03b68329486f53D9b131580a)[LZ
Executor
(0xe149...)](https://layerzeroscan.com/api/explorer/klaytn/address/0xe149187a987F129FD3d397ED04a60b0b89D1669f)  
![](https://icons-ckg.pages.dev/lz-scan/networks/klaytn-baobab.svg)Klaytn
Testnet Baobab| 40150| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/klaytn-
baobab/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x6bd9...)](https://layerzeroscan.com/api/explorer/klaytn-
baobab/address/0x6bd925aA58325fba65Ea7d4412DDB2E5D2D9427d)[ReceiveUln302
(0xFc4e...)](https://layerzeroscan.com/api/explorer/klaytn-
baobab/address/0xFc4eA96c3de3Ba60516976390fA4E945a0b8817B)[SendUln301
(0x8C89...)](https://layerzeroscan.com/api/explorer/klaytn-
baobab/address/0x8C89F0429FeB2faD83C76d32C3c17787168D9421)[ReceiveUln301
(0xe32d...)](https://layerzeroscan.com/api/explorer/klaytn-
baobab/address/0xe32d6C652b85A5183C2117749E0bc8A41e6b7282)[LZ Executor
(0xddF3...)](https://layerzeroscan.com/api/explorer/klaytn-
baobab/address/0xddF3266fEAa899ACcf805F4379E5137144cb0A7D)  
![](https://icons-ckg.pages.dev/lz-scan/networks/lif3-testnet.svg)Lif3
Testnet| 40300| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/lif3-testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)|
[SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/lif3-testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/lif3-testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/lif3-testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/lif3-testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ
Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/lif3-testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/lightlink.svg)Lightlink
MainnetRecently Added!| 30309| [EndpointV2
(0x6F47...)](https://layerzeroscan.com/api/explorer/lightlink/address/0x6F475642a6e85809B1c36Fa62763669b1b48DD5B)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/lightlink/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/lightlink/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/lightlink/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/lightlink/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/lightlink/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/lightlink-
testnet.svg)Lightlink Testnet| 40309| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/lightlink-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/lightlink-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/lightlink-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/lightlink-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/lightlink-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/lightlink-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/linea.svg)Linea Mainnet|
30183| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/linea/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x3204...)](https://layerzeroscan.com/api/explorer/linea/address/0x32042142DD551b4EbE17B6FEd53131dd4b4eEa06)[ReceiveUln302
(0xE22E...)](https://layerzeroscan.com/api/explorer/linea/address/0xE22ED54177CE1148C557de74E4873619e6c6b205)[SendUln301
(0x119C...)](https://layerzeroscan.com/api/explorer/linea/address/0x119C04C4E60158fa69eCf4cdDF629D09719a7572)[ReceiveUln301
(0x443C...)](https://layerzeroscan.com/api/explorer/linea/address/0x443CAa8CD23D8CC1e04B3Ce897822AEa6ad3EbDA)[LZ
Executor
(0x0408...)](https://layerzeroscan.com/api/explorer/linea/address/0x0408804C5dcD9796F22558464E6fE5bDdF16A7c7)  
![](https://icons-ckg.pages.dev/lz-scan/networks/lineasep-testnet.svg)Linea
Sepolia Testnet| 40287| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/lineasep-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x53fd...)](https://layerzeroscan.com/api/explorer/lineasep-
testnet/address/0x53fd4C4fBBd53F6bC58CaE6704b92dB1f360A648)[ReceiveUln302
(0x9eCf...)](https://layerzeroscan.com/api/explorer/lineasep-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[SendUln301
(0x88B2...)](https://layerzeroscan.com/api/explorer/lineasep-
testnet/address/0x88B27057A9e00c5F05DDa29241027afF63f9e6e0)[ReceiveUln301
(0xF49d...)](https://layerzeroscan.com/api/explorer/lineasep-
testnet/address/0xF49d162484290EAeAd7bb8C2c7E3a6f8f52e32d6)[LZ Executor
(0xe1a1...)](https://layerzeroscan.com/api/explorer/lineasep-
testnet/address/0xe1a12515F9AB2764b887bF60B923Ca494EBbB2d6)  
![](https://icons-ckg.pages.dev/lz-scan/networks/lisk-testnet.svg)Lisk
TestnetRecently Added!| 40327| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/lisk-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/lisk-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/lisk-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/lisk-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/lisk-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/lisk-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/loot.svg)Loot Mainnet| 30197|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/loot/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xCFf0...)](https://layerzeroscan.com/api/explorer/loot/address/0xCFf08a35A5f27F306e2DA99ff198dB90f13DEF77)[ReceiveUln302
(0xBB96...)](https://layerzeroscan.com/api/explorer/loot/address/0xBB967E3A329F4c47F654B82a2F7d11E69E5A7143)[SendUln301
(0x6167...)](https://layerzeroscan.com/api/explorer/loot/address/0x6167caAb5c3DA63311186db4D4E2596B20f557ec)[ReceiveUln301
(0xD165...)](https://layerzeroscan.com/api/explorer/loot/address/0xD1654C656455E40E2905E96b6B91088AC2B362a2)[LZ
Executor
(0x000C...)](https://layerzeroscan.com/api/explorer/loot/address/0x000CC1A759bC3A15e664Ed5379E321Be5de1c9B6)  
![](https://icons-ckg.pages.dev/lz-scan/networks/loot-testnet.svg)Loot
Testnet| 40197| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/loot-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x6271...)](https://layerzeroscan.com/api/explorer/loot-
testnet/address/0x6271e24A43cCB1509FBDC22284Ab6176237562EE)[ReceiveUln302
(0x40d0...)](https://layerzeroscan.com/api/explorer/loot-
testnet/address/0x40d0DC337feCDC4C09774e7F92Cb963674CF7Ef2)[SendUln301
(0xfE48...)](https://layerzeroscan.com/api/explorer/loot-
testnet/address/0xfE48472f5a946882aE9b8a070C29836b58faaaba)[ReceiveUln301
(0xf4A5...)](https://layerzeroscan.com/api/explorer/loot-
testnet/address/0xf4A5f28023C58F747feaB4Dd63A0b642AB583078)[LZ Executor
(0x6460...)](https://layerzeroscan.com/api/explorer/loot-
testnet/address/0x6460EE1b9D5bDE8375ca928767Cc63FBFA111A98)  
![](https://icons-ckg.pages.dev/lz-scan/networks/lyra.svg)Lyra MainnetRecently
Added!| 30311| [EndpointV2
(0xcb56...)](https://layerzeroscan.com/api/explorer/lyra/address/0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa)|
[SendUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/lyra/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[ReceiveUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/lyra/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[SendUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/lyra/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[ReceiveUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/lyra/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[LZ
Executor
(0x4208...)](https://layerzeroscan.com/api/explorer/lyra/address/0x4208D6E27538189bB48E603D6123A94b8Abe0A0b)  
![](https://icons-ckg.pages.dev/lz-scan/networks/lyra-testnet.svg)Lyra
Testnet| 40308| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/lyra-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/lyra-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/lyra-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/lyra-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/lyra-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/lyra-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/manta.svg)Manta Mainnet|
30217| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/manta/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xD165...)](https://layerzeroscan.com/api/explorer/manta/address/0xD1654C656455E40E2905E96b6B91088AC2B362a2)[ReceiveUln302
(0xC1EC...)](https://layerzeroscan.com/api/explorer/manta/address/0xC1EC25A9e8a8DE5Aa346f635B33e5B74c4c081aF)[SendUln301
(0x1aCe...)](https://layerzeroscan.com/api/explorer/manta/address/0x1aCe9DD1BC743aD036eF2D92Af42Ca70A1159df5)[ReceiveUln301
(0x000C...)](https://layerzeroscan.com/api/explorer/manta/address/0x000CC1A759bC3A15e664Ed5379E321Be5de1c9B6)[LZ
Executor
(0x8DD9...)](https://layerzeroscan.com/api/explorer/manta/address/0x8DD9197E51dC6082853aD71D35912C53339777A7)  
![](https://icons-ckg.pages.dev/lz-scan/networks/mantasep-testnet.svg)Manta
Sepolia Mainnet| 40272| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/mantasep-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/mantasep-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/mantasep-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/mantasep-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/mantasep-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x55c1...)](https://layerzeroscan.com/api/explorer/mantasep-
testnet/address/0x55c175DD5b039331dB251424538169D8495C18d1)  
![](https://icons-ckg.pages.dev/lz-scan/networks/mantle.svg)Mantle Mainnet|
30181| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/mantle/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xde19...)](https://layerzeroscan.com/api/explorer/mantle/address/0xde19274c009A22921E3966a1Ec868cEba40A5DaC)[ReceiveUln302
(0x8da6...)](https://layerzeroscan.com/api/explorer/mantle/address/0x8da6512De9379fBF4F09BF520Caf7a85435ed93e)[SendUln301
(0xa6c2...)](https://layerzeroscan.com/api/explorer/mantle/address/0xa6c26315a9229c516d7e002F098FeA7574c6C2D3)[ReceiveUln301
(0xB0a3...)](https://layerzeroscan.com/api/explorer/mantle/address/0xB0a3001dFA294F1Bea14eF8F5B6a2ae91DF69A21)[LZ
Executor
(0x4Fc3...)](https://layerzeroscan.com/api/explorer/mantle/address/0x4Fc3f4A38Acd6E4cC0ccBc04B3Dd1CCAeFd7F3Cd)  
![](https://icons-ckg.pages.dev/lz-scan/networks/mantle-sepolia.svg)Mantle
Sepolia Testnet| 40246| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/mantle-
sepolia/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x9A28...)](https://layerzeroscan.com/api/explorer/mantle-
sepolia/address/0x9A289B849b32FF69A95F8584a03343a33Ff6e5Fd)[ReceiveUln302
(0x8A3D...)](https://layerzeroscan.com/api/explorer/mantle-
sepolia/address/0x8A3D588D9f6AC041476b094f97FF94ec30169d3D)[SendUln301
(0x939A...)](https://layerzeroscan.com/api/explorer/mantle-
sepolia/address/0x939Afd54A8547078dBEa02b683A7F1FDC929f853)[ReceiveUln301
(0x72b6...)](https://layerzeroscan.com/api/explorer/mantle-
sepolia/address/0x72b65B2E699E3B5d664EF776C068236B6b8004d6)[LZ Executor
(0x8BEE...)](https://layerzeroscan.com/api/explorer/mantle-
sepolia/address/0x8BEEe743829af63F5b37e52D5ef8477eF12511dE)  
![](https://icons-ckg.pages.dev/lz-scan/networks/masa.svg)Masa Mainnet| 30263|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/masa/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/masa/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[ReceiveUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/masa/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[SendUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/masa/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[ReceiveUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/masa/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/masa/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/masa-testnet.svg)Masa
Testnet| 40263| [EndpointV2
(0xb23b...)](https://layerzeroscan.com/api/explorer/masa-
testnet/address/0xb23b28012ee92E8dE39DEb57Af31722223034747)| [SendUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/masa-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[ReceiveUln302
(0x00C5...)](https://layerzeroscan.com/api/explorer/masa-
testnet/address/0x00C5C0B8e0f75aB862CbAaeCfff499dB555FBDD2)[SendUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/masa-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[ReceiveUln301
(0xF019...)](https://layerzeroscan.com/api/explorer/masa-
testnet/address/0xF0196DEa83b47244222B315AbbbcF6b9fD2F705c)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/masa-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/beam-testnet.svg)Merit Circle
Testnet| 40178| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/beam-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x6f3a...)](https://layerzeroscan.com/api/explorer/beam-
testnet/address/0x6f3a314C1279148E53f51AF154817C3EF2C827B1)[ReceiveUln302
(0x0F7D...)](https://layerzeroscan.com/api/explorer/beam-
testnet/address/0x0F7De6155DDC16A96c0d110A488bc966Aad3991b)[SendUln301
(0x0e7C...)](https://layerzeroscan.com/api/explorer/beam-
testnet/address/0x0e7C822d4dE804f648FD204139cf6d3fD943eBe4)[ReceiveUln301
(0x36Eb...)](https://layerzeroscan.com/api/explorer/beam-
testnet/address/0x36Ebea3941907C438Ca8Ca2B1065dEef21CCdaeD)[LZ Executor
(0xA60A...)](https://layerzeroscan.com/api/explorer/beam-
testnet/address/0xA60A7a9D9723d6Adda826f5bDae29c6038B68DD3)  
![](https://icons-ckg.pages.dev/lz-scan/networks/beam.svg)Meritcircle Mainnet|
30198| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/beam/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x763B...)](https://layerzeroscan.com/api/explorer/beam/address/0x763BfcE1Ed335885D0EeC1F182fE6E6B85BAbC92)[ReceiveUln302
(0xe767...)](https://layerzeroscan.com/api/explorer/beam/address/0xe767e048221197A2b590CeB5C63C3AAD8ebf87eA)[SendUln301
(0xB041...)](https://layerzeroscan.com/api/explorer/beam/address/0xB041cd355945627BDb7281f613B6E29623ab0110)[ReceiveUln301
(0x0b5E...)](https://layerzeroscan.com/api/explorer/beam/address/0x0b5E5452d0c9DA1Bb5fB0664F48313e9667d7820)[LZ
Executor
(0x9Bdf...)](https://layerzeroscan.com/api/explorer/beam/address/0x9Bdf3aE7E2e3D211811E5e782a808Ca0a75BF1Fc)  
![](https://icons-ckg.pages.dev/lz-scan/networks/merlin.svg)Merlin Mainnet|
30266| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/merlin/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/merlin/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/merlin/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/merlin/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/merlin/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xc097...)](https://layerzeroscan.com/api/explorer/merlin/address/0xc097ab8CD7b053326DFe9fB3E3a31a0CCe3B526f)  
![](https://icons-ckg.pages.dev/lz-scan/networks/merlin-testnet.svg)Merlin
Testnet| 40264| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/merlin-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/merlin-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/merlin-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/merlin-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/merlin-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x55c1...)](https://layerzeroscan.com/api/explorer/merlin-
testnet/address/0x55c175DD5b039331dB251424538169D8495C18d1)  
![](https://icons-ckg.pages.dev/lz-scan/networks/meter.svg)Meter Mainnet|
30176| [EndpointV2
(0xef02...)](https://layerzeroscan.com/api/explorer/meter/address/0xef02BacD67C0AB45510927749009F6B9ffCE0631)|
[SendUln302
(0xD721...)](https://layerzeroscan.com/api/explorer/meter/address/0xD721315eB3d2e7e8cFDfC7d82C02a1DCe144f8E4)[ReceiveUln302
(0xffA3...)](https://layerzeroscan.com/api/explorer/meter/address/0xffA387da7E7c2d444A78cd9ebcfA89AfBF980d71)[SendUln301
(0xE6B2...)](https://layerzeroscan.com/api/explorer/meter/address/0xE6B2Ed26793d2eBEaC22eA538F627eCCEEc2a70D)[ReceiveUln301
(0xB0eE...)](https://layerzeroscan.com/api/explorer/meter/address/0xB0eE0045bb345c38C0209ca14F0F771E83Bf9b5C)[LZ
Executor
(0x27b7...)](https://layerzeroscan.com/api/explorer/meter/address/0x27b7Bf5f95c2DD6Bc07Ce4ed8598b20Fb73fF5c1)  
![](https://icons-ckg.pages.dev/lz-scan/networks/meter-testnet.svg)Meter
Testnet| 40156| [EndpointV2
(0x3E03...)](https://layerzeroscan.com/api/explorer/meter-
testnet/address/0x3E03163f253ec436d4562e5eFd038cf98827B7eC)| [SendUln302
(0x6B94...)](https://layerzeroscan.com/api/explorer/meter-
testnet/address/0x6B946AF0b8F3B4D33a36f90C5227D0054722FF32)[ReceiveUln302
(0xeA2B...)](https://layerzeroscan.com/api/explorer/meter-
testnet/address/0xeA2B12219472e0d2a7795c7f61B0602bF5c36E25)[SendUln301
(0x8098...)](https://layerzeroscan.com/api/explorer/meter-
testnet/address/0x8098DAf8D392d3606edEf496D307e2B5411A429B)[ReceiveUln301
(0x2ac4...)](https://layerzeroscan.com/api/explorer/meter-
testnet/address/0x2ac4F9E4C9d1BB0B3346613Dcb90044A46B9BfE9)[LZ Executor
(0x6892...)](https://layerzeroscan.com/api/explorer/meter-
testnet/address/0x68921A9530579203EE812ebddd0eE31ED43E7040)  
![](https://icons-ckg.pages.dev/lz-scan/networks/metis.svg)Metis Mainnet|
30151| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/metis/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x63e3...)](https://layerzeroscan.com/api/explorer/metis/address/0x63e39ccB510926d05a0ae7817c8f1CC61C5BdD6c)[ReceiveUln302
(0x5539...)](https://layerzeroscan.com/api/explorer/metis/address/0x5539Eb17a84E1D59d37C222Eb2CC4C81b502D1Ac)[SendUln301
(0x6BD7...)](https://layerzeroscan.com/api/explorer/metis/address/0x6BD792911F4B3714E88FbDf32B351632e7d22c70)[ReceiveUln301
(0xDcc1...)](https://layerzeroscan.com/api/explorer/metis/address/0xDcc1A1a26807c687300A63A72eF111F6fe994068)[LZ
Executor
(0xE6AB...)](https://layerzeroscan.com/api/explorer/metis/address/0xE6AB3B3E632f3C65c3cb4c250DcC42f5E915A1cf)  
![](https://icons-ckg.pages.dev/lz-scan/networks/metissep-testnet.svg)Metis
Sepolia Testnet| 40292| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/metissep-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x00C5...)](https://layerzeroscan.com/api/explorer/metissep-
testnet/address/0x00C5C0B8e0f75aB862CbAaeCfff499dB555FBDD2)[ReceiveUln302
(0x1d18...)](https://layerzeroscan.com/api/explorer/metissep-
testnet/address/0x1d186C560281B8F1AF831957ED5047fD3AB902F9)[SendUln301
(0xF019...)](https://layerzeroscan.com/api/explorer/metissep-
testnet/address/0xF0196DEa83b47244222B315AbbbcF6b9fD2F705c)[ReceiveUln301
(0xa78A...)](https://layerzeroscan.com/api/explorer/metissep-
testnet/address/0xa78A78a13074eD93aD447a26Ec57121f29E8feC2)[LZ Executor
(0x9dB9...)](https://layerzeroscan.com/api/explorer/metissep-
testnet/address/0x9dB9Ca3305B48F196D18082e91cB64663b13d014)  
![](https://icons-ckg.pages.dev/lz-scan/networks/minato-testnet.svg)Minato
TestnetRecently Added!| 40334| [EndpointV2
(0x6Ac7...)](https://layerzeroscan.com/api/explorer/minato-
testnet/address/0x6Ac7bdc07A0583A362F1497252872AE6c0A5F5B8)| [SendUln302
(0x00C5...)](https://layerzeroscan.com/api/explorer/minato-
testnet/address/0x00C5C0B8e0f75aB862CbAaeCfff499dB555FBDD2)[ReceiveUln302
(0x1d18...)](https://layerzeroscan.com/api/explorer/minato-
testnet/address/0x1d186C560281B8F1AF831957ED5047fD3AB902F9)[SendUln301
(0xF019...)](https://layerzeroscan.com/api/explorer/minato-
testnet/address/0xF0196DEa83b47244222B315AbbbcF6b9fD2F705c)[ReceiveUln301
(0xa78A...)](https://layerzeroscan.com/api/explorer/minato-
testnet/address/0xa78A78a13074eD93aD447a26Ec57121f29E8feC2)[LZ Executor
(0x4Cf1...)](https://layerzeroscan.com/api/explorer/minato-
testnet/address/0x4Cf1B3Fa61465c2c907f82fC488B43223BA0CF93)  
![](https://icons-ckg.pages.dev/lz-scan/networks/mode.svg)Mode Mainnet| 30260|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/mode/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/mode/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[ReceiveUln302
(0xc1B6...)](https://layerzeroscan.com/api/explorer/mode/address/0xc1B621b18187F74c8F6D52a6F709Dd2780C09821)[SendUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/mode/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[ReceiveUln301
(0x7cac...)](https://layerzeroscan.com/api/explorer/mode/address/0x7cacBe439EaD55fa1c22790330b12835c6884a91)[LZ
Executor
(0x4208...)](https://layerzeroscan.com/api/explorer/mode/address/0x4208D6E27538189bB48E603D6123A94b8Abe0A0b)  
![](https://icons-ckg.pages.dev/lz-scan/networks/mode-testnet.svg)Mode
Testnet| 40260| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/mode-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x00C5...)](https://layerzeroscan.com/api/explorer/mode-
testnet/address/0x00C5C0B8e0f75aB862CbAaeCfff499dB555FBDD2)[ReceiveUln302
(0x1d18...)](https://layerzeroscan.com/api/explorer/mode-
testnet/address/0x1d186C560281B8F1AF831957ED5047fD3AB902F9)[SendUln301
(0xF019...)](https://layerzeroscan.com/api/explorer/mode-
testnet/address/0xF0196DEa83b47244222B315AbbbcF6b9fD2F705c)[ReceiveUln301
(0xa78A...)](https://layerzeroscan.com/api/explorer/mode-
testnet/address/0xa78A78a13074eD93aD447a26Ec57121f29E8feC2)[LZ Executor
(0x9dB9...)](https://layerzeroscan.com/api/explorer/mode-
testnet/address/0x9dB9Ca3305B48F196D18082e91cB64663b13d014)  
![](https://icons-ckg.pages.dev/lz-scan/networks/moonbase.svg)Moonbase Alpha
Testnet| 40126| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/moonbase/address/0x6EDCE65403992e310A62460808c4b910D972f10f)|
[SendUln302
(0x4CC5...)](https://layerzeroscan.com/api/explorer/moonbase/address/0x4CC50568EdC84101097E06bCf736918f637e6aB7)[ReceiveUln302
(0x5468...)](https://layerzeroscan.com/api/explorer/moonbase/address/0x5468b60ed00F9b389B5Ba660189862Db058D7dC8)[SendUln301
(0x7155...)](https://layerzeroscan.com/api/explorer/moonbase/address/0x7155A274c055a9D74C83f8cA13660781643062D4)[ReceiveUln301
(0xC192...)](https://layerzeroscan.com/api/explorer/moonbase/address/0xC192220C8bb485b46132EA9b17Eb5B2A552E2324)[LZ
Executor
(0xd10f...)](https://layerzeroscan.com/api/explorer/moonbase/address/0xd10fe0817Ebb477Bc05Df7d503dE9d022B6B0831)  
![](https://icons-ckg.pages.dev/lz-scan/networks/moonbeam.svg)Moonbeam
Mainnet| 30126| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/moonbeam/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xeac1...)](https://layerzeroscan.com/api/explorer/moonbeam/address/0xeac136456d078bB76f59DCcb2d5E008b31AfE1cF)[ReceiveUln302
(0x2F4C...)](https://layerzeroscan.com/api/explorer/moonbeam/address/0x2F4C6eeA955e95e6d65E08620D980C0e0e92211F)[SendUln301
(0xa62A...)](https://layerzeroscan.com/api/explorer/moonbeam/address/0xa62ACEff16b515e5B37e3D3bccE5a6fF8178aA84)[ReceiveUln301
(0xeb2C...)](https://layerzeroscan.com/api/explorer/moonbeam/address/0xeb2C36446b9A08634BaA970AEBf8888762d24beF)[LZ
Executor
(0xEC09...)](https://layerzeroscan.com/api/explorer/moonbeam/address/0xEC0906949f88f72bF9206E84764163e24a56a499)  
![](https://icons-ckg.pages.dev/lz-scan/networks/moonriver.svg)Moonriver
Mainnet| 30167| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/moonriver/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x1BAc...)](https://layerzeroscan.com/api/explorer/moonriver/address/0x1BAcC2205312534375c8d1801C27D28370656cFf)[ReceiveUln302
(0xe8BA...)](https://layerzeroscan.com/api/explorer/moonriver/address/0xe8BAa65CeD8E46DA43520375Af6fAbC31D7bCb8B)[SendUln301
(0xB81F...)](https://layerzeroscan.com/api/explorer/moonriver/address/0xB81F326b95e79eaC4aba800Ae545efb4C602973D)[ReceiveUln301
(0x982e...)](https://layerzeroscan.com/api/explorer/moonriver/address/0x982e44efBE44f187C3d0edB8f875221aE7E6db1b)[LZ
Executor
(0x1E1E...)](https://layerzeroscan.com/api/explorer/moonriver/address/0x1E1E9A04735B9ca509eF8a46255f5104C10C6e99)  
![](https://icons-ckg.pages.dev/lz-scan/networks/morph-testnet.svg)Morph
TestnetRecently Added!| 40322| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/morph-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/morph-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/morph-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/morph-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/morph-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/morph-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/aurora.svg)Near Aurora
Mainnet| 30211| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/aurora/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x1aCe...)](https://layerzeroscan.com/api/explorer/aurora/address/0x1aCe9DD1BC743aD036eF2D92Af42Ca70A1159df5)[ReceiveUln302
(0x000C...)](https://layerzeroscan.com/api/explorer/aurora/address/0x000CC1A759bC3A15e664Ed5379E321Be5de1c9B6)[SendUln301
(0x148f...)](https://layerzeroscan.com/api/explorer/aurora/address/0x148f693af10ddfaE81cDdb36F4c93B31A90076e1)[ReceiveUln301
(0xF9d2...)](https://layerzeroscan.com/api/explorer/aurora/address/0xF9d24d3AbF64A99C6FcdF19b27eF74B723A6110a)[LZ
Executor
(0xA2b4...)](https://layerzeroscan.com/api/explorer/aurora/address/0xA2b402FFE8dd7460a8b425644B6B9f50667f0A61)  
![](https://icons-ckg.pages.dev/lz-scan/networks/okx-testnet.svg)OKX Testnet|
40155| [EndpointV2 (0x6EDC...)](https://layerzeroscan.com/api/explorer/okx-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4eb3...)](https://layerzeroscan.com/api/explorer/okx-
testnet/address/0x4eb38E1743669C6753C44A58B2F11E0c592183eD)[ReceiveUln302
(0xaaed...)](https://layerzeroscan.com/api/explorer/okx-
testnet/address/0xaaed103E18acf972b9b68743E3d4bDeBb9Ce5E5b)[SendUln301
(0x9eC6...)](https://layerzeroscan.com/api/explorer/okx-
testnet/address/0x9eC6D9cCF05B94D4A45b0968248CA5CdF35DDBfD)[ReceiveUln301
(0xF661...)](https://layerzeroscan.com/api/explorer/okx-
testnet/address/0xF66187d9C1E80A7CC22B226F439d51446a044972)[LZ Executor
(0x826b...)](https://layerzeroscan.com/api/explorer/okx-
testnet/address/0x826b93439CB1d53467566d04A9Ddc03F73614e59)  
![](https://icons-ckg.pages.dev/lz-scan/networks/okx.svg)OKXChain Mainnet|
30155| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/okx/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x7807...)](https://layerzeroscan.com/api/explorer/okx/address/0x7807888fAC5c6f23F6EeFef0E6987DF5449C1BEb)[ReceiveUln302
(0x51Ae...)](https://layerzeroscan.com/api/explorer/okx/address/0x51Ae634318E7191C7ffc5778E2D9f860e1e60361)[SendUln301
(0xA27A...)](https://layerzeroscan.com/api/explorer/okx/address/0xA27A2cA24DD28Ce14Fb5f5844b59851F03DCf182)[ReceiveUln301
(0xACbD...)](https://layerzeroscan.com/api/explorer/okx/address/0xACbD57daAafb7D9798992A7b0382fc67d3E316f3)[LZ
Executor
(0x1658...)](https://layerzeroscan.com/api/explorer/okx/address/0x1658766898B42547297A429a51FDea03BC4a863F)  
![](https://icons-ckg.pages.dev/lz-scan/networks/olive-testnet.svg)Olive
Testnet| 40277| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/olive-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/olive-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/olive-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/olive-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/olive-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x1252...)](https://layerzeroscan.com/api/explorer/olive-
testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/opencampus-
testnet.svg)Opencampus Testnet| 40297| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/opencampus-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/opencampus-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/opencampus-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/opencampus-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/opencampus-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/opencampus-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism.svg)Optimism
Mainnet| 30111| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/optimism/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x1322...)](https://layerzeroscan.com/api/explorer/optimism/address/0x1322871e4ab09Bc7f5717189434f97bBD9546e95)[ReceiveUln302
(0x3c49...)](https://layerzeroscan.com/api/explorer/optimism/address/0x3c4962Ff6258dcfCafD23a814237B7d6Eb712063)[SendUln301
(0x3823...)](https://layerzeroscan.com/api/explorer/optimism/address/0x3823094993190Fbb3bFABfEC8365b8C18517566F)[ReceiveUln301
(0x6C9A...)](https://layerzeroscan.com/api/explorer/optimism/address/0x6C9AE31DFB56699d6bD553146f653DCEC3b174Fe)[LZ
Executor
(0x2D2e...)](https://layerzeroscan.com/api/explorer/optimism/address/0x2D2ea0697bdbede3F01553D2Ae4B8d0c486B666e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/optimism-sepolia.svg)Optimism
Sepolia| 40232| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/optimism-
sepolia/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xB31D...)](https://layerzeroscan.com/api/explorer/optimism-
sepolia/address/0xB31D2cb502E25B30C651842C7C3293c51Fe6d16f)[ReceiveUln302
(0x9284...)](https://layerzeroscan.com/api/explorer/optimism-
sepolia/address/0x9284fd59B95b9143AF0b9795CAC16eb3C723C9Ca)[SendUln301
(0xFe93...)](https://layerzeroscan.com/api/explorer/optimism-
sepolia/address/0xFe9335A931e2262009a73842001a6F91ef7B6778)[ReceiveUln301
(0x4206...)](https://layerzeroscan.com/api/explorer/optimism-
sepolia/address/0x420667429538adBF982aDa16C268ba561f097F74)[LZ Executor
(0xDc0D...)](https://layerzeroscan.com/api/explorer/optimism-
sepolia/address/0xDc0D68899405673b932F0DB7f8A49191491A5bcB)  
![](https://icons-ckg.pages.dev/lz-scan/networks/orderly.svg)Orderly Mainnet|
30213| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/orderly/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x5B23...)](https://layerzeroscan.com/api/explorer/orderly/address/0x5B23E2bAe5C5f00e804EA2C4C9abe601604378fa)[ReceiveUln302
(0xCFf0...)](https://layerzeroscan.com/api/explorer/orderly/address/0xCFf08a35A5f27F306e2DA99ff198dB90f13DEF77)[SendUln301
(0xF622...)](https://layerzeroscan.com/api/explorer/orderly/address/0xF622DFb40bf7340DBCf1e5147D6CFD95d7c5cF1F)[ReceiveUln301
(0x6167...)](https://layerzeroscan.com/api/explorer/orderly/address/0x6167caAb5c3DA63311186db4D4E2596B20f557ec)[LZ
Executor
(0x1aCe...)](https://layerzeroscan.com/api/explorer/orderly/address/0x1aCe9DD1BC743aD036eF2D92Af42Ca70A1159df5)  
![](https://icons-ckg.pages.dev/lz-scan/networks/orderly-testnet.svg)Orderly
Sepolia Testnet| 40200| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/orderly-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x8e3D...)](https://layerzeroscan.com/api/explorer/orderly-
testnet/address/0x8e3Dc55b7A1f7Fe4ce328A1c90dC1B935a30Cc42)[ReceiveUln302
(0x3013...)](https://layerzeroscan.com/api/explorer/orderly-
testnet/address/0x3013C32e5F45E69ceA9baD4d96786704C2aE148c)[SendUln301
(0xD528...)](https://layerzeroscan.com/api/explorer/orderly-
testnet/address/0xD528e5146a084DA4dc29B5De74434C5BC0d17FA7)[ReceiveUln301
(0xcdF2...)](https://layerzeroscan.com/api/explorer/orderly-
testnet/address/0xcdF2186AC463Ae7c97803cF6bBA5276084AB0a72)[LZ Executor
(0x1e56...)](https://layerzeroscan.com/api/explorer/orderly-
testnet/address/0x1e567E344B2d990D2ECDFa4e14A1c9a1Beb83e96)  
![](https://icons-ckg.pages.dev/lz-scan/networks/otherworld-
testnet.svg)Otherworld Testnet| 40312| [EndpointV2
(0x4584...)](https://layerzeroscan.com/api/explorer/otherworld-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)| [SendUln302
(0x53fd...)](https://layerzeroscan.com/api/explorer/otherworld-
testnet/address/0x53fd4C4fBBd53F6bC58CaE6704b92dB1f360A648)[ReceiveUln302
(0x9eCf...)](https://layerzeroscan.com/api/explorer/otherworld-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[SendUln301
(0xe1a1...)](https://layerzeroscan.com/api/explorer/otherworld-
testnet/address/0xe1a12515F9AB2764b887bF60B923Ca494EBbB2d6)[ReceiveUln301
(0x4dFa...)](https://layerzeroscan.com/api/explorer/otherworld-
testnet/address/0x4dFa426aEAA55E6044d2b47682842460a04aF45c)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/otherworld-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/ozean-testnet.svg)Ozean
TestnetRecently Added!| 40323| [EndpointV2
(0x145C...)](https://layerzeroscan.com/api/explorer/ozean-
testnet/address/0x145C041566B21Bec558B2A37F1a5Ff261aB55998)| [SendUln302
(0x1d18...)](https://layerzeroscan.com/api/explorer/ozean-
testnet/address/0x1d186C560281B8F1AF831957ED5047fD3AB902F9)[ReceiveUln302
(0x53fd...)](https://layerzeroscan.com/api/explorer/ozean-
testnet/address/0x53fd4C4fBBd53F6bC58CaE6704b92dB1f360A648)[SendUln301
(0xa78A...)](https://layerzeroscan.com/api/explorer/ozean-
testnet/address/0xa78A78a13074eD93aD447a26Ec57121f29E8feC2)[ReceiveUln301
(0x88B2...)](https://layerzeroscan.com/api/explorer/ozean-
testnet/address/0x88B27057A9e00c5F05DDa29241027afF63f9e6e0)[LZ Executor
(0xe1a1...)](https://layerzeroscan.com/api/explorer/ozean-
testnet/address/0xe1a12515F9AB2764b887bF60B923Ca494EBbB2d6)  
![](https://icons-ckg.pages.dev/lz-scan/networks/peaq.svg)Peaq Mainnet| 30302|
[EndpointV2
(0x6F47...)](https://layerzeroscan.com/api/explorer/peaq/address/0x6F475642a6e85809B1c36Fa62763669b1b48DD5B)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/peaq/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/peaq/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/peaq/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/peaq/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/peaq/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/peaq-testnet.svg)Peaq
Testnet| 40299| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/peaq-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/peaq-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/peaq-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/peaq-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/peaq-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/peaq-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/amoy-testnet.svg)Polygon Amoy
Testnet| 40267| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/amoy-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x1d18...)](https://layerzeroscan.com/api/explorer/amoy-
testnet/address/0x1d186C560281B8F1AF831957ED5047fD3AB902F9)[ReceiveUln302
(0x53fd...)](https://layerzeroscan.com/api/explorer/amoy-
testnet/address/0x53fd4C4fBBd53F6bC58CaE6704b92dB1f360A648)[SendUln301
(0xa78A...)](https://layerzeroscan.com/api/explorer/amoy-
testnet/address/0xa78A78a13074eD93aD447a26Ec57121f29E8feC2)[ReceiveUln301
(0x88B2...)](https://layerzeroscan.com/api/explorer/amoy-
testnet/address/0x88B27057A9e00c5F05DDa29241027afF63f9e6e0)[LZ Executor
(0x4Cf1...)](https://layerzeroscan.com/api/explorer/amoy-
testnet/address/0x4Cf1B3Fa61465c2c907f82fC488B43223BA0CF93)  
![](https://icons-ckg.pages.dev/lz-scan/networks/polygon.svg)Polygon Mainnet|
30109| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/polygon/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x6c26...)](https://layerzeroscan.com/api/explorer/polygon/address/0x6c26c61a97006888ea9E4FA36584c7df57Cd9dA3)[ReceiveUln302
(0x1322...)](https://layerzeroscan.com/api/explorer/polygon/address/0x1322871e4ab09Bc7f5717189434f97bBD9546e95)[SendUln301
(0x5727...)](https://layerzeroscan.com/api/explorer/polygon/address/0x5727E81A40015961145330D91cC27b5E189fF3e1)[ReceiveUln301
(0x3823...)](https://layerzeroscan.com/api/explorer/polygon/address/0x3823094993190Fbb3bFABfEC8365b8C18517566F)[LZ
Executor
(0xCd3F...)](https://layerzeroscan.com/api/explorer/polygon/address/0xCd3F213AD101472e1713C72B1697E727C803885b)  
![](https://icons-ckg.pages.dev/lz-scan/networks/zkevm.svg)Polygon zkEVM
Mainnet| 30158| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/zkevm/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x28B6...)](https://layerzeroscan.com/api/explorer/zkevm/address/0x28B6140ead70cb2Fb669705b3598ffB4BEaA060b)[ReceiveUln302
(0x581b...)](https://layerzeroscan.com/api/explorer/zkevm/address/0x581b26F362AD383f7B51eF8A165Efa13DDe398a4)[SendUln301
(0x8161...)](https://layerzeroscan.com/api/explorer/zkevm/address/0x8161B3B224Cd6ce37cC20BE61607C3E19eC2A8A6)[ReceiveUln301
(0x23ec...)](https://layerzeroscan.com/api/explorer/zkevm/address/0x23ec43e2b8f9aE21D895eEa5a1a9c444fe301044)[LZ
Executor
(0xbE4f...)](https://layerzeroscan.com/api/explorer/zkevm/address/0xbE4fB271cfB7bcbB47EA9573321c7bfe309fc220)  
![](https://icons-ckg.pages.dev/lz-scan/networks/zkpolygon-sepolia.svg)Polygon
zkEVM Sepolia Testnet| 40247| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/zkpolygon-
sepolia/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x88B2...)](https://layerzeroscan.com/api/explorer/zkpolygon-
sepolia/address/0x88B27057A9e00c5F05DDa29241027afF63f9e6e0)[ReceiveUln302
(0xF49d...)](https://layerzeroscan.com/api/explorer/zkpolygon-
sepolia/address/0xF49d162484290EAeAd7bb8C2c7E3a6f8f52e32d6)[SendUln301
(0xd682...)](https://layerzeroscan.com/api/explorer/zkpolygon-
sepolia/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln301
(0xcF1B...)](https://layerzeroscan.com/api/explorer/zkpolygon-
sepolia/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[LZ Executor
(0x9dB9...)](https://layerzeroscan.com/api/explorer/zkpolygon-
sepolia/address/0x9dB9Ca3305B48F196D18082e91cB64663b13d014)  
![](https://icons-ckg.pages.dev/lz-scan/networks/rarible.svg)Rari Chain|
30235| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/rarible/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xA09d...)](https://layerzeroscan.com/api/explorer/rarible/address/0xA09dB5142654e3eB5Cf547D66833FAe7097B21C3)[ReceiveUln302
(0x148f...)](https://layerzeroscan.com/api/explorer/rarible/address/0x148f693af10ddfaE81cDdb36F4c93B31A90076e1)[SendUln301
(0xD4a9...)](https://layerzeroscan.com/api/explorer/rarible/address/0xD4a903930f2c9085586cda0b11D9681EECb20D2f)[ReceiveUln301
(0xb21f...)](https://layerzeroscan.com/api/explorer/rarible/address/0xb21f945e8917c6Cd69FcFE66ac6703B90f7fe004)[LZ
Executor
(0x1E4C...)](https://layerzeroscan.com/api/explorer/rarible/address/0x1E4CAc6c2c955cAED779ef24d5B8C5EE90b1f914)  
![](https://icons-ckg.pages.dev/lz-scan/networks/rarible-testnet.svg)Rarible
Testnet| 40235| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/rarible-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x7C42...)](https://layerzeroscan.com/api/explorer/rarible-
testnet/address/0x7C424244B51d03cEEc115647ccE151baF112a42e)[ReceiveUln302
(0xbf06...)](https://layerzeroscan.com/api/explorer/rarible-
testnet/address/0xbf06c8886E6904a95dD42440Bd237C4ac64940C8)[SendUln301
(0xC08D...)](https://layerzeroscan.com/api/explorer/rarible-
testnet/address/0xC08DFdD85E8530420694dA94E34f52C7462cCe7d)[ReceiveUln301
(0x7983...)](https://layerzeroscan.com/api/explorer/rarible-
testnet/address/0x7983dCA4B0E322b0B80AFBb01F1F904A0532FcB6)[LZ Executor
(0x19DC...)](https://layerzeroscan.com/api/explorer/rarible-
testnet/address/0x19DC7b94ACAFbAD3EFa1Bc782d1367a8b173Ba73)  
![](https://icons-ckg.pages.dev/lz-scan/networks/reya.svg)Reya MainnetRecently
Added!| 30313| [EndpointV2
(0x6F47...)](https://layerzeroscan.com/api/explorer/reya/address/0x6F475642a6e85809B1c36Fa62763669b1b48DD5B)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/reya/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/reya/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/reya/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/reya/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/reya/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/reya-testnet.svg)Reya
Testnet| 40319| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/reya-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/reya-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/reya-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/reya-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/reya-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/reya-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/root-testnet.svg)Root
Testnet| 40318| [EndpointV2
(0xbc2a...)](https://layerzeroscan.com/api/explorer/root-
testnet/address/0xbc2a00d907a6Aa5226Fb9444953E4464a5f4844a)| [SendUln302
(0x6460...)](https://layerzeroscan.com/api/explorer/root-
testnet/address/0x6460EE1b9D5bDE8375ca928767Cc63FBFA111A98)[ReceiveUln302
(0x72ee...)](https://layerzeroscan.com/api/explorer/root-
testnet/address/0x72eeA17eBbd1aCE0527354b2f7b25c6efC27936d)[SendUln301
(0x19D1...)](https://layerzeroscan.com/api/explorer/root-
testnet/address/0x19D1198b0f43Ec076a897bF98dEb0FD1D6CE8B9f)[ReceiveUln301
(0x0E91...)](https://layerzeroscan.com/api/explorer/root-
testnet/address/0x0E91e0239971B6CF7519e458a742e2eA4Ffb7458)[LZ Executor
(0xe729...)](https://layerzeroscan.com/api/explorer/root-
testnet/address/0xe7292d7797776bCcDF44C78f296Ff26Ddb70F70a)  
![](https://icons-ckg.pages.dev/lz-scan/networks/sanko.svg)Sanko Mainnet|
30278| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/sanko/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/sanko/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/sanko/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/sanko/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/sanko/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xc097...)](https://layerzeroscan.com/api/explorer/sanko/address/0xc097ab8CD7b053326DFe9fB3E3a31a0CCe3B526f)  
![](https://icons-ckg.pages.dev/lz-scan/networks/sanko-testnet.svg)Sanko
Testnet| 40278| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/sanko-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/sanko-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/sanko-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/sanko-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/sanko-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x1252...)](https://layerzeroscan.com/api/explorer/sanko-
testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/scroll.svg)Scroll Mainnet|
30214| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/scroll/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x9BbE...)](https://layerzeroscan.com/api/explorer/scroll/address/0x9BbEb2B2184B9313Cf5ed4a4DDFEa2ef62a2a03B)[ReceiveUln302
(0x8363...)](https://layerzeroscan.com/api/explorer/scroll/address/0x8363302080e711E0CAb978C081b9e69308d49808)[SendUln301
(0xdf3a...)](https://layerzeroscan.com/api/explorer/scroll/address/0xdf3ad32a558578AC0AD1c19AAD41DA1ba5b37d69)[ReceiveUln301
(0xE4b4...)](https://layerzeroscan.com/api/explorer/scroll/address/0xE4b45f3744eF05668b22Fcf05Fb19fF4A75d3219)[LZ
Executor
(0x581b...)](https://layerzeroscan.com/api/explorer/scroll/address/0x581b26F362AD383f7B51eF8A165Efa13DDe398a4)  
![](https://icons-ckg.pages.dev/lz-scan/networks/scroll-testnet.svg)Scroll
Sepolia Testnet| 40170| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/scroll-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x21f1...)](https://layerzeroscan.com/api/explorer/scroll-
testnet/address/0x21f1C2B131557c3AebA918D590815c47Dc4F20aa)[ReceiveUln302
(0xf2dB...)](https://layerzeroscan.com/api/explorer/scroll-
testnet/address/0xf2dB23f9eA1311E9ED44E742dbc4268de4dB0a88)[SendUln301
(0x674a...)](https://layerzeroscan.com/api/explorer/scroll-
testnet/address/0x674a6B84dDd9AdCE8E9EAc120BDb6185e1eEdBa8)[ReceiveUln301
(0x13EA...)](https://layerzeroscan.com/api/explorer/scroll-
testnet/address/0x13EA72039D7f02848CDDd67a2F948dd334cDE70e)[LZ Executor
(0xD0D4...)](https://layerzeroscan.com/api/explorer/scroll-
testnet/address/0xD0D47C34937DdbeBBe698267a6BbB1dacE51198D)  
![](https://icons-ckg.pages.dev/lz-scan/networks/sei.svg)Sei Mainnet| 30280|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/sei/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/sei/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/sei/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/sei/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/sei/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xc097...)](https://layerzeroscan.com/api/explorer/sei/address/0xc097ab8CD7b053326DFe9fB3E3a31a0CCe3B526f)  
![](https://icons-ckg.pages.dev/lz-scan/networks/sei-testnet.svg)Sei Testnet|
40258| [EndpointV2 (0x6EDC...)](https://layerzeroscan.com/api/explorer/sei-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/sei-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/sei-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/sei-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/sei-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x55c1...)](https://layerzeroscan.com/api/explorer/sei-
testnet/address/0x55c175DD5b039331dB251424538169D8495C18d1)  
![](https://icons-ckg.pages.dev/lz-scan/networks/shimmer.svg)Shimmer Mainnet|
30230| [EndpointV2
(0x148f...)](https://layerzeroscan.com/api/explorer/shimmer/address/0x148f693af10ddfaE81cDdb36F4c93B31A90076e1)|
[SendUln302
(0xD4a9...)](https://layerzeroscan.com/api/explorer/shimmer/address/0xD4a903930f2c9085586cda0b11D9681EECb20D2f)[ReceiveUln302
(0xb21f...)](https://layerzeroscan.com/api/explorer/shimmer/address/0xb21f945e8917c6Cd69FcFE66ac6703B90f7fe004)[SendUln301
(0x6c73...)](https://layerzeroscan.com/api/explorer/shimmer/address/0x6c73c7A416d96d9C6Fa57671aa1ed7eD0FDF5127)[ReceiveUln301
(0x1E4C...)](https://layerzeroscan.com/api/explorer/shimmer/address/0x1E4CAc6c2c955cAED779ef24d5B8C5EE90b1f914)[LZ
Executor
(0x868a...)](https://layerzeroscan.com/api/explorer/shimmer/address/0x868a44F9d9F09331da425539a174a2128b85D672)  
cautionShimmer, while being EVM-like, uses a different approach to gas token
decimals, which could lead to specific implementations and adjustments in your
gas calculations and transactions.  
![](https://icons-ckg.pages.dev/lz-scan/networks/skale.svg)Skale Mainnet|
30273| [EndpointV2
(0xe184...)](https://layerzeroscan.com/api/explorer/skale/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)|
[SendUln302
(0x37aa...)](https://layerzeroscan.com/api/explorer/skale/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln302
(0x15e5...)](https://layerzeroscan.com/api/explorer/skale/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[SendUln301
(0x2BF2...)](https://layerzeroscan.com/api/explorer/skale/address/0x2BF2f59d2E318Bb03C8956E7BC4c3E6c28Bd0fC2)[ReceiveUln301
(0x6b38...)](https://layerzeroscan.com/api/explorer/skale/address/0x6b383D6a7e5a151b189147F4c9f39bF57B29548f)[LZ
Executor
(0x4208...)](https://layerzeroscan.com/api/explorer/skale/address/0x4208D6E27538189bB48E603D6123A94b8Abe0A0b)  
cautionThe Skale Endpoint uses an alternative ERC20 token instead of the
native gas token for omnichain fees. You will need to modify your _payNative()
function in OApp to handle ERC20 fees (see OFTAlt).  
![](https://icons-ckg.pages.dev/lz-scan/networks/skale-testnet.svg)Skale
Testnet| 40273| [EndpointV2
(0x82b7...)](https://layerzeroscan.com/api/explorer/skale-
testnet/address/0x82b7dc04A4ABCF2b4aE570F317dcab49f5a10f24)| [SendUln302
(0x4632...)](https://layerzeroscan.com/api/explorer/skale-
testnet/address/0x4632b54146C45Cf31EE1d5A1191260Af7e9DB801)[ReceiveUln302
(0x9D0A...)](https://layerzeroscan.com/api/explorer/skale-
testnet/address/0x9D0A659cAC5F122e22bAaDD8769a3abc05C6bdAE)[SendUln301
(0x8f33...)](https://layerzeroscan.com/api/explorer/skale-
testnet/address/0x8f337D230a5088E2a448515Eab263735181A9039)[ReceiveUln301
(0x613c...)](https://layerzeroscan.com/api/explorer/skale-
testnet/address/0x613c830Ee98448389139afDae4baD61eAe82D3C0)[LZ Executor
(0x86d0...)](https://layerzeroscan.com/api/explorer/skale-
testnet/address/0x86d08462EaA1559345d7F41f937B2C804209DB8A)  
cautionThe Skale Endpoint uses an alternative ERC20 token instead of the
native gas token for omnichain fees. You will need to modify your _payNative()
function in OApp to handle ERC20 fees (see OFTAlt).  
![](https://icons-ckg.pages.dev/lz-scan/networks/solana.svg)Solana Mainnet|
30168| [EndpointV2
(76y77p...)](https://layerzeroscan.com/api/explorer/solana/address/76y77prsiCMvXMjuoZ5VRrhG5qYBrUMYTE5WgHqgjEn6)|
[SendUln302
(7a4Wjy...)](https://layerzeroscan.com/api/explorer/solana/address/7a4WjyR8VZ7yZz5XJAKm39BUGn5iT9CKcv2pmG9tdXVH)[ReceiveUln302
(7a4Wjy...)](https://layerzeroscan.com/api/explorer/solana/address/7a4WjyR8VZ7yZz5XJAKm39BUGn5iT9CKcv2pmG9tdXVH)[LZ
Executor
(6doghB...)](https://layerzeroscan.com/api/explorer/solana/address/6doghB248px58JSSwG4qejQ46kFMW4AMj7vzJnWZHNZn)  
![](https://icons-ckg.pages.dev/lz-scan/networks/solana-testnet.svg)Solana
Testnet| 40168| [EndpointV2
(76y77p...)](https://layerzeroscan.com/api/explorer/solana-
testnet/address/76y77prsiCMvXMjuoZ5VRrhG5qYBrUMYTE5WgHqgjEn6)| [SendUln302
(7a4Wjy...)](https://layerzeroscan.com/api/explorer/solana-
testnet/address/7a4WjyR8VZ7yZz5XJAKm39BUGn5iT9CKcv2pmG9tdXVH)[ReceiveUln302
(7a4Wjy...)](https://layerzeroscan.com/api/explorer/solana-
testnet/address/7a4WjyR8VZ7yZz5XJAKm39BUGn5iT9CKcv2pmG9tdXVH)[LZ Executor
(6doghB...)](https://layerzeroscan.com/api/explorer/solana-
testnet/address/6doghB248px58JSSwG4qejQ46kFMW4AMj7vzJnWZHNZn)  
cautionThe LayerZero Solana Testnet Endpoint is actually deployed on Solana
Devnet  
![](https://icons-ckg.pages.dev/lz-scan/networks/story-testnet.svg)Story
Testnet| 40315| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/story-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/story-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/story-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/story-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/story-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/story-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/taiko.svg)Taiko Mainnet|
30290| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/taiko/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xc1B6...)](https://layerzeroscan.com/api/explorer/taiko/address/0xc1B621b18187F74c8F6D52a6F709Dd2780C09821)[ReceiveUln302
(0x3775...)](https://layerzeroscan.com/api/explorer/taiko/address/0x377530cdA84DFb2673bF4d145DCF0C4D7fdcB5b6)[SendUln301
(0x7cac...)](https://layerzeroscan.com/api/explorer/taiko/address/0x7cacBe439EaD55fa1c22790330b12835c6884a91)[ReceiveUln301
(0x282b...)](https://layerzeroscan.com/api/explorer/taiko/address/0x282b3386571f7f794450d5789911a9804FA346b4)[LZ
Executor
(0xa20D...)](https://layerzeroscan.com/api/explorer/taiko/address/0xa20DB4Ffe74A31D17fc24BD32a7DD7555441058e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/taiko-testnet.svg)Taiko
Testnet| 40274| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/taiko-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/taiko-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/taiko-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/taiko-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/taiko-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x1252...)](https://layerzeroscan.com/api/explorer/taiko-
testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/tangible-testnet.svg)Tangible
Testnet| 40252| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/tangible-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x6Ac7...)](https://layerzeroscan.com/api/explorer/tangible-
testnet/address/0x6Ac7bdc07A0583A362F1497252872AE6c0A5F5B8)[ReceiveUln302
(0x145C...)](https://layerzeroscan.com/api/explorer/tangible-
testnet/address/0x145C041566B21Bec558B2A37F1a5Ff261aB55998)[SendUln301
(0x1d18...)](https://layerzeroscan.com/api/explorer/tangible-
testnet/address/0x1d186C560281B8F1AF831957ED5047fD3AB902F9)[ReceiveUln301
(0x53fd...)](https://layerzeroscan.com/api/explorer/tangible-
testnet/address/0x53fd4C4fBBd53F6bC58CaE6704b92dB1f360A648)[LZ Executor
(0xF49d...)](https://layerzeroscan.com/api/explorer/tangible-
testnet/address/0xF49d162484290EAeAd7bb8C2c7E3a6f8f52e32d6)  
![](https://icons-ckg.pages.dev/lz-scan/networks/telos-testnet.svg)Telos EVM
Testnet| 40199| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/telos-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4628...)](https://layerzeroscan.com/api/explorer/telos-
testnet/address/0x4628040135EF85759594290F0877aB93B660ac8b)[ReceiveUln302
(0x9Fc5...)](https://layerzeroscan.com/api/explorer/telos-
testnet/address/0x9Fc55169a8B47EDCE891942565De00DBd50B3C2E)[SendUln301
(0x1B39...)](https://layerzeroscan.com/api/explorer/telos-
testnet/address/0x1B39173A8198fB51dC1E1733bbbe21784505cD8c)[ReceiveUln301
(0x3793...)](https://layerzeroscan.com/api/explorer/telos-
testnet/address/0x3793DC3e532A3061e01bC0426DBDe195ACD5F591)[LZ Executor
(0x9Ed8...)](https://layerzeroscan.com/api/explorer/telos-
testnet/address/0x9Ed8C430B96ae6FDdDb542DDa4eF6f53E919eBdD)  
![](https://icons-ckg.pages.dev/lz-scan/networks/telos.svg)TelosEVM Mainnet|
30199| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/telos/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x0BcA...)](https://layerzeroscan.com/api/explorer/telos/address/0x0BcAC336466ef7F1e0b5c184aAB2867C108331aF)[ReceiveUln302
(0x8F76...)](https://layerzeroscan.com/api/explorer/telos/address/0x8F76bAcC52b5730c1f1A2413B8936D4df12aF4f6)[SendUln301
(0xdCD9...)](https://layerzeroscan.com/api/explorer/telos/address/0xdCD9fd7EabCD0fC90300984Fc1Ccb67b5BF3DA36)[ReceiveUln301
(0x07Dd...)](https://layerzeroscan.com/api/explorer/telos/address/0x07Dd1bf9F684D81f59B6a6760438d383ad755355)[LZ
Executor
(0x1785...)](https://layerzeroscan.com/api/explorer/telos/address/0x1785c94d31E3E3Ab1079e7ca8a9fbDf33EEf9dd5)  
![](https://icons-ckg.pages.dev/lz-scan/networks/tenet.svg)Tenet Mainnet|
30173| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/tenet/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x1785...)](https://layerzeroscan.com/api/explorer/tenet/address/0x1785c94d31E3E3Ab1079e7ca8a9fbDf33EEf9dd5)[ReceiveUln302
(0x1690...)](https://layerzeroscan.com/api/explorer/tenet/address/0x16909F77E57CDaaB7BE0fbDF12b6A77d99541605)[SendUln301
(0x187d...)](https://layerzeroscan.com/api/explorer/tenet/address/0x187d4dca18652677428D6A9B1978945a0b978631)[ReceiveUln301
(0x75dC...)](https://layerzeroscan.com/api/explorer/tenet/address/0x75dC8e5F50C8221a82CA6aF64aF811caA983B65f)[LZ
Executor
(0xB125...)](https://layerzeroscan.com/api/explorer/tenet/address/0xB12514e226E50844E4655696c92c0c36B8A53141)  
![](https://icons-ckg.pages.dev/lz-scan/networks/tenet-testnet.svg)Tenet
Testnet| 40173| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/tenet-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x2CAD...)](https://layerzeroscan.com/api/explorer/tenet-
testnet/address/0x2CAD3483690a95d10eeADFb7A79C212050BF5a23)[ReceiveUln302
(0xBaf9...)](https://layerzeroscan.com/api/explorer/tenet-
testnet/address/0xBaf97EC0E26b7879850c8682AdB723670C6133AF)[SendUln301
(0x74e5...)](https://layerzeroscan.com/api/explorer/tenet-
testnet/address/0x74e5399dc64Eb3Cf403fcC19DB0aF16Cd61Ba0D8)[ReceiveUln301
(0x0a3F...)](https://layerzeroscan.com/api/explorer/tenet-
testnet/address/0x0a3FcF92598bB8d9810951F0826FffA17bDc2308)[LZ Executor
(0xdfF5...)](https://layerzeroscan.com/api/explorer/tenet-
testnet/address/0xdfF535e7F030E4aA69CcC7E4a8404648e872E220)  
![](https://icons-ckg.pages.dev/lz-scan/networks/tiltyard.svg)Tiltyard| 30238|
[EndpointV2
(0x3A73...)](https://layerzeroscan.com/api/explorer/tiltyard/address/0x3A73033C0b1407574C76BdBAc67f126f6b4a9AA9)|
[SendUln302
(0x62d1...)](https://layerzeroscan.com/api/explorer/tiltyard/address/0x62d142E186344C0a2445c822e356E87faF7b8288)[ReceiveUln302
(0xd83B...)](https://layerzeroscan.com/api/explorer/tiltyard/address/0xd83B25f4Ff6C596380c36C7eD10c225d6B17Dfd7)[SendUln301
(0x8aE1...)](https://layerzeroscan.com/api/explorer/tiltyard/address/0x8aE19609FAf6343F4f6127eBA5504fa57276BC9a)[ReceiveUln301
(0x841c...)](https://layerzeroscan.com/api/explorer/tiltyard/address/0x841c5462d65Bf3Bc921b7bF2d728B7fE9d6831e7)[LZ
Executor
(0xEF77...)](https://layerzeroscan.com/api/explorer/tiltyard/address/0xEF7781FC1C4F7B2Fd3Cf03f4d65b6835b27C1A0d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/treasure-testnet.svg)Treasure
Testnet| 40316| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/treasure-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/treasure-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/treasure-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/treasure-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/treasure-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/treasure-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/tron.svg)Tron Mainnet| 30420|
[EndpointV2
(0x0Af5...)](https://layerzeroscan.com/api/explorer/tron/address/0x0Af59750D5dB5460E5d89E268C474d5F7407c061)|
[SendUln302
(0xE369...)](https://layerzeroscan.com/api/explorer/tron/address/0xE369D146219380B24Bb5D9B9E08a5b9936F9E719)[ReceiveUln302
(0x6122...)](https://layerzeroscan.com/api/explorer/tron/address/0x612215D4dB0475a76dCAa36C7f9afD748c42ed2D)[SendUln301
(0xa347...)](https://layerzeroscan.com/api/explorer/tron/address/0xa347fFf5Db6b65939BB65A3436654cB5fbd57646)[ReceiveUln301
(0xF077...)](https://layerzeroscan.com/api/explorer/tron/address/0xF077BeAF66862e6b014003E98A2f85c3429879a1)[LZ
Executor
(0x67DE...)](https://layerzeroscan.com/api/explorer/tron/address/0x67DE40af19C0C0a6D0278d96911889fAF4EBc1Bc)  
cautionTRX, the native token of Tron, uses 6 decimals, which affects how
transactions and gas fees are calculated and can require specific handling in
smart contracts and dApps.  
![](https://icons-ckg.pages.dev/lz-scan/networks/tron-testnet.svg)Tron
Testnet| 40420| [EndpointV2
(0x1b35...)](https://layerzeroscan.com/api/explorer/tron-
testnet/address/0x1b356f3030CE0c1eF9D3e1E250Bf0BB11D81b2d1)| [SendUln302
(0xaef6...)](https://layerzeroscan.com/api/explorer/tron-
testnet/address/0xaef63752785Ad2104cea1aa42b69b46f2530312F)[ReceiveUln302
(0x8438...)](https://layerzeroscan.com/api/explorer/tron-
testnet/address/0x843810EB9f002E940870a95B366cc59E623bF5f1)[SendUln301
(0xFAd5...)](https://layerzeroscan.com/api/explorer/tron-
testnet/address/0xFAd5e75352Bc694bE1f5f8a6313fc280d37E7905)[ReceiveUln301
(0x52D4...)](https://layerzeroscan.com/api/explorer/tron-
testnet/address/0x52D4be0e5088731839A06Da8659b5D2B979E21F6)[LZ Executor
(0xd9F0...)](https://layerzeroscan.com/api/explorer/tron-
testnet/address/0xd9F0144AC7cED407a12dE2649b560b0a68a59A3D)  
cautionTRX, the native token of Tron, uses 6 decimals, which affects how
transactions and gas fees are calculated and can require specific handling in
smart contracts and dApps.  
![](https://icons-ckg.pages.dev/lz-scan/networks/unichain-testnet.svg)Unichain
TestnetRecently Added!| 40333| [EndpointV2
(0xb881...)](https://layerzeroscan.com/api/explorer/unichain-
testnet/address/0xb8815f3f882614048CbE201a67eF9c6F10fe5035)| [SendUln302
(0x72e3...)](https://layerzeroscan.com/api/explorer/unichain-
testnet/address/0x72e34F44Eb09058bdDaf1aeEebDEC062f1844b00)[ReceiveUln302
(0xbEA3...)](https://layerzeroscan.com/api/explorer/unichain-
testnet/address/0xbEA34F26b6FBA63054e4eD86806adce594A62561)[SendUln301
(0xDDfe...)](https://layerzeroscan.com/api/explorer/unichain-
testnet/address/0xDDfe281aB129eaB0e319C20CD0908cD69100d368)[ReceiveUln301
(0xbfD2...)](https://layerzeroscan.com/api/explorer/unichain-
testnet/address/0xbfD2135BFfbb0B5378b56643c2Df8a87552Bfa23)[LZ Executor
(0x8548...)](https://layerzeroscan.com/api/explorer/unichain-
testnet/address/0x8548b148800BB00C6E4039Aa9C20ebb36a36A600)  
![](https://icons-ckg.pages.dev/lz-scan/networks/unreal-testnet.svg)Unreal
Testnet| 40262| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/unreal-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/unreal-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/unreal-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/unreal-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/unreal-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x55c1...)](https://layerzeroscan.com/api/explorer/unreal-
testnet/address/0x55c175DD5b039331dB251424538169D8495C18d1)  
![](https://icons-ckg.pages.dev/lz-scan/networks/vanguard-testnet.svg)Vanguard
Testnet| 40298| [EndpointV2
(0x6C7A...)](https://layerzeroscan.com/api/explorer/vanguard-
testnet/address/0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/vanguard-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/vanguard-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/vanguard-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/vanguard-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x701f...)](https://layerzeroscan.com/api/explorer/vanguard-
testnet/address/0x701f3927871EfcEa1235dB722f9E608aE120d243)  
![](https://icons-ckg.pages.dev/lz-scan/networks/tomo.svg)Viction Mainnet|
30196| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/tomo/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x6f16...)](https://layerzeroscan.com/api/explorer/tomo/address/0x6f1686189f32e78f1D83e7c6Ed433FCeBc3A5B51)[ReceiveUln302
(0x7004...)](https://layerzeroscan.com/api/explorer/tomo/address/0x7004396C99D5690da76A7C59057C5f3A53e01704)[SendUln301
(0xC1EC...)](https://layerzeroscan.com/api/explorer/tomo/address/0xC1EC25A9e8a8DE5Aa346f635B33e5B74c4c081aF)[ReceiveUln301
(0xB6Ba...)](https://layerzeroscan.com/api/explorer/tomo/address/0xB6BaCA78e430EF1D6D87a23B043bFDd4B5df8B6c)[LZ
Executor
(0x2d24...)](https://layerzeroscan.com/api/explorer/tomo/address/0x2d24207F9C1F77B2E08F2C3aD430da18e355CF66)  
![](https://icons-ckg.pages.dev/lz-scan/networks/tomo-testnet.svg)Viction
Testnet| 40196| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/tomo-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xbB7e...)](https://layerzeroscan.com/api/explorer/tomo-
testnet/address/0xbB7e6FE3fA954BF0e5Ea77d38736C56E8D09514B)[ReceiveUln302
(0x8468...)](https://layerzeroscan.com/api/explorer/tomo-
testnet/address/0x8468689ca62D8806614EEdb9F26a13e1Fddbd6BD)[SendUln301
(0x88E0...)](https://layerzeroscan.com/api/explorer/tomo-
testnet/address/0x88E02546b30A275Cb09630aC545809D76E326021)[ReceiveUln301
(0x48e4...)](https://layerzeroscan.com/api/explorer/tomo-
testnet/address/0x48e4aae2c9f9eF9CcEb0327af35c53Fa716Df9D1)[LZ Executor
(0xe4C9...)](https://layerzeroscan.com/api/explorer/tomo-
testnet/address/0xe4C9F9Fa374273736199bdeB712592cE1a3B4B26)  
![](https://icons-ckg.pages.dev/lz-
scan/networks/worldchain.svg)WorldchainRecently Added!| 30319| [EndpointV2
(0x6F47...)](https://layerzeroscan.com/api/explorer/worldchain/address/0x6F475642a6e85809B1c36Fa62763669b1b48DD5B)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/worldchain/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/worldchain/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/worldchain/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/worldchain/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/worldchain/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/worldcoin-
testnet.svg)Worldcoin TestnetRecently Added!| 40335| [EndpointV2
(0x145C...)](https://layerzeroscan.com/api/explorer/worldcoin-
testnet/address/0x145C041566B21Bec558B2A37F1a5Ff261aB55998)| [SendUln302
(0x1d18...)](https://layerzeroscan.com/api/explorer/worldcoin-
testnet/address/0x1d186C560281B8F1AF831957ED5047fD3AB902F9)[ReceiveUln302
(0x53fd...)](https://layerzeroscan.com/api/explorer/worldcoin-
testnet/address/0x53fd4C4fBBd53F6bC58CaE6704b92dB1f360A648)[SendUln301
(0xa78A...)](https://layerzeroscan.com/api/explorer/worldcoin-
testnet/address/0xa78A78a13074eD93aD447a26Ec57121f29E8feC2)[ReceiveUln301
(0x88B2...)](https://layerzeroscan.com/api/explorer/worldcoin-
testnet/address/0x88B27057A9e00c5F05DDa29241027afF63f9e6e0)[LZ Executor
(0xe1a1...)](https://layerzeroscan.com/api/explorer/worldcoin-
testnet/address/0xe1a12515F9AB2764b887bF60B923Ca494EBbB2d6)  
![](https://icons-ckg.pages.dev/lz-scan/networks/xlayer.svg)X Layer Mainnet|
30274| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/xlayer/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/xlayer/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[ReceiveUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/xlayer/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[SendUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/xlayer/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[ReceiveUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/xlayer/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/xlayer/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/xlayer-testnet.svg)X Layer
Testnet| 40269| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/xlayer-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x1d18...)](https://layerzeroscan.com/api/explorer/xlayer-
testnet/address/0x1d186C560281B8F1AF831957ED5047fD3AB902F9)[ReceiveUln302
(0x53fd...)](https://layerzeroscan.com/api/explorer/xlayer-
testnet/address/0x53fd4C4fBBd53F6bC58CaE6704b92dB1f360A648)[SendUln301
(0xa78A...)](https://layerzeroscan.com/api/explorer/xlayer-
testnet/address/0xa78A78a13074eD93aD447a26Ec57121f29E8feC2)[ReceiveUln301
(0x88B2...)](https://layerzeroscan.com/api/explorer/xlayer-
testnet/address/0x88B27057A9e00c5F05DDa29241027afF63f9e6e0)[LZ Executor
(0x4Cf1...)](https://layerzeroscan.com/api/explorer/xlayer-
testnet/address/0x4Cf1B3Fa61465c2c907f82fC488B43223BA0CF93)  
![](https://icons-ckg.pages.dev/lz-scan/networks/xchain.svg)XChain Mainnet|
30291| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/xchain/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/xchain/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[ReceiveUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/xchain/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[SendUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/xchain/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[ReceiveUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/xchain/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/xchain/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/xchain-testnet.svg)XChain
Testnet| 40282| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/xchain-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/xchain-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/xchain-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/xchain-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/xchain-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x1252...)](https://layerzeroscan.com/api/explorer/xchain-
testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/xpla.svg)XPLA Mainnet| 30216|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/xpla/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xF622...)](https://layerzeroscan.com/api/explorer/xpla/address/0xF622DFb40bf7340DBCf1e5147D6CFD95d7c5cF1F)[ReceiveUln302
(0x6167...)](https://layerzeroscan.com/api/explorer/xpla/address/0x6167caAb5c3DA63311186db4D4E2596B20f557ec)[SendUln301
(0x4f8B...)](https://layerzeroscan.com/api/explorer/xpla/address/0x4f8B7a7a346Da5c467085377796e91220d904c15)[ReceiveUln301
(0xe9bA...)](https://layerzeroscan.com/api/explorer/xpla/address/0xe9bA4C1e76D874a43942718Dafc96009ec9D9917)[LZ
Executor
(0x148f...)](https://layerzeroscan.com/api/explorer/xpla/address/0x148f693af10ddfaE81cDdb36F4c93B31A90076e1)  
![](https://icons-ckg.pages.dev/lz-scan/networks/xpla-testnet.svg)XPLA
Testnet| 40216| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/xpla-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x1a2f...)](https://layerzeroscan.com/api/explorer/xpla-
testnet/address/0x1a2fd0712Ded46794022DdB16a282e798D22a7FB)[ReceiveUln302
(0x13f7...)](https://layerzeroscan.com/api/explorer/xpla-
testnet/address/0x13f78F780BB0ED02bC6df9FFA42fc2D8bB3F9aF5)[SendUln301
(0x68D9...)](https://layerzeroscan.com/api/explorer/xpla-
testnet/address/0x68D92080C987FfFfDC7c3e937AB4f70fd9d34EA9)[ReceiveUln301
(0x9130...)](https://layerzeroscan.com/api/explorer/xpla-
testnet/address/0x9130D98D47984BF9dc796829618C36CBdA43EBb9)[LZ Executor
(0x43d2...)](https://layerzeroscan.com/api/explorer/xpla-
testnet/address/0x43d28BEbaDF8B99C1aCF8c4961E4Fb895321EF23)  
![](https://icons-ckg.pages.dev/lz-scan/networks/xai.svg)Xai Mainnet| 30236|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/xai/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/xai/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[ReceiveUln302
(0x2367...)](https://layerzeroscan.com/api/explorer/xai/address/0x2367325334447C5E1E0f1b3a6fB947b262F58312)[SendUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/xai/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[ReceiveUln301
(0xfd76...)](https://layerzeroscan.com/api/explorer/xai/address/0xfd76d9CB0Bac839725aB79127E7411fe71b1e3CA)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/xai/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/xai-testnet.svg)Xai Testnet|
40251| [EndpointV2 (0x6EDC...)](https://layerzeroscan.com/api/explorer/xai-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/xai-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[ReceiveUln302
(0xcF1B...)](https://layerzeroscan.com/api/explorer/xai-
testnet/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[SendUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/xai-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[ReceiveUln301
(0x073f...)](https://layerzeroscan.com/api/explorer/xai-
testnet/address/0x073f5b4FdF17BBC16b0980d49f6C56123477bb51)[LZ Executor
(0x55c1...)](https://layerzeroscan.com/api/explorer/xai-
testnet/address/0x55c175DD5b039331dB251424538169D8495C18d1)  
![](https://icons-ckg.pages.dev/lz-scan/networks/zircuit.svg)Zircuit Mainnet|
30303| [EndpointV2
(0x6F47...)](https://layerzeroscan.com/api/explorer/zircuit/address/0x6F475642a6e85809B1c36Fa62763669b1b48DD5B)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/zircuit/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/zircuit/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/zircuit/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/zircuit/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xcCE4...)](https://layerzeroscan.com/api/explorer/zircuit/address/0xcCE466a522984415bC91338c232d98869193D46e)  
![](https://icons-ckg.pages.dev/lz-scan/networks/zircuit-testnet.svg)Zircuit
Testnet| 40275| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/zircuit-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0x4584...)](https://layerzeroscan.com/api/explorer/zircuit-
testnet/address/0x45841dd1ca50265Da7614fC43A361e526c0e6160)[ReceiveUln302
(0xd682...)](https://layerzeroscan.com/api/explorer/zircuit-
testnet/address/0xd682ECF100f6F4284138AA925348633B0611Ae21)[SendUln301
(0x9eCf...)](https://layerzeroscan.com/api/explorer/zircuit-
testnet/address/0x9eCf72299027e8AeFee5DC5351D6d92294F46d2b)[ReceiveUln301
(0xB048...)](https://layerzeroscan.com/api/explorer/zircuit-
testnet/address/0xB0487596a0B62D1A71D0C33294bd6eB635Fc6B09)[LZ Executor
(0x1252...)](https://layerzeroscan.com/api/explorer/zircuit-
testnet/address/0x12523de19dc41c91F7d2093E0CFbB76b17012C8d)  
![](https://icons-ckg.pages.dev/lz-scan/networks/zora.svg)Zora Mainnet| 30195|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/zora/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xeDf9...)](https://layerzeroscan.com/api/explorer/zora/address/0xeDf930Cd8095548f97b21ec4E2dE5455a7382f04)[ReceiveUln302
(0x57D9...)](https://layerzeroscan.com/api/explorer/zora/address/0x57D9775eE8feC31F1B612a06266f599dA167d211)[SendUln301
(0x7004...)](https://layerzeroscan.com/api/explorer/zora/address/0x7004396C99D5690da76A7C59057C5f3A53e01704)[ReceiveUln301
(0x5EB6...)](https://layerzeroscan.com/api/explorer/zora/address/0x5EB6b3Db915d29fc624b8a0e42AC029e36a1D86B)[LZ
Executor
(0x4f8B...)](https://layerzeroscan.com/api/explorer/zora/address/0x4f8B7a7a346Da5c467085377796e91220d904c15)  
![](https://icons-ckg.pages.dev/lz-scan/networks/zora-sepolia.svg)Zora Sepolia
Testnet| 40249| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/zora-
sepolia/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xF49d...)](https://layerzeroscan.com/api/explorer/zora-
sepolia/address/0xF49d162484290EAeAd7bb8C2c7E3a6f8f52e32d6)[ReceiveUln302
(0xC186...)](https://layerzeroscan.com/api/explorer/zora-
sepolia/address/0xC1868e054425D378095A003EcbA3823a5D0135C9)[SendUln301
(0xcF1B...)](https://layerzeroscan.com/api/explorer/zora-
sepolia/address/0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C)[ReceiveUln301
(0x00C5...)](https://layerzeroscan.com/api/explorer/zora-
sepolia/address/0x00C5C0B8e0f75aB862CbAaeCfff499dB555FBDD2)[LZ Executor
(0x4Cf1...)](https://layerzeroscan.com/api/explorer/zora-
sepolia/address/0x4Cf1B3Fa61465c2c907f82fC488B43223BA0CF93)  
![](https://icons-ckg.pages.dev/lz-scan/networks/bb1.svg)inEVM Mainnet| 30234|
[EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/bb1/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x000C...)](https://layerzeroscan.com/api/explorer/bb1/address/0x000CC1A759bC3A15e664Ed5379E321Be5de1c9B6)[ReceiveUln302
(0xe9AE...)](https://layerzeroscan.com/api/explorer/bb1/address/0xe9AE261D3aFf7d3fCCF38Fa2d612DD3897e07B2d)[SendUln301
(0xF9d2...)](https://layerzeroscan.com/api/explorer/bb1/address/0xF9d24d3AbF64A99C6FcdF19b27eF74B723A6110a)[ReceiveUln301
(0x8DD9...)](https://layerzeroscan.com/api/explorer/bb1/address/0x8DD9197E51dC6082853aD71D35912C53339777A7)[LZ
Executor
(0xB041...)](https://layerzeroscan.com/api/explorer/bb1/address/0xB041cd355945627BDb7281f613B6E29623ab0110)  
![](https://icons-ckg.pages.dev/lz-scan/networks/opbnb.svg)opBNB Mainnet|
30202| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/opbnb/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0x4428...)](https://layerzeroscan.com/api/explorer/opbnb/address/0x44289609cc6781fa2C665796b6c5AAbf9FFceDC5)[ReceiveUln302
(0x9c9e...)](https://layerzeroscan.com/api/explorer/opbnb/address/0x9c9e25F9fC4e8134313C2a9f5c719f5c9F4fbD95)[SendUln301
(0xA253...)](https://layerzeroscan.com/api/explorer/opbnb/address/0xA2532E716E5c7755F567a74D75804D84d409DcDA)[ReceiveUln301
(0x7807...)](https://layerzeroscan.com/api/explorer/opbnb/address/0x7807888fAC5c6f23F6EeFef0E6987DF5449C1BEb)[LZ
Executor
(0xACbD...)](https://layerzeroscan.com/api/explorer/opbnb/address/0xACbD57daAafb7D9798992A7b0382fc67d3E316f3)  
![](https://icons-ckg.pages.dev/lz-scan/networks/opbnb-testnet.svg)opBNB
Testnet| 40202| [EndpointV2
(0x6EDC...)](https://layerzeroscan.com/api/explorer/opbnb-
testnet/address/0x6EDCE65403992e310A62460808c4b910D972f10f)| [SendUln302
(0xf514...)](https://layerzeroscan.com/api/explorer/opbnb-
testnet/address/0xf514191C4a2D3b9A629fB658702015a5bCd570BC)[ReceiveUln302
(0x4b21...)](https://layerzeroscan.com/api/explorer/opbnb-
testnet/address/0x4b21Ad992A05Fb14e08df2cAF8d71A5c28b1f5E9)[SendUln301
(0xD52C...)](https://layerzeroscan.com/api/explorer/opbnb-
testnet/address/0xD52CFbea8d2C96231D5547547Ba36De3d343713e)[ReceiveUln301
(0x5Dc8...)](https://layerzeroscan.com/api/explorer/opbnb-
testnet/address/0x5Dc8940645aCeAb31f7b3486A5855d0628Bad6d2)[LZ Executor
(0x0F08...)](https://layerzeroscan.com/api/explorer/opbnb-
testnet/address/0x0F0843fF71918B8Cb8e480BD8C581373BE3c1f9b)  
![](https://icons-ckg.pages.dev/lz-scan/networks/real.svg)re.al Mainnet|
30237| [EndpointV2
(0x1a44...)](https://layerzeroscan.com/api/explorer/real/address/0x1a44076050125825900e736c501f859c50fE728c)|
[SendUln302
(0xC391...)](https://layerzeroscan.com/api/explorer/real/address/0xC39161c743D0307EB9BCc9FEF03eeb9Dc4802de7)[ReceiveUln302
(0xe184...)](https://layerzeroscan.com/api/explorer/real/address/0xe1844c5D63a9543023008D332Bd3d2e6f1FE1043)[SendUln301
(0x37aa...)](https://layerzeroscan.com/api/explorer/real/address/0x37aaaf95887624a363effB7762D489E3C05c2a02)[ReceiveUln301
(0x15e5...)](https://layerzeroscan.com/api/explorer/real/address/0x15e51701F245F6D5bd0FEE87bCAf55B0841451B3)[LZ
Executor
(0xc097...)](https://layerzeroscan.com/api/explorer/real/address/0xc097ab8CD7b053326DFe9fB3E3a31a0CCe3B526f)  
![](https://icons-ckg.pages.dev/lz-scan/networks/zklink.svg)zkLink Mainnet|
30301| [EndpointV2
(0x5c6c...)](https://layerzeroscan.com/api/explorer/zklink/address/0x5c6cfF4b7C49805F8295Ff73C204ac83f3bC4AE7)|
[SendUln302
(0x0104...)](https://layerzeroscan.com/api/explorer/zklink/address/0x01047601DB5E63b1574aae317BAd9C684E3C9056)[ReceiveUln302
(0x9AB6...)](https://layerzeroscan.com/api/explorer/zklink/address/0x9AB633555E460C01f8c7b8ab24C88dD4986dD5A1)[SendUln301
(0xd07C...)](https://layerzeroscan.com/api/explorer/zklink/address/0xd07C30aF3Ff30D96BDc9c6044958230Eb797DDBF)[ReceiveUln301
(0xF5c8...)](https://layerzeroscan.com/api/explorer/zklink/address/0xF5c814D4c78B64a1E52ce08F473112Fc27099905)[LZ
Executor
(0x06e5...)](https://layerzeroscan.com/api/explorer/zklink/address/0x06e56abD0cb3C88880644bA3C534A498cA18E5C8)  
cautionzkLink uses a unique compiler designed for zero-knowledge proof
generation which generates different bytecode than the standard Solidity
compiler (solc).  
![](https://icons-ckg.pages.dev/lz-scan/networks/zklink-testnet.svg)zkLink
Testnet| 40283| [EndpointV2
(0xF3e3...)](https://layerzeroscan.com/api/explorer/zklink-
testnet/address/0xF3e37ca248Ff739b8d0BebCcEAe1eeB199223dba)| [SendUln302
(0xf1A4...)](https://layerzeroscan.com/api/explorer/zklink-
testnet/address/0xf1A4f4FA1643ACf9f867b635A6d66a1990A3C217)[ReceiveUln302
(0x0e2c...)](https://layerzeroscan.com/api/explorer/zklink-
testnet/address/0x0e2c52BC2e119b1919e68f4F1874D4d30F6eF9fB)[SendUln301
(0x21bc...)](https://layerzeroscan.com/api/explorer/zklink-
testnet/address/0x21bc626E5e97FBF404Fda7e7D808E41A2fA56B60)[ReceiveUln301
(0xF636...)](https://layerzeroscan.com/api/explorer/zklink-
testnet/address/0xF636882f80cb5039D80F08cDEee1b166D700091b)[LZ Executor
(0x0Cc6...)](https://layerzeroscan.com/api/explorer/zklink-
testnet/address/0x0Cc6F5414996678Aa4763c3Bc66058B47813fa85)  
cautionzkLink uses a unique compiler designed for zero-knowledge proof
generation which generates different bytecode than the standard Solidity
compiler (solc).  
![](https://icons-ckg.pages.dev/lz-scan/networks/zksync.svg)zkSync Era
Mainnet| 30165| [EndpointV2
(0xd07C...)](https://layerzeroscan.com/api/explorer/zksync/address/0xd07C30aF3Ff30D96BDc9c6044958230Eb797DDBF)|
[SendUln302
(0x07fD...)](https://layerzeroscan.com/api/explorer/zksync/address/0x07fD0e370B49919cA8dA0CE842B8177263c0E12c)[ReceiveUln302
(0x0483...)](https://layerzeroscan.com/api/explorer/zksync/address/0x04830f6deCF08Dec9eD6C3fCAD215245B78A59e1)[SendUln301
(0x5533...)](https://layerzeroscan.com/api/explorer/zksync/address/0x553313dB58dEeFa3D55B1457D27EAB3Fe5EC87E8)[ReceiveUln301
(0xdF7D...)](https://layerzeroscan.com/api/explorer/zksync/address/0xdF7D44c9EfA2DB43152D9F5eD8b755b4BEbd323B)[LZ
Executor
(0x664e...)](https://layerzeroscan.com/api/explorer/zksync/address/0x664e390e672A811c12091db8426cBb7d68D5D8A6)  
cautionzkSync uses its own compiler called zkSync-solc, which generates
different bytecode than the standard Solidity compiler (solc).  
![](https://icons-ckg.pages.dev/lz-scan/networks/zksync-sepolia.svg)zkSync
Sepolia Testnet| 40305| [EndpointV2
(0xe2Ef...)](https://layerzeroscan.com/api/explorer/zksync-
sepolia/address/0xe2Ef622A13e71D9Dd2BBd12cd4b27e1516FA8a09)| [SendUln302
(0xaF86...)](https://layerzeroscan.com/api/explorer/zksync-
sepolia/address/0xaF862837316E00d2708Bd648c5FE87EdC7093799)[ReceiveUln302
(0x5c12...)](https://layerzeroscan.com/api/explorer/zksync-
sepolia/address/0x5c123dB6f87CC0d7e320C5CC9EaAfD336B5f6eF3)[SendUln301
(0xEB01...)](https://layerzeroscan.com/api/explorer/zksync-
sepolia/address/0xEB018c5EA156EF9425e644396e90d9447Ed8eD72)[ReceiveUln301
(0x9b7F...)](https://layerzeroscan.com/api/explorer/zksync-
sepolia/address/0x9b7F328813DA3942C26D92090991D1C4c61acE20)[LZ Executor
(0x6E9b...)](https://layerzeroscan.com/api/explorer/zksync-
sepolia/address/0x6E9bcFCbEdb7d1298E66cdE81ed9f39b1e12f935)  
cautionzkSync uses its own compiler called zkSync-solc, which generates
different bytecode than the standard Solidity compiler (solc).  
  
[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/technical-reference/deployed-
contracts.md)



  * Protocol & Gas Settings
  * Execution Gas Options

Version: Endpoint V2 Docs

On this page

# Message Execution Options

What are message `_options`?

Because the source chain has no concept of the destination chain's state, you
must specify the amount of gas you anticipate will be necessary for executing
your `lzReceive` or `lzCompose` method on the destination smart contract.

LayerZero provides robust **Message Execution Options** , which allow you to
specify arbitrary logic as part of the message transaction, such as the gas
amount and `msg.value` the [Executor](/v2/home/permissionless-
execution/executors) pays for message delivery, the order of message
execution, or dropping an amount of gas to a destination address.

The most common options you will use when building are `lzReceiveOption`,
`lzComposeOption`, and `lzNativeDropOption`.

info

It's important to remember that gas values may vary depending on the
destination chain. For example, all new Ethereum transactions cost `21000`
wei, but other chains may have lower or higher opcode costs, or entirely
different gas mechanisms.

## Options Builders​

A Solidity library and off-chain SDK have been provided to build specific
Message Options for your application.

  * `OptionsBuilder.sol`: Can be imported from [`@layerzerolabs/lz-evm-oapp-v2`](https://www.npmjs.com/package/@layerzerolabs/lz-evm-oapp-v2).

  * `options.ts`: Can be imported from [`@layerzerolabs/lz-v2-utilities`](https://www.npmjs.com/package/@layerzerolabs/lz-v2-utilities).

## Generating Options​

You can generate options depending on your OApp's development environment:

  * **Remix** : for quick testing in Remix, you can deploy locally to the Remix VM a contract using the `OptionsBuilder.sol` library. See the example provided below.

[Open in
Remix](https://remix.ethereum.org/#url=https://docs.layerzero.network/LayerZero/contracts/OptionsGenerator.sol)[What
is Remix?](https://remix-ide.readthedocs.io/en/latest/index.html)  
  

  * **Foundry** : `_options` can be generated directly in your Foundry unit tests using the `OptionsBuilder.sol` library. See the [OmniCounter Test](https://github.com/LayerZero-Labs/LayerZero-v2/blob/main/packages/layerzero-v2/evm/oapp/test/OmniCounter.t.sol#L80) file as an example for how to properly invoke options.

  * **Hardhat** : you can also locally declare options in Hardhat via the `options.ts` file.

All tools use the same method for packing the `_options` bytes array to
simplify your experience when switching between environments.

### Import Options​

All `_options` tools must be imported into your environment to be used.

#### Options Library​

Import the `OptionsBuilder` from `@layerzerolabs/lz-evm-oapp-v2` into either
your Foundry test or smart contract to be deployed locally.

    
    
    import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";  
    

#### Options SDK​

Start by importing `Options` from `@layerzerolabs/lz-v2-utilities`.

    
    
    import {Options} from '@layerzerolabs/lz-v2-utilities';  
    

### Initialize Options​

The `newOptions` method is used to initialize a new bytes array.

    
    
    const _options = Options.newOptions();  
    

It's a starting point to which you can add specific option configurations.

The command below in Solidity allows you to conveniently extend the bytes type
with LayerZero's `OptionsBuilder` library methods, simplifying the creation
and manipulation of message execution options.

    
    
    using OptionsBuilder for bytes;  
    

### Add Options Types​

When generating `_options`, you will want to allocate specific gas amounts for
handling different message types used in your smart contract. For instance,
`addExecutorLzReceiveOption` is a method that can be used to specify how much
gas limit and `msg.value` the Executor uses when calling `lzReceive` on the
receiving chain.

    
    
    const GAS_LIMIT = 1000000; // Gas limit for the executor  
    const MSG_VALUE = 0; // msg.value for the lzReceive() function on destination in wei  
      
    const _options = Options.newOptions().addExecutorLzReceiveOption(GAS_LIMIT, MSG_VALUE);  
    

You can continue appending new `Options` methods to add more Executor message
handling; all packed into a single call.

See below for all Option Types.

caution

For each chain pathway, your OApp's configured Executor has a **native cap** :
an upper bound for how much gas can be sent to the destination chain.

In general, the sum of your message execution options must be **LESS THAN**
the native cap.

To check the native gas cap, you can query the Executor contract's `DstConfig`
using the [**Executor address**](/v2/developers/evm/technical-
reference/deployed-contracts) and the [**`IExecutor.sol`
interface**](https://github.com/LayerZero-
Labs/LayerZero-v2/blob/bf4318b5e88e46400931bb4c1f6aa0343c035a79/messagelib/contracts/interfaces/IExecutor.sol):

    
    
    function dstConfig(uint32 _dstEid) external view returns (uint64, uint16, uint128, uint128);  
      
    struct DstConfig {  
        uint64 baseGas; // for verifying / fixed calldata overhead  
        uint16 multiplierBps;  
        uint128 floorMarginUSD; // uses priceFeed PRICE_RATIO_DENOMINATOR  
        uint128 nativeCap; // the MAX amount of native gas an OApp can use in execution options  
    }  
    

tip

The [**create-lz-oapp**](/v2/developers/evm/create-lz-oapp/project-config) npx
package includes a script by default for checking all the Executor
`DstConfigs` for your project:

    
    
    npx hardhat lz:oapp:config:get:executor  
    

### Pass Options in Send Call​

After generating `_options`, you will want to test them in a `send` call.

#### Options SDK​

Using the Options SDK, this can be passed directly into a Hardhat task or unit
test depending on your use case.

    
    
    // Other parameters for the send function  
    const _dstEid = 'someEndpointId'; // Destination endpoint ID  
    const message = 'Your message here'; // The message you want to send  
      
    // Call the send function on the smart contract  
    // Convert your options array toHex()  
    const tx = await yourOAppContract.send(destEndpointId, message, _options.toHex());  
    await tx.wait();  
    

In this Typescript snippet, the `send` function is being called on the
`YourOAppContract` contract instance, passing in the destination endpoint ID,
the message, and the `_options` that were constructed:

    
    
    contract YourOAppContract {  
        // ... other functions and declarations  
      
        function send(uint32 _dstEid, string memory message, bytes memory _options) public payable {  
            // Logic to handle the sending of the message with the provided options  
            // This might involve interacting with other contracts or internal logic  
            bytes memory _payload = abi.encode(message);  
            _lzSend(  
                _dstEid, // Destination chain's endpoint ID.  
                _payload, // Encoded message payload being sent.  
                _options, // Message execution options (e.g., gas to use on destination).  
                MessagingFee(msg.value, 0), // Fee struct containing native gas and ZRO token.  
                payable(msg.sender) // The refund address in case the send call reverts.  
            );  
        }  
      
        // ... other functions and declarations  
    }  
    

In this Solidity snippet, the `send` function takes three parameters:
`_dstEid`, `message`, and `_options`. The function's logic would then use
those parameters to to send a message cross-chain.

#### Options Library​

Using the `OptionsBuilder.sol` library, these `_options` can be directly
referenced in your Foundry tests for quick local testing.

    
    
    import { MyOApp } from "../contracts/oapp/examples/MyOApp.sol";  
    import { TestHelper } from "../contracts/tests/TestHelper.sol";  
    import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";  
      
    contract MyOAppTest is TestHelper {  
        using OptionsBuilder for bytes;  
        // ... other test setup functions  
        function test_increment() public {  
            bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(50000, 0);  
            (uint256 nativeFee, ) = aCounter.quote(bEid, MsgCodec.VANILLA_TYPE, options);  
            aCounter.increment{ value: nativeFee }(bEid, MsgCodec.VANILLA_TYPE, options);  
        // ... other test logic  
        }  
    }  
    

The above example is taken from the [OmniCounter Foundry
Test](https://github.com/LayerZero-
Labs/LayerZero-v2/blob/main/packages/layerzero-v2/evm/oapp/test/OmniCounter.t.sol#L76)
in the LayerZero V2 repo.

info

See [**`TestHelper.sol`**](https://github.com/LayerZero-
Labs/LayerZero-v2/blob/432db51666878f147ceaf1c46d230f344430c78e/oapp/test/TestHelper.sol#L4)
for full Foundry testing support.

## Option Types​

There are multiple option types to take advantage of, each controlling
specific handling of LayerZero messages.

### `lzReceive` Option​

The `lzReceive` option specifies the gas values the Executor uses when calling
`lzReceive` on the destination chain.

    
    
    Options.newOptions().addExecutorLzReceiveOption(50000, 0);  
    

It defines the amount of `_gas` and `msg.value` to be used in the `lzReceive`
call by the Executor on the destination chain:

`OPTION_TYPE_LZRECEIVE` contains `(uint128 _gas, uint128 _value)`

`_gas`: The amount of gas you'd provide for the `lzReceive` call in source
chain native tokens. `50000` should be enough for most transactions, but this
value should be profiled based on your function's specific opcode cost on each
chain.

`_value`: The `msg.value` for the call. This value is often included to fund
any operations that need native gas on the destination chain, including
sending another nested message.

### `lzCompose` Option​

This option allows you to allocate some gas and value to your **Composed
Message** on the destination chain.
[`lzCompose`](/v2/developers/evm/oapp/message-design-patterns) is used when
you want to call external contracts from your `lzReceive` function.

    
    
    Options.newOptions().addExecutorLzComposeOption(0, 30000, 0);  
    

`OPTION_TYPE_LZCOMPOSE` contains `(uint16 _index, uint128 _gas, uint128
_value)`

`_index`: The index of the `lzCompose()` function call. When multiples of this
option are added, they are summed PER index by the Executor on the remote
chain. This can be useful for defining multiple composed message steps that
happen sequentially.

`_gas`: The gas amount for the lzCompose call varies based on the
destination's compose logic and the destination chain's characteristics (e.g.,
opcode pricing). It's important to perform tailored testing to determine the
optimal gas requirement for your specific transaction needs.

`_value`: The `msg.value` for the call.

### `lzNativeDrop` Option​

This option contains how much native gas you want to drop to the `_receiver`,
this is often done to allow users or a contract to have some gas on a new
chain.

    
    
    Options.newOptions().addExecutorNativeDropOption(100000, receiverAddressInBytes32);  
    

`OPTION_TYPE_LZNATIVEDROP` contains `(uint128 _amount, bytes32 _receiver)`

`_amount`: The amount of gas in wei to drop for the receiver.

`_receiver`: The `bytes32` representation of the receiver address.

### `OrderedExecution` Option​

By adding this option, the Executor will utilize [**Ordered Message
Delivery**](/v2/developers/evm/oapp/message-design-patterns#unordered-
delivery). This overrides the default behavior of [**Unordered Message
Delivery**](/v2/developers/evm/oapp/message-design-patterns#unordered-
delivery).

    
    
    Options.newOptions().addExecutorOrderedExecutionOption(bytes(''));  
    

For example, if nonce `2` transaction fails, all subsequent transactions with
this option will not be executed until the previous message has been resolved
with.

`bytes`: The argument should always be initialized as an empty bytes array
(`""`).

caution

These message `_options` must be combined with in-app contract changes, listed
under [**Ordered Message Delivery**](/v2/developers/evm/oapp/message-design-
patterns#enabling-ordered-delivery).

### Duplicate Option Types​

Multiple options of the same type can be passed and appended into the same
options array. The logic on how multiple options of the same type are summed
differs per option type:

    
    
    bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(50000, 0).addExecutorLzComposeOption(0, 30000, 0).addExecutorLzComposeOption(1, 30000, 0);  
    

  * **`lzReceive`** : Both the `_gas` and `_value` parameters are summed.

  * **`lzCompose`** : Both the `_gas` and `_value` parameters are **summed by index**.

  * **`lzNativeDrop`** : The `_amount` parameter is summed by unique `_receiver` address.

Make sure that appending multiple options is the intended behavior of your
unique OApp.

## Determining Gas Costs​

Gas profiling and optimization is outside the scope of LayerZero's
documentation, however, the following resources may be useful for determining
what `_options` should be used for your `_lzReceive` and `lzCompose` calls.

### Tenderly​

For supported chains, the [Tenderly Gas
Profiler](https://dashboard.tenderly.co/explorer) can be extremely useful for
determining how much to reduce your execution options by:

![Tenderly Gas](/assets/images/tenderly-3c5778599b1aa9007f440fbf7a054e57.png)

In the above image, you can see that the _lzReceive call for this OFT token
transfer with composed call used `45,358` wei for gas.

  * Provided `lzReceive` Option: `50000` wei

  * Actual `lzReceive` Cost: `45,358` wei

In general, this opcode cost may fluctuate depending on the destination chain
and how your contract logic executes, so you should take care in defining
`_options` based on the message types for your application.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/protocol-gas-settings/options.md)

[PreviousSecurity & Executor Configuration](/v2/developers/evm/protocol-gas-
settings/default-config)[NextEstimating Source Gas
Fees](/v2/developers/evm/protocol-gas-settings/gas-fees)

  * Options Builders
  * Generating Options
    * Import Options
    * Initialize Options
    * Add Options Types
    * Pass Options in Send Call
  * Option Types
    * `lzReceive` Option
    * `lzCompose` Option
    * `lzNativeDrop` Option
    * `OrderedExecution` Option
    * Duplicate Option Types
  * Determining Gas Costs
    * Tenderly



  * Contract Standards
  * Omnichain Fungible Token (OFT)

Version: Endpoint V2 Docs

On this page

# LayerZero V2 OFT Quickstart

The Omnichain Fungible Token (OFT) Standard allows **fungible tokens** to be
transferred across multiple blockchains without asset wrapping or
middlechains.

This standard works by either debiting (`burn` / `lock`) tokens on the source
chain, sending a message via LayerZero, and delivering a function call to
credit (`mint` / `unlock`) the same number of tokens on the destination chain.

This creates a **unified supply** across all networks that the OFT supports.

#### OFT.sol​

`_burn` the spender's amount on the source chain (Chain A), triggering a new
token to `_mint` on the target chain (Chain B), via the paired OFT contract.

![OFT
Example](/assets/images/oft_mechanism_light-922b88c364b5156e26edc6def94069f1.jpg#gh-
light-mode-only) ![OFT
Example](/assets/images/oft_mechanism-0894f9bd02de35d6d7ce3d648a2df574.jpg#gh-
dark-mode-only)

#### OFTAdapter.sol​

`ERC20.safeTransferFrom` the spender to the OFT Adapter contract, triggering a
`_mint` of the same amount on the selected destination chain (Chain B) via the
paired OFT Contract.

To unlock the tokens in the source chain's OFT Adapter, you will call
`OFT.send` (Chain B), triggering the token `_burn`, and sending a message via
the protocol to `ERC20.safeTransfer` out of the Adapter to the receiving
address (Chain A).

![OFT Example](/assets/images/oft-adapter-
light-a85ed5cf53a08a8fbcafb329a6fa9a70.svg#gh-light-mode-only) ![OFT
Example](/assets/images/oft-adapter-
dark-f5afe2b06072d409b411c42fc3f402e1.svg#gh-dark-mode-only)

Using this design pattern, LayerZero can **extend** any fungible token to
interoperate with other chains. The most widely used of these standards is
`OFT.sol`, an extension of the [OApp Contract
Standard](/v2/developers/evm/oapp/overview) and the [ERC20 Token
Standard](https://docs.openzeppelin.com/contracts/5.x/erc20).

info

If you prefer reading the contract code, see the OFT contract in the LayerZero
Devtools [**OFT Package**](https://github.com/LayerZero-
Labs/devtools/blob/main/packages/oft-evm/contracts/OFT.sol).

  

## Installation​

To start using the `OFT` and `OFTAdapter` contracts, you can install the [OFT
package](https://www.npmjs.com/package/@layerzerolabs/lz-evm-oapp-v2) to an
existing project:

  * npm
  * yarn
  * pnpm
  * forge

    
    
    npm install @layerzerolabs/oft-evm  
    
    
    
    yarn add @layerzerolabs/oft-evm  
    
    
    
    pnpm add @layerzerolabs/oft-evm  
    
    
    
    forge install https://github.com/LayerZero-Labs/devtools  
    
    
    
    forge install https://github.com/LayerZero-Labs/layerzero-v2  
    

Then add to your `foundry.toml`:

    
    
    [profile.default]  
    src = "src"  
    out = "out"  
    libs = ["lib"]  
      
    remappings = [  
        '@layerzerolabs/oft-evm/=lib/devtools/packages/oft-evm/',  
        '@layerzerolabs/oapp-evm/=lib/devtools/packages/oapp-evm/',  
        '@layerzerolabs/lz-evm-protocol-v2/=lib/layerzero-v2/packages/layerzero-v2/evm/protocol',  
    ]  
      
    # See more config options https://github.com/foundry-rs/foundry/blob/master/crates/config/README.md#all-options  
    

info

LayerZero contracts work with both [**OpenZeppelin
V5**](https://docs.openzeppelin.com/contracts/5.x/access-control#ownership-
and-ownable) and V4 contracts. Specify your desired version in your project's
`package.json`:

    
    
    "resolutions": {  
        "@openzeppelin/contracts": "^5.0.1",  
    }  
    

tip

LayerZero also provides [**create-lz-oapp**](/v2/developers/evm/create-lz-
oapp/start), an npx package that allows developers to create any omnichain
application in <4 minutes! Get started by running the following from your
command line:

    
    
    npx create-lz-oapp@latest  
    

## Constructing an OFT Contract​

To create an OFT, deploy the OFT contract on every chain you want the token to
exist on.

If your token already exists on the chain you want to connect, you can deploy
the OFT Adapter contract to act as an intermediary lockbox for the token.

  * OFT
  * OFT Adapter

    
    
    // SPDX-License-Identifier: UNLICENSED  
    pragma solidity ^0.8.22;  
      
    import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";  
    import { OFT } from "@layerzerolabs/oft-evm/contracts/OFT.sol";  
      
    /// @notice OFT is an ERC-20 token that extends the OFTCore contract.  
    contract MyOFT is OFT {  
        constructor(  
            string memory _name,  
            string memory _symbol,  
            address _lzEndpoint,  
            address _delegate  
        ) OFT(_name, _symbol, _lzEndpoint, _delegate) Ownable(_delegate) {}  
    }  
    

tip

Remember to add the ERC20 `_mint` method either in the constructor or as a
protected `mint` function before deploying.

  

This contract contains everything necessary to launch an omnichain ERC20 and
can be deployed immediately! It also can be highly customized if you wish to
add extra functionality.

Under the hood, `OFT.sol` extends `ERC20.sol`, by inheriting `OFTCore.sol`.
OFT also overrides `_debit` and `_credit` to use the ERC20 `_mint` and `_burn`
methods:

    
    
    // SPDX-License-Identifier: MIT  
      
    pragma solidity ^0.8.20;  
      
    import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";  
    import { IOFT, OFTCore } from "./OFTCore.sol";  
      
    /**  
     * @title OFT Contract  
     * @dev OFT is an ERC-20 token that extends the functionality of the OFTCore contract.  
     */  
    abstract contract OFT is OFTCore, ERC20 {  
        /**  
         * @dev Constructor for the OFT contract.  
         * @param _name The name of the OFT.  
         * @param _symbol The symbol of the OFT.  
         * @param _lzEndpoint The LayerZero endpoint address.  
         * @param _delegate The delegate capable of making OApp configurations inside of the endpoint.  
         */  
        constructor(  
            string memory _name,  
            string memory _symbol,  
            address _lzEndpoint,  
            address _delegate  
        ) ERC20(_name, _symbol) OFTCore(decimals(), _lzEndpoint, _delegate) {}  
      
        /**  
         * @dev Retrieves the address of the underlying ERC20 implementation.  
         * @return The address of the OFT token.  
         *  
         * @dev In the case of OFT, address(this) and erc20 are the same contract.  
         */  
        function token() public view returns (address) {  
            return address(this);  
        }  
      
        /**  
         * @notice Indicates whether the OFT contract requires approval of the 'token()' to send.  
         * @return requiresApproval Needs approval of the underlying token implementation.  
         *  
         * @dev In the case of OFT where the contract IS the token, approval is NOT required.  
         */  
        function approvalRequired() external pure virtual returns (bool) {  
            return false;  
        }  
      
        /**  
         * @dev Burns tokens from the sender's specified balance.  
         * @param _from The address to debit the tokens from.  
         * @param _amountLD The amount of tokens to send in local decimals.  
         * @param _minAmountLD The minimum amount to send in local decimals.  
         * @param _dstEid The destination chain ID.  
         * @return amountSentLD The amount sent in local decimals.  
         * @return amountReceivedLD The amount received in local decimals on the remote.  
         */  
        function _debit(  
            address _from,  
            uint256 _amountLD,  
            uint256 _minAmountLD,  
            uint32 _dstEid  
        ) internal virtual override returns (uint256 amountSentLD, uint256 amountReceivedLD) {  
            (amountSentLD, amountReceivedLD) = _debitView(_amountLD, _minAmountLD, _dstEid);  
      
            // @dev In NON-default OFT, amountSentLD could be 100, with a 10% fee, the amountReceivedLD amount is 90,  
            // therefore amountSentLD CAN differ from amountReceivedLD.  
      
            // @dev Default OFT burns on src.  
            _burn(_from, amountSentLD);  
        }  
      
        /**  
         * @dev Credits tokens to the specified address.  
         * @param _to The address to credit the tokens to.  
         * @param _amountLD The amount of tokens to credit in local decimals.  
         * @dev _srcEid The source chain ID.  
         * @return amountReceivedLD The amount of tokens ACTUALLY received in local decimals.  
         */  
        function _credit(  
            address _to,  
            uint256 _amountLD,  
            uint32 /*_srcEid*/  
        ) internal virtual override returns (uint256 amountReceivedLD) {  
            if (_to == address(0x0)) _to = address(0xdead); // _mint(...) does not support address(0x0)  
            // @dev Default OFT mints on dst.  
            _mint(_to, _amountLD);  
            // @dev In the case of NON-default OFT, the _amountLD MIGHT not be == amountReceivedLD.  
            return _amountLD;  
        }  
    }  
    

This design allows `OFT.sol` to facilitate cross-chain token transfers while
maintaining compatibility with the ERC20 token standard and extensions. Any
ERC20 compatible token library can be used with LayerZero's OFT Standard.

By default, the OFT follows ERC20 convention and uses a value of `18` for
decimals. To use a different value, you will need to override the `decimals()`
function in your contract.

    
    
    // SPDX-License-Identifier: UNLICENSED  
      
    pragma solidity ^0.8.22;  
      
    import { OFTAdapter } from "@layerzerolabs/oft-evm/contracts/OFTAdapter.sol";  
    import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";  
      
    /// @notice OFTAdapter uses a deployed ERC-20 token and safeERC20 to interact with the OFTCore contract.  
    contract MyOFTAdapter is OFTAdapter {  
        constructor(  
            address _token,  
            address _lzEndpoint,  
            address _owner  
        ) OFTAdapter(_token, _layerZeroEndpoint, _owner) Ownable(_owner) {}  
    }  
    

danger

**There can only be one OFT Adapter used in an OFT deployment.** Multiple OFT
Adapters break omnichain unified liquidity by effectively creating token
pools. If you create OFT Adapters on multiple chains, you have no way to
guarantee finality for token transfers due to the fact that the source chain
has no knowledge of the destination pool's supply (or lack of supply). This
can create race conditions where if a sent amount exceeds the available supply
on the destination chain, those sent tokens will be permanently lost.

  

This contract contains everything necessary to launch an omnichain ERC20 and
can be deployed immediately! It also can be highly customized if you wish to
add extra functionality.

Under the hood, `OFTAdapter.sol` uses the `SafeERC20.sol` library to handle
transferring tokens to and from the Adapter contract by overriding OFTCore's
`_debit` and `_credit` methods:

    
    
    // SPDX-License-Identifier: MIT  
      
    pragma solidity ^0.8.20;  
      
    import { IERC20Metadata, IERC20 } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";  
    import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";  
    import { IOFT, OFTCore } from "./OFTCore.sol";  
      
    /**  
     * @title OFTAdapter Contract  
     * @dev OFTAdapter is a contract that adapts an ERC-20 token to the OFT functionality.  
     *  
     * @dev For existing ERC20 tokens, this can be used to convert the token to crosschain compatibility.  
     * @dev WARNING: ONLY 1 of these should exist for a given global mesh,  
     * unless you make a NON-default implementation of OFT and needs to be done very carefully.  
     * @dev WARNING: The default OFTAdapter implementation assumes LOSSLESS transfers, ie. 1 token in, 1 token out.  
     * IF the 'innerToken' applies something like a transfer fee, the default will NOT work...  
     * a pre/post balance check will need to be done to calculate the amountSentLD/amountReceivedLD.  
     */  
    abstract contract OFTAdapter is OFTCore {  
        using SafeERC20 for IERC20;  
      
        IERC20 internal immutable innerToken;  
      
        /**  
         * @dev Constructor for the OFTAdapter contract.  
         * @param _token The address of the ERC-20 token to be adapted.  
         * @param _lzEndpoint The LayerZero endpoint address.  
         * @param _delegate The delegate capable of making OApp configurations inside of the endpoint.  
         */  
        constructor(  
            address _token,  
            address _lzEndpoint,  
            address _delegate  
        ) OFTCore(IERC20Metadata(_token).decimals(), _lzEndpoint, _delegate) {  
            innerToken = IERC20(_token);  
        }  
      
        /**  
         * @dev Retrieves the address of the underlying ERC20 implementation.  
         * @return The address of the adapted ERC-20 token.  
         *  
         * @dev In the case of OFTAdapter, address(this) and erc20 are NOT the same contract.  
         */  
        function token() public view returns (address) {  
            return address(innerToken);  
        }  
      
        /**  
         * @notice Indicates whether the OFT contract requires approval of the 'token()' to send.  
         * @return requiresApproval Needs approval of the underlying token implementation.  
         *  
         * @dev In the case of default OFTAdapter, approval is required.  
         * @dev In non-default OFTAdapter contracts with something like mint and burn privileges, it would NOT need approval.  
         */  
        function approvalRequired() external pure virtual returns (bool) {  
            return true;  
        }  
      
        /**  
         * @dev Locks tokens from the sender's specified balance in this contract.  
         * @param _from The address to debit from.  
         * @param _amountLD The amount of tokens to send in local decimals.  
         * @param _minAmountLD The minimum amount to send in local decimals.  
         * @param _dstEid The destination chain ID.  
         * @return amountSentLD The amount sent in local decimals.  
         * @return amountReceivedLD The amount received in local decimals on the remote.  
         *  
         * @dev msg.sender will need to approve this _amountLD of tokens to be locked inside of the contract.  
         * @dev WARNING: The default OFTAdapter implementation assumes LOSSLESS transfers, ie. 1 token in, 1 token out.  
         * IF the 'innerToken' applies something like a transfer fee, the default will NOT work...  
         * a pre/post balance check will need to be done to calculate the amountReceivedLD.  
         */  
        function _debit(  
            address _from,  
            uint256 _amountLD,  
            uint256 _minAmountLD,  
            uint32 _dstEid  
        ) internal virtual override returns (uint256 amountSentLD, uint256 amountReceivedLD) {  
            (amountSentLD, amountReceivedLD) = _debitView(_amountLD, _minAmountLD, _dstEid);  
            // @dev Lock tokens by moving them into this contract from the caller.  
            innerToken.safeTransferFrom(_from, address(this), amountSentLD);  
        }  
      
        /**  
         * @dev Credits tokens to the specified address.  
         * @param _to The address to credit the tokens to.  
         * @param _amountLD The amount of tokens to credit in local decimals.  
         * @dev _srcEid The source chain ID.  
         * @return amountReceivedLD The amount of tokens ACTUALLY received in local decimals.  
         *  
         * @dev WARNING: The default OFTAdapter implementation assumes LOSSLESS transfers, ie. 1 token in, 1 token out.  
         * IF the 'innerToken' applies something like a transfer fee, the default will NOT work...  
         * a pre/post balance check will need to be done to calculate the amountReceivedLD.  
         */  
        function _credit(  
            address _to,  
            uint256 _amountLD,  
            uint32 /*_srcEid*/  
        ) internal virtual override returns (uint256 amountReceivedLD) {  
            // @dev Unlock the tokens and transfer to the recipient.  
            innerToken.safeTransfer(_to, _amountLD);  
            // @dev In the case of NON-default OFTAdapter, the amountLD MIGHT not be == amountReceivedLD.  
            return _amountLD;  
        }  
    }  
    

## Deployment Workflow​

  1. Deploy the `OFT` to all the chains you want to connect.

  2. Since `OFT` extends `OApp`, call `OFT.setPeer` to whitelist each destination contract on every destination chain.
    
        // The real endpoint ids will vary per chain, and can be found under "Supported Chains"  
    uint32 aEid = 1;  
    uint32 bEid = 2;  
      
    MyOFT aOFT;  
    MyOFT bOFT;  
      
    function addressToBytes32(address _addr) public pure returns (bytes32) {  
        return bytes32(uint256(uint160(_addr)));  
    }  
      
    // Call on both sides per pathway  
    aOFT.setPeer(bEid, addressToBytes32(address(bOFT)));  
    bOFT.setPeer(aEid, addressToBytes32(address(aOFT)));  
    

  3. Set the DVN configuration, including optional settings such as block confirmations, security threshold, the Executor, max message size, and send/receive libraries.
    
        EndpointV2.setSendLibrary(aOFT, bEid, newLib)  
    EndpointV2.setReceiveLibrary(aOFT, bEid, newLib, gracePeriod)  
    EndpointV2.setReceiveLibraryTimeout(aOFT, bEid, lib, gracePeriod)  
    EndpointV2.setConfig(aOFT, sendLibrary, sendConfig)  
    EndpointV2.setConfig(aOFT, receiveLibrary, receiveConfig)  
    EndpointV2.setDelegate(delegate)  
    

These custom configurations will be stored on-chain as part of `EndpointV2`,
along with your respective `SendLibrary` and `ReceiveLibrary`:

    
        // LayerZero V2 MessageLibManager.sol (part of EndpointV2.sol)  
    mapping(address sender => mapping(uint32 dstEid => address lib)) internal sendLibrary;  
    mapping(address receiver => mapping(uint32 srcEid => address lib)) internal receiveLibrary;  
    mapping(address receiver => mapping(uint32 srcEid => Timeout)) public receiveLibraryTimeout;  
    // LayerZero V2 SendLibBase.sol (part of SendUln302.sol)  
    mapping(address oapp => mapping(uint32 eid => ExecutorConfig)) public executorConfigs;  
    // LayerZero V2 UlnBase.sol (both in SendUln302.sol and ReceiveUln302.sol)  
    mapping(address oapp => mapping(uint32 eid => UlnConfig)) internal ulnConfigs;  
    // LayerZero V2 EndpointV2.sol  
    mapping(address oapp => address delegate) public delegates;  
    

You can find example scripts to make these calls under [Security and Executor
Configuration](/v2/developers/evm/protocol-gas-settings/default-config).

danger

These configurations control the verification mechanisms of messages sent
between your OApps. You should review the above settings carefully.

If no configuration is set, the configuration will fallback to the default
configurations set by LayerZero Labs. For example:

    
        /// @notice The Send Library is the Oapp specified library that will be used to send the message to the destination  
    /// endpoint. If the Oapp does not specify a Send Library, the default Send Library will be used.  
    /// @dev If the Oapp does not have a selected Send Library, this function will resolve to the default library  
    /// configured by LayerZero  
    /// @return lib address of the Send Library  
    /// @param _sender The address of the Oapp that is sending the message  
    /// @param _dstEid The destination endpoint id  
    function getSendLibrary(address _sender, uint32 _dstEid) public view returns (address lib) {  
        lib = sendLibrary[_sender][_dstEid];  
        if (lib == DEFAULT_LIB) {  
            lib = defaultSendLibrary[_dstEid];  
            if (lib == address(0x0)) revert Errors.LZ_DefaultSendLibUnavailable();  
        }  
    }  
    

  

  4. (**Recommended**) The OFT inherits `OAppOptionsType3`, meaning you can enforce specific gas settings when users call `aOFT.send`.
    
        EnforcedOptionParam[] memory aEnforcedOptions = new EnforcedOptionParam[](1);  
    // Send gas for lzReceive (A -> B).  
    aEnforcedOptions[0] = EnforcedOptionParam({eid: bEid, msgType: SEND, options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(50000, 0)}); // gas limit, msg.value  
    aOFT.setEnforcedOptions(aEnforcedOptions);  
    

  5. Required only for `OFTAdapter`: Approve your `OFTAdapter` as a spender of your `ERC20` token for the token amount you want to transfer by calling `ERC20.approve`. This comes standard in the [`ERC20` interface](https://eips.ethereum.org/EIPS/eip-20#methods), and is required when using an intermediary contract to spend token amounts on behalf of the caller. See more details about each setting below.

### OFTCore​

Most of the LayerZero cross-chain messaging logic can be found within
`OFTCore.sol`. This contract implements the `OApp` related functions like
`_lzSend`, `_lzReceive`, and `sendCompose`, while also defining the core OFT
interface that every OFT variant should adhere to.

`OFT.sol` overrides the `_debit` and `_credit` methods found in `OFTCore.sol`
to use the ERC20 internal `_burn` and `_mint` methods respectively during
cross-chain token transfer.

Other OFT variants will override `_debit` and `_credit` differently depending
on implementation (e.g., [`OFTAdapter.sol`](/v2/developers/evm/oft/quickstart)
overrides `_debit` and `_credit` to use `ERC20.safeTransferFrom` to lock /
unlock tokens from the OFT Adapter contract itself).

You can also override these methods to add additional functionality to the
base transfer logic, which will be explored below.

### Token Supply Cap​

When transferring tokens across different blockchain VMs, each chain may have
a different level of decimal precision for the smallest unit of a token.

While EVM chains support `uint256` for token balances, many non-EVM
environments use `uint64`. Because of this, the default OFT Standard has a max
token supply `(2^64 - 1)/(10^6)`, or `18,446,744,073,709.551615`.

info

If your token's supply needs to exceed this limit, you'll need to override the
**shared decimals value**.

#### Optional: Overriding `sharedDecimals`​

This shared decimal precision is essentially the maximum number of decimal
places that can be reliably represented and handled across different
blockchain VMs when transferring tokens.

By default, an OFT has 6 `sharedDecimals`, which is optimal for most ERC20 use
cases that use `18` decimals.

    
    
    // @dev Sets an implicit cap on the amount of tokens, over uint64.max() will need some sort of outbound cap / totalSupply cap  
    // Lowest common decimal denominator between chains.  
    // Defaults to 6 decimal places to provide up to 18,446,744,073,709.551615 units (max uint64).  
    // For tokens exceeding this totalSupply(), they will need to override the sharedDecimals function with something smaller.  
    // ie. 4 sharedDecimals would be 1,844,674,407,370,955.1615  
    function sharedDecimals() public view virtual returns (uint8) {  
        return 6;  
    }  
    

To modify this default, simply override the `sharedDecimals` function to
return another value.

caution

Shared decimals also control how token transfer precision is calculated.

### Token Transfer Precision​

The OFT Standard also handles differences in decimal precision before every
cross-chain transfer by "**cleaning** " the amount from any decimal precision
that cannot be represented in the shared system.

The OFT Standard defines these small token transfer amounts as "**dust** ".

#### Example​

Vanilla OFTs use a local decimal value of `18` (the norm for ERC20 tokens),
and a shared decimal value of `6`.

    
    
    decimalConversionRate = 10^(localDecimals − sharedDecimals) = 10^(18−6) = 10^12  
    

This means the conversion rate is `10^12`, which indicates the smallest unit
that can be transferred is `10^-12` in terms of the token's local decimals.

For example, if you `send` a value of `1234567890123456789` (a token amount
with 18 decimals), the OFT Standard will:

  1. Divides by `decimalConversionRate`:

    
    
    1234567890123456789 / 10^12 = 1234567.890123456789 = 1234567  
    

tip

Remember that solidity performs integer arithmetic. This means when you divide
two integers, the result is also an integer with the fractional part
discarded.

  

  2. Multiplies by `decimalConversionRate`:

    
    
    1234567 * 10^12 = 1234567000000000000  
    

This process removes the last 12 digits from the original amount, effectively
"**cleaning** " the amount from any "**dust** " that cannot be represented in
a system with 6 decimal places.

    
    
    /**  
     * @dev Internal function to remove dust from the given local decimal amount.  
     * @param _amountLD The amount in local decimals.  
     * @return amountLD The amount after removing dust.  
     *  
     * @dev Prevents the loss of dust when moving amounts between chains with different decimals.  
     * @dev eg. uint(123) with a conversion rate of 100 becomes uint(100).  
     */  
    function _removeDust(uint256 _amountLD) internal view virtual returns (uint256 amountLD) {  
        return (_amountLD / decimalConversionRate) * decimalConversionRate;  
    }  
    

tip

In summary, this adjustment via the **`_removeDust`** function prevents OFT
transfers from a potential loss of value due to rounding errors between
different VMs, and should be called after determining the actual transfer
amount (e.g., after deducting fees).

### Adding Send Logic​

When calling the `send` function, `_debit` is invoked, triggering the OFT's
internal ERC20 `_burn` method to be invoked.

    
    
    /**  
     * @dev Executes the send operation.  
     * @param _sendParam The parameters for the send operation.  
     * @param _fee The calculated fee for the send() operation.  
     *      - nativeFee: The native fee.  
     *      - lzTokenFee: The lzToken fee.  
     * @param _refundAddress The address to receive any excess funds.  
     * @return msgReceipt The receipt for the send operation.  
     * @return oftReceipt The OFT receipt information.  
     *  
     * @dev MessagingReceipt: LayerZero msg receipt  
     *  - guid: The unique identifier for the sent message.  
     *  - nonce: The nonce of the sent message.  
     *  - fee: The LayerZero fee incurred for the message.  
     */  
    function send(  
        SendParam calldata _sendParam,  
        MessagingFee calldata _fee,  
        address _refundAddress  
    ) external payable virtual returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt) {  
        // @dev Applies the token transfers regarding this send() operation.  
        // - amountSentLD is the amount in local decimals that was ACTUALLY sent/debited from the sender.  
        // - amountReceivedLD is the amount in local decimals that will be received/credited to the recipient on the remote OFT instance.  
        (uint256 amountSentLD, uint256 amountReceivedLD) = _debit(  
            msg.sender,  
            _sendParam.amountLD,  
            _sendParam.minAmountLD,  
            _sendParam.dstEid  
        );  
        // @dev Builds the options and OFT message to quote in the endpoint.  
        (bytes memory message, bytes memory options) = _buildMsgAndOptions(_sendParam, amountReceivedLD);  
      
        // @dev Sends the message to the LayerZero endpoint and returns the LayerZero msg receipt.  
        msgReceipt = _lzSend(_sendParam.dstEid, message, options, _fee, _refundAddress);  
        // @dev Formulate the OFT receipt.  
        oftReceipt = OFTReceipt(amountSentLD, amountReceivedLD);  
      
        emit OFTSent(msgReceipt.guid, _sendParam.dstEid, msg.sender, amountSentLD, amountReceivedLD);  
    }  
    

You can override the `_debit` function with any additional logic you want to
execute before the message is sent via the protocol, for example, taking
custom fees.

All of the previous functions use the `_debitView` function to handle how many
tokens should be debited on the source chain, versus credited on the
destination.

This function can be overridden, allowing your OFT to implement custom fees by
changing the `amountSentLD` and `amountReceivedLD` amounts:

    
    
    /**  
     * @dev Internal function to mock the amount mutation from a OFT debit() operation.  
     * @param _amountLD The amount to send in local decimals.  
     * @param _minAmountLD The minimum amount to send in local decimals.  
     * @dev _dstEid The destination endpoint ID.  
     * @return amountSentLD The amount sent, in local decimals.  
     * @return amountReceivedLD The amount to be received on the remote chain, in local decimals.  
     *  
     * @dev This is where things like fees would be calculated and deducted from the amount to be received on the remote.  
     */  
    function _debitView(  
        uint256 _amountLD,  
        uint256 _minAmountLD,  
        uint32 /*_dstEid*/  
    ) internal view virtual returns (uint256 amountSentLD, uint256 amountReceivedLD) {  
        // @dev Remove the dust so nothing is lost on the conversion between chains with different decimals for the token.  
        amountSentLD = _removeDust(_amountLD);  
        // @dev The amount to send is the same as amount received in the default implementation.  
        amountReceivedLD = amountSentLD;  
      
        // @dev Check for slippage.  
        if (amountReceivedLD < _minAmountLD) {  
            revert SlippageExceeded(amountReceivedLD, _minAmountLD);  
        }  
    }  
    

caution

The highlighted line above demonstrates how the OFT is safe from overflow
because it reduces the size of `_amountLD` to a value that fits within the
expected range of the destination chain's precision by calling `_removeDust`.

This method looks at the desired amount of tokens to transfer and only allows
the sender to send values that meet the allowed decimal precision.

If you add fees to `_debitView`, make sure you implement the fee before
calling `_removeDust`, so that the OFT can still maintain the correct level of
decimal precision.

Review **Token Transfer Precision** to learn more about removing dust values.

### Adding Receive Logic​

Similar to `send`, you can add custom logic when receiving an ERC20 token
transfer on the destination chain by overriding the `_credit` function.

    
    
    /**  
     * @dev Credits tokens to the specified address.  
     * @param _to The address to credit the tokens to.  
     * @param _amountLD The amount of tokens to credit in local decimals.  
     * @dev _srcEid The source chain ID.  
     * @return amountReceivedLD The amount of tokens ACTUALLY received in local decimals.  
     */  
    function _credit(  
        address _to,  
        uint256 _amountLD,  
        uint32 /*_srcEid*/  
    ) internal virtual override returns (uint256 amountReceivedLD) {  
        if (_to == address(0x0)) _to = address(0xdead); // _mint(...) does not support address(0x0)  
        // @dev Default OFT mints on dst.  
        _mint(_to, _amountLD);  
        // @dev In the case of NON-default OFT, the _amountLD MIGHT not be == amountReceivedLD.  
        return _amountLD;  
    }  
    

### Setting Delegates​

In an OFT, a delegate can be assigned to implement custom configurations on
behalf of the contract owner. This delegate gains the ability to handle
various critical tasks such as setting configurations and skipping inbound
packets for the OFT.

By default, the contract owner is set as the delegate. The `setDelegate`
function allows for changing this, but you should generally keep the contract
owner as delegate.

    
    
    function setDelegate(address _delegate) public onlyOwner {  
        endpoint.setDelegate(_delegate);  
    }  
    

For instructions on how to implement custom configurations after setting your
delegate, refer to the [OApp Configuration](/v2/developers/evm/protocol-gas-
settings/default-config).

### Security and Governance​

Given the impact associated with deployment, configuration, and debugging
functions, OFT owners may want to add additional security measures in place to
call core contract functions instead of `onlyOwner`, such as:

  * **Governance Controls** : Implementing a governance mechanism where decisions to clear messages are voted upon by stakeholders.

  * **Multisig Deployment** : Deploying with a multisig wallet, preventing arbitrary actions by any one team member.

  * **Timelocks** : Using a timelock to delay the execution of the clear function, giving stakeholders time to react if the function is called inappropriately.

info

Any normal access control library can be added to the base OFT Standard. The
only relevant difference is that these access controls will need to coordinate
across multiple contract implementations, since a deployed OFT typically
consists of an OFT contract on every connected chain.

## Deployment & Usage​

You can now deploy your contracts and get one step closer to moving fungible
tokens between chains.

### Setting Trusted Peers​

You should only connect your OFT deployments together after setting your DVN
and Executor configuration (see the [Configuration
Guide](/v2/developers/evm/protocol-gas-settings/default-config) or [`create-
lz-oapp` CLI tool](/v2/developers/evm/create-lz-oapp/configuring-pathways)).

Once you've finished configuring your OFT, you can connect your OFT deployment
to different chains by calling `setPeer`.

The function takes 2 arguments: `_eid`, the endpoint ID for the destination
chain that the other OFT contract lives on, and `_peer`, the destination OFT's
contract address in `bytes32` format.

    
    
    // @dev must-have configurations for standard OApps  
    function setPeer(uint32 _eid, bytes32 _peer) public virtual onlyOwner {  
        peers[_eid] = _peer; // Array of peer addresses by destination.  
        emit PeerSet(_eid, _peer); // Event emitted each time a peer is set.  
    }  
    

caution

`setPeer` opens your OFT to start receiving messages from the messaging
channel, meaning you should configure any application settings you intend on
changing prior to calling `setPeer`.

  

danger

OFTs need `setPeer` to be called correctly on both contracts to send messages.
The peer address uses `bytes32` for handling non-EVM destination chains.

If the peer has been set to an incorrect destination address, your messages
will not be delivered and handled properly. If not resolved, users can burn
source funds without a corresponding mint on destination. You can confirm the
peer address is the expected destination OFT address by using the `isPeer`
function.

  

The [LayerZero Endpoint](/v2/home/protocol/layerzero-endpoint) will use this
peer as the destination address when sending the cross-chain message:

    
    
    // @dev the endpoint send method called by _lzSend  
    endpoint.send{ value: messageValue }(  
        MessagingParams(_dstEid, _getPeerOrRevert(_dstEid), _message, _options, _fee.lzTokenFee > 0),  
        _refundAddress  
    );  
    

The destination Endpoint will check if the `_receiver` matches the OFT
contract's expected peer before delivering the message on the destination
chain:

    
    
    function _initializable(  
        Origin calldata _origin,  
        address _receiver,  
        uint64 _lazyInboundNonce  
    ) internal view returns (bool) {  
        return  
            _lazyInboundNonce > 0 || // allowInitializePath already checked  
            ILayerZeroReceiver(_receiver).allowInitializePath(_origin);  
    }  
    

To see if an address is the trusted peer you expect for a destination, you can
read the `peers` mapping directly:

    
    
    /**  
     * @dev Internal function to check if peer is considered 'trusted' by the OApp.  
     * @param _eid The endpoint ID to check.  
     * @param _peer The peer to check.  
     * @return Whether the peer passed is considered 'trusted' by the OApp.  
     *  
     * @dev Enables OAppPreCrimeSimulator to check whether a potential Inbound Packet is from a trusted source.  
     */  
    function isPeer(uint32 _eid, bytes32 _peer) public view virtual override returns (bool) {  
        return peers[_eid] == _peer;  
    }  
    

This can be useful for confirming whether `setPeer` has been called correctly
and as expected.

### Message Execution Options​

`_options` are a generated bytes array with specific instructions for the
[DVNs](/v2/home/modular-security/security-stack-dvns) and
[Executor](/v2/home/permissionless-execution/executors) to use when handling
the authentication and execution of received messages.

You can find how to generate all the available `_options` in [Message
Execution Options](/v2/developers/evm/protocol-gas-settings/options), but for
this tutorial we'll focus on how options work with OFT.

  * `ExecutorLzReceiveOption`: instructions for how much gas the Executor should use when calling `lzReceive` on the destination Endpoint.

For example, usually to send a vanilla OFT to a destination chain you will
need `60000` wei in native gas on destination. The options will look like the
following:

    
    
    _options = 0x0003010011010000000000000000000000000000ea60;  
    

tip

`ExecutorLzReceiveOption` specifies a quote paid in advance on the source
chain by the `msg.sender` for the equivalent amount of native gas to be used
on the destination chain. If the actual cost to execute the message is less
than what was set in `_options`, there is no default way to refund the sender
the difference. Application developers need to thoroughly profile and test gas
amounts to ensure consumed gas amounts are correct and not excessive.

#### Setting Enforced Options​

Once you determine ideal message `_options`, you will want to make sure users
adhere to it. In the case of OFT, you mostly want to make sure the gas is
enough for transferring the ERC20 token, plus any additional logic.

A typical OFT's `lzReceive` call will use `60000` gas on most EVM chains, so
you can enforce this option to require callers to pay a `60000` gas limit in
the source chain transaction to prevent out of gas issues:

    
    
    _options = 0x0003010011010000000000000000000000000000ea60;  
    

tip

You can use the [**`create-lz-oapp`**](/v2/developers/evm/create-lz-
oapp/configuring-pathways#adding-enforcedoptions) npx package to set
`enforcedOptions` in a human readable format by defining your settings in your
`layerzero.config.ts`.

The `setEnforcedOptions` function allows the contract owner to specify
mandatory execution options, making sure that the application behaves as
expected when users interact with it.

    
    
    // inherited from `oapp/libs/OAppOptionsType3.sol`:  
    /**  
     * @dev Sets the enforced options for specific endpoint and message type combinations.  
     * @param _enforcedOptions An array of EnforcedOptionParam structures specifying enforced options.  
     *  
     * @dev Only the owner/admin of the OApp can call this function.  
     * @dev Provides a way for the OApp to enforce things like paying for PreCrime, AND/OR minimum dst lzReceive gas amounts etc.  
     * @dev These enforced options can vary as the potential options/execution on the remote may differ as per the msgType.  
     * eg. Amount of lzReceive() gas necessary to deliver a lzCompose() message adds overhead you dont want to pay  
     * if you are only making a standard LayerZero message ie. lzReceive() WITHOUT sendCompose().  
     */  
    function setEnforcedOptions(EnforcedOptionParam[] calldata _enforcedOptions) public virtual onlyOwner {  
        _setEnforcedOptions(_enforcedOptions);  
    }  
      
    function _setEnforcedOptions(EnforcedOptionParam[] memory _enforcedOptions) internal virtual {  
        for (uint256 i = 0; i < _enforcedOptions.length; i++) {  
            // @dev Enforced options are only available for optionType 3, as type 1 and 2 dont support combining.  
            _assertOptionsType3(_enforcedOptions[i].options);  
            enforcedOptions[_enforcedOptions[i].eid][_enforcedOptions[i].msgType] = _enforcedOptions[i].options;  
        }  
      
        emit EnforcedOptionSet(_enforcedOptions);  
    }  
    

To use `setEnforcedOptions`, we only need to pass one parameter:

  * `EnforcedOptionParam[]`: a struct specifying the execution options per message type and destination chain.
    
        struct EnforcedOptionParam {  
        uint32 eid; // destination endpoint id  
        uint16 msgType; // the message type  
        bytes options; // the execution option bytes array  
    }  
    

The OFT Standard only has handling for 2 message types:

    
        // @dev execution types to handle different enforcedOptions  
    uint16 internal constant SEND = 1; // a standard token transfer via send()  
    uint16 internal constant SEND_AND_CALL = 2; // a composed token transfer via send()  
    

Pass these values in when specifying the `msgType` for your `_options`.

For best practice, generate this array off-chain and pass it as a parameter
when configuring your OFT:

    
    
    EnforcedOptionParam[] memory aEnforcedOptions = new EnforcedOptionParam[](1);  
    // Send gas for lzReceive (A -> B).  
    aEnforcedOptions[0] = EnforcedOptionParam({eid: bEid, msgType: SEND, options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(65000, 0)});  
      
    // Call the setEnforcedOptions function  
    aOFT.setEnforcedOptions(aEnforcedOptions);  
    

caution

When setting `enforcedOptions`, try not to unintentionally pass a duplicate
`_options` argument to `extraOptions`. Passing identical `_options` in both
`enforcedOptions` and `extraOptions` will cause the protocol to charge the
caller twice on the source chain, because LayerZero interprets duplicate
`_options` as two separate requests for gas.

#### Setting Extra Options​

Any `_options` passed in the `send` call itself should be considered
`_extraOptions`.

`_extraOptions` can specify additional handling within the same message type.
These `_options` will then be combined with `enforcedOption` if set.

If not needed in your application, you should pass an empty bytes array `0x`.

    
    
    if (enforced.length > 0) {  
        // combine extra options with enforced options  
        // remove the first 2 bytes (TYPE_3) of extra options  
        // should pack executor options last in enforced options (assuming most extra options are executor options only)  
        // to save gas on grouping by worker id in message library  
        uint16 extraOptionsType = uint16(bytes2(_extraOptions[0:2]));  
        uint16 enforcedOptionsType = (uint16(uint8(enforced[0])) << 8) + uint8(enforced[1]);  
        if (extraOptionsType != enforcedOptionsType) revert InvalidOptions();  
        options = bytes.concat(enforced, _extraOptions[2:]);  
    } else {  
        // no enforced options, use extra options directly  
        options = _extraOptions;  
    }  
    

caution

As outlined above, decide on whether you need an application wide option via
`enforcedOptions` or a call specific option using `extraOptions`. Be specific
in what `_options` you use for both parameters, as your transactions will
reflect the exact settings you implement.

### Estimating Gas Fees​

Now let's get an estimate of how much gas a transfer will cost to be sent and
received.

To do this we can call the `quoteSend` function to return an estimate from the
Endpoint contract to use as a recommended `msg.value`.

Arguments of the estimate function:

  1. `SendParam`: what parameters should be used for the send call?
    
        /**  
     * @dev Struct representing token parameters for the OFT send() operation.  
     */  
     struct SendParam {  
         uint32 dstEid; // Destination endpoint ID.  
         bytes32 to; // Recipient address.  
         uint256 amountLD; // Amount to send in local decimals.  
         uint256 minAmountLD; // Minimum amount to send in local decimals.  
         bytes extraOptions; // Additional options supplied by the caller to be used in the LayerZero message.  
         bytes composeMsg; // The composed message for the send() operation.  
         bytes oftCmd; // The OFT command to be executed, unused in default OFT implementations.  
     }  
    

note

Here is a link to further explain Extra Message Options that would be used
besides `enforcedOptions`.

  2. `_payInLzToken`: what token will be used to pay for the transaction?
    
        struct MessagingFee {  
        uint nativeFee; // gas amount in native gas token  
        uint lzTokenFee; // gas amount in ZRO token  
    }  
    

    
    
    /**  
         * @notice Provides a quote for the send() operation.  
         * @param _sendParam The parameters for the send() operation.  
         * @param _payInLzToken Flag indicating whether the caller is paying in the LZ token.  
         * @return msgFee The calculated LayerZero messaging fee from the send() operation.  
         *  
         * @dev MessagingFee: LayerZero msg fee  
         *  - nativeFee: The native fee.  
         *  - lzTokenFee: The lzToken fee.  
         */  
        function quoteSend(  
            SendParam calldata _sendParam,  
            bool _payInLzToken  
        ) external view virtual returns (MessagingFee memory msgFee) {  
            // @dev mock the amount to receive, this is the same operation used in the send().  
            // The quote is as similar as possible to the actual send() operation.  
            (, uint256 amountReceivedLD) = _debitView(_sendParam.amountLD, _sendParam.minAmountLD, _sendParam.dstEid);  
      
            // @dev Builds the options and OFT message to quote in the endpoint.  
            (bytes memory message, bytes memory options) = _buildMsgAndOptions(_sendParam, amountReceivedLD);  
      
            // @dev Calculates the LayerZero fee for the send() operation.  
            return _quote(_sendParam.dstEid, message, options, _payInLzToken);  
        }  
    

### Calling `send`​

Since the `send` logic has already been defined, we'll instead view how the
function should be called.

  * Hardhat Task
  * Foundry Script

    
    
    import {task} from 'hardhat/config';  
    import {getNetworkNameForEid, types} from '@layerzerolabs/devtools-evm-hardhat';  
    import {EndpointId} from '@layerzerolabs/lz-definitions';  
    import {addressToBytes32} from '@layerzerolabs/lz-v2-utilities';  
    import {Options} from '@layerzerolabs/lz-v2-utilities';  
    import {BigNumberish, BytesLike} from 'ethers';  
      
    interface Args {  
      amount: string;  
      to: string;  
      toEid: EndpointId;  
    }  
      
    interface SendParam {  
      dstEid: EndpointId; // Destination endpoint ID, represented as a number.  
      to: BytesLike; // Recipient address, represented as bytes.  
      amountLD: BigNumberish; // Amount to send in local decimals.  
      minAmountLD: BigNumberish; // Minimum amount to send in local decimals.  
      extraOptions: BytesLike; // Additional options supplied by the caller to be used in the LayerZero message.  
      composeMsg: BytesLike; // The composed message for the send() operation.  
      oftCmd: BytesLike; // The OFT command to be executed, unused in default OFT implementations.  
    }  
      
    // send tokens from a contract on one network to another  
    task('lz:oft:send', 'Sends tokens from either OFT or OFTAdapter')  
      .addParam('to', 'contract address on network B', undefined, types.string)  
      .addParam('toEid', 'destination endpoint ID', undefined, types.eid)  
      .addParam('amount', 'amount to transfer in token decimals', undefined, types.string)  
      .setAction(async (taskArgs: Args, {ethers, deployments}) => {  
        const toAddress = taskArgs.to;  
        const eidB = taskArgs.toEid;  
      
        // Get the contract factories  
        const oftDeployment = await deployments.get('MyOFT');  
      
        const [signer] = await ethers.getSigners();  
      
        // Create contract instances  
        const oftContract = new ethers.Contract(oftDeployment.address, oftDeployment.abi, signer);  
      
        const decimals = await oftContract.decimals();  
        const amount = ethers.utils.parseUnits(taskArgs.amount, decimals);  
        let options = Options.newOptions().addExecutorLzReceiveOption(65000, 0).toBytes();  
      
        // Now you can interact with the correct contract  
        const oft = oftContract;  
      
        const sendParam: SendParam = {  
          dstEid: eidB,  
          to: addressToBytes32(toAddress),  
          amountLD: amount,  
          minAmountLD: amount,  
          extraOptions: options,  
          composeMsg: ethers.utils.arrayify('0x'), // Assuming no composed message  
          oftCmd: ethers.utils.arrayify('0x'), // Assuming no OFT command is needed  
        };  
        // Get the quote for the send operation  
        const feeQuote = await oft.quoteSend(sendParam, false);  
        const nativeFee = feeQuote.nativeFee;  
      
        console.log(  
          `sending ${taskArgs.amount} token(s) to network ${getNetworkNameForEid(eidB)} (${eidB})`,  
        );  
      
        const ERC20Factory = await ethers.getContractFactory('ERC20');  
        const innerTokenAddress = await oft.token();  
      
        // // If the token address !== address(this), then this is an OFT Adapter  
        // if (innerTokenAddress !== oft.address) {  
        //     // If the contract is OFT Adapter, get decimals from the inner token  
        //     const innerToken = ERC20Factory.attach(innerTokenAddress);  
      
        //     // Approve the amount to be spent by the oft contract  
        //     await innerToken.approve(oftDeployment.address, amount);  
        // }  
      
        const r = await oft.send(sendParam, {nativeFee: nativeFee, lzTokenFee: 0}, signer.address, {  
          value: nativeFee,  
        });  
        console.log(`Send tx initiated. See: https://layerzeroscan.com/tx/${r.hash}`);  
      });  
    
    
    
    // SPDX-License-Identifier: UNLICENSED  
    pragma solidity ^0.8.13;  
      
    import {Script, console} from "forge-std/Script.sol";  
      
    import { IOAppCore } from "@layerzerolabs/oapp-evm/contracts/oapp/interfaces/IOAppCore.sol";  
    import { SendParam, OFTReceipt } from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";  
    import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";  
    import { MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";  
    import { MyOFT } from "../contracts/MyOFT.sol";  
      
    contract SendOFT is Script {  
        using OptionsBuilder for bytes;  
      
        /**  
         * @dev Converts an address to bytes32.  
         * @param _addr The address to convert.  
         * @return The bytes32 representation of the address.  
         */  
        function addressToBytes32(address _addr) internal pure returns (bytes32) {  
            return bytes32(uint256(uint160(_addr)));  
        }  
      
        function run() public {  
            // Fetching environment variables  
            address oftAddress = vm.envAddress("OFT_ADDRESS");  
            address toAddress = vm.envAddress("TO_ADDRESS");  
            uint256 _tokensToSend = vm.envUint("TOKENS_TO_SEND");  
      
            // Fetch the private key from environment variable  
            uint256 privateKey = vm.envUint("PRIVATE_KEY");  
      
            // Start broadcasting with the private key  
            vm.startBroadcast(privateKey);  
      
            MyOFT sourceOFT = MyOFT(oftAddress);  
      
            bytes memory _extraOptions = OptionsBuilder.newOptions().addExecutorLzReceiveOption(65000, 0);  
            SendParam memory sendParam = SendParam(  
                30111, // You can also make this dynamic if needed  
                addressToBytes32(toAddress),  
                _tokensToSend,  
                _tokensToSend * 9 / 10,  
                _extraOptions,  
                "",  
                ""  
            );  
      
            MessagingFee memory fee = sourceOFT.quoteSend(sendParam, false);  
      
            console.log("Fee amount: ", fee.nativeFee);  
      
            sourceOFT.send{value: fee.nativeFee}(sendParam, fee, msg.sender);  
      
            // Stop broadcasting  
            vm.stopBroadcast();  
        }  
    }  
      
    

Below you can find the send method itself.

    
    
    // @dev executes a cross-chain OFT swap via layerZero Endpoint  
     function send(  
        SendParam calldata _sendParam,  
        MessagingFee calldata _fee,  
        address _refundAddress  
    ) external payable virtual returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt) {  
        // @dev Applies the token transfers regarding this send() operation.  
        // - amountSentLD is the amount in local decimals that was ACTUALLY sent/debited from the sender.  
        // - amountReceivedLD is the amount in local decimals that will be received/credited to the recipient on the remote OFT instance.  
        (uint256 amountSentLD, uint256 amountReceivedLD) = _debit(  
            _sendParam.amountLD,  
            _sendParam.minAmountLD,  
            _sendParam.dstEid  
        );  
      
        // @dev Builds the options and OFT message to quote in the endpoint.  
        (bytes memory message, bytes memory options) = _buildMsgAndOptions(_sendParam, amountReceivedLD);  
      
        // @dev Sends the message to the LayerZero endpoint and returns the LayerZero msg receipt.  
        msgReceipt = _lzSend(_sendParam.dstEid, message, options, _fee, _refundAddress);  
        // @dev Formulate the OFT receipt.  
        oftReceipt = OFTReceipt(amountSentLD, amountReceivedLD);  
      
        emit OFTSent(msgReceipt.guid, _sendParam.dstEid, msg.sender, amountSentLD, amountReceivedLD);  
    }  
    

To do this, we only need to pass `send` a few inputs:

  1. `SendParam`: what parameters should be used for the send call?
    
         struct SendParam {  
         uint32 dstEid; // Destination endpoint ID.  
         bytes32 to; // Recipient address.  
         uint256 amountLD; // Amount to send in local decimals.  
         uint256 minAmountLD; // Minimum amount to send in local decimals.  
         bytes extraOptions; // Additional options supplied by the caller to be used in the LayerZero message.  
         bytes composeMsg; // The composed message for the send() operation.  
         bytes oftCmd; // The OFT command to be executed, unused in default OFT implementations.  
     }  
    

info

`extraOptions` allow a caller to define an additional amount of `gas_limit`
and `msg.value` to deliver to the destination chain along with the required
amount set by the contract owner (`enforcedOptions`).

  

  2. `_fee`: what token will be used to pay for the transaction?
    
        struct MessagingFee {  
        uint nativeFee; // gas amount in native gas token  
        uint lzTokenFee; // gas amount in ZRO token  
    }  
    

  3. `_refundAddress`: If the transaction fails on the source chain, where should funds be refunded?

#### Optional: `_composedMsg`​

When sending an OFT, you can also include an optional `_composedMsg` parameter
in the transaction to execute additional logic on the destination chain as
part of the token transfer.

    
    
    // @dev executes an omnichain OFT swap via layerZero Endpoint  
    if (_composeMsg.length > 0) {  
        // @dev Remote chains will want to know the composed function caller.  
        // ALSO, the presence of a composeFrom msg.sender inside of the bytes array indicates the payload should  
        // be composed. ie. this allows users to compose with an empty payload, vs it must be length > 0  
        _composeMsg = abi.encodePacked(OFTMsgCodec.addressToBytes32(msg.sender), _composeMsg);  
    }  
      
    msgReceipt = _sendInternal(  
        _send,  
        combineOptions(_send.dstEid, SEND_AND_CALL, _extraOptions),  
        _msgFee, // message fee  
        _refundAddress, // refund address for failed source tx  
        _composeMsg // composed message  
    );  
    

On the destination chain, the `_lzReceive` function will first process the
token transfer, crediting the recipient's account with the specified amount,
and then check if `_message.isComposed()`.

    
    
    if (_message.isComposed()) {  
        bytes memory composeMsg = OFTComposeMsgCodec.encode(  
            _origin.nonce, // nonce of the origin transaction  
            _origin.srcEid, // source endpoint id of the transaction  
            amountLDReceive, // the token amount in local decimals to credit  
            _message.composeMsg() // the composed message  
        );  
        // @dev Stores the lzCompose payload that will be executed in a separate tx.  
        // standardizes functionality for delivering/executing arbitrary contract invocation on some non evm chains.  
        // @dev Composed toAddress is the same as the receiver of the oft/tokens  
        endpoint.deliverComposedMessage(toAddress, _guid, composeMsg);  
    }  
    

If the message is composed, the contract retrieves and re-encodes the
additional composed message information, then delivers the message to the
endpoint, which will execute the additional logic as a separate transaction.

#### Optional: `_oftCmd`​

The `_oftCmd` is a `bytes` array that can be used like a function selector on
the destination chain that you can check for within `_lzReceive` similar to
`lzCompose` for custom OFT implementations.

### `_lzReceive` tokens​

A successful `send` call will be delivered to the destination chain, invoking
the provided `_lzReceive` method during execution:

    
    
    function _lzReceive(  
        Origin calldata _origin,  
        bytes32 _guid,  
        bytes calldata _message,  
        address /*_executor*/,  
        bytes calldata /*_extraData*/  
    ) internal virtual override {  
        // @dev sendTo is always a bytes32 as the remote chain initiating the call doesnt know remote chain address size  
        address toAddress = _message.sendTo().bytes32ToAddress();  
      
        uint256 amountToCreditLD = _toLD(_message.amountSD());  
        uint256 amountReceivedLD = _credit(toAddress, amountToCreditLD, _origin.srcEid);  
      
        if (_message.isComposed()) {  
            bytes memory composeMsg = OFTComposeMsgCodec.encode(  
                _origin.nonce,  
                _origin.srcEid,  
                amountReceivedLD,  
                _message.composeMsg()  
            );  
            // @dev Stores the lzCompose payload that will be executed in a separate tx.  
            // standardizes functionality for executing arbitrary contract invocation on some non-evm chains.  
            // @dev Composed toAddress is the same as the receiver of the oft/tokens  
            // TODO need to document the index / understand how to use it properly  
            endpoint.sendCompose(toAddress, _guid, 0, composeMsg);  
        }  
      
        emit OFTReceived(_guid, toAddress, amountToCreditLD, amountReceivedLD);  
    }  
    

#### `_credit`:​

When receiving the message on your destination contract, `_credit` is invoked,
triggering the final steps to mint an ERC20 token on the destination to the
specified address.

    
    
    function _credit(  
        address _to,  
        uint256 _amountToCreditLD,  
        uint32 /*_srcEid*/  
    ) internal virtual override returns (uint256 amountReceivedLD) {  
        _mint(_to, _amountToCreditLD);  
        return _amountToCreditLD;  
    }  
    

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/oft/quickstart.md)

[PreviousOmnichain Application
(OApp)](/v2/developers/evm/oapp/overview)[NextOmnichain NFT
(ONFT)](/v2/developers/evm/onft/quickstart)

  * Installation
  * Constructing an OFT Contract
  * Deployment Workflow
    * OFTCore
    * Token Supply Cap
    * Token Transfer Precision
    * Adding Send Logic
    * Adding Receive Logic
    * Setting Delegates
    * Security and Governance
  * Deployment & Usage
    * Setting Trusted Peers
    * Message Execution Options
    * Estimating Gas Fees
    * Calling `send`
    * `_lzReceive` tokens



  * Protocol
  * Contract Standards

Version: Endpoint V2 Docs

On this page

# Contract Standards

Developers can easily start building omnichain applications by inheriting and
extending [LayerZero Contract Standards](/v2/developers/evm/overview) that
seamlessly integrate with the protocol's interfaces.

LayerZero offers a suite of template contracts to expedite the development
process. These templates serve as foundational blueprints for developers to
build upon:

## `OApp`​

The [OApp Contract Standard](/v2/developers/evm/oapp/overview) provides
developers with a generic message passing interface to send and receive
arbitrary pieces of data between contracts existing on different blockchain
networks.

![OApp
Example](/assets/images/ABLight-b6e0a32bf1941c8956b7073f1687dd76.svg#gh-light-
mode-only) ![OApp
Example](/assets/images/ABDark-a499c3ef51835bc97613e2f4cba97f22.svg#gh-dark-
mode-only)

This standard abstracts away the core Endpoint interfaces, allowing you to
focus on your application's core implementation and features without needing a
complex understanding of the LayerZero protocol architecture.

This interface can easily be extended to include anything from specific
financial logic in a DeFi application to a voting mechanism in a DAO, or
broadly any smart contract use case.

## `OFT`​

The [Omnichain Fungible Token (OFT)](/v2/developers/evm/oft/quickstart)
Standard allows **fungible tokens** to be transferred across multiple
blockchains without asset wrapping or middlechains.

This standard works by burning tokens on the source chain whenever an
omnichain transfer is initiated, sending a message via the protocol, and
delivering a function call to the destination contract to mint the same number
of tokens burned. This creates a **unified supply** across all networks
LayerZero supports that the OFT is deployed on.

![OFT
Example](/assets/images/oft_mechanism_light-922b88c364b5156e26edc6def94069f1.jpg#gh-
light-mode-only) ![OFT
Example](/assets/images/oft_mechanism-0894f9bd02de35d6d7ce3d648a2df574.jpg#gh-
dark-mode-only)

Using this design pattern, developers can **extend** any fungible token to
interoperate with other chains using LayerZero. The most widely used of these
standards is `OFT.sol`, an extension of the [OApp Contract
Standard](/v2/developers/evm/oapp/overview) and the [ERC20 Token
Standard](https://docs.openzeppelin.com/contracts/5.x/erc20).

## Configuration​

All Contract Standards offer an opt-in default [OApp
Configuration](/v2/developers/evm/protocol-gas-settings/default-config),
allowing for rapid development without needing complex setup or post-
deployment configuration.

The OApp owner or delegated signer can change or lock your configuration at
any time.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/protocol/contract-standards.md)

[PreviousOmnichain Mesh Network](/v2/home/protocol/mesh-network)[NextLayerZero
Endpoint](/v2/home/protocol/layerzero-endpoint)

  * `OApp`
  * `OFT`
  * Configuration



  * LayerZero V2
  * Welcome

Version: Endpoint V2 Docs

On this page

# Explore LayerZero V2

[LayerZero V2](https://layerzero.network/) is an open-source, immutable
messaging protocol designed to facilitate the creation of omnichain,
interoperable applications.

Developers can easily [send arbitrary data](/v2/home/protocol/contract-
standards#oapp), [external function calls](/v2/developers/evm/oapp/message-
design-patterns), and [tokens](/v2/home/protocol/contract-standards#oft) with
omnichain messaging while preserving full autonomy and control over their
application.

LayerZero V2 is currently live on the following [Mainnet and Testnet
Chains](/v2/developers/evm/technical-reference/deployed-contracts).

[![](/img/icons/build.svg)Getting StartedStart building on LayerZero by
sending your first omnichain message.View More ](/v2/developers/evm/getting-
started)

[![](/img/icons/protocol.svg)Supported ChainsDiscover which chains the
LayerZero V2 Endpoint is live on.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Supported SecuritySee which Decentralized Verifier
Networks (DVNs) can be added to secure your omnichain app.View More
](/v2/developers/evm/technical-reference/dvn-addresses)

[![](/img/icons/Ethereum-logo-test.svg)Solidity DevelopersResources to help
you quickly build, launch, and scale your EVM omnichain applications.View More
](/v2/developers/evm/overview)

[![](/img/icons/solanaLogoMark.svg)Solana DevelopersResources to build your
LayerZero applications on the Solana blockchain.View More
](/v2/developers/solana/overview)

  
  

See the Quickstart Guide below for specific guides on every topic related to
building with the LayerZero protocol.

## Quickstart​

Comprehensive developer guides for every step of your omnichain journey.

[![](/img/icons/build.svg)OApp OverviewBuild your first Omnichain Application
(OApp), using the LayerZero Contract Standards.View More
](/v2/developers/evm/oapp/overview)

[![](/img/icons/build.svg)Build an OFTBuild an Omnichain Fungible Token (OFT)
using familiar fungible token standards.View More
](/v2/developers/evm/oft/quickstart)

[![](/img/icons/build.svg)Estimating Gas FeesGenerate a quote of your
omnichain message gas costs before sending.View More
](/v2/developers/evm/protocol-gas-settings/gas-fees)

[![](/img/icons/config.svg)Generating OptionsBuild message options to control
gas settings, nonce ordering, and more.View More
](/v2/developers/evm/protocol-gas-settings/options)

[![](/img/icons/config.svg)Chain EndpointsThe addresses and endpoint IDs for
every supported chain.View More ](/v2/developers/evm/technical-
reference/deployed-contracts)

[![](/img/icons/config.svg)Configure OAppConfigure your Security Stack,
Executors, and other application specific settings.View More
](/v2/developers/evm/protocol-gas-settings/default-config)

[![](/img/icons/testing.svg)Track MessagesFollow your omnichain messages using
LayerZero Scan.View More ](/v2/developers/evm/tooling/layerzeroscan)

[![](/img/icons/testing.svg)TroubleshootingFind answers to common questions
and debugging support.View More
](/v2/developers/evm/troubleshooting/debugging-messages)

[![](/img/icons/testing.svg)Endpoint V1 DocsFind legacy support for LayerZero
Endpoint V1 here.View More ](/v1)

## Security​

LayerZero Labs has an absolute commitment to continuously evaluating and
improving protocol security:

  * [Core contracts are immutable](/v2/home/protocol/layerzero-endpoint) and LayerZero Labs will never deploy upgradeable contracts.

  * While application contracts come pre-configured with an optimal default, application owners can opt out of updates by [modifying and locking protocol configurations](/v2/developers/evm/protocol-gas-settings/default-config#custom-configuration).

  * Protocol updates will always be [optional and backward compatible](/v2/home/protocol/message-library).

LayerZero protocol has been thoroughly audited by leading organizations
building decentralized systems. Browse through [past public
audits](https://github.com/LayerZero-Labs/Audits/tree/main/audits) in our
Github.

## More from LayerZero​

### Questions?​

Join the LayerZero community in our [Discord](https://discord-
layerzero.netlify.app/discord) to ask for help, as well as share your feedback
or showcase what you have built with LayerZero!

### Careers​

LayerZero is growing. If you enjoy using our protocol and have a genuine
interest in omnichain design, please check out [our current job
openings](https://layerzero.network/careers).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/intro.md)

[NextV2 Overview](/v2/home/v2-overview)

  * Quickstart
  * Security
  * More from LayerZero
    * Questions?
    * Careers



  * Protocol
  * Contract Standards

Version: Endpoint V2 Docs

On this page

# Contract Standards

Developers can easily start building omnichain applications by inheriting and
extending [LayerZero Contract Standards](/v2/developers/evm/overview) that
seamlessly integrate with the protocol's interfaces.

LayerZero offers a suite of template contracts to expedite the development
process. These templates serve as foundational blueprints for developers to
build upon:

## `OApp`​

The [OApp Contract Standard](/v2/developers/evm/oapp/overview) provides
developers with a generic message passing interface to send and receive
arbitrary pieces of data between contracts existing on different blockchain
networks.

![OApp
Example](/assets/images/ABLight-b6e0a32bf1941c8956b7073f1687dd76.svg#gh-light-
mode-only) ![OApp
Example](/assets/images/ABDark-a499c3ef51835bc97613e2f4cba97f22.svg#gh-dark-
mode-only)

This standard abstracts away the core Endpoint interfaces, allowing you to
focus on your application's core implementation and features without needing a
complex understanding of the LayerZero protocol architecture.

This interface can easily be extended to include anything from specific
financial logic in a DeFi application to a voting mechanism in a DAO, or
broadly any smart contract use case.

## `OFT`​

The [Omnichain Fungible Token (OFT)](/v2/developers/evm/oft/quickstart)
Standard allows **fungible tokens** to be transferred across multiple
blockchains without asset wrapping or middlechains.

This standard works by burning tokens on the source chain whenever an
omnichain transfer is initiated, sending a message via the protocol, and
delivering a function call to the destination contract to mint the same number
of tokens burned. This creates a **unified supply** across all networks
LayerZero supports that the OFT is deployed on.

![OFT
Example](/assets/images/oft_mechanism_light-922b88c364b5156e26edc6def94069f1.jpg#gh-
light-mode-only) ![OFT
Example](/assets/images/oft_mechanism-0894f9bd02de35d6d7ce3d648a2df574.jpg#gh-
dark-mode-only)

Using this design pattern, developers can **extend** any fungible token to
interoperate with other chains using LayerZero. The most widely used of these
standards is `OFT.sol`, an extension of the [OApp Contract
Standard](/v2/developers/evm/oapp/overview) and the [ERC20 Token
Standard](https://docs.openzeppelin.com/contracts/5.x/erc20).

## Configuration​

All Contract Standards offer an opt-in default [OApp
Configuration](/v2/developers/evm/protocol-gas-settings/default-config),
allowing for rapid development without needing complex setup or post-
deployment configuration.

The OApp owner or delegated signer can change or lock your configuration at
any time.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/protocol/contract-standards.md)

[PreviousOmnichain Mesh Network](/v2/home/protocol/mesh-network)[NextLayerZero
Endpoint](/v2/home/protocol/layerzero-endpoint)

  * `OApp`
  * `OFT`
  * Configuration



  * Getting Started
  * Sending Messages

Version: Endpoint V2 Docs

On this page

# LayerZero Messages

Normally with blockchains, each network operates in isolation.

But what if you could have an interaction on one blockchain (say,
**Ethereum**) automatically trigger a reaction on another (like **Binance
Smart Chain**), all without relying on a central authority to relay that
trigger?

![OApp
Example](/assets/images/ABLight-b6e0a32bf1941c8956b7073f1687dd76.svg#gh-light-
mode-only) ![OApp
Example](/assets/images/ABDark-a499c3ef51835bc97613e2f4cba97f22.svg#gh-dark-
mode-only)

This idea is at the core of LayerZero's omnichain messaging, reshaping how
blockchains interact.

## But First, A Primer on Smart Contracts​

Before we dive deeper, let’s take a step back and look at how smart contracts
work.

At its core, a token contract on Ethereum (e.g., **ERC20**) is a smart
contract that keeps track of balances.

It uses the blockchain as a digital ledger, recording who owns what. When you
**“transfer”** tokens, you’re not moving physical objects.

Instead, the contract updates the ledger to reflect the change in ownership:

    
    
    // @dev the _transfer function from the base ERC20 token standard  
    function _transfer(address from, address to, uint256 amount) internal virtual {  
        require(from != address(0), "ERC20: transfer from the zero address");  
        require(to != address(0), "ERC20: transfer to the zero address");  
      
        _beforeTokenTransfer(from, to, amount);  
      
        uint256 fromBalance = _balances[from];  
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");  
        unchecked {  
            // @dev the sender's account is debited the amount  
            _balances[from] = fromBalance - amount;  
            // @dev the receiver's account is credited the amount  
            _balances[to] += amount;  
        }  
      
        emit Transfer(from, to, amount);  
      
        _afterTokenTransfer(from, to, amount);  
    }  
    

This ledger is the heart of every smart contract, a fundamental aspect of
blockchain technology.

## A Ledger That Lives Everywhere​

LayerZero enables your on-chain application to use any or every blockchain as
that ledger.

For example, the **Omnichain Fungible Token (OFT) Standard** allows developers
to extend the normal ERC20 token to record balances on any supported
blockchain ledger.

![OFT
Example](/assets/images/oft_mechanism_light-922b88c364b5156e26edc6def94069f1.jpg#gh-
light-mode-only) ![OFT
Example](/assets/images/oft_mechanism-0894f9bd02de35d6d7ce3d648a2df574.jpg#gh-
dark-mode-only)

  

This works by deploying an OFT contract on every blockchain you want to
interact with, enabling you to **debit** a token from an address on one
chain...

    
    
    // @dev the _debit function from the base OFT token standard  
    // @notice called on the source chain internally by the msg.sender  
    function _debit(  
        uint256 _amountLD,  
        uint256 _minAmountLD,  
        uint32 _dstEid  
    ) internal virtual override returns (uint256 amountSentLD, uint256 amountReceivedLD) {  
        (amountSentLD, amountReceivedLD) = _debitView(_amountLD, _minAmountLD, _dstEid);  
      
        // @dev In NON-default OFT, amountSentLD could be 100, with a 10% fee, the amountReceivedLD amount is 90,  
        // therefore amountSentLD CAN differ from amountReceivedLD.  
      
        // @dev Default OFT burns on src.  
        _burn(msg.sender, amountSentLD);  
    }  
    

...and **credit** it to an address on another chain.

    
    
    // @dev the _credit function from the base OFT token standard  
    // @notice called on the destination chain by the Executor  
    function _credit(  
        address _to,  
        uint256 _amountLD,  
        uint32 /*_srcEid*/  
    ) internal virtual override returns (uint256 amountReceivedLD) {  
        // @dev Default OFT mints on dst.  
        _mint(_to, _amountLD);  
        // @dev In the case of NON-default OFT, the _amountLD MIGHT not be == amountReceivedLD.  
        return _amountLD;  
    }  
    

This cross-chain interaction opens up a universe of possibilities for
decentralized applications.

## Omnichain Contract Standards​

Because every blockchain is just a digital ledger, and there are no rules
about what smart contracts on that ledger have to do, developers can create
various **omnichain standards** for determining how contracts on different
ledgers can interoperate with one another.

LayerZero offers two specialized contract standards: the **OApp** and **OFT**.

  * [OApp](/v2/developers/evm/oapp/overview): a generic message passing interface for moving arbitrary data across blockchains for custom usage.

  * [OFT](/v2/developers/evm/oft/quickstart): an omnichain ERC20 built for sending and receiving tokens across different blockchains.

Read the [Getting Started](/v2/developers/evm/getting-started) guide in the
**Developers** section to deploy your first OApp smart contract.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/getting-started/send-message.md)

[PreviousWhat is LayerZero?](/v2/home/getting-started/what-is-
layerzero)[NextProtocol Overview](/v2/home/protocol/protocol-overview)

  * But First, A Primer on Smart Contracts
  * A Ledger That Lives Everywhere
  * Omnichain Contract Standards



  * Contract Standards
  * OApp Patterns & Extensions

Version: Endpoint V2 Docs

On this page

# Design Patterns & Extensions

Each design pattern functions as a distinct omnichain building block, capable
of being used independently or in conjunction with others.

Message Pattern| Description  
---|---  
ABA| a nested send call from Chain A to Chain B that sends back again to the
source chain (`A` -> `B` -> `A`)  
Batch Send| a single send that calls multiple destination chains  
Composed| a message that transfers from a source to destination chain and
calls an external contract (`A` -> `B1` -> `B2`)  
Composed ABA| transfers data from a source to destination, calls an external
contract, and then calls back to the source (`A` -> `B1` -> `B2` -> `A`)  
Message Ordering| enforce the ordered delivery of messages on execution post
verification  
Rate Limit| rate limit the number of `send` calls for a given amount of
`messages` or `tokens` transferred  
  

This modularity allows for the seamless integration and combination of
patterns to suit specific developer requirements.

## ABA​

**AB** messaging refers to a one way send call from a source to destination
blockchain.

![OFT Example](/assets/images/ABLight-b6e0a32bf1941c8956b7073f1687dd76.svg#gh-
light-mode-only) ![OFT
Example](/assets/images/ABDark-a499c3ef51835bc97613e2f4cba97f22.svg#gh-dark-
mode-only)

In the [Getting Started Guide](/v2/developers/evm/getting-started), we use
this design pattern to send a string from Chain A to store on Chain B (`A` ->
`B`).

The **ABA** message pattern extends this simple logic by nesting another
`_lzSend` call within the destination contract's `_lzReceive` function. You
can think of this as a ping-pong style call, pinging a destination chain and
ponging back to the original source (`A` -> `B` -> `A`).

![ABA Light](/assets/images/ABAlight-fb249b677a968cf2b31c0102a79718b2.svg#gh-
light-mode-only) ![ABA
Dark](/assets/images/ABAdark-44ca6485cc8e9535054fd9c02c943d11.svg#gh-dark-
mode-only)

  

This is particularly useful when actions on one blockchain depend on the state
or confirmation of another, such as:

  * **Conditional Execution of Contracts** : A smart contract on chain A will only execute a function if a condition on chain B is met. It sends a message to chain B to check the condition and then receives a confirmation back before proceeding.

  * **Omnichain Data Feeds** : A contract on Chain A can fetch data from the destination (Chain B) to complete a process back on the source.

  * **Cross-chain Authentication** : A user or contract might authenticate on chain A, ping chain B to process something that requires this authentication, and then receive back a token or confirmation that the process was successful.

### Code Example​

This pattern demonstrates **vertical composability** , where the nested
message contains both handling for the message receipt, as well as additional
logic for a subsequent call that must all happen within one atomic
transaction.

    
    
    // SPDX-License-Identifier: MIT  
      
    pragma solidity ^0.8.22;  
      
    import { OApp, MessagingFee, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";  
    import { OAppOptionsType3 } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";  
    import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";  
      
    /**  
     * @title ABA contract for demonstrating LayerZero messaging between blockchains.  
     * @notice THIS IS AN EXAMPLE CONTRACT. DO NOT USE THIS CODE IN PRODUCTION.  
     * @dev This contract showcases a PingPong style call (A -> B -> A) using LayerZero's OApp Standard.  
     */  
    contract ABA is OApp, OAppOptionsType3 {  
      
        /// @notice Last received message data.  
        string public data = "Nothing received yet";  
      
        /// @notice Message types that are used to identify the various OApp operations.  
        /// @dev These values are used in things like combineOptions() in OAppOptionsType3.  
        uint16 public constant SEND = 1;  
        uint16 public constant SEND_ABA = 2;  
      
        /// @notice Emitted when a return message is successfully sent (B -> A).  
        event ReturnMessageSent(string message, uint32 dstEid);  
      
        /// @notice Emitted when a message is received from another chain.  
        event MessageReceived(string message, uint32 senderEid, bytes32 sender);  
      
         /// @notice Emitted when a message is sent to another chain (A -> B).  
        event MessageSent(string message, uint32 dstEid);  
      
        /// @dev Revert with this error when an invalid message type is used.  
        error InvalidMsgType();  
      
        /**  
         * @dev Constructs a new PingPong contract instance.  
         * @param _endpoint The LayerZero endpoint for this contract to interact with.  
         * @param _owner The owner address that will be set as the owner of the contract.  
         */  
        constructor(address _endpoint, address _owner) OApp(_endpoint, _owner) Ownable(msg.sender) {}  
      
        function encodeMessage(string memory _message, uint16 _msgType, bytes memory _extraReturnOptions) public pure returns (bytes memory) {  
            // Get the length of _extraReturnOptions  
            uint256 extraOptionsLength = _extraReturnOptions.length;  
      
            // Encode the entire message, prepend and append the length of extraReturnOptions  
            return abi.encode(_message, _msgType, extraOptionsLength, _extraReturnOptions, extraOptionsLength);  
        }  
      
        /**  
         * @notice Returns the estimated messaging fee for a given message.  
         * @param _dstEid Destination endpoint ID where the message will be sent.  
         * @param _msgType The type of message being sent.  
         * @param _message The message content.  
         * @param _extraSendOptions Gas options for receiving the send call (A -> B).  
         * @param _extraReturnOptions Additional gas options for the return call (B -> A).  
         * @param _payInLzToken Boolean flag indicating whether to pay in LZ token.  
         * @return fee The estimated messaging fee.  
         */  
        function quote(  
            uint32 _dstEid,  
            uint16 _msgType,  
            string memory _message,  
            bytes calldata _extraSendOptions,  
            bytes calldata _extraReturnOptions,  
            bool _payInLzToken  
        ) public view returns (MessagingFee memory fee) {  
            bytes memory payload = encodeMessage(_message, _msgType, _extraReturnOptions);  
            bytes memory options = combineOptions(_dstEid, _msgType, _extraSendOptions);  
            fee = _quote(_dstEid, payload, options, _payInLzToken);  
        }  
      
      
        /**  
         * @notice Sends a message to a specified destination chain.  
         * @param _dstEid Destination endpoint ID for the message.  
         * @param _msgType The type of message to send.  
         * @param _message The message content.  
         * @param _extraSendOptions Options for sending the message, such as gas settings.  
         * @param _extraReturnOptions Additional options for the return message.  
         */  
        function send(  
            uint32 _dstEid,  
            uint16 _msgType,  
            string memory _message,  
            bytes calldata _extraSendOptions, // gas settings for A -> B  
            bytes calldata _extraReturnOptions // gas settings for B -> A  
        ) external payable {  
            // Encodes the message before invoking _lzSend.  
            require(bytes(_message).length <= 32, "String exceeds 32 bytes");  
      
            if (_msgType != SEND && _msgType != SEND_ABA) {  
                revert InvalidMsgType();  
            }  
      
            bytes memory options = combineOptions(_dstEid, _msgType, _extraSendOptions);  
      
            _lzSend(  
                _dstEid,  
                encodeMessage(_message, _msgType, _extraReturnOptions),  
                options,  
                // Fee in native gas and ZRO token.  
                MessagingFee(msg.value, 0),  
                // Refund address in case of failed source message.  
                payable(msg.sender)  
            );  
      
            emit MessageSent(_message, _dstEid);  
        }  
      
        function decodeMessage(bytes calldata encodedMessage) public pure returns (string memory message, uint16 msgType, uint256 extraOptionsStart, uint256 extraOptionsLength) {  
            extraOptionsStart = 256;  // Starting offset after _message, _msgType, and extraOptionsLength  
            string memory _message;  
            uint16 _msgType;  
      
            // Decode the first part of the message  
            (_message, _msgType, extraOptionsLength) = abi.decode(encodedMessage, (string, uint16, uint256));  
      
            return (_message, _msgType, extraOptionsStart, extraOptionsLength);  
        }  
      
        /**  
         * @notice Internal function to handle receiving messages from another chain.  
         * @dev Decodes and processes the received message based on its type.  
         * @param _origin Data about the origin of the received message.  
         * @param message The received message content.  
         */  
        function _lzReceive(  
            Origin calldata _origin,  
            bytes32 /*guid*/,  
            bytes calldata message,  
            address,  // Executor address as specified by the OApp.  
            bytes calldata  // Any extra data or options to trigger on receipt.  
        ) internal override {  
      
            (string memory _data, uint16 _msgType, uint256 extraOptionsStart, uint256 extraOptionsLength) = decodeMessage(message);  
            data = _data;  
      
            if (_msgType == SEND_ABA) {  
      
                string memory _newMessage = "Chain B says goodbye!";  
      
                bytes memory _options = combineOptions(_origin.srcEid, SEND, message[extraOptionsStart:extraOptionsStart + extraOptionsLength]);  
      
                _lzSend(  
                    _origin.srcEid,  
                    abi.encode(_newMessage, SEND),  
                    // Future additions should make the data types static so that it is easier to find the array locations.  
                    _options,  
                    // Fee in native gas and ZRO token.  
                    MessagingFee(msg.value, 0),  
                    // Refund address in case of failed send call.  
                    // @dev Since the Executor makes the return call, this contract is the refund address.  
                    payable(address(this))  
                );  
      
                emit ReturnMessageSent(_newMessage, _origin.srcEid);  
            }  
      
            emit MessageReceived(data, _origin.srcEid, _origin.sender);  
        }  
      
      
        receive() external payable {}  
      
    }  
    

info

This message pattern can also be considered an ABC type call (`A` -> `B` ->
`C`), as the nested `_lzSend` can send to any new destination chain.

## Batch Send​

The **Batch Send** design pattern, where a single transaction can initiate
multiple `_lzSend` calls to various destination chains, is highly efficient
for operations that need to propagate an action across several blockchains
simultaneously.

![Batch Send Light](/assets/images/BatchSendLight-
fee3da4b7bd91cddfda54e033a9bac7a.svg#gh-light-mode-only) ![Batch Send
Dark](/assets/images/BatchSendDark-a59c5996e54591db2c977ccbe97d9cf9.svg#gh-
dark-mode-only)

This can significantly reduce the operational overhead associated with
performing the same action multiple times on different blockchains. It
streamlines omnichain interactions by bundling them into a single transaction,
making processes more efficient and easier to manage for example:

  * **Simultaneous Omnichain Updates** : When a system needs to update the same information across multiple chains (such as a change in governance parameters or updating oracle data), Batch Send can propagate the updates in one go.

  * **DeFi Strategies** : For DeFi protocols that operate on multiple chains, rebalancing liquidity pools or executing yield farming strategies can be done in batch to maintain parity across ecosystems.

  * **Aggregated Omnichain Data Posting** : Oracles or data providers that supply information to smart contracts on multiple chains can use Batch Send to post data such as price feeds, event outcomes, or other updates in a single transaction.

### Code Example​

    
    
    // SPDX-License-Identifier: MIT  
      
    pragma solidity ^0.8.22;  
      
    import { OApp, MessagingFee, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";  
    import { OAppOptionsType3 } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";  
    import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";  
      
    /**  
     * @title BatchSend contract for demonstrating multiple outbound cross-chain calls using LayerZero.  
     * @notice THIS IS AN EXAMPLE CONTRACT. DO NOT USE THIS CODE IN PRODUCTION.  
     * @dev This contract showcases how to send multiple cross-chain calls with one source function call using LayerZero's OApp Standard.  
     */  
    contract BatchSend is OApp, OAppOptionsType3 {  
        /// @notice Last received message data.  
        string public data = "Nothing received yet";  
      
        /// @notice Message types that are used to identify the various OApp operations.  
        /// @dev These values are used in things like combineOptions() in OAppOptionsType3 (enforcedOptions).  
        uint16 public constant SEND = 1;  
      
        /// @notice Emitted when a message is received from another chain.  
        event MessageReceived(string message, uint32 senderEid, bytes32 sender);  
      
        /// @notice Emitted when a message is sent to another chain (A -> B).  
        event MessageSent(string message, uint32 dstEid);  
      
        /// @dev Revert with this error when an invalid message type is used.  
        error InvalidMsgType();  
      
        /**  
         * @dev Constructs a new BatchSend contract instance.  
         * @param _endpoint The LayerZero endpoint for this contract to interact with.  
         * @param _owner The owner address that will be set as the owner of the contract.  
         */  
        constructor(address _endpoint, address _owner) OApp(_endpoint, _owner) Ownable(msg.sender) {}  
      
        function _payNative(uint256 _nativeFee) internal override returns (uint256 nativeFee) {  
            if (msg.value < _nativeFee) revert NotEnoughNative(msg.value);  
            return _nativeFee;  
        }  
      
        /**  
         * @notice Returns the estimated messaging fee for a given message.  
         * @param _dstEids Destination endpoint ID array where the message will be batch sent.  
         * @param _msgType The type of message being sent.  
         * @param _message The message content.  
         * @param _extraSendOptions Extra gas options for receiving the send call (A -> B).  
         * Will be summed with enforcedOptions, even if no enforcedOptions are set.  
         * @param _payInLzToken Boolean flag indicating whether to pay in LZ token.  
         * @return totalFee The estimated messaging fee for sending to all pathways.  
         */  
        function quote(  
            uint32[] memory _dstEids,  
            uint16 _msgType,  
            string memory _message,  
            bytes calldata _extraSendOptions,  
            bool _payInLzToken  
        ) public view returns (MessagingFee memory totalFee) {  
            bytes memory encodedMessage = abi.encode(_message);  
      
            for (uint i = 0; i < _dstEids.length; i++) {  
                bytes memory options = combineOptions(_dstEids[i], _msgType, _extraSendOptions);  
                MessagingFee memory fee = _quote(_dstEids[i], encodedMessage, options, _payInLzToken);  
                totalFee.nativeFee += fee.nativeFee;  
                totalFee.lzTokenFee += fee.lzTokenFee;  
            }  
        }  
      
        function send(  
            uint32[] memory _dstEids,  
            uint16 _msgType,  
            string memory _message,  
            bytes calldata _extraSendOptions // gas settings for A -> B  
        ) external payable {  
            if (_msgType != SEND) {  
                revert InvalidMsgType();  
            }  
      
            // Calculate the total messaging fee required.  
            MessagingFee memory totalFee = quote(_dstEids, _msgType, _message, _extraSendOptions, false);  
            require(msg.value >= totalFee.nativeFee, "Insufficient fee provided");  
      
            // Encodes the message before invoking _lzSend.  
            bytes memory _encodedMessage = abi.encode(_message);  
      
            uint256 totalNativeFeeUsed = 0;  
            uint256 remainingValue = msg.value;  
      
            for (uint i = 0; i < _dstEids.length; i++) {  
                bytes memory options = combineOptions(_dstEids[i], _msgType, _extraSendOptions);  
                MessagingFee memory fee = _quote(_dstEids[i], _encodedMessage, options, false);  
      
                totalNativeFeeUsed += fee.nativeFee;  
                remainingValue -= fee.nativeFee;  
      
                // Ensure the current call has enough allocated fee from msg.value.  
                require(remainingValue >= 0, "Insufficient fee for this destination");  
      
                _lzSend(  
                    _dstEids[i],  
                    _encodedMessage,  
                    options,  
                    fee,  
                    payable(msg.sender)  
                );  
      
                emit MessageSent(_message, _dstEids[i]);  
            }  
        }  
      
        /**  
         * @notice Internal function to handle receiving messages from another chain.  
         * @dev Decodes and processes the received message based on its type.  
         * @param _origin Data about the origin of the received message.  
         * @param message The received message content.  
         */  
        function _lzReceive(  
            Origin calldata _origin,  
            bytes32 /*guid*/,  
            bytes calldata message,  
            address, // Executor address as specified by the OApp.  
            bytes calldata // Any extra data or options to trigger on receipt.  
        ) internal override {  
            string memory _data = abi.decode(message, (string));  
            data = _data;  
      
            emit MessageReceived(data, _origin.srcEid, _origin.sender);  
        }  
    }  
    

## Composed​

A composed message refers to an application that invokes the Endpoint method,
`sendCompose`, to deliver a composed call to a destination contract via
`lzCompose`.

![Composed Light](/assets/images/Composed-
Light-800921daa24e98f513465291c0d4e3fb.svg#gh-light-mode-only) ![Composed
Dark](/assets/images/Composed-Dark-a0ea6d759090e92c2fc6a6597f8fbf41.svg#gh-
dark-mode-only)

This pattern demonstrates **horizontal composability** , which differs from
vertical composability in that the external call is now containerized as a new
message packet; enabling the application to ensure that certain receipt logic
remains separate from the external call itself.

info

Since each composable call is created as a separate message packet via
`lzCompose`, this pattern can be extended for as many steps as your
application needs (`B1` -> `B2` -> `B3`, etc).

  

This pattern can be particularly powerful for orchestrating complex
interactions and processes on the destination chain that need contract logic
to be handled in independent steps, such as:

  * **Omnichain DeFi Strategies** : A smart contract could trigger a token transfer on the destination chain and then automatically interact with a DeFi protocol to lend, borrow, provide liquidity, stake, etc. executing a series of financial strategies across chains.

  * **NFT Interactions** : An NFT could be transferred to another chain, and upon arrival, it could trigger a contract to issue a license, register a domain, or initiate a subscription service linked to the NFT's ownership.

  * **DAO Coordination** : A DAO could send funds to another chain's contract and compose a message to execute specific DAO-agreed upon investments or funding of public goods.

  

### Composing an OApp​

There are 3 relevant contract interactions when composing an OApp:

  1. **Source OApp** : the OApp sending a cross-chain message via `_lzSend` to a destination.

  2. **Destination OApp(s)** : the OApp receiving a cross-chain message via `_lzReceive` and calling `sendCompose`.

  3. **Composed Receiver(s)** : the contract interface implementing business logic to handle receiving a composed message via `lzCompose`.

### Sending Message​

The sending OApp is **required** to pass specific Composed Message Execution
Options (more on this below) for the `sendCompose` call, but is **not
required** to pass any input parameters for the call itself (however this
pattern may be useful depending on what arbitrary action you wish to trigger
when composing).

For example, this `send` function packs the destination `_composedAddress` for
the destination OApp to decode and use for the actual composed call.

    
    
    /// @notice Sends a message from the source to destination chain.  
    /// @param _dstEid Destination chain's endpoint ID.  
    /// @param _message The message to send.  
    /// @param _composedAddress The contract you wish to deliver a composed call to.  
    /// @param _options Message execution options (e.g., for sending gas to destination).  
    function send(  
        uint32 _dstEid,  
        string memory _message,  
        address _composedAddress, // the destination contract implementing ILayerZeroComposer  
        bytes calldata _options  
    ) external payable returns(MessagingReceipt memory receipt) {  
        // Encodes the message before invoking _lzSend.  
        bytes memory _payload = abi.encode(_message, _composedAddress);  
        receipt = _lzSend(  
            _dstEid,  
            _payload,  
            _options,  
            // Fee in native gas and ZRO token.  
            MessagingFee(msg.value, 0),  
            // Refund address in case of failed source message.  
            payable(msg.sender)  
        );  
    }  
    

### Sending Compose​

The receiving OApp invokes the LayerZero Endpoint's `sendCompose` method as
part of your OApp's `_lzReceive` business logic.

The `sendCompose` method takes the following inputs:

  1. `_to`: the contract implementing the [`ILayerZeroComposer`](https://github.com/LayerZero-Labs/LayerZero-v2/blob/main/packages/layerzero-v2/evm/protocol/contracts/interfaces/ILayerZeroComposer.sol) receive interface.

  2. `_guid`: the global unique identifier of the source message (provided standard by `lzReceive`).

  3. `_index`: the index of the composed message (used for pricing different gas execution amounts along different composed legs of the transaction).

    
    
    /// @dev the Oapp sends the lzCompose message to the endpoint  
    /// @dev the composer MUST assert the sender because anyone can send compose msg with this function  
    /// @dev with the same GUID, the Oapp can send compose to multiple _composer at the same time  
    /// @dev authenticated by the msg.sender  
    /// @param _to the address which will receive the composed message  
    /// @param _guid the message guid  
    /// @param _message the message  
    function sendCompose(address _to, bytes32 _guid, uint16 _index, bytes calldata _message) external {  
        // must have not been sent before  
        if (composeQueue[msg.sender][_to][_guid][_index] != NO_MESSAGE_HASH) revert Errors.ComposeExists();  
        composeQueue[msg.sender][_to][_guid][_index] = keccak256(_message);  
        emit ComposeSent(msg.sender, _to, _guid, _index, _message);  
    }  
    

This means that when a packet is received (`_lzReceive`) by the Destination
OApp, it will send (`sendCompose`) a new composed packet via the destination
LayerZero Endpoint.

    
    
    /// @dev Called when data is received from the protocol. It overrides the equivalent function in the parent contract.  
    /// Protocol messages are defined as packets, comprised of the following parameters.  
    /// @param _origin A struct containing information about where the packet came from.  
    /// @param _guid A global unique identifier for tracking the packet.  
    /// @param payload Encoded message.  
    function _lzReceive(  
        Origin calldata _origin,  
        bytes32 _guid,  
        bytes calldata payload,  
        address,  // Executor address as specified by the OApp.  
        bytes calldata  // Any extra data or options to trigger on receipt.  
    ) internal override {  
        // Decode the payload to get the message  
        (string memory _message, address _composedAddress) = abi.decode(payload, (string, address));  
        // Storing data in the destination OApp  
        data = _message;  
        // Send a composed message[0] to a composed receiver  
        endpoint.sendCompose(_composedAddress, _guid, 0, payload);  
    }  
    

info

The above `sendCompose` call hardcodes `_index` to `0` and simply forwards the
same `payload` as `_lzReceive` to `lzCompose`, however these inputs can also
be dynamically adjusted depending on the number and type of composed calls you
wish to make.

#### Composed Message Execution Options​

You can decide both the `_gas` and `msg.value` that should be used for the
composed call(s), depending on the type and quantity of messages you intend to
send.

Your configured Executor will use the `_options` provided in the original
`_lzSend` call to determine the gas limit and amount of `msg.value` to include
per message `_index`:

    
    
    // addExecutorLzComposeOption(uint16 _index, uint128 _gas, uint128 _value)  
    Options.newOptions()  
      .addExecutorLzReceiveOption(50000, 0)  
      .addExecutorLzComposeOption(0, 30000, 0)  
      .addExecutorLzComposeOption(1, 30000, 0);  
    

It's important to remember that gas costs may vary depending on the
destination chain. For example, all new Ethereum transactions cost `21000`
wei, but other chains may have lower or higher opcode costs, or entirely
different gas mechanisms.

You can read more about generating `_options` and the role of `_index` in
[Message Execution Options](/v2/developers/evm/protocol-gas-
settings/options#lzcompose-option).

### Receiving Compose​

The destination must implement the `ILayerZeroComposer` interface to handle
receiving the composed message.

From there, you can decide any additional composed business logic to execute
within `lzCompose`, as shown below:

    
    
    // SPDX-License-Identifier: MIT  
    pragma solidity ^0.8.22;  
      
    import { ILayerZeroComposer } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroComposer.sol";  
      
    /// @title ComposedReceiver  
    /// @dev A contract demonstrating the minimum ILayerZeroComposer interface necessary to receive composed messages via LayerZero.  
    contract ComposedReceiver is ILayerZeroComposer {  
      
        /// @notice Stores the last received message.  
        string public data = "Nothing received yet";  
      
        /// @notice Store LayerZero addresses.  
        address public immutable endpoint;  
        address public immutable oApp;  
      
        /// @notice Constructs the contract.  
        /// @dev Initializes the contract.  
        /// @param _endpoint LayerZero Endpoint address  
        /// @param _oApp The address of the OApp that is sending the composed message.  
        constructor(address _endpoint, address _oApp) {  
            endpoint = _endpoint;  
            oApp = _oApp;  
        }  
      
        /// @notice Handles incoming composed messages from LayerZero.  
        /// @dev Decodes the message payload and updates the state.  
        /// @param _oApp The address of the originating OApp.  
        /// @param /*_guid*/ The globally unique identifier of the message.  
        /// @param _message The encoded message content.  
        function lzCompose(  
            address _oApp,  
            bytes32 /*_guid*/,  
            bytes calldata _message,  
            address,  
            bytes calldata  
        ) external payable override {  
            // Perform checks to make sure composed message comes from correct OApp.  
            require(_oApp == oApp, "!oApp");  
            require(msg.sender == endpoint, "!endpoint");  
      
            // Decode the payload to get the message  
            (string memory message, ) = abi.decode(_message, (string, address));  
            data = message;  
        }  
    }  
    

### Further Reading​

For more advanced implementations of `sendCompose` and `lzCompose`:

  * Review the [`OmniCounter.sol`](https://github.com/LayerZero-Labs/LayerZero-v2/blob/main/packages/layerzero-v2/evm/oapp/contracts/oapp/examples/OmniCounter.sol#L43) for sending composed messages to the same OApp implementation.

  * Read the [OFT Composing](/v2/developers/evm/oft/oft-patterns-extensions#composed-oft) section to see how to implement composed business logic into your OFTs.

## Composed ABA​

The **Composed ABA** design pattern enables sophisticated omnichain
communication by allowing for an operation to be performed as part of the
receive logic on the destination chain (`B1`), a follow-up action or call
containerized as an independent step within `lzCompose` (`B2`), which then
sends back to the source chain (`A`).

![ComposedABA
Light](/assets/images/ComposedABAlight-e0abed129423666dd33683cdea9b0d9f.svg#gh-
light-mode-only) ![ComposedABA
Dark](/assets/images/ComposedABAdark-42a3490e1adaaaa4a13033d2009533e7.svg#gh-
dark-mode-only)

info

This message pattern can also be considered a Composed ABC type call (`A` ->
`B1` -> `B2` -> `C`), as the nested `_lzSend` can send to any new destination
chain.

  

This pattern demonstrates a complex, multi-step, process across blockchains
where each step requires its own atomic logic to execute without depending on
separate execution logic. Here are some use cases that could benefit from a
Composed ABA design pattern:

  * **Omnichain Data Verification** : Chain A sends a request to chain B to verify a set of data. Once verified, a contract on chain B executes an action based on this data and sends a signal back to chain A to either proceed with the next step or record the verification.

  * **Omnichain Collateral Management** : When collateral on chain A is locked or released, a corresponding contract on chain B could be called to issue a loan or unlock additional funds. Confirmation of the action is then sent back to chain A to complete the process.

  * **Multi-Step Contract Interaction for Games and Collectibles** : In a gaming scenario, an asset (like an NFT) could be sent from chain A to B, triggering a contract on B that could unlock a new level or feature in a game, with a confirmation or reward then sent back to chain A.

## Message Ordering​

LayerZero offers both **unordered delivery** and **ordered delivery**,
providing developers with the flexibility to choose the most appropriate
transaction ordering mechanism based on the specific requirements of their
application.

### Unordered Delivery​

By default, the LayerZero protocol uses **unordered delivery** , where
transactions can be executed out of order if all transactions prior have been
verified.

If transactions `1` and `2` have not been verified, then transaction `3`
cannot be executed until the previous nonces have been verified.

Once nonces `1`, `2`, `3` have been verified:

  * If nonce `2` failed to execute (due to some gas or user logic related issue), nonce `3` can still proceed and execute.

![Lazy Nonce Enforcement Light](/assets/images/lazy-nonce-enforcement-
light-41b977b1dc162d0bf1da1db05f09fc49.svg#gh-light-mode-only) ![Lazy Nonce
Enforcement Dark](/assets/images/lazy-nonce-enforcement-
dark-2c153f512be8cacfeb2ff5d12faf06b2.svg#gh-dark-mode-only)

This is particularly useful in scenarios where transactions are not critically
dependent on the execution of previous transactions.

### Ordered Delivery​

Developers can configure the OApp contract to use **ordered delivery**.

![Strict Nonce Enforcement Light](/assets/images/strict-nonce-enforcement-
light-c36b280a258350fef4484a533160c54d.svg#gh-light-mode-only) ![Strict Nonce
Enforcement Dark](/assets/images/strict-nonce-enforcement-dark-
adda5ea6c4cc6db2a7bb5f1b22010ba9.svg#gh-dark-mode-only)

In this configuration, if you have a sequence of packets with nonces `1`, `2`,
`3`, and so on, each packet must be executed in that exact, sequential order:

  * If nonce `2` fails for any reason, it will block all subsequent transactions with higher nonces from being executed until nonce `2` is resolved.

![Strict Nonce Enforcement Fail Light](/assets/images/strict-nonce-
enforcement-fail-light-7bf59f1f3cb6dabeb40cdf140e54bce1.svg#gh-light-mode-
only) ![Strict Nonce Enforcement Fail Dark](/assets/images/strict-nonce-
enforcement-fail-dark-a4c9e89af2036abd9187cdb29f1e0030.svg#gh-dark-mode-only)

Strict nonce enforcement can be important in scenarios where the order of
transactions is critical to the integrity of the system, such as any multi-
step process that needs to occur in a specific sequence to maintain
consistency.

info

In these cases, strict nonce enforcement can be used to provide consistency,
fairness, and censorship-resistance to maintain system integrity.

### Code Example​

To implement strict nonce enforcement, you need to implement the following:

  * a mapping to track the maximum received nonce.

  * override `_acceptNonce` and `nextNonce`.

  * add `ExecutorOrderedExecutionOption` in `_options` when calling `_lzSend`.

caution

If you do not pass an `ExecutorOrderedExecutionOption` in your `_lzSend` call,
the Executor will attempt to execute the message despite your application-
level nonce enforcement, leading to a message revert.

Append to your [Message Options](/v2/developers/evm/protocol-gas-
settings/options) an `ExecutorOrderedExecutionOption` in your `_lzSend` call:

    
    
    // appends "01000104", the ExecutorOrderedExecutionOption, to your options bytes array  
    _options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0).addExecutorOrderedExecutionOption();  
    

Implement strict nonce enforcement via function override:

    
    
    pragma solidity ^0.8.20;  
      
    import { OApp } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol"; // Import OApp and other necessary contracts/interfaces  
      
    /**  
     * @title OmniChain Nonce Ordered Enforcement Example  
     * @dev Implements nonce ordered enforcement for your OApp.  
     */  
    contract MyNonceEnforcementExample is OApp {  
        // Mapping to track the maximum received nonce for each source endpoint and sender  
        mapping(uint32 eid => mapping(bytes32 sender => uint64 nonce)) private receivedNonce;  
      
        /**  
         * @dev Constructor to initialize the omnichain contract.  
         * @param _endpoint Address of the LayerZero endpoint.  
         * @param _owner Address of the contract owner.  
         */  
        constructor(address _endpoint, address _owner) OApp(_endpoint, _owner) {}  
      
        /**  
         * @dev Public function to get the next expected nonce for a given source endpoint and sender.  
         * @param _srcEid Source endpoint ID.  
         * @param _sender Sender's address in bytes32 format.  
         * @return uint64 Next expected nonce.  
         */  
        function nextNonce(uint32 _srcEid, bytes32 _sender) public view virtual override returns (uint64) {  
            return receivedNonce[_srcEid][_sender] + 1;  
        }  
      
        /**  
         * @dev Internal function to accept nonce from the specified source endpoint and sender.  
         * @param _srcEid Source endpoint ID.  
         * @param _sender Sender's address in bytes32 format.  
         * @param _nonce The nonce to be accepted.  
         */  
        function _acceptNonce(uint32 _srcEid, bytes32 _sender, uint64 _nonce) internal virtual override {  
            receivedNonce[_srcEid][_sender] += 1;  
            require(_nonce == receivedNonce[_srcEid][_sender], "OApp: invalid nonce");  
        }  
      
        // @dev Override receive function to enforce strict nonce enforcement.  
        function _lzReceive(  
            Origin calldata _origin,  
            bytes32 _guid,  
            bytes calldata _message,  
            address _executor,  
            bytes calldata _extraData  
        ) public payable virtual override {  
            _acceptNonce(_origin.srcEid, _origin.sender, _origin.nonce);  
            // Call the internal function with the correct parameters  
            super._lzReceive(_origin, _guid, _message, _executor, _extraData);  
        }  
    }  
    

## Rate Limiting​

The `RateLimiter.sol` is used to control the number of cross-chain messages
that can be sent within a certain time window, ensuring that the OApp is not
spammed by too many transactions at once. It's particularly useful for:

  * **Preventing Denial of Service Attacks** : By setting thresholds on the number of messages that can be processed within a given timeframe, the `RateLimiter` acts as a safeguard against DoS attacks, where malicious actors might attempt to overload an OApp with a flood of transactions. This protection ensures that the OApp remains accessible and functional for legitimate users, even under attempted attacks.

  * **Regulatory Compliance** : Some applications may need to enforce limits to comply with legal or regulatory requirements.

The `RateLimiter` is only useful under specific application use cases. It will
not be necessary for most OApps and can even be counterproductive for more
generic applications:

  * **Low Traffic Applications** : If your application doesn't expect high volumes of traffic, implementing a rate limiter might be unnecessary overhead.

  * **Critical Systems Requiring Immediate Transactions** : For systems where transactions need to be processed immediately without delay, rate limiting could hinder performance.

### Installation​

To begin working with LayerZero contracts, you can install the [OApp npm
package](https://www.npmjs.com/package/@layerzerolabs/lz-evm-
oapp-v2?activeTab=code) to an existing project:

    
    
    npm install @layerzerolabs/lz-evm-oapp-v2  
    

### Usage​

Import the `RateLimiter.sol` contract into your OApp contract file and inherit
the contract:

    
    
    // SPDX-License-Identifier: UNLICENSED  
    pragma solidity ^0.8.22;  
      
    import { OApp } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";  
    import { RateLimiter } from "@layerzerolabs/oapp-evm/contracts/oapp/utils/RateLimiter.sol";  
      
    contract MyOApp is OApp, RateLimiter {  
        // ...contract  
    }  
    

#### Initializing Rate Limits​

In the constructor of your contract, initialize the rate limits using
`_setRateLimits` with an array of `RateLimitConfig` structs.

**Example:**

    
    
     constructor(  
        RateLimitConfig[] memory _rateLimitConfigs,  
        address _lzEndpoint,  
        address _delegate  
    ) OApp(_lzEndpoint, _delegate) {  
        _setRateLimits(_rateLimitConfigs);  
    }  
    // ...Rest of contract code  
    

**`RateLimitConfig` Struct:**

    
    
    struct RateLimitConfig {  
        uint32 dstEid; // destination endpoint ID  
        uint256 limit; // arbitrary limit of messages/tokens to transfer  
        uint256 window; // window of time before limit resets  
    }  
    

#### Setting Rate Limits​

Provide functions to set or update rate limits dynamically. This can include a
function to adjust individual or multiple rate limits and a mechanism to
authorize who can make these changes (typically restricted to the contract
owner or a specific role).

    
    
    /**  
     * @dev Sets the rate limits based on RateLimitConfig array. Only callable by the owner or the rate limiter.  
     * @param _rateLimitConfigs An array of RateLimitConfig structures defining the rate limits.  
     */  
    function setRateLimits(  
        RateLimitConfig[] calldata _rateLimitConfigs  
    ) external {  
        if (msg.sender != rateLimiter && msg.sender != owner()) revert OnlyRateLimiter();  
        _setRateLimits(_rateLimitConfigs);  
    }  
    

#### Checking Rate Limits During Send Calls​

Before processing transactions, use `_checkAndUpdateRateLimit` to ensure the
transaction doesn't exceed the set limits. This function should be called in
any transactional functions, such as message passing or token transfers.

#### Message Passing​

    
    
    function send(  
        uint32 _dstEid,  
        string memory _message,  
        bytes calldata _options  
    ) external payable {  
        _checkAndUpdateRateLimit(_dstEid, 1); // updating the rate limit per message sent  
        bytes memory _payload = abi.encode(_message); // Encodes message as bytes.  
        _lzSend(  
            _dstEid, // Destination chain's endpoint ID.  
            _payload, // Encoded message payload being sent.  
            _options, // Message execution options (e.g., gas to use on destination).  
            MessagingFee(msg.value, 0), // Fee struct containing native gas and ZRO token.  
            payable(msg.sender) // The refund address in case the send call reverts.  
        );  
    }  
    

#### Token Transfers​

    
    
    /**  
     * @dev Checks and updates the rate limit before initiating a token transfer.  
     * @param _amountLD The amount of tokens to be transferred.  
     * @param _minAmountLD The minimum amount of tokens expected to be received.  
     * @param _dstEid The destination endpoint identifier.  
     * @return amountSentLD The actual amount of tokens sent.  
     * @return amountReceivedLD The actual amount of tokens received.  
     */  
    function _debit(  
        uint256 _amountLD,  
        uint256 _minAmountLD,  
        uint32 _dstEid  
    ) internal virtual override returns (uint256 amountSentLD, uint256 amountReceivedLD) {  
        _checkAndUpdateRateLimit(_dstEid, _amountLD);  
        return super._debit(_amountLD, _minAmountLD, _dstEid);  
    }  
    

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/oapp/message-design-patterns.md)

[PreviousOmnichain NFT (ONFT)](/v2/developers/evm/onft/quickstart)[NextOFT
Patterns & Extensions](/v2/developers/evm/oft/oft-patterns-extensions)

  * ABA
    * Code Example
  * Batch Send
    * Code Example
  * Composed
    * Composing an OApp
    * Sending Message
    * Sending Compose
    * Receiving Compose
    * Further Reading
  * Composed ABA
  * Message Ordering
    * Unordered Delivery
    * Ordered Delivery
    * Code Example
  * Rate Limiting
    * Installation
    * Usage



  * Protocol
  * Omnichain Mesh Network

Version: Endpoint V2 Docs

On this page

# Omnichain Mesh Network

LayerZero overcomes the limitations of existing cross-chain networks that have
sparse connectivity and inconsistent communication interfaces by providing a
uniform and densely connected mesh network across all supported blockchains.

![Omnichain Light](/assets/images/omnichain-
light-4f7faf120631f7e2592c2c355d0798f7.svg#gh-light-mode-only) ![Omnichain
Dark](/assets/images/omnichain-dark-9fb0f92d9bea270f6a194fbd0bdcb306.svg#gh-
dark-mode-only)

An **Omnichain Mesh Network** refers to a densely connected web where any
chain can communicate with any other chain directly using a predictable and
stable interface, making data and value transfer across blockchains seamless.

The LayerZero protocol is designed to maintain a consistent level of security
and reliability across all these connections despite the different security
semantics and design logic each individual blockchain might have.

## Omnichain Features​

  * **Universal Network Semantics** : The network ensures uniform standards for packet delivery regardless of the blockchain pairs connected. This means that data packets are reliably transferred across chains without censorship and are delivered exactly once to their intended destinations.

  * **Modular Security Model** : Unlike other cross-chain services that use a one-size-fits-all security approach, LayerZero protocol offers a combination of configurable and non-configurable security guarantees.

    * [Decentralized Verifier Networks (DVNs)](/v2/home/modular-security/security-stack-dvns) verify messages, can be configured by the application, and allow developers to determine which security and cost-efficiency models best fit their application's needs.

    * [Configurable Block Confirmations](/v2/developers/evm/protocol-gas-settings/default-config#send-config-type-executor) enables the OApp owner to protect their OApp from block reorganizations on the source chain by configuring an amount of blocks for DVNs to wait for before verifying a message.

    * Fundamental security features like protection against censorship, replay attacks, and unauthorized code changes are built into the core immutable interfaces of the network ([LayerZero Endpoint](/v2/home/protocol/layerzero-endpoint)).

  * **Pathway Security** : While the network maintains universal standards, it also recognizes that each pathway might need a different security configuration. Each pathway is defined by a source blockchain, source application, destination blockchain, and destination application; pathways can be individually configured to ensure that security and cost are tailored to the specific needs of each connection.

  * **Chain Agnostic Applications** : Thanks to these universal semantics, developers can create [Omnichain Applications (OApps)](/v2/home/token-standards/oapp-standard) that work seamlessly across all different blockchains.

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/home/protocol/mesh-network.md)

[PreviousProtocol Overview](/v2/home/protocol/protocol-overview)[NextContract
Standards](/v2/home/protocol/contract-standards)

  * Omnichain Features



  * Contract Standards
  * Omnichain Application (OApp)

Version: Endpoint V2 Docs

On this page

# LayerZero V2 OApp Quickstart

The OApp Standard provides developers with a _generic message passing
interface_ to **send** and **receive** arbitrary pieces of data between
contracts existing on different blockchain networks.

![OApp
Example](/assets/images/ABLight-b6e0a32bf1941c8956b7073f1687dd76.svg#gh-light-
mode-only) ![OApp
Example](/assets/images/ABDark-a499c3ef51835bc97613e2f4cba97f22.svg#gh-dark-
mode-only)

This interface can easily be extended to include anything from specific
financial logic in a DeFi application, a voting mechanism in a DAO, and
broadly any smart contract use case.

LayerZero provides `OApp` for implementing generic message passing in your
contracts:

    
    
    // SPDX-License-Identifier: MIT  
    pragma solidity ^0.8.22;  
      
    import { OAppSender } from "./OAppSender.sol";  
    // @dev import the origin so its exposed to OApp implementers  
    import { OAppReceiver, Origin } from "./OAppReceiver.sol";  
    import { OAppCore } from "./OAppCore.sol";  
      
    abstract contract OApp is OAppSender, OAppReceiver {  
        constructor(address _endpoint, address _owner) OAppCore(_endpoint, _owner) {}  
      
        function oAppVersion() public pure virtual returns (uint64 senderVersion, uint64 receiverVersion) {  
            senderVersion = SENDER_VERSION;  
            receiverVersion = RECEIVER_VERSION;  
        }  
    }  
    

info

If you prefer reading the contract code, see the OApp package in the LayerZero
Devtools [**OApp Package**](https://github.com/LayerZero-
Labs/devtools/blob/main/packages/oapp-evm/contracts/oapp/OApp.sol).

tip

For developers interested in sending and receiving omnichain tokens, we
recommend inheriting the [**OFT Standard**](/v2/developers/evm/oft/quickstart)
directly instead of OApp.

## Installation​

To start using LayerZero contracts, you can install the [OApp
package](https://github.com/LayerZero-Labs/devtools/tree/main/packages/oapp-
evm) to an existing project:

  * npm
  * yarn
  * pnpm
  * forge

    
    
    npm install @layerzerolabs/oapp-evm  
    
    
    
    yarn add @layerzerolabs/oapp-evm  
    
    
    
    pnpm add @layerzerolabs/oapp-evm  
    
    
    
    forge install https://github.com/LayerZero-Labs/devtools  
    
    
    
    forge install https://github.com/LayerZero-Labs/layerzero-v2  
    

Then add to your `foundry.toml`:

    
    
    [profile.default]  
    src = "src"  
    out = "out"  
    libs = ["lib"]  
      
    remappings = [  
        '@layerzerolabs/oapp-evm/=lib/devtools/packages/oapp-evm/',  
        '@layerzerolabs/lz-evm-protocol-v2/=lib/layerzero-v2/packages/layerzero-v2/evm/protocol',  
    ]  
      
    # See more config options https://github.com/foundry-rs/foundry/blob/master/crates/config/README.md#all-options  
    

info

LayerZero contracts work with both [**OpenZeppelin
V5**](https://docs.openzeppelin.com/contracts/5.x/access-control#ownership-
and-ownable) and V4 contracts. Specify your desired version in your project's
package.json:

    
    
    "resolutions": {  
        "@openzeppelin/contracts": "^5.0.1",  
    }  
    

tip

LayerZero also provides [**create-lz-oapp**](/v2/developers/evm/create-lz-
oapp/start), an npx package that allows developers to create any omnichain
application in <4 minutes! Get started by running the following from your
command line:

    
    
    npx create-lz-oapp@latest  
    

## Creating an OApp Contract​

Every OApp will need to set two arguments in the constructor:

  1. **Endpoint Address:** The source chain’s [Endpoint Address](/v2/developers/evm/technical-reference/deployed-contracts) for communicating with the protocol.

  2. **Owner Address:** The address that will own the OApp contract.

And define the send and receive function:

  * `_lzSend`: the internal function your application must call to send an omnichain message.

  * `_lzReceive`: the function to receive an omnichain message. This internal method is called whenever the `EndpointV2.lzReceive()` is executed at the receiving OApp.

info

The OApp Contract Standard inherits directly from both `OAppSender.sol` and
`OAppReceiver.sol`, so that your child contract has handling for both sending
and receiving messages. You can inherit directly from either the
[**Sender**](https://github.com/LayerZero-
Labs/LayerZero-v2/blob/main/packages/layerzero-v2/evm/oapp/contracts/oapp/OAppSender.sol)
or [**Receiver**](https://github.com/LayerZero-
Labs/LayerZero-v2/blob/main/packages/layerzero-v2/evm/oapp/contracts/oapp/OAppReceiver.sol)
contract if your child contract only needs one type of handling, as shown in
[**Getting Started**](/v2/developers/evm/getting-started).

    
    
    // SPDX-License-Identifier: UNLICENSED  
    pragma solidity ^0.8.22;  
      
    import { OApp, Origin, MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";  
    import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";  
      
    contract MyOApp is OApp {  
        constructor(address _endpoint, address _owner) OApp(_endpoint, _owner) Ownable(_owner) {}  
      
        // Some arbitrary data you want to deliver to the destination chain!  
        string public data;  
      
        /**  
         * @notice Sends a message from the source to destination chain.  
         * @param _dstEid Destination chain's endpoint ID.  
         * @param _message The message to send.  
         * @param _options Message execution options (e.g., for sending gas to destination).  
         */  
        function send(  
            uint32 _dstEid,  
            string memory _message,  
            bytes calldata _options  
        ) external payable {  
            // Encodes the message before invoking _lzSend.  
            // Replace with whatever data you want to send!  
            bytes memory _payload = abi.encode(_message);  
            _lzSend(  
                _dstEid,  
                _payload,  
                _options,  
                // Fee in native gas and ZRO token.  
                MessagingFee(msg.value, 0),  
                // Refund address in case of failed source message.  
                payable(msg.sender)  
            );  
        }  
      
        /**  
         * @dev Called when data is received from the protocol. It overrides the equivalent function in the parent contract.  
         * Protocol messages are defined as packets, comprised of the following parameters.  
         * @param _origin A struct containing information about where the packet came from.  
         * @param _guid A global unique identifier for tracking the packet.  
         * @param payload Encoded message.  
         */  
        function _lzReceive(  
            Origin calldata _origin,  
            bytes32 _guid,  
            bytes calldata payload,  
            address,  // Executor address as specified by the OApp.  
            bytes calldata  // Any extra data or options to trigger on receipt.  
        ) internal override {  
            // Decode the payload to get the message  
            // In this case, type is string, but depends on your encoding!  
            data = abi.decode(payload, (string));  
        }  
    }  
    

## Deployment Workflow​

  1. Deploy the `OApp` to all the chains you want to connect.

  2. Call `MyOApp.setPeer` to whitelist each destination contract on every destination chain.
    
        // The real endpoint ids will vary per chain, and can be found under "Supported Chains"  
    uint32 aEid = 1;  
    uint32 bEid = 2;  
      
    MyOApp aOApp;  
    MyOApp bOApp;  
      
    function addressToBytes32(address _addr) public pure returns (bytes32) {  
        return bytes32(uint256(uint160(_addr)));  
    }  
      
    // Call on both sides per pathway  
    aOApp.setPeer(bEid, addressToBytes32(address(bOApp)));  
    bOApp.setPeer(aEid, addressToBytes32(address(aOApp)));  
    

  3. Set the DVN configuration, including optional settings such as block confirmations, security threshold, the Executor, max message size, and send/receive libraries.
    
        EndpointV2.setSendLibrary(aOApp, bEid, newLib)  
    EndpointV2.setReceiveLibrary(aOApp, bEid, newLib, gracePeriod)  
    EndpointV2.setReceiveLibraryTimeout(aOApp, bEid, lib, gracePeriod)  
    EndpointV2.setConfig(aOApp, sendLibrary, sendConfig)  
    EndpointV2.setConfig(aOApp, receiveLibrary, receiveConfig)  
    EndpointV2.setDelegate(delegate)  
    

These custom configurations will be stored on-chain as part of EndpointV2 and
your respective `SendLibrary` and `ReceiveLibrary`:

    
        // LayerZero V2 MessageLibManager.sol (part of EndpointV2.sol)  
    mapping(address sender => mapping(uint32 dstEid => address lib)) internal sendLibrary;  
    mapping(address receiver => mapping(uint32 srcEid => address lib)) internal receiveLibrary;  
    mapping(address receiver => mapping(uint32 srcEid => Timeout)) public receiveLibraryTimeout;  
    // LayerZero V2 SendLibBase.sol (part of SendUln302.sol)  
    mapping(address oapp => mapping(uint32 eid => ExecutorConfig)) public executorConfigs;  
    // LayerZero V2 UlnBase.sol (both in SendUln302.sol and ReceiveUln302.sol)  
    mapping(address oapp => mapping(uint32 eid => UlnConfig)) internal ulnConfigs;  
    // LayerZero V2 EndpointV2.sol  
    mapping(address oapp => address delegate) public delegates;  
    

You can find example scripts to make these calls under [Security and Executor
Configuration](/v2/developers/evm/protocol-gas-settings/default-config).

danger

These configurations control the verification mechanisms of messages sent
between your OApps. You should review the above settings carefully.

If no configuration is set, the configuration will fallback to the default
configurations set by LayerZero Labs. For example:

    
        /// @notice The Send Library is the Oapp specified library that will be used to send the message to the destination  
    /// endpoint. If the Oapp does not specify a Send Library, the default Send Library will be used.  
    /// @dev If the Oapp does not have a selected Send Library, this function will resolve to the default library  
    /// configured by LayerZero  
    /// @return lib address of the Send Library  
    /// @param _sender The address of the Oapp that is sending the message  
    /// @param _dstEid The destination endpoint id  
    function getSendLibrary(address _sender, uint32 _dstEid) public view returns (address lib) {  
        lib = sendLibrary[_sender][_dstEid];  
        if (lib == DEFAULT_LIB) {  
            lib = defaultSendLibrary[_dstEid];  
            if (lib == address(0x0)) revert Errors.LZ_DefaultSendLibUnavailable();  
        }  
    }  
    

  

  4. (**Recommended**) Optionally, if you inherit `OAppOptionsType3`, you can enforce specific gas settings when users call `aOApp.send`.
    
        // SPDX-License-Identifier: UNLICENSED  
    pragma solidity ^0.8.22;  
      
    import { OApp, Origin, MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";  
    import { OAppOptionsType3 } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";  
    import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";  
      
    contract MyOApp is OApp, OAppOptionsType3 {  
      
        /// @notice Message types that are used to identify the various OApp operations.  
        /// @dev These values are used in things like combineOptions() in OAppOptionsType3.  
        uint16 public constant SEND = 1;  
      
        constructor(address _endpoint, address _owner) OApp(_endpoint, _owner) Ownable(_owner) {}  
        // ... contract continues  
    }  
    
    
        EnforcedOptionParam[] memory aEnforcedOptions = new EnforcedOptionParam[](1);  
    // Send gas for lzReceive (A -> B).  
    aEnforcedOptions[0] = EnforcedOptionParam({eid: bEid, msgType: SEND, options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(50000, 0)}); // gas limit, msg.value  
    aOApp.setEnforcedOptions(aEnforcedOptions);  
    

See more details about each setting below.

### Implementing `_lzSend`​

To start sending messages from your OApp, you'll need to call `_lzSend` with
your own contract logic.

Depending on your application, this might initiate token transfers, burn and
mint NFTs, or just pass a simple string between chains.

#### Example: Sending a String​

Consider the scenario where you want to send a simple string `_message` to
store on a destination chain.

    
    
    // Sends a message from the source to destination chain.  
    function send(uint32 _dstEid, string memory _message, bytes calldata _options) external payable {  
        bytes memory _payload = abi.encode(_message); // Encodes message as bytes.  
        _lzSend(  
            _dstEid, // Destination chain's endpoint ID.  
            _payload, // Encoded message payload being sent.  
            _options, // Message execution options (e.g., gas to use on destination).  
            MessagingFee(msg.value, 0), // Fee struct containing native gas and ZRO token.  
            payable(msg.sender) // The refund address in case the send call reverts.  
        );  
    }  
    

You start by first encoding the `_message` as a bytes array and passing five
arguments to `_lzSend`:

  1. `_dstEid`: The destination Endpoint ID.

  2. `_message`: The message to be sent.

  3. `_options`: Message execution options for protocol handling _(see below)_.

  4. `MessagingFee`: what token will be used to pay for the transaction?
    
        struct MessagingFee {  
        uint256 nativeFee; // Fee amount in native gas token.  
        uint256 lzTokenFee; // Fee amount in ZRO token.  
    }  
    

  5. `_refundAddress`: specifies the address to which any excess fees should be refunded.
    
        payable(msg.sender) // The address of the user or contract that initiated the transaction.  
    

info

If your refund address is a smart contract you will need to implement a
fallback function in order for it to receive the refund.

### Message Execution Options​

You might be wondering, what are message execution `_options`?

`_options` are a generated bytes array with specific instructions for the
[Security Stack](/v2/home/modular-security/security-stack-dvns) and
[Executor](/v2/home/permissionless-execution/executors) to use when handling
the authentication and execution of received messages.

You can find how to generate all the available `_options` in [Message
Execution Options](/v2/developers/evm/protocol-gas-settings/options), but for
this tutorial you'll focus on providing the Executor with a gas amount to use
when executing our message:

  * `ExecutorLzReceiveOption`: instructions for how much gas should be used when calling `lzReceive` on the destination Endpoint.

When generated correctly, the `_options` parameter will be used in the
Endpoint `quote` to ensure enough `msg.value` is paid based to match the
Executor amount.

For example, to send a vanilla OFT, you usually need `60000` wei in
destination native gas during message execution:

    
    
    _options = 0x0003010011010000000000000000000000000000ea60;  
    

tip

`ExecutorLzReceiveOption` specifies a quote paid in advance on the source
chain by the `msg.sender` for the equivalent amount of native gas to be used
on the destination chain. If the actual cost to execute the message is less
than what was set in `_options`, there is no default way to refund the sender
the difference. Application developers need to thoroughly profile and test gas
amounts to ensure consumed gas amounts are correct and not excessive.

#### Optional: Enforced Options​

Once you determine ideal message `_options`, you will want to make sure users
adhere to it. In the case of OApp, you mostly want to make sure the gas amount
you have included in `_options` for the `lzReceive` call can be enforced for
all callers of `_lzSend`, to prevent reverts.

To require a caller to use a specific `_options`, your OApp can inherit the
enforced options interface `IOAppOptionsType3.sol`:

    
    
    // SPDX-License-Identifier: MIT  
    pragma solidity ^0.8.22;  
      
    import { OApp, Origin, MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";  
    import { IOAppOptionsType3 } from "@layerzerolabs/oapp-evm/contracts/oapp/interfaces/IOAppOptionsType3.sol";  
    import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";  
      
    contract MyOApp is OApp, IOAppOptionsType3 {  
        constructor(address _endpoint, address _owner) OApp(_endpoint, _owner) Ownable(_owner) {}  
    }  
    

The `setEnforcedOptions` function allows the contract owner to specify
mandatory execution options, making sure that the application behaves as
expected when users interact with it.

Here is code snippet from `oapp/libs/OAppOptionsType3.sol`:

    
    
    /**  
     * @dev Sets the enforced options for specific endpoint and message type combinations.  
     * @param _enforcedOptions An array of EnforcedOptionParam structures specifying enforced options.  
     *  
     * @dev Only the owner/admin of the OApp can call this function.  
     * @dev Provides a way for the OApp to enforce things like paying for PreCrime, AND/OR minimum dst lzReceive gas amounts etc.  
     * @dev These enforced options can vary as the potential options/execution on the remote may differ as per the msgType.  
     * eg. Amount of lzReceive() gas necessary to deliver a lzCompose() message adds overhead you dont want to pay  
     * if you are only making a standard LayerZero message ie. lzReceive() WITHOUT sendCompose().  
     */  
    function setEnforcedOptions(EnforcedOptionParam[] calldata _enforcedOptions) public virtual onlyOwner {  
        _setEnforcedOptions(_enforcedOptions);  
    }  
      
    function _setEnforcedOptions(EnforcedOptionParam[] memory _enforcedOptions) internal virtual {  
        for (uint256 i = 0; i < _enforcedOptions.length; i++) {  
            // @dev Enforced options are only available for optionType 3, as type 1 and 2 dont support combining.  
            _assertOptionsType3(_enforcedOptions[i].options);  
            enforcedOptions[_enforcedOptions[i].eid][_enforcedOptions[i].msgType] = _enforcedOptions[i].options;  
        }  
      
        emit EnforcedOptionSet(_enforcedOptions);  
    }  
    

To use `setEnforcedOptions`, we only need to pass one parameter:

  * `EnforcedOptionParam[]`: a struct specifying the execution options per message type and destination chain.

    
    
    struct EnforcedOptionParam {  
        uint32 eid; // destination endpoint id  
        uint16 msgType; // the message type  
        bytes options; // the execution option bytes array  
    }  
    

You will need to define your OApp's `msgType` and what those messaging types
look like. For example, OFT Standard only has handling for 2 message types:

    
    
    // @dev execution types to handle different enforcedOptions  
    uint16 internal constant SEND = 1; // a standard token transfer via send()  
    uint16 internal constant SEND_AND_CALL = 2; // a composed token transfer via send()  
    

You will pass these values in when specifying the `msgType` for your
`_options`.

If you're looking for complete example how to set enforced options in Solidity
this Foundry [test case](https://github.com/LayerZero-
Labs/LayerZero-v2/blob/7aebbd7c79b2dc818f7bb054aed2405ca076b9d6/packages/layerzero-v2/evm/oapp/test/OFT.t.sol#L441)
might be helpful:

    
    
    function test_combine_options() public {  
        uint32 eid = 1;  
        uint16 msgType = 1;  
      
        bytes memory enforcedOptions = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);  
        EnforcedOptionParam[] memory enforcedOptionsArray = new EnforcedOptionParam[](1);  
        enforcedOptionsArray[0] = EnforcedOptionParam(eid, msgType, enforcedOptions);  
        aOFT.setEnforcedOptions(enforcedOptionsArray);  
      
        bytes memory extraOptions = OptionsBuilder.newOptions().addExecutorNativeDropOption(  
            1.2345 ether,  
            addressToBytes32(userA)  
        );  
      
        bytes memory expectedOptions = OptionsBuilder  
            .newOptions()  
            .addExecutorLzReceiveOption(200000, 0)  
            .addExecutorNativeDropOption(1.2345 ether, addressToBytes32(userA));  
      
        bytes memory combinedOptions = aOFT.combineOptions(eid, msgType, extraOptions);  
        assertEq(combinedOptions, expectedOptions);  
    }  
    

### Estimating Gas Fees​

Often with the LayerZero protocol you'll want to know an estimate of how much
gas a message will cost to be sent and received.

To do this you can implement a `quote()` function within the OApp contract to
return an estimate from the Endpoint contract to use as a recommended
`msg.value`.

    
    
    /* @dev Quotes the gas needed to pay for the full omnichain transaction.  
     * @return nativeFee Estimated gas fee in native gas.  
     * @return lzTokenFee Estimated gas fee in ZRO token.  
     */  
    function quote(  
        uint32 _dstEid, // Destination chain's endpoint ID.  
        string memory _message, // The message to send.  
        bytes calldata _options, // Message execution options  
        bool _payInLzToken // boolean for which token to return fee in  
    ) public view returns (uint256 nativeFee, uint256 lzTokenFee) {  
        bytes memory _payload = abi.encode(_message);  
        MessagingFee memory fee = _quote(_dstEid, _payload, _options, _payInLzToken);  
        return (fee.nativeFee, fee.lzTokenFee);  
    }  
    

The `_quote` can be returned in either the native gas token or in ZRO token,
supporting both payment methods.

Because cross-chain gas fees are dynamic, this quote should be generated right
before calling `_lzSend` to ensure accurate pricing.

tip

Make sure that the arguments passed into the `quote()` function identically
match the parameters used in the `lzSend()` function. If parameters mismatch,
you may run into errors as your `msg.value` will not match the actual gas
quote.

  

info

Remember that when sending a message through LayerZero, the `msg.sender` will
be paying for gas on the source chain, fees to the selected DVNs to validate
the message, and for gas on the destination chain to execute the transaction.
This results in a single bundled fee on the source chain, abstracting gas away
on every other chain, leading to better composability.

### Implementing `_lzReceive`​

To start receiving messages on a destination, your OApp needs to override the
`_lzReceive` function.

    
    
    function _lzReceive(  
        Origin calldata _origin, // struct containing info about the message sender  
        bytes32 _guid, // global packet identifier  
        bytes calldata payload, // encoded message payload being received  
        address _executor, // the Executor address.  
        bytes calldata _extraData // arbitrary data appended by the Executor  
        ) internal override {  
            data = abi.decode(payload, (string)); // your logic here  
    }  
    

`_lzReceive` takes a few main inputs for message handling:

  1. `_origin`: a struct generated by the protocol containing information about where the message came from.
    
        struct Origin {  
        uint32 srcEid; // The source chain's Endpoint ID.  
        bytes32 sender; // The sending OApp address.  
        uint64 nonce; // The message nonce for the pathway.  
    }  
    

  2. `_guid`: a unique identifier for tracking the message.

  3. `payload`: the message in encoded bytes format.

  4. `_executor`: the address of the Executor calling the Endpoint's `lzReceive` function.

  5. `_extraData`: Designed to carry arbitrary data appended by the Executor and passed along with the message payload. Cannot be modified by the OApp.

note

Even if your receiving OApp contract doesn't use every interface parameter,
they must be included to match `_lzReceive`'s function signature.

  

What's great about an OApp is that you can define any arbitrary contract logic
to trigger within `_lzReceive`.

That means that this function could store data, trigger other functions, or
even invoke a nested `_lzSend` again to trigger an action back on the source
chain. For advanced usage, LayerZero provides a full list of [Message Design
Patterns](/v2/developers/evm/oapp/message-design-patterns) to experiment with.

### Setting Delegates​

In a given OApp, a delegate is able to apply configurations on behalf of the
OApp. This delegate gains the ability to handle various critical tasks such as
setting configurations and MessageLibs, and skipping or clearing payloads.

By default, the contract owner is set as the delegate. The `setDelegate`
function allows for changing this, but we recommend you always keep contract
owner as delegate.

    
    
    function setDelegate(address _delegate) public onlyOwner {  
        endpoint.setDelegate(_delegate);  
    }  
    

For instructions on how to implement custom configurations after setting your
delegate, refer to the [OApp Configuration](/v2/developers/evm/protocol-gas-
settings/default-config).

### Security and Governance​

Given the impact associated with deployment, configuration, and debugging
functions, OApp owners may want to add additional security measures in place
to call core contract functions beyond just the `onlyOwner` requirement, such
as:

  * **Governance Controls** : Implementing a governance mechanism where decisions to clear messages are voted upon by stakeholders.

  * **Multisig Deployment** : Deploying with a multisig wallet, preventing arbitrary actions by any one team member.

  * **Timelocks** : Using a timelock to delay the execution of certain function, giving stakeholders time to react if the function is called inappropriately.

## Usage​

That’s it. Once deployed, you just need to complete a few post-deployment
requirements.

### Setting Peer​

Once you've finished your [OApp Configuration](/v2/developers/evm/protocol-
gas-settings/default-config), you can open the messaging channel and connect
your OApp deployments by calling `setPeer`.

A peer is required to be set for each EID (or network). Ideally an OApp (or
OFT) will have multiple peers set where one and only one peer exists for one
EID.

The function takes 2 arguments: `_eid`, the destination endpoint ID for the
chain our other OApp contract lives on, and `_peer`, the destination OApp
contract address in `bytes32` format.

    
    
    // @dev must-have configurations for standard OApps  
    function setPeer(uint32 _eid, bytes32 _peer) public virtual onlyOwner {  
        peers[_eid] = _peer; // Array of peer addresses by destination.  
        emit PeerSet(_eid, _peer); // Event emitted each time a peer is set.  
    }  
    

caution

This function opens your OApp to start receiving messages from the messaging
channel, meaning you should configure any application settings you intend on
changing prior to calling `setPeer`.

  

danger

OApps need `setPeer` to be called correctly on both contracts to send
messages. The peer address uses `bytes32` for handling non-EVM destination
chains.

If the peer has been set to an incorrect destination address, your messages
will not be delivered and handled properly. If not resolved, users can
potentially pay gas on source without any corresponding action on destination.
You can confirm the peer address is the expected destination OApp address by
viewing the `peers` mapping directly.

  

The [LayerZero Endpoint](/v2/home/protocol/layerzero-endpoint) will use this
peer as the destination address for the cross-chain message:

    
    
    // @dev the endpoint send method called by _lzSend  
    endpoint.send{ value: messageValue }(  
        MessagingParams(_dstEid, _getPeerOrRevert(_dstEid), _message, _options, _fee.lzTokenFee > 0),  
        _refundAddress  
    );  
    

To see if an address is the trusted peer you expect for a destination, you can
read the `peers` mapping directly.

### Calling `send`​

Once your source and destination chain contracts have successfully been
deployed and peers set, you're ready to begin passing messages between them.

Remember to generate a fee estimate using `quote` first, and then pass the
returned native gas amount as your `msg.value`.

    
    
    > MyOApp.send{value: msg.value}(101, "My first omnichain message!", 0x0003010011010000000000000000000000000000c350)  
    

### Tracing and Troubleshooting​

You can follow your testnet and mainnet transaction statuses using [LayerZero
Scan](https://layerzeroscan.com/).

Refer to [Debugging Messages](/v2/developers/evm/troubleshooting/debugging-
messages) for any unexpected complications when sending a message.

You can also ask for help or follow development in the
[Discord](https://discord-layerzero.netlify.app/discord).

[Edit this page](https://github.com/LayerZero-
Labs/docs/edit/main/docs/developers/evm/oapp/overview.md)

[PreviousDebugging LayerZero Errors](/v2/developers/evm/create-lz-
oapp/debugging)[NextOmnichain Fungible Token
(OFT)](/v2/developers/evm/oft/quickstart)

  * Installation
  * Creating an OApp Contract
  * Deployment Workflow
    * Implementing `_lzSend`
    * Message Execution Options
    * Estimating Gas Fees
    * Implementing `_lzReceive`
    * Setting Delegates
    * Security and Governance
  * Usage
    * Setting Peer
    * Calling `send`
    * Tracing and Troubleshooting



