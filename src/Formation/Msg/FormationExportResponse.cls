Class Formation.Msg.FormationExportResponse Extends Ens.Response
{

Property Formation As Formation.Obj.Formation;

Property Id As %Integer;

Storage Default
{
<Data name="FormationInsertResponseDefaultData">
<Subscript>"FormationInsertResponse"</Subscript>
<Value name="1">
<Value>Doublon</Value>
</Value>
<Value name="2">
<Value>Formation</Value>
</Value>
<Value name="3">
<Value>Id</Value>
</Value>
</Data>
<DefaultData>FormationInsertResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
