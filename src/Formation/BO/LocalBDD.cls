Class Formation.BO.LocalBDD Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Method InsertLocalBDD(pRequest As Formation.Msg.FormationInsertRequest, Output pResponse As Formation.Msg.FormationInsertResponse) As %Status
{
    set tStatus = $$$OK
    
    try{
        set pResponse = ##class(Formation.Msg.FormationInsertResponse).%New()
        set tFormation = ##class(Formation.Table.Formation).%New()
        set tFormation.Name = pRequest.Formation.Nom
        set tFormation.Salle = pRequest.Formation.Salle
        $$$ThrowOnError(tFormation.%Save())
        if $RANDOM(10) < 5 {
            set pResponse.Doublon = 1
        } 
        else {
            set pResponse.Doublon = 0
        }
    }
    catch exp
    {
        Set tStatus = exp.AsStatus()
    }

    Quit tStatus
}

Method ExportLocalBDD(pRequest As Formation.Msg.FormationExportRequest, Output pResponse As Formation.Msg.FormationExportResponse) As %Status
{
    set tStatus = $$$OK
    
    try{
        set pResponse = ##class(Formation.Msg.FormationExportResponse).%New()
        set ^LOGINFO2 = "yes"

        set tFormation = ##class(Formation.Table.Formation).%OpenId(pRequest.Id)
        set pResponse.Formation.Nom = tFormation.Name
        set pResponse.Formation.Salle = tFormation.Salle
        set pResponse.Id = pRequest.Id
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
    <MapItem MessageType="Formation.Msg.FormationExportRequest">
        <Method>ExportLocalBDD</Method>
    </MapItem>
</MapItems>
}

}
