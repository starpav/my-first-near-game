# my-first-near-game
Step by step creation of the simplest P2E game on Near blockchain.

I use PC with installed OS Ubuntu - https://ubuntu.com/download/desktop,
Visual Studio Code - https://code.visualstudio.com/docs/setup/linux,
Godot Engine - https://godotengine.org/download

I'm not an experienced developer and if you haven't done blockchain game development before,
then repeating the steps in this tutorial shouldn't be difficult.
I am currently studying blockchain game development and I think my experience will help
newbies like me get their first application up and running on Near blockchain. 

Before we start, I ask you to complete the first steps yourself:
1. Creating a testnet Near account - https://docs.near.org/docs/develop/basics/create-account
2. Installing the near-cli - https://docs.near.org/docs/tools/near-cli#setup
3. Clone or download this repository - https://github.com/svntax/godot-near-sdk

## Features
- User login/logout through the [NEAR web wallet](https://wallet.near.org/).
- Calling view methods on smart contracts.
- Calling change methods on smart contracts.

## Getting Started
Так как мы создаем P2E game нам потребуется создать свой токен.
Самый легкий способ для нас это сделать, это взять  за основу данный пример https://examples.near.org/FT

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

Clone or download this repository https://github.com/near-examples/FT
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
