# my-first-near-game
Step by step creation of the simplest P2E game on Near blockchain.

I use PC with installed OS Ubuntu - https://ubuntu.com/download/desktop,
Visual Studio Code - https://code.visualstudio.com/docs/setup/linux,
Godot Engine - https://godotengine.org/download

I'm not an experienced developer and if you haven't done blockchain game development before,
but know how to use Godot Engine, then repeating the steps in this tutorial shouldn't be difficult.
I am currently studying blockchain game development and I think my experience will help
newbies like me get their first application up and running on Near blockchain. 

Before we start, I ask you to complete the first steps yourself:
1. Creating a testnet Near account - https://docs.near.org/docs/develop/basics/create-account
2. Installing the near-cli - https://docs.near.org/docs/tools/near-cli#setup

## Features
- User login/logout through the [NEAR web wallet](https://wallet.near.org/).
- Calling view methods on smart contracts.
- Calling change methods on smart contracts.

## Getting Started
Since we are creating a P2E game, we need to create our own token.
The easiest way for us to do this is to take this example as a basis - https://examples.near.org/FT

## Pre-requisites
To develop Rust contracts you would need to:
* Install [Rustup](https://rustup.rs/):
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
* Add wasm target to your toolchain:
```bash
rustup target add wasm32-unknown-unknown
```
Download or clone this repository https://github.com/near-examples/FT
Open `/FT/ft/src/lib.rs` and add new function (copy and past on 78 line):

```
    #[payable]
    pub fn ft_mint(
        &mut self,
        receiver_id: AccountId,
        amount: U128,
    ) {
        //get initial storage usage
        assert!(
            amount.0 <= 1000, 
            "Cannot mint more than 1000 tokens"
        ); 

        let initial_storage_usage = env::storage_usage();

        let mut amount_for_account = self.token.accounts.get(&receiver_id).unwrap_or(0); 
        amount_for_account += amount.0; 

        self.token.accounts.insert(&receiver_id, &amount_for_account);
        self.token.total_supply = self
            .token    
            .total_supply
            .checked_add(amount.0)
            .unwrap_or_else(|| env::panic(b"Total supply overflow"));

        //refund any excess storage
        let storage_used = env::storage_usage() - initial_storage_usage;
        let required_cost = env::storage_byte_cost() * Balance::from(storage_used);
        let attached_deposit = env::attached_deposit();

        assert!(
            required_cost <= attached_deposit,
            "Must attach {} yoctoNEAR to cover storage", required_cost
        );

        let refund = attached_deposit - required_cost;
        if refund > 1 {
            Promise::new(env::predecessor_account_id()).transfer(refund);
        }
    }
```
Save and run `./build.sh`
After compiling you can deploy this contract:

    near login
    
    near create-account firstapp.YOUR_ACCOUNT_NAME.testnet --masterAccount YOUR_ACCOUNT_NAME.testnet --initialBalance 10
    
    CONTRACT_NAME=firstapp.YOUR_ACCOUNT_NAME.testnet
    
    ID=YOUR_ACCOUNT_NAME.testnet
    
    near deploy --wasmFile res/fungible_token.wasm --accountId $CONTRACT_NAME
    
 Congratulation you done first stage!
 Now we must initialization our smart contract before usage. 
 You can read more about metadata at 'nomicon.io'. Modify the parameters and create a token: 
 
    near call $CONTRACT_NAME new '{"owner_id": "'$ID'", "total_supply": "1000000000000000", "metadata": { "spec": "ft-1.0.0", "name": "Coin", "symbol": "CNM", "decimals": 8 }}' --accountId $ID
    
 Now every new account who want to use our smart contract must be registered (only once call `storage_deposit`):
 
    near call $CONTRACT_NAME storage_deposit '{}' --accountId ACCOUNT_ID.testnet --amount 0.00125
    
After that every new user can mint our token (we will need it in the future):

    near call $CONTRACT_NAME ft_mint '{ "receiver_id": "$ID", "amount": "32" }' --accountId $ID --gas 300000000000000
    
and we can check balance:

    near view $ID ft_balance_of '{"account_id": "'$ID'"}'
    
Ok, it is all with smart contract. 

**##Let's go doing game!**

Download this demo project https://godotengine.org/asset-library/asset/120
Clone or download this repository - https://github.com/svntax/godot-near-sdk
Download the C# Mono version of Godot 3.4. Copy the `addons/godot-near-sdk` directory into platformer project's `addons` directory.

Add `Near.gd` and `CryptoProxy.gd` as singletons through Godot's AutoLoad, and make sure that your `.csproj` file has the following elements in `<PropertyGroup>` and `<ItemGroup>`:
```xml
<PropertyGroup>
  <TargetFramework>net472</TargetFramework>
  <LangVersion>latest</LangVersion>
  <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
</PropertyGroup>
```
```xml
<ItemGroup>
  <PackageReference Include="Rebex.Elliptic.Ed25519" Version="1.2.1" />
  <PackageReference Include="SimpleBase" Version="2.1.0" />
</ItemGroup>
```

Edit platformer project. Duplicate PauseMenu.tscn twice. Edit new scenes (StartMenu and GameOverMenu).
StartMenu -> rename 


