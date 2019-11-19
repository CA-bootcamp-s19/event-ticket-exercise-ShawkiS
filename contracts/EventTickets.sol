pragma solidity ^0.5.0;

    /*
        The EventTickets contract keeps track of the details and ticket sales of one event.
     */

contract EventTickets {

    address payable public owner;
    uint   TICKET_PRICE = 100 wei;

    struct Event{
        string description;
        string url;
        uint totalTickets;
        uint sales;
        mapping(address => uint256) buyers;
        bool isOpen;
    }

    Event myEvent;


    event LogBuyTickets(address purchaser, uint numOfTickets);
    event LogGetRefund(address requester, uint numOfTicketsRefunded);
    event LogEndSale(address owner, uint transferedBalance);

    modifier isOwner() {require(msg.sender == owner, "You must be the owner :)"); _; }
    

    constructor( string memory description, string memory url, uint totalTickets) public{
        owner = msg.sender;
        myEvent.description = description;
        myEvent.url = url;
        myEvent.totalTickets  = totalTickets;
        myEvent.sales = 0;
        myEvent.isOpen = true;
    }

    function readEvent()
        public
        view
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        description = myEvent.description;
        website = myEvent.url;
        totalTickets = myEvent.totalTickets;
        sales = myEvent.sales;
        isOpen = myEvent.isOpen;
    }

    function getBuyerTicketCount(address buyerAdd) public view returns(uint ticketsPurchasedCount){
        ticketsPurchasedCount = myEvent.buyers[buyerAdd];
    }


        function buyTickets( uint numTickets) public payable returns(uint) {
        require(myEvent.isOpen, "Sorry the event is not opened yet:)");
        require(msg.value >= (TICKET_PRICE * numTickets), "Sorry you didn't send enogh ether");
        require(myEvent.totalTickets - myEvent.sales >= numTickets, "There are no available tickets");
        
        myEvent.buyers[msg.sender] += numTickets;
        myEvent.sales += numTickets;
        
        uint amountToRefund = msg.value - (TICKET_PRICE * numTickets);
        if(amountToRefund > 0){
            msg.sender.transfer(amountToRefund);
        }
        
        emit LogBuyTickets(msg.sender,numTickets);
        return numTickets;
    }

    function getRefund() public payable {
        uint ticketsPurchased = myEvent.buyers[msg.sender];
        require(ticketsPurchased > 0, "There is nothing to refund:)");
        myEvent.buyers[msg.sender] = 0;
        myEvent.totalTickets += ticketsPurchased;
        msg.sender.transfer(TICKET_PRICE * ticketsPurchased);
        emit LogGetRefund(msg.sender,ticketsPurchased);
    }

    function endSale() public isOwner{

        require(myEvent.isOpen == true, " Sale is already ended");
        myEvent.isOpen = false;
        
        owner.transfer(address(this).balance);
        emit LogEndSale(msg.sender, address(this).balance);
    }
}
