# Ensemble / Interoperability Formation

## Prerequisites :

 For this formation, you'll need :
* VSCode : https://code.visualstudio.com/
* The InterSystems addons suite for vscode : https://intersystems-community.github.io/vscode-objectscript/installation/
* Docker : https://docs.docker.com/get-docker/

## Goal : 

The goal of this formation is to learn InterSystems' interoperability framework, and particularly the use of : 
* Productions
* Messages
* Business Operations
* Adapters
* Business Processes
* Business Services
* REST Services and Operations
## The framework : 

This is the framework we will be working with :
![Framework](misc/img/FrameworkFull.png)

All of these components form a production. The arrows between them are **messages**. 
In the first place, we will build a production, with its operations, services and processes that will enable us to read data from a CSV file and save it in the iris database.
After building and composing our containers with the `docker-compose.yml` and `Dockerfile` files given, we will open a Management Portal. It will give us access to an HMI where we will be able to create our productions. 

The portal should be located at the url : http://localhost:52775/csp/sys/UtilHome.csp?$NAMESPACE=IRISAPP. 
## Productions : 
We can now create our first production. For this, we will go through the Interoperability and Configure menus : 

![ProductionMenu](misc/img/ProductionMenu.png)

We then have to press `New`, select the `Formation` package and chose a name for our production : 

![ProductionCreation](misc/img/ProductionCreation.png)

Immediatly after creating our production, we will need to click on the `Production Settings` just above the `Operations` section. In the right sidebar menu, we will have to activate `Testing Enabled` in the `Development and Debugging` part of the `Settings` tab (don't forget to press Apply).

![ProductionTesting](misc/img/ProductionTesting.png)

In this first production we will now add Business Operations.

## Operations : 

A Business Operation (BO) is a specific operation that will enable us to send requests from IRIS to an external application / system. It can also be used to directly save in IRIS what we want.

We will create those operations in local, that is, in the `Formation/BO` file.

For our first operation we will save the content of a message in  the local database.

We need to have a way of storing this message first. 

### 1. Creating our storage class

Storage classes in IRIS extends the type `%Persistent`. They will be saved in the intern database.

In our `Formation/Table/Formation.cls` file we have : 
```objectscript
Class Formation.Table.Formation Extends %Persistent
{

Property Name As %String;

Property Salle As %String;

}
```

Note that when saving, additional lines are automatically added to the file. They are mandatory and are added by the InterSystems addons.

### 2. Creating our message class

This message will contain a `Formation` object, located in the `Formation/Obj/Formation.cls` file : 
```objectscript
Class Formation.Obj.Formation Extends (%SerialObject, %XML.Adaptor)
{

Property Nom As %String;

Property Salle As %String;

}
```

The `Message` class will use that `Formation`object; `src/Formation/Msg/FormationInsertRequest` :
```objectscript
Class Formation.Msg.FormationInsertRequest Extends Ens.Request
{

Property Formation As Formation.Obj.Formation;

}
```

### 3. Creating our operation : 

Now that we have all the elements we need, we can create our operation, in the `Formation/BO/LocalBDD` file : 
```objectscript
Class Formation.BO.LocalBDD Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Method InsertLocalBDD(pRequest As Formation.Msg.FormationInsertRequest, Output pResponse As Ens.StringResponse) As %Status
{
    set tStatus = $$$OK
    
    try{
        set pResponse = ##class(Ens.Response).%New()
        set tFormation = ##class(Formation.Table.Formation).%New()
        set tFormation.Name = pRequest.Formation.Nom
        set tFormation.Salle = pRequest.Formation.Salle
        $$$ThrowOnError(tFormation.%Save())
    }
    catch exp
    {
        Set tStatus = exp.AsStatus()
    }

    Quit tStatus
}

XData MessageMap
{
<MapItems>
    <MapItem MessageType="Formation.Msg.FormationInsertRequest"> 
        <Method>InsertLocalBDD</Method>
    </MapItem>
</MapItems>
}

}

```

The MessageMap gives us the method to launch depending on the type of the request (the message sent to the operation).

As we can see, if the operation received a message of the type `Formation.Msg.FormationInsertRequest`, the `InsertLocalBDD` method will be called. This method will save the message in the IRIS local database.

### 4. Adding the operation to the production : 

We now need to add this operation to the production. For this, we use the Management Portal. By pressing the `+` sign next to `Operations`, we have access to the Business Operation Wizard. There, we chose the operation class we just created in the scrolling menu. 

![OperationCreation](misc/img/OperationCreation.png)

### 5. Testing the operation : 

Double clicking on the operation will enable us to activate it. After that, by selecting the operation and going in the `Actions` tabs in the right sidebar menu, we should be able to test the operation (if not see the production creation part to activate testings / you may need to start the production if stopped).

By doing so, we will send the operation a message of the type we declared earlier. If all goes well, the results should be as shown below : 

![OperationTest](misc/img/OperationTest.png)

Showing the visual trace will enable us to see what happened between the processes, services and operations. here, we can see the message being sent to the operation by the process, and the operation sending back a response (that is just an empty string).

## Business Processes

Business Processes (BP) are the business logic of our production. They are used to process requests or relay those requests to other components of the production.

Business Processes are created within the Management Portal :

![BPMenu](misc/img/BPMenu.png)

### Simple BP

We are now in the Business Process Designer. We are going to create a simple BP that will call our operation : 

![BPAddingCall](misc/img/BPAddingCall.gif)

A BP has a **Context**. It is composed of a request class, the class of the input, and of a response class, the class of the output. **BP only have one input and one output**. It is also possible to add properties. 

Since our BP will only be used to call our BO, we can put as request class the message class we created.

![BPContext](misc/img/BPContext.png)

We then chose the target of the call function : our BO. That operation, being **called** has a **callrequest** property. We need to bind that callrequest to the request of the BP (they both are of the class ‘Formation.Msg.FormationInsertRequest‘), we do that by clicking on the call function and using the request builder : 

![BPBindRequests](misc/img/BPBindRequests.gif)

We can now save this BP (in the package ‘Formation.BP‘ and under the name ‘InsertLocalBDD‘ for example). Just like the operations, the processes can be instantiated and tested through the production configuration, for that they need to be compiled beforehand (on the Business Process Designer screen).

Our Process for now only passes the message to our Operation. We are going to complexify it so that the BP will take as input one line of a CSV file. 


### BP reading CSV lines

#### Creating a record map

In order to read a file and put its content into a file, we need a record map. There is a Record Mapper sepcialized for CSV files in the `Interoperability > Build` menu of the management portal : 

![RMMenu](misc/img/RMMenu.png)

We will create the mapper like this : 

![RMCreation](misc/img/RMCreation.png)

You should now have this Record Map : 

![RMDetails](misc/img/RMDetails.png)

Now that the Map is created, we need to have a Data Transformation from the record map format and an insertion message.

#### Creating a Data Transformation

