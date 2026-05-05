##Monetization system  
A purchase and gifting system which respects the server's authority, which combines gamepass and developer products. The system uses a verification layer, allowing a single item to either be owned through one time gamepass purchases or through developer products. The ownership is validated by combining the MarketPlaceService, together with a DataStore backend to store purchases.  
To ensure the  security, all the validation is handled on the server through RemoteFunctions and RemoteEvents, preventing client tampering and system manipulation. The client is limited to UI interactions, while the server processes the data.  
The system uses UpdateAsync in order to safely handle writes, while storing the data through a table, unique for each player. The system comes with safeguards such as:  
- Prevention of duplicate purchases
- Request versioning to avoid race conditions caused by client input
- Error handling via pcall functions for all external service interactions
- A design that supports adding new items through a core table

Additionally, the UI retrieves information before the product's purchase, such as price, description and icon. Using the MarketPlaceService, we allow players to view the real time status of the gift recipient.
