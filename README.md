# Loom Unity

Sample show how to connect unity client with side chain (loom chain) using loom unity sdk

## Plugin-based Dappchain

### Write contract

- contract: `contracts/src/blueprint.go`
- contract have to be built before dappchain run
- then we must specific built contract in `genesis.json` as a plugin contract like bellow

```yaml
{
  "contracts":
    [
      {
        "vm": "plugin",
        "format": "plugin",
        "name": "BluePrint",
        "location": "blueprint:0.0.1",
        "init": {},
      },
    ],
}
```

- then run dappchain

```js
loom run
```

- now we have a running dappchain with deployed (plugged) contract

### Connect with Dappchain from Unity Client

- to get plugged contract, we look up it by **name**

```Csharp
var contractAddr = await client.ResolveContractAddressAsync("BluePrint");
this.contract = new Contract(client, contractAddr, callerAddr);
```

- then call function by `CallAsync`

```Csharp
await this.contract.CallAsync("SetMsg", new MapEntry
{
    Key = "123",
    Value = "hello!"
});
```

## EVM-based Dappchain

### Write contract

- nothing special, we create a truffle project and migrate contracts to dappchain as normal truffle project

- before migrate, we need generate a private-public key pair

```js
loom genkey -k priv -a pub
```

- just add truffle config to connect with dappchain

```js
const { readFileSync } = require("fs")
const LoomTruffleProvider = require("loom-truffle-provider")

const chainId = "default"
const writeUrl = "http://127.0.0.1:46658/rpc"
const readUrl = "http://127.0.0.1:46658/query"
const privateKey = readFileSync("./priv", "utf-8")

const loomTruffleProvider = new LoomTruffleProvider(chainId, writeUrl, readUrl, privateKey)

module.exports = {
  networks: {
    loom_dapp_chain: {
      provider: loomTruffleProvider,
      network_id: "*"
    }
  }
}
```

- then migrate.

### Connect with Dappchain from Unity Client

- we get deployed contract by abi and address

```Csharp
const string abi = "[{\"constant\":false,\"inputs\":[{\"name\":\"_tileState\",\"type\":\"string\"}],\"name\":\"SetTileMapState\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"GetTileMapState\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"state\",\"type\":\"string\"}],\"name\":\"OnTileMapStateUpdate\",\"type\":\"event\"}]\r\n";

// change deployed contract address here
Address contractAddr = Address.FromHexString("0x2939768210Ed41bC546D96E7F50C79eca638CAF0");

var callerAddr = Address.FromPublicKey(this.publicKey);
EvmContract evmContract = new EvmContract(this.client, contractAddr, callerAddr, abi);
```

- then call function

```Csharp
TileMapStateOutput result = await this.contract.StaticCallDTOTypeOutputAsync<TileMapStateOutput>("GetTileMapState");
```

## Summary

- still not clear the benefit of using plugin contract. Furthermore, golang seems to be not easy to implement.
- using evm-based contract is more familiar with who has experience in develop ethereum applications. Maybe good place to start with.
