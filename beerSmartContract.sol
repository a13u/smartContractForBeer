/***
 * Inviatation for a beer - SMART CONTRACT
 * Use this smart contract for an invitation for a beer
 * Send ethers to the contract as pawn - if you go for a beer and both commit this, the pawn is returned, otherwise the BEERMONSTER gets the ethers
 * 
 * Should motivate to interact with people in RL ;)
 * ***/
 
pragma solidity ^0.4.16;

contract InvitationForABeerSmartContract {
    //address of the beer monster which gets the beer if the persons do not drink it (attention: aggresive)
    address beerMonster=0x7eF12B842Ea250c3788ddd805b4BB15de1D35871;
    
    //first address: inviting person, second address: invited person, third integer: pawn
    mapping(address => mapping(address=>uint)) pawnList;
    //first address: inviting person, second address: invited person, third uint: deadline in minutes within both persons have to confirm that they have drunken the beer
    mapping(address => mapping(address=>uint)) deadline;

    
    //beer "drunken" confirmations
    mapping(address => mapping(address=>bool)) confirmationList1;
    mapping(address => mapping(address=>bool)) confirmationList2;
    
     address public owner;
     
     
    function InvitationForABeerSmartContract() public{
       owner=msg.sender;
    }
    
    //if no address of the invited person is provided then the money is returned
    function invite() payable public{
        msg.sender.transfer(msg.value);
    }
    
    //inviatation: the sender invites the invited person - no deadline
    function invite(address invitedPerson) payable public{
        pawnList[msg.sender][invitedPerson]+=msg.value;
        //invited[invitedPerson]=msg.sender;
    }
 
     //inviatation: the sender invites the invited person - with deadline - if the deadline is reached, the beerMonster can eat the pawn
    function inviteWithDeadline(address invitedPerson,uint deadlineInMinutes) payable public{
        pawnList[msg.sender][invitedPerson]+=msg.value;
        //invited[invitedPerson]=msg.sender;
        deadline[msg.sender][invitedPerson]=now+deadlineInMinutes*1 minutes;
    }   

    //feed the beer monster - just for fun or to support the project
    function feedTheBeerMonster() payable public{
        beerMonster.transfer(msg.value);
    }
    
    //if the contract withdrawn by the invitor then the beermonster gets the pawn
    function withdrawInviation(address invitedPerson) public{
        beerMonster.transfer(pawnList[msg.sender][invitedPerson]);
        pawnList[msg.sender][invitedPerson]=0;
        deadline[msg.sender][invitedPerson]=0;
        
        confirmationList1[msg.sender][invitedPerson]=false;
        confirmationList2[msg.sender][invitedPerson]=false;
    }

    
    //confirmation function called by person which invited the other person (invitedPerson)
    function beerDrunkenConfirmationFromSponsor(address invitedPerson) public{
       if(confirmationList1[msg.sender][invitedPerson] && confirmationList2[msg.sender][invitedPerson]){
            confirmationList1[msg.sender][invitedPerson]=false;
            confirmationList2[msg.sender][invitedPerson]=false;
           return;
       }
       
        if(pawnList[msg.sender][invitedPerson]>0){
            //sponsor confirms that the beer was drunken
           confirmationList1[msg.sender][invitedPerson]=true; 
        }
        
        if(confirmationList1[msg.sender][invitedPerson] && confirmationList2[msg.sender][invitedPerson]){
            //both confirmed - return money
            msg.sender.transfer(pawnList[msg.sender][invitedPerson]);
            pawnList[msg.sender][invitedPerson]=0;
            confirmationList1[msg.sender][invitedPerson]=false;
            confirmationList2[msg.sender][invitedPerson]=false;
        }
    }
    

        
    //confirmation function called by person which was invited  (invitedPerson)
    function beerDrunkenConfirmationFromInvitedPerson(address sponsor) public{
       if(confirmationList1[sponsor][msg.sender] && confirmationList2[sponsor][msg.sender]){
           return;
       }
       
       if(pawnList[sponsor][msg.sender]>0){
           //invited person confirms that the beer was drunken
           confirmationList2[sponsor][msg.sender]=true; 
        }
        
        if(confirmationList1[sponsor][msg.sender] && confirmationList2[sponsor][msg.sender]){
            //both confirmed - return money
            sponsor.transfer(pawnList[sponsor][msg.sender]);
            pawnList[sponsor][msg.sender]=0;
            confirmationList1[sponsor][msg.sender]=false;
            confirmationList2[sponsor][msg.sender]=false;
        }
    }
    

    
    //checks if deadline has passed - if so then the beermonster gets the beer
    function checkDeadline(address sponsor, address invitedPerson) public{
        if(now>deadline[sponsor][invitedPerson]){
            beerMonster.transfer(pawnList[sponsor][invitedPerson]);
            pawnList[sponsor][invitedPerson]=0;
            confirmationList1[sponsor][invitedPerson]=false;
            confirmationList2[sponsor][invitedPerson]=false;
        }
    }
   
    function kill() public {
        if (msg.sender == owner) selfdestruct(owner);
    }
}
    
    
