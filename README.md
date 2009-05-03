Vending
=======

This is an implementation of a vending machine as per the spec from the Lambda Lounge language shootout ([Vending Machine Specification](http://stllambdalounge.files.wordpress.com/2009/03/vendingmachinespecification.pdf))

You will need Ruby 1.9 to run the specs/code

The core concept of this implementation is illustrated as follows:  
![delegation strategy](http://img.skitch.com/20090503-bnq9jky52t82sfwku4fhee8aj5.png "Context Modules delegated to for operations")

The VendingMachine owns all shared state managed by its two operating modes (VendingMode and ServiceMode).  It uses a named context to execute the behaviors of its operating modes, delegating all interaction requests to whatever the active context state is.

![forwardable context](http://img.skitch.com/20090503-nk7p62q72stc61a5n1dhjdgd1p.png "Forwardable Context")

Each named context uses Ruby's extend mechanism to add module methods to itself, then forwards some method calls it makes to the vending machine - the forwarded method calls allow for a clean separation between the shared-state owner (the VendingMachine) and the modes that need to operate on it (VendingMode and ServiceMode).

![forwarded method call](http://img.skitch.com/20090503-kh172nd3mgckf1e8bkq7hsq43a.png "Forwarded Method Call")

When the context object interacts with a forwarded method, the call looks the same as a local-method call.  Ruby handles the method forwarding through the Forwardable module.

Copyright
---------

Copyright (c) 2009 Mario Aquino. See LICENSE for details.
