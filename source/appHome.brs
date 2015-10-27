' *********************************************************
' **  Roku Paragraph Demonstration App
' **  Support routines
' **  Feb 2010
' **  Copyright (c) 2010 Roku Inc. All Rights Reserved.
' *********************************************************

'***************************************************
'** Set up the screen in advance before its shown
'** Do any pre-display setup work here
'***************************************************


'********************************************************************
'** selecting close exits the application
'********************************************************************
Function getSchools()
    url="http://hs3.tv/api/list_schools.php"
    xfer=createobject("roURLTransfer")
    xfer.seturl(url)
    data=xfer.gettostring()
    data2 = "{" + Chr(34) + "Schools" + Chr(34) + ":" + data + "}" 
    
   
    Return data2
End Function

Sub showImageCanvas(data)

json = ParseJSON(data)

canvasItems = CreateObject("roArray", json.Schools.count(), false)
location = 100
for each school in json.Schools
 ' print school.school_name


    add = { 
            text: school.school_name
            TargetRect:{x:location,y:location,w:400,h:300}
        }
        
    

    canvasItems.push(add)
location = location + 100
 end for

   canvas = CreateObject("roImageCanvas")
   port = CreateObject("roMessagePort")
   canvas.SetMessagePort(port)
   'Set opaque background
   canvas.SetLayer(0, {Color:"#FF000000", CompositionMode:"Source"})
   canvas.SetRequireAllImagesToDraw(true)
   canvas.SetLayer(1, canvasItems)
   canvas.Show()
   while(true)
       msg = wait(0,port)
       if type(msg) = "roImageCanvasEvent" then
           if (msg.isRemoteKeyPressed()) then
               i = msg.GetIndex()
               print "Key Pressed - " ; msg.GetIndex()
               if (i = 2) then
                   ' Up - Close the screen.
                   canvas.close()
               end if
           else if (msg.isScreenClosed()) then
               print "Closed"
               return
           end if
       end if
   end while
End Sub
