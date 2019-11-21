pragma solidity ^0.5.0;

    /*
        The EventTicketsV2 contract keeps track of the details and ticket sales of multiple events.
     */
contract EventTicketsV2 {

    address payable public owner;
    uint   PRICE_TICKET = 100 wei;

      
    uint public idGenerator;
    uint public eventsCount = 0;


       struct Event{
        string description;
        string url;
        uint totalTickets;
        uint sales;
        mapping(address => uint256) buyers;
        bool isOpen;
    }

    mapping(uint => Event) events;

    event LogEventAdded(string desc, string url, uint ticketsAvailable, uint eventId);
    event LogBuyTickets(address buyer, uint eventId, uint numTickets);
    event LogGetRefund(address accountRefunded, uint eventId, uint numTickets);
    event LogEndSale(address owner, uint balance, uint eventId);

    modifier isOwner() {require(msg.sender == owner, "You must be the owner :)"); _; }

    constructor() public{ owner = msg.sender; }

    function addEvent(string memory description, string memory url, uint ticketsNum) public isOwner returns(uint eventId){
        eventId = eventsCount++;
        
        events[eventId] = Event({
            description: description,
            url: url,
            totalTickets: ticketsNum,
            isOpen: true,
            sales: 0
        });

        emit LogEventAdded(description, url, ticketsNum, idGenerator);
        return eventId;
    } 

    function readEvent(uint eventId)
        public
        view
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        Event storage currentEvent = events[eventId];

        description = currentEvent.description;
        website = currentEvent.url;
        totalTickets = currentEvent.totalTickets;
        sales = currentEvent.sales;
        isOpen = currentEvent.isOpen;
    }


    function buyTickets(uint eventId, uint numOfTickets) public payable {

        require(events[eventId].isOpen, "Sorry the event is not opened yet:)");
        require(msg.value >= (PRICE_TICKET * numOfTickets), "Sorry you didn't send enogh ether");
        require(events[eventId].totalTickets >= numOfTickets, " There are no available tickets");

        events[eventId].buyers[msg.sender] += numOfTickets;
        events[eventId].totalTickets -= numOfTickets;
        events[eventId].sales += numOfTickets;

        uint amountToRefund = msg.value - (PRICE_TICKET * numOfTickets);
        if(amountToRefund > 0){
            msg.sender.transfer(amountToRefund);
        }
        emit LogBuyTickets( msg.sender, eventId, numOfTickets);
    }

       function getRefund(uint eventId) public payable {
        Event storage currentEvent = events[eventId];
        require(currentEvent.buyers[msg.sender] > 0, "you do not have any tickets yet");
        uint numTickets = currentEvent.buyers[msg.sender];
        uint amountToRefund = PRICE_TICKET * numTickets;
        currentEvent.buyers[msg.sender] = 0;
        msg.sender.transfer(amountToRefund);
        emit LogGetRefund(msg.sender, eventId,  numTickets);
    }

    function getBuyerNumberTickets(uint eventId) public view returns(uint ticketsNum) {
    ticketsNum = events[eventId].buyers[msg.sender];
    }

    function endSale(uint eventId) public isOwner {
        events[eventId].isOpen = false;
        emit LogEndSale(owner, address(this).balance, eventId);
        owner.transfer(address(this).balance);
    }
}
