pragma solidity >=0.4.22 <0.6.0;
/** A PoC for a betting exchange.
*/
contract Beth {
    
    address creator;
    mapping(string => Bet[]) positions;
    string[] keyNames;
    
    struct Bet {
        string runner;
        // value in ETH
        uint stake;
        // odds in decimal multipled by 100
        uint odds;
        address sender;
        // true if BACK bet, false if LAY
        bool backBet;
        bool isMatched;
        bool exists;
    }
    
    constructor() public {
        creator = msg.sender;
    }

    /** Function for placing a bet and matching. 
    *  The <i>runner</i> name is the key on which the bet matching is done.
    *  Each bet is matched with previously placed bets. Only exact match is done (no partially or cross matching implementd)
    */
    function bet(string runner, uint odds, bool isBack) public payable {
        Bet memory placedBet = Bet(runner, msg.value, odds, msg.sender, isBack, false, true);
        if(positions[runner].length == 0) {
            keyNames.push(runner);
        }

        // match the bet if possible
        Bet[] memory bets = positions[runner];
        for (uint i = 0; i < bets.length; i++) {
            Bet memory currentBet = bets[i];
            if (placedBet.backBet != currentBet.backBet  && placedBet.stake == currentBet.stake) {
                placedBet.isMatched = true;
                currentBet.isMatched = true;
            }
        }
        
        positions[runner].push(placedBet);
    }
    
    /** Function for settling a market and trensferring the winnings 
    */
    function settle(string runner, bool isWinning) public {
        if (msg.sender == creator) {
            Bet[] memory bets = positions[runner];
            
             for (uint i = 0; i < bets.length; i++) {
                Bet memory currentBet = bets[i];
                if(currentBet.isMatched){
                    if(currentBet.backBet && isWinning){
                        if(currentBet.sender.send(currentBet.odds * currentBet.stake)){}
                    }
                    if (!currentBet.backBet && ! isWinning) {
                        if(currentBet.sender.send(currentBet.stake + currentBet.stake/currentBet.odds)){}
                    }
                }else{
                    if(currentBet.sender.send(currentBet.stake)){}
                }
            }
        }
    }
    
}
