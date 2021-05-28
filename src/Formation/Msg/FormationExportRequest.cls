Class Formation.Msg.FormationExportRequest Extends Ens.Request
{

Property Id As %Integer;

Storage Default
{
<Data name="FormationInsertRequestDefaultData">
<Subscript>"FormationInsertRequest"</Subscript>
<Value name="1">
<Value>Formation</Value>
</Value>
<Value name="2">
<Value>Id</Value>
</Value>
</Data>
<DefaultData>FormationInsertRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
