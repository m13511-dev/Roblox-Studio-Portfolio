## Modular weapon system
A third person style weapon system, focused on scalability, performace and separation of functions. The core of the system is a runtime based architecture, in which each weapon gets a dedicated runtime instance, containing all the weapon's information and behaviour such as firing logic, reloading and state changes without relying on other scripts. The system is composed of multiple specialized modules such as:

Runtime core and methods
Raycasting Module
Utility systems
Visual modules
Effect system (visuals, audio and animations)
Configuration modules, exclusive to each weapon
The system supports multiple firemodes (semi, burst and auto), real time aim updating and client side visuals prediction, while maintaining the server's authority when it comes to critical calculations, blocking off the possibility of exploits based on system manipulation.
