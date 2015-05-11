xquery version "1.0";

declare namespace html="http://www.w3.org/1999/xhtml";
declare namespace xf="http://www.w3.org/2002/xforms";

(:~
 : Note need to add app:dir var, and use in configuring css
:)

(:~
: Here $node is the document or XML fragment to work on, 
: $new-node is the new element to insert, 
: $element-name-to-check is which other element to use as a reference for inserting $new-node, 
: and $location gives the option of inserting $new-node before, after, or as the first or last child of $element-name-to-check. 
: $location accepts four values: 'before', 'after', 'first-child', and 'last-child' 
: (if another value is given, $element-name-to-check is removed).
:
: @author Jens Østergaard Petersen
: @param $node The XML document or fragment that one wishes to insert elements into.
: @param $new-node The element to insert.
: @param $element-name-to-check The element in $node in relation to which to insert $new-node.
: @param $location The location one wishes to insert $new-node in relation to $element-name-to-check. 
    The options are "before", "after", "first-child" and "last-child". 
: @return $node with $new-node inserted in the $location in relation to $element-name-to-check
:
: Adapted for use with teian and syriaca.org tei records
: @author Winona Salesky

        <link rel="stylesheet" type="text/css" href="/db/apps/shared-resources/resources/css/bootstrap-3.0.3.min.css"/>
        <!-- Latest compiled and minified CSS -->
        <script type="text/javascript" src="resources/scripts//jquery-1.7.1.min.js"/>
        <script type="text/javascript" src="resources/scripts/bootstrap-3.0.3.min.js"/>
:)
declare function local:insert-element($node as node()?, $new-node as node(), 
    $element-name-to-check as xs:string, $location as xs:string) { 
        if (local-name($node) eq $element-name-to-check)
        then
            if ($location eq 'before')
            then ($new-node, $node) 
            else 
                if ($location eq 'after')
                then ($node, $new-node)
                else
                    if ($location eq 'first-child')
                    then element { node-name($node) } { 
                        $node/@*
                        ,
                        $new-node
                        ,
                        for $child in $node/node()
                            return 
                                (:local:insert-element($child, $new-node, $element-name-to-check, $location):)
                                $child
                    }
                    else
                        if ($location eq 'last-child')
                        then element { node-name($node) } { 
                            $node/@*
                            ,
                            for $child in $node/node()
                                return 
                                    (:local:insert-element($child, $new-node, $element-name-to-check, $location):)
                                    $child 
                            ,
                            $new-node
                        }
                        else () (:The $element-to-check is removed if none of the four options are used.:)
        else
            if ($node instance of element()) 
            then
                element { node-name($node) } { 
                    $node/@*
                    , 
                    for $child in $node/node()
                        return 
                            local:insert-element($child, $new-node, $element-name-to-check, $location) 
             }
         else $node
};

let $form-name := request:get-parameter("form", "")
let $form-path := $form-name
let $form-doc := doc($form-path)
let $form-description := <div class="description">Place holder</div>
let $form-doc := local:insert-element($form-doc, $form-description, 'iframe', 'remove')   
let $dummy := request:set-attribute("betterform.filter.ignoreResponseBody", "true")
let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/exist/rest/db/apps/xsltforms/xsltforms.xsl"'}
let $css-pi := processing-instruction css-conversion {'no'}
let $debug := processing-instruction xsltforms-options {'debug="yes"'}
return ($xslt-pi,$css-pi, $debug, $form-doc)