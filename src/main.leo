program shib.aleo{
    record Record {
        owner: address,
        amt: u32,
        gates: u64,
    }

    record Buildings{
        owner : address,
        addr2 : address,
        gates: u64,
        amt : u32,
        amt2 : u32,
    }

    //Build a monopoly game of two players a, b address
    transition main(owner: address, addr2: address, amt: u32, amt2: u32) -> Buildings{
        return Buildings{
            owner: owner,
            addr2: addr2,
            gates: 0u64,
            amt: amt,
            amt2: amt2,
        };
    }

    //Player a or player b buys a land at 1000 per price 
    transition monopoly_buy (owner: address, addr2: address, amt: u32, amt2: u32) -> Buildings{
        let all_int: u32 = 123u32;
        let all_int2: u32 = ((all_int * all_int) / 10u32) % 10000u32;

        let buy : Buildings = Buildings{
            owner: owner,
            addr2: addr2,
            gates: 0u64,
            amt:  amt - all_int2,
            amt2: amt2
        };
        return buy;
    
    }

       transition monopoly_buy1 (owner: address, addr2: address, amt: u32, amt2: u32) -> Buildings{
        let all_int: u32 = 123u32;
        let all_int2: u32 = ((all_int * all_int) / 10u32) % 10000u32;

        let buy : Buildings = Buildings{
            owner: owner,
            addr2: addr2,
            gates: 0u64,
            amt:  amt , //addr2 pays owner 100 NGN for rent
            amt2: amt2 - all_int2 //remaining balance of addr2
        };
        return buy;
    
    }

    //player a receive rent of 100 token per annum
    transition monopoly_rent (owner: address, addr2: address, amt: u32, amt2: u32) -> Buildings{
        let rent: u32 = 100u32;
        return Buildings{
            owner: owner,
            addr2: addr2,
            gates: 0u64,
            amt: amt + rent,
            amt2: amt2
        };

    }


    transition monopoly_sale (owner: address, addr2: address, amt: u32, amt2: u32) -> Buildings{
        let sale_ownership: u32 = amt;
        let new_ownership: u32 = amt2 + sale_ownership;
        return Buildings{
            owner: owner,
            addr2: addr2,
            gates: 0u64,
            amt: amt - sale_ownership,
            amt2: new_ownership
        };
    }
}