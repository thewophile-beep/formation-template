Class Formation.BO.Router Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Method FindRoute(pRequest As Ens.Request, Output pResponse As Formation.Msg.FormationRouterResponse) As %Status
{
    set tStatus = $$$OK
    
    set pResponse = ##class(Formation.Msg.FormationRouterResponse).%New()
    if pRequest.%IsA("Formation.Msg.FormationInsertRequest") {
        set pResponse.EstInsert = 1
    }
    else {
        set pResponse.EstInsert = 0
    }
    

    Quit tStatus
}

XData MessageMap
{
<MapItems>
    <MapItem MessageType="Ens.Request"> 
        <Method>FindRoute</Method>
    </MapItem>
</MapItems>
}

}
