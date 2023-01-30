program purchase.aleo{

    record Dummy_Record_1 {
        owner: address,
        amt: u32,
        gates: u64,
    }
    

    //Build a monopoly game of two players a, b address
    transition test(owner: address,amt: u32) -> Dummy_Record_1{
        return Dummy_Record_1{
            owner: owner,
            gates: 0u64,
            amt: amt,
        };
    }

    //===============================================================
    //Function to select the color attribute of building for owner
    //===============================================================
    function owner_color(amt: u32) -> u32{
        amt  = 1500u32;
        let white_color: bool = true;
        let black_color: bool = false;
        let white_amt: u32 = 1500u32;
        let black_amt: u32 = 1000u32;
        let owner_amt: u32 = amt;

        
        if(owner_amt == white_amt && white_color){
            return white_amt;
        }else{
            return black_amt;
        }
    }



    //================================================================
    //Function to select the color attribute of building for address2
    //================================================================
    function addr2_color(amt: u32) -> u32{
        amt  = 1000u32;
        let white_color: bool = true;
        let black_color: bool = false;
        let white_amt: u32 = 1500u32;
        let black_amt: u32 = 1000u32;
        let buy_amt: u32 = amt;

        
        if(buy_amt != white_amt && white_color){
            return black_amt;
        }else{
            return white_amt;
        }
    }

}
