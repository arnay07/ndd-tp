Class esb.BS.API Extends esb.REST.Base
{

Parameter Version = "1.0.6";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Server Info -->
<Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
<!-- Swagger specs -->
<Route Url="/_spec" Method="GET" Call="SwaggerSpec" />
<!-- Sinistre-->
<Route Url="/reservation/sinistre" Method="POST" Call="reservationSinistre"/>
</Routes>
}

/// PersonsREST general information
ClassMethod GetInfo() As %Status
{
  SET version = ..#Version
  SET info = {
    "version": (version)
  }
  RETURN ..%ProcessResult($$$OK, info)
}

ClassMethod SwaggerSpec() As %Status
{
  Set tSC = ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)
  Do swagger.info.%Remove("x-ISC_Namespace")
  Set swagger.basePath = "/crud"
  Set swagger.info.title = "InterSystems IRIS REST CRUD demo"
  Set swagger.info.version = "0.1"
  Set swagger.host = "localhost:52773"
  Return ..%ProcessResult($$$OK, swagger)
}

ClassMethod reservationSinistre() As %Status
{
    #dim tSC As %Status = $$$OK
    Set msg = ##class(esb.msg.reservationSinistreDmde).%New()

    Set data=%request.Content
    $$$TOE(tSC,msg.%JSONImport(data))

    set tSC = ##class(Ens.Director).CreateBusinessService("ServiceSinistreReservation",.tService) if $$$ISERR(tSC) quit 
    set tSC = tService.ProcessInput(msg,.response,"reservationSinistre")
    Set %response.Status = 200
    Set %response.ContentType = ..#CONTENTTYPEJSON
    Do response.%JSONExport()
    Quit tSC
}

}
