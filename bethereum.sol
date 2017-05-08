pragma solidity ^0.4.1;
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
    
    function Beth() {
        creator = msg.sender;
    }

    /** Function for placing a bet and matching. 
    *  The <i>runner</i> name is the key on which the bet matching is done.
    *  Each bet is matched with previously placed bets. Only exact match is done (no partially or cross matching implementd)
    */
    function bet(string runner, uint odds, bool isBack) payable {
        var bet = Bet(runner, msg.value, odds, msg.sender, isBack, false, true);
        if(positions[runner].length == 0) {
            keyNames.push(runner);
        }

        // match the bet if possible
        var bets = positions[runner];
        for (uint i = 0; i < bets.length; i++) {
            var currentBet = bets[i];
            if (bet.backBet != currentBet.backBet  && bet.stake == currentBet.stake) {
                bet.isMatched = true;
                currentBet.isMatched = true;
            }
        }
        
        positions[runner].push(bet);
    }
    
    /** Function for settling a market and trensferring the winnings 
    */
    function settle(string runner, bool isWinning) {
        if (msg.sender == creator) {
            var bets = positions[runner];
            
             for (uint i = 0; i < bets.length; i++) {
                var bet = bets[i];
                if(bet.isMatched){
                    if(bet.backBet && isWinning){
                        if(bet.sender.send(bet.odds * bet.stake)){}
                    }
                    if (!bet.backBet && ! isWinning) {
                        if(bet.sender.send(bet.stake + bet.stake/bet.odds)){}
                    }
                }else{
                    if(bet.sender.send(bet.stake)){}
                }
            }
        }
    }
    
}
