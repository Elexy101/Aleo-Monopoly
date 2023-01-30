program rent.aleo{

    record Dummy_Record_2{
        owner: address,
        amt: u32,
        gates: u64,
    }
    

    //Build a monopoly game of two players a, b address
    transition test2(owner: address,amt: u32) -> Dummy_Record_2{
        return Dummy_Record_2{
            owner: owner,
            gates: 0u64,
            amt: amt,
        };
    }



    //=====================================================================
    //Function to get rent payment for the owner 
    //=====================================================================
    function give_owner_rent(amt: u32) -> u32{
        amt  = 150u32;
        let white_color: bool = true;
        let black_color: bool = false;
        //rent amount
        let rent_amt: u32 = amt;
        let no_amt: u32 = 0u32;

        
        if(rent_amt != no_amt && white_color){
            return rent_amt;
        }else{
            return no_amt;
        }
    }


    //=====================================================================
    //Function to get rent payment for the addr2 
    //=====================================================================
    function give_addr2_rent(amt: u32) -> u32{
        amt  = 100u32;
        let white_color: bool = false;
        let black_color: bool = true;
        //rent amount
        let rent_amt: u32 = amt;
        let no_amt: u32 = 0u32;

        
        if(rent_amt != no_amt && black_color){
            return rent_amt;
        }else{
            return no_amt;
        }
    }
}