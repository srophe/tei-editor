xquery version "3.0";
(:~
 : Submit new data to data folder for review
 : Send email alert to appropriate editor?
:)
declare namespace request="http://exist-db.org/xquery/request";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:media-type "text/xml";

(:~
let $data-root := xs:anyURI('/db/apps/srophe-forms/forms/data/')
let $cache := 'change value to force refresh: 344' 
let $results := request:get-data()     
let $file-name := concat('new', '.xml')
let $path-name := concat($data-root, $file-name)
'/db/apps/srophe-data/data/'
:)

let $data-root := '/db/apps/srophe-data/data/'
let $cache := 'change value to force refresh: 344' 
let $results := request:get-data()
let $id := replace($results/descendant::tei:idno[1],'/tei','')
let $id :=
   if (exists($id))
      then $id
   else 'data/new'      
let $file-name := concat(tokenize($id,'/')[last()], '.xml')
let $collection :=
    if(contains($id,'/place/')) then concat($data-root,'places/tei')
    else if(contains($id,'/person')) then concat($data-root,'persons/tei')
    else if(contains($id,'/bibl')) then concat($data-root,'bibl/tei')
    else if(contains($id,'/manuscript')) then concat($data-root,'manuscripts/tei')
    else if(contains($id,'/work')) then concat($data-root,'works/tei')
    else 'data'
let $path-name := 
    if(contains($id, '/place')) then concat($data-root, 'places/tei/', $file-name)
    else if(contains($id, '/person')) then concat($data-root, 'persons/tei/', $file-name)
    else if(contains($id, '/bibl')) then concat($data-root, 'bibl/tei/', $file-name)
    else if(contains($id,'/manuscript')) then concat($data-root, 'manuscripts/tei/', $file-name)
    else if(contains($id,'/work')) then concat($data-root, 'works/tei/', $file-name)
    else concat('/db/apps/tei-editor/forms/data/', $file-name)
return 
        try {
        <data code="200">
            <message path="{$path-name}">New document saved: { xmldb:store($collection, $file-name, $results)}</message>
        </data>
        } catch * {
        <data code="500">
            <message path="{$path-name}">Caught error {$err:code}: {$err:description}</message>
        </data>            
        }