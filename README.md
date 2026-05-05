![Roblox](https://img.shields.io/badge/Roblox-Studio-blue?logo=roblox)<br>
## ABOUT ME
Roblox developer focused on clean and organized systems, and performance optimization.
I build systems designed for real multiplayer environments, incorporating security in order to prevent exploits and unintended behaviours.
The entire project code won't be shown, only snippets and in some cases a module.

## MAIN PROJECTS
**Monetization system**  
A purchase and gifting system which respects the server's authority, which combines gamepass and developer products. The system uses a verification layer, allowing a single item to either be owned through one time gamepass purchases or through developer products. The ownership is validated by combining the MarketPlaceService, together with a DataStore backend to store purchases.  
To ensure the  security, all the validation is handled on the server through RemoteFunctions and RemoteEvents, preventing client tampering and system manipulation. The client is limited to UI interactions, while the server processes the data.  
The system uses UpdateAsync in order to safely handle writes, while storing the data through a table, unique for each player. The system comes with safeguards such as:  
- Prevention of duplicate purchases
- Request versioning to avoid race conditions caused by client input
- Error handling via pcall functions for all external service interactions
- A design that supports adding new items through a core table

Additionally, the UI retrieves information before the product's purchase, such as price, description and icon. Using the MarketPlaceService, we allow players to view the real time status of the gift recipient.

**Modular weapon system**  
A third person style weapon system, focused on scalability, performace and separation of functions. The core of the system is a runtime based architecture, in which each weapon gets a dedicated runtime instance, containing all the weapon's information and behaviour such as firing logic, reloading and state changes without relying on other scripts. 
The system is composed of multiple specialized modules such as:    
- Runtime core and methods  
- Raycasting Module  
- Utility systems  
- Visual modules  
- Effect system (visuals, audio and animations)  
- Configuration modules, exclusive to each weapon  

The system supports multiple firemodes (semi, burst and auto), real time aim updating and client side visuals prediction, while maintaining the server's authority when it comes to critical calculations, blocking off the possibility of exploits based on system manipulation.

## CONTACT ME
- [Roblox studio](https://create.roblox.com/talent/creators/724989015)
- Email: inflammablescience@gmail.com
- [Github](https://github.com/m13511-dev/Roblox-Studio-Portfolio)  
Open to commisions
